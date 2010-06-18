//
//  GPGMEAdditions.h
//  GPGMail
//
//  Created by Dave Lopper on 1/21/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <MacGPGME/MacGPGME.h>


@interface GPGKey(GPGMail)
- (BOOL) canHaveChildren;
- (NSNumber *) validityNumber;
- (NSString *) prefixedShortKeyID;
- (NSNumber *) additionalInfoValue;
- (NSString *) additionalInfo;
@end

@interface GPGRemoteKey(GPGMail)
- (BOOL) canHaveChildren;
- (NSString *) prefixedShortKeyID;
@end

@interface GPGUserID(GPGMail)
- (BOOL) canHaveChildren;
- (NSNumber *) validityNumber;
- (NSString *) normalizedEmail;
- (NSNumber *) additionalInfoValue;
- (NSString *) additionalInfo;
@end

@interface GPGRemoteUserID(GPGMail)
- (BOOL) canHaveChildren;
@end

@interface GPGSignature(GPGMail)
- (NSNumber *) validityNumber;
@end
