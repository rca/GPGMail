/* NSData+GPGMail.h created by dave on Fri 13-Apr-2001 */

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

#import <Foundation/NSData.h>


@interface NSData (GPGMail)

- (NSData *)gpgStandardizedEOLsToCRLF;
// Converts all LF or CR end-of-lines to CRLF end-of-lines
- (NSData *)gpgStandardizedEOLsToLF;
// Converts all CRLF or CR end-of-lines to LF end-of-lines
- (BOOL)gpgContainsNonASCIICharacter;
// Returns YES if contains 8-bit values > 127
- (NSData *)gpgNormalizedDataForVerifying;

- (NSRange)gpgHeaderBodySeparationRange;

- (NSData *)gpgFormatFlowedFixedWithCRLF:(BOOL) useCRLF useQP:(BOOL)useQP;
- (NSData *)gpgDeleteTrailingSpacesUseCRLF:(BOOL) useCRLF useQP:(BOOL)useQP;
- (NSData *)gpgDecodeFlowedWithEncoding:(CFStringEncoding)encoding;

@end

@interface NSMutableData (GPGMail)
- (void)gpgNormalizeDataForSigning;  // Normalizes EOLs
- (void)gpgNormalizeDataForVerifying;  // Normalizes EOLs
- (BOOL)gpgApplyQuotedPrintableIfNeeded:(BOOL)alreadyUsesQuotedPrintable;  // Returns YES if needed to quoted-printable (and alreadyUsesQuotedPrintable was NO)
- (void)gpgASCIIfy;  // Replaces all non-ASCII chars by '_'

@end
