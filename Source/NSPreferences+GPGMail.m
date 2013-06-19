/* NSPreferences+GPGMail.m created by Lukas Pitschl (lukele) on Sat 20-Aug-2011 */

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

/*
 * Credit for the re-inserting toolbar code when preference pane is restored
 * no re-opened (Lion restore feature) goes to Adam Nohejl.
 *
 * http://nohejl.name/2011/07/21/mail-preferences-modules-in-mac-os-x-10-7/
 */

#import "CCLog.h"
#import "NSObject+LPDynamicIvars.h"
#import <NSPreferences.h>
#import <NSPreferencesModule.h>
#import "NSPreferences+GPGMail.h"
#import "GPGMailPreferences.h"
#import "GPGMailBundle.h"

@implementation NSPreferences (GPGMail)

+ (id)MASharedPreferences {
	static BOOL added = NO;
	
	id preferences = [self MASharedPreferences];
    
    if(preferences == nil)
        return nil;
    
    if(added)
        return preferences;
    
    // Check modules, if GPGMailPreferences is not yet in there.
    NSPreferencesModule *gpgMailPreferences = [GPGMailPreferences sharedInstance];
    NSString *preferencesName = GMLocalizedString(@"PGP_PREFERENCES");
    [preferences addPreferenceNamed:preferencesName owner:gpgMailPreferences];
    added = YES;
	
    NSWindow *preferencesPanel = [preferences valueForKey:@"_preferencesPanel"];
    NSToolbar *toolbar = [preferencesPanel toolbar];
    // If the toolbar is nil, the setup will be done later by Mail.app.
    if(!toolbar)
        return preferences;
    
    BOOL gpgMailPreferencesToolbarExists = NO;
    // Mail Preferences is not able to restore to the GPGMail preference module
    // if it was last open.
    // That's why GPGMail saves the information of the last open one and restores it
    // on its own.
    NSToolbarItem *lastSelectedItem = nil;
    NSString *lastSelectedItemIdentifier = [[GPGOptions sharedOptions] valueForKey:@"MailPreferencesLastSelectedToolbarItem"];
    int i = 0;
    for(id item in [toolbar items]) {
        if((!lastSelectedItemIdentifier && i == 0) || [lastSelectedItemIdentifier isEqualToString:[item itemIdentifier]])
            lastSelectedItem = item;
        
        if([[item itemIdentifier] isEqualToString:preferencesName]) {
            gpgMailPreferencesToolbarExists = YES;
            break;
        }
        i++;
    }
    
    // If the GPGMail Preference toolbar item doesn't exist,
    // add it.
    if(!gpgMailPreferencesToolbarExists)
        [toolbar insertItemWithItemIdentifier:preferencesName atIndex:[[toolbar items] count]];
    
    // Make sure the preferences window shows all toolbar items.
    [preferences setIvar:@"makeAllToolbarItemsVisible" value:@YES];
    // If the preference window wasn't closed before Mail.app was shutdown
    // and the last preference module to be shown was GPGMail,
    // Mail.app doesn't show it automatically after restarting and restoring
    // the preference pane window.
    // In case of GPGMail being the last item, it's not in the toolbar yet
    // since it was just recently added. Use _selectModuleOwner to select it.
    if(!lastSelectedItem && [lastSelectedItemIdentifier isEqualToString:preferencesName]) {
        NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:preferencesName];
        [preferences toolbarItemClicked:toolbarItem];
    }
    else
        [preferences toolbarItemClicked:lastSelectedItem];
    // Force resizing of the window so that all toolbar items fit.
    [preferences resizeWindowToShowAllToolbarItems:preferencesPanel];
    
    return preferences;
}


- (NSSize)sizeForWindowShowingAllToolbarItems:(NSWindow *)window {
    NSRect frame = [window frame];
    float width = 0.0f;
	NSArray *subviews = [[[[window toolbar] valueForKey:@"_toolbarView"] subviews][0] subviews];
    for (NSView *view in subviews) {
        width += view.frame.size.width;
	}
    // Add padding to fit them all.
    width += 10;
    return NSMakeSize(width > frame.size.width ? width : frame.size.width, frame.size.height);
}

- (NSSize)MAWindowWillResize:(id)window toSize:(NSSize)toSize {
    if(![[self getIvar:@"makeAllToolbarItemsVisible"] boolValue])
        return [self MAWindowWillResize:window toSize:toSize];
    
    NSSize newSize = [self sizeForWindowShowingAllToolbarItems:window];
    [self removeIvar:@"makeAllToolbarItemsVisible"];
    return newSize;
}

- (void)resizeWindowToShowAllToolbarItems:(NSWindow *)window {
    NSRect frame = [window frame];
    frame.size = [self sizeForWindowShowingAllToolbarItems:window];
    [self setIvar:@"makeAllToolbarItemsVisible" value:@YES];
    [window setFrame:frame display:YES];
}

- (void)MAToolbarItemClicked:(id)toolbarItem {
    // Resize the window, otherwise it would make it small
    // again.
    [[GPGOptions sharedOptions] setValue:[toolbarItem itemIdentifier] forKey:@"MailPreferencesLastSelectedToolbarItem"];
    [self MAToolbarItemClicked:toolbarItem];
    [self resizeWindowToShowAllToolbarItems:[self valueForKey:@"_preferencesPanel"]];
}

- (void)MAShowPreferencesPanelForOwner:(id)owner {
    [self MAShowPreferencesPanelForOwner:owner];
    [self resizeWindowToShowAllToolbarItems:[self valueForKey:@"_preferencesPanel"]];
}

@end
