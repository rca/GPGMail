/* GMMessageRulesApplier.m created by Lukas Pitschl (@lukele) on Fri 14-Jun-2013 */

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

#import "GMMessageRulesApplier.h"
#import "Message+GPGMail.h"
#import "MessageStore.h"

@interface GMMessageRulesApplier ()

@property (nonatomic, strong) NSMutableArray *messages;

@end

@implementation GMMessageRulesApplier

@synthesize messages = _messages;

- (id)init {
	if(self = [super init]) {
		_rulesQueue	= dispatch_queue_create("org.gpgmail.rules", NULL);;
		_messages	= [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)scheduleMessage:(Message *)message isEncrypted:(BOOL)isEncrypted {
	id messageID = [message messageID];
	typeof(self) __weak weakSelf = self;
	
	dispatch_async(_rulesQueue, ^{
		__strong typeof(self) strongSelf = weakSelf;
		if(![strongSelf.messages containsObject:messageID] || isEncrypted) {
			[strongSelf.messages addObject:messageID];
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[message dataSourceProxy] routeMessages:@[message] isUserAction:NO];
			});
		}
	});
}

- (void)dealloc {
	dispatch_release(_rulesQueue);
}

@end
