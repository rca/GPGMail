/* MimeBody+GPGMail.m created by stephane on Thu 06-Jul-2000 */

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
 * THIS SOFTWARE IS PROVIDED BY THE GPGMAIL PROJECT TEAM ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGMAIL PROJECT TEAM BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MimeBody+GPGMail.h"
#import "MimePart+GPGMail.h"
#import "MessageBody+GPGMail.h"
#import "MessageHeaders+GPGMail.h"
#import "NSData+GPGMail.h"
#import "NSString+GPGMail.h"
#import "GPGMailBundle.h"
#import "GPGMailPatching.h"

#import <Message.h>
#import <MutableMessageHeaders.h>
#import <MessageStore.h>
#import <MessageWriter.h>
//#import <MimeTextAttachment.h>
#import <ObjectCache.h>
#import <NSData+Message.h>
#import <NSString+Message.h>

#import <Foundation/Foundation.h>


@interface MimeBody(GPGMailPrivate)
- (NSData *) gpgOpenPGPSignWithKey:(GPGKey *)key passphraseDelegate:(id)passphraseDelegate encapsulated:(BOOL)encapsulated headers:(MutableMessageHeaders **)headersPtr;
@end

@implementation MimeBody(GPGMail)

- (BOOL) gpgIsEncrypted
{
    // In this case we assume that we don't need to decode quoted-printable/base64
    // Most of the time, raw data has been flushed and can be retrieved
    // only this way. If we don't do this, body data is nil!
    // It may happen that rawData is nil, in case message body is on server (not cached)
    // and server is unreachable. If body is readable, it will never (?) return nil.
#warning COMMENTED OUT next two lines
//    if([self rawData] == nil)
//        return NO;
//    NSParameterAssert([self rawData] != nil);
	(void)[self mimeType];

    return [[self topLevelPart] gpgIsEncrypted];
}

- (MessageBody *) gpgDecryptedBodyWithPassphraseDelegate:(id)passphraseDelegate signature:(NSArray **)signaturesPtr headers:(MessageHeaders **)decryptedMessageHeaders
{
    NSData	*decryptedData;

    decryptedData = [[self topLevelPart] gpgDecryptedDataWithPassphraseDelegate:passphraseDelegate signatures:signaturesPtr]; // Can raise an exception
    if(decryptedData){
        MutableMessageHeaders	*headers = [[[self message] headers] mutableCopy];
        NSData					*headerData;
        NSRange					headerBodySeparationRange;

        // When decrypting data which is an encapsulated signature,
        // it may happen that line-endings are CRLF, what causes problems to Mail
        // Let's be sure that line-endings are Unix.
        // This is needed for Sylpheed's encapsulated signatures.
        decryptedData = [NSMutableData dataWithData:decryptedData];
        [(NSMutableData *)decryptedData convertNetworkLineEndingsToUnix];
        headerBodySeparationRange = [decryptedData gpgHeaderBodySeparationRange];
            
        // WARNING: it may happen that decrypted contains NO MIME headers!!! (plain text encryption, not OpenPGP)
        // In this case, the first char is 0x0a (or maybe 0x0d ?)
        // => do NOT try to get headers...
        
#warning Should we not remove MIME headers first?
        NSAssert(headerBodySeparationRange.location != NSNotFound, @"Unexpected case...");
        if(headerBodySeparationRange.location != 0){
            // These new headers are only MIME ones
            NSString		*aKey;
            NSEnumerator	*orderEnum;
            
            headerData = [decryptedData subdataWithRange:NSMakeRange(0, headerBodySeparationRange.location)];// or NSMaxRange(headerBodySeparationRange)?
if(0){
#warning This patch does not help...
    NSMutableData	*myData = [NSMutableData dataWithData:headerData];
    int				i = 0, myCount = [myData length];
    BOOL			beginsLine = YES, myModification = NO;
    char			*myBytes = [myData mutableBytes];
    
    for(i = 0; i < myCount; i++){
        if(myBytes[i] == ' ' && beginsLine){
            myBytes[i] = '\t';
            myModification = YES;
        }
        beginsLine = (myBytes[i] == '\n');
    }
    if(myModification){
        [myData convertNetworkLineEndingsToUnix];
        headerData = myData;
    }
}
            MessageHeaders  *tempHeaders;
            
            tempHeaders = [[MessageHeaders alloc] initWithHeaderData:headerData encoding:kCFStringEncodingUTF8]; // Core Foundation encoding!
            orderEnum = [[headers _decodeHeaderKeysFromData:headerData] objectEnumerator];
            while(aKey = [orderEnum nextObject])
#warning FIXME: LEOPARD - which method??
				[headers setHeader:[tempHeaders firstHeaderForKey:aKey] forKey:aKey];
            [tempHeaders release];
        }
        else{
            // plain/text (non OpenPGP style) messages
            headerData = [NSData dataWithData:[[[self message] messageStore] headerDataForMessage:[self message]]];
        }
        // Tomio used to include headerBodySeparation in decrypted data, whereas I don't
        // Including it means that we also add a supplementary separating line
        // between displayed headers and body.
        decryptedData = [decryptedData subdataWithRange:NSMakeRange(NSMaxRange(headerBodySeparationRange), [decryptedData length] - NSMaxRange(headerBodySeparationRange))]; // We NEED to remove headers from body data...

        *decryptedMessageHeaders = [headers autorelease];
		// Headers are now OK

        {
            MimeBody	*decryptedBody = [[MimeBody alloc] init];
            
#warning FIXME: No longer needed - done differently?
	//            [((MessageStore *)[[self message] messageStore])->_caches.objectCaches._bodyDataCache setObject:decryptedData forKey:[NSValue valueWithNonretainedObject:decryptedBody]];
	//            [((MessageStore *)[[self message] messageStore])->_caches.objectCaches._headerCache setObject:headerData forKey:[NSValue valueWithNonretainedObject:decryptedBody]];
	return [NSDictionary dictionaryWithObjectsAndKeys:headerData, @"headerData", decryptedData, @"decryptedData", [decryptedBody autorelease], @"decryptedBody", nil];
        }
    }
    return nil;
}

- (NSData *) gpgOpenPGPEncryptForRecipients:(NSArray *)recipients trustAllKeys:(BOOL)trustsAllKeys signWithKey:(GPGKey *)key passphraseDelegate:(id)passphraseDelegate headers:(MutableMessageHeaders **)headersPtr
{
	// (Message may be signed or not; if signed, signature is embedded in encrypted file)
	// Copy headers content-transfer-encoding and content-type to the beginning of the body (+ empty line)
	// Set headers Content-Type = multipart/encrypted; boundary=foo; protocol="application/pgp-encrypted"
	// and content-transfer-encoding = ???
	// Encode modified body
	// Modify body this way:
    
	// --foo
    // Content-Type: application/pgp-encrypted
    //
    // Version: 1
    //
    // --foo
    // Content-Type: application/octet-stream
    //
    // <PGP block>
    //
    // --foo--

    // Perhaps we will need to register ourself as handler for these new MIME types.
    // Other headers: content-id, content-description, content-disposition

    // First, we need to retrieve the MIME-specific headers; they need to be embedded in the encrypted data.
    NSMutableData			*dataToEncrypt = [NSMutableData data];
    NSData					*encryptedData = nil;
    MutableMessageHeaders	*newHeaders = [[[self message] headers] mutableCopy];
    MutableMessageHeaders	*headersToEncrypt = [[MutableMessageHeaders alloc] init];
    NSString				*newBoundary = [MimeBody createMimeBoundary];
    BOOL					usesQuotedPrintable = NO;
    GPGContext              *aContext;
    GPGData                 *inputData;
    NSData                  *rawData = [self gpgRawData];

    [headersToEncrypt setHeader:[newHeaders firstHeaderForKey:@"content-type"] forKey:@"content-type"];
    [headersToEncrypt setHeader:[newHeaders firstHeaderForKey:@"content-transfer-encoding"] forKey:@"content-transfer-encoding"];

    NSAssert2([rawData length] > 0, @"-[%@ %@]: No data to encrypt!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    // We don't support 8bit data from Mail; this is OK currently.
    // Would we support it, we should check all MIME parts for their charset
    // (if content-transfer-encoding is 8bit), and find the common one,
    // then convert parts to this encoding, OR use quoted-printable or base64.
    // Much too complicated, and not necessary currently.
    // Note that RFC3156 accepts encrypting 8bit data, if data is not signed.
//    NSAssert(![rawData gpgContainsNonASCIICharacter], @"We support only 7bit content-transfer-encoding");
    
    if(key != nil){
        if(![[GPGMailBundle sharedInstance] usesEncapsulatedSignature]){
            [dataToEncrypt appendData:[headersToEncrypt gpgEncodedHeadersExcludingFromSpace]]; // Already contains ending spacer
            [dataToEncrypt appendData:rawData];
            // Fix for attachments which contain non-ASCII chars: despite this has been reported to Apple,
            // they don't consider it a bug; let's replace non-ASCII chars (normally only in headers) by '_'
            [dataToEncrypt gpgASCIIfy];
//            [dataToEncrypt gpgNormalizeDataForSigning];
        }
        else{
            // RFC 1847 Encapsulation
            NSData	*tempData = [self gpgOpenPGPSignWithKey:key passphraseDelegate:passphraseDelegate encapsulated:YES headers:headersPtr];
            
            key = nil;
            [dataToEncrypt appendData:tempData];
        }
    }
    else{
        [dataToEncrypt appendData:[headersToEncrypt gpgEncodedHeadersExcludingFromSpace]]; // Already contains ending spacer
        [dataToEncrypt appendData:rawData];
    }

    aContext = [[GPGContext alloc] init];
    [aContext setPassphraseDelegate:passphraseDelegate];
    [aContext setUsesArmor:YES];
    [aContext setUsesTextMode:YES];
    if(key != nil){
        [aContext addSignerKey:key];
    }
    inputData = [[GPGData alloc] initWithData:dataToEncrypt];
    if(GPGMailLoggingLevel & GPGMailDebug_SaveInputDataMask){
        NSString    *filename = [NSTemporaryDirectory() stringByAppendingPathComponent:[[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"txt"]];
        
        if([dataToEncrypt writeToFile:filename atomically:NO])
            NSLog(@"[DEBUG] Data to encrypt/sign in %@", filename);
        else
            NSLog(@"[DEBUG] FAILED to write data to encrypt/sign in %@", filename);
    }
    @try{
        GPGData *outputData;

#warning Set encoding!
        if(key != nil)
            outputData = [aContext encryptedSignedData:inputData withKeys:recipients trustAllKeys:trustsAllKeys /* encoding:kCFStringEncodingISOLatin1*/]; // Can raise an exception
        else{
            if(recipients == nil){
                // Symetric encryption
                outputData = [aContext encryptedData:inputData/* encoding:kCFStringEncodingISOLatin1*/]; // Can raise an exception
            }
            else
                outputData = [aContext encryptedData:inputData withKeys:recipients trustAllKeys:trustsAllKeys/* encoding:kCFStringEncodingISOLatin1*/]; // Can raise an exception
        }

            // Can also happen when a key has been revoked, is invalid, has expired
//            [NSException raise:NSGenericException format:@"Unable to find public keys for some addresses, or keys need to be (locally) signed"];
        encryptedData = [[[outputData data] retain] autorelease]; // Because context will be freed
	}@catch(NSException *localException){
        [inputData release];
        [aContext release];
        [newHeaders release];
        [headersToEncrypt release];
        [localException raise];
    }
    [inputData release];
    [aContext release];
    [headersToEncrypt release];

    // We check whether encryptedData contains only ASCII; might not be the case
    // if user added a comment to the armor with other chars... (this is bad practice)
    // In that case, we always use UTF-8 (We could/should test whether data is valid UTF8).
    if([encryptedData gpgContainsNonASCIICharacter]){
        encryptedData = [encryptedData encodeQuotedPrintableForText:YES];
        usesQuotedPrintable = YES;
    }

    [newHeaders removeHeaderForKey:@"content-type"];
    [newHeaders removeHeaderForKey:@"content-transfer-encoding"];
    [newHeaders setHeader:@"7bit" forKey:@"content-transfer-encoding"];
    [newHeaders setHeader:[NSString stringWithFormat:@"multipart/encrypted; protocol=\"application/pgp-encrypted\";\n\tboundary=\"%@\"", newBoundary] forKey:@"content-type"];
    if([[GPGMailBundle sharedInstance] addsCustomHeaders])
        [newHeaders setHeader:[@"GPGMail " stringByAppendingString:[(GPGMailBundle *)[GPGMailBundle sharedInstance] version]] forKey:GPGMailHeaderKey];
	newHeaders = [[MutableMessageHeaders alloc] initWithHeaderData:[[newHeaders autorelease] encodedHeadersIncludingFromSpace:NO] encoding:[newHeaders preferredEncoding]]; // Needed, to ensure _data ivar is updated
    if(headersPtr != NULL)
        *headersPtr = newHeaders;
    [newHeaders autorelease];
    
    dataToEncrypt = [NSMutableData data];
#if 0
    [dataToEncrypt appendData:[@"\n--" dataUsingEncoding:NSASCIIStringEncoding]];
#else
#warning According to Tomio, we should not have a LF as first char
    [dataToEncrypt appendData:[@"--" dataUsingEncoding:NSASCIIStringEncoding]];
#endif
    [dataToEncrypt appendData:[newBoundary dataUsingEncoding:NSASCIIStringEncoding]];
    [dataToEncrypt appendData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [dataToEncrypt appendData:[@"content-type: application/pgp-encrypted\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [dataToEncrypt appendData:[@"content-transfer-encoding: 7bit\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [dataToEncrypt appendData:[@"content-description: " dataUsingEncoding:NSASCIIStringEncoding]];
    [dataToEncrypt appendData:[NSLocalizedStringFromTableInBundle(@"CONTENT_DESCRIPTION_HEADER", @"GPGMail", [NSBundle bundleForClass:[GPGMailBundle class]], "") encodedHeaderData]];
    [dataToEncrypt appendData:[@"\n\n"dataUsingEncoding:NSASCIIStringEncoding]];
    [dataToEncrypt appendData:[@"Version: 1\n\n--" dataUsingEncoding:NSASCIIStringEncoding]];
    [dataToEncrypt appendData:[newBoundary dataUsingEncoding:NSASCIIStringEncoding]];
    [dataToEncrypt appendData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [dataToEncrypt appendData:[@"content-type: application/octet-stream; name=\"" dataUsingEncoding:NSASCIIStringEncoding]];
    [dataToEncrypt appendData:[NSLocalizedStringFromTableInBundle(@"PGP_ENCRYPTED_FILENAME", @"GPGMail", [NSBundle bundleForClass:[GPGMailBundle class]], "") encodedHeaderData]];
    [dataToEncrypt appendData:[@".asc\"" dataUsingEncoding:NSASCIIStringEncoding]];
    if(!usesQuotedPrintable){
        [dataToEncrypt appendData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding]];
        [dataToEncrypt appendData:[@"content-transfer-encoding: 7bit\n" dataUsingEncoding:NSASCIIStringEncoding]];
    }
    else{
        [dataToEncrypt appendData:[[@"; charset=" stringByAppendingString:(NSString *)CFStringConvertEncodingToIANACharSetName(kCFStringEncodingUTF8)] dataUsingEncoding:NSASCIIStringEncoding]];
        [dataToEncrypt appendData:[@"content-transfer-encoding: quoted-printable\n" dataUsingEncoding:NSASCIIStringEncoding]];
    }
    [dataToEncrypt appendData:[@"content-description: " dataUsingEncoding:NSASCIIStringEncoding]];
#warning Take care of line length
    [dataToEncrypt appendData:[NSLocalizedStringFromTableInBundle(@"This is an encrypted message part", @"GPGMail", [NSBundle bundleForClass:[GPGMailBundle class]], "") encodedHeaderData]];
    // Now we do it like Enigmail: we put content inline (but still provide a file name)
    [dataToEncrypt appendData:[@"\ncontent-disposition: inline; filename=\"" dataUsingEncoding:NSASCIIStringEncoding]];
#warning Take care of line length
    [dataToEncrypt appendData:[NSLocalizedStringFromTableInBundle(@"PGP_ENCRYPTED_FILENAME", @"GPGMail", [NSBundle bundleForClass:[GPGMailBundle class]], "") encodedHeaderData]];
    [dataToEncrypt appendData:[@".asc\"\n\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [dataToEncrypt appendData:encryptedData];
    [dataToEncrypt appendData:[@"\n--" dataUsingEncoding:NSASCIIStringEncoding]];
    [dataToEncrypt appendData:[newBoundary dataUsingEncoding:NSASCIIStringEncoding]];
    [dataToEncrypt appendData:[@"--\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    return [[dataToEncrypt retain] autorelease];
}

- (NSData *) gpgEncryptForRecipients:(NSArray *)recipients trustAllKeys:(BOOL)trustsAllKeys signWithKey:(GPGKey *)key passphraseDelegate:(id)passphraseDelegate format:(GPGMailFormat *)mailFormatPtr headers:(MutableMessageHeaders **)headersPtr
{
    NSParameterAssert(mailFormatPtr != NULL);
    switch(*mailFormatPtr){
        case GPGLegacyPGPMailFormat:
        case GPGAutomaticMailFormat:
            // Bug: if message contains only an attachment of type text/plain,
            // even if message is actually multipart, [self mimeType] still returns "text"!
            // => check top-level part:
            if([[(MimePart *)[self topLevelPart] type] isEqualToString:@"text"] && [[(MimePart *)[self topLevelPart] subtype] isEqualToString:@"plain"]){
                // Plain text (inline) old style
                *mailFormatPtr = GPGLegacyPGPMailFormat;
                return [super gpgEncryptForRecipients:recipients trustAllKeys:trustsAllKeys signWithKey:key passphraseDelegate:passphraseDelegate format:mailFormatPtr headers:headersPtr];
            }
            else
                *mailFormatPtr = GPGOpenPGPMailFormat;
            // No break, on purpose!
        case GPGOpenPGPMailFormat:
            // OpenPGP style
            return [self gpgOpenPGPEncryptForRecipients:recipients trustAllKeys:trustsAllKeys signWithKey:key passphraseDelegate:passphraseDelegate headers:headersPtr];
        default:
            NSAssert1(*mailFormatPtr == GPGLegacyPGPMailFormat || *mailFormatPtr == GPGAutomaticMailFormat || *mailFormatPtr == GPGOpenPGPMailFormat, @"Invalid mail format (%d)!", *mailFormatPtr);
            return nil; // Never reached
    }
}

- (BOOL) gpgHasSignature
{
	// In this case we assume that we don't need to decode quoted-printable/base64
	// Most of the time, raw data has been flushed and can be retrieved
	// only this way. If we don't do this, body data is nil!
    // It may happen that rawData is nil, in case message body is on server (not cached)
    // and server is unreachable. If body is readable, it will never (?) return nil.
#warning COMMENTED OUT next two lines
//    if([self rawData] == nil)
//        return NO;
//    NSParameterAssert([self rawData] != nil);
	(void)[self mimeType]; // Still needed?
    
    return [[self topLevelPart] gpgHasSignature];
}

- (BOOL) gpgAllAttachmentsAreAvailable
{
    return [[self topLevelPart] gpgAllAttachmentsAreAvailable];
}

- (GPGSignature *) gpgEmbeddedAuthenticationSignature
{
    return [[self topLevelPart] gpgAuthenticationSignature]; // Can raise an exception
}

- (GPGSignature *) gpgAuthenticationSignature
{
    return [[self topLevelPart] gpgAuthenticationSignature]; // Can raise an exception
}

- (NSData *)gpgRawDataWithEnforcedQuotedPrintable
{
    // TODO: recreate message body and parts; for each text/plain part, 
    // enforce quoted-printable; create new message from these parts, 
    // and get the message body's raw data
//    BOOL            modifiedBody = NO;
//    NSEnumerator    *partEnum = [self allPartsEnumerator];
//    MimePart        *eachPart;
//    
//    while(eachPart = [partEnum nextObject]){
//        if([[[eachPart type] lowercaseString] isEqualToString:@"text"] && [[[eachPart subtype] lowercaseString] isEqualToString:@"plain"] && [[[eachPart contentTransferEncoding] lowercaseString] isEqualToString:@"7bit"]){
//            modifiedBody = YES;
//            [eachPart setContentTransferEncoding:@"quoted-printable"];
//        }
//    }
//    if(modifiedBody)
//        NSLog(@"===>\n%@", [[[NSString alloc] initWithData:[self gpgRawData] encoding:NSASCIIStringEncoding] autorelease]); // TODO: will still return old data; how to change that? Clear cache? MessageWriter is used in a separate thread...
    
    return [self gpgRawData];
}

- (NSData *) gpgOpenPGPSignWithKey:(GPGKey *)key passphraseDelegate:(id)passphraseDelegate encapsulated:(BOOL)encapsulated headers:(MutableMessageHeaders **)headersPtr
{
    // Copy headers content-transfer-encoding and content-type to the beginning of the body (+ empty line?)
    // Set headers Content-Type = multipart/signed; boundary=bar; micalg=pgp-md5; protocol="application/pgp-signature"
    // and content-transfer-encoding = ???
    // Encode modified body
    // Modify body this way:

    // --bar
    // <PGP signed block, without PGP boundaries => original encoded body, prepended with headers (used for sig too)>
    //
    // --bar
    // Content-Type: application/pgp-signature
    //
    // <PGP sig block>
    //
    // --foo--

    NSMutableData			*dataToSign = [NSMutableData data], *signedData;
    NSData					*signatureData = nil;
    MutableMessageHeaders	*newHeaders = [[[self message] headers] mutableCopy];
    MutableMessageHeaders	*headersToSign = [[MutableMessageHeaders alloc] init];
    NSString				*newBoundary = [MimeBody createMimeBoundary];
    GPGHandler				*aHandler;
    BOOL					signatureDataIsOnlyASCII;
    GPGContext              *aContext;
    GPGData                 *inputData;
//    NSData                  *data;
    GPGSignature            *newSignature;
    NSData                  *rawData = /*[self gpgRawData]*/[self gpgRawDataWithEnforcedQuotedPrintable];

    [headersToSign setHeader:[newHeaders firstHeaderForKey:@"content-type"] forKey:@"content-type"];
    [headersToSign setHeader:[newHeaders firstHeaderForKey:@"content-transfer-encoding"] forKey:@"content-transfer-encoding"];

    NSAssert2([rawData length] > 0, @"-[%@ %@]: No data to sign!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    // 'From ' escaping is done by Mail, no need to check.
    // We also don't need to check for trailing spaces, Mail cares for it. FIXME: NOT TRUE!!!
    [dataToSign appendData:[headersToSign gpgEncodedHeadersExcludingFromSpace]]; // Already contains ending spacer
    [dataToSign appendData:rawData];
    [dataToSign gpgNormalizeDataForSigning];
    // "all data signed according to this protocol MUST be constrained to 7 bits"
    // Normally, Mail already takes care of it, by using quoted-printable or base64 if necessary
    if([dataToSign gpgContainsNonASCIICharacter]){
        // Fix for attachments which contain non-ASCII chars: despite this has been reported to Apple,
        // they don't consider it a bug; let's replace non-ASCII chars (normally only in headers) by '_'
        [dataToSign gpgASCIIfy];
    }
    NSAssert(![dataToSign gpgContainsNonASCIICharacter], @"Signed part can only contain 7bit bytes");

    aContext = [[GPGContext alloc] init];
    [aContext setPassphraseDelegate:passphraseDelegate];
    [aContext setUsesArmor:YES];
    [aContext setUsesTextMode:YES];
    [aContext addSignerKey:key];
#warning FIXME: For each text/plain format=flowed MIME part, fix the usenet sig space by quoting it
//    if([[eachPart bodyParameterForKey:@"format"] isEqualToString:@"flowed"])
//        dataToSign = [dataToSign gpgFormatFlowedFixedWithCRLF:useCRLF useQP:NO];
    // We can iterate through all parts, and ask them for their format=flowed, and getting their data
    // out of [self rawData] using their -range
    inputData = [[GPGData alloc] initWithData:dataToSign];
    if(GPGMailLoggingLevel & GPGMailDebug_SaveInputDataMask){
        NSString    *filename = [NSTemporaryDirectory() stringByAppendingPathComponent:[[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"txt"]];
        
        if([dataToSign writeToFile:filename atomically:NO])
            NSLog(@"[DEBUG] Data to sign in %@", filename);
        else
            NSLog(@"[DEBUG] FAILED to write data to sign in %@", filename);
    }
    @try{
#warning Use kCFStringEncodingISOLatin1 encoding!
        GPGData *outputData = [aContext signedData:inputData signatureMode:GPGSignatureModeDetach /*encoding:kCFStringEncodingISOLatin1*/]; // Can raise an exception
        // We can safely use kCFStringEncodingISOLatin1, because dataToSign is only on 7 bits

        signatureData = [outputData data];
    }@catch(NSException *localException){
        [inputData release];
        [aContext release];
        [newHeaders release];
        [headersToSign release];
        [localException raise];
    }
    [inputData release];

    newSignature = [[[aContext operationResults] objectForKey:@"newSignatures"] lastObject];
    if(newSignature == nil){
        NSLog(@"### GPGMail: unable to create signature!");
        [aContext release];
        [newHeaders release];
        [headersToSign release];
#warning FIXME: Use specific error message
        [NSException raise:GPGMailException format:@"NO_VALID_PRIVATE_KEY"];
    }

    aHandler = [GPGHandler handler];
    if(!encapsulated){
        NSString    *hashAlgorithm = [[GPGMailBundle sharedInstance] hashAlgorithmDescription:[newSignature hashAlgorithm]]; // FIXME: Should we check strict conformance to OpenPGP in hash choice?
        
        [newHeaders removeHeaderForKey:@"content-type"];
        [newHeaders removeHeaderForKey:@"content-transfer-encoding"];
        [newHeaders setHeader:[NSString stringWithFormat:@"multipart/signed; protocol=\"application/pgp-signature\";\n\tmicalg=%@; boundary=\"%@\"", [@"pgp-" stringByAppendingString:hashAlgorithm], newBoundary] forKey:@"content-type"];
        [newHeaders setHeader:@"7bit" forKey:@"content-transfer-encoding"];
        if([[GPGMailBundle sharedInstance] addsCustomHeaders])
            [newHeaders setHeader:[@"GPGMail " stringByAppendingString:[(GPGMailBundle *)[GPGMailBundle sharedInstance] version]] forKey:GPGMailHeaderKey];
		newHeaders = [[MutableMessageHeaders alloc] initWithHeaderData:[[newHeaders autorelease] encodedHeadersIncludingFromSpace:NO] encoding:[newHeaders preferredEncoding]]; // Needed, to ensure _data ivar is updated
        if(headersPtr != NULL)
            *headersPtr = newHeaders;
    }
    [newHeaders autorelease];
    
    signedData = [NSMutableData data];
    if(!encapsulated)
#if 1
#warning RESTORED THIS, BECAUSE WAS MISSING SPACER
        [signedData appendData:[@"\n--" dataUsingEncoding:NSASCIIStringEncoding]];
#else
#warning According to Tomio, we should not have LF as first char
        [signedData appendData:[@"--" dataUsingEncoding:NSASCIIStringEncoding]];
#endif
    else{
        NSString    *hashAlgorithm = [[GPGMailBundle sharedInstance] hashAlgorithmDescription:[newSignature hashAlgorithm]]; // FIXME: Should we check strict conformance to OpenPGP in hash choice?

        [signedData appendData:[[NSString stringWithFormat:@"Content-type: multipart/signed; protocol=\"application/pgp-signature\";\n\tmicalg=%@; boundary=\"%@\"\n", [@"pgp-" stringByAppendingString:hashAlgorithm], newBoundary] dataUsingEncoding:NSASCIIStringEncoding]];
        [signedData appendData:[@"Content-transfer-encoding: 7bit\n" dataUsingEncoding:NSASCIIStringEncoding]];
        if([[GPGMailBundle sharedInstance] addsCustomHeaders])
            [signedData appendData:[[NSString stringWithFormat:@"%@: GPGMail %@\n", GPGMailHeaderKey, [(GPGMailBundle *)[GPGMailBundle sharedInstance] version]] dataUsingEncoding:NSASCIIStringEncoding]];
        
        [signedData appendData:[@"\n--" dataUsingEncoding:NSASCIIStringEncoding]];
    }
    [signedData appendData:[newBoundary dataUsingEncoding:NSASCIIStringEncoding]];
    [signedData appendData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding]];
#if 0
    [signedData appendData:[headersToSign gpgEncodedHeadersExcludingFromSpace]]; // Already contains ending spacer
    [signedData appendData:[self rawData]];
#else
#warning CHECK THIS
    {
        NSMutableData	*convertedData = [NSMutableData dataWithData:dataToSign];

        [convertedData convertNetworkLineEndingsToUnix];
        [signedData appendData:convertedData];
    }
#endif
    [signedData appendData:[[NSString stringWithFormat:@"\n--%@\n", newBoundary] dataUsingEncoding:NSASCIIStringEncoding]];
    [headersToSign release];

    // Signature part
    // We check whether signatureData contains only ASCII; might not be the case
    // if user added a comment to the armor with other chars... (this is bad practice)
    // In that case, we always use UTF-8 (We could/should test whether data is valid UTF8).
    signatureDataIsOnlyASCII = ![signatureData gpgContainsNonASCIICharacter];
    [signedData appendData:[@"content-type: application/pgp-signature; x-mac-type=70674453;\n\tname=" dataUsingEncoding:NSASCIIStringEncoding]];
#warning CHECK whether we need to enclose filename in double-quotes
#warning Take care of line length
    [signedData appendData:[NSLocalizedStringFromTableInBundle(@"PGP_SIGNATURE_FILENAME", @"GPGMail", [NSBundle bundleForClass:[GPGMailBundle class]], "") encodedHeaderData]];
    [signedData appendData:[@".sig" dataUsingEncoding:NSASCIIStringEncoding]];
    if(!signatureDataIsOnlyASCII)
        [signedData appendData:[[@"; charset=" stringByAppendingString:(NSString *)CFStringConvertEncodingToIANACharSetName(kCFStringEncodingUTF8)] dataUsingEncoding:NSASCIIStringEncoding]];
    [signedData appendData:[@"\ncontent-description: " dataUsingEncoding:NSASCIIStringEncoding]];
#warning Take care of line length
    [signedData appendData:[NSLocalizedStringFromTableInBundle(@"This is a digitally signed message part", @"GPGMail", [NSBundle bundleForClass:[GPGMailBundle class]], "") encodedHeaderData]];
    [signedData appendData:[@"\ncontent-disposition: inline; filename=" dataUsingEncoding:NSASCIIStringEncoding]];
#warning CHECK whether we need to enclose filename in double-quotes
#warning Take care of line length
    [signedData appendData:[NSLocalizedStringFromTableInBundle(@"PGP_SIGNATURE_FILENAME", @"GPGMail", [NSBundle bundleForClass:[GPGMailBundle class]], "") encodedHeaderData]];
    [signedData appendData:[@".sig\n" dataUsingEncoding:NSASCIIStringEncoding]];
    // Force the use of quoted-printable. It should be more robust (Idea by Roberto Aguilar!)
    if(!signatureDataIsOnlyASCII){
        signatureData = [signatureData encodeQuotedPrintableForText:YES];
        // What about base64 instead?
        [signedData appendData:[@"content-transfer-encoding: quoted-printable\n\n" dataUsingEncoding:NSASCIIStringEncoding]];
    }
    else
        [signedData appendData:[@"content-transfer-encoding: 7bit\n\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [signedData appendData:signatureData];
    [signedData appendData:[[NSString stringWithFormat:@"\n--%@--\n", newBoundary] dataUsingEncoding:NSASCIIStringEncoding]];
    [aContext release];
    
    return [[signedData retain] autorelease];
}

- (NSData *) gpgSignWithKey:(GPGKey *)key passphraseDelegate:(id)passphraseDelegate format:(GPGMailFormat *)mailFormatPtr headers:(MutableMessageHeaders **)headersPtr
{
    NSParameterAssert(mailFormatPtr != NULL);
    switch(*mailFormatPtr){
        case GPGLegacyPGPMailFormat:
        case GPGAutomaticMailFormat:
            if([[self mimeType] isEqualToString:@"text"] && [[self mimeSubtype] isEqualToString:@"plain"]){
                *mailFormatPtr = GPGLegacyPGPMailFormat;
                return [super gpgSignWithKey:key passphraseDelegate:passphraseDelegate format:mailFormatPtr headers:headersPtr];
            }
            else
                *mailFormatPtr = GPGOpenPGPMailFormat;
            // No break, on purpose!
        case GPGOpenPGPMailFormat:
            return [self gpgOpenPGPSignWithKey:key passphraseDelegate:passphraseDelegate encapsulated:NO headers:headersPtr];
        default:
            NSAssert1(*mailFormatPtr == GPGLegacyPGPMailFormat || *mailFormatPtr == GPGAutomaticMailFormat || *mailFormatPtr == GPGOpenPGPMailFormat, @"Invalid mail format (%d)!", *mailFormatPtr);
            return nil; // Never reached
    }
}

- (BOOL) gpgIsPGPMIMEMessage
{
    return [[self topLevelPart] gpgIsOpenPGPEncryptedContainerPart] || [[self topLevelPart] gpgIsOpenPGPSignedContainerPart];
}

@end

#if 0

@interface NSDataMessageStore : MessageStore
{
    NSData *_data;	// 88 = 0x58
}

- (id)initWithData:(id)fp8;
- (void)dealloc;
- (id)storePath;
- (id)headerDataForMessage:(id)fp8;
- (id)bodyDataForMessage:(id)fp8;
- (id)_setOrGetBody:(id)fp8 forMessage:(id)fp12;

@end

#import "GPGMailPatching.h"
#import "MimePart.h"

@implementation MimePart(XXX)

static IMP  MimePart_decodeText = NULL;
static IMP  MimePart_decryptedMessageBody = NULL;
/*
+ (void) load
{
    MimePart_decodeText = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(decodeText), [MimePart class], @selector(gpgDecodeText), [MimePart class]);
    MimePart_decryptedMessageBody = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(decryptedMessageBody), [MimePart class], @selector(gpgDecryptedMessageBody), [MimePart class]);
}
*/
- (void) xxxdecrypt
{
    if([self decryptedMessageBody] == nil){
        if([self gpgIsEncrypted]){
            if(GPGMailLoggingLevel)
                NSLog(@"[DEBUG] %p decryption...", self);
            GPGSignature    *aSignature = nil;
            NSArray         *signatures = nil;
            MimeBody        *decryptedBody;
            MessageHeaders  *decryptedMessageHeaders;
            MessageStore    *messageStore = [(Message *)[[self mimeBody] message] messageStore];
            
            decryptedBody = [[self mimeBody] gpgDecryptedBodyWithPassphraseDelegate:[GPGMailBundle sharedInstance] signatures:&signatures headers:&decryptedMessageHeaders];
            if(signatures != nil && [signatures count] > 0)
                aSignature = [signatures objectAtIndex:0];
            NSMutableData *headerData = [decryptedMessageHeaders encodedHeadersIncludingFromSpace:NO];
            NSMutableData *theData = [NSMutableData dataWithData:headerData];
            id  dataMessageStore = messageStore; // should be NSMessageDataStore
            
            [theData appendData:[messageStore->_bodyDataCache objectForKey:decryptedBody]];
            Message         *decryptedMessage = [Message messageWithRFC822Data:theData];
            [decryptedBody setMessage:decryptedMessage];
            [messageStore _setHeaderDataInCache:headerData forMessage:decryptedMessage];
            [messageStore->_headerCache removeObjectForKey:decryptedBody];
            [decryptedMessage setMessageFlags:[[[self mimeBody] message] messageFlags]];
            [messageStore->_bodyCache setObject:decryptedBody forKey:decryptedMessage];
            [messageStore->_bodyDataCache setObject:[messageStore->_bodyDataCache objectForKey:decryptedBody] forKey:decryptedMessage];
            [messageStore->_bodyDataCache removeObjectForKey:decryptedBody];
            [decryptedMessage setMessageStore:dataMessageStore];
            [[decryptedMessage messageStore] setNumberOfAttachments:[[decryptedBody attachments] count] isSigned:(aSignature != nil && [aSignature validityError] == GPGErrorNoError) isEncrypted:YES forMessage:decryptedMessage];
            MimePart    *newPart = [[MimePart alloc] init];
            [(MimeBody *)decryptedBody setTopLevelPart:newPart];
            [newPart setMimeBody:decryptedBody];
            [newPart release];
            NSAssert1([[(MimeBody *)decryptedBody topLevelPart] parseMimeBody], @"### GPGMail: %s: cannot parse body!", __PRETTY_FUNCTION__);
            
            [self _setDecryptedMessageBody:decryptedBody];
            [[[[self mimeBody] message] messageStore] setNumberOfAttachments:0 isSigned:(aSignature != nil) isEncrypted:YES forMessage:[[self mimeBody] message]];
            NSLog(@"[self decryptedMessageBody] = %@", [self decryptedMessageBody]);
#warning Maybe will work when we use real NSDataMessageStore?
        }
    }    
}

- (id) gpgDecodeText
{
    id  result;
    
    [self xxxdecrypt];
    result = MimePart_decodeText(self, _cmd);
    
    return result;
}

- (id) gpgDecryptedMessageBody
{
    if(GPGMailLoggingLevel)
    NSLog(@"%p decryptedMessageBody", self);
    id  result = MimePart_decryptedMessageBody(self, _cmd);
    if(GPGMailLoggingLevel)
    NSLog(@"=> %@", result);
    return result;
}

@end

#endif

// FIXME: Never invoked
//@implementation MessageWriter(GPGMail)
//
//static IMP MessageWriter_appendDataForMimePart_toData_withPartData = NULL;
//
//+ (void)load
//{
//    MessageWriter_appendDataForMimePart_toData_withPartData = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(appendDataForMimePart:toData:withPartData:), [MessageWriter class], @selector(gpgAppendDataForMimePart:toData:withPartData:), [MessageWriter class]);
//}
//
//- (void)gpgAppendDataForMimePart:(id)fp8 toData:(id)fp12 withPartData:(id)fp16
//{
//    ((void (*)(id, SEL, id, id, id))MessageWriter_appendDataForMimePart_toData_withPartData)(self, _cmd, fp8, fp12, fp16);
//}
//
//@end
