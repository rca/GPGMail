/* GPGMailBundle.m created by dave on Thu 29-Jun-2000 */
/* GPGMailBundle.m completely re-created by Lukas Pitschl (@lukele) on Thu 13-Jun-2013 */
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

#import <mach-o/getsect.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <Libmacgpg/Libmacgpg.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import "CCLog.h"
#import "JRLPSwizzle.h"
#import "GMCodeInjector.h"
#import "GMKeyManager.h"
#import "GMMessageRulesApplier.h"
#import "GPGMailBundle.h"
#import "GPGMailPreferences.h"
#import "MVMailBundle.h"
#import "NSString+GPGMail.h"
#import "GMSecurityControl.h"
#import "HeadersEditor+GPGMail.h"
#import "DocumentEditor.h"
#import "GMSecurityMethodAccessoryView.h"
#import "MCError.h"

#ifndef NSAppKitVersionNumber10_10
#define NSAppKitVersionNumber10_10 1343
#endif

@interface DeliveryFailure_GPGMail : NSObject
@end

@implementation DeliveryFailure_GPGMail

- (void)MAReportError:(MCError *)error {
    error = [GM_MAIL_CLASS(@"MFError") errorWithDomain:[error domain] code:1038 localizedDescription:nil title:[error localizedDescription] helpTag:nil
                                              userInfo:[error userInfo]];
    [self MAReportError:error];
}

@end

@interface MailToolbar_GPGMail : NSObject
@end

@implementation MailToolbar_GPGMail

+ (id)MA_plistForToolbarWithIdentifier:(id)arg1 {
    id ret = [self MA_plistForToolbarWithIdentifier:arg1];
    
    if(![arg1 isEqualToString:@"ComposeWindow"])
        return ret;
    
    NSMutableDictionary *configuration = [ret mutableCopy];
    NSMutableArray *defaultSet = [configuration[@"default set"] mutableCopy];
    [defaultSet addObject:@"toggleSecurityMethod:"];
    [configuration setObject:defaultSet forKey:@"default set"];
    
    return configuration;
}

@end


#import "NSObject+LPDynamicIvars.m"
@interface ComposeWindowController_GPGMail : NSObject

@end

@interface ComposeWindowController_GPGMail (NotImplemented)

- (id)contentViewController;
- (id)windowTransformAnimation;
- (void)cancelAnimation;
- (void)setSendAnimationCancelled:(BOOL)cancelled;

@end

@implementation ComposeWindowController_GPGMail

- (id)MAToolbarAllowedItemIdentifiers:(id)arg1 {
    id ret = [self MAToolbarAllowedItemIdentifiers:arg1];
    
    return ret;
}

- (id)MAToolbarDefaultItemIdentifiers:(id)toolbar {
    id defaultItemIdentifiers = [self MAToolbarDefaultItemIdentifiers:toolbar];
    
    // Appening the security method identifier to toggle between OpenPGP and S/MIME.
    NSMutableArray *identifiers = [defaultItemIdentifiers mutableCopy];
    [identifiers addObject:@"toggleSecurityMethod:"];
    
    return identifiers;
}

- (id)MAToolbar:(id)arg1 itemForItemIdentifier:(id)arg2 willBeInsertedIntoToolbar:(BOOL)arg3 {
    id ret = nil;
    
    if(![arg2 isEqualToString:@"toggleSecurityMethod:"]) {
       ret = [self MAToolbar:arg1 itemForItemIdentifier:arg2 willBeInsertedIntoToolbar:arg3];
    }
    else {
        // The delegate of GMSecurityMethodAccessoryView will be the current composeViewController.
        // At this point it's however not yet set on the ComposeWindowController, so once the
        // compose view controller is ready, it will set if self up as delegate.
        GMSecurityMethodAccessoryView *securityMethodAccessoryView = [[GMSecurityMethodAccessoryView alloc] init];
        
        [self setIvar:@"SecurityMethodAccessoryView" value:securityMethodAccessoryView];
        
        ret = [[NSToolbarItem alloc] initWithItemIdentifier:arg2];
        [ret setView:securityMethodAccessoryView];
        [ret setMinSize:NSMakeSize(100, 23)];
        [ret setTarget:nil];
    }
    
    return ret;
}

- (void)showSheetForAlert:(id)arg1 completion:(id)arg2 {
    [self showSheetForAlert:arg1 completion:arg2];
}

- (void)MADealloc {
    [self MADealloc];
}

- (void)MA_sendAnimationCompleted {
    [self MA_sendAnimationCompleted];
}

- (void)MA_performSendAnimation {
    // Store the the current frame position, to restore it in case of an error.
    NSPoint currentOrigin = [(id)self window].frame.origin;
    [self setIvar:@"WindowFrameOriginBeforeAnimation" value:@{@"X": @(currentOrigin.x), @"Y": @(currentOrigin.y)}];
    [self MA_performSendAnimation];
}

- (void)restorePositionBeforeAnimation {
    NSDictionary *originBeforeAnimation = [self getIvar:@"WindowFrameOriginBeforeAnimation"];
    if(!originBeforeAnimation)
        return;
    [self removeIvar:@"WindowFrameOriginBeforeAnimation"];
    [[(id)self window] setFrameOrigin:NSMakePoint([originBeforeAnimation[@"X"] floatValue], [originBeforeAnimation[@"Y"] floatValue])];
}

- (void)MA_cancelSendAnimation {
    id window = [(id)self window];
    if([window isKindOfClass:NSClassFromString(@"FullScreenModalCapableWindow")]) {
        [[window windowTransformAnimation] cancelAnimation];
    }
    [self setSendAnimationCancelled:YES];

    [self MA_cancelSendAnimation];
}
- (void)MASetShouldCloseWindowWhenAnimationCompletes:(BOOL)shouldClose {
    // On El Capitan we might have to force set NO here.
    // Otherwise it's not possible to show the user a custom error message,
    // if there was a problem processing the message with gpg.
    shouldClose = NO;
    [self MASetShouldCloseWindowWhenAnimationCompletes:shouldClose];
}

- (void)MAWindowDidResignKey:(id)arg1 {
    [self MAWindowDidResignKey:arg1];
}

- (void)MAComposeViewControllerShouldClose:(id)arg1 {
    [self MAComposeViewControllerShouldClose:arg1];
}

- (void)MAWindowWillClose:(id)arg1 {
    [self MAWindowWillClose:arg1];
}

- (void)MAAnimationDidEnd:(id)arg1 {
    [self MAAnimationDidEnd:arg1];
}

- (void)MAComposeViewControllerDidSend:(id)arg1 {
    [self MAComposeViewControllerDidSend:arg1];
}

#warning REMOVE THIS CODE AND PROPERLY IMPLEMENT IT. OTHERWISE WE WILL BREAK THE FUTURE TAB BAR CODE.
- (void)MA_tabBarView:(id)arg1 performSendAnimationOfTabBarViewItem:(id)arg2 {
    // This is ugly as fuck, but for the time being it has to do.
    // We simply don't do anything with the tabBarViewItem or the view controller, since we might still need it
    // and only run the animations.
    [[(id)self window] invalidateRestorableState];
    [(id)self _performSendAnimation];
    return;
//    
//    // We pass nil in order to prevent the tab bar item to be destryed.
//    // Otherwise, in case of a gpg processing error, the message will throw an exception
//    // if the user tries to send the message again.
//    id dummyTabViewItem = [[NSClassFromString(@"ComposeTabViewItem") alloc] initWithIdentifier:@"GPGMailDummyTabView"];
//    //[dummyTabViewItem setViewController:[[NSClassFromString(@"ComposeViewController") alloc] init]];
//    //[arg2 setViewController:dummyTabViewItem];
//    [self MA_tabBarView:arg1 performSendAnimationOfTabBarViewItem:dummyTabViewItem];

}

- (id)MASelectedTabBarViewItemAfterClosingCurrentTabInTabBarView:(id)arg1 {
    id ret = [self MASelectedTabBarViewItemAfterClosingCurrentTabInTabBarView:arg1];
    return ret;
}

@end



@interface MUITokenAddressField_GPGMail : NSObject
@end

@implementation MUITokenAddressField_GPGMail

- (id)MATokenFieldCell:(id)arg1 setUpTokenAttachmentCell:(id)arg2 forRepresentedObject:(id)arg3 {
    id result = [self MATokenFieldCell:arg1 setUpTokenAttachmentCell:arg2 forRepresentedObject:arg3];
    
    return result;
}

@end

@interface MUIAddressTokenAttachmentCell_GPGMail : NSObject

- (struct CGRect)pullDownRectForBounds:(struct CGRect)arg1;

@end

@implementation MUIAddressTokenAttachmentCell_GPGMail

- (id)MATokenBackgroundColor {
    id result = [self MATokenBackgroundColor];
    
    if([((id)self) cellAttribute:NSCellHighlighted] != 0)
        return [NSColor greenColor];
    
    return [NSColor brownColor];
}

- (id)MATokenForegroundColor {
    id result = [self MATokenForegroundColor];
    
    if([((id)self) cellAttribute:NSCellHighlighted] != 0)
        return [NSColor greenColor];
    
    return result;
}

/**
 Defines the width of the address token. In order to fit our custom accessory view
 in there, we'll extend the size of it by the width of the accessory view and a wanted padding.
 */
- (struct CGSize)MACellSizeForBounds:(struct CGRect)arg1 {
    NSSize cellSize = [self MACellSizeForBounds:arg1];
    
    return NSMakeSize(cellSize.width + 10, cellSize.height);
}

- (void)MADrawInteriorWithFrame:(struct CGRect)arg1 inView:(id)arg2 {
    [self MADrawInteriorWithFrame:arg1 inView:arg2];
    // When hovering over an address bar and not the token address field itself, the inView seems to be a different target.
    // We'll have to find out which one, so our token accessory is always shown and not only when actively hovering over the token address field.
    NSLog(@"In View: %@", arg2);
    if([arg2 isKindOfClass:NSClassFromString(@"MUITokenAddressField")] ||
       [arg2 isKindOfClass:NSClassFromString(@"MUITokenAddressTextView")] ||
       [arg2 isKindOfClass:NSClassFromString(@"NSTokenTextView")]) {
        NSRect bounds = [self pullDownRectForBounds:arg1];
        [[NSImage imageNamed:@"NSTokenPopDownArrow"] drawInRect:NSMakeRect(bounds.origin.x-10, bounds.origin.y, bounds.size.width, bounds.size.height) fromRect:NSMakeRect(0, 0, 9, 6) operation:NSCompositeSourceAtop fraction:1 respectFlipped:YES hints:nil];
    }
}

@end

#import "GPGFlaggedString.h"

@interface MUITokenAddress_GPGMail : NSObject
@end

@implementation MUITokenAddress_GPGMail

- (id)MAInitWithAddress:(id)arg1 isRecent:(BOOL)arg2 contact:(id)arg3 {
    id ret = [self MAInitWithAddress:arg1 isRecent:arg2 contact:arg3];
    return ret;
}

- (id)MAFormattedAddress {
    id address = [self MAFormattedAddress];
    
    // Add our custom field to the returned formatted address, if any is available.
    if([self getIvar:@"AssociatedGPGKey"]) {
        address = [[GPGFlaggedString alloc] initWithString:address flag:@"AssociatedGPGKey" value:[self getIvar:@"AssociatedGPGKey"]];
    }
    
    return address;
}

- (void)MA_getRecordFromAddress {
    [self MA_getRecordFromAddress];
}

- (void)MAGetRecordFromAddress {
    [self MAGetRecordFromAddress];
}


@end

@interface MUIAddressField_GPGMail : NSObject
- (void)setTokenValue:(id)tokenValue;
- (id)tokenValue;
- (void)_tokenFieldCommittedEditing:(id)tokenField;

@end

@implementation MUIAddressField_GPGMail

/* Is called when the user exits the "To" Field (for example).
 * The MUIAddressField can contain one or more addresses.
 */
- (void)MA_tokenFieldCommitedEditing:(id)arg1 {
    // The token value contains all the MUITokenAddress(es), so this is a good point, to add the AssociatedGPGKey information
    // to the MUITokenAdd
    
    
    
    
    [self MA_tokenFieldCommitedEditing:arg1];
}

/* This method is called, when a complete address has been entered.
   It might be the best place to kick off our key search in the background.
 */
- (id)MATokenField:(id)arg1 shouldAddObjects:(id)arg2 atIndex:(unsigned long long)arg3 {
    NSMutableArray *objects = [NSMutableArray array];
    for(id tokenAddress in arg2) {
        [tokenAddress setIvar:@"AssociatedGPGKey" value:@"This is some string I wish to receive in ComposeBackEnd"];
        [objects addObject:tokenAddress];
    }
    
    id ret = [self MATokenField:arg1 shouldAddObjects:objects atIndex:arg3];
    
    // Unfortunately, this method is called after the HeadersEditor receives a address change KVO notification
    // from an MUIAddressField.
    // So in order for the HeadersEditor and in turn then the ComposeBackEnd receives our GPGFlaggedString with
    // the associated gpg key information, we'll force another changeFromHeader call (which updates the header information of the
    // ComposeBackEnd.
    [self _tokenFieldCommittedEditing:arg1];
    [((id)self) setTokenValue:[((id)self) tokenValue]];
    
    
    return ret;
}

- (id)MAAddresses {
    id ret = [self MAAddresses];
    
    return ret;
}

- (void)MASetAddresses:(id)addresses {
    [self MASetAddresses:addresses];
}

- (void)MASetTokenValue:(id)tokenValue {
    [self MASetTokenValue:tokenValue];
}

@end


@interface GPGMailBundle ()

@property GPGErrorCode gpgStatus;
@property (nonatomic, strong) GMKeyManager *keyManager;

@end


#pragma mark Constants and global variables

NSString *GPGMailSwizzledMethodPrefix = @"MA";
NSString *GPGMailAgent = @"GPGMail %@";
NSString *GPGMailKeyringUpdatedNotification = @"GPGMailKeyringUpdatedNotification";
NSString *gpgErrorIdentifier = @"^~::gpgmail-error-code::~^";

int GPGMailLoggingLevel = 0;
static BOOL gpgMailWorks = NO;

#pragma mark GPGMailBundle Implementation

@implementation GPGMailBundle
@synthesize accountExistsForSigning, gpgStatus;


#pragma mark Multiple Installations

+ (NSArray *)multipleInstallations {
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES);
    NSString *bundlesPath = [@"Mail" stringByAppendingPathComponent:@"Bundles"];
    NSString *bundleName = @"GPGMail.mailbundle";
    
    NSMutableArray *installations = [NSMutableArray array];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    for(NSString *libraryPath in libraryPaths) {
        NSString *bundlePath = [libraryPath stringByAppendingPathComponent:[bundlesPath stringByAppendingPathComponent:bundleName]];
        if([fileManager fileExistsAtPath:bundlePath])
            [installations addObject:bundlePath];
    }
    
    return (NSArray *)installations;
}

+ (void)showMultipleInstallationsErrorAndExit:(NSArray *)installations {
    NSAlert *errorModal = [[NSAlert alloc] init];
    
    errorModal.messageText = GMLocalizedString(@"GPGMAIL_MULTIPLE_INSTALLATIONS_TITLE");
    errorModal.informativeText = [NSString stringWithFormat:GMLocalizedString(@"GPGMAIL_MULTIPLE_INSTALLATIONS_MESSAGE"), [installations componentsJoinedByString:@"\n\n"]];
    [errorModal addButtonWithTitle:GMLocalizedString(@"GPGMAIL_MULTIPLE_INSTALLATIONS_BUTTON")];
    [errorModal runModal];
    
    
    // It's not at all a good idea to use exit and kill the app,
    // but in this case it's alright because otherwise the user would experience a
    // crash anyway.
    exit(0);
}


#pragma mark Init, dealloc etc.

+ (void)initialize {    
    // Make sure the initializer is only run once.
    // Usually is run, for every class inheriting from
    // GPGMailBundle.
    if(self != [GPGMailBundle class])
        return;
    
    if (![GPGController class]) {
		NSRunAlertPanel([self localizedStringForKey:@"LIBMACGPG_NOT_FOUND_TITLE"], [self localizedStringForKey:@"LIBMACGPG_NOT_FOUND_MESSAGE"], nil, nil, nil);
		return;
	}
        
    /* Check the validity of the code signature.
     * Disable for the time being, since Info.plist is part of the code signature
     * and if a new version of OS X is released, and the UUID is added, this check
     * will always fail.
     * Probably not possible in the future either.
     */
//    if (![[self bundle] isValidSigned]) {
//		NSRunAlertPanel([self localizedStringForKey:@"CODE_SIGN_ERROR_TITLE"], [self localizedStringForKey:@"CODE_SIGN_ERROR_MESSAGE"], nil, nil, nil);
//        return;
//    }
    
    // If one happens to have for any reason (like for example installed GPGMail
    // from the installer, which will reside in /Library and compiled with XCode
    // which will reside in ~/Library) two GPGMail.mailbundle's,
    // display an error message to the user and shutdown Mail.app.
    NSArray *installations = [self multipleInstallations];
    if([installations count] > 1) {
        [self showMultipleInstallationsErrorAndExit:installations];
        return;
    }
    
    Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
    // If this class is not available that means Mail.app
    // doesn't allow plugins anymore. Fingers crossed that this
    // never happens!
    if(!mvMailBundleClass)
        return;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
    class_setSuperclass([self class], mvMailBundleClass);
#pragma GCC diagnostic pop
    
    // Initialize the bundle by swizzling methods, loading keys, ...
    GPGMailBundle *instance = [GPGMailBundle sharedInstance];
    
    [[((MVMailBundle *)self) class] registerBundle];             // To force registering composeAccessoryView and preferences
}

- (id)init {
	if (self = [super init]) {
		NSLog(@"Loaded GPGMail %@", [self version]);
        
        NSBundle *myBundle = [GPGMailBundle bundle];
        
        // Load all necessary images.
        [self _loadImages];
        
        
        // Set domain and register the main defaults.
        GPGOptions *options = [GPGOptions sharedOptions];
        options.standardDomain = [GPGMailBundle bundle].bundleIdentifier;
		NSDictionary *defaultsDictionary = [NSDictionary dictionaryWithContentsOfFile:[myBundle pathForResource:@"GPGMailBundle" ofType:@"defaults"]];
        [(id)options registerDefaults:defaultsDictionary];
        
        if (![options boolForKey:@"DefaultsLoaded"]) {
            NSRunAlertPanel([GPGMailBundle localizedStringForKey:@"NO_DEFAULTS_TITLE"], [GPGMailBundle localizedStringForKey:@"NO_DEFAULTS_MESSAGE"], nil, nil, nil);
            NSLog(@"GPGMailBundle.defaults can't be loaded!");
        }
        
        
        // Configure the logging level.
        GPGMailLoggingLevel = (int)[[GPGOptions sharedOptions] integerForKey:@"DebugLog"];
        GPGMailLoggingLevel = 1;
        DebugLog(@"Debug Log enabled: %@", [[GPGOptions sharedOptions] integerForKey:@"DebugLog"] > 0 ? @"YES" : @"NO");
        
        _keyManager = [[GMKeyManager alloc] init];
        
        // Initiate the Message Rules Applier.
        _messageRulesApplier = [[GMMessageRulesApplier alloc] init];
                
        // Start the GPG checker.
        [self startGPGChecker];
        
        // Specify that a count exists for signing.
        accountExistsForSigning = YES;
        
        // Inject the plugin code.
        [GMCodeInjector injectUsingMethodPrefix:GPGMailSwizzledMethodPrefix];
	}
    
	return self;
}

- (void)dealloc {
    dispatch_release(_checkGPGTimer);
}

- (void)_loadImages {
    /**
     * Loads all images which are used in the GPGMail User interface.
     */
    // We need to load images and name them, because all images are searched by their name; as they are not located in the main bundle,
	// +[NSImage imageNamed:] does not find them.
	NSBundle *myBundle = [GPGMailBundle bundle];
    
    NSArray *bundleImageNames = @[@"GPGMail",
                                  @"ValidBadge",
                                  @"InvalidBadge",
                                  @"GreenDot",
                                  @"YellowDot",
                                  @"RedDot",
                                  @"MenuArrowWhite",
                                  @"certificate",
                                  @"encryption",
                                  @"CertSmallStd",
                                  @"CertSmallStd_Invalid", 
                                  @"CertLargeStd",
                                  @"CertLargeNotTrusted",
                                  @"SymmetricEncryptionOn",
                                  @"SymmetricEncryptionOff"];
    NSMutableArray *bundleImages = [[NSMutableArray alloc] initWithCapacity:[bundleImageNames count]];
    
    for (NSString *name in bundleImageNames) {
        NSImage *image = [[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:name]];

        // Shoud an image not exist, log a warning, but don't crash because of inserting
        // nil!
        if(!image) {
            NSLog(@"GPGMail: Image %@ not found in bundle resources.", name);
            continue;
        }
        [image setName:name];
        [bundleImages addObject:image];
    }
    
    _bundleImages = bundleImages;
    
}

#pragma mark Check and status of GPG.

- (void)startGPGChecker {
    // Periodically check status of gpg.
    [self checkGPG];
    _checkGPGTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_checkGPGTimer, dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC), 60 * NSEC_PER_SEC, 10 * NSEC_PER_SEC);
    
    __block typeof(self) __unsafe_unretained weakSelf = self;
    dispatch_source_set_event_handler(_checkGPGTimer, ^{
        [weakSelf checkGPG];
    });
    dispatch_resume(_checkGPGTimer);
}

- (BOOL)checkGPG {
    self.gpgStatus = (GPGErrorCode)[GPGController testGPG];
    switch (gpgStatus) {
        case GPGErrorNotFound:
            DebugLog(@"DEBUG: checkGPG - GPGErrorNotFound");
            break;
        case GPGErrorConfigurationError:
            DebugLog(@"DEBUG: checkGPG - GPGErrorConfigurationError");
        case GPGErrorNoError: {
            static dispatch_once_t onceToken;
            
            GMKeyManager * __weak weakKeyManager = self->_keyManager;
            
            dispatch_once(&onceToken, ^{
                [weakKeyManager scheduleInitialKeyUpdate];
            });
            
            gpgMailWorks = YES;
            return YES;
        }
        default:
            DebugLog(@"DEBUG: checkGPG - %i", gpgStatus);
            break;
    }
    gpgMailWorks = NO;
    return NO;
}

+ (BOOL)gpgMailWorks {
	return gpgMailWorks;
}

- (BOOL)gpgMailWorks {
	return gpgMailWorks;
}


#pragma mark Handling keys

- (NSSet *)allGPGKeys {
    if (!gpgMailWorks) return nil;
    
    return [_keyManager allKeys];
}

- (GPGKey *)anyPersonalPublicKeyWithPreferenceAddress:(NSString *)address {
    if(!gpgMailWorks) return nil;
    
    return [_keyManager anyPersonalPublicKeyWithPreferenceAddress:address];
}

- (GPGKey *)secretGPGKeyForKeyID:(NSString *)keyID {
    if (!gpgMailWorks) return nil;
    
    return [_keyManager secretKeyForKeyID:keyID includeDisabled:NO];
}

- (GPGKey *)secretGPGKeyForKeyID:(NSString *)keyID includeDisabled:(BOOL)includeDisabled {
    if (!gpgMailWorks) return nil;
    
    return [_keyManager secretKeyForKeyID:keyID includeDisabled:includeDisabled];
}

- (NSMutableSet *)signingKeyListForAddress:(NSString *)sender {
    if (!gpgMailWorks) return nil;
    
    return [_keyManager signingKeyListForAddress:[sender gpgNormalizedEmail]];
}

- (NSMutableSet *)publicKeyListForAddresses:(NSArray *)recipients {
    if (!gpgMailWorks) return nil;
    
    return [_keyManager publicKeyListForAddresses:recipients];
}

- (BOOL)canSignMessagesFromAddress:(NSString *)address {
    if (!gpgMailWorks) return NO;
    
    return [_keyManager secretKeyExistsForAddress:[address gpgNormalizedEmail]];
}

- (BOOL)canEncryptMessagesToAddress:(NSString *)address {
    if (!gpgMailWorks) return NO;
    
    return [_keyManager publicKeyExistsForAddress:[address gpgNormalizedEmail]];
}

- (GPGKey *)preferredGPGKeyForSigning {
    if (!gpgMailWorks) return nil;
    
    return [_keyManager findKeyByHint:[[GPGOptions sharedOptions] valueInGPGConfForKey:@"default-key"] onlySecret:YES];
}

- (GPGKey *)keyForFingerprint:(NSString *)fingerprint {
    if (!gpgMailWorks) return nil;
    
    return [_keyManager keyForFingerprint:fingerprint];
}

#pragma mark Message Rules

- (void)scheduleApplyingRulesForMessage:(Message *)message isEncrypted:(BOOL)isEncrypted {
    [_messageRulesApplier scheduleMessage:message isEncrypted:isEncrypted];
}

#pragma mark Localization Helper

+ (NSString *)localizedStringForKey:(NSString *)key {
    NSBundle *gmBundle = [GPGMailBundle bundle];
    NSString *localizedString = NSLocalizedStringFromTableInBundle(key, @"GPGMail", gmBundle, @"");
    // Translation found, out of here.
    if(![localizedString isEqualToString:key])
        return localizedString;
    
    NSBundle *englishLanguageBundle = [NSBundle bundleWithPath:[gmBundle pathForResource:@"en" ofType:@"lproj"]];
    return [englishLanguageBundle localizedStringForKey:key value:@"" table:@"GPGMail"];
}

#pragma mark General Infos

+ (NSBundle *)bundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleForClass:[GPGMailBundle class]];
    });
    return bundle;
}


- (NSString *)version {
	return [[GPGMailBundle bundle] infoDictionary][@"CFBundleShortVersionString"];
}

+ (NSString *)bundleVersion {
    /**
     Returns the version of the bundle as string.
     */
    return [[[GPGMailBundle bundle] infoDictionary] valueForKey:@"CFBundleVersion"];
}

+ (NSNumber *)bundleBuildNumber {
    return [[[GPGMailBundle bundle] infoDictionary] valueForKey:@"BuildNumber"];
}

+ (NSString *)agentHeader {
    NSString *header = [NSString stringWithFormat:GPGMailAgent, [(GPGMailBundle *)[GPGMailBundle sharedInstance] version]];
    return header;
}

+ (Class)resolveMailClassFromName:(NSString *)name {
    NSArray *prefixes = @[@"", @"MC", @"MF"];
    
    // MessageWriter is called MessageGenerator under Mavericks.
    if([name isEqualToString:@"MessageWriter"] && !NSClassFromString(@"MessageWriter"))
        name = @"MessageGenerator";
    
    __block Class resolvedClass = nil;
    [prefixes enumerateObjectsUsingBlock:^(NSString *prefix, NSUInteger idx, BOOL *stop) {
        NSString *modifiedName = [name copy];
        if([prefixes containsObject:[modifiedName substringToIndex:2]])
            modifiedName = [modifiedName substringFromIndex:2];
        
        NSString *className = [prefix stringByAppendingString:modifiedName];
        resolvedClass = NSClassFromString(className);
        if(resolvedClass)
            *stop = YES;
    }];
    
    return resolvedClass;
}

+ (BOOL)isMountainLion {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
    Class Message = [self resolveMailClassFromName:@"Message"];
    return [Message instancesRespondToSelector:@selector(dataSource)];
#pragma clang diagnostic pop
}

+ (BOOL)isLion {
    return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6 && ![self isMountainLion] && ![self isMavericks] && ![self isYosemite];
}

+ (BOOL)isMavericks {
    return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_8;
}

+ (BOOL)isYosemite {
    return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9;
}

+ (BOOL)isElCapitan {
    return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_10;
}

+ (BOOL)hasPreferencesPanel {
    // LEOPARD Invoked on +initialize. Else, invoked from +registerBundle.
	return YES;
}

+ (NSString *)preferencesOwnerClassName {
	return NSStringFromClass([GPGMailPreferences class]);
}

+ (NSString *)preferencesPanelName {
	return GMLocalizedString(@"PGP_PREFERENCES");
}

+ (id)backEndFromObject:(id)object {
    id backEnd = nil;
    if([object isKindOfClass:[GPGMailBundle resolveMailClassFromName:@"HeadersEditor"]]) {
        if([GPGMailBundle isElCapitan])
            backEnd = [[object composeViewController] backEnd];
        else
            backEnd = [[object valueForKey:@"_documentEditor"] backEnd];
    }
    else if([object isKindOfClass:[GMSecurityControl class]]) {
        if([GPGMailBundle isElCapitan])
            backEnd = [[object composeViewController] backEnd];
        else
            backEnd = [[object valueForKey:@"_documentEditor"] backEnd];
    }
    
    //NSAssert(backEnd != nil, @"Couldn't find a way to access the ComposeBackEnd");
    
    return backEnd;
}

@end
