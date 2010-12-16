/* GPGSignature.m created by dave on Tue 21-Nov-2000 */

/*
 *	Copyright GPGMail Project Team (gpgmail-devel@lists.gpgmail.org), 2000
 *	(see LICENSE.txt file for license information)
 */

#import "GPGSignature.h"

#import <Foundation/Foundation.h>


@implementation GPGSignature

+ (id)signatureWithContents:(NSString *)contents {
	NSScanner *aScanner = [NSScanner scannerWithString:contents];
	GPGSignature *signature = nil;

	// gpg: can't mmap pool of 16384 bytes: Invalid argument - using malloc
	// gpg: Please note that you don't have secure memory on this system
	// ...
	// gpg: Signature made 07/04/00 19:25:39 CEST using DSA key ID 12345678
	// gpg: Good signature from "GPGMail Project Team <gpgmail-devel@lists.gpgmail.org>"
	//

	if ([aScanner scanUpToString:@"Signature made " intoString:NULL] && ![aScanner isAtEnd]) {
		NSString *aString;

		signature = [[[self alloc] init] autorelease];

		NSAssert([aScanner scanString:@"Signature made " intoString:NULL], @"Did not scan twice the same string?!");
		NSAssert([aScanner scanUpToString:@" using " intoString:&aString], @"Unable to find end of signature date?!");
		signature->date = [[NSCalendarDate dateWithString:aString calendarFormat:@"%m/%d/%y %H:%M:%S %Z"] retain];

		NSAssert([aScanner scanString:@" using " intoString:NULL], @"Did not scan twice the same string?!");
		NSAssert([aScanner scanUpToString:@" key ID " intoString:&aString], @"Unable to find end of signature type?!");
		signature->signatureType = [aString retain];

		NSAssert([aScanner scanString:@" key ID " intoString:NULL], @"Did not scan twice the same string?!");
		NSAssert([aScanner scanUpToString:@"\n" intoString:&aString], @"Unable to find end of signature key ID?!");
		signature->keyID = [aString retain];

		NSAssert([aScanner scanUpToString:@"Good signature from \"" intoString:NULL], @"Unable to find signatory name?!");
		NSAssert([aScanner scanString:@"Good signature from \"" intoString:NULL], @"Did not scan twice the same string?!");
		NSAssert([aScanner scanUpToString:@" (" intoString:&aString], @"Unable to find end of signatory name?!");
		signature->signatoryName = [aString retain];

		NSAssert([aScanner scanString:@" (" intoString:NULL], @"Did not scan twice the same string?!");
		NSAssert([aScanner scanUpToString:@")<" intoString:&aString], @"Unable to find end of comment?!");
		signature->comment = [aString retain];

		NSAssert([aScanner scanString:@")<" intoString:NULL], @"Did not scan twice the same string?!");
		NSAssert([aScanner scanUpToString:@">\"" intoString:&aString], @"Unable to find end of signatory email?!");
		signature->signatoryEmail = [aString retain];
	} else {
		// We could return an exception
	}

	return signature;
}

- (void)dealloc {
	[date release];
	[signatureType release];
	[keyID release];
	[signatoryName release];
	[comment release];
	[signatoryEmail release];

	[super dealloc];
}

- (NSCalendarDate *)date {
	return date;
}

- (NSString *)signatureType {
	return signatureType;
}

- (NSString *)keyID {
	return keyID;
}

- (NSString *)signatoryName {
	return signatoryName;
}

- (NSString *)comment {
	return comment;
}

- (NSString *)signatoryEmail {
	return signatoryEmail;
}

@end
