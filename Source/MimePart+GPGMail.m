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
#import "NSData+GPGMail.h"
#import "NSArray+Functional.h"
#import "NSObject+LPDynamicIvars.h"
#import "GPGFlaggedHeaderValue.h"
#import "MimePart+GPGMail.h"
#import "MimeBody+GPGMail.h"
#import "NSString+GPGMail.h"
#import "Message+GPGMail.h"
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

@implementation MimePart (GPGMail)

/**
 A second attempt to finding messages including PGP data.
 OpenPGP/MIME encrypted/signed messages follow RFC 3156, so those
 messages are no problem to decrypt.
 
 Inline PGP encrypted/signed messages are a whole other story, since
 there's no standard which describes exactly how to produce them.
 
 THE THEORY
   * Each message which contains encrypted/signed data is either:
     * One part: text/plain
       * Find data, encrypt it and create a new message with the old message headers
       * Setting the message as the decrypted message.
     * Multi part: multipart/alternative, multipart/mixed
       * Most likely contains a text/html and a text/plain part.
       * Both parts might contain PGP relevant data, but text/html data is
         very hard to process right (it most likely fails.)
       * In that case: ignore the text/html part and simply process the plain part.
         (Users might have a problem with that, but most likely not, since messages including HTML
          should always use OpenPGP/MIME)
 OLD METHOD
   * The old method used several entry points for the different mime types
   * and tried to find pgp data in there.
   * This method often failed, due to compley mime types which needed
   * manual searching and guessing of parts to follow.
   * Useless to say, it wasn't failsafe.
 
 NEW METHOD
   * The new method performs the following step:
     1.) Check if the message contains the OpenPGP/MIME parts
         * found -> decrpyt the message, return the decrypted message.
         Heck this was easy!
     2.) Check if the message contains any PGP inline data.
         * not found -> call Mail.app's original method and let Mail.app to the heavy leaving.
         * found -> follow step 3
     3.) Loop through every mime part of the message (recursively) and
         find text/plain parts.
     4.) Check each text/plain part if it contains PGP inline data.
         If it does, store its address (or better the mime part object?) in a
         dynamic ivar on the message.
     5.) Check for each subsequent call of decodeWithContext if the current mime part
         matches a found encrypted part.
         * found -> decrypt the part, flag the message as decrypted, build a new decrypted message with the original headers 
                    and return that to Mail.app.
     
     Since Mail.app calls decodeWithContext recursively, at the end of the cycle
     it comes back to the topLevelPart.
     
     6.) When Mail.app returns to the topLevelPart and no decrypted part was found,
         even though GPGMail knows there was a part which contains PGP data, this means two things:
         1.) Something went wrong (sorry for that ...)
         2.) The message was a multipart message and contains a HTML part, which was chosen
             as the preferred part, due to a setting in Mail.app.
             In that case, decodeWithContext: is never called on the text/plain mime part.
         
         If the second thing holds true, GPGMail fetches the mime part which is supposed
         to include the PGP data, processes it and returns the result to Mail.app.
 
    * The advantage of the new method is that it completely ignores complex mime types,
      making the whole decoding process more reliable.
 
 */
// TODO: Extend to find multiple signatures and encrypted data parts, if necessary.
- (id)MADecodeWithContext:(id)ctx {
    DebugLog(@"[DEBUG] %s enter - decoding: %@", __PRETTY_FUNCTION__,
             [(Message *)[(MimeBody *)[self mimeBody] message] subject]);
    // Check if PGP is enabled in Mail.app settings for decoding messages,
    // otherwise leave.
    if(![[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToReceive"] ||
       [[GPGMailBundle sharedInstance] componentsMissing])
        return [self MADecodeWithContext:ctx];
    
    if([[[(MimeBody *)[self mimeBody] message] getIvar:@"skipPGPProcessing"] boolValue]) {
        return [self MADecodeWithContext:ctx];
    }
    
    // Multipart mixed might contain PGP/MIME signed parts.
    // Don't ask me who generates this, but some client does...
    // Apparently this happens when a mail goes through the mailinglist daemon.
    // FRECK!
    if([self isType:@"multipart" subtype:@"mixed"]) {
        return [self MADecodeWithContext:ctx];
    }
    
    // 1.) Check if this is the top level mime part.
    //     If so, check the whole body if PGP data is included.
    MimePart *topLevelPart = [[self mimeBody] topLevelPart];
    MimePart *PGPSignedPart = nil;
    MimePart *PGPEncryptedPart = nil;
    
    if([topLevelPart isEqual:self]) {
        BOOL isPGPMimeEncrypted = [topLevelPart isPGPMimeEncrypted];
        // Try to decrypt the message using PGP/Mime methods and
        // return the result.
        // If an error occured the original Mail.app method is called.
        if(isPGPMimeEncrypted) {
            id ret = [self decodeMultipartEncryptedWithContext:ctx];
            if(!ret)
                return [self MADecodeWithContext:ctx];
            return ret;
        }
        // Check if the message is PGP/Mime signed. If so the original
        // Mail.app method is invoked, since PGP/MIME signatures behave basically
        // exactly like S/MIME signatures.
        BOOL isPGPMimeSigned = [topLevelPart isPGPMimeSigned];
        if(isPGPMimeSigned)
            return [self decodeMultipartSignedWithContext:ctx];
        
        // PGP/MIME is covered. Now onto PGP inline data.
        // First, look through the whole body data, to find pgp signatures
        // and pgp encrypted data.
        // If no PGP data is found let Mail.app take over and finish.
        // Otherwise the heavy part starts.
        // The data might be base64Decoded. If so, decode first, then check.
        NSData *decodedData = nil;
        if([self.contentTransferEncoding isEqualToString:@"base64"]) 
            decodedData = [[[self mimeBody] bodyData] decodeBase64];
        else
            decodedData = [[self mimeBody] bodyData];
        if([decodedData rangeOfPGPSignatures].location == NSNotFound && [decodedData rangeOfPGPInlineEncryptedData].location == NSNotFound)
            return [self MADecodeWithContext:ctx];
        
        // So, encrypted data or signature data was found. Now on to the hard part.
        [self findPGPInlineSignedAndEncryptedMimeParts];
        PGPEncryptedPart = [self getIvar:@"PGPEncryptedPart"];
        PGPSignedPart = [self getIvar:@"PGPSignedPart"];
        MimePart *earlyAlphaFuckedUpPart = [self getIvar:@"PGPFuckedUpEarlyAlpha"];
        
        if(PGPEncryptedPart)
            return [PGPEncryptedPart decodeInlinePGPDataWithContext:ctx];
        if(PGPSignedPart)
            return [PGPSignedPart decodeInlinePGPDataWithContext:ctx];
        if(earlyAlphaFuckedUpPart)
            return [earlyAlphaFuckedUpPart decodeMultipartEncryptedWithContext:ctx];
        
        // Hopefully encrypted parts and signed parts were successfully found,
        // now Mail.app takes over and parses every mime part.
    }
    id ret = [self MADecodeWithContext:ctx];
    return ret;
}

- (void)MAClearCachedDecryptedMessageBody {
    if(![[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToReceive"])
        return [self MAClearCachedDecryptedMessageBody];
    
    // Don't clear PGP messages for now. Just for testing!
    //    if([[self mimeBody] containsPGPEncryptedData])
    //        return;
    Message *message = [(MimeBody *)[self mimeBody] message];
    [message removeIvars];
    [self MAClearCachedDecryptedMessageBody];
}

- (void)findPGPInlineSignedAndEncryptedMimeParts {
    __block void (^_findPGPInlineSignedAndEncryptedMimeParts)(MimePart *);
    __block MimePart *signedMimePart = nil;
    __block MimePart *encryptedMimePart = nil;
    __block MimePart *fuckedUpEarlyAlphaPart = nil;
    _findPGPInlineSignedAndEncryptedMimeParts = ^(MimePart *currentPart) {
        if([currentPart isType:@"text" subtype:@"plain"]) {
            // Check the current part for signature or encrypted data.
            NSRange encryptedDataRange = [[currentPart bodyData] rangeOfPGPInlineEncryptedData];
            NSRange signatureDataRange = [[currentPart bodyData] rangeOfPGPInlineSignatures];
            // GPGMail assumes that the message data is always first signed,
            // then encrypted.
            if(encryptedDataRange.location != NSNotFound) {
                [self setIvar:@"PGPEncryptedPart" value:currentPart];
                encryptedMimePart = currentPart;
                NSValue *encryptedDataRangeValue = [NSValue valueWithBytes:&encryptedDataRange objCType:@encode(NSRange)];
                [currentPart setIvar:@"PGPEncryptedDataRange" value:encryptedDataRangeValue];
            }
            if(signatureDataRange.location != NSNotFound) {
                [self setIvar:@"PGPSignedPart" value:currentPart];
                signedMimePart = currentPart;
                NSValue *signatureDataRangeValue = [NSValue valueWithBytes:&signatureDataRange objCType:@encode(NSRange)];
                [currentPart setIvar:@"PGPSignedDataRange" value:signatureDataRangeValue];
            }
        }
        else if([currentPart isType:@"multipart" subtype:@"encrypted"] && ![[[self mimeBody] topLevelPart] isEqual:currentPart]) {
            // It's one of the fucked up, early alpha messages.
            fuckedUpEarlyAlphaPart = currentPart;
            [self setIvar:@"PGPFuckedUpEarlyAlpha" value:fuckedUpEarlyAlphaPart];
        }
        // No match, search the subparts.
        if(!signedMimePart || !encryptedMimePart) {
            for(MimePart *tmpPart in [currentPart subparts]) {
                _findPGPInlineSignedAndEncryptedMimeParts(tmpPart);
            }
                
        }
    };
    _findPGPInlineSignedAndEncryptedMimeParts(self);
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
        return decryptedMessageBody ? [decryptedMessageBody parsedMessageWithContext:ctx] : nil;
    }
    // 2. Fetch the data part. (Version part should be there, otherwise this message wouldn't
    //                          be in decryption mode.)
    MimePart *dataPart = [self subpartAtIndex:1];
    NSData *encryptedData = [dataPart bodyData];
    // Check if the data part contains the Content-Type string.
    // If so, this is a message which was created by a very early alpha
    // of GPGMail 2.0 which sent out completely corrupted messages.
    if([encryptedData rangeOfData:[@"Content-Type" dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0, [encryptedData length])].location != NSNotFound)
        return [self decodeFuckedUpEarlyAlphaData:encryptedData context:ctx];

    BOOL quotedPrintable = [[dataPart.contentTransferEncoding lowercaseString] isEqualToString:@"quoted-printable"];
    encryptedData = quotedPrintable ? [encryptedData decodeQuotedPrintableForText:YES] : encryptedData;
    
    decryptedMessageBody = [self decryptedMessageBodyForEncryptedData:encryptedData inlineEncrypted:NO];
    
    [[self mimeBody] setIvar:@"skipPGPProcessing" value:[NSNumber numberWithBool:YES]];
    ((MFMimeDecodeContext *)ctx).shouldSkipUpdatingMessageFlags = YES;
    return [decryptedMessageBody parsedMessageWithContext:ctx];
}

- (id)decodeFuckedUpEarlyAlphaData:(NSData *)data context:(MFMimeDecodeContext *)ctx {
    DebugLog(@"[DEBUG] Fucked up data: %@", [NSString stringWithData:data encoding:NSUTF8StringEncoding]);
    // This data might contain a signature part.
    // In that case it's a little bit more complicated since it's necessary to add a
    // top level mime part.
    if([data rangeOfData:[@"application/pgp-signature" dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0, [data length])].location != NSNotFound) {
        NSMutableData *newData = [NSMutableData data];
        NSString *boundary = (NSString *)[MimeBody newMimeBoundary];
        [newData appendData:[boundary dataUsingEncoding:NSUTF8StringEncoding]];
        [boundary release];
        [newData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        NSRange boundaryStart = [data rangeOfData:[@"--Apple-Mail=_" dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0, [data length])];
        NSRange boundaryEnd = [data rangeOfData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(boundaryStart.location, [data length] - boundaryStart.location)];
        DebugLog(@"[DEBUG] %s Boundary end: %@", __PRETTY_FUNCTION__, NSStringFromRange(boundaryEnd));
        NSString *partBoundary = [NSString stringWithData:[data subdataWithRange:NSMakeRange(boundaryStart.location+2, boundaryEnd.location-3)] encoding:NSUTF8StringEncoding];
        DebugLog(@"[DEBUG] %s original boundary: %@ -- END", __PRETTY_FUNCTION__, partBoundary);
        DebugLog(@"[DEBUG] %s Content-Type: %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:@"Content-Type: multipart/signed; boundary=\"%@\"; protocol=\"application/pgp-signature\";\r\n", partBoundary]);
        [newData appendData:[[NSString stringWithFormat:@"Content-Type: multipart/signed; boundary=\"%@\"; protocol=\"application/pgp-signature\";\r\n", partBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [newData appendData:[@"Content-Transfer-Encoding: 7bit\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [newData appendData:data];
        [newData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", partBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        DebugLog(@"[DEBUG] %s boundary: %@", __PRETTY_FUNCTION__, partBoundary);
        data = newData;
    }
    
    Message *newMessage = [Message messageWithRFC822Data:data];
    ctx.shouldSkipUpdatingMessageFlags = YES;
    // Skip PGP Processing, otherwise this ends up in an endless loop.
    [newMessage setIvar:@"skipPGPProcessing" value:[NSNumber numberWithBool:YES]];
    // Process the message like a really encrypted message.
    // Otherwise the decoding is creates a loop which is really slow!
    [newMessage setMessageInfoFromMessage:[(MimeBody *)[self mimeBody] message]];
    // 3. Call message body updating flags to set the correct flags for the new message.
    // This will setup the decrypted message, run through all parts and find signature part.
    // We'll save the message body for later, since it will be used to do a last
    // decodeWithContext and the output returned.
    // Fake the message flags on the decrypted message.
    MimeBody *decryptedMimeBody = [newMessage messageBodyUpdatingFlags:YES];
    // Check if the decrypted message contains any signatures, if so it's necessary
    // to unset the attachment flag.
    BOOL isSigned = [decryptedMimeBody containsPGPSignedData];
    // Fixes the problem where an attachment icon is shown, when a message is either encrypted or signed.
    unsigned int numberOfAttachments = [(MimePart *)[[self mimeBody] topLevelPart] numberOfAttachments];
    if(numberOfAttachments > 0)
        numberOfAttachments -= 2;
    // Set the new number of attachments.
    [[(MimeBody *)[self mimeBody] message] setNumberOfAttachments:numberOfAttachments isSigned:isSigned isEncrypted:YES];
    // After that set the decryptedMessage body with encrypted to yes!
    MFError *error = [[decryptedMimeBody topLevelPart] valueForKey:@"_smimeError"];
    if(error)
        [[ActivityMonitor currentMonitor] setError:error];
    [decryptedMimeBody setIvar:@"PGPEarlyAlphaFuckedUpEncrypted" value:[NSNumber numberWithBool:YES]];
    [[[self mimeBody] topLevelPart] setDecryptedMessageBody:decryptedMimeBody isEncrypted:YES isSigned:isSigned error:error];
    // Flag the message as process.
    [[(MimeBody *)[self mimeBody] message] setIvar:@"PGPMessageProcessed" value:[NSNumber numberWithBool:YES]];
    [[[self mimeBody] topLevelPart] removeIvar:@"PGPEncryptedPart"];
    [self removeIvar:@"PGPEncryptedDataRange"];
    // I could really smash myself for ever introducing this bug!!!
    // For the security header to correctly show the signatures,
    // the message has to be flagged as specially encrypted.
    [[self mimeBody] setIvar:@"PGPEarlyAlphaFuckedUpEncrypted" value:[NSNumber numberWithBool:YES]];
    // For some reason, these messages are super complicated, so we store the messageBody ourselves.
    [[(MimeBody *)[self mimeBody] message] setIvar:@"PGPEarlyAlphaFuckedUpEncryptedMessageBody" value:decryptedMimeBody];

    return [decryptedMimeBody parsedMessageWithContext:ctx];
}

- (id)decodeInlinePGPDataWithContext:(id)ctx {
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
        return decryptedMessageBody ? [decryptedMessageBody parsedMessageWithContext:ctx] : nil;
    }
    
    // Extract the PGP block from the plain text, if available.
    // Check if gpgDataRange is available, otherwise just exit decryption mode.
    // Check if there's a PGP signature in the plain text.
    BOOL isPGPEncrypted = NO;
    BOOL isPGPSigned = NO;
    
    NSRange pgpSignedRange = {NSNotFound, 0};
    NSRange pgpEncryptedRange = {NSNotFound, 0};
    if([self ivarExists:@"PGPEncryptedDataRange"])
        [[self getIvar:@"PGPEncryptedDataRange"] getValue:&pgpEncryptedRange];
    if([self ivarExists:@"PGPSignedDataRange"])
        [[self getIvar:@"PGPSignedDataRange"] getValue:&pgpSignedRange];
    
    if(pgpEncryptedRange.location != NSNotFound)
        isPGPEncrypted = YES;
    if(pgpSignedRange.location != NSNotFound)
        isPGPSigned = YES;
    
    if(isPGPEncrypted) {
        NSData *encryptedData = [[self bodyData] subdataWithRange:pgpEncryptedRange];
        // If the transfer encoding is set to quoted-printable, we have to run the data 
        // to decodeQuotedPrintableForText first.
        BOOL quotedPrintable = [[self.contentTransferEncoding lowercaseString] isEqualToString:@"quoted-printable"];
        NSData *realEncryptedData = quotedPrintable ? [encryptedData decodeQuotedPrintableForText:YES] : encryptedData;
        
        
        // Inline encrypted might return a string or a message body.
        decryptedMessageBody = [self decryptedMessageBodyForEncryptedData:realEncryptedData inlineEncrypted:YES];
        if([decryptedMessageBody isKindOfClass:[NSString class]])
            return decryptedMessageBody;
        [ctx setIvar:@"skipPGPProcessing" value:[NSNumber numberWithBool:YES]];
        return [decryptedMessageBody parsedMessageWithContext:ctx];
    }
    else if(isPGPSigned) {
        [self _verifyPGPInlineSignature];
        // It might actually alright, to simply return the plain mime body, without
        // running it through -[MimePart decodeTextPlainWithContext].
    }
    [ctx setIvar:@"skipPGPProcessing" value:[NSNumber numberWithBool:YES]];
    id ret = [self decodeTextPlainWithContext:ctx];
    if(isPGPSigned)
        ret = [self stripSignatureFromContent:ret];
    
    return ret;
}

// TODO: Find out if this "algorithm" always works, due to HTML input.
- (id)stripSignatureFromContent:(id)content {
    if([content isKindOfClass:[NSString class]]) {
        // Find -----BEGIN PGP SIGNED MESSAGE----- and
        // remove everything to the next empty line.
        NSRange beginRange = [content rangeOfString:PGP_SIGNED_MESSAGE_BEGIN];
        if(beginRange.location == NSNotFound)
            return content;
        
        NSString *remainingContent = [content stringByReplacingCharactersInRange:beginRange withString:@""];
        // Find the first occurence of two newlines (\n\n). This is HTML so it's <BR><BR> (can't be good!)
        // This delimits the signature part.
        NSRange signatureDelimiterRange = [remainingContent rangeOfString:@"<BR><BR>"];
        if(signatureDelimiterRange.location == NSNotFound)
            return content;
        NSRange pgpDelimiterRange = NSUnionRange(beginRange, signatureDelimiterRange);
        remainingContent = [content stringByReplacingCharactersInRange:pgpDelimiterRange withString:@""];
        
        // Now, there might be signatures in the quoted text, but the only interesting signature, will be at the end of the mail, that's
        // why the search is time done from the end.
        NSRange startRange = [remainingContent rangeOfString:PGP_MESSAGE_SIGNATURE_BEGIN options:NSBackwardsSearch];
        if(startRange.location == NSNotFound)
            return content;
        NSRange endRange = [remainingContent rangeOfString:PGP_MESSAGE_SIGNATURE_END options:NSBackwardsSearch];
        if(endRange.location == NSNotFound)
            return content;
        NSRange gpgSignatureRange = NSUnionRange(startRange, endRange);
        NSString *strippedContent = [remainingContent stringByReplacingCharactersInRange:gpgSignatureRange withString:@""];
        
        return strippedContent;
    }
    return content;
}


- (id)decryptedMessageBodyForEncryptedData:(NSData *)encryptedData inlineEncrypted:(BOOL)inlineEncrypted {
    __block NSData *decryptedData = nil;
    __block NSArray *foundSignatures = nil;
    __block NSException *decryptionException = nil;
    __block id decryptedMimeBody = nil;
    
    [[GPGMailBundle sharedInstance] addDecryptionTask:^{
        MFError *foundError;
        MimeBody *decryptedMessageBody = [self decryptedMessageBodyIsEncrypted:NULL isSigned:NULL error:&foundError];
        // If an error is found and no decryptedMessageBody is set, push the error
        // to the current activity monitor (this is necessary for the error banner to be shown)
        // and leave with nil.
        // If decryptedMessageBody is set, return its content using decodeWithContext:ctx.
        if(decryptedMessageBody || foundError) {
            if(foundError)
                [[ActivityMonitor currentMonitor] setError:foundError];
            decryptedMimeBody = decryptedMessageBody ? decryptedMessageBody : nil;
            return;
        }
        
        // Otherwise decrypt it.
        GPGController *gpgc = [[GPGController alloc] init];
        gpgc.verbose = (GPGMailLoggingLevel > 0);
        @try {
            decryptedData = [gpgc decryptData:encryptedData];
            foundSignatures = [gpgc signatures];
            [foundSignatures retain];
            
            NSMutableData *messageData = [[NSMutableData alloc] init];
            
            if(inlineEncrypted) {
                NSRange encryptedDataRange = {NSNotFound, 0};
                if([self ivarExists:@"PGPEncryptedDataRange"])
                    [[self getIvar:@"PGPEncryptedDataRange"] getValue:&encryptedDataRange];
                NSData *originalData = [self bodyData];
                // For some reasone sometimes the encrypted data range doesn't exist anymore at this point.
                // (Threading issue?). In that case, simply return the original body, otherwise GPGMail
                // crashes and Mail.app with it.
                if(encryptedDataRange.location != NSNotFound) {
                    [messageData appendData:[originalData subdataWithRange:NSMakeRange(0, encryptedDataRange.location)]];
                    if(decryptedData && [decryptedData length] != 0) 
                        [messageData appendData:decryptedData];
                    else
                        [messageData appendData:encryptedData];
                    [messageData appendData:[originalData subdataWithRange:NSMakeRange(encryptedDataRange.location+encryptedDataRange.length, [originalData length]-encryptedDataRange.length-encryptedDataRange.location)]];
                }
                else {
                    [messageData appendData:originalData];
                }
                if(gpgc.error) {
                    [self failedToDecryptWithException:gpgc.error];
                    // Return the original content. 
                    NSString *messageString = [messageData stringByGuessingEncoding];
                    messageString = [messageString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
                    decryptedMimeBody = messageString;
                    return;
                }
            }
            // Not inline encrypted, let Mail.app display the attachment.
            if(gpgc.error || !decryptedData || (decryptedData && ![decryptedData length])) {
                [self failedToDecryptWithException:gpgc.error];
                // Return the original 
                decryptedMimeBody = nil;
                return;
            }
            // 1. Create a new Message using messageWithRFC822Data:
            // This creates the message store automatically!
            Message *decryptedMessage;
            if(inlineEncrypted)
                decryptedMessage = [self messageWithMessageData:messageData];
            else
                decryptedMessage = [Message messageWithRFC822Data:decryptedData];
            
            // This is a test, to have the message seem signed... we'll see..
            // 2. Set message info from the original encrypted message.
            [decryptedMessage setMessageInfoFromMessage:[(MimeBody *)[self mimeBody] message]];
            
            // 3. Call message body updating flags to set the correct flags for the new message.
            // This will setup the decrypted message, run through all parts and find signature part.
            // We'll save the message body for later, since it will be used to do a last
            // decodeWithContext and the output returned.
            // Fake the message flags on the decrypted message.
            decryptedMimeBody = [decryptedMessage messageBodyUpdatingFlags:YES];
            // Check if the decrypted message contains any signatures, if so it's necessary
            // to unset the attachment flag.
            
            // Check if signatures are available. If not, they could still be in a mime part,
            // but messageBodyUpdatingFlags will take care of those.
            // Let's just set them on the decrypted message body.
            BOOL isSigned = NO;
            if([foundSignatures count]) {
                [[decryptedMimeBody topLevelPart] setValue:foundSignatures forKey:@"_messageSigners"];
                isSigned = YES;
            }
            else {
                // For PGP/MIME signed messages, the message signers can be found in the decryptedMimebody
                isSigned = [decryptedMimeBody containsPGPSignedData];
            }
            
            // Fixes the problem where an attachment icon is shown, when a message is either encrypted or signed.
            unsigned int decryptedNumberOfAttachments = [decryptedMimeBody numberOfAttachmentsSigned:NULL encrypted:NULL numberOfTNEFAttachments:NULL];
            if(decryptedNumberOfAttachments == NSNotFound)
                decryptedNumberOfAttachments = 0;
            if(decryptedNumberOfAttachments > 0 && isSigned)
                decryptedNumberOfAttachments -= 1;
            // Set the new number of attachments.
            [[(MimeBody *)[self mimeBody] message] setNumberOfAttachments:decryptedNumberOfAttachments isSigned:isSigned isEncrypted:YES];
            
            // If a signature error has been found, set that one on the decrypted message as well.
            // This is only necessary if the message body is not cleared.
            // Otherwise the message is revaluated.
            MFError *signatureError = [[decryptedMimeBody topLevelPart] valueForKey:@"_smimeError"];
            if(signatureError)
                [[ActivityMonitor currentMonitor] setError:signatureError];
            
            // After that set the decryptedMessage body with encrypted to yes!
            [[[self mimeBody] topLevelPart] setDecryptedMessageBody:decryptedMimeBody isEncrypted:YES isSigned:isSigned error:signatureError];
            // Flag the message as process.
            [[(MimeBody *)[self mimeBody] message] setIvar:@"PGPMessageProcessed" value:[NSNumber numberWithBool:YES]];
            [[[self mimeBody] topLevelPart] removeIvar:@"PGPEncryptedPart"];
            [self removeIvar:@"PGPEncryptedDataRange"];
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
    
    return decryptedMimeBody;
}

- (Message *)messageWithMessageData:(NSData *)messageData {
    MutableMessageHeaders *headers = [[MutableMessageHeaders alloc] init];
    NSMutableString *contentTypeString = [[NSMutableString alloc] init];
    [contentTypeString appendFormat:@"%@/%@", self.type, self.subtype];
    if([self bodyParameterForKey:@"charset"])
        [contentTypeString appendFormat:@"; charset=\"%@\"", [self bodyParameterForKey:@"charset"]];
    [headers setHeader:[contentTypeString dataUsingEncoding:NSASCIIStringEncoding] forKey:@"Content-Type"];
    [contentTypeString release];
    if(self.contentTransferEncoding)
        [headers setHeader:self.contentTransferEncoding forKey:@"Content-Transfer-Encoding"];
    
    NSMutableData *completeMessageData = [[NSMutableData alloc] init];
    [completeMessageData appendData:[headers encodedHeadersIncludingFromSpace:NO]];
    [completeMessageData appendData:messageData];
    [headers release];
    
    Message *message = [Message messageWithRFC822Data:completeMessageData];
    [completeMessageData release];
    
    return message;
}

- (void)failedToDecryptWithException:(NSException *)exception {
    NSBundle *gpgMailBundle = [NSBundle bundleForClass:[GPGMailBundle class]];
    NSString *title = NSLocalizedStringFromTableInBundle(@"MESSAGE_BANNER_PGP_DECRYPT_ERROR_TITLE", @"GPGMail", gpgMailBundle, @"");
    NSString *message = NSLocalizedStringFromTableInBundle(@"MESSAGE_BANNER_PGP_DECRYPT_ERROR_MESSAGE", @"GPGMail", gpgMailBundle, @"");
    MFError *error = [MFError errorWithDomain:@"MFMessageErrorDomain" code:1035 localizedDescription:nil title:title helpTag:nil 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:title, @"_MFShortDescription", message, @"NSLocalizedDescription", nil]];
    [[[self mimeBody] topLevelPart] setDecryptedMessageBody:nil isEncrypted:NO isSigned:NO error:error];
    [[ActivityMonitor currentMonitor] setError:error];
    // Set the message as processed, so it's not processed again.
    [[(MimeBody *)[self mimeBody] message] setIvar:@"PGPMessageProcessed" value:[NSNumber numberWithBool:YES]];
    [[(MimeBody *)[self mimeBody] topLevelPart] removeIvar:@"PGPEncryptedPart"];
    [self removeIvar:@"PGPEncryptedDataRange"];
    // Tell the message to fake the message flags, means adding the signed
    // and encrypted flag, otherwise the error banner is not shown.
    [[(MimeBody *)[self mimeBody] message] fakeMessageFlagsIsEncrypted:YES isSigned:NO];
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
        else
            [normalRecipients addObject:recipient];
    }
    DebugLog(@"Recipients: %@", recipients);
    DebugLog(@"BCC Recipients: %@", bccRecipients);
    DebugLog(@"Recipients: %@", normalRecipients);
    // TODO: unfortunately we don't know the hidden recipients in here...
    //       gotta find a workaround.
    // Ask the mail bundle for the GPGKeys matching the email address.
    NSSet *normalKeyList = [[GPGMailBundle sharedInstance] publicKeyListForAddresses:normalRecipients];
    NSMutableSet *bccKeyList = [[GPGMailBundle sharedInstance] publicKeyListForAddresses:bccRecipients];
	[bccKeyList minusSet:normalKeyList];
    
    DebugLog(@"BCC Recipients: %@", bccKeyList);
    
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
    DebugLog(@"[DEBUG] %s data: [%@] %@", __PRETTY_FUNCTION__, [data class], data);
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
		//*signatureData = [gpgc processData:data withEncryptSignMode:GPGClearSign recipients:nil hiddenRecipients:nil];
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
    
    
    // This doesn't work for PGP Inline,
    // But actually the signature could be created inline
    // Just the same way the pgp/signature is created and later
    // extracted.
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
    if(![[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToReceive"])
        return [self MAUsesKnownSignatureProtocol];
    
    if([[self bodyParameterForKey:@"protocol"] isEqualToString:@"application/pgp-signature"])
        return YES;
    return [self MAUsesKnownSignatureProtocol];
}

- (void)MAVerifySignature {
    if(![[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToReceive"])
        return [self MAVerifySignature];
    
    // If this is a non GPG signed message, let's call the original method
    // and get out of here!    
    if(![[self bodyParameterForKey:@"protocol"] isEqualToString:@"application/pgp-signature"]) {
        [self MAVerifySignature];
        return;
    }
    
    // Set the new number of attachments.
    unsigned int numberOfAttachments = [(MimePart *)[[self mimeBody] topLevelPart] numberOfAttachments];
    if(numberOfAttachments > 0)
        numberOfAttachments -= 1;
    [[(MimeBody *)[self mimeBody] message] setNumberOfAttachments:numberOfAttachments isSigned:YES isEncrypted:NO];
    
    MFError *error;
    BOOL needsVerification = [self needsSignatureVerification:&error];
    if(!error)
        error = [[[self mimeBody] topLevelPart] valueForKey:@"_smimeError"];
    
    DebugLog(@"Error: %@", error);
    if(!needsVerification || error) {
        if(error)
            [[ActivityMonitor currentMonitor] setError:error];
        return;
    }
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
    
    __block NSArray *signatures = nil;
    __block NSException *verificationException = nil;
    [[GPGMailBundle sharedInstance] addVerificationTask:^{
        GPGController *gpgc = [[GPGController alloc] init];
        gpgc.verbose = (GPGMailLoggingLevel > 0);
        @try {
            signatures = [gpgc verifySignature:signatureData originalData:signedData];
            [signatures retain];
            if(gpgc.error)
                @throw gpgc.error;
        }
        @catch(NSException *e) {
            verificationException = e;
            if(!signatures)
                signatures = nil;
            DebugLog(@"[DEBUG] %s - verification errror: %@", __PRETTY_FUNCTION__, e);
        }
        @finally {
            [gpgc release];
        }
    }];
	
    if(![signatures count] || verificationException) {
        if([signatures count])
            [[[self mimeBody] topLevelPart] setValue:signatures forKey:@"_messageSigners"];
        [self failedToVerifyWithException:verificationException];
        return;
    }
    
    // Check if the public key is in the keychain, otherwise display a warning [#269]
    BOOL nonDownloadedKeyFound = NO;
    for(GPGSignature *signature in signatures) {
        if(!signature.userID) {
            nonDownloadedKeyFound = YES;
            break;
        }
    }
    if(nonDownloadedKeyFound)
        [self failedToVerifyWithException:[NSException exceptionWithName:@"PGPKeyNotInKeychain" reason:@"The PGP key of the signature is not in your keychain" userInfo:nil]];
    
    // Signatures are stored in _messageSigners. that might not work, but
    // hopefully it does.
    [[[self mimeBody] topLevelPart] setValue:[signatures retain] forKey:@"_messageSigners"];
    DebugLog(@"[DEBUG] %s Found signatures: %@", __PRETTY_FUNCTION__, signatures);
    DebugLog(@"[DEBUG] %s saved signatures: %@", __PRETTY_FUNCTION__, [self valueForKey:@"_messageSigners"]);
    //[self setIvar:signatures value:@"messageSigners"];
    [signatures release];
    
    // Set a flag on the message that it has been completely process,
    // to avoid reprocessing it.
    [[(MimeBody *)[self mimeBody] message] setIvar:@"PGPMessageProcessed" value:[NSNumber numberWithBool:YES]];
    
    return;
}
         
- (void)_verifyPGPInlineSignature {
    NSData *signedData = [self bodyData];
    DebugLog(@"[DEBUG] %s mime part: %@", __PRETTY_FUNCTION__, self);
    DebugLog(@"[DEBUG] %s plain message signed data: %@", __PRETTY_FUNCTION__, [signedData stringByGuessingEncoding]);
    if(![signedData length] || [[self bodyData] rangeOfPGPInlineSignatures].location == NSNotFound)
        return;
    
    __block NSArray *signatures = nil;
    __block NSException *verificationException = nil;
    [[GPGMailBundle sharedInstance] addVerificationTask:^{
        GPGController *gpgc = [[GPGController alloc] init];
        gpgc.verbose = (GPGMailLoggingLevel > 0);
        @try {
            signatures = [gpgc verifySignedData:signedData];
            [signatures retain];
            if(gpgc.error)
                @throw gpgc.error;
        }
        @catch(NSException *e) {
            verificationException = e;
            if(!signatures)
                signatures = nil;
        }
        @finally {
            [gpgc release];
        }
    }];
    
    if(![signatures count] || verificationException) {
        if([signatures count])
            [[[self mimeBody] topLevelPart] setValue:signatures forKey:@"_messageSigners"];
        [self failedToVerifyWithException:verificationException];
        return;
    }
    
    // Check if the public key is in the keychain, otherwise display a warning [#269]
    BOOL nonDownloadedKeyFound = NO;
    for(GPGSignature *signature in signatures) {
        if(!signature.userID) {
            nonDownloadedKeyFound = YES;
            break;
        }
    }
    if(nonDownloadedKeyFound)
        [self failedToVerifyWithException:[NSException exceptionWithName:@"PGPKeyNotInKeychain" reason:@"The PGP key of the signature is not in your keychain" userInfo:nil]];
    
    DebugLog(@"[DEBUG] %s mime part: %@", __PRETTY_FUNCTION__, self);
    // Store the signature and done!
    [[[self mimeBody] topLevelPart] setValue:signatures forKey:@"_messageSigners"];
    DebugLog(@"[DEBUG] %s Found signatures: %@", __PRETTY_FUNCTION__, signatures);
    DebugLog(@"[DEBUG] %s saved signatures: %@", __PRETTY_FUNCTION__, [self valueForKey:@"_messageSigners"]);
    [signatures release];
    
    // Set a flag on the message that it has been completely process,
    // to avoid reprocessing it.
    [[(MimeBody *)[self mimeBody] message] setIvar:@"PGPMessageProcessed" value:[NSNumber numberWithBool:YES]];
    [[(MimeBody *)[self mimeBody] topLevelPart] removeIvar:@"PGPSignedPart"];
    [self removeIvar:@"PGPSignedDataRange"];
}

- (void)failedToVerifyWithException:(NSException *)exception {
    NSString *localizedKeyTitle = @"MESSAGE_BANNER_PGP_VERIFY_ERROR_TITLE";
    NSString *localizedKeyMessage = @"MESSAGE_BANNER_PGP_VERIFY_ERROR_MESSAGE";
    if([exception.name isEqualToString:@"PGPKeyNotInKeychain"]) {
        localizedKeyTitle = @"MESSAGE_BANNER_PGP_VERIFY_NOT_IN_KEYCHAIN_ERROR_TITLE";
        localizedKeyMessage = @"MESSAGE_BANNER_PGP_VERIFY_NOT_IN_KEYCHAIN_ERROR_MESSAGE";
    }
    
    NSBundle *gpgMailBundle = [NSBundle bundleForClass:[GPGMailBundle class]];
    NSString *title = NSLocalizedStringFromTableInBundle(localizedKeyTitle, @"GPGMail", gpgMailBundle, @"");
    NSString *message = NSLocalizedStringFromTableInBundle(localizedKeyMessage, @"GPGMail", gpgMailBundle, @"");
    MFError *error = [MFError errorWithDomain:@"MFMessageErrorDomain" code:1036 localizedDescription:nil title:title helpTag:nil 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:title, @"_MFShortDescription", message, @"NSLocalizedDescription", nil]];
    [[[self mimeBody] topLevelPart] setValue:error forKey:@"_smimeError"];
    [[ActivityMonitor currentMonitor] setError:error];
    // Set the message as processed, so it's not processed again.
    [[(MimeBody *)[self mimeBody] message] setIvar:@"PGPMessageProcessed" value:[NSNumber numberWithBool:YES]];
    [[(MimeBody *)[self mimeBody] topLevelPart] removeIvar:@"PGPSignedPart"];
    [self removeIvar:@"PGPSignedDataRange"];
    // Tell the message to fake the message flags, means adding the signed
    // and encrypted flag, otherwise the error banner is not shown.
    [[(MimeBody *)[self mimeBody] message] fakeMessageFlagsIsEncrypted:NO isSigned:YES];
}
         
- (id)MACopySignerLabels {
    if(![[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToReceive"])
        return [self MACopySignerLabels];

    // Check if the signature in the message signers is a GPGSignature, if
    // so, copy the email addresses and return them.
    NSMutableArray *signerLabels = [NSMutableArray array];
    NSArray *messageSigners = [self copyMessageSigners];
    // In case there are no message signers, simply return the original method.
    // Might be a problem, but shouldn't.
    if(![messageSigners count]) {
        [messageSigners release];
        return [self MACopySignerLabels];
    }
    if(![[messageSigners objectAtIndex:0] isKindOfClass:[GPGSignature class]]) {
        [messageSigners release];
        return [self MACopySignerLabels];
    }
    for(GPGSignature *signature in messageSigners) {
        // For some reason a signature might not have an email set.
        // This happens if the public key is not available (not downloaded or imported
        // from the signature server yet). In that case, display the user id.
        // Also, add an appropriate warning.
        NSString *email = [signature email];
        if(!email)
            email = [signature fingerprint];
        [signerLabels addObject:email];
    }
    [messageSigners release];
    
    return [signerLabels copy];
}

- (id)MACopyMessageSigners {
    if(![[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToReceive"])
        return [self MACopyMessageSigners];
    
    // Only invoke the original method if _messageSigners is not set yet.
    if([[[self mimeBody] topLevelPart] valueForKey:@"_messageSigners"])
        return [[[[self mimeBody] topLevelPart] valueForKey:@"_messageSigners"] copy];
    
    return [self MACopyMessageSigners];
}

- (BOOL)MAIsSigned {
    if(![[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToReceive"])
        return [self MAIsSigned];
    
    BOOL ret = [self MAIsSigned];
    // For plain text message is signed doesn't automatically find
    // the right signed status, so we check if copy signers are available.
    BOOL isPGPSigned = [self isPGPSigned];
    return (ret | isPGPSigned);
}

- (BOOL)isPGPSigned {
    NSArray *messageSigners = [[[self mimeBody] topLevelPart] valueForKey:@"_messageSigners"];
    if(messageSigners)
        DebugLog(@"[DEBUG] %s message signers: %@", __PRETTY_FUNCTION__, messageSigners);
    BOOL hasMessageSigners = ([messageSigners count] > 0 && [[messageSigners objectAtIndex:0] isKindOfClass:[GPGSignature class]]);
    return hasMessageSigners;
}

- (BOOL)isPGPInlineEncrypted {
    // Fetch body data to look for the leading GPG string.
    // For some reason textEncoding doesn't really work... and is actually never called
    // by Mail.app itself it seems.
    return [[self mimeBody] containsPGPEncryptedData];
}

- (BOOL)isPGPMimeSigned {
    // Check for RFC 3156 defined parts. multipart/signed, protocol application/pgp-signature.
    //
    if([self isType:@"multipart" subtype:@"signed"] && 
       [[self bodyParameterForKey:@"protocol"] isEqualToString:@"application/pgp-signature"] &&
       [[self subparts] count] == 2 &&
       [[self subpartAtIndex:1] isType:@"application" subtype:@"pgp-signature"]) {
        return YES;
    }
    
    return NO;
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
           NSString *version = [[versionPart bodyData] stringByGuessingEncoding];
           // All conditions matched.
           if([[version lowercaseString] rangeOfString:@"version: 1"].location != NSNotFound || 
              [[version lowercaseString] rangeOfString:@"version : 1"].location != NSNotFound) {
               // Save that this MimePart is encrypted for later. It's gonna trigger
               // a method which Mail uses to draw the message header which is used
               // for GPGMail's UI.
               [self setIvar:@"isEncrypted" value:[NSNumber numberWithBool:YES]];
               return YES;
           }
           else {
               return NO;
           }
    }
    
    return NO;
}

- (BOOL)isPGPEncrypted {
    if([self isPGPMimeEncrypted])
        return YES;
    if([self isPGPInlineEncrypted])
        return YES;
    return NO;
}

- (BOOL)MAIsEncrypted {
    if(![[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToReceive"])
        return [self MAIsEncrypted];
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

@end
