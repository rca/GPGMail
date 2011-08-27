/* GPGFlaggedHeaderValue.m created by lukele on Thu 09-Aug-2011 */

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

#import "CCLog.h"
#import "NSString-EmailAddressString.h"
#import "GPGFlaggedHeaderValue.h"

const NSString *gpgFlaggedHeaderValuePrefix = @"gpg-flagged-%@-";
const NSString *gpgFlaggedHeaderValueSuffix = @"::";
static NSString* gpgFlaggedHeaderValueIdentifier;


@implementation GPGFlaggedHeaderValue

@synthesize key = _key, flaggedValue = _flaggedValue, value = _value;

+ (void)initialize {
    if(!gpgFlaggedHeaderValueIdentifier)
        gpgFlaggedHeaderValueIdentifier = [[NSString alloc] initWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]];
}

- (id)initWithHeaderValue:(NSString *)value key:(NSString *)key {
    self = [super init];
    if (self) {
        // Use the uncommentedAddress to get the address without
        // further user information.
        NSString *uncommentedAddress = [value uncommentedAddress];
        NSMutableString *flaggedValue = [NSMutableString stringWithFormat:(NSString *)gpgFlaggedHeaderValuePrefix, (NSString *)gpgFlaggedHeaderValueIdentifier];
        [flaggedValue appendFormat:@"%@%@%@", key, gpgFlaggedHeaderValueSuffix, uncommentedAddress];
        NSRange uncommentedAddressRange = [value rangeOfString:uncommentedAddress];
        NSString *realFlaggedValue = [value stringByReplacingCharactersInRange:uncommentedAddressRange withString:flaggedValue];
        
        _flaggedValue = [realFlaggedValue retain];
        _key = [key copy];
        _value = [value copy];
        _uncommentedFlaggedValue = nil;
        // Initialization code here.
    }
    
    return self;
}

- (id)description {
    return [_value description];
}

/**
 It's necessary to implement uncommentedAddress, since it's
 called before the addresses are passed into the signing and encryption
 methods and the flagged value would be replaced with the simple string.
 */
- (id)uncommentedAddress {
    // Don't autorelease it here, otherwise the object is overreleased,
    // after the message is sent.
    // Only create once. The NSString uncommentedAddress behaves the same way.
    if(!_uncommentedFlaggedValue) {
        _uncommentedFlaggedValue = [[GPGFlaggedHeaderValue alloc] initWithHeaderValue:[_value uncommentedAddress] key:_key];
    }
    return _uncommentedFlaggedValue;
}

- (BOOL)isFlaggedValue {
    return YES;
}

- (BOOL)isFlaggedValueWithKey:(NSString *)key {
    return [_key isEqualToString:key];
}

- (BOOL)isKindOfClass:(Class)aClass {
    if(aClass == NSClassFromString(@"NSString"))
        return YES;
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _value;
}

- (void)dealloc {
    [_flaggedValue release];
    [_uncommentedFlaggedValue release];
    [_key release];
    [_value release];
    [super dealloc];
}

@end

@implementation NSString (GPGFlaggedHeaderValue)

- (GPGFlaggedHeaderValue *)flaggedValueWithKey:(NSString *)key {
    // Don't autorelease it here, otherwise the object is overreleased,
    // after the message is sent.
    return [[[GPGFlaggedHeaderValue alloc] initWithHeaderValue:self key:key] autorelease]; 
}

- (BOOL)isFlaggedValue {
    return NO;
}

- (BOOL)isFlaggedValueWithKey:(NSString *)key {
    return NO;
}

@end

