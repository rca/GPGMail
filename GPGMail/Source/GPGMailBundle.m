/* GPGMailBundle.m created by dave on Thu 29-Jun-2000 */

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

#import "GPGMailBundle.h"
#import "MessageContentController+GPGMail.h"
#import "MessageViewer+GPGMail.h"
#import "MessageBody+GPGMail.h"
#import "Message+GPGMail.h"
#import "GPGMailPatching.h"

#import <Message.h>
#import <MessageHeaders.h>
#import <MessageBody.h>
#import <MailToolbarItem.h>

#import "MessageEditor+GPGMail.h"
#import "GPG.subproj/GPGPassphraseController.h"
#import "GPG.subproj/GPGProgressIndicatorController.h"
#import "GPGMailPreferences.h"
#import "TableViewManager+GPGMail.h"
#import "GPGKeyDownload.h"

#import <ExceptionHandling/NSExceptionHandler.h>
#import <AppKit/AppKit.h>
#include <mach-o/dyld.h>

#include <Sparkle/Sparkle.h>

#import "GPGDefaults.h"

#import "MVMailBundle.h"


// The following strings are used as toolbarItem identifiers and userDefault keys (value is the position index)
NSString	*GPGAuthenticateMessageToolbarItemIdentifier = @"GPGAuthenticateMessageToolbarItem";
NSString	*GPGDecryptMessageToolbarItemIdentifier = @"GPGDecryptMessageToolbarItem";
NSString	*GPGSignMessageToolbarItemIdentifier = @"GPGGPGSignMessageToolbarItemIdentifier";
NSString	*GPGEncryptMessageToolbarItemIdentifier = @"GPGEncryptMessageToolbarItem";

NSString	*GPGKeyListWasInvalidatedNotification = @"GPGKeyListWasInvalidatedNotification";
NSString	*GPGPreferencesDidChangeNotification = @"GPGPreferencesDidChangeNotification";
NSString	*GPGKeyGroupsChangedNotification = @"GPGKeyGroupsChangedNotification";
NSString	*GPGMissingKeysNotification = @"GPGMissingKeysNotification";

NSString	*GPGMailException = @"GPGMailException";



int  GPGMailLoggingLevel = 1;


static BOOL	gpgMailWorks = YES;

@interface NSObject(GPGMailBundle)
// Service implemented by Mail.app
- (void) mailTo:(NSPasteboard *)pasteboard userData:(NSString *)userData error:(NSString **)error;
@end

@interface NSApplication(GPGMailBundle_Revealed)
- (NSArray *) messageEditors;
@end

@interface GPGEngine(GPGMailBundle_Revealed)
- (NSString *) debugDescription;
@end

// If we use bodyWasDecoded:forMessage:, other bundles, like SWUrlification, may
// not have the possibility to modify the body (replacing smileys/URLs with icons)
// If we use bodyWillBeDecoded:forMessage:, we have other problems:
// Problems: called when rebuilding mbox, in another thread => exceptions...
// When new mail is sent, also called in another thread. If we do nothing here, mail is NOT encoded too...
// Plus, decrypted will be indexed.


@interface GPGMailBundle(Private)
- (void) refreshPersonalKeysMenu;
- (void) refreshPublicKeysMenu;
- (void) flushKeyCache:(BOOL)flag;
@end

#include <objc/objc.h>
#include <objc/objc-class.h>
@implementation GPGMailBundle


+ (void)load
{
    GPGMailLoggingLevel = [[GPGDefaults standardDefaults] integerForKey:@"GPGMailDebug"];
    [[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask: NSLogOtherExceptionMask | NSLogTopLevelExceptionMask];
}

+ (void)addSnowLeopardCompatibility
{
    NSLog(@"Adding Snow Leopard Compatibility");
    
    /* Adding methods for ComposeBackEnd. */
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_ComposeBackEnd") toClass:NSClassFromString(@"ComposeBackEnd")];
    
    /* Adding methods for HeadersEditor. */
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_HeadersEditor") toClass:NSClassFromString(@"HeadersEditor")];
    /* Adding methods for MailDocumentEditor. */
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_MailDocumentEditor") toClass:NSClassFromString(@"MailDocumentEditor")];
    
    /* Add Methods from GPGMail Message Viewer to Message Viewer. */
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_MessageViewer") toClass:NSClassFromString(@"MessageViewer")];
    
    /* Add methods of GPGMail Message Content Controller to Message Content Controller. */
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_MessageContentController") toClass:NSClassFromString(@"MessageContentController")];
    
    /* Swizzling method for the contextual menu of the table view manager. */
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_TableViewManager") toClass:NSClassFromString(@"TableViewManager")];

    /* Emulate categories for MailTextAttachment. */
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_MailTextAttachment") toClass:NSClassFromString(@"MailTextAttachment")];
}

+ (void) initialize {
    static BOOL initialized = NO;
    if (initialized) {
        return;
    }
    initialized = YES;
    
    
    if(class_getSuperclass([self class]) != NSClassFromString(@"MVMailBundle")) {
        [super initialize];
        
        Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
        if(mvMailBundleClass)
            class_setSuperclass([self class], mvMailBundleClass);
        
        [GPGMailBundle addSnowLeopardCompatibility];
    }
	NSBundle *myBundle = [NSBundle bundleForClass:self];
	
    // Do not call super - see +initialize documentation
       

    
	// We need to load images and name them, because all images are searched by their name; as they are not located in the main bundle,
	// +[NSImage imageNamed:] does not find them.
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"encrypted"]] setName:@"gpgEncrypted"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"clear"]] setName:@"gpgClear"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"signed"]] setName:@"gpgSigned"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"unsigned"]] setName:@"gpgUnsigned"];

	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"GPGMail"]] setName:@"GPGMail"];
    [(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"MacGPG"]] setName:@"MacGPG"];
    [(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"GPGMail32"]] setName:@"GPGMail32"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"GPGMailPreferences"]] setName:@"GPGMailPreferences"];

    [(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"questionMark"]] setName:@"gpgQuestionMark"];
    [(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"SmallAlert12"]] setName:@"gpgSmallAlert12"];
    [(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"SmallAlert16"]] setName:@"gpgSmallAlert16"];
    [(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"EmptyImage"]] setName:@"gpgEmptyImage"];
    [(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"ValidBadge"]] setName:@"gpgValidBadge"];
    [(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"InvalidBadge"]] setName:@"gpgInvalidBadge"];
    
	// Do NOT release images!
    
    
    [self registerBundle]; // To force registering composeAccessoryView and preferences
    
    NSLog(@"Loaded GPGMail %@", [(GPGMailBundle *)[self sharedInstance] version]);

    SUUpdater *updater = [SUUpdater updaterForBundle:[NSBundle bundleForClass:[self class]]];
    updater.delegate = [self sharedInstance];
    //[updater setAutomaticallyChecksForUpdates:YES];
    [updater resetUpdateCycle];
#warning Sparkle should automatically start to check, but sometimes doesn't.
}

- (NSString *)pathToRelaunchForUpdater:(SUUpdater *)updater {
    return @"/Applications/Mail.app";
}

+ (BOOL) hasPreferencesPanel
{
    return gpgMailWorks; // LEOPARD Invoked on +initialize. Else, invoked from +registerBundle
}

+ (NSString *) preferencesOwnerClassName
{
    return NSStringFromClass([GPGMailPreferences class]);
}

+ (NSString *) preferencesPanelName
{
    return NSLocalizedStringFromTableInBundle(@"PGP_PREFERENCES", @"GPGMail", [NSBundle bundleForClass:self], "PGP preferences panel name");
}

+ (BOOL) gpgMailWorks
{
    return gpgMailWorks;
}

- (BOOL) gpgMailWorks
{
    return gpgMailWorks;
}

- (NSMenuItem *) newMenuItemWithTitle:(NSString *)title action:(SEL)action andKeyEquivalent:(NSString *)keyEquivalent inMenu:(NSMenu *)menu relativeToItemWithSelector:(SEL)selector offset:(int)offset
// Taken from /System/Developer/Examples/EnterpriseObjects/AppKit/ModelerBundle/EOUtil.m
{
   // Simple utility category which adds a new menu item with title, action
   // and keyEquivalent to menu (or one of its submenus) under that item with
   // selector as its action.  Returns the new addition or nil if no such 
   // item could be found.

    NSMenuItem  *menuItem;
    NSArray     *items = [menu itemArray];
    int         iI;
   
    if(!keyEquivalent)
        keyEquivalent = @"";
   
    for(iI = 0; iI < [items count]; iI++){
        menuItem = [items objectAtIndex:iI];

        if([menuItem action] == selector)
            return ([menu insertItemWithTitle:title action:action keyEquivalent:keyEquivalent atIndex:iI + offset]);
        else if([[menuItem target] isKindOfClass:[NSMenu class]]){
            menuItem = [self newMenuItemWithTitle:title action:action andKeyEquivalent:keyEquivalent inMenu:[menuItem target] relativeToItemWithSelector:selector offset:offset];
            if(menuItem)
                return menuItem;
        }
    }   

    return nil;
}

- (void) setPGPMenu:(NSMenu *)pgpMenu
{
    if(gpgMailWorks){
        pgpMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"PGP_MENU", @"GPGMail", [NSBundle bundleForClass:[self class]], "<PGP> submenu title") action:NULL andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:@selector(addSenderToAddressBook:) offset:1];

        if(!pgpMenuItem)
            NSLog(@"### GPGMail: unable to add submenu <PGP>");
        else{
            [[pgpMenuItem menu] insertItem:[NSMenuItem separatorItem] atIndex:[[pgpMenuItem menu] indexOfItem:pgpMenuItem]];
            [[pgpMenuItem menu] setSubmenu:pgpMenu forItem:pgpMenuItem];
            [encryptsNewMessageMenuItem setState:NSOffState];
            [signsNewMessageMenuItem setState:([self alwaysSignMessages] ? NSOnState:NSOffState)];
            [pgpMenuItem retain];
            [self refreshPersonalKeysMenu];
            [self refreshPublicKeysMenu];
#warning CHECK: keys not synced with current editor?
        }
    }
}

- (void) refreshKeyIdentifiersDisplayInMenu:(NSMenu *)menu
{
    NSArray			*displayedKeyIdentifiers = [self displayedKeyIdentifiers];
    NSEnumerator	*anEnum = [[self allDisplayedKeyIdentifiers] objectEnumerator];
    NSString		*anIdentifier;
    int				i = 1;

    while(anIdentifier = [anEnum nextObject]){
        if(![displayedKeyIdentifiers containsObject:anIdentifier])
            [[menu itemWithTag:i] setState:NSOffState];
        else
            [[menu itemWithTag:i] setState:NSOnState];
        i++;
    }
}

- (void) setPGPViewMenu:(NSMenu *)pgpViewMenu
{
    if(gpgMailWorks){
		SEL	targetSelector;
		
		targetSelector = @selector(toggleThreadedMode:);
        pgpViewMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"PGP_KEYS_MENU", @"GPGMail", [NSBundle bundleForClass:[self class]], "<PGP Keys> submenu title") action:NULL andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:targetSelector offset:-1];

        if(!pgpViewMenuItem)
            NSLog(@"### GPGMail: unable to add submenu <PGP Keys>");
        else{
            NSMenu	*aMenu = [pgpViewMenuItem menu];
/*            int		anIndex = [aMenu indexOfItem:pgpViewMenuItem];

            [pgpViewMenuItem retain];
            while(--anIndex > 0)
                if([[aMenu itemAtIndex:anIndex] isSeparatorItem])
                    break;
            if(anIndex > 0){
                [aMenu removeItem:pgpViewMenuItem];
                [aMenu insertItem:pgpViewMenuItem atIndex:anIndex];
            }*/
            [aMenu setSubmenu:pgpViewMenu forItem:pgpViewMenuItem];

            [self refreshKeyIdentifiersDisplayInMenu:pgpViewMenu];
        }
    }
}

#pragma mark Toolbar stuff (+contextual menu)

- (id) realDelegateForToolbar:(NSToolbar *)toolbar
{
//#warning This won't work if other controller usurps delegate!
//    if([toolbar delegate] != self){
    if(![[toolbar delegate] isKindOfClass:NSClassFromString(@"MVMailBundle")]){
        [realToolbarDelegates removeObjectForKey:[NSValue valueWithNonretainedObject:toolbar]];
        return nil;
    }
    else
        return [[realToolbarDelegates objectForKey:[NSValue valueWithNonretainedObject:toolbar]] nonretainedObjectValue];
}

- (void) addAdditionalContextualMenuItemsToMessageViewer:(MessageViewer *)viewer
{
    NSMenu      *menu = [[viewer gpgTableManager] gpgContextualMenu];
    NSMenu      *pgpMenu = [[self encryptsNewMessageMenuItem] menu];
    NSMenuItem  *newMenuItem;

    // We need to take care of not adding items more than once!
    // WARNING Hardcoded dependency on menu item order in PGP menu
    newMenuItem = [pgpMenu itemAtIndex:0];
    if([menu indexOfItemWithTitle:[newMenuItem title]] == -1){
        newMenuItem = [NSMenuItem separatorItem];
        [menu addItem:newMenuItem];
        newMenuItem = [[pgpMenu itemAtIndex:0] copyWithZone:[menu zone]];
        [newMenuItem setKeyEquivalent:@""];
        [menu addItem:newMenuItem];
        [newMenuItem release];
        newMenuItem = [[pgpMenu itemAtIndex:1] copyWithZone:[menu zone]];
        [newMenuItem setKeyEquivalent:@""];
        [menu addItem:newMenuItem];
        [newMenuItem release];
    }
}

- (id) usurpToolbarDelegate:(NSToolbar *)toolbar
{
	NSArray	*additionalIdentifiers = [additionalToolbarItemIdentifiersPerToolbarIdentifier objectForKey:[toolbar identifier]];
    id		realDelegate = [toolbar delegate];
    
    if(realDelegate == nil){
        NSLog(@"### GPGMail: toolbar %@ has no delegate!", [toolbar identifier]);
        return nil;
    }
    
	if(additionalIdentifiers != nil && [additionalIdentifiers count] > 0){        
        if([realDelegate isKindOfClass:NSClassFromString(@"MessageViewer")])
            [self addAdditionalContextualMenuItemsToMessageViewer:realDelegate];
        // In case other bundles usurp delegation too, they probably do it my way ;-)
        else if([realDelegate respondsToSelector:@selector(realDelegateForToolbar:)]){
            id	usurpedDelegate = [realDelegate realDelegateForToolbar:toolbar];
            if([usurpedDelegate isKindOfClass:NSClassFromString(@"MessageViewer")])            
                [self addAdditionalContextualMenuItemsToMessageViewer:usurpedDelegate];
        }
        [realToolbarDelegates setObject:[NSValue valueWithNonretainedObject:realDelegate] forKey:[NSValue valueWithNonretainedObject:toolbar]];
        [toolbar setDelegate:self];

        return realDelegate;
    }
    else
        // No usurpation if no item added...
        return nil;
}

- (NSToolbarItem *) createToolbarItemWithItemIdentifier:(NSString *)itemIdentifier label:(NSString *)label altLabel:(NSString *)altLabel paletteLabel:(NSString *)paletteLabel tooltip:(NSString *)tooltip target:(id)target action:(SEL)action imageNamed:(NSString *)imageName forToolbar:(NSToolbar *)toolbar
{
    NSBundle				*myBundle = [NSBundle bundleForClass:[self class]];
    SegmentedToolbarItem	*anItem = [[NSClassFromString(@"SegmentedToolbarItem") alloc] initWithItemIdentifier:itemIdentifier];
	// By default has already one segment - no need to create it
	[[[anItem subitems] objectAtIndex:0] setImage:[NSImage imageNamed:imageName]];
	[anItem setLabel:NSLocalizedStringFromTableInBundle(label, @"GPGMail", myBundle, "") forSegment:0];
	[anItem setAlternateLabel:NSLocalizedStringFromTableInBundle(altLabel, @"GPGMail", myBundle, "") forSegment:0];
	[anItem setPaletteLabel:NSLocalizedStringFromTableInBundle(paletteLabel, @"GPGMail", myBundle, "") forSegment:0];
	[anItem setToolTip:NSLocalizedStringFromTableInBundle(tooltip, @"GPGMail", myBundle, "") forSegment:0];
	[anItem setTag:-1 forSegment:0];
	[anItem setTarget:target forSegment:0];
	[anItem setAction:action forSegment:0];

    return [anItem autorelease];
}

- (BOOL) itemForItemIdentifier:(NSString *)itemIdentifier alreadyInToolbar:(NSToolbar *)toolbar
{
    NSEnumerator	*anEnum = [[toolbar items] objectEnumerator];
    NSToolbarItem	*anItem;
    
    while(anItem = [anEnum nextObject])
        if([[anItem itemIdentifier] isEqualToString:itemIdentifier] && ![anItem allowsDuplicatesInToolbar])
            return YES;
    return NO;
}

- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	// IMPORTANT: we need to give, as altLabel, the largest label we can have!
    if([itemIdentifier isEqualToString:GPGDecryptMessageToolbarItemIdentifier])
        return [self createToolbarItemWithItemIdentifier:itemIdentifier label:@"DECRYPT_ITEM" altLabel:@"" paletteLabel:@"DECRYPT_ITEM" tooltip:@"DECRYPT_ITEM_TOOLTIP" target:self action:@selector(gpgDecrypt:) imageNamed:@"gpgClear" forToolbar:toolbar];
    else if([itemIdentifier isEqualToString:GPGAuthenticateMessageToolbarItemIdentifier])
        return [self createToolbarItemWithItemIdentifier:itemIdentifier label:@"AUTHENTICATE_ITEM" altLabel:@"" paletteLabel:@"AUTHENTICATE_ITEM" tooltip:@"AUTHENTICATE_ITEM_TOOLTIP" target:self action:@selector(gpgAuthenticate:) imageNamed:@"gpgSigned" forToolbar:toolbar];
    else if([itemIdentifier isEqualToString:GPGEncryptMessageToolbarItemIdentifier]){
        // (We cannot use responder chain mechanism, because MessageEditor class does not cooperate...)
        NSToolbarItem	*newItem;
        
        if([self buttonsShowState])
            newItem = [self createToolbarItemWithItemIdentifier:itemIdentifier label:@"ENCRYPTED_ITEM" altLabel:@"CLEAR_ITEM" paletteLabel:@"ENCRYPTED_ITEM" tooltip:@"ENCRYPTED_ITEM_TOOLTIP" target:self action:@selector(gpgToggleEncryptionForNewMessage:) imageNamed:@"gpgEncrypted" forToolbar:toolbar]; // label, tooltip and image will be updated by GPGMailComposeAccessoryViewOwner
        else
            newItem = [self createToolbarItemWithItemIdentifier:itemIdentifier label:@"MAKE_ENCRYPTED_ITEM" altLabel:@"MAKE_CLEAR_ITEM" paletteLabel:@"MAKE_ENCRYPTED_ITEM" tooltip:@"MAKE_ENCRYPTED_ITEM_TOOLTIP" target:self action:@selector(gpgToggleEncryptionForNewMessage:) imageNamed:@"gpgClear" forToolbar:toolbar]; // label, tooltip and image will be updated by GPGMailComposeAccessoryViewOwner

        return newItem;
    }
    else if([itemIdentifier isEqualToString:GPGSignMessageToolbarItemIdentifier]){
        // (We cannot use responder chain mechanism, because MessageEditor class does not cooperate...)
        NSToolbarItem	*newItem;
        
        if([self buttonsShowState])
            newItem = [self createToolbarItemWithItemIdentifier:itemIdentifier label:@"SIGNED_ITEM" altLabel:@"UNSIGNED_ITEM" paletteLabel:@"SIGNED_ITEM" tooltip:@"SIGNED_ITEM_TOOLTIP" target:self action:@selector(gpgToggleSignatureForNewMessage:) imageNamed:@"gpgSigned" forToolbar:toolbar]; // label, tooltip and image will be updated by GPGMailComposeAccessoryViewOwner
        else
            newItem = [self createToolbarItemWithItemIdentifier:itemIdentifier label:@"MAKE_SIGNED_ITEM" altLabel:@"MAKE_UNSIGNED_ITEM" paletteLabel:@"MAKE_SIGNED_ITEM" tooltip:@"MAKE_SIGNED_ITEM_TOOLTIP" target:self action:@selector(gpgToggleSignatureForNewMessage:) imageNamed:@"gpgUnsigned" forToolbar:toolbar]; // label, tooltip and image will be updated by GPGMailComposeAccessoryViewOwner

        return newItem;
    }
    else
        return [[self realDelegateForToolbar:toolbar] toolbar:toolbar itemForItemIdentifier:itemIdentifier willBeInsertedIntoToolbar:flag];
}
    
- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [[self realDelegateForToolbar:toolbar] toolbarDefaultItemIdentifiers:toolbar];
}

- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    NSArray		*additionalIdentifiers = [additionalToolbarItemIdentifiersPerToolbarIdentifier objectForKey:[toolbar identifier]];

    if(additionalIdentifiers != nil){
        NSEnumerator	*anEnum = [additionalIdentifiers objectEnumerator];
        NSString		*anIdentifier;
        NSMutableArray	*identifiers = [NSMutableArray arrayWithArray:[[self realDelegateForToolbar:toolbar] toolbarAllowedItemIdentifiers:toolbar]];
        
        while(anIdentifier = [anEnum nextObject])
            [identifiers addObject:anIdentifier];
        return identifiers;
    }
    else
        return [[self realDelegateForToolbar:toolbar] toolbarAllowedItemIdentifiers:toolbar];
}

- (void) toolbarWillAddItem: (NSNotification *)notification notifyRealDelegate:(BOOL)notifyRealDelegate
{
    NSToolbar	*toolbar = [notification object];

    if(notifyRealDelegate){
        id	realDelegate = [self realDelegateForToolbar:toolbar];
        
        if([realDelegate respondsToSelector:@selector(toolbarWillAddItem:)])
            [realDelegate performSelector:@selector(toolbarWillAddItem:) withObject:notification];
    }
}

- (void) anyToolbarWillAddItem: (NSNotification *)notification
{
    NSToolbar	*toolbar = [notification object];
    id			realDelegate = [self realDelegateForToolbar:toolbar];
    
    if(realDelegate == nil){
        realDelegate = [self usurpToolbarDelegate:toolbar]; // Can fire notification!
        if(realDelegate != nil)
            [self toolbarWillAddItem:notification notifyRealDelegate:NO];
    }
}

- (void) toolbarWillAddItem: (NSNotification *)notification
{
    // Called automatically by toolbar we are the delegate of
	[self toolbarWillAddItem:notification notifyRealDelegate:YES];
}

- (void) toolbarDidRemoveItem: (NSNotification *)notification
{
    // Called automatically by toolbar we are the delegate of
    // Update userDefaults
    NSToolbar	*toolbar = [notification object];
    id			realDelegate = [self realDelegateForToolbar:toolbar];
    NSString	*itemIdentifier = [[[notification userInfo] objectForKey:@"item"] itemIdentifier];
    NSArray		*additionalIdentifiers = [additionalToolbarItemIdentifiersPerToolbarIdentifier objectForKey:[toolbar identifier]];

    NSRunAlertPanel(@"[toolbar identifier]", @"%@", nil, nil, nil, [toolbar identifier]);
    
    // WARNING: check whether it was a duplicate item!
	if([additionalIdentifiers containsObject:itemIdentifier])
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[itemIdentifier stringByAppendingFormat:@".%@", [toolbar identifier]]];
    if([realDelegate respondsToSelector:_cmd])
        [realDelegate performSelector:_cmd withObject:notification];
}

- (void) refreshPersonalKeysMenu
{
    GPGKey          *aKey;
    GPGKey          *theDefaultKey = [self defaultKey];
    NSMenu			*aSubmenu = [personalKeysMenuItem submenu];
    NSEnumerator	*anEnum = [[NSArray arrayWithArray:[aSubmenu itemArray]] objectEnumerator];
    NSMenuItem      *anItem;
    BOOL			displaysAllUserIDs = [self displaysAllUserIDs];
    
    while(anItem = [anEnum nextObject])
        [aSubmenu removeItem:anItem];
    
    anEnum = [[self personalKeys] objectEnumerator];
    while(aKey = [anEnum nextObject]){
        anItem = [aSubmenu addItemWithTitle:[self menuItemTitleForKey:aKey] action:@selector(gpgChoosePersonalKey:) keyEquivalent:@""];
        [anItem setRepresentedObject:aKey];
        [anItem setTarget:self];
        if(![self canKeyBeUsedForSigning:aKey])
            [anItem setEnabled:NO];
        if(theDefaultKey && [aKey isEqual:theDefaultKey])
            [anItem setState:NSOnState];
        // TODO: We should change the OnState image and use a dot
        if(displaysAllUserIDs){
            NSEnumerator	*userIDEnum = [[self secondaryUserIDsForKey:aKey] objectEnumerator];
            GPGUserID       *aUserID;

            while(aUserID = [userIDEnum nextObject]){
                anItem = [aSubmenu addItemWithTitle:[self menuItemTitleForUserID:aUserID indent:1] action:NULL keyEquivalent:@""];
                [anItem setEnabled:NO];
            }
        }
    }
}

- (void) refreshPublicKeysMenu
{
    NSMenu			*aSubmenu = [choosePublicKeysMenuItem menu];
    NSEnumerator	*anEnum = [[NSArray arrayWithArray:[aSubmenu itemArray]] objectEnumerator];
    NSMenuItem      *anItem;
    int				i;
    GPGKey          *theDefaultKey = [[self defaultKey] publicKey];

    for(i = 0; i < GPGENCRYPTION_MENU_ITEMS_COUNT; i++)
        [anEnum nextObject]; // Skip some items

    while(anItem = [anEnum nextObject]) {
        [aSubmenu removeItem:anItem];
    }
    
#warning Duplicated code!
    anEnum = [[self personalKeys] objectEnumerator]; // This is not an error to use personalKeys...
    if([self encryptsToSelf] && theDefaultKey){
        anItem = [aSubmenu addItemWithTitle:[self menuItemTitleForKey:theDefaultKey] action:NULL keyEquivalent:@""];
        if(![self canKeyBeUsedForEncryption:theDefaultKey])
            [anItem setEnabled:NO];
        
        if([self displaysAllUserIDs]){
            NSEnumerator	*userIDEnum = [[self secondaryUserIDsForKey:theDefaultKey] objectEnumerator];
            GPGUserID       *aUserID;

            while(aUserID = [userIDEnum nextObject]){
                anItem = [aSubmenu addItemWithTitle:[self menuItemTitleForUserID:aUserID indent:1] action:NULL keyEquivalent:@""];
                [anItem setEnabled:NO];
            }
        }
    }
}

- (void) checkPGPmailPresence
{
    if(![self ignoresPGPPresence]){
        if(NSClassFromString(@"PGPMailBundle") != Nil){
            NSBundle	*myBundle = [NSBundle bundleForClass:[self class]];
            NSString	*errorTitle = NSLocalizedStringFromTableInBundle(@"GPGMAIL_VS_PGPMAIL", @"GPGMail", myBundle, "");
            NSString	*errorMessage = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"GPGMAIL_%@_VS_PGPMAIL_%@", @"GPGMail", myBundle, ""), [myBundle bundlePath], [[NSBundle bundleForClass:NSClassFromString(@"PGPMailBundle")] bundlePath]];
            
            if(NSRunCriticalAlertPanel(errorTitle, @"%@", NSLocalizedStringFromTableInBundle(@"QUIT", @"GPGMail", myBundle, ""), NSLocalizedStringFromTableInBundle(@"CONTINUE_ANYWAY", @"GPGMail", myBundle, ""), nil, errorMessage) == NSAlertDefaultReturn)
                [[NSApplication sharedApplication] terminate:nil];
            else
                [self setIgnoresPGPPresence:YES];
        }
    }
}

- (GPGEngine *) engine
{
    if(engine == nil){
        BOOL    logging = (GPGMailLoggingLevel > 0);

        engine = [GPGEngine engineForProtocol:GPGOpenPGPProtocol];
        NSAssert(engine != nil, @"### gpgme has been configured without OpenPGP engine?!");
        [engine retain];
        if(logging)
            NSLog(@"[DEBUG] Engine: %@", [engine debugDescription]);
    }
    
    return engine;
}

- (BOOL) checkGPG
{
    NSString	*errorTitle = nil;
    GPGError	anError = GPGErrorNoError;
    NSBundle	*myBundle = [NSBundle bundleForClass:[self class]];
    GPGEngine   *anEngine = [self engine];
/*    NSArray     *availableExecutablePaths = [anEngine availableExecutablePaths];
    NSString    *chosenPath = nil;
    
    if(![anEngine usesCustomExecutablePath]){        
        if([availableExecutablePaths count] == 1){
            chosenPath = [availableExecutablePaths lastObject];
            @try{
                [[GPGEngine engineForProtocol:GPGOpenPGPProtocol] setExecutablePath:chosenPath];
            }@catch(NSException *localException){
                chosenPath = nil;
            }
        }
        else{
            // Give choice to user: either from availables, or custom, or cancel
        }
    }*/

    
    anError = [GPGEngine checkVersionForProtocol:GPGOpenPGPProtocol];    
    if(anError != GPGErrorNoError)
        errorTitle = [self gpgErrorDescription:anError];
    else{    
        // Now that engine executable path is configurable, we need to check it
        if([anEngine version] == nil)
            anError = GPGErrorInvalidEngine;
    }
    
    if(anError != GPGErrorNoError){
        NSString	*errorMessage = nil;
        
        if(GPGErrorInvalidEngine == [self gpgErrorCodeFromError:anError]){
            NSString    *currentVersion;
            NSString	*requiredVersion;
            NSString	*executablePath;

            requiredVersion = [anEngine requestedVersion];
            currentVersion = [anEngine version];
            executablePath = [anEngine executablePath];

            if(currentVersion == nil){
                errorMessage = NSLocalizedStringFromTableInBundle(@"GPGMAIL_CANNOT_WORK_MISSING_GPG_%@_VERSION_%@", @"GPGMail", myBundle, "");
                errorMessage = [NSString stringWithFormat:errorMessage, executablePath, requiredVersion];
            }
            else{
                errorMessage = NSLocalizedStringFromTableInBundle(@"GPGMAIL_CANNOT_WORK_HAS_GPG_%@_VERSION_%@_NEEDS_%@", @"GPGMail", myBundle, "");
                errorMessage = [NSString stringWithFormat:errorMessage, executablePath, currentVersion, requiredVersion];
            }
        }
        else
            errorMessage = NSLocalizedStringFromTableInBundle(@"GPGMAIL_CANNOT_WORK", @"GPGMail", myBundle, "");
        (void)NSRunCriticalAlertPanel(errorTitle, @"%@", nil, nil, nil, errorMessage);

        return NO;
    }
    else
        return YES;
}

- (BOOL) checkSystem
{
	BOOL	isCompatibleSystem;

#warning CHECK - change for leopard!
    isCompatibleSystem = (NSClassFromString(@"NSGarbageCollector") != Nil);
	
	if(!isCompatibleSystem){
        NSBundle	*aBundle = [NSBundle bundleForClass:[self class]];
		
        (void)NSRunCriticalAlertPanel(NSLocalizedStringFromTableInBundle(@"INVALID_GPGMAIL_VERSION", @"GPGMail", aBundle, "Alert panel title"), @"%@", nil, nil, nil, NSLocalizedStringFromTableInBundle(@"NEEDS_COMPATIBLE_BUNDLE_VERSION", @"GPGMail", aBundle, "Alert panel message"));
    }
    
    return isCompatibleSystem;
}

- (void)finishInitialization
{
    NSMenuItem  *aMenuItem;
    
    // There's a bug in MOX: added menu items are not enabled/disabled correctly
    // if they are instantiated programmatically
    NSAssert([NSBundle loadNibNamed:@"GPGMenu" owner:self], @"### GPGMail: -[GPGMailBundle init]: Unable to load nib named GPGMenu");
    // If we disable usurpation, we can't set contextual menu?!
    NSEnumerator	*anEnum = [[NSClassFromString(@"MessageViewer") allMessageViewers] objectEnumerator];    
    MessageViewer	*aViewer;

    realToolbarDelegates = [[NSMutableDictionary allocWithZone:[self zone]] init];
    additionalToolbarItemIdentifiersPerToolbarIdentifier = [[NSDictionary allocWithZone:[self zone]] initWithObjectsAndKeys:[NSArray arrayWithObjects:GPGDecryptMessageToolbarItemIdentifier, GPGAuthenticateMessageToolbarItemIdentifier, nil], @"MainWindow", [NSArray arrayWithObjects:GPGDecryptMessageToolbarItemIdentifier, GPGAuthenticateMessageToolbarItemIdentifier, nil], @"SingleMessageViewer", [NSArray arrayWithObjects:GPGEncryptMessageToolbarItemIdentifier, GPGSignMessageToolbarItemIdentifier, nil], @"ComposeWindow_NewMessage", [NSArray arrayWithObjects:GPGEncryptMessageToolbarItemIdentifier, GPGSignMessageToolbarItemIdentifier, nil], @"ComposeWindow_ReplyOrForward", nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anyToolbarWillAddItem:) name:NSToolbarWillAddItemNotification object:nil];
    // LEOPARD - list is always empty. If too early, then it's OK for us. No instance has yet been created, and we will do the work through -anyToolbarWillAddItem:
    while(aViewer = [anEnum nextObject])
        [self usurpToolbarDelegate:[aViewer gpgToolbar]];
    
    [GPGPassphraseController setCachesPassphrases:[self remembersPassphrasesDuringSession]];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceDidMount:) name:NSWorkspaceDidMountNotification object:[NSWorkspace sharedWorkspace]];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceDidUnmount:) name:NSWorkspaceDidUnmountNotification object:[NSWorkspace sharedWorkspace]];
    [allUserIDsMenuItem setState:([self displaysAllUserIDs] ? NSOnState:NSOffState)];
    
    aMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"PGP_SEARCH_KEYS_MENUITEM", @"GPGMail", [NSBundle bundleForClass:[self class]], "<PGP Key Search> menuItem title") action:@selector(gpgSearchKeys:) andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:@selector(showAddressHistoryPanel:) offset:1];
    
    if(!aMenuItem)
        NSLog(@"### GPGMail: unable to add menuItem <PGP Key Search>");
    else{
        [aMenuItem setTarget:self];
    }
    
    // Addition which has nothing to do with GPGMail
    if([[GPGDefaults gpgDefaults] boolForKey:@"GPGEnableMessageURLCopy"]){
        aMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"COPY_MSG_URL_MENUITEM", @"GPGMail", [NSBundle bundleForClass:[self class]], "<Copy Message URL> menuItem title") action:@selector(gpgCopyMessageURL:) andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:@selector(pasteAsQuotation:) offset:0];
    }
    
    [self performSelector:@selector(checkPGPmailPresence) withObject:nil afterDelay:0];
    /*            if([[GPGDefaults gpgDefaults] boolForKey:@"GPGAddServiceReplacement"]){
     aMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"ENCRYPT_SELECTION...", @"GPGMail", [NSBundle bundleForClass:[self class]], "<Encrypt Selection> menuItem title") action:@selector(gpgEncryptSelection:) andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:@selector(complete:) offset:1];
     [aMenuItem setTarget:self];
     aMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"SIGN_SELECTION...", @"GPGMail", [NSBundle bundleForClass:[self class]], "<Sign Selection> menuItem title") action:@selector(gpgSignSelection:) andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:@selector(complete:) offset:1];
     [aMenuItem setTarget:self];
     }*/
    
    [self synchronizeKeyGroupsWithAddressBookGroups];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(abDatabaseChangedExternally:) name:kABDatabaseChangedExternallyNotification object:[ABAddressBook sharedAddressBook]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(abDatabaseChanged:) name:kABDatabaseChangedNotification object:[ABAddressBook sharedAddressBook]];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(keyringChanged:) name:GPGKeyringChangedNotification object:nil];                
}

- (id) init
{
    if(self = [super init]){
        NSBundle		*myBundle = [NSBundle bundleForClass:[self class]];
        NSDictionary	*defaultsDictionary = [NSDictionary dictionaryWithContentsOfFile:[myBundle pathForResource:@"GPGMailBundle" ofType:@"defaults"]];
        
        if(gpgMailWorks)
            gpgMailWorks = [self checkSystem];

        if(defaultsDictionary)
            [[GPGDefaults gpgDefaults] registerDefaults:defaultsDictionary];
        
        if(gpgMailWorks)
            gpgMailWorks = [self checkGPG];
        if(gpgMailWorks)
            [self finishInitialization];
    }

    return self;
}

- (void) messageStoreMessageFlagsChanged:(NSNotification *)notification
{
    if(GPGMailLoggingLevel)
        NSLog(@"[DEBUG] messageStoreMessageFlagsChanged, from %@, with %@", [notification object], [notification userInfo]);
}

- (void) workspaceDidMount:(NSNotification *)notification
{
    // Some people put their keys on a mountable volume, and sometimes don't mount that volume
    // before launching Mail. In case the keyrings are in a newly-mounted volume, we refresh them
    if([self refreshesKeysOnVolumeMount])
        [self flushKeyCache:YES];
}

- (void) workspaceDidUnmount:(NSNotification *)notification
{
    // Some people put their keys on a mountable volume, and sometimes don't mount that volume
    // before launching Mail. In case the keyrings are in a newly-mounted volume, we refresh them
    if([self refreshesKeysOnVolumeMount])
        [self flushKeyCache:YES];
}

- (void) dealloc
{
    // Never invoked...
    [realToolbarDelegates release];
    [additionalToolbarItemIdentifiersPerToolbarIdentifier release];
    [cachedPersonalKeys release];
    [cachedPublicKeys release];
    if(cachedUserIDsPerKey != NULL)
        NSFreeMapTable(cachedUserIDsPerKey);
    [cachedKeyGroups release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:nil object:nil];
    [locale release];

	struct objc_super s = { self, [self superclass] };
	objc_msgSendSuper(&s, @selector(dealloc));
}

- (NSString *) versionDescription
{
    return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"VERSION: %@", @"GPGMail", [NSBundle bundleForClass:[self class]], "Description of version prefixed with <Version: >"), [self version]];
}

- (NSString *) version
{
    return [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSMenuItem *) decryptMenuItem
{
    return decryptMenuItem;
}

- (NSMenuItem *) authenticateMenuItem
{
    return authenticateMenuItem;
}

- (NSMenuItem *) encryptsNewMessageMenuItem
{
    return encryptsNewMessageMenuItem;
}

- (NSMenuItem *) signsNewMessageMenuItem
{
	return signsNewMessageMenuItem;
}

- (NSMenuItem *) personalKeysMenuItem
{
    return personalKeysMenuItem;
}

- (NSMenuItem *) choosePublicKeysMenuItem
{
    return choosePublicKeysMenuItem;
}

- (NSMenuItem *) automaticPublicKeysMenuItem
{
    return automaticPublicKeysMenuItem;
}

- (NSMenuItem *) symetricEncryptionMenuItem
{
    return symetricEncryptionMenuItem;
}

- (NSMenuItem *) usesOnlyOpenPGPStyleMenuItem
{
    return usesOnlyOpenPGPStyleMenuItem;
}

- (NSMenuItem *) pgpMenuItem
{
    return pgpMenuItem;
}

- (NSMenuItem *) pgpViewMenuItem
{
    return pgpViewMenuItem;
}

- (NSMenuItem *) allUserIDsMenuItem
{
    return allUserIDsMenuItem;
}

+ (BOOL) hasComposeAccessoryViewOwner
{
	return gpgMailWorks; // TIGER + LEOPARD Invoked on +initialize
}

+ (NSString *) composeAccessoryViewOwnerClassName
{
    // TIGER/LEOPARD Never invoked!
    return @"GPGMailComposeAccessoryViewOwner";
}

- (void) preferencesDidChange:(SEL)selector
{
    NSString	*aString = NSStringFromSelector(selector);

    aString = [[[aString substringWithRange:NSMakeRange(3, 1)] lowercaseString] stringByAppendingString:[aString substringWithRange:NSMakeRange(4, [aString length] - 5)]];
    // aString is the 'getter' derived from the 'setter' selector (setXXX:)
    [[NSNotificationCenter defaultCenter] postNotificationName:GPGPreferencesDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObject:aString forKey:@"key"]];
}

- (void) setAlwaysSignMessages:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAlwaysSignMessage"];
    if(![signsNewMessageMenuItem isEnabled])
        [signsNewMessageMenuItem setState:(flag ? NSOnState:NSOffState)];
    [self preferencesDidChange:_cmd];
}

- (BOOL) alwaysSignMessages
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAlwaysSignMessage"];
}

- (void) setAlwaysEncryptMessages:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAlwaysEncryptMessage"];
    // FIXME: Update menu for mixed
    if(![encryptsNewMessageMenuItem isEnabled])
        [encryptsNewMessageMenuItem setState:(flag ? NSOnState:NSOffState)];
    [self preferencesDidChange:_cmd];
}

- (BOOL) alwaysEncryptMessages
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAlwaysEncryptMessage"];
}

- (void) setEncryptMessagesWhenPossible:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGEncryptMessageWhenPossible"];
    // FIXME: Update menu
//    if(![encryptsNewMessageMenuItem isEnabled])
//        [encryptsNewMessageMenuItem setState:(flag ? NSOnState:NSOffState)];
    [self preferencesDidChange:_cmd];
}

- (BOOL) encryptMessagesWhenPossible
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGEncryptMessageWhenPossible"];
}

- (void) setDefaultKey:(GPGKey *)key
{
    if(key != nil){
        [[GPGDefaults gpgDefaults] setObject:[key fingerprint] forKey:@"GPGDefaultKeyFingerprint"];
        [key retain];
        [defaultKey release];
        defaultKey = key;
    }
    else{
        [[GPGDefaults gpgDefaults] removeObjectForKey:@"GPGDefaultKeyFingerprint"];
        [defaultKey release];
        defaultKey = nil;
    }
    [self refreshPersonalKeysMenu];
    [self refreshPublicKeysMenu];
    [self preferencesDidChange:_cmd];
}

- (GPGKey *) defaultKey
{
    if(defaultKey == nil && gpgMailWorks){
        NSString    *aPattern = [[GPGDefaults gpgDefaults] stringForKey:@"GPGDefaultKeyFingerprint"];
        BOOL		searchedAllKeys = NO;
		BOOL		fprPattern = YES;
        
        if(!aPattern || [aPattern length] == 0){
            aPattern = [[NSUserDefaults standardUserDefaults] stringForKey:@"MailUserName"]; // No longer used since 10.4
			fprPattern = NO;
		}
        if(!aPattern || [aPattern length] == 0)
            aPattern = nil; // Return all secret keys
        
        do{
            NSEnumerator	*anEnum = [[self keysForSearchPatterns:(aPattern ? [NSArray arrayWithObject:(fprPattern ? aPattern : [aPattern valueForKey:@"gpgNormalizedEmail"])] : nil) attributeName:(fprPattern ? @"key.fingerprint":@"normalizedEmail") secretKeys:YES] objectEnumerator];
            GPGKey          *aKey;
            
            while(aKey = [anEnum nextObject]){
                [defaultKey release];
                defaultKey = [aKey retain];
                break;
            }
            if(aPattern == nil)
                searchedAllKeys = YES;
            else
                aPattern = nil;
        }while(defaultKey == nil && !searchedAllKeys);
    }

    return defaultKey;
}

- (void) setRemembersPassphrasesDuringSession:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGRemembersPassphrasesDuringSession"];
    [GPGPassphraseController setCachesPassphrases:flag];
    [self preferencesDidChange:_cmd];
}

- (BOOL) remembersPassphrasesDuringSession
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGRemembersPassphrasesDuringSession"];
}

- (void) setDecryptsMessagesAutomatically:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDecryptsMessagesAutomatically"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) decryptsMessagesAutomatically
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGDecryptsMessagesAutomatically"];
}

- (void) setAuthenticatesMessagesAutomatically:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAuthenticatesMessagesAutomatically"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) authenticatesMessagesAutomatically
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAuthenticatesMessagesAutomatically"];
}

- (void) setDisplaysButtonsInComposeWindow:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDisplaysButtonsInComposeWindow"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) displaysButtonsInComposeWindow
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGDisplaysButtonsInComposeWindow"];
}

- (void) setEncryptsToSelf:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGEncryptsToSelf"];
    [self refreshPublicKeysMenu];
    [self preferencesDidChange:_cmd];
}

- (BOOL) encryptsToSelf
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGEncryptsToSelf"];
}

- (void) setUsesKeychain:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGUsesKeychain"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) usesKeychain
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGUsesKeychain"];
}

- (void) setUsesOnlyOpenPGPStyle:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGOpenPGPStyleOnly"];
    if(![usesOnlyOpenPGPStyleMenuItem isEnabled])
        [usesOnlyOpenPGPStyleMenuItem setState:(flag ? NSOnState:NSOffState)];
    [self preferencesDidChange:_cmd];
}

- (BOOL) usesOnlyOpenPGPStyle
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGOpenPGPStyleOnly"];
}

- (void) setDecryptsOnlyUnreadMessagesAutomatically:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDecryptsOnlyUnreadMessagesAutomatically"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) decryptsOnlyUnreadMessagesAutomatically
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGDecryptsOnlyUnreadMessagesAutomatically"];
}

- (void) setAuthenticatesOnlyUnreadMessagesAutomatically:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAuthenticatesOnlyUnreadMessagesAutomatically"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) authenticatesOnlyUnreadMessagesAutomatically
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAuthenticatesOnlyUnreadMessagesAutomatically"];
}

- (void) setUsesEncapsulatedSignature:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGUsesEncapsulatedSignature"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) usesEncapsulatedSignature
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGUsesEncapsulatedSignature"];
}

- (void) setUsesBCCRecipients:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGUsesBCCRecipients"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) usesBCCRecipients
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGUsesBCCRecipients"];
}

- (void) setTrustsAllKeys:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGTrustsAllKeys"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) trustsAllKeys
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGTrustsAllKeys"];
}

- (void) setAutomaticallyShowsAllInfo:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAutomaticallyShowsAllInfo"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) automaticallyShowsAllInfo
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAutomaticallyShowsAllInfo"];
}

- (void) setPassphraseFlushTimeout:(NSTimeInterval)timeout
{
    NSParameterAssert(timeout >= 0.0);
    [[GPGDefaults gpgDefaults] setFloat:timeout forKey:@"GPGPassphraseFlushTimeout"];
    [self preferencesDidChange:_cmd];
}

- (NSTimeInterval) passphraseFlushTimeout
{
    return [[GPGDefaults gpgDefaults] floatForKey:@"GPGPassphraseFlushTimeout"];
}

- (void) setChoosesPersonalKeyAccordingToAccount:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGChoosesPersonalKeyAccordingToAccount"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) choosesPersonalKeyAccordingToAccount
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGChoosesPersonalKeyAccordingToAccount"];
}

- (void) setButtonsShowState:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGButtonsShowState"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) buttonsShowState
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGButtonsShowState"];
}

- (void) setSignWhenEncrypting:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGSignWhenEncrypting"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) signWhenEncrypting
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGSignWhenEncrypting"];
}

- (NSArray *) allDisplayedKeyIdentifiers
{
    static NSArray	*allDisplayedKeyIdentifiers = nil;
    
    if(!allDisplayedKeyIdentifiers)
        // TODO: After adding longKeyID, update GPGPreferences.nib
        allDisplayedKeyIdentifiers = [[NSArray arrayWithObjects:@"name", @"email", @"comment", @"fingerprint", @"keyID", /*@"longKeyID",*/ @"validity", @"algorithm", nil] retain];

    return allDisplayedKeyIdentifiers;
}

- (void) setDisplayedKeyIdentifiers:(NSArray *)keyIdentifiers
{
    NSEnumerator	*anEnum = [keyIdentifiers objectEnumerator];
    NSString		*anIdentifier;

    while(anIdentifier = [anEnum nextObject]){
        NSAssert1([[self allDisplayedKeyIdentifiers] containsObject:anIdentifier], @"### GPGMail: -[GPGMailBundle setDisplayedKeyIdentifiers:]: invalid identifier '%@'", anIdentifier);
    }
    [[GPGDefaults gpgDefaults] setObject:keyIdentifiers forKey:@"GPGDisplayedKeyIdentifiers"];
    [self refreshPublicKeysMenu];
    [self refreshPersonalKeysMenu];
    [self refreshKeyIdentifiersDisplayInMenu:[[self pgpViewMenuItem] submenu]];
    [self preferencesDidChange:_cmd];
}

- (NSArray *) displayedKeyIdentifiers
{
    return [[GPGDefaults gpgDefaults] arrayForKey:@"GPGDisplayedKeyIdentifiers"];
}

- (void) setDisplaysAllUserIDs:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDisplaysAllUserIDs"];
    [self refreshPublicKeysMenu];
    [self refreshPersonalKeysMenu];
    [allUserIDsMenuItem setState:([self displaysAllUserIDs] ? NSOnState:NSOffState)];
    [self preferencesDidChange:_cmd];
}

- (BOOL) displaysAllUserIDs
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGDisplaysAllUserIDs"];
}

- (void) setFiltersOutUnusableKeys:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGFiltersOutUnusableKeys"];
    [self flushKeyCache:YES];
    [self preferencesDidChange:_cmd];
}

- (BOOL) filtersOutUnusableKeys
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGFiltersOutUnusableKeys"];
}

- (void) setShowsPassphrase:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGShowsPassphrase"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) showsPassphrase
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGShowsPassphrase"];
}

- (void) setLineWrappingLength:(int)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"LineLength"];
    [self preferencesDidChange:_cmd];
}

- (int) lineWrappingLength
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"LineLength"];
}

- (void) setIgnoresPGPPresence:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGIgnoresPGPPresence"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) ignoresPGPPresence
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGIgnoresPGPPresence"];
}

- (void) setRefreshesKeysOnVolumeMount:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGRefreshesKeysOnVolumeMount"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) refreshesKeysOnVolumeMount
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGRefreshesKeysOnVolumeMount"];
}

- (void) setDisablesSMIME:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDisablesSMIME"];
    [self preferencesDidChange:_cmd];
}

- (BOOL) disablesSMIME
{
    return gpgMailWorks && [[GPGDefaults gpgDefaults] boolForKey:@"GPGDisablesSMIME"];
}

- (void) setWarnedAboutMissingPrivateKeys:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGWarnedAboutMissingPrivateKeys"];
}

- (BOOL) warnedAboutMissingPrivateKeys
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGWarnedAboutMissingPrivateKeys"];
}

- (void) setEncryptsReplyToEncryptedMessage:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGEncryptsReplyToEncryptedMessage"];
}

- (BOOL) encryptsReplyToEncryptedMessage
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGEncryptsReplyToEncryptedMessage"];
}

- (void) setSignsReplyToSignedMessage:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGSignsReplyToSignedMessage"];
}

- (BOOL) signsReplyToSignedMessage
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGSignsReplyToSignedMessage"];
}

- (void) setUsesABEntriesRules:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGUsesABEntriesRules"];
}

- (BOOL) usesABEntriesRules
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGUsesABEntriesRules"];
}

- (void) setAddsCustomHeaders:(BOOL)flag
{
    [[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAddCustomHeaders"];
}

- (BOOL) addsCustomHeaders
{
    return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAddCustomHeaders"];
}

- (void) mailTo:(id)sender
{
    NSString		*error = nil;
    NSPasteboard	*aPasteboard = [NSPasteboard pasteboardWithUniqueName];
    NSArray			*pbTypes = [NSArray arrayWithObject:NSStringPboardType];
    id				serviceProvider = [NSApplication sharedApplication];

    (void)[aPasteboard declareTypes:pbTypes owner:nil];
    (void)[aPasteboard addTypes:pbTypes owner:nil];
    (void)[aPasteboard setString:@"gpgmail-users@lists.gpgmail.org" forType:NSStringPboardType];

    // Invoke <MailViewer/Mail To> service
    if([serviceProvider respondsToSelector:@selector(mailTo:userData:error:)])
        [serviceProvider mailTo:aPasteboard userData:nil error:&error];
    if(error)
        NSBeep();
}

- (void) gpgForwardAction:(SEL)action from:(id)sender
{
    // Still used as of v37 for encrypt/sign toolbar buttons
    id	messageEditor = [[NSApplication sharedApplication] targetForAction:action];

    if(messageEditor && [messageEditor respondsToSelector:action])
        [messageEditor performSelector:action withObject:sender];
}

- (IBAction) gpgToggleEncryptionForNewMessage:(id)sender
{
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgToggleSignatureForNewMessage:(id)sender
{
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgChoosePublicKeys:(id)sender
{
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgChoosePersonalKey:(id)sender
{
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgChoosePublicKey:(id)sender
{
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgToggleAutomaticPublicKeysChoice:(id)sender
{
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgToggleSymetricEncryption:(id)sender
{
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgToggleUsesOnlyOpenPGPStyle:(id)sender
{
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgToggleShowKeyInformation:(id)sender
{
    NSString		*anIdentifier = [[self allDisplayedKeyIdentifiers] objectAtIndex:([sender tag] - 1)];
    NSMutableArray	*anArray = [NSMutableArray arrayWithArray:[self displayedKeyIdentifiers]];
    int				oldState = [sender state];

    if(oldState == NSOnState)
        [anArray removeObject:anIdentifier];
    else
        [anArray addObject:anIdentifier];
    [self setDisplayedKeyIdentifiers:anArray];
}

- (IBAction) gpgToggleDisplayAllUserIDs:(id)sender
{
    [self setDisplaysAllUserIDs:([sender state] != NSOnState)]; // Toggle...
}

- (id) messageViewerOrEditorForToolbarItem:(NSToolbarItem *)item
{
    NSEnumerator	*anEnum = [[NSClassFromString(@"MessageViewer") allMessageViewers] objectEnumerator];    
    MessageViewer	*aViewer;
    MessageViewer   *anEditor;

    while(aViewer = [anEnum nextObject]){
        NSToolbar	*aToolbar = [aViewer gpgToolbar];

        if([[aToolbar items] containsObject:item])
            return aViewer;

        if([item isKindOfClass:[NSClassFromString(@"SegmentedToolbarItemSegmentItem") class]] && [[aToolbar items] containsObject:[(SegmentedToolbarItemSegmentItem *)item parent]])
            return aViewer;
    }
    // These "messageEditors" are not real message editors, but detached viewers (no mailbox)...
    anEnum = [[NSClassFromString(@"MailDocumentEditor") documentEditors] objectEnumerator];
    while(anEditor = [anEnum nextObject]){
        NSToolbar	*aToolbar = [anEditor gpgToolbar];

        if([[aToolbar items] containsObject:item])
            return anEditor;
        if([item isKindOfClass:[NSClassFromString(@"SegmentedToolbarItemSegmentItem") class]] && [[aToolbar items] containsObject:[(id)item parent]])
            return anEditor;
    }

    anEnum = [[NSClassFromString(@"MessageViewer") allSingleMessageViewers] objectEnumerator];
    while(aViewer = [anEnum nextObject]){
        NSToolbar	*aToolbar = [aViewer gpgToolbar];

        if([[aToolbar items] containsObject:item])
            return aViewer;

        if([item isKindOfClass:[NSClassFromString(@"SegmentedToolbarItemSegmentItem") class]] && [[aToolbar items] containsObject:[(SegmentedToolbarItemSegmentItem *)item parent]])
            return aViewer;
    }

    return nil; // May happen, while new compose window is being set up.
}

- (Message *) targetMessageForToolbarItem:(NSToolbarItem *)item
{
    if(item == nil){
        // item is nil when validating menu items => menu items apply to
        // first responder (or use responder chain)
        MessageViewer		*messageViewer = [[NSApplication sharedApplication] targetForAction:@selector(gpgTextViewer:)];
        MessageContentController	*viewer = [messageViewer gpgTextViewer:nil];
        
        return [viewer gpgMessage];
    }
    else{
        NSEnumerator	*anEnum = [[NSClassFromString(@"MessageViewer") allMessageViewers] objectEnumerator];    
        MessageViewer	*aViewer;
        MessageViewer   *anEditor;
       
        while(aViewer = [anEnum nextObject]){
            NSToolbar	*aToolbar = [aViewer gpgToolbar];
            
            if([[aToolbar items] containsObject:item])
                return [[aViewer gpgTextViewer:nil] gpgMessage];
        }

        // These "messageEditors" are not real message editors, but detached viewers (no mailbox)...
        anEnum = [[NSClassFromString(@"MailDocumentEditor") documentEditors] objectEnumerator];
        while(anEditor = [anEnum nextObject]){
            NSToolbar	*aToolbar = [anEditor gpgToolbar];
            
            if([[aToolbar items] containsObject:item])
                return [[anEditor gpgTextViewer:nil] gpgMessage];
        }

        anEnum = [[NSClassFromString(@"MessageViewer") allSingleMessageViewers] objectEnumerator];
        while(aViewer = [anEnum nextObject]){
            NSToolbar	*aToolbar = [aViewer gpgToolbar];
            
            if([[aToolbar items] containsObject:item])
                return [[aViewer gpgTextViewer:nil] gpgMessage];
        }
    }
    
    return nil;
}

- (BOOL) _validateAction:(SEL)anAction toolbarItem:(NSToolbarItem *)item menuItem:(NSMenuItem *)menuItem
{
    if(anAction == @selector(gpgToggleEncryptionForNewMessage:) || anAction == @selector(gpgToggleSignatureForNewMessage:) || anAction == @selector(gpgChoosePersonalKey:) || anAction == @selector(gpgChoosePublicKeys:) || anAction == @selector(gpgChoosePublicKey:) || anAction == @selector(gpgToggleAutomaticPublicKeysChoice:) || anAction == @selector(gpgToggleSymetricEncryption:) || anAction == @selector(gpgToggleUsesOnlyOpenPGPStyle:)){
        if(menuItem){
            id	messageEditor = [[NSApplication sharedApplication] targetForAction:anAction];

            if(messageEditor != nil)
                return ([messageEditor respondsToSelector:@selector(gpgIsRealEditor)] && [messageEditor gpgIsRealEditor] && [messageEditor gpgValidateMenuItem:menuItem]);
            else
                return NO;
        }
        else{
            id	messageEditor = [self messageViewerOrEditorForToolbarItem:item];

            if(messageEditor != nil){
                return ([messageEditor respondsToSelector:@selector(gpgIsRealEditor)] && [messageEditor gpgIsRealEditor] && [messageEditor gpgValidateToolbarItem:item]);
            }
            else
                return NO;
        }
    }
    else if(anAction == @selector(gpgDecrypt:) || anAction == @selector(gpgAuthenticate:)){
        if(menuItem){
            MessageViewer		*messageViewer = [[NSApplication sharedApplication] targetForAction:@selector(gpgTextViewer:)];
            MessageContentController	*viewer = [messageViewer gpgTextViewer:nil];

            return [viewer validateMenuItem:menuItem];
        }
        else{
            MessageViewer		*messageViewer = [self messageViewerOrEditorForToolbarItem:item];
            MessageContentController	*viewer = [messageViewer gpgTextViewer:nil];
            
            return [viewer gpgValidateAction:anAction];
        }
    }
    else if(anAction == @selector(gpgReloadPGPKeys:))
        return YES;
    else if(anAction == @selector(gpgToggleDisplayAllUserIDs:))
        return YES;
    else if(anAction == @selector(gpgToggleShowKeyInformation:))
        return YES;
    else if(anAction == @selector(gpgSearchKeys:))
        return YES;
/*    else if(anAction == @selector(gpgEncryptSelection:) || anAction == @selector(gpgSignSelection:)){
        static id previousDelegate = nil;
        static id previousResponder = nil;

        if(previousDelegate != [[NSApp mainWindow] delegate]){
            previousDelegate = [[NSApp mainWindow] delegate];
            NSLog(@"[[NSApp mainWindow] delegate] = %@", [[NSApp mainWindow] delegate]);
        }
        if(previousResponder != [[NSApp mainWindow] firstResponder]){
            previousResponder = [[NSApp mainWindow] firstResponder];
            NSLog(@"[[NSApp mainWindow] firstResponder] = %@", [[NSApp mainWindow] firstResponder]);
        }
        if([[[NSApp mainWindow] delegate] isKindOfClass:[MessageEditor class]] && [[[NSApp mainWindow] firstResponder] isKindOfClass:[MessageTextView class]]){
            if([[[NSApp mainWindow] firstResponder] selectedAttachments] == nil && [[[NSApp mainWindow] firstResponder] selectedRange].length > 0)
            return YES;
        }
    }*/

    return NO;
}

- (BOOL) validateMenuItem:(NSMenuItem *)theItem
{
    // (Not called for toolbarItems when displayed as menuItems; validateToolbarItem: is called)
    return [self _validateAction:[theItem action] toolbarItem:nil menuItem:theItem];
}

- (BOOL) validateToolbarItem:(NSToolbarItem *)theItem
{
    // WARNING: this method is called repeatedly by Mail.app
    // In fact it is called so often that sometimes it can lock down Mail.app.
    // That's why we cache validation results
    return [self _validateAction:[theItem action] toolbarItem:theItem menuItem:nil];
}

- (BOOL)validateToolbarItem:(id)fp8 forSegment:(int)fp12
{
    return [self _validateAction:[fp8 actionForSegment:fp12] toolbarItem:fp8 menuItem:nil];
}

- (IBAction) gpgDecrypt:(id)sender
{
    MessageViewer		*messageViewer = [[NSApplication sharedApplication] targetForAction:@selector(gpgTextViewer:)];
    MessageContentController	*viewer = [messageViewer gpgTextViewer:nil];

    [viewer gpgDecrypt:sender];
}

- (IBAction) gpgAuthenticate:(id)sender
{
    MessageViewer		*messageViewer = [[NSApplication sharedApplication] targetForAction:@selector(gpgTextViewer:)];
    MessageContentController	*viewer = [messageViewer gpgTextViewer:nil];

    [viewer gpgAuthenticate:sender];
}

- (void) progressIndicatorDidCancel:(GPGProgressIndicatorController *)controller
{
//    [[GPGHandler defaultHandler] cancelOperation];
}

- (IBAction) gpgReloadPGPKeys:(id)sender
{
    [self flushKeyCache:YES];
    if(gpgMailWorks)
        [self synchronizeKeyGroupsWithAddressBookGroups];
}

- (IBAction) gpgSearchKeys:(id)sender
{
    [[GPGKeyDownload sharedInstance] gpgSearchKeys:sender];
}

- (void) flushKeyCache:(BOOL)refresh
{
    [cachedPersonalKeys release];
    cachedPersonalKeys = nil;
    [cachedPublicKeys release];
    cachedPublicKeys = nil;
    [cachedKeyGroups release];
    cachedKeyGroups = nil;
    [defaultKey release];
    defaultKey = nil;
    if(cachedUserIDsPerKey != NULL){
        NSFreeMapTable(cachedUserIDsPerKey);
        cachedUserIDsPerKey = NULL;
    }
    if(refresh){
        [[NSNotificationCenter defaultCenter] postNotificationName:GPGKeyListWasInvalidatedNotification object:self];
        [self refreshPersonalKeysMenu]; // Was disabled
        [self refreshPublicKeysMenu]; // Was disabled
    }
#warning CHECK: keys not synced with current editor!
}

- (void) warnUserForMissingPrivateKeys:(id)sender
{
    NSBundle	*aBundle = [NSBundle bundleForClass:[self class]];
    NSString	*aTitle = NSLocalizedStringFromTableInBundle(@"NO PGP PRIVATE KEY - TITLE", @"GPGMail", aBundle, "");
    NSString	*aMessage = NSLocalizedStringFromTableInBundle(@"NO PGP PRIVATE KEY - MESSAGE", @"GPGMail", aBundle, "");

    (void)NSRunAlertPanel(aTitle, @"%@", nil, nil, nil, aMessage);
    [self setWarnedAboutMissingPrivateKeys:YES];
}

- (NSArray *) keysForSearchPatterns:(NSArray *)searchPatterns attributeName:(NSString *)attributeKeyPath secretKeys:(BOOL)secretKeys
{
    // We need to perform search in-memory, because asking gpgme/gpg to do it launches
    // a task each time, starving the system resources!
    NSMutableArray  *keys = [NSMutableArray array];
	NSArray			*allKeys = (secretKeys ? [self personalKeys] : [self publicKeys]);
	
	if(!searchPatterns)
		[keys addObjectsFromArray:allKeys];
	else{
		NSEnumerator    *keyEnum = [allKeys objectEnumerator];
		GPGKey          *eachKey;
		
		while((eachKey = [keyEnum nextObject])){
			NSEnumerator    *uidEnum = [[eachKey userIDs] objectEnumerator];
			GPGUserID       *eachUserID;
			BOOL            found = NO;
			
			while((eachUserID = [uidEnum nextObject])){
				if([searchPatterns containsObject:[eachUserID valueForKeyPath:attributeKeyPath]]){ // FIXME: Zombie(?) of searchPatterns crash in -isEqual:
					found = YES;
					break;
				}
			}
			
			if(found)
				[keys addObject:eachKey];
		}
	}
    
    return keys;
}

- (NSArray *) personalKeys
{
    if(!cachedPersonalKeys && gpgMailWorks){
        GPGContext      *aContext = [[GPGContext alloc] init];
        NSEnumerator	*anEnum;
        NSMutableArray	*anArray = [[NSMutableArray alloc] init];
        GPGKey          *aKey;
        BOOL			filterKeys = [self filtersOutUnusableKeys];
        
        @try{
            anEnum = [aContext keyEnumeratorForSearchPattern:@"" secretKeysOnly:YES];
			
			while(aKey = [anEnum nextObject]){
				// BUG in gpg <= 1.2.x: secret keys have no capabilities when listed in batch!
				// That's why we refresh key.
				aKey = [aContext refreshKey:aKey];
				if(!filterKeys || [self canKeyBeUsedForSigning:aKey])
					[anArray addObject:aKey];
			}
		}@catch(NSException *localException){
			[aContext release];
			[anArray release];
			[localException raise];
        }
        cachedPersonalKeys = anArray;
        [aContext release];
        if([cachedPersonalKeys count] == 0 && ![self warnedAboutMissingPrivateKeys])
            [self performSelector:@selector(warnUserForMissingPrivateKeys:) withObject:nil afterDelay:0];
    }

    return cachedPersonalKeys;
}

- (NSArray *) keyGroups
{
    if(!cachedKeyGroups && gpgMailWorks){
        GPGContext      *aContext = [[GPGContext alloc] init];
        
        cachedKeyGroups = [[aContext keyGroups] retain];
        [aContext release];
    }
    
    return cachedKeyGroups;
}

- (NSArray *) publicKeys
{
    if(!cachedPublicKeys && gpgMailWorks){
        GPGContext      *aContext = [[GPGContext alloc] init];
        NSEnumerator	*anEnum;
        NSMutableArray	*anArray = [[NSMutableArray alloc] init];
        GPGKey          *aKey;
        BOOL			filterKeys = [self filtersOutUnusableKeys];

        @try{
            anEnum = [aContext keyEnumeratorForSearchPattern:@"" secretKeysOnly:NO];
			
			while(aKey = [anEnum nextObject]){
				if(!filterKeys || [self canKeyBeUsedForEncryption:aKey])
					[anArray addObject:aKey];
			}
		}@catch(NSException *localException){
			[aContext release];
			[anArray release];
			[localException raise];
        }
        cachedPublicKeys = anArray;
        [aContext release];
    }

    return cachedPublicKeys;
}

- (NSArray *) secondaryUserIDsForKey:(GPGKey *)key
{
    // BUG: if primary userID is not valid,
    // it will not be filtered out!
    NSArray	*result;
    
    if(cachedUserIDsPerKey == NULL){
        // We NEED to retain userIDs, else there are zombies, due to DO
        cachedUserIDsPerKey = NSCreateMapTableWithZone(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 50, [self zone]);
    }
    result = NSMapGet(cachedUserIDsPerKey, key);
    if(result == nil){
        int	aCount;
        
        result = [key userIDs];
        aCount = [result count];
        if(aCount > 1){
            NSEnumerator	*anEnum = [result objectEnumerator];
            NSMutableArray	*anArray = [NSMutableArray array];
            GPGUserID       *aUserID;
            BOOL			filterKeys = [self filtersOutUnusableKeys];

            (void)[anEnum nextObject]; // Skip primary userID
            while(aUserID = [anEnum nextObject]){
                if(!filterKeys || [self canUserIDBeUsed:aUserID])
                    [anArray addObject:aUserID];
            }
            result = anArray;
        }
        else
            result = [NSArray array];
        NSMapInsert(cachedUserIDsPerKey, key, result);
    }

    return result;
}

- (NSString *) context:(GPGContext *)context passphraseForKey:(GPGKey *)key again:(BOOL)again
{
    NSString	*passphrase;

    if(again && key != nil)
        [GPGPassphraseController flushCachedPassphraseForUser:key];

    // (Find current window) No longer necessary - will be replaced by agent
    passphrase = [[GPGPassphraseController controller] passphraseForUser:key title:NSLocalizedStringFromTableInBundle(@"MESSAGE_DECRYPTION_PASSPHRASE_TITLE", @"GPGMail", [NSBundle bundleForClass:[self class]], "") window:/*[[self composeAccessoryView] window]*/nil];

    return passphrase;
}

- (GPGKey *) publicKeyForSecretKey:(GPGKey *)secretKey
{
    // Do not invoke -[GPGKey publicKey], because it will perform a gpg op
    // Get key from cached public keys
    NSEnumerator    *keyEnum = [[self publicKeys] objectEnumerator];            
    NSString        *aFingerprint = [secretKey fingerprint];
    GPGKey          *aPublicKey;
    
    while(aPublicKey = [keyEnum nextObject]){
        if([[aPublicKey fingerprint] isEqualToString:aFingerprint])
            break;
    }        
    
    return aPublicKey;
}

- (NSString *) menuItemTitleForKey:(GPGKey *)key
{
    NSEnumerator	*anEnum;
    NSString		*anIdentifier;
    NSMutableArray	*components = [NSMutableArray array];
    NSBundle		*myBundle = [NSBundle bundleForClass:[self class]];
    GPGUserID       *primaryUserID;
    GPGSubkey       *aSubkey;
    BOOL            isKeyRevoked, hasKeyExpired, isKeyDisabled, isKeyInvalid;
    BOOL            hasNonRevokedSubkey = NO, hasNonExpiredSubkey = NO, hasNonDisabledSubkey = NO, hasNonInvalidSubkey = NO;

#warning FIXME: Secret keys are never marked as revoked! Check expired/disabled/invalid
    key = [self publicKeyForSecretKey:key];
    
    primaryUserID = ([[key userIDs] count] > 0 ? [[key userIDs] objectAtIndex:0]:nil);
    isKeyRevoked = [key isKeyRevoked]; // Secret keys are never marked as revoked!
    hasKeyExpired = [key hasKeyExpired];
    isKeyDisabled = [key isKeyDisabled];
    isKeyInvalid = [key isKeyInvalid];

    // A key can have no "problem" whereas the subkey it needs has such "problems"!!!
#warning We really need to filter keys according to SUBKEYS!
    // Currently we filter only according to key -> we display disabled keys,
    // whereas we shouldn't even show them
    anEnum = [[key subkeys] objectEnumerator];
    while(aSubkey = [anEnum nextObject]){
        if(![aSubkey isKeyRevoked])
            hasNonRevokedSubkey = YES;
        if(![aSubkey hasKeyExpired])
            hasNonExpiredSubkey = YES;
        if(![aSubkey isKeyDisabled])
            hasNonDisabledSubkey = YES;
        if(![aSubkey isKeyInvalid])
            hasNonInvalidSubkey = YES;
#if 0
        isKeyRevoked = isKeyRevoked || [aSubkey isKeyRevoked];
        hasKeyExpired = hasKeyExpired || [aSubkey hasKeyExpired];
        isKeyDisabled = isKeyDisabled || [aSubkey isKeyDisabled];
        isKeyInvalid = isKeyInvalid || [aSubkey isKeyInvalid];
#endif
    }

    if(primaryUserID != nil){
        if([primaryUserID hasBeenRevoked])
            [components addObject:NSLocalizedStringFromTableInBundle(@"REVOKED_USER_ID:", @"GPGMail", myBundle, "")];
        if([primaryUserID isInvalid])
            [components addObject:NSLocalizedStringFromTableInBundle(@"INVALID_USER_ID:", @"GPGMail", myBundle, "")];
    }

    if(isKeyRevoked && !hasNonRevokedSubkey)
        [components addObject:NSLocalizedStringFromTableInBundle(@"REVOKED_KEY:", @"GPGMail", myBundle, "")];
    if(hasKeyExpired && !hasNonExpiredSubkey)
        [components addObject:NSLocalizedStringFromTableInBundle(@"EXPIRED_KEY:", @"GPGMail", myBundle, "")];
    if(isKeyDisabled && !hasNonDisabledSubkey)
        [components addObject:NSLocalizedStringFromTableInBundle(@"DISABLED_KEY:", @"GPGMail", myBundle, "")];
    if(isKeyInvalid && !hasNonInvalidSubkey)
        [components addObject:NSLocalizedStringFromTableInBundle(@"INVALID_KEY:", @"GPGMail", myBundle, "")];

    anEnum = [[self displayedKeyIdentifiers] objectEnumerator];
    while(anIdentifier = [anEnum nextObject]){
        id			aValue;
        NSString	*aComponent;

        if([anIdentifier isEqualToString:@"validity"])
            anIdentifier = @"validityNumber";
        else if([anIdentifier isEqualToString:@"keyID"])
            anIdentifier = @"shortKeyID";
        else if([anIdentifier isEqualToString:@"longKeyID"])
            anIdentifier = @"keyID";
        else if([anIdentifier isEqualToString:@"algorithm"])
            anIdentifier = @"algorithmDescription";
        else if([anIdentifier isEqualToString:@"fingerprint"])
            anIdentifier = @"formattedFingerprint";
        aValue = [key performSelector:NSSelectorFromString(anIdentifier)];
        if(aValue == nil || ([aValue isKindOfClass:[NSString class]] && [(NSString *)aValue length] == 0))
            continue;

        if([anIdentifier isEqualToString:@"email"])
            aComponent = [NSString stringWithFormat:@"<%@>", aValue];
        else if([anIdentifier isEqualToString:@"comment"])
            aComponent = [NSString stringWithFormat:@"(%@)", aValue];
        else if([anIdentifier isEqualToString:@"validityNumber"]){
            // Validity has no meaning yet for secret keys, always unknown, so we never display it
            if(![key isSecret]){
                NSString	*aDesc = [NSString stringWithFormat:@"Validity=%@", aValue];

                aDesc = NSLocalizedStringFromTableInBundle(aDesc, @"GPGMail", myBundle, "");
                aComponent = [NSString stringWithFormat:@"[%@%@]", NSLocalizedStringFromTableInBundle(@"VALIDITY: ", @"GPGMail", myBundle, ""), aDesc];
            }
            else
                continue;
        }
        else if([anIdentifier isEqualToString:@"shortKeyID"])
            aComponent = [NSString stringWithFormat:@"0x%@", aValue];
        else if([anIdentifier isEqualToString:@"keyID"])
            aComponent = [NSString stringWithFormat:@"0x%@", aValue];
        else
            aComponent = aValue;
        [components addObject:aComponent];
    }

    return [components componentsJoinedByString:@" "];
}

- (NSString *) menuItemTitleForUserID:(GPGUserID *)userID indent:(unsigned)indent
{
    NSEnumerator	*anEnum = [[self displayedKeyIdentifiers] objectEnumerator];
    NSString		*anIdentifier;
    NSMutableArray	*titleElements = [NSMutableArray array];
    NSBundle		*myBundle = [NSBundle bundleForClass:[self class]];

#warning FIXME: Secret keys are never marked as revoked! Check expired/disabled/invalid
    if([userID hasBeenRevoked])
        [titleElements addObject:NSLocalizedStringFromTableInBundle(@"REVOKED_USER_ID:", @"GPGMail", myBundle, "")];
    if([userID isInvalid])
        [titleElements addObject:NSLocalizedStringFromTableInBundle(@"INVALID_USER_ID:", @"GPGMail", myBundle, "")];

    while(anIdentifier = [anEnum nextObject]){
        id	aValue;
        
        if([anIdentifier isEqualToString:@"fingerprint"] || [anIdentifier isEqualToString:@"keyID"] || [anIdentifier isEqualToString:@"algorithm"] || [anIdentifier isEqualToString:@"longKeyID"])
            continue;
        if([anIdentifier isEqualToString:@"validity"])
            anIdentifier = @"validityNumber";
        
        aValue = [userID performSelector:NSSelectorFromString(anIdentifier)];

        if(aValue == nil || ([aValue isKindOfClass:[NSString class]] && [(NSString *)aValue length] == 0))
            continue;

        if([anIdentifier isEqualToString:@"email"])
            [titleElements addObject:[NSString stringWithFormat:@"<%@>", aValue]];
        else if([anIdentifier isEqualToString:@"comment"])
            [titleElements addObject:[NSString stringWithFormat:@"(%@)", aValue]];
        else if([anIdentifier isEqualToString:@"validityNumber"]){
            // Validity has no meaning yet for secret keys, always unknown, so we never display it
            if(![[userID key] isSecret]){
                NSString	*aDesc = [NSString stringWithFormat:@"Validity=%@", aValue];

                aDesc = NSLocalizedStringFromTableInBundle(aDesc, @"GPGMail", myBundle, "");
                [titleElements addObject:[NSString stringWithFormat:@"[%@%@]", NSLocalizedStringFromTableInBundle(@"VALIDITY: ", @"GPGMail", myBundle, ""), aDesc]]; // Would be nice to have an image for that
            }
        }
        else
            [titleElements addObject:aValue];
    }

    return [[@"" stringByPaddingToLength:(indent * 4) withString:@" " startingAtIndex:0] stringByAppendingString:[titleElements componentsJoinedByString:@" "]];
}

- (BOOL) canKeyBeUsedForEncryption:(GPGKey *)key
{
    // A subkey can be expired, without the key being, thus making key useless because it has
    // no other subkey...
    // We don't care about ownerTrust, validity
    NSEnumerator    *anEnum = [[key subkeys] objectEnumerator];
    GPGSubkey       *aSubkey;
    
    while(aSubkey = [anEnum nextObject]){
        if([aSubkey canEncrypt] && ![aSubkey hasKeyExpired] && ![aSubkey isKeyRevoked] && ![aSubkey isKeyInvalid] && ![aSubkey isKeyDisabled])
            return YES;
    }
    return NO;
}

- (BOOL) canKeyBeUsedForSigning:(GPGKey *)key
{
    // A subkey can be expired, without the key being, thus making key useless because it has
    // no other subkey...
    // We don't care about ownerTrust, validity, subkeys
    NSEnumerator    *anEnum;
    GPGSubkey       *aSubkey;
    
#warning FIXME: Secret keys are never marked as revoked! Check expired/disabled/invalid
    key = [self publicKeyForSecretKey:key];

    // If primary key itself can sign, that's OK (unlike what gpgme documentation says!)
    if([key canSign] && ![key hasKeyExpired] && ![key isKeyRevoked] && ![key isKeyInvalid] && ![key isKeyDisabled])
        return YES;
    
    anEnum = [[key subkeys] objectEnumerator];
    while(aSubkey = [anEnum nextObject]){
        if([aSubkey canSign] && ![aSubkey hasKeyExpired] && ![aSubkey isKeyRevoked] && ![aSubkey isKeyInvalid] && ![aSubkey isKeyDisabled])
            return YES;
    }
    return NO;
}

- (BOOL) canUserIDBeUsed:(GPGUserID *)userID
{
    // We suppose that key is OK
    // We don't care about validity
#warning FIXME: Secret keys are never marked as revoked! Check expired/disabled/invalid
    return (![userID hasBeenRevoked] && ![userID isInvalid]);
}

- (NSString *) descriptionForError:(GPGError)error
{
    unsigned	errorCode = [self gpgErrorCodeFromError:error];
    NSString	*aKey = [NSString stringWithFormat:@"GPGErrorCode=%u", errorCode];
    NSString	*localizedString = NSLocalizedStringFromTableInBundle(aKey, @"GPGMail", [NSBundle bundleForClass:[self class]], "");

    if([localizedString isEqualToString:aKey])
        localizedString = [NSString stringWithFormat:@"%@ (%u)", [self gpgErrorDescription:errorCode], errorCode];

    return localizedString;
}

- (NSString *) descriptionForException:(NSException *)exception
{
    if([[exception name] isEqualToString:GPGException]){
        // Workaround for bug in gpgme: in case we encrypt to a key which is not trusted, we get a General Error instead of a Invalid Key error
        GPGError        anError = [[[exception userInfo] objectForKey:GPGErrorKey] unsignedIntValue];
        NSDictionary    *keyErrors = [[[[exception userInfo] objectForKey:GPGContextKey] operationResults] objectForKey:@"keyErrors"];
        NSString        *aDescription;
        
        if([self gpgErrorCodeFromError:anError] == GPGErrorGeneralError && [keyErrors count] > 0)
            aDescription = [self descriptionForError:[self gpgMakeErrorWithSource:[self gpgErrorSourceFromError:anError] code:GPGErrorUnusablePublicKey]];
        else
            aDescription = [self descriptionForError:[[[exception userInfo] objectForKey:GPGErrorKey] unsignedIntValue]];

        if(keyErrors != nil){
            NSEnumerator    *keyEnum = [keyErrors keyEnumerator];
            id              aKey; // GPGKey or GPGRemoteKey
            NSMutableArray  *errors = [[NSMutableArray alloc] initWithCapacity:[keyErrors count]];
            
            while(aKey = [keyEnum nextObject]){
                GPGError    anError = [[keyErrors objectForKey:aKey] unsignedIntValue];
                
                if(anError != GPGErrorNoError){
                    NSString    *aKeyDescription = [aKey isKindOfClass:[GPGRemoteKey class]] ? [@"0x" stringByAppendingString:[aKey keyID]] : [self menuItemTitleForKey:aKey];
                    
                    [errors addObject:[NSString stringWithFormat:@"%@ - %@", aKeyDescription, [self descriptionForError:anError]]];
                }
            }
            if([errors count] > 0)
                aDescription = [errors componentsJoinedByString:@". "];
            [errors release];
        }
        
        return aDescription;
    }
    else if([[exception name] isEqualToString:GPGMailException]){
        return NSLocalizedStringFromTableInBundle([exception reason], @"GPGMail", [NSBundle bundleForClass:[self class]], "");
    }
    else{
        NSString	*aString = [exception reason];

        if([aString hasPrefix:@"[NOTE: this exception originated in the server.]"])
            aString = [aString substringFromIndex:49]; // String is not localized, no problem
        return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"EXCEPTION: %@", @"GPGMail", [NSBundle bundleForClass:[self class]], ""), aString];
    }
}

- (NSString *) hashAlgorithmDescription:(GPGHashAlgorithm)algorithm
{
    // We can't use results coming from MacGPGME: they are not the same as defined in RFC3156
    switch(algorithm){
        case GPG_MD5HashAlgorithm:
            return @"md5";
        case GPG_SHA_1HashAlgorithm:
            return @"sha1";
        case GPG_RIPE_MD160HashAlgorithm:
            return @"ripemd160";
        case GPG_MD2HashAlgorithm:
            return @"md2";
        case GPG_TIGER192HashAlgorithm:
            return @"tiger192";
        case GPG_HAVALHashAlgorithm:
            return @"haval-5-160";
        case GPG_SHA256HashAlgorithm:
            return @"sha256";
        case GPG_SHA384HashAlgorithm:
            return @"sha384";
        case GPG_SHA512HashAlgorithm:
            return @"sha512";
        default:{
            NSString    *hashAlgorithmDescription = GPGHashAlgorithmDescription(algorithm);
            
            if(hashAlgorithmDescription == nil)
                hashAlgorithmDescription = [NSString stringWithFormat:@"%d", algorithm];
                
            [NSException raise:NSGenericException format:NSLocalizedStringFromTableInBundle(@"INVALID_HASH_%@", @"GPGMail", [NSBundle bundleForClass:[self class]], ""), hashAlgorithmDescription];
            return nil; // Never reached
        }
    }
}

- (id) locale
{
//    return [NSLocale autoupdatingCurrentLocale]; // FIXME: does not work as expected
    return [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
}

/*
- (void) encryptSelectionSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    MessageTextView	*aTextView = contextInfo;
    NSString		*originalString = [[aTextView string] substringWithRange:[aTextView selectedRange]];
}

- (IBAction) gpgSignSelection:(id)sender
{
}

- (IBAction) gpgEncryptSelection:(id)sender
{
    MessageTextView	*aTextView = [[NSApp mainWindow] firstResponder];
    NSWindow		*aWindow;

    // Load nib containing list of pubkeys + encoding choice
    [NSApp beginSheet:aWindow modalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(encryptSelectionSheetDidEnd:returnCode:contextInfo:) contextInfo:aTextView];
}
*/
- (NSString *) gpgErrorDescription:(GPGError)error
{
    return GPGErrorDescription(error);
}

- (GPGErrorCode) gpgErrorCodeFromError:(GPGError)error
{
    return GPGErrorCodeFromError(error);
}

- (GPGErrorSource) gpgErrorSourceFromError:(GPGError)error
{
    return GPGErrorSourceFromError(error);
}

- (GPGError) gpgMakeErrorWithSource:(GPGErrorSource)source code:(GPGErrorCode)code
{
    return GPGMakeError(source, code);
}

@end

#import <AddressBook/AddressBook.h>

@interface ABGroup(GPGMail)
- (NSArray *) gpgFlattenedMembers;
@end


@implementation ABGroup(GPGMail)

- (NSArray *) gpgFlattenedMembers
{
    NSArray         *gpgFlattenedMembers = [self members];
    NSEnumerator    *anEnum = [[self subgroups] objectEnumerator];
    ABGroup         *aGroup;
    
    while((aGroup = [anEnum nextObject])){
        gpgFlattenedMembers = [gpgFlattenedMembers arrayByAddingObjectsFromArray:[aGroup gpgFlattenedMembers]];
    }
    
    return gpgFlattenedMembers;
}

@end

@implementation GPGMailBundle(AddressGroups)

- (void) synchronizeKeyGroupsWithAddressBookGroups
{
    // FIXME: Do that in secondary thread
    // We try to create/update gpg groups according to AB groups
    // We don't modify gpg groups not referenced in AB groups
    // We create/modify only gpg groups which have keys for all members
    NSEnumerator    *abGroupEnum = [[[ABAddressBook sharedAddressBook] groups] objectEnumerator];
    ABGroup         *aGroup;
    GPGContext      *aContext = [[GPGContext alloc] init];
    NSArray         *gpgGroups;
    GPGKeyGroup     *aKeyGroup;
    BOOL            groupsChanged = NO;
    
	@try{
		gpgGroups = [aContext keyGroups];
		while((aGroup = [abGroupEnum nextObject])){
			NSEnumerator    *memberEnum = [[aGroup gpgFlattenedMembers] objectEnumerator];
			ABPerson        *aMember;
			BOOL            someMemberHasNoEmail = NO;
			BOOL            someMemberHasNoKey = NO;
			NSMutableArray  *futureGroupKeys = [NSMutableArray array];
			GPGKeyGroup     *existingKeyGroup = nil;
			NSEnumerator    *keyGroupEnum = [gpgGroups objectEnumerator];
			NSString        *aGroupName = [aGroup valueForProperty:kABGroupNameProperty];
			
			while((aKeyGroup = [keyGroupEnum nextObject])){
				if([[aKeyGroup name] isEqualToString:aGroupName]){
					existingKeyGroup = aKeyGroup;
					break;
				}
			}
			
			while((aMember = [memberEnum nextObject])){
				ABMultiValue    *emailsValue = [aMember valueForProperty:kABEmailProperty];
				unsigned        aCount = [emailsValue count];
				
				if(aCount > 0){
					NSMutableArray  *emails = [NSMutableArray arrayWithCapacity:aCount];
					unsigned        i;
					NSArray         *gpgKeys;
					
					for(i = 0; i < aCount; i++)
						[emails addObject:[emailsValue valueAtIndex:i]];
					gpgKeys = [self keysForSearchPatterns:[emails valueForKey:@"gpgNormalizedEmail"] attributeName:@"normalizedEmail" secretKeys:NO];
					switch([gpgKeys count]){
						case 0:
							someMemberHasNoKey = YES;
							break;
						case 1:
							[futureGroupKeys addObject:[gpgKeys lastObject]];
							break;
						default:{
							// If existing gpg group already has user's key, use it, else ask which key(s) to choose
							BOOL    existingGroupHasKeyForMember = NO;
							
							if(existingKeyGroup){
								NSEnumerator    *keyEnumerator = [gpgKeys objectEnumerator];
								GPGKey          *aKey;
								
								while((aKey = [keyEnumerator nextObject])){
									if([[existingKeyGroup keys] containsObject:aKey]){
										existingGroupHasKeyForMember = YES;
										[futureGroupKeys addObject:aKey];
									}
								}
							}
							
							if(!existingGroupHasKeyForMember){
								//                            if(delegate)
								//                                gpgKeys = [delegate chooseKeys:gpgKeys forMember:aMember inGroup:aGroup];
								if([gpgKeys count] == 0)
									someMemberHasNoKey = YES;
								else
									[futureGroupKeys addObjectsFromArray:gpgKeys];
							}
						}
					}
					if(someMemberHasNoKey)
						break;
				}
				else{
					someMemberHasNoEmail = YES;
					break;
				}
			}
			
			if(!someMemberHasNoEmail && !someMemberHasNoKey){
                if(GPGMailLoggingLevel){
                    if(existingKeyGroup)
                        NSLog(@"[DEBUG] Will update group %@ having keys\n%@\nwith keys\n%@", aGroupName, [[existingKeyGroup keys] valueForKey:@"keyID"], [futureGroupKeys valueForKey:@"keyID"]);
                    else
                        NSLog(@"[DEBUG] Will create group %@ with keys\n%@", aGroupName, [futureGroupKeys valueForKey:@"keyID"]);
                }
				@try{
					(void)[GPGKeyGroup createKeyGroupNamed:aGroupName withKeys:futureGroupKeys];
					groupsChanged = YES;
				}@catch(NSException *localException){
					// FIXME: Report to user that group name is invalid?
					// Let's ignore the error
				}
			}
		}
	}@catch(NSException *localException){
		// FIXME: Report to user that group name is invalid?
		// Let's ignore the error
		[aContext release];
		[localException raise];
    }
	[aContext release];
			
    if(groupsChanged)
        // FIXME: Post in main thread
        [[NSNotificationCenter defaultCenter] postNotificationName:GPGKeyGroupsChangedNotification object:nil];
}

- (void) abDatabaseChangedExternally:(NSNotification *)notification
{
    // FIXME: Update only what's needed
    [self synchronizeKeyGroupsWithAddressBookGroups];
}

- (void) abDatabaseChanged:(NSNotification *)notification
{
    // FIXME: Update only what's needed
    [self synchronizeKeyGroupsWithAddressBookGroups];
}

- (void) keyringChanged:(NSNotification *)notification
{
    [self gpgReloadPGPKeys:nil];
}

@end
