/* NSData+GPGMail.m created by dave on Fri 13-Apr-2001 */

/*
 * Copyright (c) 2000-2011, GPGTools Project Team <gpgmail-devel@lists.gpgmail.org>
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

#import "NSData+GPGMail.h"
#import <Foundation/Foundation.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import <NSData+Message.h>


@implementation NSData (GPGMail)

- (NSData *)gpgStandardizedEOLsToCRLF {
	// Converts all LF or CR end-of-lines to CRLF end-of-lines
#define CR '\r'
#define LF '\n'
	unsigned length = [self length];
	NSData *result;

	if (length > 0) {
		unsigned i = 0, newLength = 0;
		BOOL foundCR = NO;
		const unsigned char *oldBytes;
		unsigned char aByte, *newBytes;

		oldBytes = [self bytes];
		newBytes = NSZoneMalloc(NSDefaultMallocZone(), 2 * length);

		for (; i < length; i++) {
			aByte = oldBytes[i];
			if (aByte == LF) {
				if (!foundCR) {
					newBytes[newLength++] = CR;
					newBytes[newLength++] = LF;
				} else {
					newBytes[newLength++] = LF;
					foundCR = NO;
				}
			} else {
				if (foundCR) {
					newBytes[newLength++] = LF;
				}
				newBytes[newLength++] = aByte;
				foundCR = (aByte == CR);
			}
		}
		if (foundCR) {
			newBytes[newLength++] = LF;                                      // Last byte!

		}
		result = [NSData dataWithBytes:newBytes length:newLength];
		NSZoneFree(NSDefaultMallocZone(), newBytes);
	} else {
		result = [NSData data];
	}

	return result;
#undef LF
#undef CR
}

- (NSData *)gpgStandardizedEOLsToLF {
	// Converts all CRLF or CR end-of-lines to LF end-of-lines
#define CR '\r'
#define LF '\n'
	unsigned length = [self length];
	NSData *result;

	if (length > 0) {
		unsigned i = 0, newLength = 0;
		BOOL foundCR = NO;
		const unsigned char *oldBytes;
		unsigned char aByte, *newBytes;

		oldBytes = [self bytes];
		newBytes = NSZoneMalloc(NSDefaultMallocZone(), length);

		for (; i < length; i++) {
			aByte = oldBytes[i];
			if (aByte == CR) {
				newBytes[newLength++] = LF;
				foundCR = YES;
			} else {
				if (foundCR && aByte == LF) {
					foundCR = NO;
				} else {
					newBytes[newLength++] = aByte;
					foundCR = (aByte == CR);
				}
			}
		}

		result = [NSData dataWithBytes:newBytes length:newLength];
		NSZoneFree(NSDefaultMallocZone(), newBytes);
	} else {
		result = [NSData data];
	}

	return result;
#undef LF
#undef CR
}

- (BOOL)gpgContainsNonASCIICharacter {
	unsigned i = [self length];

	if (i > 0) {
		const char *bytes = [self bytes];

		do {
			if (bytes[--i] & 0x80) {
				return YES;
			}
		} while (i != 0);
	}
	return NO;
}

- (NSData *)gpgNormalizedDataForVerifying {
	NSMutableData *result = [NSMutableData dataWithData:self];

	[result gpgNormalizeDataForVerifying];

	return result;
}

- (NSRange)gpgHeaderBodySeparationRange {
#define CR '\r'
#define LF '\n'
	const unsigned char *bytes = [self bytes];
	const int length = [self length];
	int i;
	NSRange result = NSMakeRange(NSNotFound, 0);

	// First let's find start of body (skip headers)
	for (i = 0; i < length; i++) {
		if (bytes[i] == CR) {
			if (i + 1 < length) {
				if (bytes[i + 1] == CR) {
					result.location = i + 1;
					result.length = 1;
					break;
				}
				if (bytes[i + 1] == LF) {
					if (i + 3 < length) {
						if (bytes[i + 2] == CR && bytes[i + 3] == LF) {
							result.location = i + 2;
							result.length = 2;
							break;
						}
					}
				}
			}
			if (i == 0) {
				result.location = 0;
				result.length = 1;
				break;
			}
		} else if (bytes[i] == LF) {
			if (i + 1 < length) {
				if (bytes[i + 1] == LF) {
					result.location = i + 1;
					result.length = 1;
					break;
				}
			}
			if (i == 0) {
				result.location = 0;
				result.length = 1;
				break;
			}
		}
	}

	return result;
#undef LF
#undef CR
}

enum {
	lookingForNothing,
	lookingForFirstDash,
	lookingForSecondDash,
	lookingForFirstSpace,
	lookingForSecondSpace,
	lookingForCR,
	lookingForLF
};

- (NSData *)gpgFormatFlowedFixedWithCRLF:(BOOL)useCRLF useQP:(BOOL)useQP {
	// Replace line consisting of DASH DASH SPACE [SPACE] by DASH DASH
	// WARNING Sometimes there is only 1 space!
	unsigned length = [self length];
	NSData *result;

	if (length > 0) {
		unsigned i = 0, newLength = 0;
		const unsigned char *oldBytes;
		unsigned char aByte, *newBytes;
		int state = lookingForFirstDash;

		oldBytes = [self bytes];
		newBytes = NSZoneMalloc(NSDefaultMallocZone(), length);

		for (; i < length; i++) {
			aByte = oldBytes[i];
			if (state == lookingForFirstDash && aByte == '-') {
				state = lookingForSecondDash;
				newBytes[newLength++] = '-';
			} else if (state == lookingForSecondDash && aByte == '-') {
				state = lookingForFirstSpace;
				newBytes[newLength++] = '-';
			} else if (state == lookingForFirstSpace && aByte == ' ') {
				state = lookingForSecondSpace;
				newBytes[newLength++] = ' ';
			} else if (state == lookingForSecondSpace && aByte == ' ') {
				if (useCRLF) {
					state = lookingForCR;
				} else {
					state = lookingForLF;
				}
				newBytes[newLength++] = ' ';
			} else if (useCRLF && (state == lookingForSecondSpace || state == lookingForCR) && aByte == '\r') {
				state = lookingForLF;
				newBytes[newLength++] = '\r';
			} else if ((state == lookingForSecondSpace || state == lookingForLF) && aByte == '\n') {
				if (useCRLF) {
					if (state == lookingForSecondSpace) {
						newLength -= 2;
					} else {
						newLength -= 3;
					}
					if (useQP) {
						newBytes[newLength++] = '=';
						newBytes[newLength++] = '2';
						newBytes[newLength++] = '0';
						newBytes[newLength++] = '\r';
						newBytes[newLength++] = '\n';
					} else {
						newBytes[newLength++] = '\r';
						newBytes[newLength++] = '\n';
					}
				} else {
					// Remove trailing space(s)
					if (state == lookingForSecondSpace) {
						newLength -= 1;
					} else {
						newLength -= 2;
					}
					// If uses quoted-printable, append space encoded in quoted-printable
					if (useQP) {
						newBytes[newLength++] = '=';
						newBytes[newLength++] = '2';
						newBytes[newLength++] = '0';
						newBytes[newLength++] = '\n';
					} else {
						newBytes[newLength++] = '\n';
					}
				}
				state = lookingForFirstDash;
			} else {
				state = (aByte == '\n' ? lookingForFirstDash : lookingForNothing);
				newBytes[newLength++] = aByte;
			}
		}

		result = [NSData dataWithBytes:newBytes length:newLength];
		NSZoneFree(NSDefaultMallocZone(), newBytes);
	} else {
		result = [NSData data];
	}

	return result;
}

- (NSData *)gpgDeleteTrailingSpacesUseCRLF:(BOOL)useCRLF useQP:(BOOL)useQP {
	// Delete trailing spaces, or replace the last one (on a line) by a quoted one
	unsigned length = [self length];
	NSData *result;

	if (length > 0) {
		unsigned i = 0, newLength = 0;
		const unsigned char *oldBytes;
		unsigned char aByte, *newBytes;
		BOOL lookingForCR = useCRLF, lookingForLF = !useCRLF;

		oldBytes = [self bytes];
		newBytes = NSZoneMalloc(NSDefaultMallocZone(), length);

		for (; i < length; i++) {
			aByte = oldBytes[i];
			if (lookingForCR && aByte == '\r') {
				lookingForCR = NO;
				lookingForLF = YES;
				newBytes[newLength++] = '\r';
			} else if (lookingForLF && aByte == '\n') {
				lookingForCR = useCRLF;
				lookingForLF = !useCRLF;
				if (useCRLF) {
					if (!useQP) {
						while (newLength > 1 && newBytes[newLength - 2] == ' ')
							newLength--;
						newBytes[newLength - 1] = '\r';
						newBytes[newLength++] = '\n';
					} else {
						if (newLength > 1 && newBytes[newLength - 2] == ' ') {
							newBytes[newLength - 2] = '=';
							newBytes[newLength - 1] = '2';
							newBytes[newLength++] = '0';
							newBytes[newLength++] = '\r';
							newBytes[newLength++] = '\n';
						}
					}
				} else {
					if (!useQP) {
						while (newLength > 0 && newBytes[newLength - 1] == ' ')
							newLength--;
						newBytes[newLength++] = '\n';
					} else {
						if (newLength > 0 && newBytes[newLength - 1] == ' ') {
							newBytes[newLength - 1] = '=';
							newBytes[newLength++] = '2';
							newBytes[newLength++] = '0';
							newBytes[newLength++] = '\n';
						}
					}
				}
			} else {
				if (aByte == '\n') {
					lookingForCR = useQP;
					lookingForLF = !useQP;
				}
				newBytes[newLength++] = aByte;
			}
		}

		result = [NSData dataWithBytes:newBytes length:newLength];
		NSZoneFree(NSDefaultMallocZone(), newBytes);
	} else {
		result = [NSData data];
	}

	return result;
}

- (NSData *)gpgDecodeFlowedWithEncoding:(CFStringEncoding)encoding {
	// Decode format=flowed data according to
	// http://www.ietf.org/rfc/rfc2646.txt?number=2646
	// FIXME: Does not support any UTF16
	NSMutableData *outputData = [self mutableCopy];
	unsigned aLength = [self length];
	unsigned i = 0;
	BOOL lastCharWasSP = NO;
	BOOL lastCharsWereSPCR = NO;
	unsigned anOffset = 0;
	const char *bytes = [self bytes];

	for (; i < aLength; i++) {
		char aChar = bytes[i];

		if (aChar == '\n' && lastCharsWereSPCR) {
			[outputData replaceBytesInRange:NSMakeRange(i - anOffset - 1, 2) withBytes:NULL length:0];                                     // Delete CRLF
			lastCharsWereSPCR = NO;
			lastCharWasSP = NO;
			anOffset += 2;
		} else if (aChar == '\r' && lastCharWasSP) {
			lastCharsWereSPCR = YES;
			lastCharWasSP = NO;
		} else if (aChar == ' ') {
			lastCharsWereSPCR = NO;
			lastCharWasSP = YES;
		} else {
			lastCharsWereSPCR = NO;
			lastCharWasSP = NO;
		}
	}

	return [outputData autorelease];
}

@end

@implementation NSMutableData (GPGMail)

- (void)gpgNormalizeDataForSigning {
	[self setData:[self gpgStandardizedEOLsToCRLF]];             // All end-of-lines must be made with <CR><LF>
	// Let's remove/replace trailing whitespace
#warning Remove trailing whitespaces!
}

- (void)gpgNormalizeDataForVerifying {
	// Verifying can occur only on 7-bit data (OpenPGP)
//    NSAssert(![self gpgContainsNonASCIICharacter], @"### -[NSMutableData(GPGMail) gpgNormalizeDataForVerifying]: Invalid signed content with 8-bit data?!");
	[self setData:[self gpgStandardizedEOLsToCRLF]];             // All end-of-lines must be made with <CR><LF>
}

- (BOOL)gpgApplyQuotedPrintableIfNeeded:(BOOL)alreadyUsesQuotedPrintable {
#warning No longer needed?
	// self is expected to be "normalized"
	// If a line begins with "From " we quote-printable one of the characters, for example the "F" => "=46"
	// Signing can occur only on 7-bit data (OpenPGP)
	BOOL needsQuotedPrintable = NO;

	if ([self gpgContainsNonASCIICharacter]) {
		NSParameterAssert(alreadyUsesQuotedPrintable == NO);                         // How could it be possible?! Would be a bug.
		needsQuotedPrintable = YES;
#warning Might need base64 instead
		NSLog(@"### GPGMail: signature will be invalid. Cannot sign 8bit data in OpenPGP.");
	} else {
		NSString *aString = [[NSString alloc] initWithData:self encoding:NSASCIIStringEncoding];

		needsQuotedPrintable = ([aString hasPrefix:@"From "] || [aString rangeOfString:@"\r\nFrom " options:NSLiteralSearch].length > 0);
#warning Might need base64 instead
		[aString release];
	}

	if (needsQuotedPrintable) {
#if 0
		NSMutableString *modifiedString;
		unsigned stringLength;
		NSRange searchRange;

		if (!alreadyUsesQuotedPrintable) {
			modifiedString = [[NSMutableString alloc] initWithData:[self encodeQuotedPrintableForText:YES] encoding:NSASCIIStringEncoding];
		} else {
			modifiedString = [[NSMutableString alloc] initWithData:self encoding:NSASCIIStringEncoding];
		}
		stringLength = [modifiedString length];
		searchRange = NSMakeRange(0, stringLength);

		if ([modifiedString hasPrefix:@"From "]) {
			[modifiedString replaceCharactersInRange:NSMakeRange(0, 1) withString:@"=46"];
			stringLength += 2;
			searchRange.location = 5;
			searchRange.length = stringLength - 5;
		}
		do {
			NSRange aRange = [modifiedString rangeOfString:@"\r\nFrom " options:NSLiteralSearch range:searchRange];

			if (aRange.length > 0) {
				[modifiedString replaceCharactersInRange:aRange withString:@"\r\n=46rom "];
				stringLength += 2;
				searchRange.location = aRange.location + 7;
				searchRange.length = stringLength - aRange.location;
			} else {
				break;
			}
		} while (searchRange.length > 0);
		[self setData:[modifiedString dataUsingEncoding:NSASCIIStringEncoding]];
		[modifiedString release];
#else
		// BUG in Mail.app: lines beginning with "From " are not all escaped, but I can't do it here,
		// because I work only on the top-level part which wraps all subparts
		// Mail in 10.1.4 (maybe earlier): bug has been corrected by Apple
		NSLog(@"### GPGMail: Authentication might not work.");
		needsQuotedPrintable = NO;
#endif /* if 0 */
	}

	return needsQuotedPrintable && !alreadyUsesQuotedPrintable;
}

- (void)gpgASCIIfy {
	// Replaces all non-ASCII chars by '_'
	int i;
	unsigned char *bytes = [self mutableBytes];

	for (i = [self length] - 1; i >= 0; i--) {
		if (bytes[i] > 127) {
			bytes[i] = '_';
		}
	}
}

@end
