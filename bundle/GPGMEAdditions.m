//
//  GPGMEAdditions.m
//  GPGMail
//
//  Created by Dave Lopper on 1/21/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "GPGMEAdditions.h"
#import "NSString+GPGMail.h"
#import "GPGMailBundle.h"


@implementation GPGKey(GPGMail)

- (BOOL) canHaveChildren
{
    return YES;
}

- (NSNumber *) validityNumber
{
    return [NSNumber numberWithInt:[self validity]];
}

- (NSString *) prefixedShortKeyID
{
    return [@"0x" stringByAppendingString:[self shortKeyID]];
}

- (NSNumber *) additionalInfoValue
{
    // FIXME: Use that for key chooser
    int anInt = 0;
    
    if([self isKeyDisabled])
        anInt += 32;
    if([self isKeyInvalid])
        anInt += 16;
    if([self isKeyRevoked])
        anInt += 8;
    if([self hasKeyExpired])
        anInt += 4;
    /*    if(![self canEncrypt])
        anInt += 2;
    if(![self canSign])
        anInt += 1;*/
    
    return [NSNumber numberWithInt:anInt];
}

- (NSString *) additionalInfo
{
    // FIXME: Use that for key chooser
    NSMutableArray  *additionalInfo = [NSMutableArray array];
    NSBundle        *aBundle = [NSBundle bundleForClass:[GPGMailBundle class]];
    
    if([self isKeyDisabled])
        [additionalInfo addObject:NSLocalizedStringFromTableInBundle(@"DISABLED_KEY_QUALIFIER", @"GPGMail", aBundle, @"")];
    if([self isKeyInvalid])
        [additionalInfo addObject:NSLocalizedStringFromTableInBundle(@"INVALID_KEY_QUALIFIER", @"GPGMail", aBundle, @"")];
    if([self isKeyRevoked])
        [additionalInfo addObject:NSLocalizedStringFromTableInBundle(@"REVOKED_KEY_QUALIFIER", @"GPGMail", aBundle, @"")];
    if([self hasKeyExpired])
        [additionalInfo addObject:NSLocalizedStringFromTableInBundle(@"EXPIRED_KEY_QUALIFIER", @"GPGMail", aBundle, @"")];
/*    if(![self canEncrypt])
        [additionalInfo addObject:NSLocalizedStringFromTableInBundle(@"CANNOT_ENCRYPT_KEY_QUALIFIER", @"GPGMail", aBundle, @"")];
    if(![self canSign])
            [additionalInfo addObject:NSLocalizedStringFromTableInBundle(@"CANNOT_SIGN_KEY_QUALIFIER", @"GPGMail", aBundle, @"")];*/
    
    if([additionalInfo count] == 0)
        return @"";
    
    return [NSString stringWithFormat:@"(%@)", [additionalInfo componentsJoinedByString:@", "]];
}

@end

@implementation GPGUserID(GPGMail)

- (BOOL) canHaveChildren
{
    return NO;
}

- (NSNumber *) validityNumber
{
    return [NSNumber numberWithInt:[self validity]];
}

- (NSString *) normalizedEmail
{
    return [[self email] gpgNormalizedEmail];
}

- (NSNumber *) additionalInfoValue
{
    // FIXME: Use that for key chooser
    int anInt = 0;
    
    if([self isInvalid])
        anInt += 2;
    if([self hasBeenRevoked])
        anInt += 1;
    
    return [NSNumber numberWithInt:anInt];
}

- (NSString *) additionalInfo
{
    // FIXME: Use that for key chooser
    NSMutableArray  *additionalInfo = [NSMutableArray array];
    NSBundle        *aBundle = [NSBundle bundleForClass:[GPGMailBundle class]];
    
    if([self isInvalid])
        [additionalInfo addObject:NSLocalizedStringFromTableInBundle(@"INVALID_USER_ID_QUALIFIER", @"GPGMail", aBundle, @"")];
    if([self hasBeenRevoked])
        [additionalInfo addObject:NSLocalizedStringFromTableInBundle(@"REVOKED_USER_ID_QUALIFIER", @"GPGMail", aBundle, @"")];
    
    if([additionalInfo count] == 0)
        return @"";
    
    return [NSString stringWithFormat:@"(%@)", [additionalInfo componentsJoinedByString:@", "]];
}

@end

@implementation GPGRemoteKey(GPGMail)

- (BOOL) canHaveChildren
{
    return YES;
}

- (NSString *) prefixedShortKeyID
{
    return [@"0x" stringByAppendingString:[self shortKeyID]];
}

@end

@implementation GPGRemoteUserID(GPGMail)

- (BOOL) canHaveChildren
{
    return NO;
}

@end

@implementation GPGSignature(GPGMail)

- (NSNumber *) validityNumber
{
    return [NSNumber numberWithInt:[self validity]];
}

@end

