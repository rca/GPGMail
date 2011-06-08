/* MessageKeychainManager+GPGMail.m created by stephane on Wed 18-Feb-2004 */

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


#import "MessageKeychainManager+GPGMail.h"
#import "GPGMailBundle.h"
#import "GPGMailPatching.h"

static IMP MessageKeychainManager_canSignMessagesFromAddress = NULL;
static IMP MessageKeychainManager_canEncryptMessagesToAddress = NULL;

@implementation MFKeychainManager (GPGMail)

+ (void)load {
	MessageKeychainManager_canSignMessagesFromAddress = GPGMail_ReplaceImpOfClassSelectorOfClassWithImpOfClassSelectorOfClass(@selector(canSignMessagesFromAddress:), self, @selector(gpgCanSignMessagesFromAddress:), self);
	MessageKeychainManager_canEncryptMessagesToAddress = GPGMail_ReplaceImpOfClassSelectorOfClassWithImpOfClassSelectorOfClass(@selector(canEncryptMessagesToAddress:), self, @selector(gpgCanEncryptMessagesToAddress:), self);
}

+ (char)gpgCanSignMessagesFromAddress:(id)fp8 {
	if ([[GPGMailBundle sharedInstance] disablesSMIME]) {
		return NO;
	} else {
		return ((char (*)(id, SEL, id))MessageKeychainManager_canSignMessagesFromAddress)(self, _cmd, fp8);
	}
}

+ (char)gpgCanEncryptMessagesToAddress:(id)fp8 {
	if ([[GPGMailBundle sharedInstance] disablesSMIME]) {
		return NO;
	} else {
		return ((char (*)(id, SEL, id))MessageKeychainManager_canEncryptMessagesToAddress)(self, _cmd, fp8);
	}
}

@end
