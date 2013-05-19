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
 * THIS SOFTWARE IS PROVIDED BY GPGTools Project Team AND CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL GPGTools Project Team AND CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Message.h>
#import <MimeBody.h>
#import <MessageContentController.h>
#import "CCLog.h"
#import "NSObject+LPDynamicIvars.h"
#import "MimePart+GPGMail.h"
#import "Message+GPGMail.h"
#import "GPGMailBundle.h"
#import "ActivityMonitor.h"
#import "BannerController.h"
#import "MessageContentController+GPGMail.h"

@implementation MessageContentController_GPGMail : NSObject

- (void)decryptPGPMessage {
    [[((MessageContentController *)self) message] setIvar:@"shouldBeDecrypting" value:[NSNumber numberWithBool:YES]];
    [((MessageContentController *)self) reloadCurrentMessageShouldReparseBody:YES];
}

- (void)MASetMessageToDisplay:(id)message {
    [message setIvar:@"UserSelectedMessage" value:[NSNumber numberWithBool:YES]];
    [self MASetMessageToDisplay:message];
}

- (void)MA_backgroundLoadFinished:(MessageViewingState *)messageViewingState {
    [self MA_backgroundLoadFinished:messageViewingState];
    BOOL showBanner = ((MessageContentController *)self).message.shouldShowErrorBanner;
    
    if(((MessageContentController *)self).message && showBanner)
        [(BannerController *)[self valueForKey:@"_bannerController"] _showCertificateBanner];
}

@end
