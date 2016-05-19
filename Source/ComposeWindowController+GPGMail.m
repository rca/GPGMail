/* ComposeWindowController+GPGMail.m created by Lukas Pitschl on Tue 22-09-2015 */

/*
 * Copyright (c) 2000-2015, GPGTools <team@gpgtools.org>
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
 * THIS SOFTWARE IS PROVIDED BY THE GPGTools ``AS IS'' AND ANY
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

#import "NSObject+LPDynamicIvars.h"
#import "GMSecurityMethodAccessoryView.h"
#import "ComposeWindowController+GPGMail.h"

@implementation ComposeWindowController_GPGMail

- (id)MAToolbarDefaultItemIdentifiers:(id)toolbar {
	id defaultItemIdentifiers = [self MAToolbarDefaultItemIdentifiers:toolbar];
	
	// Appending the security method identifier to toggle between OpenPGP and S/MIME.
	NSMutableArray *identifiers = [defaultItemIdentifiers mutableCopy];
	[identifiers addObject:@"toggleSecurityMethod:"];
	
	return identifiers;
}

- (id)MAToolbar:(id)toolbar itemForItemIdentifier:(id)itemIdentifier willBeInsertedIntoToolbar:(BOOL)willBeInsertedIntoToolbar {
	if(![itemIdentifier isEqualToString:@"toggleSecurityMethod:"]) {
		return [self MAToolbar:toolbar itemForItemIdentifier:itemIdentifier willBeInsertedIntoToolbar:willBeInsertedIntoToolbar];
	}
	
	// Make sure our toolbar item was not already added.
	for(NSToolbarItem *item in [toolbar items]) {
		if([item.itemIdentifier isEqualToString:itemIdentifier])
			return nil;
	}
	
	// The delegate of GMSecurityMethodAccessoryView will be the current composeViewController.
	// At this point it's however not yet set on the ComposeWindowController, so once the
	// compose view controller is ready, it will set if self up as delegate.
	GMSecurityMethodAccessoryView *securityMethodAccessoryView = [[GMSecurityMethodAccessoryView alloc] initWithStyle:GMSecurityMethodAccessoryViewStyleToolbarItem];
	[self setIvar:@"SecurityMethodAccessoryView" value:securityMethodAccessoryView];
	
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	[item setView:securityMethodAccessoryView];
	[item setMinSize:NSMakeSize(75, 23)];
	[item setTarget:nil];
	
	return item;
}

- (void)MA_performSendAnimation {
	// Store the the current frame position, to restore it in case of an error.
	NSPoint currentOrigin = [(id)self window].frame.origin;
	[self setIvar:@"WindowFrameOriginBeforeAnimation" value:@{@"X": @(currentOrigin.x), @"Y": @(currentOrigin.y)}];
	[self MA_performSendAnimation];
	return;
}

- (void)restorePositionBeforeAnimation {
	NSDictionary *originBeforeAnimation = [self getIvar:@"WindowFrameOriginBeforeAnimation"];
	if(!originBeforeAnimation)
		return;
	[self removeIvar:@"WindowFrameOriginBeforeAnimation"];
	[[(id)self window] setFrameOrigin:NSMakePoint([originBeforeAnimation[@"X"] floatValue], [originBeforeAnimation[@"Y"] floatValue])];
	[[(id)self window] makeKeyAndOrderFront:0];
	return;
}

- (void)MA_tabBarView:(id)tabBarView performSendAnimationOfTabBarViewItem:(id)tabBarViewItem {
	// This is ugly as fuck, but for the time being it has to do.
	// We simply don't do anything with the tabBarViewItem or the view controller, since we might still need it
	// and only run the animations.
	// After we receive confirmation that the email has in fact been send with success, we'll run this method.
	id viewController = [tabBarViewItem viewController];
	if([[viewController getIvar:@"GMAllowReleaseOfTabBarViewItem"] boolValue]) {
		[viewController removeIvar:@"GMAllowReleaseOfTabBarViewItem"];
		[self MA_tabBarView:tabBarView performSendAnimationOfTabBarViewItem:tabBarViewItem];
		return;
	}
	
	[[(id)self window] invalidateRestorableState];
	[self _performSendAnimation];
}

@end
