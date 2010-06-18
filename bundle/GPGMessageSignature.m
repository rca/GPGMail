//
//  GPGMessageSignature.m
//  GPGMail
//
//  Created by Dave Lopper on 11/26/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GPGMessageSignature.h"


@implementation GPGMessageSignature

- (id)initWithSignature:(GPGSignature *)aSignature range:(NSRange)aRange
{
    if(self = [super init]){
        signature = [aSignature retain];
        signedRange = aRange;
    }
    
    return self;
}

- (void) dealloc
{
    [signature release];
    
    [super dealloc];
}

- (GPGSignature *)signature
{
    return signature;
}

- (NSRange)signedRange
{
    return signedRange;
}

- (BOOL)coversWholeMessage
{
    return YES; // TODO:
}

@end
