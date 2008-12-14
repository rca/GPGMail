/* Message+GPGMail.h created by stephane on Fri 30-Jun-2000 */

/*
 * Copyright (c) 2000-2008, Stéphane Corthésy <stephane at sente.ch>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of Stéphane Corthésy nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY STÉPHANE CORTHÉSY AND CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL STÉPHANE CORTHÉSY AND CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Message.h>

#import "GPG.subproj/GPGHandler.h"
#import "GPGMailBundle.h"


@class NSArray;


@interface Message(GPGMail)

//- (NSArray *) gpgRecipients;
// Returns email addresses of To, CC (but not BCC)

- (BOOL) gpgIsEncrypted;
- (void) gpgEncryptForRecipients:(NSArray *)recipients trustAllKeys:(BOOL)trustsAllKeys signWithKey:(GPGKey *)key passphraseDelegate:(id)passphraseDelegate format:(GPGMailFormat)mailFormat;
// Doesn't encrypt empty messages
// Signs only if key is not nil; passphraseDelegate is necessary only if key is not nil.
// Can raise an exception
//- (Message *) gpgDecryptedMessageWithPassphraseDelegate:(id)passphraseDelegate signature:(GPGSignature **)signature;
- (void) gpgDecryptMessageWithPassphraseDelegate:(id)passphraseDelegate messageSignatures:(NSMutableArray *)messageSignatures;
// Can raise an exception
// Returns a new Message

- (BOOL) gpgHasSignature;
- (void) gpgSignWithKey:(GPGKey *)key passphraseDelegate:(id)passphraseDelegate format:(GPGMailFormat)mailFormat;
// Doesn't sign empty messages
// Can raise an exception
- (GPGSignature *) gpgAuthenticationSignature;
// Can raise an exception
- (GPGSignature *) gpgEmbeddedAuthenticationSignature;
// Can raise an exception
// Must be used for OpenPGP embedded signatures, to avoid some checks

- (BOOL) gpgIsPGPMIMEMessage;

#if defined(LEOPARD) || defined(TIGER)
- (GPGSignature *) gpgSignature;
- (void) setGpgIsDecrypting:(BOOL)flag;
- (BOOL) gpgIsDecrypting;
- (void) gpgSetMayClearCachedDecryptedMessageBody:(BOOL)flag;
- (BOOL) gpgMayClearCachedDecryptedMessageBody;
- (NSException *) gpgException;
- (void) setGpgException:(NSException *)exception;
- (NSArray *) gpgMessageSignatures;
- (void) setGpgMessageSignatures:(NSArray *)messageSignatures;
#endif

- (NSString *) gpgDescription;

- (NSData *)gpgCurrentFullBodyPartDataAndHeaderDataIfReadilyAvailable:(NSData **)headerDataPtr;
- (void)gpgUpdateCurrentFullBodyPartData:(NSData *)newData;

@end
