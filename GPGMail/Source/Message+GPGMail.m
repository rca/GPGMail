/* Message+GPGMail.m created by stephane on Fri 30-Jun-2000 */

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

#import "Message+GPGMail.h"

#import "MessageBody+GPGMail.h"
#import "MessageHeaders+GPGMail.h"
#import "GPGMailPatching.h"
#import "NSObject+GPGMail.h"
#import "GPGMessageSignature.h"
#import "MimePart+GPGMail.h"

#import <NSString+Message.h>
#import <MessageHeaders.h>
#import <MimeBody.h>
#import <MutableMessageHeaders.h>
#import <MessageStore.h>
#import <MimeBody.h>
#import <ObjectCache.h>

#import <Foundation/Foundation.h>


@implementation Message (GPGMail)

GPG_DECLARE_EXTRA_IVARS(Message)

- (BOOL)gpgIsEncrypted {
#if 0
	return [[self messageBody] gpgIsEncrypted];
#else
#warning TEST!!!
	// On Panther 7B49, sometimes deadlocks because tries to fetch body twice(?)
	// Using -messageBodyIfAvailable seems to solve problem.
	// What about decrypting non-cached messages??
	return [[self messageBodyIfAvailable] gpgIsEncrypted];
#endif
}

- (void)gpgEncryptForRecipients:(NSArray *)recipients trustAllKeys:(BOOL)trustsAllKeys signWithKey:(GPGKey *)key passphraseDelegate:(id)passphraseDelegate format:(GPGMailFormat)mailFormat {
	// Let's not try to encrypt empty messages.
	// Note that signature (if any) has already been appended at this stage.
	if ([(NSData *)[[self messageBody] rawData] length] > 0) {
		NSAutoreleasePool * localAP;
		NSMutableData * someData;
		Message * dummyMessage;
		MutableMessageHeaders * newHeaders = nil;

		NSAssert([[self messageBody] respondsToSelector:@selector(mutableData)], @"### GPGMail: -[Message(GPGMail) gpgEncryptForRecipients:signWithKey:passphraseDelegate:]: Oops, we can no longer use -[MessageBody mutableData]?!");

		localAP = [[NSAutoreleasePool alloc] init];
		someData = [NSMutableData dataWithData:[[self headers] gpgEncodedHeadersExcludingFromSpace]];
		[someData appendData:[[self messageBody] rawData]];
		// [self messageBody] is an instance of a private class _OutgoingMessageBody.
		// We need to work with a MimeBody to be able to sign it correctly,
		// that's why we create a new Message from our headers' and body's data.
		dummyMessage = [Message messageWithRFC822Data:someData];
		// WARNING: dummyMessage's headers now contain MIME headers, and body contains NO headers!

		@try {
			GPGMailFormat usedFormat = mailFormat;
			NSData * encryptedData = [(MessageBody *)[dummyMessage messageBody] gpgEncryptForRecipients:recipients trustAllKeys:trustsAllKeys signWithKey:key passphraseDelegate:passphraseDelegate format:&usedFormat headers:&newHeaders];                                 // Can raise an exception

			if (usedFormat == GPGOpenPGPMailFormat) {
				// FIXME: If we want to localize that description string, we need to encode it with qp or whatever, AND change headers; content-transfer-encoding is currently set to 7bit
				NSData * descriptionData = [NSLocalizedStringFromTableInBundle (/*@"MULTIPART_ENCRYPTED_DESCRIPTION"*/ @"This is an OpenPGP/MIME encrypted message (RFC 2440 and 3156)", @"GPGMail", [NSBundle bundleForClass:[GPGMailBundle class]], "") dataUsingEncoding:NSASCIIStringEncoding];

				[someData setData:descriptionData];
				[someData appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
				[someData appendData:encryptedData];
			} else {
				[someData setData:encryptedData];
			}
		}@catch (NSException * localException) {
			[localException retain];
			[localAP release];
			[[localException autorelease] raise];
		}
		[self performSelector:@selector(setMutableHeaders:) withObject:newHeaders]; // OutgoingMessage
		[[self messageBody] setRawData:someData];                                   // No effect on Message data
		// We need to recreate the whole raw data, headers + body.
		NSMutableData * newRawData = [NSMutableData dataWithData:[newHeaders headerData]];
		[newRawData appendData:someData];
		[[self valueForKey:@"rawData"] setData:newRawData];                         // And that works!
		[localAP release];
		// Encrypted sent messages are stored in encrypted form.
	}
	// If message body is empty, we don't encrypt anything, but we accept mail delivery
}

/*!
 * Decrypted body will be set (or not) on output.
 * @param messageSignatures On input, must be an empty array. On output, can contain GPGMessageSignature instances.
 * @throws GPGException
 */
- (void)gpgDecryptMessageWithPassphraseDelegate:(id)passphraseDelegate messageSignatures:(NSMutableArray *)messageSignatures {
	NSException * anException;

	NSAssert(![self gpgIsDecrypting], @"May not already be decrypting");

	@try {
		[self setGpgIsDecrypting:YES];
		if (GPGMailLoggingLevel) {
			NSLog(@"[DEBUG] Decrypting...");
		}
		[[[self messageBody] topLevelPart] gpgBetterDecode];                         // Evaluate the decode method matching [part type].
		if (GPGMailLoggingLevel) {
			NSLog(@"[DEBUG] Finished Decrypting");
		}
		[messageSignatures addObjectsFromArray:[self gpgMessageSignatures]];
	}
	@catch (NSException * localException) {
		if (GPGMailLoggingLevel) {
			NSLog(@"[DEBUG] Failed Decrypting");
		}
		@throw localException;
	}
	@finally{
		[self setGpgIsDecrypting:NO];
	}

	anException = [self gpgException];
	if (anException != nil) {
		[anException raise];
	}
}

- (void)gpgSignWithKey:(GPGKey *)key passphraseDelegate:(id)passphraseDelegate format:(GPGMailFormat)mailFormat {
	// Let's not try to sign empty messages. Note that signature (if any) has already been appended at this stage.
	if ([(NSData *)[[self messageBody] rawData] length] > 0) {
		NSAutoreleasePool * localAP;
		NSMutableData * someData;
		Message * dummyMessage;
		MutableMessageHeaders * newHeaders = nil;

		NSAssert([[self messageBody] respondsToSelector:@selector(mutableData)], @"### GPGMail: -[Message(GPGMail) gpgSignWithKey:passphraseDelegate:]: Oops, we can no longer use -[MessageBody mutableData]?!");

		localAP = [[NSAutoreleasePool alloc] init];
		someData = [NSMutableData dataWithData:[[self headers] gpgEncodedHeadersExcludingFromSpace]];
		[someData appendData:[[self messageBody] rawData]];
		// [self messageBody] is an instance of a private class _OutgoingMessageBody.
		// We need to work with a MimeBody to be able to sign it correctly,
		// that's why we create a new Message from our headers' and body's data.
		dummyMessage = [Message messageWithRFC822Data:someData];

		@try {
			GPGMailFormat usedFormat = mailFormat;
			NSData * signedData = [(MessageBody *)[dummyMessage messageBody] gpgSignWithKey:key passphraseDelegate:passphraseDelegate format:&usedFormat headers:&newHeaders];                                             // Can raise an exception

			if (usedFormat == GPGOpenPGPMailFormat) {
				// FIXME: If we want to localize that description string, we need to encode it with qp or whatever, AND change headers; content-transfer-encoding is currently set to 7bit
				NSData * descriptionData = [NSLocalizedStringFromTableInBundle (/*@"MULTIPART_SIGNED_DESCRIPTION"*/ @"This is an OpenPGP/MIME signed message (RFC 2440 and 3156)", @"GPGMail", [NSBundle bundleForClass:[GPGMailBundle class]], "") dataUsingEncoding:NSASCIIStringEncoding];

				[someData setData:descriptionData];
//                [someData appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
				[someData appendData:signedData];
			} else {
				[someData setData:signedData];
			}
		}@catch (NSException * localException) {
			[localException retain];
			[localAP release];
			[[localException autorelease] raise];
		}
#if 1
		[self performSelector:@selector(setMutableHeaders:) withObject:newHeaders]; // OutgoingMessage
		[[self messageBody] setRawData:someData];                                   // No effect on Message data
		// We need to recreate the whole raw data, headers + body.
		NSMutableData * newRawData = [NSMutableData dataWithData:[newHeaders headerData]];
		[newRawData appendData:someData];
		[[self valueForKey:@"rawData"] setData:newRawData];                         // And that works!
#else
		// Q: what did I try here???
//    [[self messageBody] flushEncodedBodyCache]; // Flush old data before modifying message => will recreate headers (warning: do not do it before!!)
		[[[self messageBody] performSelector:@selector(mutableData)] setData:someData];
		[self setHeaders:[dummyMessage headers]];
		[[self headers] setMessage:self];                                           // Needed!
		(void)[[self messageBody] rawData];                                         // NEEDED!
		[self setHeaders:[dummyMessage headers]];
		[[self headers] setMessage:self];                                           // Needed!
#endif
		[localAP release];
	}
	// If message body is empty, we don't sign anything, but we accept mail delivery
}

- (BOOL)gpgHasSignature {
	return [[self messageBody] gpgHasSignature];
}

/*!
 * @throws GPGException
 */
- (GPGSignature *)gpgAuthenticationSignature {
	GPGSignature * aSignature = [[self messageBody] gpgAuthenticationSignature];           // Can raise an exception

	// No immediate effect, but OK after mailbox has been closed and reopened?
	// #warning TEST update of messageStore
	[[self messageStore] setNumberOfAttachments:[[[self messageBody] attachments] count] isSigned:(aSignature != nil && [aSignature validityError] == GPGErrorNoError) isEncrypted:NO forMessage:self];
	// TESTME:
//    [[self messageStore] messageFlagsDidChange:self flags:];
//    [[self messageStore] setFlag:state:forMessage:self];

	return aSignature;
}

/*! DEPRECATED */
- (GPGSignature *)gpgEmbeddedAuthenticationSignature {
	return [[self messageBody] gpgEmbeddedAuthenticationSignature];         // Can raise an exception
}

/*! DEPRECATED */
- (BOOL)gpgIsPGPMIMEMessage {
	return [[self messageBody] gpgIsPGPMIMEMessage];
}

+ (void)load {
	[self gpgInitExtraIvars];
}

- (NSArray *)gpgMessageSignatures {
	return GPG_GET_EXTRA_IVAR(@"messageSignatures");
}

- (void)setGpgMessageSignatures:(NSArray *)messageSignatures {
	GPG_SET_EXTRA_IVAR(messageSignatures, @"messageSignatures");
}

/*!
 * @result Signature covering whole message, or nil when no signature, or signature(s) covering only part of the message
 */
- (GPGSignature *)gpgSignature {
	NSEnumerator * msgSigEnum = [[self gpgMessageSignatures] objectEnumerator];
	GPGMessageSignature * eachMsgSig;

	while (eachMsgSig = [msgSigEnum nextObject])
		if ([eachMsgSig coversWholeMessage]) {
			return [eachMsgSig signature];
		}
	return nil;
}

- (NSException *)gpgException {
	NSException * cachedException;

	cachedException = GPG_GET_EXTRA_IVAR(@"exception");

	return cachedException;
}

- (void)setGpgException:(NSException *)exception {
	GPG_SET_EXTRA_IVAR(exception, @"exception");
}

#warning FIXME: LEOPARD
/*
 * - (id)pgpDecryptedMessageBody
 * {
 *  // See -[MimePart(PGPMail) _pgpDecodePGP] for an explanation
 *  const PGPMailDecodeOptions  *ioOptionsPtr = [self pgpDecodeOptions];
 *  MessageBody                 *messageBody = ((ioOptionsPtr != NULL && ioOptionsPtr->mDecryptedMessageBody != nil) ? ioOptionsPtr->mDecryptedMessageBody : [[(MimeBody *)[self messageBody] topLevelPart] decryptedMessageBodyIsEncrypted:NULL isSigned:NULL]);
 *
 *  return messageBody;
 * }
 */

- (void)setGpgIsDecrypting:(BOOL)flag {
	if (!flag) {
		[[(MimeBody *)[self messageBody] topLevelPart] resetGpgCache];
		GPG_SET_EXTRA_IVAR(nil, @"fullBodyData");
		GPG_SET_EXTRA_IVAR(nil, @"headerData");
	}
	GPG_SET_EXTRA_IVAR([NSNumber numberWithBool:flag], @"isDecrypting");
}

- (BOOL)gpgIsDecrypting {
	return [GPG_GET_EXTRA_IVAR (@"isDecrypting")boolValue];
}

- (void)gpgSetMayClearCachedDecryptedMessageBody:(BOOL)flag {
	GPG_SET_EXTRA_IVAR([NSNumber numberWithBool:!flag], @"lockCache");
}

- (BOOL)gpgMayClearCachedDecryptedMessageBody {
	return ![GPG_GET_EXTRA_IVAR (@"lockCache")boolValue];
}


- (NSString *)gpgDescription {
	// See http://www.livejournal.com/users/jwz/505711.html
	return [[self description] stringByAppendingFormat:@" _messageFlags = 0x%0x (priority:%d%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@)",
			_messageFlags,
			((_messageFlags & 0x007F0000) >> 16),
			((_messageFlags & 0x00000001) ? @", read":@""),
			((_messageFlags & 0x00000002) ? @", deleted":@""),
			((_messageFlags & 0x00000004) ? @", answered":@""),
			((_messageFlags & 0x00000008) ? @", encrypted":@""),
			((_messageFlags & 0x00000010) ? @", flagged":@""),
			((_messageFlags & 0x00000020) ? @", recent":@""),
			((_messageFlags & 0x00000040) ? @", draft":@""),
			((_messageFlags & 0x00000080) ? @", initial":@""),                             /* no longer used */
			((_messageFlags & 0x00000100) ? @", forwarded":@""),
			((_messageFlags & 0x00000200) ? @", redirected":@""),
			((_messageFlags & 0x00800000) ? @", signed":@""),
			((_messageFlags & 0x01000000) ? @", is junk":@""),
			((_messageFlags & 0x02000000) ? @", is not junk":@""),
			((_messageFlags & 0x20000000) ? @", junk mail level recorded":@""),
			((_messageFlags & 0x0000FC00) ? [NSString stringWithFormat:@", # attachments: %d", ((_messageFlags & 0x0000FC00) >> 10)]:@""),
			((_messageFlags & 0x1C000000) ? [NSString stringWithFormat:@", font size delta: %d", ((_messageFlags & 0x1C000000) >> 26)]:@""),
			((_messageFlags & 0x40000000) ? @", highlight text in toc":@""),
			((_messageFlags & 0x80000000) ? @", u31":@"")
	];
}

/*
 * When decrypting multiple encrypted parts, we need to have an up-to-date
 * fullBodyData.
 */
- (NSData *)gpgCurrentFullBodyPartDataAndHeaderDataIfReadilyAvailable:(NSData **)headerDataPtr {
	NSData * cachedData = GPG_GET_EXTRA_IVAR(@"fullBodyData");

	if (cachedData == nil) {
		cachedData = [[self messageStore] fullBodyDataForMessage:self andHeaderDataIfReadilyAvailable:headerDataPtr];
		GPG_SET_EXTRA_IVAR(cachedData, @"fullBodyData");
		GPG_SET_EXTRA_IVAR(*headerDataPtr, @"headerData");
	} else {
		*headerDataPtr = GPG_GET_EXTRA_IVAR(@"headerData");
	}

	return cachedData;
}

- (void)gpgUpdateCurrentFullBodyPartData:(NSData *)newData {
	GPG_SET_EXTRA_IVAR(newData, @"fullBodyData");
}

@end

/*
 * when decrypting a message, create a NSDataMessageStore initialized with decrypted data(?);
 * messageStore will be dealloc'd when the decrypted/encrypted(?) will be dealloc'd
 *
 */
