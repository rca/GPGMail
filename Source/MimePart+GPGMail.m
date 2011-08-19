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
#import "NSArray+Functional.h"
#import "NSObject+LPDynamicIvars.h"
#import "GPGFlaggedHeaderValue.h"
#import "MimePart+GPGMail.h"
#import "NSString+GPGMail.h"
#import <MFMessageFramework.h>
#import <ActivityMonitor.h>
#import <NSString-NSStringUtils.h>
#import <NSData-MimeDataEncoding.h>
#import <MFMimeDecodeContext.h>
#import <MFError.h>
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
	NSString *selectorName = [NSString stringWithFormat:@"decode%@%@WithContext:", [type capitalizedString], [[subtype stringByReplacingOccurrencesOfString:@"-" withString:@"_"] capitalizedString]];
    // Mail.app doesn't know how to deal with multipart/encrypted mime parts, 
    // so it's GPGMail's responsibility to detect a multipart/encrypted
    // mime part and call the appropriate method.
    SEL selector = NSSelectorFromString(selectorName);
    
    NSNumber *shouldBeDecrypting = [[(MimeBody *)[self mimeBody] message] getIvar:@"shouldBeDecrypting"];
    if([shouldBeDecrypting boolValue] && [self respondsToSelector:selector]) {
        // It's necessary to set this var on the message, so the flags are changed.
        // Changing the flags is necessary for the error banner to show!
        id ret = [self performSelector:selector withObject:ctx];
        // Call the original implementation so that the mime parts
        // are displayed as attachments.
        if(!ret)
            return [self MADecodeWithContext:ctx];
        return ret;
    }
    
    // Not decrypting or not encrypted message -> invoking original method.
    return [self MADecodeWithContext:ctx];
}

- (id)decodeMultipartEncryptedWithContext:(id)ctx {
    // 1. Step, check if the message was already decrypted.
    char isEncrypted, isSigned;
    MFError *error;
    MimeBody *decryptedMessageBody = [self decryptedMessageBodyIsEncrypted:&isEncrypted isSigned:&isSigned error:&error];
    // If an error is found and no decryptedMessageBody is set, push the error
    // to the current activity monitor (this is necessary for the error banner to be shown)
    // and leave with nil.
    // If decryptedMessageBody is set, return its content using decodeWithContext:ctx.
    if(decryptedMessageBody || error) {
        if(error)
            [[ActivityMonitor currentMonitor] setError:error];
        return decryptedMessageBody ? [[decryptedMessageBody topLevelPart] decodeWithContext:ctx] : nil;
    }
    // 2. Fetch the data part. (Version part should be there, otherwise this message wouldn't
    //                          be in decryption mode.)
    MimePart *dataPart = [self subpartAtIndex:1];
    NSData *encryptedData = [dataPart bodyData];
    BOOL quotedPrintable = [[dataPart.contentTransferEncoding lowercaseString] isEqualToString:@"quoted-printable"];
    encryptedData = quotedPrintable ? [encryptedData decodeQuotedPrintableForText:YES] : encryptedData;
    
    decryptedMessageBody = [self decryptedMessageBodyForEncryptedData:encryptedData];
    id ret = [decryptedMessageBody parsedMessageWithContext:ctx];
    return ret;
}

- (id)MADecodeMultipartAlternativeWithContext:(id)ctx {
    // This is a special case. A multipart/alternative message.
    // For multipart/alternative messages, Mail.app uses favorited part
    // given in the settings.
    NSNumber *shouldBeDecrypting = [[(MimeBody *)[self mimeBody] message] getIvar:@"shouldBeDecrypting"];
    // If not in decrypt mode, OUT OF HERE!
    if(!shouldBeDecrypting)
        return [self MADecodeMultipartAlternativeWithContext:ctx];
    
    for(MimePart *part in [self subparts]) {
        if([part isType:@"text" subtype:@"plain"])
            return [part decodeTextPlainWithContext:ctx];
    }
    return [self MADecodeMultipartAlternativeWithContext:ctx];
}
- (id)MADecodeTextPlainWithContext:(id)ctx {
    // 1. Step, check if the message was already decrypted.
    char isEncrypted, isSigned;
    MFError *error;
    MimeBody *decryptedMessageBody = [self decryptedMessageBodyIsEncrypted:&isEncrypted isSigned:&isSigned error:&error];
    // If an error is found and no decryptedMessageBody is set, push the error
    // to the current activity monitor (this is necessary for the error banner to be shown)
    // and leave with nil.
    // If decryptedMessageBody is set, return its content using decodeWithContext:ctx.
    if(decryptedMessageBody || error) {
        if(error)
            [[ActivityMonitor currentMonitor] setError:error];
        return decryptedMessageBody ? [[decryptedMessageBody topLevelPart] decodeWithContext:ctx] : nil;
    }
    
    // Extract the PGP block from the plain text, if available.
    // Check if gpgDataRange is available, otherwise just exit decryption mode.
    // Check if there's a PGP signature in the plain text.
    BOOL isPGPEncrypted = NO;
    BOOL isPGPSigned = NO;
    NSRange pgpSignedRange = [self rangeOfPlainPGPSignatures];
    if([[[self mimeBody] topLevelPart] ivarExists:@"gpgDataRange"])
        isPGPEncrypted = YES;
    if(pgpSignedRange.location != NSNotFound)
        isPGPSigned = YES;
    
    if(isPGPEncrypted) {
        NSRange gpgDataRange = [[[[self mimeBody] topLevelPart] getIvar:@"gpgDataRange"] rangeValue];
        NSData *encryptedData = [[[self mimeBody] bodyData] subdataWithRange:gpgDataRange];
        // If the transfer encoding is set to quoted-printable, we have to run the data 
        // to decodeQuotedPrintableForText first.
        BOOL quotedPrintable = [[self.contentTransferEncoding lowercaseString] isEqualToString:@"quoted-printable"];
        NSData *realEncryptedData = quotedPrintable ? [encryptedData decodeQuotedPrintableForText:YES] : encryptedData;
        
        
        decryptedMessageBody = [self decryptedMessageBodyForEncryptedData:realEncryptedData];
        return [decryptedMessageBody parsedMessageWithContext:ctx]; 
    }
    else if(isPGPSigned) {
        [self _verifyPGPInlineSignature];
    }
    
    id ret = [self MADecodeTextPlainWithContext:ctx];
    if(isPGPSigned)
        ret = [self stripSignatureFromContent:ret];
    
    return ret;
}

// TODO: Find out if this "algorithm" always works, due to HTML input.
- (id)stripSignatureFromContent:(id)content {
    if([content isKindOfClass:[NSString class]]) {
        // Find -----BEGIN PGP SIGNED MESSAGE----- and
        // remove everything to the next empty line.
        NSRange beginRange = [content rangeOfString:(NSString *)PGP_SIGNED_MESSAGE_BEGIN];
        if(beginRange.location == NSNotFound)
            return content;
        NSString *remainingContent = [content stringByReplacingCharactersInRange:beginRange withString:@""];
        // Find the first occurence of two newlines (\n\n). This is HTML so it's <BR><BR> (can't be good!)
        // This delimits the signature part.
        NSRange signatureDelimiterRange = [content rangeOfString:@"<BR><BR>"];
        if(signatureDelimiterRange.location == NSNotFound)
            return content;
        NSRange pgpDelimiterRange = NSUnionRange(beginRange, signatureDelimiterRange);
        remainingContent = [content stringByReplacingCharactersInRange:pgpDelimiterRange withString:@""];
        
        NSRange startRange = [remainingContent rangeOfString:(NSString *)PGP_MESSAGE_SIGNATURE_BEGIN];
        if(startRange.location == NSNotFound)
            return content;
        NSRange endRange = [remainingContent rangeOfString:(NSString *)PGP_MESSAGE_SIGNATURE_END];
        if(endRange.location == NSNotFound)
            return content;
        NSRange gpgSignatureRange = NSUnionRange(startRange, endRange);
        NSString *strippedContent = [remainingContent stringByReplacingCharactersInRange:gpgSignatureRange withString:@""];
        
        return strippedContent;
    }
    return content;
}

// TODO: Implement better check to understand whether the decrypted data contains mail headers or not (pgp inline encrypted).
// TODO: If it doesn't contain mail headers add a method for better understanding if the decrypted data
//       contains HTML and don't change \n to <br> in that case.
- (id)decryptedMessageBodyForEncryptedData:(NSData *)encryptedData {
    __block NSData *decryptedData;
    __block NSArray *signatures = nil;
    __block NSException *decryptionException = nil;
    [[GPGMailBundle sharedInstance] addDecryptionTask:^{
        GPGController *gpgc = [[GPGController alloc] init];
        gpgc.verbose = (GPGMailLoggingLevel > 0);
        @try {
            decryptedData = [gpgc decryptData:encryptedData];
            if(gpgc.error) {
                @throw gpgc.error;
            }
            signatures = [gpgc signatures];
            [signatures retain];
        }
        @catch(NSException *e) {
            DebugLog(@"[DEBUG] %s exception: %@", __PRETTY_FUNCTION__, e);
            decryptionException = e;
            decryptedData = nil;
        }
        @finally {
            [gpgc release];
        }
    }];
    // TODO: Perform some error handling here. Store the error in self->_smimeError.
    if(decryptedData == nil && decryptionException) {
        [self failedToDecryptWithException:decryptionException];
        return nil;
    }
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
    return decryptedMimeBody;
}

- (void)failedToDecryptWithException:(NSException *)exception {
    NSBundle *gpgMailBundle = [NSBundle bundleForClass:[GPGMailBundle class]];
    NSString *title = NSLocalizedStringFromTableInBundle(@"MESSAGE_BANNER_PGP_DECRYPT_ERROR_TITLE", @"GPGMail", gpgMailBundle, @"");
    NSString *message = NSLocalizedStringFromTableInBundle(@"MESSAGE_BANNER_PGP_DECRYPT_ERROR_MESSAGE", @"GPGMail", gpgMailBundle, @"");
    MFError *error = [MFError errorWithDomain:@"MFMessageErrorDomain" code:1035 localizedDescription:nil title:title helpTag:nil 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:title, @"_MFShortDescription", message, @"NSLocalizedDescription", nil]];
    [self setDecryptedMessageBody:nil isEncrypted:NO isSigned:NO error:error];
    [[ActivityMonitor currentMonitor] setError:error];
    // Tell the message to fake the message flags, means adding the signed
    // and encrypted flag, otherwise the error banner is not shown.
    [[(MimeBody *)[self mimeBody] message] setIvar:@"fakeMessageFlags" value:[NSNumber numberWithBool:YES]];
}

- (id)MANewEncryptedPartWithData:(id)data recipients:(id)recipients encryptedData:(id *)encryptedData {
    DebugLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    // First thing todo, check if an address with the gpg-mail prefix is found.
    // If not, S/MIME is wanted.
    NSArray *prefixedAddresses = [recipients filter:^(id recipient){
        return [(NSString *)recipient isFlaggedValue] ? recipient : nil;
    }];
    if(![prefixedAddresses count])
        return [self MANewEncryptedPartWithData:data recipients:recipients encryptedData:encryptedData];
    
    // Split the recipients in normal and bcc recipients.
    NSMutableArray *normalRecipients = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *bccRecipients = [[NSMutableArray alloc] initWithCapacity:1];
    for(NSString *recipient in recipients) {
        if([recipient isFlaggedValueWithKey:@"bcc"])
            [bccRecipients addObject:recipient];
        else if([recipient isFlaggedValueWithKey:@"from"])
            [bccRecipients addObject:recipient];
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
    [dataPart setBodyParameter:@"encrypted.asc" forKey:@"name"];
    dataPart.contentTransferEncoding = @"7bit";
    [dataPart setDisposition:@"inline"];
    [dataPart setDispositionParameter:@"encrypted.asc" forKey:@"filename"];
    [dataPart setContentDescription:@"Message encrypted with OpenPGP using GPGMail"];
    
    return dataPart;
}

// TODO: sha1 the right algorithm?
// TODO: Implement visual exception if no valid signing keys are found.
// TODO: Translate the error message if creating the signature fails.
//       At the moment the standard S/MIME message is used.
// TODO: Translate "OpenPGP digital signature".
- (id)MANewSignedPartWithData:(id)data sender:(id)sender signatureData:(id *)signatureData {
    DebugLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    DebugLog(@"[DEBUG] %s data: %@", __PRETTY_FUNCTION__, data);
    DebugLog(@"[DEBUG] %s sender: [%@] %@", __PRETTY_FUNCTION__, [sender class], sender);
    // If sender doesn't show any injected header values, S/MIME is wanted,
    // hence the original method called.
    if(![sender isFlaggedValueWithKey:@"from"]) {
        return [self MANewSignedPartWithData:data sender:sender signatureData:signatureData];
    }
    
    NSSet *normalKeyList = [[GPGMailBundle sharedInstance] signingKeyListForAddresses:[NSArray arrayWithObject:sender]];
    // Should not happen, but if no valid signing keys are found
    // raise an error. Returning nil tells Mail that an error occured.
    if(![normalKeyList count]) {
        [self failedToSignForSender:sender];
        return nil;
    }
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
        *signatureData = [gpgc processData:data withEncryptSignMode:GPGDetachedSign recipients:nil hiddenRecipients:nil];
		if (gpgc.error) {
			@throw gpgc.error;
		}
    }
    @catch(NSException *e) {
		if ([e isKindOfClass:[GPGException class]] && [(GPGException *)e errorCode] == GPGErrorCancelled) {
			[self failedToSignForSender:sender];
            return nil;
		}
        DebugLog(@"[DEBUG] %s sign error: %@", __PRETTY_FUNCTION__, e);
		@throw e;
    }
    @finally {
        [gpgc release];
    }
    
    MimePart *topPart = [[MimePart alloc] init];
    [topPart setType:@"multipart"];
    [topPart setSubtype:@"signed"];
    // TODO: sha1 the right algorithm?
    [topPart setBodyParameter:@"pgp-sha1" forKey:@"micalg"];
    [topPart setBodyParameter:@"application/pgp-signature" forKey:@"protocol"];
    
    MimePart *signaturePart = [[MimePart alloc] init];
    [signaturePart setType:@"application"];
    [signaturePart setSubtype:@"pgp-signature"];
    [signaturePart setBodyParameter:@"signature.asc" forKey:@"name"];
    signaturePart.contentTransferEncoding = @"7bit";
    [signaturePart setDisposition:@"inline"];
    [signaturePart setDispositionParameter:@"signature.asc" forKey:@"filename"];
    // TODO: translate this string.
    [signaturePart setContentDescription:@"Message signed with OpenPGP using GPGMail"];
    
    // Self is actually the whole current message part.
    // So the only thing to do is, add self to our top part
    // and add the signature part to the top part and voila!
    [topPart addSubpart:self];
    [topPart addSubpart:signaturePart];
    
    return topPart;
}

- (void)failedToSignForSender:(NSString *)sender {
    NSBundle *messagesFramework = [NSBundle bundleForClass:[MimePart class]];
    NSString *localizedDescription = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"SMIME_CANT_SIGN_MESSAGE", @"Delayed", messagesFramework, @""),
                                      [sender gpgNormalizedEmail]];
    NSString *titleDescription = NSLocalizedStringFromTableInBundle(@"SMIME_CANT_SIGN_TITLE", @"Delayed", messagesFramework, @"");
    MFError *error = [MFError errorWithDomain:@"MFMessageErrorDomain" code:1036 localizedDescription:nil title:titleDescription
                                      helpTag:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:localizedDescription,
                                                            @"NSLocalizedDescription", titleDescription, @"_MFShortDescription", nil]];
    // Puh, this was all but easy, to find out where the error is used.
    // Overreleasing allows to track it's path as an NSZombie in Instruments!
    [[ActivityMonitor currentMonitor] setError:error];
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
    MimePart *signaturePart = nil;
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
	if (![signatureData length]) {
		return;
	}
	
    //DebugLog(@"[DEBUG] %s signature: %@", __PRETTY_FUNCTION__, [NSString stringWithData:signatureData encoding:[self guessedEncoding]]);
    GPGController *gpgc = [[GPGController alloc] init];
    gpgc.verbose = (GPGMailLoggingLevel > 0);
    NSArray *signatures;
    @try {
        signatures = [gpgc verifySignature:signatureData originalData:signedData];
        [signatures retain];
        if(gpgc.error)
            @throw gpgc.error;
    }
    @catch (NSException* e) {
        [self failedToVerifyWithException:e];
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

- (void)failedToVerifyWithException:(NSException *)exception {
    NSBundle *gpgMailBundle = [NSBundle bundleForClass:[GPGMailBundle class]];
    NSString *title = NSLocalizedStringFromTableInBundle(@"MESSAGE_BANNER_PGP_VERIFY_ERROR_TITLE", @"GPGMail", gpgMailBundle, @"");
    NSString *message = NSLocalizedStringFromTableInBundle(@"MESSAGE_BANNER_PGP_VERIFY_ERROR_MESSAGE", @"GPGMail", gpgMailBundle, @"");
    MFError *error = [MFError errorWithDomain:@"MFMessageErrorDomain" code:1036 localizedDescription:nil title:title helpTag:nil 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:title, @"_MFShortDescription", message, @"NSLocalizedDescription", nil]];
    [[ActivityMonitor currentMonitor] setError:error];
    // Tell the message to fake the message flags, means adding the signed
    // and encrypted flag, otherwise the error banner is not shown.
    [[(MimeBody *)[self mimeBody] message] setIvar:@"fakeMessageFlags" value:[NSNumber numberWithBool:YES]];
}
         
- (id)MACopySignerLabels {
    DebugLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    DebugLog(@"[DEBUG] %s who am i: %@", __PRETTY_FUNCTION__, self);
    // Check if the signature in the message signers is a GPGSignature, if
    // so, copy the email addresses and return them.
    NSMutableArray *signerLabels = [NSMutableArray array];
    NSArray *messageSigners = [self copyMessageSigners];
    // In case there are no message signers, simply return the original method.
    // Might be a problem, but shouldn't.
    if(![messageSigners count])
        return [self MACopySignerLabels];
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
    
    BOOL isPGPMimeEncrypted = [self isPGPMimeEncrypted];
    if(isPGPMimeEncrypted)
        return YES;
    BOOL isPGPInlineEncrypted = [self isPGPInlineEncrypted];
    if(isPGPInlineEncrypted)
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
