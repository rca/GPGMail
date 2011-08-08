/* MimePart+GPGMail.m created by stephane on Mon 10-Jul-2000 */

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
 * THIS SOFTWARE IS PROVIDED BY GPGTools Project Team AND CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL GPGTools Project Team AND CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Libmacgpg/Libmacgpg.h>
#import <Libmacgpg/GPGKey.h>
#import "CCLog.h"
#import "NSObject+LPDynamicIvars.h"
#import "MimePart+GPGMail.h"
#import "NSString+GPGMail.h"
#import <NSString-NSStringUtils.h>
#import <NSData-MimeDataEncoding.h>
#import <MFMimeDecodeContext.h>
#import <Message.h>
#import <MessageWriter.h>
#import <MimeBody.h>
#import <MutableMessageHeaders.h>
#import "GPGMailBundle.h"

const NSString *PGP_MESSAGE_BEGIN = @"-----BEGIN PGP MESSAGE-----";
const NSString *PGP_MESSAGE_END = @"-----END PGP MESSAGE-----";
const NSString *PGP_SIGNED_MESSAGE_BEGIN = @"-----BEGIN PGP SIGNED MESSAGE-----";
const NSString *PGP_MESSAGE_SIGNATURE_BEGIN = @"-----BEGIN PGP SIGNATURE-----";
const NSString *PGP_MESSAGE_SIGNATURE_END = @"-----END PGP SIGNATURE-----";

@implementation MimePart (GPGMail)

- (id)MADecodeWithContext:(id)ctx {
    DebugLog(@"[DEBUG] %s enter - decoding: %@", __PRETTY_FUNCTION__,
          [(Message *)[(MimeBody *)[self mimeBody] message] subject]);
    NSString *type = [NSString stringWithString:(NSString *)[self type]];
	NSString *subtype = [NSString stringWithString:(NSString *)[self subtype]];
	NSString *selectorName = [NSString stringWithFormat:@"MADecode%@%@WithContext:", [type capitalizedString], [[subtype stringByReplacingOccurrencesOfString:@"-" withString:@"_"] capitalizedString]];
    char isEncrypted, isSigned;
    NSError *error;
    MimeBody *decryptedMessageBody;
    // decodeApplicationGpg_EncryptedWithContext is not automatically called
    // by GPGMail, therefore we need to call it ourselves. 
    // At the moment this only happens if decrypting was initiated by the
    // user. 
    // This might be extended to whenever Mail loads the message.
    SEL selector = NSSelectorFromString(selectorName);
    
    // We have two different scenarios.
    // 1.) Non MIME GPG.
    //     The problem is, this could be either text/plain or multipart/alternative (for what reason ever, enigmail does that).
    //     So let's check if the message is encrypted, in that case find the data part and return it decoded.
    // 2.) MIME GPG.
    //     Way easiert, just call the MADecodeMultipartEncryptedWithContext and done!
    NSNumber *shouldBeDecrypting = [[(MimeBody *)[self mimeBody] message] getIvar:@"shouldBeDecrypting"];
    id pgpInfo = [[[self mimeBody] topLevelPart] getIvar:@"gpgDataRange"];

    // Check if we're in shouldBeDecrypting state AND if either we have implemented
    // a matching selector (would be PGP/MIME) or gpgDataRange (Non PGP/MIME) is set.
    if([shouldBeDecrypting boolValue] && (pgpInfo != nil || [self respondsToSelector:selector])) {
        // One of the two matches so first check if the message has already been decrypted and cached.
        decryptedMessageBody = [self decryptedMessageBodyIsEncrypted:&isEncrypted isSigned:&isSigned error:&error];
        if(decryptedMessageBody != nil) {
            ((MFMimeDecodeContext *)ctx).shouldSkipUpdatingMessageFlags = NO;
            return [[decryptedMessageBody topLevelPart] decodeWithContext:ctx];
        }
        // Not yet decrypted and cached, perform either PGP/MIME or Non PGP/MIME operation.
        if(pgpInfo) {
            return [self decodeTextPlainWithContext:ctx];
        }
        // Otherwise it's PGP/MIME and our own decode selector for multipart/encrypted is called.
        return [self performSelector:selector withObject:ctx];
    }
    // Not decrypting or not encrypted message -> invoking original method.
    return [self MADecodeWithContext:ctx];
}

- (id)MADecodeMultipartEncryptedWithContext:(id)ctx {
    // If this is the top level part, decrypt it!
    MimePart *dataPart = [[[self mimeBody] topLevelPart] subpartAtIndex:1];
    NSData *encryptedData = [dataPart bodyData];
    // TODO: Don't always use the decodeQuotedPrintable. It might return nothing
    // useful if quoted-printable is not set on the e-
    return [self MADecodeApplicationPgp_EncryptedWithData:[encryptedData decodeQuotedPrintableForText:YES] context:ctx];
}

- (id)MADecodeTextPlainWithContext:(id)ctx {
    // Extract the PGP block from the plain text, if available.
    // Check if gpgDataRange is available, otherwise just exit decryption mode.
    // Check if there's a PGP signature in the plain text.
    BOOL isEncrypted = NO;
    BOOL isSigned = NO;
    NSRange pgpSignedRange = [self rangeOfPlainPGPSignatures];
    if([[[self mimeBody] topLevelPart] ivarExists:@"gpgDataRange"])
        isEncrypted = YES;
    if(pgpSignedRange.location != NSNotFound)
        isSigned = YES;
    
    if(isEncrypted) {
        NSRange gpgDataRange = [[[[self mimeBody] topLevelPart] getIvar:@"gpgDataRange"] rangeValue];
        NSData *encryptedData = [[[self mimeBody] bodyData] subdataWithRange:gpgDataRange];
        // If the transfer encoding is set to quoted-printable, we have to run the data 
        // to decodeQuotedPrintableForText first.
        BOOL quotedPrintable = [[self.contentTransferEncoding lowercaseString] isEqualToString:@"quoted-printable"];
        NSData *realEncryptedData = quotedPrintable ? [encryptedData decodeQuotedPrintableForText:YES] : encryptedData;
        
        
        return [self MADecodeApplicationPgp_EncryptedWithData:realEncryptedData context:ctx];
    }
    else if(isSigned) {
        [self _verifyPGPInlineSignature];
    }
    
    id ret = [self MADecodeTextPlainWithContext:ctx];
    DebugLog(@"[DEBUG] before Return value: %@", ret);
    if(isSigned)
        ret = [self stripSignatureFromContent:ret];
    DebugLog(@"[DEBUG] after Return value: %@", ret);
    
    return ret;
}

- (id)stripSignatureFromContent:(id)content {
    if([content isKindOfClass:[NSString class]]) {
        NSRange startRange = [content rangeOfString:(NSString *)PGP_MESSAGE_SIGNATURE_BEGIN];
        if(startRange.location == NSNotFound)
            return content;
        NSRange endRange = [content rangeOfString:(NSString *)PGP_MESSAGE_SIGNATURE_END];
        if(endRange.location == NSNotFound)
            return content;
        NSRange gpgSignatureRange = NSUnionRange(startRange, endRange);
        NSString *strippedContent = [content stringByReplacingCharactersInRange:gpgSignatureRange withString:@""];
        return strippedContent;
    }
    return content;
}

// TODO: Implement better check to understand whether the decrypted data contains mail headers or not (pgp inline encrypted).
// TODO: If it doesn't contain mail headers add a method for better understanding if the decrypted data
//       contains HTML and don't change \n to <br> in that case.
- (id)MADecodeApplicationPgp_EncryptedWithData:(NSData *)encryptedData context:(id)ctx {
    __block NSData *decryptedData;
    __block NSArray *signatures = nil;
    [[GPGMailBundle sharedInstance] addDecryptionTask:^{
        GPGController *gpgc = [[GPGController alloc] init];
        gpgc.verbose = (GPGMailLoggingLevel > 0);
        @try {
            decryptedData = [gpgc decryptData:encryptedData];
            signatures = [gpgc signatures];
            [signatures retain];
        }
        @catch(NSException *e) {
            DebugLog(@"[DEBUG] %s exception: %@", __PRETTY_FUNCTION__, e);
            decryptedData = nil;
        }
        @finally {
            [gpgc release];
        }
    }];
    // TODO: Perform some error handling here. Store the error in self->_smimeError.
    if(decryptedData == nil)
        return nil;
    // Remove all added ivars, otherwise mail could try to decrypt
    // already decrypted data again. 
    [[(MimeBody *)[self mimeBody] message] removeIvar:@"shouldBeDecrypting"];
    [[(MimeBody *)[self mimeBody] topLevelPart] removeIvar:@"hasRunEncryptedCheck"];
    // 1. Create a new Message using messageWithRFC822Data:
    // This creates the message store automatically!
    Message *decryptedMessage = [Message messageWithRFC822Data:decryptedData];
    // If the encrypted message contains no mime parts (in plain text encrypted case)
    // messageWithRFC822Data will contain an empty message body. In that case, let's add
    // a fake boundary.
    DebugLog(@"[DEBUG] %s decrypted message: %@", __PRETTY_FUNCTION__, [NSString stringWithData:decryptedData encoding:NSASCIIStringEncoding]);
    DebugLog(@"[DEBUG] %s decrypted message size: %llu", __PRETTY_FUNCTION__, [decryptedMessage messageSize]);
#warning This is no good check at all for finding out if the decrypted data contains email headers (pgp inline encrypted) but must do for now...
    if([decryptedMessage messageSize] == 0 || [[NSString stringWithData:decryptedData encoding:NSASCIIStringEncoding] rangeOfString:@"content-type" options:NSCaseInsensitiveSearch].location == NSNotFound) {
        // We'll try to use the message writer to get something we can use.
        NSMutableData *bodyData = [[NSMutableData alloc] initWithCapacity:0];
        MessageWriter *mw = [[MessageWriter alloc] init];
        MimePart *topLevelPart = [[MimePart alloc] init];
        // Use text/html so html contained is rendered correctly.
        // Not sure this makes sense, but let's keep it for the moment.
        // Only problem, \n must be replaced with <br>.
        // If the content actually contains HTML, this unfortunately adds another <br>...
        [topLevelPart setType:@"text"];
        [topLevelPart setSubtype:@"html"];
        [topLevelPart setBodyParameter:[[MimeBody newMimeBoundary] autorelease] forKey:@"boundary"];
        MutableMessageHeaders *headers = [[MutableMessageHeaders alloc] initWithHeaderData:[(MessageHeaders *)[(Message *)[(MimeBody *)[self mimeBody] message] headers] headerData] encoding:NSASCIIStringEncoding];
        NSMutableData *contentTypeData = [[NSMutableData alloc] initWithLength:0];
        [contentTypeData appendData:[[NSString stringWithFormat:@"%@/%@;", [topLevelPart type], [topLevelPart subtype]] dataUsingEncoding:NSASCIIStringEncoding]];
        for(id key in [topLevelPart bodyParameterKeys])
            [contentTypeData appendData:[[NSString stringWithFormat:@"\n\t%@=\"%@\";", key, [topLevelPart bodyParameterForKey:key]] dataUsingEncoding:NSASCIIStringEncoding]];
        [headers setHeader:contentTypeData forKey:@"content-type"];
        [contentTypeData release];
        [headers setHeader:[GPGMailBundle agentHeader] forKey:@"x-pgp-agent"];
        [headers removeHeaderForKey:@"content-disposition"];
        [headers removeHeaderForKey:@"from "];
        [bodyData appendData:[headers encodedHeadersIncludingFromSpace:NO]];
        // Convert newlines to breaks.
        NSString *decryptedDataString = [decryptedData gpgString];
        decryptedDataString = [decryptedDataString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        decryptedData = [decryptedDataString dataUsingEncoding:NSUTF8StringEncoding];
        // Don't set neither charset nor encoding, so hopefully Mail
        // will guess.
        CFMutableDictionaryRef partsRef = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
        CFDictionaryAddValue(partsRef, topLevelPart, decryptedData);
        NSMutableDictionary *partBodyMap = (NSMutableDictionary *)partsRef;
        [mw appendDataForMimePart:topLevelPart toData:bodyData withPartData:partBodyMap];
        CFRelease(partsRef);
        
        decryptedMessage = [Message messageWithRFC822Data:bodyData];
        [bodyData release];
        [topLevelPart release];
        [mw release];
        [headers release];
    }
    // This is a test, to have the message seem signed... we'll see..
    // 2. Set message info from the original encrypted message.
    [decryptedMessage setMessageInfoFromMessage:[(MimeBody *)[self mimeBody] message]];
    // 3. Call message body updating flags to set the correct flags for the new message.
    // This will setup the decrypted message, run through all parts and find signature part.
    // We'll save the message body for later, since it will be used to do a last
    // decodeWithContext and the output returned.
    MimeBody *decryptedMimeBody = [decryptedMessage messageBodyUpdatingFlags:YES];
    // Check if signatures are available. If not, they could still be in a mime part,
    // but messageBodyUpdatingFlags will take care of those.
    // Let's just set them on the decrypted message body.
    BOOL isSigned = NO;
    if([signatures count]) {
        [[decryptedMimeBody topLevelPart] setValue:signatures forKey:@"_messageSigners"];
        isSigned = YES;
    }
    // After that set the decryptedMessage body with encrypted to yes!
    [self setDecryptedMessageBody:decryptedMimeBody isEncrypted:YES isSigned:isSigned error:nil];
    // Last step, remove the shouldBeDecrypting, otherwise the message is
    // automatically decrypted every time it's selected.
    return [[decryptedMimeBody topLevelPart] decodeWithContext:ctx];
}

// TODO: Should calll the original method if open pgp checkox is not checked.
- (id)MANewEncryptedPartWithData:(id)data recipients:(id)recipients encryptedData:(id *)encryptedData {
    DebugLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    // Split the recipients in normal and bcc recipients.
    NSMutableArray *normalRecipients = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *bccRecipients = [[NSMutableArray alloc] initWithCapacity:1];
    for(NSString *recipient in recipients) {
        if(((NSRange)[recipient rangeOfString:@"gpg-mail-bcc::"]).location != NSNotFound)
            [bccRecipients addObject:[recipient stringByReplacingCharactersInRange:[recipient rangeOfString:@"gpg-mail-bcc::"] withString:@""]];
        else if(((NSRange)[recipient rangeOfString:@"gpg-mail-from::"]).location != NSNotFound)
            [bccRecipients addObject:[recipient stringByReplacingCharactersInRange:[recipient rangeOfString:@"gpg-mail-from::"] withString:@""]];
        else
            [normalRecipients addObject:recipient];
    }
    DebugLog(@"BCC Recipients: %@", bccRecipients);
    DebugLog(@"Recipients: %@", normalRecipients);
    // TODO: unfortunately we don't know the hidden recipients in here...
    //       gotta find a workaround.
    // Ask the mail bundle for the GPGKeys matching the email address.
    NSSet *normalKeyList = [[GPGMailBundle sharedInstance] publicKeyListForAddresses:normalRecipients];
    NSMutableSet *bccKeyList = [[GPGMailBundle sharedInstance] publicKeyListForAddresses:bccRecipients];
	[bccKeyList minusSet:normalKeyList];


    GPGController *gpgc = [[GPGController alloc] init];
    gpgc.verbose = (GPGMailLoggingLevel > 0);
    gpgc.useArmor = YES;
    gpgc.useTextMode = YES;
    // Automatically trust keys, even though they are not specifically
    // marked as such.
    // Eventually add warning for this.
    gpgc.trustAllKeys = YES;
    @try {
        *encryptedData = [gpgc processData:data withEncryptSignMode:GPGPublicKeyEncrypt recipients:normalKeyList hiddenRecipients:bccKeyList];
		if (gpgc.error) {
			@throw gpgc.error;
		}
    }
    @catch(NSException *e) {
        DebugLog(@"[DEBUG] %s encryption error: %@", __PRETTY_FUNCTION__, e);
        // TODO: Add encryption error handling. (Re-use the dialogs shown for S/MIME
        //       encryption errors?
        return nil;
    }
    @finally {
        [gpgc release];
    }
        
    // 1. Create a new mime part for the encrypted data.
    // -> Problem S/MIME only has one mime part GPG/MIME has two, one for
    // -> the version, one for the data.
    // -> Therefore it's necessary to manipulate the message mime parts in
    // -> _makeMessageWithContents:
    // -> Not great, but not a big problem either (let's hope)
    MimePart *dataPart = [[MimePart alloc] init];
    
    [dataPart setType:@"application"];
    [dataPart setSubtype:@"octet-stream"];
    [dataPart setBodyParameter:@"PGP.asc" forKey:@"name"];
    dataPart.contentTransferEncoding = @"7bit";
    [dataPart setDisposition:@"inline"];
    [dataPart setDispositionParameter:@"PGP.asc" forKey:@"filename"];
    [dataPart setContentDescription:@"Message encrypted with OpenPGP using GPGMail"];
    
    return dataPart;
}

// TODO: sha1 the right algorithm?
// TODO: Should calll the original method if open pgp checkox is not checked.
- (id)MANewSignedPartWithData:(id)arg1 sender:(id)arg2 signatureData:(id *)arg3 {
    DebugLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    DebugLog(@"[DEBUG] %s data: %@", __PRETTY_FUNCTION__, arg1);
    DebugLog(@"[DEBUG] %s sender: %@", __PRETTY_FUNCTION__, arg2);
    NSSet *normalKeyList = [[GPGMailBundle sharedInstance] signingKeyListForAddresses:[NSArray arrayWithObject:arg2]];
    GPGController *gpgc = [[GPGController alloc] init];
    gpgc.verbose = (GPGMailLoggingLevel > 0);
    gpgc.useArmor = YES;
    gpgc.useTextMode = YES;
    // Automatically trust keys, even though they are not specifically
    // marked as such.
    // Eventually add warning for this.
    gpgc.trustAllKeys = YES;
    // Recipients are not needed for signing. Use addSignerKey instead.
    for(NSString *fingerprint in normalKeyList)
        [gpgc addSignerKey:fingerprint];
    @try {
        *arg3 = [gpgc processData:arg1 withEncryptSignMode:GPGDetachedSign recipients:nil hiddenRecipients:nil];
		if (gpgc.error) {
			@throw gpgc.error;
		}
    }
    @catch(NSException *e) {
		if ([e isKindOfClass:[GPGException class]] && [(GPGException *)e errorCode] == GPGErrorCancelled) {
			//TODO: Handle GPGErrorCancelled. 
		}
        DebugLog(@"[DEBUG] %s sign error: %@", __PRETTY_FUNCTION__, e);
		@throw e;
    }
    @finally {
        [gpgc release];
    }
    DebugLog(@"[DEBUG] %s signature: %@", __PRETTY_FUNCTION__, [[[NSString alloc] initWithData:*arg3 encoding:NSUTF8StringEncoding] autorelease]);
    
    MimePart *topPart = [[MimePart alloc] init];
    [topPart setType:@"multipart"];
    [topPart setSubtype:@"signed"];
    // TODO: sha1 the right algorithm?
    [topPart setBodyParameter:@"pgp-sha1" forKey:@"micalg"];
    [topPart setBodyParameter:@"application/pgp-signature" forKey:@"protocol"];
    
    MimePart *signaturePart = [[MimePart alloc] init];
    [signaturePart setType:@"application"];
    [signaturePart setSubtype:@"pgp-signature"];
    [signaturePart setBodyParameter:@"PGP.sig" forKey:@"name"];
    signaturePart.contentTransferEncoding = @"7bit";
    [signaturePart setDisposition:@"inline"];
    [signaturePart setDispositionParameter:@"PGP.sig" forKey:@"filename"];
    // TODO: translate this string.
    [signaturePart setContentDescription:@"OpenPGP digital signature"];
    
    // Self is actually the whole current message part.
    // So the only thing to do is, add self to our top part
    // and add the signature part to the top part and voila!
    [topPart addSubpart:self];
    [topPart addSubpart:signaturePart];
    
    //return signaturePart;
    DebugLog(@"[DEBUG] %s part before: %@", __PRETTY_FUNCTION__, self);
    //id ret = [self GPGNewSignedPartWithData:arg1 sender:arg2 signatureData:&signedData];
    DebugLog(@"[DEBUG] %s gpg signed part: %@", __PRETTY_FUNCTION__, topPart);
    
    return topPart;
}

- (BOOL)MAUsesKnownSignatureProtocol {
    if([[self bodyParameterForKey:@"protocol"] isEqualToString:@"application/pgp-signature"])
        return YES;
    return [self MAUsesKnownSignatureProtocol];
}

- (void)MAVerifySignature {
    // If this is a non GPG signed message, let's call the original method
    // and get out of here!
    if(![[self bodyParameterForKey:@"protocol"] isEqualToString:@"application/pgp-signature"])
        return [self MAVerifySignature];
    MFError *error;
    BOOL needsVerification = [self needsSignatureVerification:&error];
    if(!needsVerification || error)
        return;
    // If the signature was not yet verified, check if we recognize the protocol.
    // This is not really necessary, but the original method does it like this,
    // and this should mimic it the best way possible.
    if(![self usesKnownSignatureProtocol])
        return;
    // Now on to fetching the signed data.
    NSData *signedData = [self signedData];
    // And last finding the signature.
    MimePart *signaturePart;
    for(MimePart *part in [self subparts]) {
        if([part isType:@"application" subtype:@"pgp-signature"]) {
            signaturePart = part;
            break;
        }
    }
    if(![signedData length] || !signaturePart)
        return;
    // And now the funny part, the actual verification.
    NSData *signatureData = [signaturePart bodyData];
    //DebugLog(@"[DEBUG] %s signature: %@", __PRETTY_FUNCTION__, [NSString stringWithData:signatureData encoding:[self guessedEncoding]]);
    GPGController *gpgc = [[GPGController alloc] init];
    gpgc.verbose = (GPGMailLoggingLevel > 0);
    NSArray *signatures;
    @try {
        signatures = [gpgc verifySignature:signatureData originalData:signedData];
        [signatures retain];
    }
    @catch (NSException* e) {
        DebugLog(@"[DEBUG] %s - verification errror: %@", __PRETTY_FUNCTION__, e);
        return;
    }
    @finally {
        [gpgc release];
    }
    // Signatures are stored in _messageSigners. that might not work, but
    // hopefully it does.
    [self setValue:[signatures retain] forKey:@"_messageSigners"];
    DebugLog(@"[DEBUG] %s Found signatures: %@", __PRETTY_FUNCTION__, signatures);
    DebugLog(@"[DEBUG] %s saved signatures: %@", __PRETTY_FUNCTION__, [self valueForKey:@"_messageSigners"]);
    //[self setIvar:signatures value:@"messageSigners"];
    [signatures release];
    
    return;
}

- (void)_verifyPGPInlineSignature {
    NSData *signedData = [self bodyData];
    DebugLog(@"[DEBUG] %s plain message signed data: %@", __PRETTY_FUNCTION__, [NSString stringWithData:signedData encoding:[[[self mimeBody] preferredBodyPart] guessedEncoding]]);
    if(![signedData length] || [self rangeOfPlainPGPSignatures].location == NSNotFound)
        return;
    GPGController *gpgc = [[GPGController alloc] init];
    gpgc.verbose = (GPGMailLoggingLevel > 0);
    NSArray *signatures;
    @try {
        signatures = [gpgc verifySignedData:signedData];
        [signatures retain];
    }
    @catch (NSException* e) {
        DebugLog(@"[DEBUG] %s - verification errror: %@", __PRETTY_FUNCTION__, e);
        return;
    }
    @finally {
        [gpgc release];
    }
    DebugLog(@"[DEBUG] %s mime part: %@", __PRETTY_FUNCTION__, self);
    // Store the signature and done!
    [self setValue:signatures forKey:@"_messageSigners"];
    DebugLog(@"[DEBUG] %s Found signatures: %@", __PRETTY_FUNCTION__, signatures);
    DebugLog(@"[DEBUG] %s saved signatures: %@", __PRETTY_FUNCTION__, [self valueForKey:@"_messageSigners"]);
    [signatures release];
}

- (id)MACopySignerLabels {
    DebugLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    DebugLog(@"[DEBUG] %s who am i: %@", __PRETTY_FUNCTION__, self);
    // Check if the signature in the message signers is a GPGSignature, if
    // so, copy the email addresses and return them.
    NSMutableArray *signerLabels = [NSMutableArray array];
    NSArray *messageSigners = [self copyMessageSigners];
    if(![[messageSigners objectAtIndex:0] isKindOfClass:[GPGSignature class]]) {
        [messageSigners release];
        return [self MACopySignerLabels];
    }
    for(GPGSignature *signature in messageSigners) {
        // For some reason a signature might not have an email set.
        // This happens if the public key is not available (not downloaded or imported
        // from the signature server yet). In that case, display the user id.
        NSString *email = [signature email];
        if(!email)
            email = [signature fingerprint];
        [signerLabels addObject:email];
    }
    [messageSigners release];
    
    return [signerLabels copy];
}

- (BOOL)MAIsSigned {
    DebugLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    DebugLog(@"[DEBUG] %s who am i: %@", __PRETTY_FUNCTION__, self);
    DebugLog(@"[DEBUG] %s type: %@ - %lld", __PRETTY_FUNCTION__, [self type], [self typeCode]);
    DebugLog(@"[DEBUG] %s subtype: %@ - %lld", __PRETTY_FUNCTION__, [self subtype], [self subtypeCode]);
    BOOL ret = [self MAIsSigned];
    // For plain text message is signed doesn't automatically find
    // the right signed status, so we check if copy signers are available.
    BOOL hasMessageSigners = ([self valueForKey:@"_messageSigners"] && [(NSArray *)[self valueForKey:@"_messageSigners"] count] > 0);
    return (ret | hasMessageSigners);
}

- (BOOL)isPGPSigned {
    NSArray *messageSigners = [self valueForKey:@"_messageSigners"];
    BOOL hasMessageSigners = ([messageSigners count] > 0 && [[messageSigners objectAtIndex:0] isKindOfClass:[GPGSignature class]]);
    return hasMessageSigners;
}

- (BOOL)isPGPInlineEncrypted {
    // Fetch body data to look for the leading GPG string.
    // For some reason textEncoding doesn't really work... and is actually never called
    // by Mail.app itself it seems.
    NSString *body = [NSString stringWithData:[[self mimeBody] bodyData] encoding:[[[self mimeBody] preferredBodyPart] guessedEncoding]];
    // If the encoding can't be guessed, the body will probably be empty,
    // so let's get out of here.!
    if(![body length])
        return NO;
    NSRange startRange = [body rangeOfString:(NSString *)PGP_MESSAGE_BEGIN];
    // For some reason (OS X Bug? Code bug?) comparing to NSNotFound doesn't
    // (always?) work.
    //if(startRange.location == NSNotFound)
    if(startRange.location == NSNotFound)
        return NO;
    NSRange endRange = [body rangeOfString:(NSString *)PGP_MESSAGE_END];
    if(endRange.location == NSNotFound)
        return NO;
    
    NSRange gpgRange = NSUnionRange(startRange, endRange);
    // Save the range for later use.
    [[[self mimeBody] topLevelPart] setIvar:@"gpgDataRange" value:[NSValue valueWithRange:gpgRange]];
    [self setIvar:@"isEncrypted" value:[NSNumber numberWithBool:YES]];
    return YES;
}

- (BOOL)isPGPMimeEncrypted {
    // Check for multipart/encrypted, protocol application/pgp-encrypted, otherwise exit!
    if(![[[self type] lowercaseString] isEqualToString:@"multipart"] || ![[[self subtype] lowercaseString] isEqualToString:@"encrypted"])
        return NO;

    if([self bodyParameterForKey:@"protocol"] != nil && ![[[self bodyParameterForKey:@"protocol"] lowercaseString] isEqualToString:@"application/pgp-encrypted"])
        return NO;
    
    // Alright, passed. So next, subparts must be exactly 2!
    if([(NSArray *)[self subparts] count] != 2)
        return NO;
    
    MimePart *versionPart = [self subpartAtIndex:0];
    MimePart *dataPart = [self subpartAtIndex:1];
    
    // Version Part is application/pgp- encrypted.
    // Data Part is application/octet-stream OR application/pgp-signature (for FireGPG < 0.7.1)
    if([[[versionPart type] lowercaseString] isEqualToString:@"application"] && [[[versionPart subtype] lowercaseString] isEqualToString:@"pgp-encrypted"] &&
       [[[dataPart type] lowercaseString] isEqualToString:@"application"] && ([[[dataPart subtype] lowercaseString] isEqualToString:@"octet-stream"] ||
                                                               [[[dataPart subtype] lowercaseString] isEqualToString:@"pgp-signature"])) {
           // For some strange reason version is NSUTF8 encoded, not ascii... hmm...
           NSString *version = [[NSString alloc] initWithData:[versionPart bodyData] encoding:NSUTF8StringEncoding];
           // All conditions matched.
           if([[version lowercaseString] rangeOfString:@"version: 1"].location != NSNotFound || 
              [[version lowercaseString] rangeOfString:@"version : 1"].location != NSNotFound) {
               [version release];
               // Save that this MimePart is encrypted for later. It's gonna trigger
               // a method which Mail uses to draw the message header which is used
               // for GPGMail's UI.
               [self setIvar:@"isEncrypted" value:[NSNumber numberWithBool:YES]];
               return YES;
           }
           else {
               [version release];
               return NO;
           }
    }
    
    return NO;
}

- (BOOL)MAIsEncrypted {
    // If this is not a topLevelPart, we simply return the original
    // MimePart.isEncrypted value.
    if([self parentPart] != nil)
        return [self MAIsEncrypted];
    
    [self isPGPMimeEncrypted];
    [self isPGPInlineEncrypted];
    
    // If either inline PGP or MIME PGP encrypted data is found
    // return true.
    if([self ivarExists:@"isEncrypted"])
        return YES;
    
    // Otherwise to also support S/MIME encrypted messages, call
    // the original method.
    return [self MAIsEncrypted];
}

- (NSRange)rangeOfPlainPGPSignatures {
    NSRange range = NSMakeRange(NSNotFound, 0);
    
    NSString *signedContent = [NSString stringWithData:[[self mimeBody] bodyData] encoding:[[[self mimeBody] preferredBodyPart] guessedEncoding]];
    if([signedContent length] == 0)
        return range;
    NSRange startRange = [signedContent rangeOfString:(NSString *)PGP_SIGNED_MESSAGE_BEGIN];
    if(startRange.location == NSNotFound)
        return range;
    NSRange endRange = [signedContent rangeOfString:(NSString *)PGP_MESSAGE_SIGNATURE_END];
    if(endRange.location == NSNotFound)
        return range;
    
    return NSUnionRange(startRange, endRange);
}

- (NSUInteger)guessedEncoding {
    NSString *charset = [[self bodyParameterForKey:@"charset"] lowercaseString];
    // utf8 is always the default encoding we wanna use.
    NSUInteger encoding = NSUTF8StringEncoding;
    if([charset isEqualToString:@"iso-8859-1"])
        encoding = NSISOLatin1StringEncoding;
    else if([charset isEqualToString:@"iso-8859-2"])
        encoding = NSISOLatin2StringEncoding;
    else if([self.contentTransferEncoding isEqualToString:@"7bit"])
        encoding = NSASCIIStringEncoding;
    
    return encoding;
    
}

@end
