/* GPGSignature.h created by dave on Tue 21-Nov-2000 */

/*
 *	Copyright GPGMail Project Team (gpgmail-devel@lists.gpgmail.org), 2000
 *	(see LICENSE.txt file for license information)
 */

#import <Foundation/NSObject.h>


@class NSCalendarDate;


@interface GPGSignature : NSObject
{
	NSCalendarDate * date;
	NSString * signatureType;
	NSString * keyID;
	NSString * signatoryName;
	NSString * comment;
	NSString * signatoryEmail;
}

+ (id)signatureWithContents:(NSString *)contents;

- (NSCalendarDate *)date;
- (NSString *)signatureType;
- (NSString *)keyID;
- (NSString *)signatoryName;
- (NSString *)comment;
- (NSString *)signatoryEmail;

@end
