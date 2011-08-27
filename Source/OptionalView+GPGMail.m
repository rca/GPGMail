//
//  OptionalView+GPGMail.m
//  GPGMail
//
//  Created by Lukas Pitschl on 31.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Libmacgpg/Libmacgpg.h>
#import "NSObject+LPDynamicIvars.h"
#import "OptionalView+GPGMail.h"

@implementation OptionalView_GPGMail

- (double)MAWidthIncludingOptionSwitch:(BOOL)includeOptionSwitch {
    if(![[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToSend"]) {
        return [self MAWidthIncludingOptionSwitch:includeOptionSwitch];
    }
    
    double ret;
    if([self ivarExists:@"securityViewWidth"])
        ret = [[self getIvar:@"securityViewWidth"] floatValue] + (includeOptionSwitch ? 20.0f : 0.0f);
    else
        ret = [self MAWidthIncludingOptionSwitch:includeOptionSwitch];
    return ret;
}

@end
