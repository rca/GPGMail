/* MessageBody+GPGMail.m created by dave on Thu 02-Nov-2000 */

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

#import "MessageBody+GPGMail.h"
#import "NSData+GPGMail.h"
#import "NSString+GPGMail.h"
#import "GPGMailBundle.h"
#import "GPGDefaults.h"

#import <NSData+Message.h>
#import <NSString+Message.h>
#import <Message.h>
#import <MessageHeaders.h>
#import <MimeBody.h>
#import <MimePart.h>
#import <MutableMessageHeaders.h>
#import <ObjectCache.h>
#import <MessageStore.h>
#import <MacGPGME/MacGPGME.h>

#import <Foundation/Foundation.h>


/*
 *	Read messages always have MimeBodies, even if they are plain text messages.
 *  New messages have a _OutgoingMessageBody
 *  There is no instance of MessageBody, ever(?).
 */

NSString	*GPGMailHeaderKey = @"X-PGP-Agent";

@implementation MessageBody(GPGMail)

- (void) gpgSetEncodedBody:(NSData *)data
{
#if defined(SNOW_LEOPARD) || defined(LEOPARD) || defined(TIGER)
	// Hopefully not necessary to play with cache
#else
    if([[self message] messageStore])
        [((MessageStore *)[[self message] messageStore])->_bodyDataCache setObject:data forKey:[self message]];
    else{
        NSLog(@"### GPGMail: Unable to modify encodedBody");
    }
#endif
}

- (NSData *) gpgEncryptForRecipients:(NSArray *)recipients trustAllKeys:(BOOL)trustsAllKeys signWithKey:(GPGKey *)key passphraseDelegate:(id)passphraseDelegate format:(GPGMailFormat *)mailFormatPtr headers:(MutableMessageHeaders **)headersPtr
{
    // For text/plain messages, we encrypt/sign displayed text, not encoded (raw) text,
    // and THEN we apply quoted-printable/base64, for example. Thus encrypted/signed data
    // can be 8bit data.
    // This way users can sign/verify displayed text (that's how most plug-ins work, I guess)
    NSData					*modifiedData = nil, *dataToModify = [self gpgRawData];
    BOOL					usesQuotedPrintable = NO, usedQuotedPrintable = NO;
    BOOL					usesBase64 = NO, usedBase64 = NO;
    CFStringEncoding		newEncoding, originalEncoding;
    MutableMessageHeaders	*newHeaders;
    GPGContext              *aContext;
    GPGData                 *inputData;
    // IMPORTANT: for encrypted messages, we no longer keep the original
    // content-transfer-encoding, because PGP7 plug-in uses encoded data when decrypting,
    // and fails to, when content-transfer-encoding is not 7bit!
    BOOL					keepsOriginalContentTransferEncoding = (recipients == nil);
    BOOL                    useCRLF = [[GPGDefaults gpgDefaults] boolForKey:@"GPGUsesAlwaysCRLF"];

    NSAssert1([dataToModify length] > 0, @"### %s: No data to encrypt/sign!", __PRETTY_FUNCTION__);

    // If message contains non-ASCII chars, it (normally) should have been quoted-printable'd
    // or base64'd.
    // Thus we need to decode it, encrypt/sign it, and requote it.
    usedQuotedPrintable = [[(MessageHeaders *)[[self message] headers] firstHeaderForKey:@"content-transfer-encoding"] isEqualToString:@"quoted-printable"];
    if(usedQuotedPrintable)
        dataToModify = [dataToModify decodeQuotedPrintableForText:YES];
    else{
        usedBase64 = [[(MessageHeaders *)[[self message] headers] firstHeaderForKey:@"content-transfer-encoding"] isEqualToString:@"base64"];
        if(usedBase64)
            dataToModify = [dataToModify decodeBase64];
    }

//    if(key != nil)
    if(useCRLF)
        dataToModify = [dataToModify gpgStandardizedEOLsToCRLF];
    else
        dataToModify = [dataToModify gpgStandardizedEOLsToLF]; // Let's standardize end-of-lines; we use LF end-of-line, because other mailers interpret CRLF as end-of-line + empty line (CR)

    newEncoding = originalEncoding = [[(MimeBody *)self topLevelPart] textEncoding];

    dataToModify = [GPGHandler convertedStringData:dataToModify fromEncoding:originalEncoding toEncoding:&newEncoding];
    if(key != nil && recipients == nil){
        NSString  *formatParam = [[(MimeBody *)self topLevelPart] bodyParameterForKey:@"format"];

        if([formatParam isEqualToString:@"flowed"]){
            // With format=flowed, a space at the end of a line means "line goes on next line", except when line is "-- ".
            // Mail does its job correctly by removing all other trailing spaces, but after a message has been signed,
            // the exception line '-- ' has been transformed into '- -- ', and the exception is no longer an exception!
            // In consequence, MUA will display the line following the '- -- ' line on the same line (flowed), what is wrong.
            // To avoid that we replace the '-- ' lines by '--', and they will be transformed by gpg into '- --', what is correct.
            // We can't, AFAIK, keep the trailing space in the usenet sig separator without breaking something; this can only be done
            // with OpenPGP/MIME which can escape the trailing space using quoted-printable, for example.
            dataToModify = [dataToModify gpgFormatFlowedFixedWithCRLF:useCRLF useQP:NO];
        }
    }

    aContext = [[GPGContext alloc] init];
    [aContext setPassphraseDelegate:passphraseDelegate];
    [aContext setUsesArmor:YES];
    [aContext setUsesTextMode:YES];
    if(key != nil)
        [aContext addSignerKey:key];
    inputData = [[GPGData alloc] initWithData:dataToModify];
    if(GPGMailLoggingLevel & GPGMailDebug_SaveInputDataMask){
        NSString    *filename = [NSTemporaryDirectory() stringByAppendingPathComponent:[[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"txt"]];
        
        if([dataToModify writeToFile:filename atomically:NO])
            NSLog(@"[DEBUG] Data to encrypt/sign in %@", filename);
        else
            NSLog(@"[DEBUG] FAILED to write data to encrypt/sign in %@", filename);
    }
    
    @try{
        GPGData *outputData;

#warning Use newEncoding!
        if(recipients != nil){
            if(key != nil)
#warning Use also encapsulated signature!
                outputData = [aContext encryptedSignedData:inputData withKeys:recipients trustAllKeys:trustsAllKeys /*encoding:newEncoding*/];
            else{
                outputData = [aContext encryptedData:inputData withKeys:recipients trustAllKeys:trustsAllKeys /*encoding:newEncoding*/];
            }
        }
        else{
            if(key != nil)
                outputData = [aContext signedData:inputData signatureMode:GPGSignatureModeClear /*encoding:newEncoding*/];
            else{
                // Symetric encryption
                outputData = [aContext encryptedData:inputData /*encoding:newEncoding*/];
            }
        }
        modifiedData = [[[outputData data] retain] autorelease]; // Because context will be freed
//            [NSException raise:GPGException format:@"%@", NSLocalizedStringFromTableInBundle(@"UNTRUSTED RECIPIENTS", @"GPGMail", [NSBundle bundleForClass:[GPGMailBundle class]], "")];
    }@catch(NSException *localException){
        [inputData release];
        [aContext release];
        [localException raise];
	}
    [inputData release];
    [aContext release];
    
    // We must convert to quoted-printable/base64 AFTER having
    // encrypted the message (that's what do other MUAs).
#warning If PGP block contains non-ASCII chars, we MUST keep original content-transfer-encoding!
#warning How could we know that we should use base64 now? (based on PGP sig comments...)
    if(keepsOriginalContentTransferEncoding && usedBase64){
        modifiedData = [modifiedData encodeBase64];
        usesBase64 = YES;
    }
#warning TESTME: now we always force using quoted-printable
    else /*if([modifiedData gpgContainsNonASCIICharacter] || (keepsOriginalContentTransferEncoding && usedQuotedPrintable))*/{
        // If body contains non-ASCII character, we need to use quoted-printable
        // characters, as non-ASCII characters could be modified by some MTA
        // and invalidate the signature.
        modifiedData = [modifiedData encodeQuotedPrintableForText:YES];
        usesQuotedPrintable = YES;
//        NSLog(@"$$$ FORCING QUOTED-PRINTABLE $$$");
    }
    
    [self gpgSetEncodedBody:modifiedData]; // Replace current encrypted data; this modification IS persistent (i.e. saved in mailbox)
    // Let's also modify the headers to create a basic MIME
    // message with quoted-printable/base64 (if needed) and appropriate character set.
    newHeaders = [[[self message] headers] mutableCopy];

/*    if(!keepsOriginalContentTransferEncoding)
        [newHeaders setHeader:@"7bit" forKey:@"content-transfer-encoding"];
    else*/ if(usesQuotedPrintable && !usedQuotedPrintable)
        [newHeaders setHeader:@"quoted-printable" forKey:@"content-transfer-encoding"];
    else if(usesBase64 && !usedBase64)
        [newHeaders setHeader:@"base64" forKey:@"content-transfer-encoding"];
    if(newEncoding != originalEncoding){
        // Let's replace only the charset
#warning TODO: for encrypted messages, pass charset in PGP block (instead?)
        NSMutableString	*newContentType = [NSMutableString stringWithString:[newHeaders firstHeaderForKey:@"content-type"]];
        NSString		*charset = [[(MimeBody *)self topLevelPart] bodyParameterForKey:@"charset"];
        NSRange			charsetRange = [newContentType rangeOfString:charset];
        
        NSAssert2(charsetRange.location != NSNotFound, @"### -[MessageBody(GPGMail)  gpgEncryptForRecipients:signWithKey:passphraseDelegate:]: unable to find charset '%@' in '%@'", charset, newContentType);
        [newContentType replaceCharactersInRange:charsetRange withString:(NSString *)CFStringConvertEncodingToIANACharSetName(newEncoding)];
        [newHeaders setHeader:newContentType forKey:@"content-type"];
    }
    if([[GPGMailBundle sharedInstance] addsCustomHeaders])
        [newHeaders setHeader:[@"GPGMail " stringByAppendingString:[(GPGMailBundle *)[GPGMailBundle sharedInstance] version]] forKey:GPGMailHeaderKey];
#if defined(SNOW_LEOPARD) || defined(LEOPARD)
    newHeaders = [[MutableMessageHeaders alloc] initWithHeaderData:[[newHeaders autorelease] encodedHeadersIncludingFromSpace:NO] encoding:[newHeaders preferredEncoding]]; // Needed, to ensure _data ivar is updated
#endif
    if(headersPtr != NULL)
        *headersPtr = newHeaders;
    [newHeaders autorelease];

    return modifiedData;
}

- (NSData *) gpgSignWithKey:(GPGKey *)key passphraseDelegate:(id)passphraseDelegate format:(GPGMailFormat *)mailFormatPtr headers:(MutableMessageHeaders **)headersPtr
{
    return [self gpgEncryptForRecipients:nil trustAllKeys:YES signWithKey:key passphraseDelegate:passphraseDelegate format:mailFormatPtr headers:headersPtr];
}

- (BOOL) gpgIsEncrypted
{
    // This method is not used, because all messageBodies are MimeBody instances
    [NSException raise:NSGenericException format:@"### GPGMail: %s: unexpected case!", __PRETTY_FUNCTION__];
    return NO;
}

- (MessageBody *) gpgDecryptedBodyWithPassphraseDelegate:(id)passphraseDelegate signatures:(NSArray **)signaturesPtr headers:(MessageHeaders **)decryptedMessageHeaders
{
    // This method is not used, because all messageBodies are MimeBody instances
    [NSException raise:NSGenericException format:@"### GPGMail: %s: unexpected case!", __PRETTY_FUNCTION__];
    return nil;
}

- (NSRange) _gpgSignedRange
{
    // This method is not used, because all messageBodies are MimeBody instances
    [NSException raise:NSGenericException format:@"### GPGMail: %s: unexpected case!", __PRETTY_FUNCTION__];
    return NSMakeRange(NSNotFound, 0);
}

- (BOOL) gpgHasSignature
{
    // This method is not used, because all messageBodies are MimeBody instances
    [NSException raise:NSGenericException format:@"### GPGMail: %s: unexpected case!", __PRETTY_FUNCTION__];
    return NO;
}

- (GPGSignature *) gpgAuthenticationSignatureFromData:(NSData *)data
{
    // This method is not used, because all messageBodies are MimeBody instances
    [NSException raise:NSGenericException format:@"### GPGMail: %s: unexpected case!", __PRETTY_FUNCTION__];
    return nil;
}

- (GPGSignature *) gpgAuthenticationSignature
{
    // This method is not used, because all messageBodies are MimeBody instances
    [NSException raise:NSGenericException format:@"### GPGMail: %s: unexpected case!", __PRETTY_FUNCTION__];
    return nil;
}

- (GPGSignature *) gpgEmbeddedAuthenticationSignature
{
    return [self gpgAuthenticationSignature];
}

- (BOOL) gpgIsPGPMIMEMessage
{
    return NO;
}

- (NSData *)gpgRawData
{
#if defined(SNOW_LEOPARD) || defined(LEOPARD)
	return [[[self message] messageStore] bodyDataForMessage:[self message]]; // Always returns new instance
#else
	return [self rawData];
#endif
}

@end
