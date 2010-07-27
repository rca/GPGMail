/* NSString+GPGMail.m created by dave on Mon 29-Oct-2001 */

/*
 * Copyright (c) 2000-2010, GPGMail Project Team <gpgmail-devel@lists.gpgmail.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGMail Project Team nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGMAIL PROJECT TEAM ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGMAIL PROJECT TEAM BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSString+GPGMail.h"
#import "GPGMailBundle.h"
#import <NSString+Message.h>

#import <Foundation/Foundation.h>


@implementation NSString(GPGMail)

+ (NSStringEncoding) gpgEncodingForMIMECharset:(NSString *)charset
{
#warning Should no longer be needed...
    CFStringEncoding	cfEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)charset);
    NSStringEncoding	nsEncoding;
    
    NSAssert1(cfEncoding != kCFStringEncodingInvalidId, @"### GPGMail: unknown charset %@", charset);
    nsEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
    NSAssert1(cfEncoding != kCFStringEncodingInvalidId, @"### GPGMail: unable to convert CoreFoundation charset %@ to Foundation's", charset);
    return nsEncoding;
}

+ (NSString *) gpgMIMECharsetForEncoding:(NSStringEncoding)encoding
{
#warning Should no longer be needed...
    CFStringEncoding	cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);
    
    NSAssert1(cfEncoding != kCFStringEncodingInvalidId, @"### GPGMail: unable to convert Foundation encoding %u to CoreFoundation's", encoding);
    return (NSString *)CFStringConvertEncodingToIANACharSetName(cfEncoding);
}

- (NSString *) gpgNormalizedEmail
{
    return [[self lowercaseString] uncommentedAddress];
}

@end
