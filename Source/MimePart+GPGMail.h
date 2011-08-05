/* MimePart+GPGMail.h created by stephane on Mon 10-Jul-2000 */
/* MimePart+GPGMail.h re-created by Lukas Pitschl (@lukele) on Wed 03-Aug-2011 */

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

#import <MimePart.h>

#import <Libmacgpg/Libmacgpg.h>


@interface MimePart (GPGMail)

/**
 Creates the parsed message (content of the emai) which is then
 displayed to the user.
 It's called for every mime part once. It might return a string, an instance
 of parsed message or information to an attachment.
 
 For each part also decryptedMessageBodyIsEncrypted is called, which returns
 the message body of the decrypted message, which is set by either the S/MIME
 methods of Mail.app or the GPG methods. This also allows Mail.app to cache
 the decrypted body internally. (GPGMail might, but does not interfere with that
 cache at the moment.)
 
 GPGMail uses this method to implement support for GPG related mime parts, being
 pgp-encrypted and pgp-signature for the moment. It's also used for text/plain
 to support inline gpg encrypted messages.
 */
- (id)MADecodeWithContext:(id)ctx;

/**
 * Is called by GPGDecodeWithContext if a multipart/encrypted mime part
 * is found. Performs the decryption and returns the result.
 */
- (id)MADecodeMultipartEncryptedWithContext:(id)ctx;

/**
 Is called by GPGDecodeWithContext if a plain/text mime part is
 found, which contains gpg inline data. The GPG data might either be
 encrypted data or signature data. Based on the found data, the decryption
 or signature verification is performed and the result returned.
 
 Strips away the signature if found.
 */
- (id)MADecodeTextPlainWithContext:(id)ctx;

/**
 Removes the PGP signature part from the parsed message.
 Currently handles NSString type only!
 */
- (id)stripSignatureFromContent:(id)content;

/**
 Performs the decryption of GPG encrypted data and returns
 the result, parsing all the mime parts of the decoded message
 using GPGDecodeWithContext.
 
 If the encrypted data doesn't contain any mime parts, a new mime part
 is created, otherwise messageWithRFC822Data ends up creating an empty
 message body.
 */
- (id)MADecodeApplicationPgp_EncryptedWithData:(NSData *)encryptedData context:(id)ctx;

/**
 This methods is called internally by Mail's MessageWriter. The MessageWriter
 class is used to create outgoing messages and has various flags among them shouldSign
 and shouldEncrypt.
 If shouldEncrypt is set, this method is called the data to encrypt and returns the
 mime part which will contain the encrypted data.
 
 The actual encrypted data is stored in the pointer *encryptedData.
 */
- (id)MANewEncryptedPartWithData:(id)data recipients:(id)recipients encryptedData:(id *)encryptedData;

/**
 Like newEncryptedPartWithData (see above), this method is called from MessageWriter
 too when creating the outgoing message and shouldSign is set to true.
 
 Only the data to actually sign is passed in (some transformation necessary, to help
 with signature verification problems?)
 
 Again, the mime part containing the data is returned and the signature written
 to the *signatureData pointer. 
 */
- (id)MANewSignedPartWithData:(id)arg1 sender:(id)arg2 signatureData:(id *)arg3;

/**
 Called by verifySignature, after checking with needs signature verification
 is the verification has not already happened.
 If this method returns true, verifySignatureWithCMSDecoder is called, otherwise
 no validation happens.
 TODO: Allow for SMIME to still work!
 Using some kind of flag to signal gpg message.
 */
- (BOOL)MAUsesKnownSignatureProtocol;

/**
 For signed messages Mail.app automatically calls verifySignature.
 After first checking if the verification has not already been performed,
 using the MimePart.needsSignatureVerification method, this method
 verifies the signature, and stores all found signatures in MimePart._messageSigners.
 
 Unfortunately verifySignature understands that the signature
 is no MIME signature, hence never calls _verifySignatureWithCMSDecoder,
 therefore we have to hijack this method and re-implement it for our own.
 To decide whether or not the original method should be called, we'll
 use the protocol information.
 */
- (void)MAVerifySignature;

/**
 Verify an inline message signature and set GPGSignatures on mime part.
 Is only called, if ----BEGIN PGP SIGNATURE---- is found.
 */
- (void)_verifyPGPInlineSignature;

/**
 Is called by Mail.app in various occasions, not all of them explored
 yet.
 It simply returns the email address of each signature.
 */
- (id)MACopySignerLabels;

/**
 Is called by Mail.app to check if a message is signed. It's not yet entirely
 clear how Mail finds out whether a message is signed or not, but GPGMail uses
 the MimePart._messageSigners variable. 
 If message signers are available, this returns true.
 */
- (BOOL)MAIsSigned;

/**
 This methods checks if the mail body contains some inline PGP
 encrypted data, which starts with -----BEGIN PGP MESSAGE-----
 and ends with -----END PGP MESSAGE-----.
 
 If encrypted data is found, the range of the data is stored internally
 for use in the decoding functions and returns true.
 
 TODO: Cache this status, best on message level. Top level part
 didn't work so well...
 */
- (BOOL)isPGPInlineEncrypted;

/**
 This method checks if two special PGP related mime parts exist for the message. 
 1.) Part of type application/pgp-encrypted which contains the version (basically
 always version: 1)
 2.) Part of type application/octet-stream which contains the actual encrypted data.
 Returns true if the parts are found, otherwise false.
 
 TODO: Cache this status, best on message level. Top level part
 didn't work so well...
 */
- (BOOL)isPGPMimeEncrypted;

/**
 This method is called by Mail.app internally in various occasions, especially
 in MessageHeaderDisplay._attributedStringForSecurityHeader to check whether or not
 the security UI for a message should be displayed or not.
 */
- (BOOL)MAIsEncrypted;

/**
 Finds inline pgp signatures which start with -----BEGIN PGP SIGNATURE-----
 and ends with -----END PGP SIGNATURE-----.
 
 Returns the range of the signature or NSNotFound.
 */
- (NSRange)rangeOfPlainPGPSignatures;

/**
 Guesses the encoding of the mime body by checking the mime part
 for charset information.
 TODO: probably improve.
 */
- (NSUInteger)guessedEncoding;

@end

