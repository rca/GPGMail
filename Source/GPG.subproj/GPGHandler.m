/* GPGHandler.m created by stephane on Fri 30-Jun-2000 */

/*
 * Copyright (c) 2000-2011, GPGTools Project Team <gpgtools-devel@lists.gpgtools.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGTools Project Team nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGTools Project Team ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGTools Project Team BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "GPGHandler.h"
#import "GPGDefaults.h"

#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSPanel.h>


NSString *GPGHandlerException = @"GPGHandlerException";


#define NOTHING_READ 0
#define READ_STDOUT  (1 << 0)
#define READ_STDERR  (1 << 1)
#define READ_ALL     (READ_STDOUT | READ_STDERR)


@interface GPGHandler (Private)
- (NSException *)runGpgTaskWithArguments:(NSArray *)arguments passphrase:(NSString *)passphrase inputData:(NSData *)inputData outputData:(NSData **)outputData errorData:(NSData **)errorData encoding:(CFStringEncoding)encoding;
+ (NSString *)defaultHashAlgorithm;
@end


@implementation GPGHandler

static NSString *_gpgPath = nil;
static NSArray *_knownHashAlgorithms = nil;
static NSString *_defaultHashAlgorithm = nil;
static BOOL _blindlyTrustAllKeysForEncryption = NO;

+ (void)initialize {
	// Do not call super - see +initialize documentation
	if (_defaultHashAlgorithm == nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:[NSApplication sharedApplication]];
		(void)[self defaultHashAlgorithm];                         // We need this to know ASAP which gpg version we're running
	}
}

+ (id)handler {
	GPGHandler *newHandler = [[self alloc] init];

	return [newHandler autorelease];
}

+ (void)applicationWillTerminate:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:[notification name] object:[notification object]];
	[self clearCache];
}

+ (void)clearCache {
	[_gpgPath release];
	_gpgPath = nil;
	[_knownHashAlgorithms release];
	_knownHashAlgorithms = nil;
	[_defaultHashAlgorithm release];
	_defaultHashAlgorithm = nil;
}

+ (NSData *)convertedStringData:(NSData *)data fromEncoding:(CFStringEncoding)originalEncoding toEncoding:(CFStringEncoding *)newEncoding {
	NSParameterAssert(newEncoding != NULL);
	switch (originalEncoding) {
		case kCFStringEncodingISOLatin1:
		case kCFStringEncodingISOLatin2:
		case kCFStringEncodingKOI8_R:
		case kCFStringEncodingISO_2022_JP:                                                                                   // Tomio addition 28.04.05
		case kCFStringEncodingUTF8:
		case kCFStringEncodingASCII:                                                                                         // We'll us iso8859-1 for gpg; would cause problem if comment contains non-ASCII chars...
			*newEncoding = originalEncoding;
			return data;
		default: {
			CFStringRef aString = CFStringCreateFromExternalRepresentation(NULL, (CFDataRef)data, originalEncoding);             /* May return NULL on conversion error */
			CFDataRef outputData;

			NSAssert(aString != NULL, @"Unable to convert back to string!");
			outputData = CFStringCreateExternalRepresentation(NULL, aString, kCFStringEncodingISOLatin1, 0);                     /* May return NULL on conversion error */
			if (outputData == NULL) {
				outputData = CFStringCreateExternalRepresentation(NULL, aString, kCFStringEncodingISOLatin2, 0);
				if (outputData == NULL) {
					outputData = CFStringCreateExternalRepresentation(NULL, aString, kCFStringEncodingKOI8_R, 0);
					if (outputData == NULL) {
						outputData = CFStringCreateExternalRepresentation(NULL, aString, kCFStringEncodingISO_2022_JP, 0);
						if (outputData == NULL) {
							outputData = CFStringCreateExternalRepresentation(NULL, aString, kCFStringEncodingUTF8, 0);
							NSAssert(outputData != NULL, @"Unable to convert string to UTF-8!!!");
							*newEncoding = kCFStringEncodingUTF8;
						} else {
							*newEncoding = kCFStringEncodingISO_2022_JP;
						}
					} else {
						*newEncoding = kCFStringEncodingKOI8_R;
					}
				} else {
					*newEncoding = kCFStringEncodingISOLatin2;
				}
			} else {
				*newEncoding = kCFStringEncodingISOLatin1;
			}

			CFRelease(aString);

			return [(NSData *) outputData autorelease];
		}
	}
}

static NSString * stringForEncoding(CFStringEncoding encoding){
	switch (encoding) {
		case kCFStringEncodingISOLatin1:
		case kCFStringEncodingASCII:
			return @"iso-8859-1";
		case kCFStringEncodingISOLatin2:
			return @"iso-8859-2";
		case kCFStringEncodingKOI8_R:
			return @"koi8-r";
		case kCFStringEncodingUTF8:
			return @"utf-8";
		default:
			// Let's use a default encoding instead of raising an exception.
			// This gives user a chance to see message, even if some
			// chars a not displayed correctly.
			NSLog(@"### GPGMail: stringForEncoding(): unknown encoding %@ (%d) => using iso-8859-1", CFStringGetNameOfEncoding(encoding), encoding);
			return @"iso-8859-1";
	}
}

+ (NSArray *)knownHashAlgorithms {
	if (_knownHashAlgorithms == nil) {
		NSException *runException;
		NSData *outputData;

#warning Called more than once!
// NSLog(@"Launching --version");
		runException = [[self handler] runGpgTaskWithArguments:[NSArray arrayWithObject:@"--version"] passphrase:nil inputData:nil outputData:&outputData errorData:NULL encoding:kCFStringEncodingUTF8];
		if (!runException) {
			NSString *stdoutString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
			NSScanner *aScanner = [NSScanner scannerWithString:stdoutString];

			// gpg (GnuPG) 1.0.6
			// Copyright (C) 1999 Free Software Foundation, Inc.
			// This program comes with ABSOLUTELY NO WARRANTY.
			// This is free software, and you are welcome to redistribute it
			// under certain conditions. See the file COPYING for details.
			//
			// Home: ~/.gnupg
			// Supported algorithms:
			// Cipher: 3DES, CAST5, BLOWFISH, TWOFISH
			// Pubkey: ELG-E, DSA, ELG
			// Hash: MD5, SHA1, RIPEMD160

			if ([stdoutString hasPrefix:@"gpg (GnuPG) 1.0.4"] || [stdoutString hasPrefix:@"gpg (GnuPG) 1.0.5"]) {
				// We need to know this, because one of the feature we rely on is not present before 1.0.6
				[NSException raise:NSGenericException format:@"GPGMail doesn't support gpg version < 1.0.6."];
			}
			if (![stdoutString hasPrefix:@"gpg (GnuPG) 1.0.6"]) {
				_blindlyTrustAllKeysForEncryption = YES;                                                  // We will use --always-trust for encryption

			}
			if ([aScanner scanUpToString:@"Hash: " intoString:NULL] && ![aScanner isAtEnd]) {
				NSString *algoString;

				NSAssert1([aScanner scanString:@"Hash: " intoString:NULL], @"### GPGMail: %s: Unable to scan the same string twice?!", __PRETTY_FUNCTION__);
				NSAssert1([aScanner scanUpToString:@"\n" intoString:&algoString], @"### GPGMail: %s: No EOL on Hash line?!", __PRETTY_FUNCTION__);
				algoString = [algoString lowercaseString];
				_knownHashAlgorithms = [algoString componentsSeparatedByString:@", "];
			}
			if (_knownHashAlgorithms == nil || [_knownHashAlgorithms count] == 0) {
				NSLog(@"### GPGMail: %s: Unable to retrieve known hash algorithms! Forcing use of SHA1.\n%@", __PRETTY_FUNCTION__, stdoutString);
				_knownHashAlgorithms = [NSArray arrayWithObjects:@"SHA1", nil];
			}
			[stdoutString release];
			[_knownHashAlgorithms retain];
		} else {
			[runException raise];
		}
	}

	return _knownHashAlgorithms;
}

+ (NSString *)defaultHashAlgorithm {
	if (_defaultHashAlgorithm == nil) {
		NSString *anAlgo = [[GPGDefaults gpgDefaults] stringForKey:@"GPGHashAlgorithm"];

		if (anAlgo == nil || [anAlgo length] == 0) {
			anAlgo = [[self knownHashAlgorithms] objectAtIndex:0];
		} else {
			anAlgo = [anAlgo lowercaseString];
			NSAssert3([[self knownHashAlgorithms] containsObject:anAlgo], @"### GPGMail: %s: Unknown hash algorithm '%@'. Known hash algorithms: %@", __PRETTY_FUNCTION__, anAlgo, [self knownHashAlgorithms]);
		}

		_defaultHashAlgorithm = [anAlgo retain];
	}

	return _defaultHashAlgorithm;
}

/*+ (NSString *)gpgPath {
	if (_gpgPath == nil) {
		_gpgPath = [[[GPGEngine engineForProtocol:GPGOpenPGPProtocol] executablePath] retain];
	}
	return _gpgPath;
}*/

- (id)init {
	if ((self = [super init]) != nil) {
		readLock = [[NSConditionLock alloc] initWithCondition:NOTHING_READ];
	}

	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[readLock release];
	[stderrData release];
	[stdoutData release];
	[statusData release];
	[currentTask release];

	[super dealloc];
}

- (NSString *)gpgPath {
	return [[self class] gpgPath];
}

static NSArray * recipientArgumentsFromSenderAndArguments(NSString *sender, NSArray *recipients){
// We add the sender to the recipients list, so user can always decrypt data he has encrypted
// This can be disabled with userDefault GPGEncryptsToSelf set to NO.
	int recipientsCount = [recipients count];
	NSMutableArray *recipientArgs = [NSMutableArray arrayWithCapacity:2 * recipientsCount + 2];
	int i;

	for (i = 0; i < recipientsCount; i++) {
		NSString *aRecipient = [recipients objectAtIndex:i];

		if ([recipientArgs containsObject:aRecipient]) {
			// No need to add the same recipient more than once; gpg probably checks this too.
			continue;
		}
		[recipientArgs addObject:@"--recipient"];
		[recipientArgs addObject:aRecipient];
	}

	if (![recipientArgs containsObject:sender] && [[GPGDefaults gpgDefaults] boolForKey:@"GPGEncryptsToSelf"]) {
		[recipientArgs addObject:@"--recipient"];
		[recipientArgs addObject:sender];
	}

	return recipientArgs;
}

- (NSException *)displayableExceptionFromException:(NSException *)exception {
	if ([[exception name] isEqualToString:GPGHandlerException]) {
		NSString *errorString = [[exception userInfo] objectForKey:@"Error"];
		NSArray *errorLines = [errorString componentsSeparatedByString:@"\n"];
		int errorLineCount = [errorLines count], i;
		NSMutableArray *filteredErrorLines = [NSMutableArray arrayWithCapacity:errorLineCount];

		for (i = 0; i < errorLineCount; i++) {
			NSString *errorLine = [errorLines objectAtIndex:i];

			// Skip first two lines:
			// gpg: can't mmap pool of 16384 bytes: Invalid argument - using malloc
			// gpg: Please note that you don't have secure memory on this system
			if ([errorLine hasPrefix:@"gpg: can't mmap"] || [errorLine hasPrefix:@"gpg: Please note that"]) {
				continue;
			}

			if ([errorLine hasPrefix:@"gpg: "]) {
				if ([errorLine length] > 5) {
					[filteredErrorLines addObject:[errorLine substringFromIndex:5]];
				}
			} else {
				[filteredErrorLines addObject:errorLine];
			}
		}
		errorString = [filteredErrorLines componentsJoinedByString:@"\n"];

		return [NSException exceptionWithName:GPGHandlerException reason:errorString userInfo:[exception userInfo]];
	} else {
		return exception;
	}
}

- (void)readStderr:(NSNotification *)notification {
	[readLock lock];
	stderrData = [[[notification userInfo] objectForKey:NSFileHandleNotificationDataItem] retain];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:[notification name] object:[notification object]];
	[readLock unlockWithCondition:[readLock condition] | READ_STDERR];
}

- (void)readStdout:(NSNotification *)notification {
	[readLock lock];
	stdoutData = [[[notification userInfo] objectForKey:NSFileHandleNotificationDataItem] retain];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:[notification name] object:[notification object]];
	[readLock unlockWithCondition:[readLock condition] | READ_STDOUT];
}

- (NSException *)runGpgTaskWithArguments:(NSArray *)arguments passphrase:(NSString *)passphrase inputData:(NSData *)inputData outputData:(NSData **)outputData errorData:(NSData **)errorData encoding:(CFStringEncoding)encoding {
	NSPipe *stdinPipe = [NSPipe pipe];
	NSPipe *stdoutPipe = [NSPipe pipe];
	NSPipe *stderrPipe = [NSPipe pipe];
	NSException *result = nil;
	NSArray *defaultArguments;
	NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithDictionary:[[NSProcessInfo processInfo] environment]];              // We MUST add current environment!!
	NSData *passphraseData;

	operationCancelled = NO;

	if (passphrase != nil) {
		passphraseData = (NSData *)CFStringCreateExternalRepresentation(NULL, (CFStringRef)[passphrase stringByAppendingString: @"\n"], encoding, 0);
#warning We should modify message encoding...
		NSAssert2(passphraseData != nil, @"### GPGMail: %s: unable to encode passphrase using encoding %@! Please don't use non-ASCII characters for your passphrase, or use UTF-8 in Mail.", __PRETTY_FUNCTION__, stringForEncoding(encoding));
	} else {
		passphraseData = nil;
	}

	currentTask = [[NSTask alloc] init];
	[currentTask setLaunchPath:[self gpgPath]];

	// WARNING: with gpg < 1.0.6, --charset utf-8 is not recognized as a valid option!
	defaultArguments = [NSArray arrayWithObjects:@"--no-verbose", @"--batch", @"--no-tty", /*@"--utf8-strings",*/ @"--charset", stringForEncoding(encoding), nil];
	[currentTask setArguments:[defaultArguments arrayByAddingObjectsFromArray:arguments]];             // Should we add --openpgp argument?
	[currentTask setStandardInput:stdinPipe];
	[currentTask setStandardOutput:stdoutPipe];
	[currentTask setStandardError:stderrPipe];
	// Let's set env variables used by GNU text localization
	// We can parse only English strings...
	[environment setObject:@"en_US.UTF-8" forKey:@"LANG"];
	[environment setObject:@"en_US.UTF-8" forKey:@"LANGUAGE"];
	[environment setObject:@"en_US.UTF-8" forKey:@"LC_ALL"];
	[environment setObject:@"en_US.UTF-8" forKey:@"LC_MESSAGE"];
	[currentTask setEnvironment:environment];

	if ([[GPGDefaults gpgDefaults] boolForKey:@"GPGTraceEnabled"]) {
		NSLog(@"----------\n%@ %@", [currentTask launchPath], [[currentTask arguments] componentsJoinedByString:@" "]);
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readStderr:) name:NSFileHandleReadToEndOfFileCompletionNotification object:[stderrPipe fileHandleForReading]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readStdout:) name:NSFileHandleReadToEndOfFileCompletionNotification object:[stdoutPipe fileHandleForReading]];

	@try{
		NSException *writeException = nil;

		[currentTask launch];
		// We need to read the pipes asynchronously, as we cannot poll more than one pipe:
		// If we use non-blocking methods (provided by bbum's category), sometimes the task
		// seems to be never-ending! If we use blocking methods, well, we are blocked if
		// data size is larger than 4k (pipe buffer size).
		// By using asynchronous reading, we need to wait for the end of reading, that's why we
		// use a NSConditionLock to make the synchronization. Does anyone have a better idea?
		// We NEED to make the following 2 calls before writing data to stdin, else it blocks
		// if inputData is large.
		// BUG: if user enters wrong passphrase, Mail throws a SIGPIPE signal which
		// results in a warning for the user; he can ignore it.
		[[stderrPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
		[[stdoutPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
		if (passphraseData != nil) {
			// Problem: if we write passphrase + data in one pass, then if passphrase
			// is wrong, data cannot be written, because task has terminated,
			// and system raises a SIGPIPE exception that we cannot catch.
			// To workaround this problem (this will be corrected with MacGPGME),
			// we write passphrase, then wait 1 second, and check if stdout and stderr
			// pipes have been closed, meaning that there was an error with passphrase.
			@try{
				[[stdinPipe fileHandleForWriting] writeData:passphraseData];                                                 // SIGPIPE might be thrown here
			}@catch (NSException *localException) {
				writeException = localException;
				inputData = nil;
			}
			if (inputData != nil) {
				[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
				if ([readLock tryLockWhenCondition:READ_ALL]) {
					inputData = nil;
					[readLock unlock];
				}
			}
		}
		if (inputData != nil) {
#ifdef DEBUG
			[inputData writeToFile:[NSTemporaryDirectory () stringByAppendingPathComponent:[@"stdin-" stringByAppendingString:[[NSProcessInfo processInfo] globallyUniqueString]]] atomically:NO];
#endif
			@try{
				if ([[GPGDefaults gpgDefaults] boolForKey:@"GPGTraceEnabled"]) {
					CFStringRef aString = CFStringCreateFromExternalRepresentation(NULL, (CFDataRef)inputData, encoding);

					NSLog(@"IN: %@", aString);
					CFRelease(aString);
				}
				[[stdinPipe fileHandleForWriting] writeData:inputData];                 // SIGPIPE might be thrown here
			}@catch (NSException *localException) {
				writeException = localException;
			}
		}
		[[stdinPipe fileHandleForWriting] closeFile];                           // We need to inform task that we do not have any more data for it!

		// It seems we need to run the current runloop for some more time, as notifications
		// are not yet all posted...
		while ([readLock tryLockWhenCondition:READ_ALL] == NO)
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

		// Rendez-vous
		[readLock unlockWithCondition:NOTHING_READ];

		[currentTask waitUntilExit];                         // Couldn't we put this call before the rendez-vous?!

		if ([[GPGDefaults gpgDefaults] boolForKey:@"GPGLogStderrEnabled"]) {
			CFStringRef aString = CFStringCreateFromExternalRepresentation(NULL, (CFDataRef)stderrData, encoding);

			NSLog(@"%@", aString);
			CFRelease(aString);
		}
		if (!operationCancelled) {
#ifdef DEBUG
			[stdoutData writeToFile:[NSTemporaryDirectory () stringByAppendingPathComponent:[@"stdout-" stringByAppendingString:[[NSProcessInfo processInfo] globallyUniqueString]]] atomically:NO];
#endif
			if ([[GPGDefaults gpgDefaults] boolForKey:@"GPGTraceEnabled"]) {
				CFStringRef aString = CFStringCreateFromExternalRepresentation(NULL, (CFDataRef)stdoutData, encoding);

				NSLog(@"=> %@", aString);
				CFRelease(aString);
				if ([[GPGDefaults gpgDefaults] boolForKey:@"GPGLogStderrEnabled"]) {
					NSLog(@"#Termination status: %d", [currentTask terminationStatus]);
				} else {
					aString = CFStringCreateFromExternalRepresentation(NULL, (CFDataRef)stderrData, encoding);
					NSLog(@"#%d: %@", [currentTask terminationStatus], aString);
					CFRelease(aString);
				}
			}

			// It can happen that returned status is 0 (no error), but according to stdout
			// we should consider the task has failed.
			// e.g. trying to encrypt with a key which is not trusted returns no error
			// (if at least another key was trusted), but in our case it should be considered
			// as an error!
			if ([currentTask terminationStatus]) {
				NSString *stderrString = (NSString *)CFStringCreateFromExternalRepresentation(NULL, (CFDataRef)stderrData, encoding);

				result = [NSException exceptionWithName:GPGHandlerException reason:NSLocalizedStringFromTableInBundle(@"Error after gpg execution", @"GPG", [NSBundle bundleForClass:[self class]], "") userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[currentTask terminationStatus]], @"TerminationStatus", stderrString, @"Error", nil]];
				[stderrString release];
				// BUG: special case: decrypt + authenticate. Message could be decrypted
				// successfully, but authentication failed (forged sig, missing pubkey, ...)
				// => we should display decrypted message to user, but warn him than
				// message could not be authenticated!
				// Currently, there is no way with our API to do this!
				// This will be solved with MacGPGME.
			} else {
				// Let's check stderr content...
				NSString *stderrString = (NSString *)CFStringCreateFromExternalRepresentation(NULL, (CFDataRef)stderrData, encoding);

				if ([stderrString rangeOfString:@"no info to calculate a trust probability"].length > 0) {
					result = [NSException exceptionWithName:GPGHandlerException reason:NSLocalizedStringFromTableInBundle(@"Error after gpg execution", @"GPG", [NSBundle bundleForClass:[self class]], "") userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[currentTask terminationStatus]], @"TerminationStatus", stderrString, @"Error", nil]];
				}
				[stderrString release];
			}
		} else {
			[stdoutData release];
			stdoutData = nil;
			[stderrData release];
			stderrData = nil;
			result = [NSException exceptionWithName:GPGHandlerException reason:NSLocalizedStringFromTableInBundle(@"gpg execution manually interrupted", @"GPG", [NSBundle bundleForClass:[self class]], "") userInfo:nil];
			if ([[GPGDefaults gpgDefaults] boolForKey:@"GPGTraceEnabled"]) {
				NSLog(@"## gpg manually interrupted");
			}
		}
		if (outputData != NULL) {
			*outputData = stdoutData;
		}
		if (errorData != NULL) {
			*errorData = stderrData;
		}
	}@catch (NSException *localException) {
		result = localException;
	}

	if (passphraseData != NULL) {
		CFRelease((CFDataRef)passphraseData);
	}
	[currentTask release];
	currentTask = nil;
	[stderrData autorelease];             // Do NOT release it, as we passed it as a return parameter
	stderrData = nil;
	[stdoutData autorelease];             // Do NOT release it, as we passed it as a return parameter
	stdoutData = nil;

	if (result && !operationCancelled) {
		result = [self displayableExceptionFromException:(NSException *)result];
	}

	return (NSException *)result;
}

- (NSData *)encryptData:(NSData *)data withSignatureType:(GPGMessageSignatureType)signatureType sender:(NSString *)sender passphrase:(NSString *)passphrase recipients:(NSArray *)recipients encoding:(CFStringEncoding)encoding {
	// If we want a detached signature, we need to call gpg twice:
	// the first time with only encryption,
	// and the second time with only detached signature.
	// We cannot retrieve both a detached signature and an encrypted data.
	NSException *runException;
	NSData *outputData = nil;
	NSMutableArray *arguments;

	NSParameterAssert(data != NULL);
	NSParameterAssert(sender != nil);
	NSParameterAssert(recipients != nil);

	arguments = [NSMutableArray arrayWithArray:recipientArgumentsFromSenderAndArguments(sender, recipients)];
	if (signatureType == GPGInlineSignature) {
		[arguments addObjectsFromArray:[NSArray arrayWithObjects:@"--local-user", sender, @"--passphrase-fd", @"0", @"--sign", nil]];
	}
	[arguments addObjectsFromArray:[NSArray arrayWithObjects:@"--digest-algo", [self defaultHashAlgorithm], @"--textmode", @"--armor", @"--encrypt", nil]];             // According to doc, --encrypt must be added AFTER --recipient
#warning Using --always-trust when encrypting!
	// With gpg 1.0.6, if we use a key which has not been signed by ours,
	// encryption aborts with an error.
	// With gpg 1.0.7, this is no longer the case: encryption is done, but only
	// with keys that have been signed by ours!
	// In order to avoid (workaround...) the problem of sending mails
	// missing (unsigned) receiver keys, we decide to trust all keys blindly,
	// by using --always-trust.
	if (_blindlyTrustAllKeysForEncryption) {
		[arguments insertObject:@"--always-trust" atIndex:[arguments count] - 1];
	}

	if (signatureType == GPGNoSignature) {
		passphrase = nil;
	}

	runException = [self runGpgTaskWithArguments:arguments passphrase:passphrase inputData:data outputData:&outputData errorData:NULL encoding:encoding];

	if (runException) {
		[runException raise];
	}

	return outputData;
}

- (NSData *)signData:(NSData *)data sender:(NSString *)sender passphrase:(NSString *)passphrase detachedSignature:(BOOL)detachedSignature encoding:(CFStringEncoding)encoding {
	NSException *runException;
	NSData *outputData = nil;
	NSMutableArray *arguments;

	NSParameterAssert(data != NULL);
	NSParameterAssert(sender != nil);
	NSParameterAssert(passphrase != nil);

	arguments = [NSMutableArray arrayWithObjects:@"--digest-algo", [self defaultHashAlgorithm], @"--textmode", @"--local-user", sender, @"--passphrase-fd", @"0", @"--armor", nil];
	if (detachedSignature) {
		[arguments addObject:@"--detach-sig"];
	} else {
		[arguments addObject:@"--clearsign"];
	}

#ifdef DEBUG
	[data writeToFile:@"/tmp/unsigned.data" atomically:NO];
#endif

	runException = [self runGpgTaskWithArguments:arguments passphrase:passphrase inputData:data outputData:&outputData errorData:NULL encoding:encoding];

	if (!runException) {
#ifdef DEBUG
		[outputData writeToFile:@"/tmp/signed.data" atomically:NO];
#endif
	} else {
		[runException raise];
	}

	return outputData;
}

static NSString * extractSignaturesFromData(NSData *data, CFStringEncoding encoding){
	NSString *stderrString = (NSString *)CFStringCreateFromExternalRepresentation(NULL, (CFDataRef)data, encoding);
	NSArray *stderrLines = [stderrString componentsSeparatedByString:@"\n"];
	int count = [stderrLines count], i;
	int start, end;
	NSMutableString *signature = [NSMutableString string];

	// gpg: can't mmap pool of 16384 bytes: Invalid argument - using malloc
	// gpg: Please note that you don't have secure memory on this system
	// gpg: Signature made 07/04/00 19:25:39 CEST using DSA key ID 12345678
	// gpg: Good signature from "GPGTools Project Team <gpgtools-devel@lists.gpgtools.org>"
	//

	// gpg: Please note that you don't have secure memory on this system
	// gpg: Signature made 01/04/01 17:04:11 CET using DSA key ID 12345678
	// gpg: Good signature from "GPGTools Project Team <gpgtools-devel@lists.gpgtools.org>"
	// gpg: WARNING: This key is not certified with a trusted signature!
	// gpg:          There is no indication that the signature belongs to the owner.
	// gpg: Fingerprint: xxxx xxxx
	//

	// warning Might return many signatures
	for (i = 0; i < count; i++) {
		NSString *aLine = [stderrLines objectAtIndex:i];

		if ([aLine hasPrefix:@"gpg: Good signature"]) {
			start = [aLine rangeOfString:@"\""].location + 1;
			end = [aLine rangeOfString:@"\"" options:NSBackwardsSearch].location;
			if ([signature length] > 0) {
				[signature appendString:@", "];
			}
			[signature appendString:[aLine substringWithRange:NSMakeRange(start, end - start)]];
		} else if ([signature length] > 0) {
			// Append remaining lines (without gpg: )
			if ([aLine length] > 0) {
				[signature appendString:@"\n"];
				if ([aLine hasPrefix:@"gpg: "]) {
					[signature appendString:[aLine substringFromIndex:5]];
				} else {
					[signature appendString:aLine];
				}
			}
		}
	}
	[stderrString release];

	if ([signature length] > 0) {
		return signature;
	} else {
		return nil;
	}
}

- (NSData *)decryptData:(NSData *)data passphrase:(NSString *)passphrase signature:(NSString **)signature encoding:(CFStringEncoding)encoding {
	NSException *runException;
	NSData *errorData;
	NSData *outputData = nil;
	NSArray *arguments;

	NSParameterAssert(data != NULL);
	NSParameterAssert(passphrase != nil);

	arguments = [NSArray arrayWithObjects:@"--passphrase-fd", @"0", @"--decrypt", nil];

	runException = [self runGpgTaskWithArguments:arguments passphrase:passphrase inputData:data outputData:&outputData errorData:&errorData encoding:encoding];

	if (!runException) {
		if (signature != NULL) {
			*signature = extractSignaturesFromData(errorData, encoding);
		}
	} else {
		[runException raise];
	}

	return outputData;
}

- (NSString *)authenticationSignatureFromData:(NSData *)signedData encoding:(CFStringEncoding)encoding {
	NSException *runException;
	NSData *errorData = nil;
	NSData *outputData;
	NSArray *arguments;

	NSParameterAssert(signedData != nil);

	arguments = [NSArray arrayWithObject:@"--verify"];

	runException = [self runGpgTaskWithArguments:arguments passphrase:nil inputData:signedData outputData:&outputData errorData:&errorData encoding:encoding];

	if (runException) {
		[runException raise];
	}

	return extractSignaturesFromData(errorData, encoding);
}

- (NSString *)authenticationSignatureFromData:(NSData *)signedData signatureFile:(NSString *)signatureFile encoding:(CFStringEncoding)encoding {
	NSException *runException;
	NSData *errorData = nil;
	NSData *outputData;
	NSArray *arguments;

	NSParameterAssert(signedData != nil);
	NSParameterAssert(signatureFile != nil);

	arguments = [NSArray arrayWithObjects:@"--verify", signatureFile, @"-", nil];             // gpg 1.0.4 fix: we MUST add the - argument

	runException = [self runGpgTaskWithArguments:arguments passphrase:nil inputData:signedData outputData:&outputData errorData:&errorData encoding:encoding];

	if (runException) {
		[runException raise];
	}

	return extractSignaturesFromData(errorData, encoding);
}

- (NSArray *)knownHashAlgorithms {
	return [[self class] knownHashAlgorithms];
}

- (NSString *)defaultHashAlgorithm {
	return [[self class] defaultHashAlgorithm];
}

+ (NSRange)_pgpBlockRangeInData:(NSData *)data delimitedBy:(NSString *)startString and:(NSString *)endString
   // Should we support multiple pgp blocks, serialized or embedded?
   // Currently it returns the first start-of-block with the first end-of-block
{
	NSRange pgpRange = NSMakeRange(NSNotFound, 0);
	NSString *string;
	NSRange beginRange;

	string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];             // Using ASCII will consider each byte as a char, whatever the char is; we don't care about 8bit chars
	startString = [startString stringByAppendingString:@"\r\n"];

	// We'd better look for string in NSData, not in NSString, to avoid byte conversions (? ASCII ?)
	if (![string hasPrefix:startString]) {
		startString = [@"\r\n" stringByAppendingString:startString];
		beginRange = [string rangeOfString:startString];
	} else {
		beginRange = NSMakeRange(0, [startString length]);
	}
	if (beginRange.length > 0) {
		NSRange endRange;

		endString = [@"\r\n" stringByAppendingString:endString];
		endRange = [string rangeOfString:endString options:0 range:NSMakeRange(NSMaxRange(beginRange), [string length] - NSMaxRange(beginRange))];
		if (endRange.length > 0) {
			NSAssert1(endRange.location > beginRange.location, @"### GPGMail: %s: end is before start!", __PRETTY_FUNCTION__);
			pgpRange = NSUnionRange(beginRange, endRange);
		}
	}

	[string release];

	return pgpRange;
}

+ (NSRange)_pgpBlockRangeInData:(NSData *)data delimitedBy:(NSString *)startString and:(NSString *)endString encoding:(CFStringEncoding)encoding
// Should we support multiple pgp blocks, serialized or embedded?
// Currently it returns the first start-of-block with the first end-of-block
{
	// FIXME: Does not support UTF16/UTF24/UTF32
	NSRange pgpRange = NSMakeRange(NSNotFound, 0);
	NSString *string;
	NSRange beginRange;

	string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];             // Using ASCII will consider each byte as a char, whatever the char is; we don't care about 8bit chars
	startString = [startString stringByAppendingString:@"\r\n"];

	// We'd better look for string in NSData, not in NSString, to avoid byte conversions (? ASCII ?)
	if (![string hasPrefix:startString]) {
		startString = [@"\r\n" stringByAppendingString:startString];
		beginRange = [string rangeOfString:startString];
	} else {
		beginRange = NSMakeRange(0, [startString length]);
	}
	if (beginRange.length > 0) {
		NSRange endRange;

		endString = [@"\r\n" stringByAppendingString:endString];
		endRange = [string rangeOfString:endString options:0 range:NSMakeRange(NSMaxRange(beginRange), [string length] - NSMaxRange(beginRange))];
		if (endRange.length > 0) {
			NSAssert1(endRange.location > beginRange.location, @"### GPGMail: %s: end is before start!", __PRETTY_FUNCTION__);
			pgpRange = NSUnionRange(beginRange, endRange);
		}
	}

	[string release];

	return pgpRange;
}

+ (NSRange)pgpSignatureBlockRangeInData:(NSData *)data {
	return [self _pgpBlockRangeInData:data delimitedBy:@"-----BEGIN PGP SIGNED MESSAGE-----" and:@"-----END PGP SIGNATURE-----"];
}

+ (NSRange)pgpEncryptionBlockRangeInData:(NSData *)data {
	return [self _pgpBlockRangeInData:data delimitedBy:@"-----BEGIN PGP MESSAGE-----" and:@"-----END PGP MESSAGE-----"];
}

+ (NSRange)pgpPublicKeyBlockRangeInData:(NSData *)data {
	return [self _pgpBlockRangeInData:data delimitedBy:@"-----BEGIN PGP PUBLIC KEY BLOCK-----" and:@"-----END PGP PUBLIC KEY BLOCK-----"];
}

+ (NSRange)pgpSignatureBlockRangeInData:(NSData *)data encoding:(CFStringEncoding)encoding {
	return [self _pgpBlockRangeInData:data delimitedBy:@"-----BEGIN PGP SIGNED MESSAGE-----" and:@"-----END PGP SIGNATURE-----" encoding:encoding];
}

+ (NSRange)pgpEncryptionBlockRangeInData:(NSData *)data encoding:(CFStringEncoding)encoding {
	return [self _pgpBlockRangeInData:data delimitedBy:@"-----BEGIN PGP MESSAGE-----" and:@"-----END PGP MESSAGE-----" encoding:encoding];
}

- (void)cancelOperation {
	operationCancelled = YES;
	[currentTask interrupt];
}

@end
