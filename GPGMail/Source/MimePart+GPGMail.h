/* MimePart+GPGMail.h created by stephane on Mon 10-Jul-2000 */

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

#import <MimePart.h>

#import <MacGPGME/MacGPGME.h>


@interface MimePart (GPGMail)

- (BOOL)gpgIsEncrypted;
// Checks MIME headers/parameters; does not (currently) look in sub-parts

- (NSData *)gpgDecryptedDataWithPassphraseDelegate:(id) passphraseDelegate signatures:(NSArray **)signaturesPtr;
// Decrypts self; does not (currently) look in sub-parts
// Returns nil if nothing to decrypt
// Can raise an exception

- (BOOL)gpgHasSignature;
// Returns YES if recognizes signature block in self; does not (currently) look in sub-parts

- (GPGSignature *)gpgAuthenticationSignature;
// Returns the signature retrieved from self; does not (currently) look in sub-parts
// Can raise an exception

- (BOOL)gpgAllAttachmentsAreAvailable;
// Checks that part and subparts have downloaded all attachments. Needed for authentication.

- (BOOL)gpgSaveBodyToFile:fp12;

- (BOOL)gpgIsOpenPGPEncryptedContainerPart;
- (BOOL)gpgIsOpenPGPSignedContainerPart;

- (void)resetGpgCache;
- (id)gpgBetterDecode;

@end

