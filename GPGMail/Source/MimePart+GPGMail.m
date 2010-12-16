/* MimePart+GPGMail.m created by stephane on Mon 10-Jul-2000 */

/*
 * Copyright (c) 2000-2010, GPGMail Project Team <gpgmail-devel@lists.gpgmail.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGMail Project Team nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY GPGMAIL PROJECT TEAM AND CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL GPGMAIL PROJECT TEAM AND CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MimePart+GPGMail.h"
#import "NSData+GPGMail.h"
#import "NSString+GPGMail.h"
#import "GPGMailBundle.h"
#import "GPGMailPatching.h"
#import "Message+GPGMail.h"
#import "NSObject+GPGMail.h"

#import "GPG.subproj/GPGHandler.h"

#import <MimeBody.h>
#import <NSData+Message.h>
#import <NSString+Message.h>
#import <MessageStore.h>
#import <MutableMessageHeaders.h>
#import <NSDataMessageStore.h>

#import <ExceptionHandling/NSExceptionHandler.h>
#import <Foundation/Foundation.h>

#define DECRYPT_PGP_ATTACHMENTS 1

@implementation MimePart (GPGMail)

GPG_DECLARE_EXTRA_IVARS(MimePart)

- (NSData *)gpgFullBodyPartData {
#warning FIXME: Does not work when (IMAP) account is offline!
	// fullBodyDataForMessage: and dataForMimePart: return nil!!!
	// -headerDataForMessage: works even offline
	// -bodyDataForMessage: works even offline, but doesn't include attachment data!
	NSData *bodyPartData;

	// We cannot use [[[[self mimeBody] message] messageStore] dataForMimePart:self]
	// because returned data doesn't have part's headers, and we need them to authenticate
	// a part.

	if ([[self mimeBody] topLevelPart] == self) {
		bodyPartData = [[(Message *)[[self mimeBody] message] messageStore] fullBodyDataForMessage:[[self mimeBody] message]];
//        bodyPartData = [[[[self mimeBody] message] messageStore] bodyDataForMessage:[[self mimeBody] message]]; // (no headers, but begins with line separator)
//        if([[[self contentTransferEncoding] lowercaseString] isEqualToString:@"quoted-printable"])
//            bodyPartData = [bodyPartData decodeQuotedPrintableForText:YES];
	} else {
		// Subpart of multipart
#if 0
		NSString *boundary = [NSString stringWithFormat:@"\r\n--%@\r\n", [[self parentPart] bodyParameterForKey:@"boundary"]];
#else
#warning Check patch
		// Patched by Tomio	(January 20,2002)
		NSString *boundary = [NSString stringWithFormat:@"--%@\r\n", [[self parentPart] bodyParameterForKey:@"boundary"]];
#endif
		char bytes[2] = { 0, 0 };

#warning BUG if not on second level!
#warning BUG? We need to check if ends with CRLF
//        bodyPartData = [[[self mimeBody] rawData] gpgStandardizedEOLsToCRLF];
		bodyPartData = [[[(Message *)[[self mimeBody] message] messageStore] fullBodyDataForMessage:[[self mimeBody] message]] gpgStandardizedEOLsToCRLF];                         // Forces download of attachments
		if (bodyPartData == nil) {
			return nil;
		}
#warning Does not return data for attachments!
		[bodyPartData getBytes:bytes length:2];
		if (bytes[0] != '\r' && bytes[1] != '\n') {
			// There are cases where raw data begins directly with the boundary
			// Thanks to Tomio Arisaka
			NSMutableData *newData;

			bytes[0] = '\r';
			bytes[1] = '\n';
			newData = [NSMutableData dataWithBytes:bytes length:2];

			[newData appendData:bodyPartData];
			bodyPartData = newData;
		}
#warning Not sure that created boundary can be written with ASCII...
		// NEW bug? It seems that sometimes(...) we get a range exception here!
#if 0
		bodyPartData = [[bodyPartData componentsSeparatedByData:[boundary dataUsingEncoding:NSASCIIStringEncoding]] objectAtIndex:[[[self parentPart] subparts] indexOfObject:self] + 1];         // +1, because first element is empty
#else
		{
			int anIndex = [[[self parentPart] subparts] indexOfObject:self];
			NSArray *components = [bodyPartData componentsSeparatedByData:[boundary dataUsingEncoding:NSASCIIStringEncoding]];

			anIndex = MIN(anIndex, [[[self parentPart] subparts] count] - 1);                                                                                                                     // FIXME: Why this code? Useless!?
//            anIndex = MIN(anIndex, [components count] - 1);
			bodyPartData = [components objectAtIndex:anIndex + 1];                                                                                                                                // +1, because first element is empty
		}
#endif
		// Patched by Tomio	(January 20,2002)
#warning Check patch
		{                                                                                                                                                                                         // removes CRLF from the end of data
			NSRange range = { 0, [bodyPartData length] - 2 };
			bodyPartData = [bodyPartData subdataWithRange:range];
		}
	}

	return bodyPartData;
}

/*!
 * DEPRECATED - now we can use -bodyData
 */
- (NSData *)gpgBodyPartData {
#if 0
	NSData *bodyPartData = [[[[self mimeBody] message] messageStore] dataForMimePart:self];

	if ([[[self contentTransferEncoding] lowercaseString] isEqualToString:@"quoted-printable"]) {
		bodyPartData = [bodyPartData decodeQuotedPrintableForText:YES];
	}

	return bodyPartData;
#else
#warning Compare my solution against Tomio
	NSData *bodyPartData;

	if ([[self mimeBody] topLevelPart] == self) {
		bodyPartData = [[(Message *)[[self mimeBody] message] messageStore] fullBodyDataForMessage:[[self mimeBody] message]];                         // (no headers, but begins with line separator)
//        bodyPartData = [[[[self mimeBody] message] messageStore] bodyDataForMessage:[[self mimeBody] message]]; // (no headers, but begins with line separator)
		if ([[[self contentTransferEncoding] lowercaseString] isEqualToString:@"quoted-printable"]) {
			bodyPartData = [bodyPartData decodeQuotedPrintableForText:YES];
		} else if ([[[self contentTransferEncoding] lowercaseString] isEqualToString:@"base64"]) {
			bodyPartData = [bodyPartData decodeBase64];
		}
	} else {
		// Subpart of multipart
#if 0   // patched by Tomio	(November 29, 2001)(January 20,2002)
		NSString *boundary = [NSString stringWithFormat:@"\r\n--%@\r\n", [[self parentPart] bodyParameterForKey:@"boundary"]];

		bodyPartData = [[[[[self mimeBody] rawData] gpgStandardizedEOLsToCRLF] componentsSeparatedByData:[boundary dataUsingEncoding:NSASCIIStringEncoding]] objectAtIndex:[[[self parentPart] subparts] indexOfObject:self] + 1];         // +1, because first element is empty
#else
		NSString *boundary = [NSString stringWithFormat:@"--%@\r\n", [[self parentPart] bodyParameterForKey:@"boundary"]];

		bodyPartData = [[[[[self mimeBody] rawData] gpgStandardizedEOLsToCRLF] componentsSeparatedByData:[boundary dataUsingEncoding:NSASCIIStringEncoding]] objectAtIndex:[[[self parentPart] subparts] indexOfObject:self] + 1];
		{                                                                                                                                                                                                                                  // removes CRLF from the end of data
			NSRange range = { 0, [bodyPartData length] - 2 };
			bodyPartData = [bodyPartData subdataWithRange:range];
		}
//        [bodyPartData writeToFile:@"/tmp/BodyPartData.txt" atomically:YES];	// debug
//        NSRunAlertPanel(@"Debug", @"%@", nil, nil, nil, @"BodyPartData");	// debug
#endif
		if ([[[self contentTransferEncoding] lowercaseString] isEqualToString:@"quoted-printable"]) {
			bodyPartData = [bodyPartData decodeQuotedPrintableForText:YES];
		} else if ([[[self contentTransferEncoding] lowercaseString] isEqualToString:@"base64"]) {
			bodyPartData = [bodyPartData decodeBase64];
		}
	}

	return bodyPartData;
#endif /* if 0 */
}

- (NSData *)gpgBodyPartData2 {
	if ([[self subparts] count] == 0) {
		NSData *bodyPartData = [[(Message *)[[self mimeBody] message] messageStore] dataForMimePart:self];

		if ([[[self contentTransferEncoding] lowercaseString] isEqualToString:@"quoted-printable"]) {
			bodyPartData = [bodyPartData decodeQuotedPrintableForText:YES];
		} else if ([[[self contentTransferEncoding] lowercaseString] isEqualToString:@"base64"]) {
			bodyPartData = [bodyPartData decodeBase64];
		}

		return bodyPartData;
	} else {
		/*
		 * if([[self mimeBody] topLevelPart] == self){
		 *  bodyPartData = [[[[self mimeBody] message] messageStore] fullBodyDataForMessage:[[self mimeBody] message]]; // (no headers, but begins with line separator); forces download of all subparts if necessary
		 *  if([[[self contentTransferEncoding] lowercaseString] isEqualToString:@"quoted-printable"])
		 *      bodyPartData = [bodyPartData decodeQuotedPrintableForText:YES];
		 * }
		 * else{
		 *  // Subpart of multipart
		 *  NSString	*boundary = [NSString stringWithFormat:@"\r\n--%@\r\n", [[self parentPart] bodyParameterForKey:@"boundary"]];
		 *
		 *  bodyPartData = [[[[self mimeBody] message] messageStore] fullBodyDataForMessage:[[self mimeBody] message]]; // (no headers, but begins with line separator); forces download of all subparts if necessary
		 * }*/
		return nil;
	}
}

- (BOOL)gpgIsOpenPGPEncryptedContainerPart
// Does not look recursively in sub-parts
{
	if ([[[self type] lowercaseString] isEqualToString:@"multipart"] && [[[self subtype] lowercaseString] isEqualToString:@"encrypted"])
																																																																																																																																																																																																																																																																																  #warning Workaround!
	{
		// Sometimes, we can't get the bodyParameterForKey:@"protocol",
		// despite there is one! Let's ignore it...
		if ([self bodyParameterForKey:@"protocol"] == nil || [[[self bodyParameterForKey:@"protocol"] lowercaseString] isEqualToString:@"application/pgp-encrypted"]) {
			// The multipart/encrypted MUST consist of exactly two parts
			if ([[self subparts] count] == 2) {
				BOOL recognizesVersion = NO;
				MimePart *versionPart = [self subpartAtIndex:0];
				MimePart *dataPart = [self subpartAtIndex:1];

				// The first MIME body part must have a content type of "application/pgp-encrypted".  This body contains the control information.
				if ([[[versionPart type] lowercaseString] isEqualToString:@"application"] && [[[versionPart subtype] lowercaseString] isEqualToString:@"pgp-encrypted"] && [[[dataPart type] lowercaseString] isEqualToString:@"application"] && ([[[dataPart subtype] lowercaseString] isEqualToString:@"octet-stream"] || [[[dataPart subtype] lowercaseString] isEqualToString:@"pgp-signature"])) {
					// Quirk mode: FireGPG < 0.7.1 declared 'application/pgp-signature' instead of 'application/octet-stream'
					NSData *bodyData = [versionPart bodyData];                                                                           // (it doesn't matter if data has been decoded; normally there was nothing to decode)

					if (bodyData) {
						// bodyData might be nil if mimePart has not yet been downloaded
						// from server. We assume that part is PGP encrypted though.
						// #warning Do we use the right encoding?
						NSString *string = [[NSString alloc] initWithData:bodyData encoding:NSASCIIStringEncoding];                          // [versionPart textEncoding] ?
						NSString *lowercaseString = [string lowercaseString];

// NSLog(@"-[MimePart gpgIsOpenPGPEncryptedContainerPart]: [versionPart textEncoding] = %d = %@", [versionPart textEncoding], [NSString localizedNameOfStringEncoding:[versionPart textEncoding]]);
						// A message complying with this standard MUST contain a "Version: 1" field in this body.
						// NOTE: to insure compatibility with Mulberry, we need to check against "Version : 1" too
						// Note also that "Version: 1" is not necessarily ended by a CR! (Ximian Evolution)
						// EudoraGPG (Windows) adds one more newline after the "version" line; fix provided by Georg Wedemeyer
						// FIXME: Wouldn't support versions 10 and later, or versions 1.x
						if ([lowercaseString rangeOfString:@"version: 1"].location != NSNotFound || [lowercaseString rangeOfString:@"version : 1"].location != NSNotFound) {
							recognizesVersion = YES;
						}
						[string release];
					}
				}

				if (recognizesVersion) {
					return YES;
				}
			}
		}
	}

	return NO;
}

- (BOOL)_gpgLooksLikeBinaryPGPAttachment {
	BOOL looksLikePGP = NO;
	NSString *aType = [[self type] lowercaseString];
	NSString *aSubtype = [[self subtype] lowercaseString];

	if ([aType isEqualToString:@"application"] && [aSubtype isEqualToString:@"octet-stream"]) {
		NSData *bodyData = [self bodyData];                          // We use only the body (no headers), and decoded!

		if (bodyData != nil) {
			// This is an octet stream. Is it a PGP-encrypted file?
			// Let's do a pre-test: like magic(5), we check some bytes of the data. If it looks like PGP data,
			// then we will try decryption.
			unsigned length = [bodyData length];
			unsigned char *bytes = (unsigned char *)[bodyData bytes];

			if (length > 1) {
				if (bytes[0] == 0x0085 && bytes[1] == 0x02) {
					looksLikePGP = YES;
				} else if (bytes[0] == 0x00a6 && bytes[1] == 0x00) {
					looksLikePGP = YES;
				} else if (bytes[0] == 0x0085 && bytes[1] == 0x01) {                                             // According to http://lists.gnupg.org/pipermail/gnupg-devel/1999-September/016052.html
					looksLikePGP = YES;
				}
			}

			if (!looksLikePGP) {
				// If filename ends with .gpg, .pgp or .asc, we suppose it's a PGP file
				NSString *pathExtension = [[[self attachmentFilename] pathExtension] lowercaseString];

				if (pathExtension != nil && ([pathExtension isEqualToString:@"gpg"] || [pathExtension isEqualToString:@"pgp"] || [pathExtension isEqualToString:@"asc"])) {
					looksLikePGP = YES;
				}
			}
		}
	}

	return looksLikePGP;
}

- (BOOL)_gpgIsNonOpenPGPEncryptedPart {
	// We accept only text/plain or application/octet-stream
	// As with plain text messages, contains simple PGP encrypted block
	NSData *bodyData;
	NSString *aType = [[self type] lowercaseString];
	NSString *aSubtype = [[self subtype] lowercaseString];
	BOOL isPlainText = ([aType isEqualToString:@"text"] && [aSubtype isEqualToString:@"plain"]);

	// We don't support text/html
	// It's rather difficult, even if it's not impossible:
	// We should search for armor in HTMLDocument
	// If there is a text/plain alternative, then user can see decrypted message
	if (!isPlainText) {
		BOOL isApplicationPGP = ([aType isEqualToString:@"application"] && [aSubtype isEqualToString:@"pgp"]);

		if (isApplicationPGP && [[[self bodyParameterForKey:@"format"] lowercaseString] isEqualToString:@"text"]) {
			// Content-Type: application/pgp; format=text; x-action=encryptsign
			// Content-Type: application/pgp; format=text; x-action=sign
			// Content-Type: application/pgp; format=text
			// Content-Type: application/pgp; format=text; x-action=encrypt
			// Here we don't case about the x-action.
			return YES;
		} else {
#if DECRYPT_PGP_ATTACHMENTS

			if ([self _gpgLooksLikeBinaryPGPAttachment]) {                                   // TODO: there are problems to fix with message body: message should cache decrypted message body, it's not part's task
				return YES;
			} else
#endif
			return NO;
		}
	}

	// If message contains a plain text PGP attachment, don't consider the part to be encrypted;
	// user will have to do it manually.
	if ([self isAttachment]) {
		return NO;
	}

	bodyData = [self bodyData];             // We use only the body (no headers), and decoded!
	if (bodyData != nil) {
		return [GPGHandler pgpEncryptionBlockRangeInData:[bodyData gpgStandardizedEOLsToCRLF]].location != NSNotFound;
	} else {
		return NO;
	}
}

- (BOOL)gpgIsEncrypted
// Checks MIME headers/parameters (OpenPGP) and content, also in sub-parts
// Maybe we should NOT check deeply in sub-parts, as long as
// we cannot show block boundaries in viewer.
{
	int i;
	NSArray *parts;

	// Special case for attached messages: if a message is embedded in the main message, don't look at
	// that message content. User will see the embedded message as a separate message.
	if ([[[self type] lowercaseString] isEqualToString:@"message"] && [[[self subtype] lowercaseString] isEqualToString:@"rfc822"]) {
		return NO;
	}

	if ([self gpgIsOpenPGPEncryptedContainerPart]) {
		return YES;
	}

	parts = [self subparts];
	i = [parts count];
	if (i > 0) {
		for (i = i - 1; i >= 0; i--) {
			if ([[parts objectAtIndex:i] gpgIsEncrypted]) {
				return YES;
			}
		}
	}
	// If we don't put the "else", it means that MIME message could have an armored
	// PGP body extending over many parts!
	else if ([self _gpgIsNonOpenPGPEncryptedPart]) {
		return YES;
	}

	return NO;
}

- (NSData *)_gpgDecryptedPGPMIMEDataWithPassphraseDelegate:(id)passphraseDelegate signatures:(NSArray **)signaturesPtr {
	// Only for OpenPGP/MIME
	// It doesn't matter if decrypted data contains headers too.
	NSData *bodyPartData = [self /*gpgBodyPartData2*/ bodyData];

	if (bodyPartData != nil) {
		GPGContext *aContext = [[GPGContext alloc] init];
		GPGData *inputData = [[GPGData alloc] initWithData:bodyPartData];

		if (GPGMailLoggingLevel & GPGMailDebug_SaveInputDataMask) {
			NSString *filename = [NSTemporaryDirectory () stringByAppendingPathComponent:[[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"asc"]];

			if ([bodyPartData writeToFile:filename atomically:NO]) {
				NSLog(@"[DEBUG] Data to decrypt in %@", filename);
			} else {
				NSLog(@"[DEBUG] FAILED to write data to decrypt in %@", filename);
			}
		}

		[aContext setPassphraseDelegate:passphraseDelegate];
		[aContext setUsesArmor:YES];
		[aContext setUsesTextMode:YES];
		@try {
			GPGData *outputData = [aContext decryptedData:inputData signatures:signaturesPtr /*encoding:[self textEncoding]*/];              // Can raise an exception
			NSData *decryptedData;

			decryptedData = [[[outputData data] retain] autorelease];                                                                        // Because context will be released
			if (signaturesPtr != NULL) {
				[[*signaturesPtr retain] autorelease];                                                                                       // Because context will be released
			}
			[aContext release];
			[inputData release];
			return decryptedData;
		}@catch (NSException *localException) {
			[inputData release];
			[aContext release];
			[localException raise];
			return nil;
		}
	} else {
		// Happens if part has not been downloaded
		[NSException raise:NSGenericException format:NSLocalizedStringFromTableInBundle(@"DATA_NOT_AVAILABLE", @"GPGMail", [NSBundle bundleForClass:[GPGHandler class]], "")];
		return nil;
	}
	return nil;                     // Never reached, but mutes gcc warning
}

- (NSData *)_gpgDecryptedInlineDataWithPassphraseDelegate:(id)passphraseDelegate signatures:(NSArray **)signaturesPtr {
	NSData *data = [self bodyData]; // At this stage, bodyData returns decoded data (if raw data was quoted-printable/base64)
	NSRange pgpRange;
	NSData *pgpData;
	volatile NSData *decryptedData = nil;
	GPGContext *aContext = [[GPGContext alloc] init];
	GPGData *inputData;
	BOOL isText;

	// TODO: add support for multiple ASCII armors in same part
	[aContext setPassphraseDelegate:passphraseDelegate];
#if DECRYPT_PGP_ATTACHMENTS
	if ([self _gpgLooksLikeBinaryPGPAttachment]) {
		pgpRange = NSMakeRange(0, [data length]);
		pgpData = data;
		[aContext setUsesArmor:NO];
		[aContext setUsesTextMode:NO];
		isText = NO;
	} else
#endif
	{
		data = [data gpgStandardizedEOLsToCRLF];
		pgpRange = [GPGHandler pgpEncryptionBlockRangeInData:data];
		NSAssert(pgpRange.location != NSNotFound, @"Not encrypted!");
		pgpData = [data subdataWithRange:pgpRange];
		[aContext setUsesArmor:YES];
		[aContext setUsesTextMode:YES];
		isText = YES;
	}

	inputData = [[GPGData alloc] initWithData:pgpData];
	if (GPGMailLoggingLevel & GPGMailDebug_SaveInputDataMask) {
		NSString *filename = [NSTemporaryDirectory () stringByAppendingPathComponent:[[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:(isText ? @"asc":@"gpg")]];

		if ([pgpData writeToFile:filename atomically:NO]) {
			NSLog(@"[DEBUG] Data to decrypt in %@", filename);
		} else {
			NSLog(@"[DEBUG] FAILED to write data to decrypt in %@", filename);
		}
	}

#warning CHECK: Do we support decrypted-then-verified messages?
	@try {
		GPGData *outputData = [aContext decryptedData:inputData signatures:signaturesPtr /*encoding:[self textEncoding]*/];          // Can raise an exception

		decryptedData = [[[outputData data] retain] autorelease];                                                                    // Because context will be released

		if (signaturesPtr != NULL) {
			[[*signaturesPtr retain] autorelease];                                                                                   // Because context will be released
		}
	}@catch (NSException *localException) {
		[inputData release];
		[aContext release];
		[localException raise];
	}
	[aContext release];
	[inputData release];

	NSMutableData *newEncodedBody = [NSMutableData dataWithCapacity:[data length]];                   // Not the exact size, but approximately correct...

	if (isText) {
		[newEncodedBody appendData:[data subdataWithRange:NSMakeRange(0, pgpRange.location)]];
		[newEncodedBody appendData:(NSData *)decryptedData];
		[newEncodedBody convertNetworkLineEndingsToUnix];
		[newEncodedBody appendData:[data subdataWithRange:NSMakeRange(NSMaxRange(pgpRange), [data length] - NSMaxRange(pgpRange))]];
	} else {
		[newEncodedBody setData:(NSData *)decryptedData];
	}

	// Don't forget to reencode data according to content-transfer-encoding!
	if ([[[self contentTransferEncoding] lowercaseString] isEqualToString:@"quoted-printable"]) {
		[newEncodedBody setData:[newEncodedBody encodeQuotedPrintableForText:YES]];
	} else if ([[[self contentTransferEncoding] lowercaseString] isEqualToString:@"base64"]) {
		[newEncodedBody setData:[newEncodedBody encodeBase64]];
	}
/*    {
 *      // HACK: Just to tell that there is no header part...
 *      // We need to do this, because of the way we handle data later.
 *      NSMutableData	*prefixData = [[NSMutableData alloc] initWithData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding]];
 *
 *      [prefixData appendData:newEncodedBody];
 *      [newEncodedBody setData:prefixData];
 *      [prefixData release];
 *  }*/

	return newEncodedBody;
}

- (void)_gpgDecryptInlineDataWithPassphraseDelegate:(id)passphraseDelegate signatures:(NSArray **)signaturesPtr intoData:(NSMutableData *)decryptedData fromData:(NSData *)fullBodyData {
	NSData *partDecryptedData = [self _gpgDecryptedInlineDataWithPassphraseDelegate:passphraseDelegate signatures:signaturesPtr];

	if (partDecryptedData != nil) {
		NSRange partRange = [self range];

		[decryptedData setData:[fullBodyData subdataWithRange:NSMakeRange(0, partRange.location)]];
		[decryptedData appendData:partDecryptedData];
		[decryptedData appendData:[fullBodyData subdataWithRange:NSMakeRange(NSMaxRange(partRange), [fullBodyData length] - (NSMaxRange(partRange)))]];
	}
}

/*!
 * Invoked for part even when not directly encrypted/signed. In this case, must forward message to subparts.
 */
- (NSData *)gpgDecryptedDataWithPassphraseDelegate:(id)passphraseDelegate signatures:(NSArray **)signaturesPtr
// We would give back the signatures (or nil) of the latest part!
// Returning nil means that we could not decrypt data
{
	NSArray *parts = [self subparts];
	int partCount = [parts count];

	if ([self gpgIsOpenPGPEncryptedContainerPart]) {
		// The second MIME body part MUST contain the actual encrypted data.  It must be labeled with a content type of "application/octet-stream".
		MimePart *aPart = [parts objectAtIndex:1];
		NSData *decryptedData = [aPart _gpgDecryptedPGPMIMEDataWithPassphraseDelegate:passphraseDelegate signatures:signaturesPtr];                              // Can raise an exception

#warning Do we really need to convert CRLF to LF as Tomio does?
// Signature authentication should do it by itself

		// TODO: support recursive decryption - embedded encrypted parts. Decrypted part could contain encrypted sub-parts too.
//      MimePart	*decryptedPart = [MimePart bodyPartWithData:decryptedData];
//
//      if([decryptedPart gpgIsEncrypted])
//          return [decryptedPart gpgDecryptedDataForReceiver:receiver passphrase:passphrase signatures:signaturesPtr];
//      else
		return decryptedData;
	} else if (partCount > 0) {
		int anIndex;
		NSMutableData *decryptedData = nil;
		NSData *fullBodyData = nil;

		for (anIndex = 0; anIndex < partCount; anIndex++) {
			MimePart *aPart = [parts objectAtIndex:anIndex];

			if ([aPart _gpgIsNonOpenPGPEncryptedPart]) {
				if (!fullBodyData) {
					fullBodyData = [[(Message *)[[self mimeBody] message] messageStore] fullBodyDataForMessage:[[self mimeBody] message]];
					decryptedData = [NSMutableData dataWithData:fullBodyData];
				}
				[aPart _gpgDecryptInlineDataWithPassphraseDelegate:passphraseDelegate signatures:signaturesPtr intoData:decryptedData fromData:fullBodyData];
#if 0
				NSData *partDecryptedData = [aPart _gpgDecryptedInlineDataWithPassphraseDelegate:passphraseDelegate signatures:signaturesPtr];

				if (partDecryptedData != nil) {
					NSRange partRange = [aPart range];

					[decryptedData setData:[fullBodyData subdataWithRange:NSMakeRange(0, partRange.location)]];
					[decryptedData appendData:partDecryptedData];
					[decryptedData appendData:[fullBodyData subdataWithRange:NSMakeRange(NSMaxRange(partRange), [fullBodyData length] - (NSMaxRange(partRange)))]];
				}
#endif
			}
#warning No support yet for deeper levels...
		}

		if (!decryptedData) {
#warning NOT HANDLED (embedded encrypted parts)
			//        NSBeep();
			NSLog(@"### GPGMail: unable (yet) to decrypt embedded MIME parts");
			/*        for(i = i - 1; i >= 0; i--){
			 * [[parts objectAtIndex:i] gpgDecryptedDataForReceiver:receiver passphrase:passphrase signatures:signaturesPtr];
			 * }*/
			// We need to recreate sub-parts...
			[NSException raise:NSInternalInconsistencyException format:NSLocalizedStringFromTableInBundle(@"UNSUPPORTED_ENCRYPTION_FORMAT", @"GPGMail", [NSBundle bundleForClass:[GPGHandler class]], "")];

//            return nil; // Let's return original data as we cannot decrypt it
		} else {
/*            // HACK: Just to tell that there is no header part...
 *          // We need to do this, because of the way we handle data later.
 *          NSMutableData	*prefixData = [[NSMutableData alloc] initWithData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding]];
 *
 *          [prefixData appendData:decryptedData];
 *          [decryptedData setData:prefixData];
 *          [prefixData release];*/
		}

		return decryptedData;
	} else if ([self _gpgIsNonOpenPGPEncryptedPart]) {
		return [self _gpgDecryptedInlineDataWithPassphraseDelegate:passphraseDelegate signatures:signaturesPtr];
	} else {
		return nil;                          // Let's return original data as we cannot decrypt it
	}
}

- (BOOL)gpgIsOpenPGPSignedContainerPart
// Checks MIME headers/parameters, in this part only
{
	MimePart *aPart;
	NSArray *parts;
	NSString *hashAlgorithmName;

	// OpenPGP signed messages are denoted by the "multipart/signed" content
	// type, described in [2], with a "protocol" parameter which MUST have a
	// value of "application/pgp-signature" (MUST be quoted).
	if (![[[self type] lowercaseString] isEqualToString:@"multipart"] && ![[[self subtype] lowercaseString] isEqualToString:@"signed"]) {
		return NO;                          // We don't go further in subparts in this method

	}
#warning Workaround!
	// Sometimes, we can't get the bodyParameterForKey:@"protocol",
	// despite there is one! Let's ignore it...
	if ([self bodyParameterForKey:@"protocol"] && ![[[self bodyParameterForKey:@"protocol"] lowercaseString] isEqualToString:@"application/pgp-signature"]) {
		return NO;
	}
	// The "micalg" parameter for the "application/pgp-signature" protocol
	// MUST contain exactly one hash-symbol of the format "pgp-<hash-
	// identifier>", where <hash-identifier> identifies the Message
	// Integrity Check (MIC) algorithm used to generate the signature.
	hashAlgorithmName = [[self bodyParameterForKey:@"micalg"] lowercaseString];
	// To insure compatibility with Sylpheed, we don't consider it an error
	// if micalg is missing (anyway, we don't need to pass it to gpg).
#warning Workaround!
	// Sometimes, we can't get the bodyParameterForKey:@"micalg",
	// despite there is one! Let's ignore it...
#if 0
	if (hashAlgorithmName) {
		if (![hashAlgorithmName hasPrefix:@"pgp-"]) {
			return NO;
		} else {
			hashAlgorithmName = [hashAlgorithmName substringFromIndex:4];
		}
		if (![[[GPGHandler handler] knownHashAlgorithms] containsObject:hashAlgorithmName]) {
			return NO;
		}
	}
#endif

	parts = [self subparts];
	// The multipart/signed body MUST consist of exactly two parts.
	if ([parts count] != 2) {
		return NO;
	}

	// The second body MUST contain the OpenPGP digital signature. It
	// MUST be labeled with a content type of "application/pgp-signature".
	aPart = [parts objectAtIndex:1];
	if ([[[aPart type] lowercaseString] isEqualToString:@"application"] && [[[aPart subtype] lowercaseString] isEqualToString:@"pgp-signature"]) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)_gpgIsNonOpenPGPSignedPart {
	// As with plain text messages, contains simple PGP signed block
	NSData *bodyData;

	// We don't support text/html
	// It's rather difficult, even if it's not impossible:
	// We should search for armor in HTMLDocument
	// If there is a text/plain alternative, then user can see decrypted message
	if (([self type] && ![[[self type] lowercaseString] isEqualToString:@"text"]) || ([self subtype] && ![[[self subtype] lowercaseString] isEqualToString:@"plain"]))
																																																																																																																																																																																																																																																																																																																																																#warning Test new recognition
	{
		if (([self type] && ![[[self type] lowercaseString] isEqualToString:@"application"]) || ([self subtype] && ![[[self subtype] lowercaseString] isEqualToString:@"pgp"])) {
			return NO;
		}
	}

	// If message contains a plain text PGP attachment, don't consider the part to be a PGP part;
	// user will have to do it manually.
	if ([self isAttachment]) {
		return NO;
	}

	// In non-OpenPGP case, we assume that mailer signed displayed data,
	// i.e. non quoted-printable/base64 data
	bodyData = [[self bodyData] gpgStandardizedEOLsToCRLF];             // WARNING: in this case can contain 8bit characters
#warning Assertion not respected if body not loaded?
#warning ADDED TEST
#if 0
	NSParameterAssert(bodyData != nil);

	return [GPGHandler pgpSignatureBlockRangeInData:bodyData].location != NSNotFound;
#else
	if (bodyData != nil) {
		return [GPGHandler pgpSignatureBlockRangeInData:bodyData].location != NSNotFound;
	} else {
		return NO;
	}
#endif
}

- (BOOL)gpgHasSignature
// Checks MIME headers/parameters (OpenPGP) and content, also in sub-parts
// Maybe we should NOT check deeply in sub-parts, as long as
// we cannot show block boundaries in viewer.
{
	int i;
	NSArray *parts;

	// Special case for attached messages: if a message is embedded in the main message, don't look at
	// that message content. User will see the embedded message as a separate message.
	if ([[[self type] lowercaseString] isEqualToString:@"message"] && [[[self subtype] lowercaseString] isEqualToString:@"rfc822"]) {
		return NO;
	}

	if ([self gpgIsOpenPGPSignedContainerPart]) {
		return YES;
	}

	parts = [self subparts];
	i = [parts count];
	if (i > 0) {
		for (i = i - 1; i >= 0; i--) {
			if ([[parts objectAtIndex:i] gpgHasSignature]) {
				return YES;
			}
		}
	}
	// If we don't put the "else", it means that signature could extend on more that one part?!?
	else if ([self _gpgIsNonOpenPGPSignedPart]) {
		return YES;
	}

	return NO;
}

- (BOOL)gpgIsOpenPGPKeyPart {
	return ([[[self type] lowercaseString] isEqualToString:@"application"] && [[[self subtype] lowercaseString] isEqualToString:@"pgp-keys"]);
}

- (BOOL)_gpgIsNonOpenPGPKeyPart {
	// As with plain text messages, contains simple PGP signed block
	NSData *bodyData;

	// We don't support text/html
	// It's rather difficult, even if it's not impossible:
	// We should search for armor in HTMLDocument
	// If there is a text/plain alternative, then user can see decrypted message
	if (([self type] && ![[[self type] lowercaseString] isEqualToString:@"text"]) || ([self subtype] && ![[[self subtype] lowercaseString] isEqualToString:@"plain"]))
																																																																																																																																																																																																																																																																																																																																																#warning Test new recognition
	{
		if (([self type] && ![[[self type] lowercaseString] isEqualToString:@"application"]) || ([self subtype] && ![[[self subtype] lowercaseString] isEqualToString:@"pgp"])) {
			return NO;
		}
	}

#if 0
	// If message contains a plain text PGP attachment, don't consider the part to be a PGP part;
	// user will have to do it manually.
	if ([self isAttachment]) {
		return NO;
	}
#endif

	// In non-OpenPGP case, we assume that mailer signed displayed data,
	// i.e. non quoted-printable/base64 data
	bodyData = [[self bodyData] gpgStandardizedEOLsToCRLF];             // WARNING: in this case can contain 8bit characters
#warning Assertion not respected if body not loaded?
#warning ADDED TEST
#if 0
	NSParameterAssert(bodyData != nil);

	return [GPGHandler pgpPublicKeyBlockRangeInData:bodyData].location != NSNotFound;
#else
	if (bodyData != nil) {
		return [GPGHandler pgpPublicKeyBlockRangeInData:bodyData].location != NSNotFound;
	} else {
		return NO;
	}
#endif
}

- (BOOL)gpgContainsKeyBlock {
	int i;
	NSArray *parts;

	if ([self gpgIsOpenPGPKeyPart]) {
		return YES;
	}

	parts = [self subparts];
	i = [parts count];
	if (i > 0) {
		for (i = i - 1; i >= 0; i--) {
			if ([[parts objectAtIndex:i] gpgContainsKeyBlock]) {
				return YES;
			}
		}
	}
	// If we don't put the "else", it means that signature could extend on more that one part?!?
	else if ([self _gpgIsNonOpenPGPKeyPart]) {
		return YES;
	}

	return NO;
}

- (BOOL)gpgAllAttachmentsAreAvailable {
	NSArray *subparts = [self subparts];
	int subpartsCount = [subparts count];

	if (subpartsCount == 0) {
		// Using [[[[self mimeBody] message] messageStore] dataForMimePart:self]
		// always returns nil for .sig attachments! Because they are attachments,
		// not displayed inline??
		return [[(Message *)[[self mimeBody] message] messageStore] hasCachedDataForMimePart:self];
	} else {
		// A multipart part never has anything in the cache
		for (--subpartsCount; subpartsCount >= 0; subpartsCount--) {
			if (![[subparts objectAtIndex:subpartsCount] gpgAllAttachmentsAreAvailable]) {
				return NO;
			}
		}
		return YES;
	}
}

- (GPGSignature *)gpgAuthenticationSignature {
	NSArray *parts = [self subparts];
	int i = [parts count];

	if ([self gpgIsOpenPGPSignedContainerPart]) {
		MimePart *aPart;
		NSData *signedData;
		NSString *signatureFile = nil;
		GPGContext *aContext = [[GPGContext alloc] init];
		GPGData *inputData, *signatureInputData;
		NSString *aTempFile;

		// We can not use _attachDir and -fileWrapperForBody, because we flushed data => _attachDir is nil
		// We can anyway create a temporary file, for example in /tmp,
		// which will contain the signature.
		aTempFile = [NSTemporaryDirectory () stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
		signatureFile = [aTempFile stringByAppendingPathExtension:@"sig"];
#if 1
		aPart = [parts objectAtIndex:1];
		NSAssert1([aPart gpgSaveBodyToFile:signatureFile], @"Unable to save temporary file %@", signatureFile);

		signedData = [NSMutableData dataWithContentsOfFile:signatureFile];
		[(NSMutableData *) signedData gpgNormalizeDataForVerifying];
		NSAssert1([signedData writeToFile:signatureFile atomically:YES], @"Unable to save (again) temporary file %@", signatureFile);
		aPart = [parts objectAtIndex:0];
		signedData = [[aPart gpgFullBodyPartData] gpgNormalizedDataForVerifying];
#warning We should ensure that it is not decoded if it was quoted-printable/base64??
#else
#warning Test patch from Tomio
		{
#warning BUG! Does not take data for attachments!!!
			NSData *bodyData;
			NSString *aString, *boundary;
			NSStringEncoding originalEncoding;
			NSRange range;
			unsigned int point;

			aPart = [parts objectAtIndex:0];                                        // text part
			aString = [aPart bodyParameterForKey:@"charset"];
			// considers whether "Content-Transfer-Encoding" is "quoted-printable" or "base64"
			originalEncoding = NSISOLatin1StringEncoding;
			if (![[[aPart contentTransferEncoding] lowercaseString] isEqualToString:@"quoted-printable"]) {
				if (aString != nil) {
					originalEncoding = [NSString gpgEncodingForMIMECharset:aString];
				}
				bodyData = [[aPart /*gpgBodyPartData*/ bodyData] gpgNormalizedDataForVerifying];
			} else if (![[[aPart contentTransferEncoding] lowercaseString] isEqualToString:@"base64"]) {
				if (aString != nil) {
					originalEncoding = [NSString gpgEncodingForMIMECharset:aString];
				}
				bodyData = [[aPart /*gpgBodyPartData*/ bodyData] gpgNormalizedDataForVerifying];
			} else {
#warning Unknown method!!!
//                bodyData = [[aPart gpgBodyPartDataWithoutDecodeQuotePrintable] gpgNormalizedDataForVerifying];
				bodyData = [[aPart /*gpgBodyPartData*/ bodyData] gpgNormalizedDataForVerifying];
			}
			aString = [[NSString alloc] initWithData:bodyData encoding:originalEncoding];
			boundary = [NSString stringWithFormat:@"--%@\r\n", [[aPart parentPart] bodyParameterForKey:@"boundary"]];
			range = [aString rangeOfString:boundary];
			point = range.location + range.length;
			if (point > [aString length]) {
				point = 0;
			}
			bodyData = [[aString substringFromIndex:point] dataUsingEncoding:originalEncoding];             // removes a line-separator
			[aString release];
			aPart = [parts objectAtIndex:1];                                                                // signed part
			signedData = [[aPart bodyData] gpgStandardizedEOLsToCRLF];
// Stephane: no, encoding can be different; why does it need to go to string, back to data??
//            aString = [[NSString alloc] initWithData:signedData encoding:originalEncoding];
//            signedData = [aString dataUsingEncoding:originalEncoding];
			NSAssert1([signedData writeToFile:signatureFile atomically:YES], @"Unable to save temporary file %@", signatureFile);
			[aString release];
			signedData = bodyData;
		}
#endif /* if 1 */
		inputData = [[GPGData alloc] initWithData:signedData];
		if (GPGMailLoggingLevel & GPGMailDebug_SaveInputDataMask) {
			NSString *signedDataFile = [aTempFile stringByAppendingPathExtension:@"asc"];

			if ([signedData writeToFile:signedDataFile atomically:NO]) {
				NSLog(@"[DEBUG] Data to verify in %@", signedDataFile);
			} else {
				NSLog(@"[DEBUG] FAILED to write data to verify in %@", signedDataFile);
			}
		}

		signatureInputData = [[GPGData alloc] initWithContentsOfFile:signatureFile];
		[aContext setUsesArmor:YES];
		[aContext setUsesTextMode:YES];
		@try {
			GPGSignature *aSignature;

			(void)[aContext verifySignatureData:signatureInputData againstData:inputData /*encoding:[self textEncoding]*/];             // Can raise an exception

			if (!(GPGMailLoggingLevel & GPGMailDebug_SaveInputDataMask)) {
				[[NSFileManager defaultManager] removeItemAtPath:signatureFile error:nil];
			}

			aSignature = [[[[aContext signatures] lastObject] retain] autorelease];                                                     // Because context will be released
#warning Workaround for gpgme 0.4.x bug: does not return an error when CRC or BADARMOR error!
			if (aSignature == nil) {
				[[NSException exceptionWithName:GPGException reason:[[GPGMailBundle sharedInstance] gpgErrorDescription:GPGErrorChecksumError] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:GPGErrorChecksumError], GPGErrorKey, nil]] raise];
			}
			[aContext release];
			[inputData release];
			[signatureInputData release];
			return aSignature;
		}@catch (NSException *localException) {
			if (!(GPGMailLoggingLevel & GPGMailDebug_SaveInputDataMask)) {
				[[NSFileManager defaultManager] removeItemAtPath:signatureFile error:nil];
			}

			[inputData release];
			[signatureInputData release];
			if ([[localException name] isEqualToString:GPGException]) {
				NSArray *signatures = [[[aContext signatures] retain] autorelease];                                                  // Because context will be released

				[aContext release];
				if ([signatures count]) {
					// In this case, signature will contain the exception in its status
					return [signatures lastObject];
				}
			} else {
				[aContext release];
			}
			[localException raise];
			return nil;
		}
	} else if (i > 0) {
		// Not handled correctly... We should retrieve a dict with sigs per part.
		// Currently we stop on the first retrieved sig (from the end!)
		for (i = i - 1; i >= 0; i--) {
			GPGSignature *aSignature = [[parts objectAtIndex:i] gpgAuthenticationSignature];                                        // Can raise an exception

			if (aSignature != nil) {
				return aSignature;
			}
		}
		return nil;
	}
	// Is the "else" really necessary?!
	// If we don't put the "else", it means that signature could extend on more that one part?!?
	else if ([self _gpgIsNonOpenPGPSignedPart]) {
		// In non-OpenPGP case, we assume that mailer signed displayed data,
		// i.e. non quoted-printable/base64 data
		NSData *data = [self bodyData];                                  // At this stage, bodyData returns decoded data (if raw data was quoted-printable/base64)
		NSRange pgpRange;
		NSData *pgpData;
		GPGHandler *aHandler;
		GPGContext *aContext = [[GPGContext alloc] init];
		GPGData *inputData;

#warning WARNING By converting EOL to CRLF, we break signature! I thought EOLs were not used...
		data = [data gpgStandardizedEOLsToCRLF];                           // WARNING: in this case can contain 8bit characters

		pgpRange = [GPGHandler pgpSignatureBlockRangeInData:data];         // Expects CRLF EOLs
		NSAssert(pgpRange.location != NSNotFound, @"Not signed!");

		pgpData = [data subdataWithRange:pgpRange];
		pgpData = [pgpData gpgStandardizedEOLsToLF];                       // Back to LF??
		aHandler = [GPGHandler handler];

		// There was a bug in previous GPGMailv11; some signed messages would have
		// an invalid signature now...
		// First we try the right way, and if it doesn't work, we try the old way.
		// Problem happens with messages containing non-ASCII characters.
		inputData = [[GPGData alloc] initWithData:pgpData];
		if (GPGMailLoggingLevel & GPGMailDebug_SaveInputDataMask) {
			NSString *filename = [NSTemporaryDirectory () stringByAppendingPathComponent:[[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"asc"]];

			if ([pgpData writeToFile:filename atomically:NO]) {
				NSLog(@"[DEBUG] Data to verify in %@", filename);
			} else {
				NSLog(@"[DEBUG] FAILED to write data to verify in %@", filename);
			}
		}

		[aContext setUsesArmor:YES];
		[aContext setUsesTextMode:YES];
#if 0
		@try {
			// The following call should be enough...
			(void)[aContext verifySignedData:inputData /*encoding:[self textEncoding]*/];                                     // Can raise an exception
			[inputData release];
			inputData = nil;

			return [[[aContext autorelease] signatures] lastObject];
		}@catch (NSException *localException) {
			NSException *originalException = localException;
			volatile NSArray *originalSignatures = [[[aContext signatures] retain] autorelease];                              // Because context will be released

			data = [[self bodyData] gpgStandardizedEOLsToCRLF];
			pgpRange = [GPGHandler pgpSignatureBlockRangeInData:data];
			NSAssert(pgpRange.location != NSNotFound, @"Not signed!");
			pgpData = [data subdataWithRange:pgpRange];
			@try {
				NSArray *verificationSignatures;

				[inputData release];
				inputData = [[GPGData alloc] initWithData:pgpData];
				verificationSignatures = [aContext verifySignedData:inputData /*encoding:[self textEncoding]*/];                 // Can raise an exception
				[[verificationSignatures retain] autorelease];                                                                   // Because context will be released
				[aContext release];
				[inputData release];

				return [verificationSignatures lastObject];
			}@catch (NSException *localException) {
				[inputData release];
				[aContext release];
				if ([[originalException name] isEqualToString:GPGException]) {
					if ([(NSArray *) originalSignatures count]) {
						// In this case, signature will contain the exception in its status
						return [(NSArray *) originalSignatures lastObject];
					}
				}
				[(NSException *) originalException raise];
				return nil;                                                 // Never reached
			}
		}
#else
#warning Test old signatures?! (<= v11)
		@try {
			NSArray *verificationSignatures;
			GPGSignature *aSignature;

			verificationSignatures = [aContext verifySignedData:inputData /*encoding:[self textEncoding]*/];                                     // Can raise an exception

			aSignature = [verificationSignatures lastObject];

#warning Workaround for gpgme 0.4.x bug: does not return an error when CRC or BADARMOR error!
			if (aSignature == nil) {
				[[NSException exceptionWithName:GPGException reason:[[GPGMailBundle sharedInstance] gpgErrorDescription:GPGErrorInvalidArmor] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:GPGErrorInvalidArmor], GPGErrorKey, nil]] raise];
			}

			if ([[GPGMailBundle sharedInstance] gpgErrorCodeFromError:[aSignature status]] == GPGErrorBadSignature && [[self bodyParameterForKey:@"format"] isEqualToString:@"flowed"]) {
				// When format=flowed, we need to decode string in some special way:
				// http://www.ietf.org/rfc/rfc2646.txt?number=2646
				// To avoid doing it, let's ask Mail to do it for ourself.
				// We don't even search for PGP armor boundaries, it seems
				// gpg does it very well.
				// WARNING Do this only when format=flowed!
#warning BUG Using attributedString or -convertFromFlowedText: removes all quote prefixes (>) !!!
#if 0
				pgpData = [[[self attributedString] string] dataUsingEncoding:[self textEncoding]];
#else
				pgpData = [self bodyData];
				pgpData = [pgpData gpgStandardizedEOLsToCRLF];                                                 // WARNING Might break sig
				pgpData = [pgpData gpgDecodeFlowedWithEncoding:[self textEncoding]];
#endif
				pgpRange = NSMakeRange(0, [pgpData length]);

				if (pgpRange.location != NSNotFound) {
					[inputData release];
					inputData = [[GPGData alloc] initWithData:pgpData];
					if (GPGMailLoggingLevel & GPGMailDebug_SaveInputDataMask) {
						NSString *filename = [NSTemporaryDirectory () stringByAppendingPathComponent:[[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"asc"]];

						if ([pgpData writeToFile:filename atomically:NO]) {
							NSLog(@"[DEBUG] Data to verify in %@", filename);
						} else {
							NSLog(@"[DEBUG] FAILED to write data to verify in %@", filename);
						}
					}

					verificationSignatures = [aContext verifySignedData:inputData /*encoding:[self textEncoding]*/];                                     // Can raise an exception
					[inputData release];
					inputData = nil;

					aSignature = [[[verificationSignatures lastObject] retain] autorelease];                                                             // Because context will be released
					[aContext release];
					aContext = nil;

#warning Workaround for gpgme 0.4.x bug: does not return an error when CRC or BADARMOR error!
					if (aSignature == nil) {
						[[NSException exceptionWithName:GPGException reason:[[GPGMailBundle sharedInstance] gpgErrorDescription:GPGErrorInvalidArmor] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:GPGErrorInvalidArmor], GPGErrorKey, nil]] raise];
					}
				} else {
					[inputData release];
					inputData = nil;
					[aContext release];
					aContext = nil;
				}
			} else {
				[inputData release];
				inputData = nil;
				[aContext release];
				aContext = nil;
			}

			return aSignature;
		}@catch (NSException *localException) {
			[inputData release];
			[aContext release];
			[localException raise];
			return nil;     // Never reached
		}
#endif /* if 0 */
	} else {
		return nil;
	}
	return nil;             // Never reached, but mutes gcc warning
}

/*
 * // There is no easy way to force Mail to put some other
 * // MIME contents inline: MessageBody asks MIMEPart's attributedString,
 * // which invokes isAttachment, and eventually filewrapper and
 * // contentsForTextSystem.
 * // It seems that isAttachment always returns YES for application type.
 * // We'd need to poseAs MimePart to rewrite isAttachment for our special cases.
 * // We'll do it later ;-)
 *
 * - decodeApplicationPgp
 * {
 *  // Invoked automatically by -[MimePart contentsForTextSystem]
 *  // for content-type:application/pgp
 *  id	result = [self decodeTextPlain];
 *
 *  return result;
 * }
 *
 * - decodeApplicationPgp_signature
 * {
 *  // Invoked automatically by -[MimePart contentsForTextSystem]
 *  // for content-type:application/pgp-signature
 *
 *  return [self decodeTextPlain];
 * }
 */
- (BOOL)gpgSaveBodyToFile:fp12 {
	// If body was quoted-printable/base64, calling [self bodyData] will return decoded data
	return [[self bodyData] writeToFile:fp12 atomically:NO];
}


// The decode* methods return a NSAttributedString; they are invoked automatically by -[MimePart(DecodingSupport) contentsForTextSystem]

static IMP MimePart_decodeTextPlain = NULL;
static IMP MimePart_decodeTextHtml = NULL;
static IMP MimePart_decodeApplicationOctet_stream = NULL;
static IMP MimePart_decodeMultipartSigned = NULL;
static IMP MimePart_decodeMultipartEncrypted = NULL;
static IMP MimePart_decodeApplicationPgp = NULL;
static IMP MimePart_clearCachedDescryptedMessageBody = NULL;
static IMP MimePart_copySignerLabels = NULL;
static IMP MimePart_isSigned = NULL;
static IMP MimePart_isEncrypted = NULL;

+ (void)gpgAddMethodForSelector:(SEL)selector implementationSelector:(SEL)implementationSelector implementation:(IMP *)implementationPtr {
	// We don't add that method using a category,
	// to allow 'peaceful' coexistence between PGPmail and GPGMail ;-)
	// PGPmail will do the same.
	Method existingMethod = class_getInstanceMethod([self class], selector);

	if (existingMethod == NULL) {
		Method replacementMethod = class_getInstanceMethod([self class], implementationSelector);

		if (!class_addMethod([self class], selector, method_getImplementation(replacementMethod), method_getTypeEncoding(replacementMethod))) {
			NSLog(@"### ERROR: unable to add -[MimePart %@]", NSStringFromSelector(selector));
		}
	} else {
		*implementationPtr = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(decodeMultipartEncrypted), [MimePart class], implementationSelector, [MimePart class]);
		if (*implementationPtr == NULL) {
			NSLog(@"### ERROR: unable to add our version of -[MimePart %@]", NSStringFromSelector(selector));
		}
	}
}

+ (void)load {
	[self gpgInitExtraIvars];
	MimePart_decodeTextPlain = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(decodeTextPlain), [MimePart class], @selector(gpgDecodeTextPlain), [MimePart class]);
	MimePart_decodeTextHtml = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(decodeTextHtml), [MimePart class], @selector(gpgDecodeTextHtml), [MimePart class]);
	MimePart_decodeApplicationOctet_stream = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(decodeApplicationOctet_stream), [MimePart class], @selector(gpgDecodeApplicationOctet_stream), [MimePart class]);
	MimePart_decodeMultipartSigned = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(decodeMultipartSigned), [MimePart class], @selector(gpgDecodeMultipartSigned), [MimePart class]);
	MimePart_clearCachedDescryptedMessageBody = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(clearCachedDecryptedMessageBody), [MimePart class], @selector(gpgClearCachedDescryptedMessageBody), [MimePart class]);
	[self gpgAddMethodForSelector:@selector(decodeMultipartEncrypted) implementationSelector:@selector(gpgDecodeMultipartEncrypted) implementation:&MimePart_decodeMultipartEncrypted];
	[self gpgAddMethodForSelector:@selector(decodeApplicationPgp) implementationSelector:@selector(gpgDecodeApplicationPgp) implementation:&MimePart_decodeApplicationPgp];

	// Do not overload -[MimePart usesKnownSignatureProtocol], else Mail will display its banner even for PGP messages.
	MimePart_copySignerLabels = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(copySignerLabels), [MimePart class], @selector(gpgCopySignerLabels), [MimePart class]);
	// -[MimePart copyMessageSigners], invoked by -[MimePart copySignerlabels], returns a (retained) array of MessageSigner or nil.
	// -[MimePart signedData] returns a Subdata
	MimePart_isSigned = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(isSigned), [MimePart class], @selector(gpgIsSigned), [MimePart class]);
	// -[MimePart verifySignature:] modifies the NSArray ptr to return an array of MessageSigner, or NULL.
	MimePart_isEncrypted = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(isEncrypted), [MimePart class], @selector(_gpgIsEncrypted), [MimePart class]);
}

- (NSArray *)gpgCopySignerLabels {
	// FIXME: will perform verification - we don't want that; we want to use cached verification info, not perform verification now; if we prevent verification now, we no longer have opportunity to modify those signers labels!
	if (![GPGMailBundle gpgMailWorks] /*|| ![[[(MimeBody *)[self mimeBody] message] gpgMessageSignatures] count]*/) {
		return ((id (*)(id, SEL))MimePart_copySignerLabels)(self, _cmd);                                // Returns an array of NSString, or nil. Invokes -[MimePart  copyMessageSigners].
	} else {
		NSArray *pgpSignerLabels = nil;
		NSArray *smimeSignerLabels = ((id (*)(id, SEL))MimePart_copySignerLabels)(self, _cmd);          // Returns an array of NSString, or nil. Invokes -[MimePart copyMessageSigners].
		NSArray *allSignerLabels;

		if ([self gpgHasSignature]) {
			GPGSignature *sig = [self gpgAuthenticationSignature];                                      // FIXME: Does not support multiple signatures

			if ([sig status] == GPGErrorNoError) {
				NSString *aString = [sig fingerprint];
				GPGKey *signatureKey = nil;

				if (aString) {
					GPGContext *aContext = [[GPGContext alloc] init];

					@try {
						signatureKey = [aContext keyFromFingerprint:aString secretKey:NO];
					}@catch (NSException *localException) {
						[aContext release];
						[localException raise];
					}
					[aContext release];
				}
				if (signatureKey) {
					aString = [signatureKey name];                                                              // Like Apple does for S/MIME
				} else if ([aString length] >= 32) {
					aString = [GPGKey formattedFingerprint:aString];
				}
				pgpSignerLabels = [NSArray arrayWithObject:aString];
			}
		}

		if (pgpSignerLabels != nil) {
			if (smimeSignerLabels != nil) {
				allSignerLabels = [[pgpSignerLabels arrayByAddingObjectsFromArray:smimeSignerLabels] retain];
				[smimeSignerLabels release];
			} else {
				allSignerLabels = [pgpSignerLabels retain];
			}
		} else {
			allSignerLabels = smimeSignerLabels;
		}

		if ((GPGMailLoggingLevel > 0)) {
			NSLog(@"[DEBUG] %s => %@", __PRETTY_FUNCTION__, allSignerLabels);
		}

		return allSignerLabels;
	}
}

- (BOOL)gpgIsSigned {
	if (![GPGMailBundle gpgMailWorks]) {
		return ((BOOL (*)(id, SEL))MimePart_isSigned)(self, _cmd);
	} else {
		BOOL result;

		if ([self gpgHasSignature]) {
			result = YES;
		} else {
			result = ((BOOL (*)(id, SEL))MimePart_isSigned)(self, _cmd);
		}
		//    NSLog(@"%s => %@", __PRETTY_FUNCTION__, result ? @"YES":@"NO");

		return result;
	}
}

- (BOOL)_gpgIsEncrypted {
	if (![GPGMailBundle gpgMailWorks]) {
		return ((BOOL (*)(id, SEL))MimePart_isEncrypted)(self, _cmd);
	} else {
		BOOL result;

		if ([self gpgIsEncrypted]) {
			result = YES;
		} else {
			result = ((BOOL (*)(id, SEL))MimePart_isEncrypted)(self, _cmd);
		}
		//    NSLog(@"%s => %@", __PRETTY_FUNCTION__, result ? @"YES":@"NO");

		return result;
	}
}

/*!
 * Array of cached decrypted parts, or nil.
 */
- (NSArray *)gpgDecryptedParts {
	return GPG_GET_EXTRA_IVAR(@"decryptedParts");
}

- (void)setGpgDecryptedParts:(NSArray *)parts {
	GPG_SET_EXTRA_IVAR(parts, @"decryptedParts");
}
/*
 * - (GPGSignature *)gpgSignature
 * {
 *      return GPG_GET_EXTRA_IVAR(@"signature");
 * }
 *
 * - (void)setGpgSignature:(GPGSignature *)signature
 * {
 *  GPG_SET_EXTRA_IVAR(signature, @"signature");
 * }*/
/*
 * - (NSException *)gpgException
 * {
 *      return GPG_GET_EXTRA_IVAR(@"exception");
 * }
 *
 * - (void)setGpgException:(NSException *)exception
 * {
 *  GPG_SET_EXTRA_IVAR(exception, @"exception");
 * }
 */
/*!
 * If we can decrypt the part (or subparts), then we decode it, else we return nil.
 * @result Decoded content or nil.
 */
#if 0
- (id)_gpgDecodePGP_NEW {
	NSArray *decryptedParts = [self gpgDecryptedParts];              // Try to get from cache
	id result = nil;
	Message *encryptedMessage = (Message *)[[self mimeBody] message];

	if (!decryptedParts && [encryptedMessage gpgIsDecrypting]) {
		if ([self gpgIsEncrypted]) {
			if (GPGMailLoggingLevel > 0) {
				NSLog(@"[DEBUG] Will decrypt PGP part %p", self);
			}
			GPGSignature *aSignature = nil;
			NSArray *signatures = nil;
			BOOL decryptedDataContainsHeaders = [self gpgIsOpenPGPEncryptedContainerPart];
			NSData *decryptedData = [self gpgDecryptedDataWithPassphraseDelegate:[GPGMailBundle sharedInstance] signatures:&signatures];                                                                  // Can raise an exception!

			if (signatures != nil && [signatures count] > 0) {
				aSignature = [signatures objectAtIndex:0];
			}
			if (decryptedData) {
				unsigned numberOfAttachments, numberOfTNEFAttachments;
				BOOL isSigned, isEncrypted;
				NSDataMessageStore *tempMessageStore;
				Message *decryptedMessage;
				MimePart *decryptedPart;

				MutableMessageHeaders *newHeaders;
				NSMutableData *newDecryptedData;

				if ([(MimeBody *)[encryptedMessage messageBody] topLevelPart] == self) {
					newHeaders = [[encryptedMessage headers] mutableCopy];
				} else {
					newHeaders = nil;
				}

				if (decryptedDataContainsHeaders) {
					// S/MIME doesn't do that: the decrypted message has quite no header.
					// What we want is to get all the headers of the encrypted message,
					// plus/minus the ones of the decrypted message, because
					// we will display the decrypted message (unlike S/MIME which displays the decryptedBody),
					// this way we can can the raw data and headers of the decrypted message, unlike S/MIME.
					// FIXME: NO - only when top-level part!
					NSAssert(newHeaders != nil, @"### GPGMail does not support OpenPGP MIME when only part(s) of the message are encrypted");
					NSEnumerator *headerKeysToRemoveEnum = [[newHeaders _decodeHeaderKeysFromData:decryptedData] objectEnumerator];
					NSString *aHeaderKey;

					while ((aHeaderKey = [headerKeysToRemoveEnum nextObject]))
						[newHeaders removeHeaderForKey:aHeaderKey];
				}

#if DECRYPT_PGP_ATTACHMENTS
				if ([self _gpgLooksLikeBinaryPGPAttachment]) {
					NSString *aFileName = [self attachmentFilename];

					if (aFileName) {
						NSString *ext = [[aFileName pathExtension] lowercaseString];

						if ([ext isEqualToString:@"asc"] || [ext isEqualToString:@"gpg"] || [ext isEqualToString:@"pgp"]) {
							NSString *newMIME = @"";
							NSFileWrapper *dummyFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:decryptedData];

							// How can get get MIME type from extension??
							aFileName = [aFileName stringByDeletingPathExtension];
							[dummyFileWrapper setPreferredFilename:aFileName];
							newMIME = [dummyFileWrapper mimeType];
							[dummyFileWrapper release];
							// TODO: Modify newHeaders by adding new filename + new content-encoding + new MIME type
							/*                            [newHeaders removeHeaderForKey:@"content-disposition"];
							 * [newHeaders setHeader:[@"attachment; filename=" stringByAppendingString:aFileName] forKey:@"content-disposition"];
							 * [newHeaders removeHeaderForKey:@"content-type"];
							 * [newHeaders setHeader:[NSString stringWithFormat:@"%@; filename=%@", newMIME, aFileName] forKey:@"content-type"];*/
						}
					}
#warning Seems completely dans les choux with partially decrypted/decoded attachment!
				}
#endif /* if DECRYPT_PGP_ATTACHMENTS */

				newDecryptedData = [[newHeaders _encodedHeadersIncludingFromSpace:NO] mutableCopy];                                                 // Using -headerData still returns removed header!
				if (decryptedDataContainsHeaders) {
					[newDecryptedData setLength:[newDecryptedData length] - 1];                                                                     // Remove header separator char
				}
				[newDecryptedData appendData:decryptedData];
				// Enigmail uses \r\n as header line separator, whereas GPGMail only uses \n
				// If we don't do that transformation, NSDataMessageStore complaints "couldn't find body"
				// Is GPGMail wrong with its \n only?
				[newDecryptedData convertNetworkLineEndingsToUnix];
				decryptedData = [newDecryptedData autorelease];
				[newHeaders release];
				tempMessageStore = [[NSDataMessageStore alloc] initWithData:decryptedData];
				decryptedMessage = [tempMessageStore message];
				[decryptedMessage setMessageInfoFromMessage:encryptedMessage];
				decryptedMessageBody = [decryptedMessage messageBody];                                                                 // OK for Leopard, even for embedded message
				if (GPGMailLoggingLevel > 0) {
					NSLog(@"[DEBUG] Caching decrypted PGP part %p", self);
				}
				[self _setDecryptedMessageBody:decryptedMessageBody isEncrypted:YES isSigned:(aSignature != nil)];
				// We need to store that decrypted message body, because for embedded messages,
				// their messageBody is re-created at every call, and it is impossible to cache (inside Message)
				// the decrypted body. We use that cached decrypted body in
				// -[MessageContentController(PGPMail) pgpAccessoryViewOwner:displayMessage:isSigned:],
				// via -[Message(PGPMail) pgpDecrypedMessageBody]
#warning FIXME: LEOPARD We need to cache the decryptedBody
				//                theDecodeOptions.mDecryptedMessageBody = [decryptedMessageBody retain];
				decryptedPart = [decryptedMessageBody topLevelPart];                                                                 // FIXME: WRONG, in case of multiple encrypted parts
				result = [decryptedPart gpgBetterDecode];
#if 0
				[decryptedPart getNumberOfAttachments:&numberOfAttachments isSigned:&isSigned isEncrypted:&isEncrypted];
				[[encryptedMessage messageStore] setNumberOfAttachments:numberOfAttachments isSigned:(theDecodeOptions.mIsSigned) isEncrypted:(theDecodeOptions.mIsEncrypted) forMessage:encryptedMessage];
#else
				[self getNumberOfAttachments:&numberOfAttachments numberOfTNEFAttachments:&numberOfTNEFAttachments isSigned:&isSigned isEncrypted:&isEncrypted];
#warning FIXME: Set isSigned only when sig is valid
				[[encryptedMessage messageStore] setNumberOfAttachments:numberOfAttachments isSigned:(aSignature != nil) isEncrypted:YES forMessage:encryptedMessage];
#endif
				[tempMessageStore release];
				// messageStore is retained by its message, and its message is retained by the encrypted mimePart
				// Everything will be released when clearCachedDescryptedMessageBody is invoked
				// Now find a way to clear that cached decrypted body!
				// Encrypted mime part stores decrypted message body, decrypted message and decrypted message store in its _otherIvars ivar
#warning FIXME: We should store something when encrypted without sig -> no sig value = +/-1?
				[encryptedMessage setGpgSignature:aSignature];
			}
		}
	} else {
		if (/*decryptedMessageBody*/ decryptedPart != nil && GPGMailLoggingLevel > 0) {
			NSLog(@"[DEBUG] PGP part %p has already been decrypted (cache)", self);
		}
		result = [/*[decryptedMessageBody topLevelPart]*/ decryptedPart gpgBetterDecode];                                // WRONG, in case of multiple encrypted parts
	}
	if (GPGMailLoggingLevel) {
		NSLog(@"[DEBUG] Done: result = %p", result);
	}

	return result;
}
#endif /* if 0 */

- (void)resetGpgCache {
	[[self subparts] makeObjectsPerformSelector:_cmd];
	GPG_SET_EXTRA_IVAR(nil, @"range");
}

- (NSRange)gpgRange {
	NSValue *rangeValue = GPG_GET_EXTRA_IVAR(@"range");

	if (rangeValue == nil) {
		return [self range];
	} else {
		return [rangeValue rangeValue];
	}
}

- (void)shiftGpgRangeBy:(NSInteger)shift ifAfterLocation:(NSUInteger)location {
	NSRange currentRange = [self gpgRange];

	if (currentRange.location != NSNotFound && currentRange.location > location) {
		currentRange.location += shift;
		GPG_SET_EXTRA_IVAR([NSValue valueWithRange:currentRange], @"range");
	}

	NSEnumerator *partEnum = [[self subparts] objectEnumerator];
	MimePart *eachSubpart;

	while (eachSubpart = [partEnum nextObject])
		[eachSubpart shiftGpgRangeBy:shift ifAfterLocation:location];
}

- (void)setGpgRange:(NSRange)range {
	NSRange currentRange = [self gpgRange];
	NSInteger delta = (range.location - currentRange.location) + (range.length - currentRange.length);
	MimePart *topLevelPart = [[self mimeBody] topLevelPart];

	[topLevelPart shiftGpgRangeBy:delta ifAfterLocation:currentRange.location];
	GPG_SET_EXTRA_IVAR([NSValue valueWithRange:range], @"range");
}

- (id)_gpgDecodePGP {
	MimeBody *decryptedMessageBody = [self decryptedMessageBodyIsEncrypted:NULL isSigned:NULL];
	id result = nil;
	Message *encryptedMessage = (Message *)[[self mimeBody] message];

	if (!decryptedMessageBody && [encryptedMessage gpgIsDecrypting]) {
		if ([self gpgIsEncrypted]) {
			if (GPGMailLoggingLevel > 0) {
				NSLog(@"[DEBUG] Will decrypt PGP part %p", self);
			}
			GPGSignature *aSignature = nil;
			NSArray *signatures = nil;
			BOOL getsNewPartData = [self gpgIsOpenPGPEncryptedContainerPart];
			NSData *decryptedData = [self gpgDecryptedDataWithPassphraseDelegate:[GPGMailBundle sharedInstance] signatures:&signatures];                                                                  // Can raise an exception!
			BOOL isTopLevelPart = ([(MimeBody *)[encryptedMessage messageBody] topLevelPart] == self);

			if (signatures != nil && [signatures count] > 0) {
				aSignature = [signatures objectAtIndex:0];
			}
			if (decryptedData) {
				unsigned numberOfAttachments, numberOfTNEFAttachments;
				char isSigned, isEncrypted;
				NSDataMessageStore *tempMessageStore;
				Message *decryptedMessage;
				MimePart *decryptedPart;

				MutableMessageHeaders *newHeaders;
				NSMutableData *newDecryptedData;

				if (isTopLevelPart) {
					newHeaders = [[encryptedMessage headers] mutableCopy];
				} else {
#if DECRYPT_PGP_ATTACHMENTS
					// Extracting part data from message store does not work: we get ony the body data, without the headers.
//                    NSData  *originalHeaderData = [[encryptedMessage messageStore] dataForMimePart:self];
//
//                    originalHeaderData = [originalHeaderData subdataWithRange:[originalHeaderData rangeOfRFC822HeaderData]];
//                    newHeaders = [[MutableMessageHeaders alloc] initWithHeaderData:originalHeaderData encoding:NSUTF8StringEncoding]; // FIXME: not sure about encoding
//                    id  headerValue;

					newHeaders = [[MutableMessageHeaders alloc] init];
					// TODO: how can we get part's headers?
//                    headerValue = [self contentTransferEncoding];
//                    if(headerValue != nil)
//                        [newHeaders setHeader:headerValue forKey:@"content-type"];
//                    headerValue = [self contentTransferEncoding];
//                    if(headerValue != nil)
//                        [newHeaders setHeader:headerValue forKey:@"content-transfer-encoding"];
//                    headerValue = [self contentTransferEncoding];
//                    if(headerValue != nil)
//                        [newHeaders setHeader:headerValue forKey:@"content-disposition"];
//                    headerValue = [self contentDescription];
//                    if(headerValue != nil)
//                        [newHeaders setHeader:headerValue forKey:@"content-description"];
//                    headerValue = [self contentTransferEncoding];
//                    if(headerValue != nil)
//                        [newHeaders setHeader:headerValue forKey:@"content-id"];
//                    headerValue = [self contentTransferEncoding];
//                    if(headerValue != nil)
//                        [newHeaders setHeader:headerValue forKey:@"content-location"];
//                    headerValue = [self contentTransferEncoding];
//                    if(headerValue != nil)
//                        [newHeaders setHeader:headerValue forKey:@"content-languages"];
#else
					newHeaders = nil;
#endif /* if DECRYPT_PGP_ATTACHMENTS */
				}

				if (getsNewPartData) {
					// S/MIME doesn't do that: the decrypted message has quite no header.
					// What we want is to get all the headers of the encrypted message,
					// plus/minus the ones of the decrypted message, because
					// we will display the decrypted message (unlike S/MIME which displays the decryptedBody),
					// this way we can can the raw data and headers of the decrypted message, unlike S/MIME.
					// FIXME: NO - only when top-level part!
					NSAssert(newHeaders != nil, @"### GPGMail does not support OpenPGP MIME when only part(s) of the message are encrypted");
					NSEnumerator *headerKeysToRemoveEnum = [[newHeaders _decodeHeaderKeysFromData:decryptedData] objectEnumerator];
					NSString *aHeaderKey;

					while ((aHeaderKey = [headerKeysToRemoveEnum nextObject]))
						[newHeaders removeHeaderForKey:aHeaderKey];
				} else {
					BOOL isApplicationPGP = ([[[self type] lowercaseString] isEqualToString:@"application"] && [[[self subtype] lowercaseString] isEqualToString:@"pgp"]);

					if (isApplicationPGP && [[[self bodyParameterForKey:@"format"] lowercaseString] isEqualToString:@"text"]) {
						// FIXME: if not top-level part, newHeaders is nil!
						[newHeaders removeHeaderForKey:@"content-type"];
						[newHeaders setHeader:@"text/plain" forKey:@"content-type"];
					}
				}

#if DECRYPT_PGP_ATTACHMENTS
				if ([self _gpgLooksLikeBinaryPGPAttachment]) {
					NSString *aFileName = [self attachmentFilename];

					if (aFileName) {
						NSString *ext = [[aFileName pathExtension] lowercaseString];

						if ([ext isEqualToString:@"asc"] || [ext isEqualToString:@"gpg"] || [ext isEqualToString:@"pgp"]) {
							NSString *newMIME;

							// How can get get MIME type from extension??
							aFileName = [aFileName stringByDeletingPathExtension];                                                                                     // Removes only last extension (.pgp, .gpg, .asc)
							if ([decryptedData respondsToSelector:@selector(_web_guessedMIMETypeForExtension:)]) {
								newMIME = [decryptedData _web_guessedMIMETypeForExtension:[aFileName pathExtension]];
							} else {
								newMIME = @"application/octet-stream";
							}
							// Modify newHeaders by adding new filename + new content-encoding + new MIME type
							[newHeaders removeHeaderForKey:@"content-disposition"];
							[newHeaders setHeader:[@"attachment; filename=" stringByAppendingString:aFileName] forKey:@"content-disposition"];                                                                                    // FIXME: no escaping of filename
							[newHeaders removeHeaderForKey:@"content-type"];
							[newHeaders setHeader:[NSString stringWithFormat:@"%@; filename=%@", newMIME, aFileName] forKey:@"content-type"];                                                                                     // FIXME: no escaping of filename
							[newHeaders removeHeaderForKey:@"content-transfer-encoding"];
							[newHeaders setHeader:@"base64" forKey:@"content-transfer-encoding"];
//                            decryptedData = [decryptedData encodeBase64]; // FIXME: seems to be already in base64!?
						}
					}
				}
#endif /* if DECRYPT_PGP_ATTACHMENTS */
				if (!isTopLevelPart) {
					// Replace part's data with part's decrypted data,
					// in whole message data, and set decryptedData to that.
					NSData *originalHeaderData = nil;
					NSData *originalBodyData = [encryptedMessage gpgCurrentFullBodyPartDataAndHeaderDataIfReadilyAvailable:&originalHeaderData];
					NSRange partBodyRange = [self gpgRange];                                                             // FIXME: aRange.location = NSNotFound, sometimes!

//                    NSAssert(partBodyRange.location != NSNotFound, @"### GPGMail is not yet able to decode that embedded encrypted part");
					if (partBodyRange.location == NSNotFound) {
						NSLog(@"### GPGMail is not yet able to decode that embedded encrypted part");
						[NSException raise:NSInternalInconsistencyException format:@"### GPGMail is not yet able to decode that embedded encrypted part"];
					}
					if (![originalHeaderData isKindOfClass:[NSData class]]) {
						originalHeaderData = [originalHeaderData valueForKey:@"data"];                                                                          // It was actually a Subdata
					}
					if (![originalBodyData isKindOfClass:[NSData class]]) {
						originalBodyData = [originalBodyData valueForKey:@"data"];                                                                              // It was actually a Subdata
					}
					newDecryptedData = [[NSMutableData alloc] initWithData:decryptedData];
					[newDecryptedData convertNetworkLineEndingsToUnix];

					// Extract header range: search backwards for part boundary,
					// which is a line starting with '--'
					const char *partBodyDataPtr = [originalBodyData bytes] + partBodyRange.location;
					const char *aCharPtr = partBodyDataPtr;
					while (*aCharPtr != '-' || *(aCharPtr - 1) != '-' || *(aCharPtr - 2) != '\n')
						aCharPtr--;
					// Now go until next line, to get header start
					while (*aCharPtr != '\n')
						aCharPtr++;
					aCharPtr++;
					// Augment partBodyRange to include headers
					int headerPartLength = partBodyDataPtr - aCharPtr;
					partBodyRange.location -= headerPartLength;
					partBodyRange.length += headerPartLength;

					// If we had no headers, e.g. part is not a PGP attachment,
					// then use same headers as before decryption.
					if ([[newHeaders allHeaderKeys] count] == 0) {
						[newHeaders release];
						newHeaders = [[MutableMessageHeaders alloc] initWithHeaderData:[originalBodyData subdataWithRange:NSMakeRange(partBodyRange.location, headerPartLength)] encoding:NSUTF8StringEncoding];
					}

					NSRange decryptedPartBodyRange = NSMakeRange(0, [newDecryptedData length]);
					NSData *newHeadersData = [newHeaders _encodedHeadersIncludingFromSpace:NO];                                                              // Contains headers/body separator
					[newDecryptedData replaceBytesInRange:NSMakeRange(0, 0) withBytes:[newHeadersData bytes] length:[newHeadersData length]];
					decryptedPartBodyRange.location += [newHeadersData length];

					[newDecryptedData replaceBytesInRange:NSMakeRange(0, 0) withBytes:[originalHeaderData bytes] length:[originalHeaderData length]];
					[newDecryptedData replaceBytesInRange:NSMakeRange([originalHeaderData length], 0) withBytes:[[originalBodyData subdataToIndex:partBodyRange.location] bytes] length:partBodyRange.location];
					decryptedPartBodyRange.location += partBodyRange.location;
					[newDecryptedData appendData:[originalBodyData subdataFromIndex:NSMaxRange(partBodyRange)]];
					decryptedData = [newDecryptedData autorelease];
					[encryptedMessage gpgUpdateCurrentFullBodyPartData:[decryptedData subdataFromIndex:[originalHeaderData length]]];                     // Remove headers - only body
					[self setGpgRange:decryptedPartBodyRange];
				} else {
					newDecryptedData = [[newHeaders _encodedHeadersIncludingFromSpace:NO] mutableCopy];                                                   // Using -headerData still returns removed header!
					if (getsNewPartData) {
						[newDecryptedData setLength:[newDecryptedData length] - 1];                                                                       // Remove header separator char
					}
					[newDecryptedData appendData:decryptedData];
					// Enigmail uses \r\n as header line separator, whereas GPGMail only uses \n
					// If we don't do that transformation, NSDataMessageStore complaints "couldn't find body"
					// Is GPGMail wrong with its \n only?
					[newDecryptedData convertNetworkLineEndingsToUnix];
					decryptedData = [newDecryptedData autorelease];
					[newHeaders release];
				}
				tempMessageStore = [[NSDataMessageStore alloc] initWithData:decryptedData];
				decryptedMessage = [tempMessageStore message];
				[decryptedMessage setMessageInfoFromMessage:encryptedMessage];
				decryptedMessageBody = [decryptedMessage messageBody];                                                                 // OK for Leopard, even for embedded message
				if (decryptedMessageBody == nil && GPGMailLoggingLevel) {
					NSLog(@"ERROR: decryptedMessageBody should not be nil!");
				}
				if (GPGMailLoggingLevel > 0) {
					NSLog(@"[DEBUG] Caching decrypted PGP part %p", self);
				}
				[/*self*/ [[self mimeBody] topLevelPart] _setDecryptedMessageBody:decryptedMessageBody isEncrypted:YES isSigned:(aSignature != nil)];
				// We need to store that decrypted message body, because for embedded messages,
				// their messageBody is re-created at every call, and it is impossible to cache (inside Message)
				// the decrypted body. We use that cached decrypted body in
				// -[MessageContentController(PGPMail) pgpAccessoryViewOwner:displayMessage:isSigned:],
				// via -[Message(PGPMail) pgpDecrypedMessageBody]
#warning FIXME: LEOPARD We need to cache the decryptedBody
//                theDecodeOptions.mDecryptedMessageBody = [decryptedMessageBody retain];
//				decryptedPart = [decryptedMessageBody topLevelPart]; // FIXME: WRONG, in case of multiple encrypted parts
				decryptedPart = [decryptedMessageBody partWithNumber:[self partNumber]];                                                 // FIXME: WRONG, in case of PGP/MIME parts which result in multiple parts
				result = [decryptedPart gpgBetterDecode];                                                                                // Can invoke _gpgDecodePGP
#if 0
				[decryptedPart getNumberOfAttachments:&numberOfAttachments isSigned:&isSigned isEncrypted:&isEncrypted];
				[[encryptedMessage messageStore] setNumberOfAttachments:numberOfAttachments isSigned:(theDecodeOptions.mIsSigned) isEncrypted:(theDecodeOptions.mIsEncrypted) forMessage:encryptedMessage];
#else

				// TESTME! This is only a patch to bug: no automatic verification
				if (aSignature == nil) {
					aSignature = [decryptedPart gpgAuthenticationSignature];
					if (aSignature) {
						signatures = [NSArray arrayWithObject:aSignature];
					}
				}
				// End of patch

				[self getNumberOfAttachments:&numberOfAttachments numberOfTNEFAttachments:&numberOfTNEFAttachments isSigned:&isSigned isEncrypted:&isEncrypted];
#warning FIXME: Set isSigned only when sig is valid
				[[encryptedMessage messageStore] setNumberOfAttachments:numberOfAttachments isSigned:(aSignature != nil) isEncrypted:YES forMessage:encryptedMessage];
#endif
				[tempMessageStore release];
				// messageStore is retained by its message, and its message is retained by the encrypted mimePart
				// Everything will be released when clearCachedDescryptedMessageBody is invoked
				// Now find a way to clear that cached decrypted body!
				// Encrypted mime part stores decrypted message body, decrypted message and decrypted message store in its _otherIvars ivar
#warning FIXME: We should store something when encrypted without sig -> no sig value = +/-1?
				[encryptedMessage setGpgMessageSignatures:signatures];
			}
		}
	} else {
		if (decryptedMessageBody != nil && GPGMailLoggingLevel > 0) {
			NSLog(@"[DEBUG] PGP part %p has already been decrypted (cache)", self);
		}
		result = [[decryptedMessageBody topLevelPart] gpgBetterDecode];                                 // WRONG, in case of multiple encrypted parts
	}
	if (GPGMailLoggingLevel) {
		NSLog(@"[DEBUG] Done: result = %p", result);
	}

	return result;
}

- (id)gpgBetterDecode {
	if (GPGMailLoggingLevel) {
		NSLog(@"Top level part: %@", self);
	}
	NSString *type = [NSString stringWithString:(NSString *)[self type]];
	NSString *subtype = [NSString stringWithString:(NSString *)[self subtype]];
	NSString *selector = [NSString stringWithFormat:@"decode%@%@", [type capitalizedString], [[subtype stringByReplacingOccurrencesOfString:@"-" withString:@"_"] capitalizedString]];

	/* Unfortunately calling decode (replacement of contentsForTextSystem) doesn't work anymore.
	 * calling the appropriate decode method for the top part fixes the problem.
	 */
	if ([self respondsToSelector:NSSelectorFromString(selector)]) {
		return [self performSelector:NSSelectorFromString(selector)];
	} else {
		/* Otherwise try it with decode. */
		if (GPGMailLoggingLevel) {
			NSLog(@"Using decode anyway!");
		}
		return [self decode];                             // Will force re-evaluation of the decode* methods. Will not raise an exception, because -contentsForTextSystem will catch it!
	}
}

- gpgDecodeMultipartEncrypted
{
	if (![GPGMailBundle gpgMailWorks]) {
		if (MimePart_decodeMultipartEncrypted) {
			return ((id (*)(id, SEL))MimePart_decodeMultipartEncrypted)(self, _cmd);                                      // TESTME Test when PGPmail is present
		} else {
			return [self decodeMultipart];
		}
	} else {
		id result = nil;

		if (GPGMailLoggingLevel) {
			NSLog(@"[DEBUG] %p decodeMultipartEncrypted", self);
		}
		@try {
			//        [self setGpgException:nil];
			[(Message *)[[self mimeBody] message] setGpgException:nil];
			result = [self _gpgDecodePGP];                                     // Can raise an exception!
		}@catch (NSException *localException) {
			//        [localException raise]; // Exception will be caught by Mail and a message will be logged in console: '*** Exception Decryption failed was raised while decoding mime message part. Displaying as text/plain.'
			//        [self setGpgException:localException];
			[(Message *)[[self mimeBody] message] setGpgException:localException];
		}

		if (!result) {
			//        [encryptedMessage setGpgIsDecrypting:NO]; // Needed, else will try again to decrypt
			if (MimePart_decodeMultipartEncrypted) {
				result = ((id (*)(id, SEL))MimePart_decodeMultipartEncrypted)(self, _cmd);                                                  // TESTME Test when PGPmail is present
			} else {
				result = [self decodeMultipart];                                                                                            // Use default behavior (works!)
			}
		}
		if (GPGMailLoggingLevel) {
			NSLog(@"[DEBUG] Done: result = %p", result);
		}
		return result;
	}
}

- gpgDecodeMultipartSigned
{
	if (![GPGMailBundle gpgMailWorks]) {
		return ((id (*)(id, SEL))MimePart_decodeMultipartSigned)(self, _cmd);
	} else {
		if (GPGMailLoggingLevel) {
			NSLog(@"[DEBUG] %p decodeMultipartSigned", self);
		}
		id result = [self _gpgDecodePGP];

		if (!result) {
			result = ((id (*)(id, SEL))MimePart_decodeMultipartSigned)(self, _cmd);
		}
		if (GPGMailLoggingLevel) {
			NSLog(@"[DEBUG] Done: result = %p", result);
		}

		return result;
	}
}

- gpgDecodeTextPlain
{
	id result = nil;

	if (![GPGMailBundle gpgMailWorks]) {
		result = ((id (*)(id, SEL))MimePart_decodeTextPlain)(self, _cmd);
	} else {
#if 0
		//	NSLog(@"$$$ %p gpgDecodeTextPlain", self);
		result = [self _gpgDecodePGP];
		if (!result) {
			result = ((id (*)(id, SEL))MimePart_decodeTextPlain)(self, _cmd);
		}
		//	NSLog(@"$$$ Done: result = %p", result);
		return result;
#else
		if (GPGMailLoggingLevel) {
			NSLog(@"[DEBUG] %p gpgDecodeTextPlain", self);
		}
		@try {
			result = [self _gpgDecodePGP];                                     // Can raise an exception!
		}@catch (NSException *localException) {
			[(Message *)[[self mimeBody] message] setGpgException:localException];
		}

		if (!result) {
			result = ((id (*)(id, SEL))MimePart_decodeTextPlain)(self, _cmd);
		}

		return result;
#endif /* if 0 */
	}

	return result;
}

- gpgDecodeTextHtml
{
	if (![GPGMailBundle gpgMailWorks]) {
		return ((id (*)(id, SEL))MimePart_decodeTextHtml)(self, _cmd);
	} else {
		if (GPGMailLoggingLevel) {
			NSLog(@"[DEBUG] %p gpgDecodeTextHtml", self);
		}
		id result = [self _gpgDecodePGP];

		if (!result) {
			result = ((id (*)(id, SEL))MimePart_decodeTextHtml)(self, _cmd);
		}
		if (GPGMailLoggingLevel) {
			NSLog(@"[DEBUG] Done: result = %p", result);
		}
		return result;
	}
}

- gpgDecodeApplicationOctet_stream
{
	if (![GPGMailBundle gpgMailWorks]) {
		return ((id (*)(id, SEL))MimePart_decodeApplicationOctet_stream)(self, _cmd);
	} else {
		BOOL doDecode = ![[self parentPart] gpgIsOpenPGPEncryptedContainerPart];
		id result = nil;

		if (doDecode) {
			if (GPGMailLoggingLevel) {
				NSLog(@"[DEBUG] %p gpgDecodeApplicationOctet_stream", self);
			}
			result = [self _gpgDecodePGP];
		}

		if (!result) {
			result = ((id (*)(id, SEL))MimePart_decodeApplicationOctet_stream)(self, _cmd);
		}
		if (doDecode && GPGMailLoggingLevel) {
			NSLog(@"[DEBUG] Done: result = %p", result);
		}
		return result;
	}
}

- gpgDecodeApplicationPgp
{
	if (![GPGMailBundle gpgMailWorks]) {
		return ((id (*)(id, SEL))MimePart_decodeApplicationOctet_stream)(self, _cmd);
	} else {
		id result = nil;

		if (GPGMailLoggingLevel) {
			NSLog(@"[DEBUG] %p gpgDecodeApplicationPgp", self);
		}
		@try {
			result = [self _gpgDecodePGP];                                                         // Can raise an exception!
		}@catch (NSException *localException) {
			[(Message *)[[self mimeBody] message] setGpgException:localException];
		}

		if (!result) {
			if (MimePart_decodeApplicationPgp) {
				result = ((id (*)(id, SEL))MimePart_decodeApplicationPgp)(self, _cmd);                 // TESTME: Test when PGPmail is present
			} else {
				result = [self decodeApplicationOctet_stream];
			}
		}

		return result;
	}
}

- (void)gpgClearCachedDescryptedMessageBody {
	// Is invoked automatically when selection changes? Currently called by _setMessage:fp8 headerOrder: (indirectly)
	if (![GPGMailBundle gpgMailWorks]) {
		((void (*)(id, SEL))MimePart_clearCachedDescryptedMessageBody)(self, _cmd);
	} else {
		if (GPGMailLoggingLevel) {
			NSLog(@"[DEBUG] %p clearCachedDescryptedMessageBody", self);
		}
		Message *aMessage = (Message *)[[self mimeBody] message];

		if ([aMessage gpgMayClearCachedDecryptedMessageBody]) {
			[aMessage setGpgMessageSignatures:nil];
			((void (*)(id, SEL))MimePart_clearCachedDescryptedMessageBody)(self, _cmd);
			if (GPGMailLoggingLevel) {
				NSLog(@"[DEBUG] Really did it");
			}
		} else if (GPGMailLoggingLevel) {
			NSLog(@"[DEBUG] Not yet");
		}
	}
}

@end
