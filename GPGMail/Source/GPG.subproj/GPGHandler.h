/* GPGHandler.h created by stephane on Fri 30-Jun-2000 */

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

#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>
#import <CoreFoundation/CFString.h>


@class NSArray;
@class NSConditionLock;
@class NSData;
@class NSTask;


typedef enum {
    GPGNoSignature,
    GPGInlineSignature,			// Old-style
    GPGDetachedSignature,		// OpenPGP: sign+encrypt in one operation
    GPGEncapsulatedSignature	// OpenPGP: sign then encrypt => 2 operations
}GPGMessageSignatureType;


extern NSString	*GPGHandlerException;
	// UserInfo:
	//	TerminationStatus = task termination status (NSNumber)
	//	Error = stderr (NSString)


@interface GPGHandler : NSObject
{
    NSConditionLock	*readLock;
    NSData			*stderrData;
    NSData			*stdoutData;
    NSData			*statusData;
    NSTask			*currentTask;
    BOOL            operationCancelled;
}

// All operations use options: --armor --utf8-strings

+ (id) handler;
+ (void) clearCache;

+ (NSData *) convertedStringData:(NSData *)data fromEncoding:(CFStringEncoding)originalEncoding toEncoding:(CFStringEncoding *)newEncoding;
// Always use this method before passing data to a method:
// gpg knows only very few encodings, and will convert data
// to the one it knows.

- (NSData *) encryptData:(NSData *)data withSignatureType:(GPGMessageSignatureType)signatureType sender:(NSString *)sender passphrase:(NSString *)passphrase recipients:(NSArray *)recipients encoding:(CFStringEncoding)encoding;
// Raises an exception in case of error.

- (NSData *) decryptData:(NSData *)data passphrase:(NSString *)passphrase signature:(NSString **)signature encoding:(CFStringEncoding)encoding;
// Returns decrypted data. Signature (if any) is returned in *signature.
// Raises an exception in case of error.

- (NSData *) signData:(NSData *)data sender:(NSString *)sender passphrase:(NSString *)passphrase detachedSignature:(BOOL)detachedSignature encoding:(CFStringEncoding)encoding;
// Returns either signed data, or detached signature.
// Raises an exception in case of error.

- (NSString *) authenticationSignatureFromData:(NSData *)signedData encoding:(CFStringEncoding)encoding;
// Returns authenticated user-id (Real Name (Comment) <email>)
// Raises an exception in case of error.

- (NSString *) authenticationSignatureFromData:(NSData *)signedData signatureFile:(NSString *)signatureFile encoding:(CFStringEncoding)encoding;
// Returns authenticated user-id (Real Name (Comment) <email>)
// Raises an exception in case of error.

- (NSArray *) knownHashAlgorithms;
// Raises an exception in case of error.
- (NSString *) defaultHashAlgorithm;
// Raises an exception in case of error.

// The following two method expect normalized EndOfLines CRLF
+ (NSRange) pgpSignatureBlockRangeInData:(NSData *)data;
+ (NSRange) pgpEncryptionBlockRangeInData:(NSData *)data;
+ (NSRange) pgpPublicKeyBlockRangeInData:(NSData *)data;

- (void) cancelOperation;

@end
