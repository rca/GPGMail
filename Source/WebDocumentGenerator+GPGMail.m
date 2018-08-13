/* CertificateBannerViewController+GPGMail.m created by Lukas Pitschl (@lukele) on Thu 17-Oct-2013 */

/*
 * Copyright (c) 2000-2013, GPGTools Team <team@gpgtools.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGTools nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGTools Team ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGTools Team BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "WebDocumentGenerator+GPGMail.h"
#import "ConversationMember+GPGMail.h"
#import "MUIWebDocument.h"
#import "MCMessage.h"
#import "GPGMailBundle.h"
#import "ConversationMember+GPGMail.h"
#import "NSObject+LPDynamicIvars.h"

@implementation WebDocumentGenerator_GPGMail

- (void)MASetWebDocument:(MUIWebDocument *)webDocument {
	/* On Yosemite, the message selector no longer exists, but is encapsulated in a conversation member object. */
    MCMessage *message = nil;
    if([self respondsToSelector:@selector(message)])
        message = (MCMessage *)[(id)self message];
    else if([GPGMailBundle isYosemite]) {
        message = [(ConversationMember *)[(WebDocumentGenerator *)self valueForKey:@"_conversationMember"] originalMessage];
    }
    id error = [message getIvar:@"PGPMainError"];
	if(error)
		[webDocument setParseError:error];
	[self MASetWebDocument:webDocument];
}

@end
