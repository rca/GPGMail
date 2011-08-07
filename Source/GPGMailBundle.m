/* GPGMailBundle.m created by dave on Thu 29-Jun-2000 */

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

#import <objc/objc.h>
#import <objc/objc-class.h>
#import <ExceptionHandling/ExceptionHandling.h>
#import <Sparkle/Sparkle.h>
#import <MailApp.h>
#import <MailAccount.h>
#import "JRSwizzle.h"
#import "CCLog.h"
#import "NSSet+Functional.h"
#import "NSString+GPGMail.h"
#import "GPGDefaults.h"
#import "GPGMailPreferences.h"
#import "GPGKeyDownload.h"
#import "GPGProgressIndicatorController.h"
#import "GPGMailBundle.h"


// The following strings are used as toolbarItem identifiers and userDefault keys (value is the position index)
NSString *GPGKeyListWasInvalidatedNotification = @"GPGKeyListWasInvalidatedNotification";
NSString *GPGPreferencesDidChangeNotification = @"GPGPreferencesDidChangeNotification";
NSString *GPGKeyGroupsChangedNotification = @"GPGKeyGroupsChangedNotification";
NSString *GPGMissingKeysNotification = @"GPGMissingKeysNotification";
NSString *GPGKeyringChangedNotification = @"GPGKeyringChangedNotification";
NSString *GPGMailException = @"GPGMailException";
NSString *GPGMailSwizzledMethodPrefix = @"MA";
NSString *GPGMailAgent = @"GPGMail %@";

int GPGMailLoggingLevel = 1;

static BOOL gpgMailWorks = YES;

@interface NSObject (GPGMailBundle)
// Service implemented by Mail.app
- (void)mailTo:(NSPasteboard *)pasteboard userData:(NSString *)userData error:(NSString **)error;
@end

@interface GPGMailBundle (Private)
- (void)refreshPersonalKeysMenu;
- (void)refreshPublicKeysMenu;
- (void)flushKeyCache:(BOOL)flag;
@end

@implementation GPGMailBundle

@synthesize cachedPublicGPGKeys, cachedPersonalGPGKeys, cachedGPGKeys;

+ (void)load {
	//GPGMailLoggingLevel = [[GPGDefaults standardDefaults] integerForKey:@"GPGMailDebug"];
	[[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask:NSLogOtherExceptionMask | NSLogTopLevelExceptionMask];
}

/**
 This method replaces all of Mail's methods which are necessary for GPGMail
 to work correctly.
 
 For each class of Mail that must be extended, a class with the same name
 and suffix _GPGMail (<ClassName>_GPGMail) exists which implements the methods
 to be relaced.
 On runtime, these methods are first added to the original Mail class and
 after that, the original Mail methods are swizzled with the ones of the 
 <ClassName>_GPGMail class.
 
 swizzleMap contains all classes and methods which need to be swizzled.
 */
+ (void)_installGPGMail {
	DebugLog(@"Adding GPGMail methods");
    
    NSArray *swizzleMap = [NSArray arrayWithObjects:
        // Mail internal classes.
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"MessageHeaderDisplay", @"class", 
            @"MessageHeaderDisplay_GPGMail", @"gpgMailClass",
            [NSArray arrayWithObjects:
                @"_attributedStringForSecurityHeader", 
                @"textView:clickedOnLink:atIndex:", nil], @"selectors", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"MailAccount", @"class",
            @"MailAccount_GPGMail", @"gpgMailClass", 
            [NSArray arrayWithObjects:
                @"accountExistsForSigning", nil], @"selectors", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"ComposeBackEnd", @"class", 
            @"ComposeBackEnd_GPGMail", @"gpgMailClass", 
            [NSArray arrayWithObjects:
                @"_makeMessageWithContents:isDraft:shouldSign:shouldEncrypt:shouldSkipSignature:shouldBePlainText:", 
                @"canEncryptForRecipients:sender:",
                @"canSignFromAddress:",
                @"recipientsThatHaveNoKeyForEncryption", nil], @"selectors", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"ComposeHeaderView", @"class", 
            @"ComposeHeaderView_GPGMail", @"gpgMailClass",
            [NSArray arrayWithObjects:
                @"_calculateSecurityFrame:", 
                @"awakeFromNib", nil], @"selectors", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"OptionalView", @"class", 
            @"OptionalView_GPGMail", @"gpgMailClass",
            [NSArray arrayWithObjects:
                @"widthIncludingOptionSwitch:", nil], @"selectors", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"MessageContentController", @"class",
            @"MessageContentController_GPGMail", @"gpgMailClass",
            [NSArray arrayWithObjects:
                @"setMessageToDisplay:", nil], @"selectors", nil],
        // Messages.framework classes. Messages.framework classes can be extended using
        // categories. No need for a special GPGMail class.
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"MimePart", @"class", 
            [NSArray arrayWithObjects:
                @"isEncrypted",
                @"newEncryptedPartWithData:recipients:encryptedData:", 
                @"newSignedPartWithData:sender:signatureData:", 
                @"verifySignature", 
                @"decodeWithContext:", 
                @"copySignerLabels", 
                @"isSigned", 
                @"usesKnownSignatureProtocol", 
                @"decodeTextPlainWithContext:", nil], @"selectors", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"MimeBody", @"class", 
            [NSArray arrayWithObjects:
                @"isSignedByMe", nil], @"selectors", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"NSPreferences", @"class", 
            [NSArray arrayWithObjects:
                @"sharedPreferences", nil], @"selectors", nil],
        nil];

    
    NSError *error = nil;
    for(NSDictionary *swizzleInfo in swizzleMap) {
        // If this is a non Messages.framework class, add all methods
        // of the class referenced in gpgMailClass first.
        Class mailClass = NSClassFromString([swizzleInfo objectForKey:@"class"]);
        if([swizzleInfo objectForKey:@"gpgMailClass"]) {
            Class gpgMailClass = NSClassFromString([swizzleInfo objectForKey:@"gpgMailClass"]);
            if(!mailClass) {
                NSLog(@"Class %@ doesn't exist", mailClass);
                break;
            }
            if(!gpgMailClass) {
                NSLog(@"Class %@ doesn't exist", gpgMailClass);
                break;
            }
            [mailClass jr_addMethodsFromClass:gpgMailClass error:&error];
            if(error)
                DebugLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
            error = nil;
        }
        for(NSString *method in [swizzleInfo objectForKey:@"selectors"]) {
            error = nil;
            NSString *gpgMethod = [NSString stringWithFormat:@"%@%@%@", GPGMailSwizzledMethodPrefix, [[method substringToIndex:1] uppercaseString], [method substringFromIndex:1]]; 
            [mailClass jr_swizzleMethod:NSSelectorFromString(method) withMethod:NSSelectorFromString(gpgMethod) error:&error];
            if(error) {
                error = nil;
                // Try swizzling as class method on error.
                [mailClass jr_swizzleClassMethod:NSSelectorFromString(method) withClassMethod:NSSelectorFromString(gpgMethod) error:&error];
                if(error)
                    DebugLog(@"[DEBUG] %s Class Error: %@", __PRETTY_FUNCTION__, error);
            }
        }
    }
    
}

+ (void)initialize {
	// Make sure the initializer is only run once.
    // Usually is run, for every class inheriting from
    // GPGMailBundle.
    if(self != [GPGMailBundle class])
        return;
    
    Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
    // If this class is not available that means Mail.app
    // doesn't allow plugins anymore. Fingers crossed that this
    // never happens!
    if(!mvMailBundleClass)
        return;
    
    class_setSuperclass([self class], mvMailBundleClass);
	// Last step necessary to completely setup our bundle is
    // swizzling the Mail classes.
    [self _installGPGMail];
    // Load all necessary images.
    [self _loadImages];
    // Install the Sparkle Updater.
    [self _installSparkleUpdater];
    NSLog(@"Loaded GPGMail %@", [(GPGMailBundle *)[self sharedInstance] version]);
	
    [((MVMailBundle *)[self class]) registerBundle];             // To force registering composeAccessoryView and preferences
}

/**
 * Loads all images which are used in the GPGMail User interface.
 */
+ (void)_loadImages {
    // We need to load images and name them, because all images are searched by their name; as they are not located in the main bundle,
	// +[NSImage imageNamed:] does not find them.
	NSBundle *myBundle = [NSBundle bundleForClass:self];
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
}

/**
 Installs the sparkle updater.
 TODO: Sparkle should automatically start to check, but sometimes it doesn't work.
 */
+ (void)_installSparkleUpdater {
	SUUpdater *updater = [SUUpdater updaterForBundle:[NSBundle bundleForClass:[self class]]];
	updater.delegate = [self sharedInstance];
	// [updater setAutomaticallyChecksForUpdates:YES];
	[updater resetUpdateCycle];
}

- (NSString *)pathToRelaunchForUpdater:(SUUpdater *)updater {
	return @"/Applications/Mail.app";
}

+ (BOOL)hasPreferencesPanel {
	return gpgMailWorks;             // LEOPARD Invoked on +initialize. Else, invoked from +registerBundle
}

+ (NSString *)preferencesOwnerClassName {
	return NSStringFromClass([GPGMailPreferences class]);
}

+ (NSString *)preferencesPanelName {
	return NSLocalizedStringFromTableInBundle(@"PGP_PREFERENCES", @"GPGMail", [NSBundle bundleForClass:self], "PGP preferences panel name");
}

+ (BOOL)gpgMailWorks {
	return gpgMailWorks;
}

/**
 Allows to run one decryption task at a time.
 This is necessary to ensure that pinentry password requests
 are not displayed concurrently.
 */
- (void)addDecryptionTask:(gpgmail_decryption_task_t)task {
    dispatch_sync(decryptionQueue, task);
}

- (BOOL)gpgMailWorks {
	return gpgMailWorks;
}

- (NSMenuItem *)newMenuItemWithTitle:(NSString *)title action:(SEL)action andKeyEquivalent:(NSString *)keyEquivalent inMenu:(NSMenu *)menu relativeToItemWithSelector:(SEL)selector offset:(int)offset {
// Taken from /System/Developer/Examples/EnterpriseObjects/AppKit/ModelerBundle/EOUtil.m

	// Simple utility category which adds a new menu item with title, action
	// and keyEquivalent to menu (or one of its submenus) under that item with
	// selector as its action.  Returns the new addition or nil if no such
	// item could be found.

	NSMenuItem *menuItem;
	NSArray *items = [menu itemArray];
	int iI;

	if (!keyEquivalent) {
		keyEquivalent = @"";
	}

	for (iI = 0; iI < (int)[items count]; iI++) {
		menuItem = [items objectAtIndex:iI];

		if ([menuItem action] == selector) {
			return ([[menu insertItemWithTitle:title action:action keyEquivalent:keyEquivalent atIndex:iI + offset] retain]);
		} else if ([[menuItem target] isKindOfClass:[NSMenu class]]) {
			menuItem = [self newMenuItemWithTitle:title action:action andKeyEquivalent:keyEquivalent inMenu:[menuItem target] relativeToItemWithSelector:selector offset:offset];
			if (menuItem) {
				return menuItem;
			}
		}
	}

	return nil;
}

- (void)setPGPMenu:(NSMenu *)pgpMenu {
//	if (gpgMailWorks) {
//		pgpMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"PGP_MENU", @"GPGMail", [NSBundle bundleForClass:[self class]], "<PGP> submenu title") action:NULL andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:@selector(addSenderToAddressBook:) offset:1];
//
//		if (!pgpMenuItem) {
//			DebugLog(@"### GPGMail: unable to add submenu <PGP>");
//		} else {
//			[[pgpMenuItem menu] insertItem:[NSMenuItem separatorItem] atIndex:[[pgpMenuItem menu] indexOfItem:pgpMenuItem]];
//			[[pgpMenuItem menu] setSubmenu:pgpMenu forItem:pgpMenuItem];
//			[encryptsNewMessageMenuItem setState:NSOffState];
//			[signsNewMessageMenuItem setState:([self alwaysSignMessages] ? NSOnState:NSOffState)];
//			[pgpMenuItem retain];
//			[self refreshPersonalKeysMenu];
//			[self refreshPublicKeysMenu];
//#warning CHECK: keys not synced with current editor?
//		}
//	}
}

- (void)refreshKeyIdentifiersDisplayInMenu:(NSMenu *)menu {
	NSArray *displayedKeyIdentifiers = [self displayedKeyIdentifiers];
	int i = 1;

    for (NSString *anIdentifier in [self allDisplayedKeyIdentifiers]) {
		if (![displayedKeyIdentifiers containsObject:anIdentifier]) {
			[[menu itemWithTag:i] setState:NSOffState];
		} else {
			[[menu itemWithTag:i] setState:NSOnState];
		}
		i++;
	}
}

- (void)setPGPViewMenu:(NSMenu *)pgpViewMenu {
	if (gpgMailWorks) {
		SEL targetSelector;

		targetSelector = @selector(toggleThreadedMode:);
		pgpViewMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"PGP_KEYS_MENU", @"GPGMail", [NSBundle bundleForClass:[self class]], "<PGP Keys> submenu title") action:NULL andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:targetSelector offset:-1];

		if (!pgpViewMenuItem) {
			DebugLog(@"### GPGMail: unable to add submenu <PGP Keys>");
		} else {
			NSMenu *aMenu = [pgpViewMenuItem menu];
/*            int		anIndex = [aMenu indexOfItem:pgpViewMenuItem];
 *
 *          [pgpViewMenuItem retain];
 *          while(--anIndex > 0)
 *              if([[aMenu itemAtIndex:anIndex] isSeparatorItem])
 *                  break;
 *          if(anIndex > 0){
 *              [aMenu removeItem:pgpViewMenuItem];
 *              [aMenu insertItem:pgpViewMenuItem atIndex:anIndex];
 *          }*/
			[aMenu setSubmenu:pgpViewMenu forItem:pgpViewMenuItem];

			[self refreshKeyIdentifiersDisplayInMenu:pgpViewMenu];
		}
	}
}

#pragma mark Toolbar stuff (+contextual menu)

- (void)refreshPersonalKeysMenu {
	GPGKey *theDefaultKey = [self defaultKey];
	NSMenu *aSubmenu = [personalKeysMenuItem submenu];
	NSMenuItem *anItem;
	BOOL displaysAllUserIDs = [self displaysAllUserIDs];

    
    [aSubmenu removeAllItems];

    DebugLog(@"Personal Keys: %@", [self personalKeys]);
    
    for (GPGKey *aKey in [self personalKeys]) {
		NSString *title = [self menuItemTitleForKey:aKey];
        anItem = [aSubmenu addItemWithTitle:title action:@selector(gpgChoosePersonalKey:) keyEquivalent:@""];
        [anItem setRepresentedObject:aKey];
		[anItem setTarget:self];
		if (![self canKeyBeUsedForSigning:aKey]) {
			[anItem setEnabled:NO];
		}
        if (theDefaultKey && [aKey isEqual:theDefaultKey]) {
            [anItem setState:NSMixedState];
        }
		if (displaysAllUserIDs) {
            for (GPGUserID *aUserID in [self secondaryUserIDsForKey:aKey]) {
				anItem = [aSubmenu addItemWithTitle:[self menuItemTitleForUserID:aUserID indent:1] action:NULL keyEquivalent:@""];
				[anItem setEnabled:NO];
			}
		}
	}
}

- (void)refreshPublicKeysMenu {
	DebugLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
    NSMenu *aSubmenu = [choosePublicKeysMenuItem menu];
    GPGKey *theDefaultKey = [self publicKeyForSecretKey:[self defaultKey]];
    NSMenuItem *anItem;

    NSUInteger count = [[aSubmenu itemArray] count];
    for (; count > GPGENCRYPTION_MENU_ITEMS_COUNT; count--) {
        [aSubmenu removeItemAtIndex:GPGENCRYPTION_MENU_ITEMS_COUNT];
    }
    
	if ([self encryptsToSelf] && theDefaultKey) {
		anItem = [aSubmenu addItemWithTitle:[self menuItemTitleForKey:theDefaultKey] action:NULL keyEquivalent:@""];
        [anItem setEnabled:[self canKeyBeUsedForEncryption:theDefaultKey]];
        
		if ([self displaysAllUserIDs]) {
            for (GPGUserID *aUserID in [self secondaryUserIDsForKey:theDefaultKey]) {
				anItem = [aSubmenu addItemWithTitle:[self menuItemTitleForUserID:aUserID indent:1] action:NULL keyEquivalent:@""];
				[anItem setEnabled:NO];
			}
		}
	}
}

- (void)checkPGPmailPresence {
	if (![self ignoresPGPPresence]) {
		if (NSClassFromString(@"PGPMailBundle") != Nil) {
			NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
			NSString *errorTitle = NSLocalizedStringFromTableInBundle(@"GPGMAIL_VS_PGPMAIL", @"GPGMail", myBundle, "");
			NSString *errorMessage = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"GPGMAIL_%@_VS_PGPMAIL_%@", @"GPGMail", myBundle, ""), [myBundle bundlePath], [[NSBundle bundleForClass:NSClassFromString(@"PGPMailBundle")] bundlePath]];

			if (NSRunCriticalAlertPanel(errorTitle, @"%@", NSLocalizedStringFromTableInBundle(@"QUIT", @"GPGMail", myBundle, ""), NSLocalizedStringFromTableInBundle(@"CONTINUE_ANYWAY", @"GPGMail", myBundle, ""), nil, errorMessage) == NSAlertDefaultReturn) {
				[[NSApplication sharedApplication] terminate:nil];
			} else {
				[self setIgnoresPGPPresence:YES];
			}
		}
	}
}

// TODO: Fix me for libmacgpg
- (BOOL)checkGPG {
    GPGErrorCode errorCode = [[GPGController gpgController] testGPG];
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    switch (errorCode) {
        case GPGErrorNotFound:
            NSRunCriticalAlertPanel(NSLocalizedStringFromTableInBundle(@"GPG_NOT_FOUND_TITLE", @"GPGMail", myBundle, ""), NSLocalizedStringFromTableInBundle(@"GPG_NOT_FOUND_MESSAGE", @"GPGMail", myBundle, ""), nil, nil, nil);
            break;
        case GPGErrorConfigurationError:
            NSRunCriticalAlertPanel(NSLocalizedStringFromTableInBundle(@"GPG_CONFIG_ERROR_TITLE", @"GPGMail", myBundle, ""), NSLocalizedStringFromTableInBundle(@"GPG_CONFIG_ERROR_MESSAGE", @"GPGMail", myBundle, ""), nil, nil, nil);
            break;
        case GPGErrorNoError:
            return YES;
        default:
            break;
    }
    return NO;
}


// TODO: Rewrite! Find better way to check for Snow Leopard and
// Lion. (Isn't setting the deployment target enough?!)
- (BOOL)checkSystem {
	BOOL isCompatibleSystem;

	isCompatibleSystem = (NSClassFromString(@"NSGarbageCollector") != Nil);

	if (!isCompatibleSystem) {
		NSBundle *aBundle = [NSBundle bundleForClass:[self class]];

		(void)NSRunCriticalAlertPanel(NSLocalizedStringFromTableInBundle(@"INVALID_GPGMAIL_VERSION", @"GPGMail", aBundle, "Alert panel title"), @"%@", nil, nil, nil, NSLocalizedStringFromTableInBundle(@"NEEDS_COMPATIBLE_BUNDLE_VERSION", @"GPGMail", aBundle, "Alert panel message"));
	}

	return isCompatibleSystem;
}

- (void)finishInitialization {
	NSMenuItem *aMenuItem;
    
    // Load all keys.
    [self loadGPGKeys];
    
    DebugLog(@"Personal Keys: %@", [self personalKeys]);
    DebugLog(@"Public Keys: %@", [self publicKeys]);
    
    // Create the decryption queue.
    decryptionQueue = dispatch_queue_create("org.gpgmail.decryption", NULL);
    
	// There's a bug in MOX: added menu items are not enabled/disabled correctly
	// if they are instantiated programmatically
	NSAssert([NSBundle loadNibNamed:@"GPGMenu" owner:self], @"### GPGMail: -[GPGMailBundle init]: Unable to load nib named GPGMenu");
	// If we disable usurpation, we can't set contextual menu?!

	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceDidMount:) name:NSWorkspaceDidMountNotification object:[NSWorkspace sharedWorkspace]];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceDidUnmount:) name:NSWorkspaceDidUnmountNotification object:[NSWorkspace sharedWorkspace]];
	[allUserIDsMenuItem setState:([self displaysAllUserIDs] ? NSOnState:NSOffState)];

	aMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"PGP_SEARCH_KEYS_MENUITEM", @"GPGMail", [NSBundle bundleForClass:[self class]], "<PGP Key Search> menuItem title") action:@selector(gpgSearchKeys:) andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:@selector(showAddressHistoryPanel:) offset:1];

	if (!aMenuItem) {
		DebugLog(@"### GPGMail: unable to add menuItem <PGP Key Search>");
	} else {
		[aMenuItem setTarget:self];
	}
    [aMenuItem release];

	// Addition which has nothing to do with GPGMail
	if ([[GPGDefaults gpgDefaults] boolForKey:@"GPGEnableMessageURLCopy"]) {
		aMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"COPY_MSG_URL_MENUITEM", @"GPGMail", [NSBundle bundleForClass:[self class]], "<Copy Message URL> menuItem title") action:@selector(gpgCopyMessageURL:) andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:@selector(pasteAsQuotation:) offset:0];
        [aMenuItem release];
    }
    
	[self performSelector:@selector(checkPGPmailPresence) withObject:nil afterDelay:0];

	[(NSDistributedNotificationCenter *)[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(keyringChanged:) name:GPGKeyringChangedNotification object:nil];
}

- (id)init {
	if (self = [super init]) {
		NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
		NSDictionary *defaultsDictionary = [NSDictionary dictionaryWithContentsOfFile:[myBundle pathForResource:@"GPGMailBundle" ofType:@"defaults"]];

		if (gpgMailWorks) {
			gpgMailWorks = [self checkSystem];
		}

		if (defaultsDictionary) {
			[[GPGDefaults gpgDefaults] registerDefaults:defaultsDictionary];
		}

		if (gpgMailWorks) {
			gpgMailWorks = [self checkGPG];
		}
		if (gpgMailWorks) {
			[self finishInitialization];
		}
	}

	return self;
}

- (void)workspaceDidMount:(NSNotification *)notification {
	// Some people put their keys on a mountable volume, and sometimes don't mount that volume
	// before launching Mail. In case the keyrings are in a newly-mounted volume, we refresh them
	if ([self refreshesKeysOnVolumeMount]) {
		[self flushKeyCache:YES];
	}
}

- (void)workspaceDidUnmount:(NSNotification *)notification {
	// Some people put their keys on a mountable volume, and sometimes don't mount that volume
	// before launching Mail. In case the keyrings are in a newly-mounted volume, we refresh them
	if ([self refreshesKeysOnVolumeMount]) {
		[self flushKeyCache:YES];
	}
}

- (void)dealloc {
    // Release the decryption queue.
    dispatch_release(decryptionQueue);
    
    cachedPersonalGPGKeys = nil;
    [cachedPersonalGPGKeys release];
    cachedPublicGPGKeys = nil;
    [cachedPublicGPGKeys release];
    [cachedGPGKeys release];
    
	// Never invoked...
	if (cachedUserIDsPerKey != NULL) {
		NSFreeMapTable(cachedUserIDsPerKey);
	}
	[cachedKeyGroups release];
	[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:nil object:nil];
	[locale release];

	struct objc_super s = { self, [self superclass] };
    objc_msgSendSuper(&s, @selector(dealloc));
}

- (NSString *)versionDescription {
	return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"VERSION: %@", @"GPGMail", [NSBundle bundleForClass:[self class]], "Description of version prefixed with <Version: >"), [self version]];
}

- (NSString *)version {
	return [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

@synthesize decryptMenuItem;
@synthesize authenticateMenuItem;
@synthesize encryptsNewMessageMenuItem;
@synthesize signsNewMessageMenuItem;
@synthesize personalKeysMenuItem;
@synthesize choosePublicKeysMenuItem;
@synthesize automaticPublicKeysMenuItem;
@synthesize symetricEncryptionMenuItem;
@synthesize usesOnlyOpenPGPStyleMenuItem;
@synthesize pgpMenuItem;
@synthesize pgpViewMenuItem;
@synthesize allUserIDsMenuItem;

- (void)preferencesDidChange:(SEL)selector {
	NSString *aString = NSStringFromSelector(selector);

	aString = [[[aString substringWithRange:NSMakeRange(3, 1)] lowercaseString] stringByAppendingString:[aString substringWithRange:NSMakeRange(4, [aString length] - 5)]];
	// aString is the 'getter' derived from the 'setter' selector (setXXX:)
	[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] postNotificationName:GPGPreferencesDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObject:aString forKey:@"key"]];
}

- (void)setAlwaysSignMessages:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAlwaysSignMessage"];
	if (![signsNewMessageMenuItem isEnabled]) {
		[signsNewMessageMenuItem setState:(flag ? NSOnState:NSOffState)];
	}
	[self preferencesDidChange:_cmd];
}

- (BOOL)alwaysSignMessages {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAlwaysSignMessage"];
}

- (void)setAlwaysEncryptMessages:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAlwaysEncryptMessage"];
	// FIXME: Update menu for mixed
	if (![encryptsNewMessageMenuItem isEnabled]) {
		[encryptsNewMessageMenuItem setState:(flag ? NSOnState:NSOffState)];
	}
	[self preferencesDidChange:_cmd];
}

- (BOOL)alwaysEncryptMessages {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAlwaysEncryptMessage"];
}

- (void)setEncryptMessagesWhenPossible:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGEncryptMessageWhenPossible"];
	// FIXME: Update menu
//    if(![encryptsNewMessageMenuItem isEnabled])
//        [encryptsNewMessageMenuItem setState:(flag ? NSOnState:NSOffState)];
	[self preferencesDidChange:_cmd];
}

- (BOOL)encryptMessagesWhenPossible {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGEncryptMessageWhenPossible"];
}

- (void)setDefaultKey:(GPGKey *)key {
	if (key != nil) {
		[[GPGDefaults gpgDefaults] setObject:[key fingerprint] forKey:@"GPGDefaultKeyFingerprint"];
		[key retain];
		[defaultKey release];
		defaultKey = key;
	} else {
		[[GPGDefaults gpgDefaults] removeObjectForKey:@"GPGDefaultKeyFingerprint"];
		[defaultKey release];
		defaultKey = nil;
	}
	[self refreshPersonalKeysMenu];
	[self refreshPublicKeysMenu];
	[self preferencesDidChange:_cmd];
}

- (GPGKey *)defaultKey {
	if (defaultKey == nil && gpgMailWorks) {        
		NSString *aPattern = [[GPGDefaults gpgDefaults] stringForKey:@"GPGDefaultKeyFingerprint"];
		BOOL searchedAllKeys = NO;
		BOOL fprPattern = YES;

		if (!aPattern || [aPattern length] == 0) {
            // Lion doesn't have userEmail... unfortunately.
            //aPattern = [NSApp userEmail];
			aPattern = @"";
            fprPattern = NO;
            if (!aPattern || [aPattern length] == 0) {
                aPattern = nil; // Return all secret keys
            }
		}
        
		do {
            NSArray *patterns;
            if (aPattern) {
                if (fprPattern) {
                    patterns = [NSArray arrayWithObject:aPattern];
                } else {
                    patterns = [NSArray arrayWithObject:[aPattern valueForKey:@"gpgNormalizedEmail"]];
                }
            } else {
                patterns = nil;
            }

            NSArray *keys = [self keysForSearchPatterns:patterns attributeName:(fprPattern ? @"primaryKey.fingerprint" : @"email") secretKeys:YES];
            if ([keys count] > 0) {
                [defaultKey release];
                defaultKey = [[keys objectAtIndex:0] retain];
            }
            
			if (aPattern == nil) {
				searchedAllKeys = YES;
			} else {
				aPattern = nil;
			}
		} while (defaultKey == nil && !searchedAllKeys);
	}

	return defaultKey;
}

//- (void)setRemembersPassphrasesDuringSession:(BOOL)flag {
//	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGRemembersPassphrasesDuringSession"];
//	[GPGPassphraseController setCachesPassphrases:flag];
//	[self preferencesDidChange:_cmd];
//}
//
- (BOOL)remembersPassphrasesDuringSession {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGRemembersPassphrasesDuringSession"];
}

- (void)setDecryptsMessagesAutomatically:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDecryptsMessagesAutomatically"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)decryptsMessagesAutomatically {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGDecryptsMessagesAutomatically"];
}

- (void)setAuthenticatesMessagesAutomatically:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAuthenticatesMessagesAutomatically"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)authenticatesMessagesAutomatically {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAuthenticatesMessagesAutomatically"];
}

- (void)setDisplaysButtonsInComposeWindow:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDisplaysButtonsInComposeWindow"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)displaysButtonsInComposeWindow {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGDisplaysButtonsInComposeWindow"];
}

- (void)setEncryptsToSelf:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGEncryptsToSelf"];
	[self refreshPublicKeysMenu];
	[self preferencesDidChange:_cmd];
}

- (BOOL)encryptsToSelf {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGEncryptsToSelf"];
}

- (void)setUsesKeychain:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGUsesKeychain"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)usesKeychain {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGUsesKeychain"];
}

- (void)setUsesOnlyOpenPGPStyle:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGOpenPGPStyleOnly"];
	if (![usesOnlyOpenPGPStyleMenuItem isEnabled]) {
		[usesOnlyOpenPGPStyleMenuItem setState:(flag ? NSOnState:NSOffState)];
	}
	[self preferencesDidChange:_cmd];
}

- (BOOL)usesOnlyOpenPGPStyle {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGOpenPGPStyleOnly"];
}

- (void)setDecryptsOnlyUnreadMessagesAutomatically:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDecryptsOnlyUnreadMessagesAutomatically"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)decryptsOnlyUnreadMessagesAutomatically {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGDecryptsOnlyUnreadMessagesAutomatically"];
}

- (void)setAuthenticatesOnlyUnreadMessagesAutomatically:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAuthenticatesOnlyUnreadMessagesAutomatically"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)authenticatesOnlyUnreadMessagesAutomatically {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAuthenticatesOnlyUnreadMessagesAutomatically"];
}

- (void)setUsesEncapsulatedSignature:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGUsesEncapsulatedSignature"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)usesEncapsulatedSignature {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGUsesEncapsulatedSignature"];
}

- (void)setUsesBCCRecipients:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGUsesBCCRecipients"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)usesBCCRecipients {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGUsesBCCRecipients"];
}

- (void)setTrustsAllKeys:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGTrustsAllKeys"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)trustsAllKeys {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGTrustsAllKeys"];
}

- (void)setAutomaticallyShowsAllInfo:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAutomaticallyShowsAllInfo"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)automaticallyShowsAllInfo {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAutomaticallyShowsAllInfo"];
}

- (void)setPassphraseFlushTimeout:(NSTimeInterval)timeout {
	NSParameterAssert(timeout >= 0.0);
	[[GPGDefaults gpgDefaults] setFloat:timeout forKey:@"GPGPassphraseFlushTimeout"];
	[self preferencesDidChange:_cmd];
}

- (NSTimeInterval)passphraseFlushTimeout {
	return [[GPGDefaults gpgDefaults] floatForKey:@"GPGPassphraseFlushTimeout"];
}

- (void)setChoosesPersonalKeyAccordingToAccount:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGChoosesPersonalKeyAccordingToAccount"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)choosesPersonalKeyAccordingToAccount {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGChoosesPersonalKeyAccordingToAccount"];
}

- (void)setButtonsShowState:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGButtonsShowState"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)buttonsShowState {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGButtonsShowState"];
}

- (void)setSignWhenEncrypting:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGSignWhenEncrypting"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)signWhenEncrypting {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGSignWhenEncrypting"];
}

- (NSArray *)allDisplayedKeyIdentifiers {
	static NSArray *allDisplayedKeyIdentifiers = nil;

	if (!allDisplayedKeyIdentifiers) {
		// TODO: After adding longKeyID, update GPGPreferences.nib
		allDisplayedKeyIdentifiers = [[NSArray arrayWithObjects:@"name", @"email", @"comment", @"fingerprint", @"keyID", /*@"longKeyID",*/ @"validity", @"algorithm", nil] retain];
	}

	return allDisplayedKeyIdentifiers;
}

- (void)setDisplayedKeyIdentifiers:(NSArray *)keyIdentifiers {
    NSArray *allKeyIdentifiers = [self allDisplayedKeyIdentifiers];
  
    for (NSString *anIdentifier in keyIdentifiers) {
        NSAssert1([allKeyIdentifiers containsObject:anIdentifier], @"### GPGMail: -[GPGMailBundle setDisplayedKeyIdentifiers:]: invalid identifier '%@'", anIdentifier);
    }
	
    
    [[GPGDefaults gpgDefaults] setObject:keyIdentifiers forKey:@"GPGDisplayedKeyIdentifiers"];
	[self refreshPublicKeysMenu];
	[self refreshPersonalKeysMenu];
	[self refreshKeyIdentifiersDisplayInMenu:[[self pgpViewMenuItem] submenu]];
	[self preferencesDidChange:_cmd];
}

- (NSArray *)displayedKeyIdentifiers {
	return [[GPGDefaults gpgDefaults] arrayForKey:@"GPGDisplayedKeyIdentifiers"];
}

- (void)setDisplaysAllUserIDs:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDisplaysAllUserIDs"];
	[self refreshPublicKeysMenu];
	[self refreshPersonalKeysMenu];
	[allUserIDsMenuItem setState:([self displaysAllUserIDs] ? NSOnState:NSOffState)];
	[self preferencesDidChange:_cmd];
}

- (BOOL)displaysAllUserIDs {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGDisplaysAllUserIDs"];
}

- (void)setFiltersOutUnusableKeys:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGFiltersOutUnusableKeys"];
	[self flushKeyCache:YES];
	[self preferencesDidChange:_cmd];
}

- (BOOL)filtersOutUnusableKeys {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGFiltersOutUnusableKeys"];
}

- (void)setShowsPassphrase:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGShowsPassphrase"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)showsPassphrase {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGShowsPassphrase"];
}

- (void)setLineWrappingLength:(int)value {
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"LineLength"];
	[self preferencesDidChange:_cmd];
}

- (long)lineWrappingLength {
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"LineLength"];
}

- (void)setIgnoresPGPPresence:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGIgnoresPGPPresence"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)ignoresPGPPresence {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGIgnoresPGPPresence"];
}

- (void)setRefreshesKeysOnVolumeMount:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGRefreshesKeysOnVolumeMount"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)refreshesKeysOnVolumeMount {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGRefreshesKeysOnVolumeMount"];
}

- (void)setDisablesSMIME:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDisablesSMIME"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)disablesSMIME {
	return gpgMailWorks && [[GPGDefaults gpgDefaults] boolForKey:@"GPGDisablesSMIME"];
}

- (void)setWarnedAboutMissingPrivateKeys:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGWarnedAboutMissingPrivateKeys"];
}

- (BOOL)warnedAboutMissingPrivateKeys {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGWarnedAboutMissingPrivateKeys"];
}

- (void)setEncryptsReplyToEncryptedMessage:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGEncryptsReplyToEncryptedMessage"];
}

- (BOOL)encryptsReplyToEncryptedMessage {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGEncryptsReplyToEncryptedMessage"];
}

- (void)setSignsReplyToSignedMessage:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGSignsReplyToSignedMessage"];
}

- (BOOL)signsReplyToSignedMessage {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGSignsReplyToSignedMessage"];
}

- (void)setUsesABEntriesRules:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGUsesABEntriesRules"];
}

- (BOOL)usesABEntriesRules {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGUsesABEntriesRules"];
}

- (void)setAddsCustomHeaders:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAddCustomHeaders"];
}

- (BOOL)addsCustomHeaders {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAddCustomHeaders"];
}

- (void)mailTo:(id)sender {
	NSString *error = nil;
	NSPasteboard *aPasteboard = [NSPasteboard pasteboardWithUniqueName];
	NSArray *pbTypes = [NSArray arrayWithObject:NSStringPboardType];
	id serviceProvider = [NSApplication sharedApplication];

	(void)[aPasteboard declareTypes:pbTypes owner:nil];
	(void)[aPasteboard addTypes:pbTypes owner:nil];
	(void)[aPasteboard setString:@"gpgtools-users@lists.gpgtools.org" forType:NSStringPboardType];

	// Invoke <MailViewer/Mail To> service
	if ([serviceProvider respondsToSelector:@selector(mailTo:userData:error:)]) {
		[(MailApp *)serviceProvider mailTo:aPasteboard userData:nil error:&error];
	}
	if (error) {
		NSBeep();
	}
}

//- (void)gpgForwardAction:(SEL)action from:(id)sender {
//	// Still used as of v37 for encrypt/sign toolbar buttons
//	id messageEditor = [[NSApplication sharedApplication] targetForAction:action];
//
//	if (messageEditor && [messageEditor respondsToSelector:action]) {
//		[messageEditor performSelector:action withObject:sender];
//	}
//}

// TODO: Implement something useful!
- (BOOL)validateMenuItem:(NSMenuItem *)theItem {
	return YES;
}

- (IBAction)gpgReloadPGPKeys:(id)sender {
	[self flushKeyCache:YES];
	if (gpgMailWorks) {
		[self synchronizeKeyGroupsWithAddressBookGroups];
	}
}

- (IBAction)gpgSearchKeys:(id)sender {
	[[GPGKeyDownload sharedInstance] gpgSearchKeys:sender];
}

- (void)flushKeyCache:(BOOL)refresh {
	cachedPersonalGPGKeys = nil;
    [cachedPersonalGPGKeys release];
	cachedPublicGPGKeys = nil;
	[cachedPublicGPGKeys release];
	[cachedKeyGroups release];
	cachedKeyGroups = nil;
	[defaultKey release];
	defaultKey = nil;
	if (cachedUserIDsPerKey != NULL) {
		NSFreeMapTable(cachedUserIDsPerKey);
		cachedUserIDsPerKey = NULL;
	}
	if (refresh) {
		[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] postNotificationName:GPGKeyListWasInvalidatedNotification object:self];
		[self refreshPersonalKeysMenu];                       // Was disabled
		[self refreshPublicKeysMenu];                         // Was disabled
	}
#warning CHECK: keys not synced with current editor!
}

- (void)warnUserForMissingPrivateKeys:(id)sender {
	NSBundle *aBundle = [NSBundle bundleForClass:[self class]];
	NSString *aTitle = NSLocalizedStringFromTableInBundle(@"NO PGP PRIVATE KEY - TITLE", @"GPGMail", aBundle, "");
	NSString *aMessage = NSLocalizedStringFromTableInBundle(@"NO PGP PRIVATE KEY - MESSAGE", @"GPGMail", aBundle, "");

	(void)NSRunAlertPanel(aTitle, @"%@", nil, nil, nil, aMessage);
	[self setWarnedAboutMissingPrivateKeys:YES];
}

- (NSArray *)keysForSearchPatterns:(NSArray *)searchPatterns attributeName:(NSString *)attributeKeyPath secretKeys:(BOOL)secretKeys {
	// We need to perform search in-memory, because asking gpgme/gpg to do it launches
	// a task each time, starving the system resources!
	NSMutableArray *keys = [NSMutableArray array];
	NSSet *allKeys = (secretKeys ? [self personalKeys] : [self publicKeys]);

	if (!searchPatterns) {
		[keys addObjectsFromArray:[allKeys allObjects]];
	} else {
        for (GPGKey *eachKey in allKeys) {
			BOOL found = NO;
            
            for (GPGUserID *eachUserID in [eachKey userIDs]) {
				if ([searchPatterns containsObject:[eachUserID valueForKeyPath:attributeKeyPath]]) {                                                               // FIXME: Zombie(?) of searchPatterns crash in -isEqual:
					found = YES;
					break;
				}
			}

			if (found) {
				[keys addObject:eachKey];
			}
		}
	}

	return keys;
}

- (BOOL)canSignMessagesFromAddress:(NSString *)address {
    NSString *fingerprint = [_cachedPublicGPGKeysByEmail valueForKey:[address gpgNormalizedEmail]];
    return (fingerprint != nil);
}

- (BOOL)canEncryptMessagesToAddress:(NSString *)address {
    NSString *fingerprint = [_cachedPublicGPGKeysByEmail objectForKey:[address gpgNormalizedEmail]];
    return (fingerprint != nil);
}

- (NSArray *)publicKeyListForAddresses:(NSArray *)recipients {
    NSMutableArray *keyList = [NSMutableArray array];
    GPGKey *tmpKey;
    for(id recipient in recipients) {
        tmpKey = [_cachedPublicGPGKeysByEmail objectForKey:recipient];
        [keyList addObject:tmpKey];
    }
    return keyList;
}

- (NSArray *)signingKeyListForAddresses:(NSArray *)senders {
    NSMutableArray *keyList = [NSMutableArray array];
    GPGKey *tmpKey;
    for(id sender in senders) {
        tmpKey = [_cachedPersonalGPGKeysByEmail objectForKey:sender];
        [keyList addObject:tmpKey];
    }
    return keyList;
}

- (NSSet *)loadGPGKeys {
    if(!gpgMailWorks) return nil;
    if(!cachedGPGKeys) {
        GPGController *gpgc = [[GPGController alloc] init];
        gpgc.verbose = (GPGMailLoggingLevel > 0);
        cachedGPGKeys = [gpgc allKeys];
        [cachedGPGKeys retain];
        [gpgc release];
    }
    return cachedGPGKeys;
}

- (NSSet *)allGPGKeys {
    return cachedGPGKeys;
}

/**
 Create a map for the gpg keys which can be accessed by using
 an email address.
 All email addresses of user ids are taking into consideration.
 */
- (NSMutableDictionary *)emailMapForGPGKeys:(NSSet *)keys {
    NSMutableDictionary *keyEmailMap = [NSMutableDictionary dictionary];
    for(GPGKey *key in keys) {
        // TODO: 
        NSMutableArray *userIDs = [NSMutableArray arrayWithObject:[key primaryUserID]];
        [userIDs addObjectsFromArray:[key userIDs]];
        NSString *email;
        for(GPGUserID *userID in userIDs) {
            email = [[userID email] gpgNormalizedEmail];
            if(email && ![keyEmailMap objectForKey:email])
                [keyEmailMap setObject:[key fingerprint] forKey:email];
        }
    }
    return keyEmailMap;
    
}

- (NSSet *)personalKeys {
    NSSet *allKeys;
    BOOL filterKeys;
    
    if(!gpgMailWorks)
        return nil;
    
    if(!cachedPersonalGPGKeys) {
        filterKeys = [self filtersOutUnusableKeys];
        allKeys = [self loadGPGKeys];
        cachedPersonalGPGKeys = [[allKeys filter:^(id obj) {
            return ((GPGKey *)obj).secret && (!filterKeys || [self canKeyBeUsedForSigning:obj]) ? obj : nil; 
        }] retain];
        
        if ([cachedPersonalGPGKeys count] == 0 && ![self warnedAboutMissingPrivateKeys]) {
			[self performSelector:@selector(warnUserForMissingPrivateKeys:) withObject:nil afterDelay:0];
		}
        
        NSMutableDictionary *emailMap = [self emailMapForGPGKeys:cachedPersonalGPGKeys];
        _cachedPersonalGPGKeysByEmail = [[NSDictionary alloc] initWithDictionary:emailMap];
    
        DebugLog(@"Emails can be used to sign: %@", _cachedPersonalGPGKeysByEmail);
    }
    
    return cachedPersonalGPGKeys;
}

- (NSSet *)publicKeys {
    NSSet *allKeys;
    BOOL filterKeys;
    
    if(!gpgMailWorks)
        return nil;
    
    if(!cachedPublicGPGKeys) {
        filterKeys = [self filtersOutUnusableKeys];
        allKeys = [self loadGPGKeys];
        cachedPublicGPGKeys = [[allKeys filter:^(id obj) {
            return !filterKeys || [self canKeyBeUsedForEncryption:obj] ? obj : nil; 
        }] retain];
        
        NSMutableDictionary *emailMap = [self emailMapForGPGKeys:cachedPublicGPGKeys];
        _cachedPublicGPGKeysByEmail = [[NSDictionary alloc] initWithDictionary:emailMap];

        DebugLog(@"Emails can be used to encrypt: %@", _cachedPublicGPGKeysByEmail);
    }
    
    return cachedPublicGPGKeys;
}

// TODO: Fix for libmacgpg
//- (NSArray *)keyGroups {
//	if (!cachedKeyGroups && gpgMailWorks) {
//		GPGContext *aContext = [[GPGContext alloc] init];
//
//		cachedKeyGroups = [[aContext keyGroups] retain];
//		[aContext release];
//	}
//
//	return cachedKeyGroups;
//}

- (NSArray *)secondaryUserIDsForKey:(GPGKey *)key {
	// BUG: if primary userID is not valid,
	// it will not be filtered out!
	NSArray *result;

	if (cachedUserIDsPerKey == NULL) {
		// We NEED to retain userIDs, else there are zombies, due to DO
		cachedUserIDsPerKey = NSCreateMapTableWithZone(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 50, [self zone]);
	}
	result = NSMapGet(cachedUserIDsPerKey, key);
	if (result == nil) {
        
		result = [key userIDs];
		if ([result count] > 1) {
			NSEnumerator *anEnum = [result objectEnumerator];
			NSMutableArray *anArray = [NSMutableArray array];
			GPGUserID *aUserID;
			BOOL filterKeys = [self filtersOutUnusableKeys];

            
			[anEnum nextObject]; // Skip primary userID
			while (aUserID = [anEnum nextObject]) {
				if (!filterKeys || [self canUserIDBeUsed:aUserID]) {
					[anArray addObject:aUserID];
				}
            }
			result = anArray;
		} else {
			result = [NSArray array];
		}
		NSMapInsert(cachedUserIDsPerKey, key, result);
	}

	return result;
}

// TODO: Fix for libmacgpg
//- (NSString *)context:(GPGContext *)context passphraseForKey:(GPGKey *)key again:(BOOL)again {
//	NSString *passphrase;
//
//	if (again && key != nil) {
//		[GPGPassphraseController flushCachedPassphraseForUser:key];
//	}
//
//	// (Find current window) No longer necessary - will be replaced by agent
//	passphrase = [[GPGPassphraseController controller] passphraseForUser:key title:NSLocalizedStringFromTableInBundle(@"MESSAGE_DECRYPTION_PASSPHRASE_TITLE", @"GPGMail", [NSBundle bundleForClass:[self class]], "") window:/*[[self composeAccessoryView] window]*/ nil];
//
//	return passphrase;
//}

- (GPGKey *)publicKeyForSecretKey:(GPGKey *)secretKey {
	// Do not invoke -[GPGKey publicKey], because it will perform a gpg op
	// Get key from cached public keys
	[secretKey retain];
    NSString *aFingerprint = [secretKey fingerprint];

    for (GPGKey *aPublicKey in [self publicKeys]) {
		if ([[aPublicKey fingerprint] isEqualToString:aFingerprint]) {
            [secretKey release];
			return aPublicKey;
		}
    }
    [secretKey release];
	return nil;
}

- (NSString *)menuItemTitleForKey:(GPGKey *)key {
	NSMutableArray *components = [NSMutableArray array];
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	GPGUserID *primaryUserID;
	BOOL isKeyRevoked, hasKeyExpired, isKeyDisabled, isKeyInvalid;
	BOOL hasNonRevokedSubkey = NO, hasNonExpiredSubkey = NO, hasNonDisabledSubkey = NO, hasNonInvalidSubkey = NO;
    GPGKey *publicKey;
    
    [key retain];
#warning FIXME: Secret keys are never marked as revoked! Check expired/disabled/invalid
	publicKey = [self publicKeyForSecretKey:key];
    [key release];
	primaryUserID = ([[publicKey userIDs] count] > 0 ? [[publicKey userIDs] objectAtIndex:0] : nil);
	isKeyRevoked = publicKey.revoked;             // Secret keys are never marked as revoked!
	hasKeyExpired = publicKey.expired;
	isKeyDisabled = publicKey.disabled;
	isKeyInvalid = publicKey.invalid;

	// A key can have no "problem" whereas the subkey it needs has such "problems"!!!
#warning We really need to filter keys according to SUBKEYS!
	// Currently we filter only according to key -> we display disabled keys,
	// whereas we shouldn't even show them
    for (GPGSubkey *aSubkey in [publicKey subkeys]) {
		if (!aSubkey.revoked) {
			hasNonRevokedSubkey = YES;
		}
		if (!aSubkey.expired) {
			hasNonExpiredSubkey = YES;
		}
		if (!aSubkey.disabled) {
			hasNonDisabledSubkey = YES;
		}
		if (!aSubkey.invalid) {
			hasNonInvalidSubkey = YES;
		}
	}

	if (primaryUserID != nil) {
		if (primaryUserID.revoked) {
			[components addObject:NSLocalizedStringFromTableInBundle(@"REVOKED_USER_ID:", @"GPGMail", myBundle, "")];
		}
		if (primaryUserID.invalid) {
			[components addObject:NSLocalizedStringFromTableInBundle(@"INVALID_USER_ID:", @"GPGMail", myBundle, "")];
		}
	}

	if (isKeyRevoked && !hasNonRevokedSubkey) {
		[components addObject:NSLocalizedStringFromTableInBundle(@"REVOKED_KEY:", @"GPGMail", myBundle, "")];
	}
	if (hasKeyExpired && !hasNonExpiredSubkey) {
		[components addObject:NSLocalizedStringFromTableInBundle(@"EXPIRED_KEY:", @"GPGMail", myBundle, "")];
	}
	if (isKeyDisabled && !hasNonDisabledSubkey) {
		[components addObject:NSLocalizedStringFromTableInBundle(@"DISABLED_KEY:", @"GPGMail", myBundle, "")];
	}
	if (isKeyInvalid && !hasNonInvalidSubkey) {
		[components addObject:NSLocalizedStringFromTableInBundle(@"INVALID_KEY:", @"GPGMail", myBundle, "")];
	}

    for (NSString *anIdentifier in [self displayedKeyIdentifiers]) {
		id aValue;
		NSString *aComponent;

		if ([anIdentifier isEqualToString:@"validity"]) {
			anIdentifier = @"validityNumber";
		} else if ([anIdentifier isEqualToString:@"keyID"]) {
			anIdentifier = @"shortKeyID";
		} else if ([anIdentifier isEqualToString:@"longKeyID"]) {
			anIdentifier = @"keyID";
		} else if ([anIdentifier isEqualToString:@"algorithm"]) {
			anIdentifier = @"algorithmDescription";
		} else if ([anIdentifier isEqualToString:@"fingerprint"]) {
			anIdentifier = @"formattedFingerprint";
		}
		aValue = [publicKey performSelector:NSSelectorFromString(anIdentifier)];
		if (aValue == nil || ([aValue isKindOfClass:[NSString class]] && [(NSString *) aValue length] == 0)) {
			continue;
		}

		if ([anIdentifier isEqualToString:@"email"]) {
			aComponent = [NSString stringWithFormat:@"<%@>", aValue];
		} else if ([anIdentifier isEqualToString:@"comment"]) {
			aComponent = [NSString stringWithFormat:@"(%@)", aValue];
		} else if ([anIdentifier isEqualToString:@"validityNumber"]) {
			// Validity has no meaning yet for secret keys, always unknown, so we never display it
			if (!publicKey.secret) {
				NSString *aDesc = [NSString stringWithFormat:@"Validity=%@", aValue];

				aDesc = NSLocalizedStringFromTableInBundle(aDesc, @"GPGMail", myBundle, "");
				aComponent = [NSString stringWithFormat:@"[%@%@]", NSLocalizedStringFromTableInBundle(@"VALIDITY: ", @"GPGMail", myBundle, ""), aDesc];
			} else {
				continue;
			}
		} else if ([anIdentifier isEqualToString:@"shortKeyID"]) {
			aComponent = [NSString stringWithFormat:@"0x%@", aValue];
		} else if ([anIdentifier isEqualToString:@"keyID"]) {
			aComponent = [NSString stringWithFormat:@"0x%@", aValue];
		} else {
			aComponent = aValue;
		}
		[components addObject:aComponent];
	}

	return [components componentsJoinedByString:@" "];
}

- (NSString *)menuItemTitleForUserID:(GPGUserID *)userID indent:(unsigned)indent {
	NSMutableArray *titleElements = [NSMutableArray array];
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];

#warning FIXME: Secret keys are never marked as revoked! Check expired/disabled/invalid
	if (userID.revoked) {
		[titleElements addObject:NSLocalizedStringFromTableInBundle(@"REVOKED_USER_ID:", @"GPGMail", myBundle, "")];
	}
	if (userID.invalid) {
		[titleElements addObject:NSLocalizedStringFromTableInBundle(@"INVALID_USER_ID:", @"GPGMail", myBundle, "")];
	}

    for (NSString *anIdentifier in [self displayedKeyIdentifiers]) {
		id aValue;

		if ([anIdentifier isEqualToString:@"fingerprint"] || [anIdentifier isEqualToString:@"keyID"] || [anIdentifier isEqualToString:@"algorithm"] || [anIdentifier isEqualToString:@"longKeyID"]) {
			continue;
		}
		if ([anIdentifier isEqualToString:@"validity"]) {
			anIdentifier = @"validityNumber";
		}

		aValue = [userID performSelector:NSSelectorFromString(anIdentifier)];

		if (aValue == nil || ([aValue isKindOfClass:[NSString class]] && [(NSString *) aValue length] == 0)) {
			continue;
		}

		if ([anIdentifier isEqualToString:@"email"]) {
			[titleElements addObject:[NSString stringWithFormat:@"<%@>", aValue]];
		} else if ([anIdentifier isEqualToString:@"comment"]) {
			[titleElements addObject:[NSString stringWithFormat:@"(%@)", aValue]];
		} else if ([anIdentifier isEqualToString:@"validityNumber"]) {
			// Validity has no meaning yet for secret keys, always unknown, so we never display it
			if (!userID.primaryKey.secret) {
				NSString *aDesc = [NSString stringWithFormat:@"Validity=%@", aValue];

				aDesc = NSLocalizedStringFromTableInBundle(aDesc, @"GPGMail", myBundle, "");
				[titleElements addObject:[NSString stringWithFormat:@"[%@%@]", NSLocalizedStringFromTableInBundle(@"VALIDITY: ", @"GPGMail", myBundle, ""), aDesc]];                                                 // Would be nice to have an image for that
			}
		} else {
			[titleElements addObject:aValue];
		}
	}

	return [[@"" stringByPaddingToLength:(indent * 4) withString:@" " startingAtIndex:0] stringByAppendingString:[titleElements componentsJoinedByString:@" "]];
}

- (BOOL)canKeyBeUsedForEncryption:(GPGKey *)key {
	// Only either the key or one of the subkeys has to be valid,
    // non-expired, non-disabled, non-revoked and be used for encryption.
    // We don't care about ownerTrust, validity
	NSMutableArray* allKeys = [NSMutableArray array];
    [allKeys addObject:key];
    [allKeys addObjectsFromArray:[key subkeys]];
    for(GPGSubkey *subkey in allKeys) {
        if(subkey.canEncrypt && !subkey.expired && !subkey.revoked &&
           !subkey.invalid && !subkey.disabled) {
            return YES;
        }
        else {
            // Apparently if the primary key doesn't match this criterias, subkeys
            // don't need to be checked, and it's not included.
            if([key.fingerprint isEqualToString:subkey.fingerprint])
                return NO;
        }
    }
    return NO;
}

// TODO: Public key might not be available... how can this be?
- (BOOL)canKeyBeUsedForSigning:(GPGKey *)key {
	// Only either the key or one of the subkeys has to be valid,
    // non-expired, non-disabled, non-revoked and be used for encryption.
    // We don't care about ownerTrust, validity
	// We need the public key here, but get passed the secret key.
    GPGKey *publicKey = [self publicKeyForSecretKey:key];
    
    // Public Key might not be available... how can this be?
    if(!publicKey)
        return NO;
    NSMutableSet* allKeys = [NSMutableSet set];
    [allKeys addObject:publicKey];
    [allKeys addObjectsFromArray:[publicKey subkeys]];
    for(GPGSubkey *subkey in allKeys) {
        if(subkey.canSign && !subkey.expired && !subkey.revoked &&
           !subkey.invalid && !subkey.disabled) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)canUserIDBeUsed:(GPGUserID *)userID {
	// We suppose that key is OK
	// We don't care about validity
#warning FIXME: Secret keys are never marked as revoked! Check expired/disabled/invalid
	return (!userID.revoked && !userID.invalid);
}

- (id)locale {
//    return [NSLocale autoupdatingCurrentLocale]; // FIXME: does not work as expected
	return [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
}

/**
 Returns the version of the bundle as string.
 */
+ (NSString *)bundleVersion {
    return [[[NSBundle bundleForClass:self] infoDictionary]
            valueForKey:@"CFBundleVersion"];
}

+ (NSString *)agentHeader {
    return [NSString stringWithFormat:GPGMailAgent, [self bundleVersion]];
}

@end

#import <AddressBook/AddressBook.h>

@interface ABGroup (GPGMail)
- (NSArray *)gpgFlattenedMembers;
@end


@implementation ABGroup (GPGMail)

- (NSArray *)gpgFlattenedMembers {
	NSArray *gpgFlattenedMembers = [self members];

    for (ABGroup *aGroup in [self subgroups]) {
		gpgFlattenedMembers = [gpgFlattenedMembers arrayByAddingObjectsFromArray:[aGroup gpgFlattenedMembers]];
    }

	return gpgFlattenedMembers;
}

@end

@implementation GPGMailBundle (AddressGroups)

// TODO: Implement synchronize key groups with addressbook groups.

- (void)abDatabaseChangedExternally:(NSNotification *)notification {
	// FIXME: Update only what's needed
	[self synchronizeKeyGroupsWithAddressBookGroups];
}

- (void)abDatabaseChanged:(NSNotification *)notification {
	// FIXME: Update only what's needed
	[self synchronizeKeyGroupsWithAddressBookGroups];
}

- (void)keyringChanged:(NSNotification *)notification {
	[self gpgReloadPGPKeys:nil];
}

@end
