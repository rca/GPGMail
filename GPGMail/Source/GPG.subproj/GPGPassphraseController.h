/* GPGPassphraseController.h created by stephane on Fri 30-Jun-2000 */

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

#import <AppKit/AppKit.h>


@interface GPGPassphraseController : NSObject
{
	IBOutlet NSPanel *panel;
	IBOutlet NSTextField *passphraseTextField;
	IBOutlet NSTextField *messageTextField;
	IBOutlet NSTextField *titleTextField;
	IBOutlet NSTextField *clearPassphraseTextField;
	IBOutlet NSButton *passphraseCheckBox;
	IBOutlet NSTabView *passphraseTabView;
	BOOL isInUse;
	NSConditionLock *lock;
}

+ (id)controller;
// Each call can return a different instance

- (NSString *)passphraseForUser:(id) user title:(NSString *)title window:(NSWindow *)parentWindow;
// If result is nil, entry was cancelled.
// May return cached passphrase; not necessarily asks user for it.
// Automatically resets flush timer
// parentWindow is used only on MacOS X, for sheets
- (IBAction)endModal:(id)sender;
- (IBAction)toggleShowPassphrase:(id)sender;

+ (void)setCachesPassphrases:(BOOL)flag;
+ (BOOL)cachesPassphrases;
+ (void)flushCachedPassphrases;
+ (void)flushCachedPassphraseForUser:(id)user;

@end
