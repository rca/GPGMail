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

#define restrict
#import <RegexKit/RegexKit.h>
#import <NSString-NSStringUtils.h>
#import "NSData+GPGMail.h"

@implementation NSData (GPGMail)

- (NSString *)stringByGuessingEncoding {
    NSString *retString;
    
	if ([self length] == 0) {
		return @"";
	}
	
    int items = 10;
//    int encodings[10] = {NSUTF8StringEncoding, 
//                            NSWindowsCP1251StringEncoding, NSWindowsCP1252StringEncoding, NSWindowsCP1253StringEncoding,
//                            NSWindowsCP1254StringEncoding, NSWindowsCP1250StringEncoding, NSISO2022JPStringEncoding,
//                            NSISOLatin1StringEncoding, NSISOLatin2StringEncoding,                    
//                            NSASCIIStringEncoding};
    int encodings[10] = {NSUTF8StringEncoding, 
        NSISOLatin1StringEncoding, NSISOLatin2StringEncoding,
        NSWindowsCP1251StringEncoding, NSWindowsCP1252StringEncoding, NSWindowsCP1253StringEncoding,
        NSWindowsCP1254StringEncoding, NSWindowsCP1250StringEncoding, NSISO2022JPStringEncoding,
        NSASCIIStringEncoding};

    for(int i = 0; i < items; i++) {
        retString = [NSString stringWithData:self encoding:encodings[i]];
        if([retString length] > 0)
            return retString;
        
    }
    
    @throw [NSException exceptionWithName:@"GPGUnknownStringEncodingException" 
                                   reason:@"It was not possible to recognize the string encoding." userInfo:nil];
}

- (NSRange)rangeOfPGPInlineSignatures  {
    NSRange range = NSMakeRange(NSNotFound, 0);
    // Use the regular expression to ignore all signatures contained in a reply.
    NSString *signatureRegex = [NSString stringWithFormat:@"(?sm)(^%@\r?\n(.*)\r?\n%@)", PGP_SIGNED_MESSAGE_BEGIN, PGP_MESSAGE_SIGNATURE_END];
    
    NSString *signedContent = [self stringByGuessingEncoding];
    if([signedContent length] == 0)
        return range;
    
    NSRange signedRange = NSMakeRange(NSNotFound, 0);
    @try {
         signedRange = [signedContent rangeOfRegex:signatureRegex inRange:NSMakeRange(0, [signedContent length]) capture:0];
    }
    @catch(id e) {
        // Fail gracefully, if for example binary data is detected.
    }
    
    if(signedRange.location == NSNotFound)
        return range;
    
    return signedRange;
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
    
    NSRange range = NSMakeRange(NSNotFound, 0);
    // Use the regular expression to ignore all signatures contained in a reply.
    NSString *encryptedRegex = [NSString stringWithFormat:@"(?sm)(^%@\r?\n(.*)\r?\n%@)", PGP_MESSAGE_BEGIN, PGP_MESSAGE_END];
    
    NSRange encryptedRange = NSMakeRange(NSNotFound, 0);
    @try {
        encryptedRange = [body rangeOfRegex:encryptedRegex inRange:NSMakeRange(0, [body length]) capture:0];
    }
    @catch(id e) {
        // Fail gracefully, if for example binary data is detected.
    }
    
    if(encryptedRange.location == NSNotFound)
        return range;
    
    return encryptedRange;
    
    
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

- (BOOL)mightContainPGPEncryptedDataOrSignatures {
    NSString *body = [self stringByGuessingEncoding];
    NSRange nextRange;
    nextRange.location = 0;
    nextRange.length = [body length];
    // If the encoding can't be guessed, the body will probably be empty,
    // so let's get out of here.!
    if(!nextRange.length) 
        return NO;

    while (true) {
        NSRange matchRange = [body rangeOfString:PGP_BEGIN_PGP_PREFIX
                                         options:NSLiteralSearch range:nextRange];
        if(matchRange.location == NSNotFound)
            return NO;
        
        nextRange.location = matchRange.location + [PGP_BEGIN_PGP_PREFIX length];
        nextRange.length = [body length] - nextRange.location;
        NSString *footerMatch;
        
        // Detect "MESSAGE" or "SIGNATURE" in prefix and set suffix
        matchRange = [body rangeOfString:PGP_MESSAGE_PREFIX_TAIL 
                                 options:NSAnchoredSearch range:nextRange];
        if (matchRange.location != NSNotFound) {
            footerMatch = PGP_MESSAGE_END;
            nextRange.location += [PGP_MESSAGE_PREFIX_TAIL length];
            nextRange.length = [body length] - nextRange.location;
        }
        else if ((matchRange = [body rangeOfString:PGP_SIGNATURE_PREFIX_TAIL 
                                           options:NSAnchoredSearch 
                                             range:nextRange]).location != NSNotFound) {
            footerMatch = PGP_MESSAGE_SIGNATURE_END;
            nextRange.location += [PGP_SIGNATURE_PREFIX_TAIL length];
            nextRange.length = [body length] - nextRange.location;
        }
        else {
            continue;
        }

        matchRange = [body rangeOfString:footerMatch options:NSLiteralSearch range:nextRange];
        if (matchRange.location != NSNotFound)
            return YES;
    }
    
    return NO;
}

- (NSRange)rangeOfPGPPublicKey {
    NSString *body = [self stringByGuessingEncoding];
    if(![body length])
        return NSMakeRange(NSNotFound, 0);

    NSRange startRange = [body rangeOfString:PGP_MESSAGE_PUBLIC_KEY_BEGIN];
    if(startRange.location == NSNotFound)
        return startRange;

    NSRange nextRange;
    nextRange.location = startRange.location + [PGP_MESSAGE_PUBLIC_KEY_BEGIN length];
    nextRange.length = [body length] - nextRange.location;
    NSRange endRange = [body rangeOfString:PGP_MESSAGE_PUBLIC_KEY_END 
                                   options:NSLiteralSearch 
                                     range:nextRange];
    if(endRange.location == NSNotFound)
        return endRange;
    
    return NSUnionRange(startRange, endRange);
}

@end
