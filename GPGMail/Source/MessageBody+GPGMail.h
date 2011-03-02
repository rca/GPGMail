/* MessageBody+GPGMail.h created by dave on Thu 02-Nov-2000 */

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

#import <MessageBody.h>

#import "GPGMailBundle.h"
#import "GPG.subproj/GPGHandler.h"


@class MessageHeaders;
@class MutableMessageHeaders;


/*
 * This class is no longer a concrete class on MacOS X 10.1; it is now totally abstract (no instance created).
 * Messages have all MimeBody bodies, sometimes with type/subtype = nil/nil.
 */


extern NSString *GPGMailHeaderKey;


@interface MessageBody (GPGMail)

- (NSData *)gpgEncryptForRecipients:(NSArray *)recipients trustAllKeys:(BOOL) trustsAllKeys signWithKey:(GPGKey *)key passphraseDelegate:(id) passphraseDelegate format:(GPGMailFormat *)mailFormatPtr headers:(MutableMessageHeaders **)headersPtr;
// Signs only if key is not nil; passphraseDelegate is necessary only if key is not nil.
// Can raise an exception

- (NSData *)gpgSignWithKey:(GPGKey *)key passphraseDelegate:(id) passphraseDelegate format:(GPGMailFormat *)mailFormatPtr headers:(MutableMessageHeaders **)headersPtr;
// Can raise an exception

- (BOOL)gpgIsEncrypted;

- (MessageBody *)gpgDecryptedBodyWithPassphraseDelegate:(id) passphraseDelegate signatures:(NSArray **)signaturesPtr headers:(MessageHeaders **)decryptedMessageHeaders;
// Can raises an exception; test first with -gpgIsEncrypted

- (BOOL)gpgHasSignature;

- (GPGSignature *)gpgAuthenticationSignature;
// Raises an exception if message does not contain a signature; test first with -gpgHasSignature
// Returns nil if no authenticated signature has been found
- (GPGSignature *)gpgEmbeddedAuthenticationSignature;
// Can raise an exception
// Must be used for OpenPGP embedded signatures, to avoid some checks
// In MessageBody, same implementation as -gpgAuthenticationSignature
- (GPGSignature *)gpgAuthenticationSignatureFromData:(NSData *)data;
// Used by -[MimeBody(GPGMail) gpgAuthenticationSignature]

- (BOOL)gpgIsPGPMIMEMessage;

- (NSData *)gpgRawData;

@end
