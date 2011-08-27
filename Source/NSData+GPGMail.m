/* NSData+GPGMail.h created by Lukas Pitschl (@lukele) on Wed 24-Aug-2011 */

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

#import <NSString-NSStringUtils.h>
#import "NSData+GPGMail.h"

@implementation NSData (GPGMail)

- (NSString *)stringByGuessingEncoding {
    NSString *retString;
    
	if ([self length] == 0) {
		return @"";
	}
	
    int encodings[4] = {NSUTF8StringEncoding, NSISOLatin1StringEncoding, NSISOLatin2StringEncoding,
        NSASCIIStringEncoding};
    for(int i = 0; i < 4; i++) {
        retString = [NSString stringWithData:self encoding:encodings[i]];
        if([retString length] > 0)
            return retString;
        
    }
    
    @throw [NSException exceptionWithName:@"GPGUnknownStringEncodingException" 
                                   reason:@"It was not possible to recognize the string encoding." userInfo:nil];
}

- (NSRange)rangeOfPGPInlineSignatures  {
    NSRange range = NSMakeRange(NSNotFound, 0);
    
    NSString *signedContent = [self stringByGuessingEncoding];
    if([signedContent length] == 0)
        return range;
    NSRange startRange = [signedContent rangeOfString:PGP_SIGNED_MESSAGE_BEGIN];
    if(startRange.location == NSNotFound)
        return range;
    NSRange endRange = [signedContent rangeOfString:PGP_MESSAGE_SIGNATURE_END];
    if(endRange.location == NSNotFound)
        return range;
    
    return NSUnionRange(startRange, endRange);
}

- (NSRange)rangeOfPGPSignatures  {
    NSRange range = NSMakeRange(NSNotFound, 0);
    
    NSString *signedContent = [self stringByGuessingEncoding];
    if([signedContent length] == 0)
        return range;
    NSRange startRange = [signedContent rangeOfString:PGP_MESSAGE_SIGNATURE_BEGIN];
    if(startRange.location == NSNotFound)
        return range;
    NSRange endRange = [signedContent rangeOfString:PGP_MESSAGE_SIGNATURE_END];
    if(endRange.location == NSNotFound)
        return range;
    
    return NSUnionRange(startRange, endRange);
}


- (NSRange)rangeOfPGPInlineEncryptedData {
    // Fetch part body to look for the leading GPG string.
    // For some reason textEncoding doesn't really work... and is actually never called
    // by Mail.app itself it seems.
    NSString *body = [self stringByGuessingEncoding];
    // If the encoding can't be guessed, the body will probably be empty,
    // so let's get out of here.!
    if(![body length])
        return NSMakeRange(NSNotFound, 0);
    NSRange startRange = [body rangeOfString:PGP_MESSAGE_BEGIN];
    // For some reason (OS X Bug? Code bug?) comparing to NSNotFound doesn't
    // (always?) work.
    //if(startRange.location == NSNotFound)
    if(startRange.location == NSNotFound)
        return NSMakeRange(NSNotFound, 0);
    NSRange endRange = [body rangeOfString:PGP_MESSAGE_END];
    if(endRange.location == NSNotFound)
        return NSMakeRange(NSNotFound, 0);
    
    NSRange gpgRange = NSUnionRange(startRange, endRange);
    return gpgRange;
}

@end
