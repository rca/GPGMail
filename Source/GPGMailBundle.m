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
#import <dispatch/dispatch.h>
#import <ExceptionHandling/ExceptionHandling.h>
#import <Sparkle/Sparkle.h>
#import <Libmacgpg/Libmacgpg.h>
#import <MailApp.h>
#import <MailAccount.h>
#import "JRLPSwizzle.h"
#import "CCLog.h"
#import "NSSet+Functional.h"
#import "NSString+GPGMail.h"
//#import "GPGDefaults.h"
#import "GPGMailPreferences.h"
#import "GPGKeyDownload.h"
#import "GPGProgressIndicatorController.h"
#import "GPGMailBundle.h"
#import "GPGVersionComparator.h"


NSString *GPGMailSwizzledMethodPrefix = @"MA";
NSString *GPGMailAgent = @"GPGMail %@";

int GPGMailLoggingLevel = 1;

static BOOL gpgMailWorks = YES;

@interface GPGMailBundle ()
@property (nonatomic, retain) SUUpdater *updater;
- (void)updateGPGKeys:(NSObject <EnumerationList> *)keys;
@end

// Remove registerBundle warning.
@interface NSObject (GPGMail)
- (void)registerBundle;
@end

@implementation GPGMailBundle

@synthesize publicGPGKeys, secretGPGKeys, allGPGKeys, updater, accountExistsForSigning, componentsMissing = _componentsMissing,
secretGPGKeysByEmail = _secretGPGKeysByEmail, publicGPGKeysByEmail = _publicGPGKeysByEmail, gpgc;

+ (void)load {
	GPGMailLoggingLevel = 1; //[[GPGOptions sharedOptions] integerForKey:@"GPGMailDebug"];
    NSLog(@"Logging Level: %d", GPGMailLoggingLevel);
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
    //	DebugLog(@"Adding GPGMail methods");
    NSArray *swizzleMap = [NSArray arrayWithObjects:
                           // Mail internal classes.
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"MessageHeaderDisplay", @"class",
                            @"MessageHeaderDisplay_GPGMail", @"gpgMailClass",
                            [NSArray arrayWithObjects:
                             @"_attributedStringForSecurityHeader",
                             @"textView:clickedOnLink:atIndex:", nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"ComposeBackEnd", @"class",
                            @"ComposeBackEnd_GPGMail", @"gpgMailClass",
                            [NSArray arrayWithObjects:
                             @"_makeMessageWithContents:isDraft:shouldSign:shouldEncrypt:shouldSkipSignature:shouldBePlainText:",
                             @"canEncryptForRecipients:sender:",
                             @"canSignFromAddress:",
                             @"recipientsThatHaveNoKeyForEncryption",
                             @"setEncryptIfPossible:",
                             @"setSignIfPossible:",
                             nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"ComposeHeaderView", @"class",
                            @"ComposeHeaderView_GPGMail", @"gpgMailClass",
                            [NSArray arrayWithObjects:
                             @"_calculateSecurityFrame:",
                             @"awakeFromNib", nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"HeadersEditor", @"class",
                            @"HeadersEditor_GPGMail", @"gpgMailClass",
                            [NSArray arrayWithObjects:
                             @"securityControlChanged:", nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"MessageAttachment", @"class",
                            @"MessageAttachment_GPGMail", @"gpgMailClass",
                            [NSArray arrayWithObjects:
                             @"filename", nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"OptionalView", @"class",
                            @"OptionalView_GPGMail", @"gpgMailClass",
                            [NSArray arrayWithObjects:
                             @"widthIncludingOptionSwitch:", nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"MailDocumentEditor", @"class",
                            @"MailDocumentEditor_GPGMail", @"gpgMailClass",
                            [NSArray arrayWithObjects:
                             @"backEndDidLoadInitialContent:",
                             @"dealloc",
                             @"windowForMailFullScreen", nil], @"selectors", nil],
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
                             @"decodeTextPlainWithContext:",
                             @"decodeTextHtmlWithContext:",
                             @"decodeApplicationOctet_streamWithContext:",
                             //                @"copySignerLabels",
                             //                @"copyMessageSigners",
                             @"isSigned",
                             @"isMimeSigned",
                             @"isMimeEncrypted",
                             @"usesKnownSignatureProtocol",
                             @"clearCachedDecryptedMessageBody",
                             @"setDecryptedMessageBody:isEncrypted:isSigned:error:",
                             nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"MimeBody", @"class",
                            [NSArray arrayWithObjects:
                             @"isSignedByMe",
                             @"_isPossiblySignedOrEncrypted", nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"Message", @"class",
                            [NSArray arrayWithObjects:
                             @"messageBodyUpdatingFlags:", nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"MailAccount", @"class",
                            [NSArray arrayWithObjects:
                             @"accountExistsForSigning", nil], @"selectors", nil],
                           //                           [NSDictionary dictionaryWithObjectsAndKeys:
                           //                            @"Message", @"class",
                           //                            [NSArray arrayWithObjects:
                           //                             @"messageBodyUpdatingFlags:", nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"NSPreferences", @"class",
                            [NSArray arrayWithObjects:
                             @"sharedPreferences",
                             @"windowWillResize:toSize:",
                             @"toolbarItemClicked:",
                             @"showPreferencesPanelForOwner:", nil], @"selectors", nil],
                           nil];
    
    
    NSError *error = nil;
    for(NSDictionary *swizzleInfo in swizzleMap) {
        // If this is a non Messages.framework class, add all methods
        // of the class referenced in gpgMailClass first.
        Class mailClass = NSClassFromString([swizzleInfo objectForKey:@"class"]);
        if([swizzleInfo objectForKey:@"gpgMailClass"]) {
            Class gpgMailClass = NSClassFromString([swizzleInfo objectForKey:@"gpgMailClass"]);
            if(!mailClass) {
                NSLog(@"WARNING: Class %@ doesn't exist. GPGMail might behave weirdly!", [swizzleInfo objectForKey:@"class"]);
                continue;
            }
            if(!gpgMailClass) {
                NSLog(@"WARNING: Class %@ doesn't exist. GPGMail might behave weirdly!", [swizzleInfo objectForKey:@"gpgMailClass"]);
                continue;
            }
            [mailClass jrlp_addMethodsFromClass:gpgMailClass error:&error];
            if(error)
                NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
            error = nil;
        }
        for(NSString *method in [swizzleInfo objectForKey:@"selectors"]) {
            error = nil;
            NSString *gpgMethod = [NSString stringWithFormat:@"%@%@%@", GPGMailSwizzledMethodPrefix, [[method substringToIndex:1] uppercaseString], [method substringFromIndex:1]];
            [mailClass jrlp_swizzleMethod:NSSelectorFromString(method) withMethod:NSSelectorFromString(gpgMethod) error:&error];
            if(error) {
                error = nil;
                // Try swizzling as class method on error.
                [mailClass jrlp_swizzleClassMethod:NSSelectorFromString(method) withClassMethod:NSSelectorFromString(gpgMethod) error:&error];
                if(error)
                    NSLog(@"[DEBUG] %s Class Error: %@", __PRETTY_FUNCTION__, error);
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
	// Automatically performs the check, since the check is performed in init.
    GPGMailBundle *instance = [GPGMailBundle sharedInstance];
    [instance description];
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
    [(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"encryption_unlocked"]] setName:@"decryptedBadge"];
    
    [(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"invalid-signature-icon-overlay"]] setName:@"invalid-signature-icon-overlay"];
    
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

/**
 Installs the sparkle updater.
 TODO: Sparkle should automatically start to check, but sometimes it doesn't work.
 */
+ (void)_installSparkleUpdater {
    SUUpdater *updater = [SUUpdater updaterForBundle:[NSBundle bundleForClass:[self class]]];
	updater.delegate = [self sharedInstance];
	[updater resetUpdateCycle];
    [[self sharedInstance] setUpdater:updater];
}

- (NSString *)pathToRelaunchForUpdater:(SUUpdater *)updater {
	return @"/Applications/Mail.app";
}

- (id <SUVersionComparison>)versionComparatorForUpdater:(SUUpdater *)updater {
    return [GPGVersionComparator sharedVersionComparator];
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

- (void)addVerificationTask:(gpgmail_verification_task_t)task {
    dispatch_sync(verificationQueue, task);
}

- (void)addCollectionTask:(gpgmail_verification_task_t)task {
    dispatch_sync(verificationQueue, task);
}

- (BOOL)gpgMailWorks {
	return gpgMailWorks;
}

// TODO: Fix me for libmacgpg
- (BOOL)checkGPG {
    GPGErrorCode errorCode = (GPGErrorCode)[GPGController testGPG];
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    switch (errorCode) {
        case GPGErrorNotFound:
            NSRunCriticalAlertPanel(NSLocalizedStringFromTableInBundle(@"GPG_NOT_FOUND_TITLE", @"GPGMail", myBundle, ""), NSLocalizedStringFromTableInBundle(@"GPG_NOT_FOUND_MESSAGE", @"GPGMail", myBundle, ""), nil, nil, nil);
            break;
        case GPGErrorConfigurationError:
            NSRunCriticalAlertPanel(NSLocalizedStringFromTableInBundle(@"GPG_CONFIG_ERROR_TITLE", @"GPGMail", myBundle, ""), NSLocalizedStringFromTableInBundle(@"GPG_CONFIG_ERROR_MESSAGE", @"GPGMail", myBundle, ""), nil, nil, nil);
            break;
        case GPGErrorNoError: {
            NSString *pinentryPath = [GPGTask pinentryPath];
            BOOL pinentryAvailable = [pinentryPath length] > 0;
            self.componentsMissing = !pinentryAvailable;
            if(!pinentryAvailable) {
                NSRunCriticalAlertPanel(NSLocalizedStringFromTableInBundle(@"GPG_CONFIG_ERROR_NO_PINENTRY_TITLE", @"GPGMail", myBundle, ""), NSLocalizedStringFromTableInBundle(@"GPG_CONFIG_ERROR_NO_PINENTRY_MESSAGE", @"GPGMail", myBundle, ""), nil, nil, nil);
            }
            
            return YES;
        }
        default:
            break;
    }
    self.componentsMissing = YES;
    return NO;
}

- (void)finishInitialization {
    // Create the decryption queue.
    decryptionQueue = dispatch_queue_create("org.gpgmail.decryption", NULL);
    verificationQueue = dispatch_queue_create("org.gpgmail.verification", NULL);
    collectingQueue = dispatch_queue_create("org.gpgmail.collection", NULL);
    keysUpdateQueue = dispatch_queue_create("org.gpgmail.update", DISPATCH_QUEUE_CONCURRENT);
    
    // Init GPGController.
    [self gpgc];
    
    self.accountExistsForSigning = YES;
    
}

- (id)init {
	if (self = [super init]) {
		NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
		NSDictionary *defaultsDictionary = [NSDictionary dictionaryWithContentsOfFile:[myBundle pathForResource:@"GPGMailBundle" ofType:@"defaults"]];
        
		[[GPGOptions sharedOptions] setStandardDomain:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
		if (defaultsDictionary) {
			[[GPGOptions sharedOptions] registerDefaults:defaultsDictionary];
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

- (void)dealloc {
    // Release the decryption queue.
    dispatch_release(decryptionQueue);
    
    self.secretGPGKeys = nil;
    self.publicGPGKeys = nil;
    self.secretGPGKeysByEmail = nil;
    self.publicGPGKeysByEmail = nil;
    self.updater = nil;
    [gpgc release];
    gpgc = nil;
    [updateLock release];
    updateLock = nil;
    [allGPGKeys release];
    allGPGKeys = nil;
    
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

/* Set: use OpenPGP to send messages */
- (void)setUsesOpenPGPToSend:(BOOL)flag {
	[[GPGOptions sharedOptions] setBool:flag forKey:@"UseOpenPGPToSend"];
}

/* Get: use OpenPGP to send messages */
- (BOOL)usesOpenPGPToSend {
	return [[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToSend"];
}

/* Set: use OpenPGP to receive messages */
- (void)setUsesOpenPGPToReceive:(BOOL)flag {
	[[GPGOptions sharedOptions] setBool:flag forKey:@"UseOpenPGPToReceive"];
}

/* Get: use OpenPGP to receive messages */
- (BOOL)usesOpenPGPToReceive {
	return [[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToReceive"];
}

- (void)setWarnedAboutMissingPrivateKeys:(BOOL)flag {
    [[GPGOptions sharedOptions] setBool:flag forKey:@"WarnAboutMissingPrivateKeys"];
}

- (BOOL)warnedAboutMissingPrivateKeys {
    return [[GPGOptions sharedOptions] boolForKey:@"WarnAboutMissingPrivateKeys"];
}

- (void)warnUserForMissingPrivateKeys:(id)sender {
	NSBundle *aBundle = [NSBundle bundleForClass:[self class]];
	NSString *aTitle = NSLocalizedStringFromTableInBundle(@"NO PGP PRIVATE KEY - TITLE", @"GPGMail", aBundle, "");
	NSString *aMessage = NSLocalizedStringFromTableInBundle(@"NO PGP PRIVATE KEY - MESSAGE", @"GPGMail", aBundle, "");
    
	(void)NSRunAlertPanel(aTitle, @"%@", nil, nil, nil, aMessage);
	[self setWarnedAboutMissingPrivateKeys:YES];
}

- (BOOL)canSignMessagesFromAddress:(NSString *)address {
    NSString *fingerprint = [self.secretGPGKeysByEmail valueForKey:[address gpgNormalizedEmail]];
    return (fingerprint != nil);
}

- (BOOL)canEncryptMessagesToAddress:(NSString *)address {
    NSString *fingerprint = [self.publicGPGKeysByEmail objectForKey:[address gpgNormalizedEmail]];
    return (fingerprint != nil);
}

- (NSMutableSet *)publicKeyListForAddresses:(NSArray *)recipients {
    NSMutableSet *keyList = [NSMutableSet setWithCapacity:[recipients count]];
    GPGKey *tmpKey;
    for(NSString *recipient in recipients) {
        recipient = [recipient gpgNormalizedEmail];
        tmpKey = [self.publicGPGKeysByEmail objectForKey:recipient];
        if (tmpKey)
            [keyList addObject:tmpKey];
    }
    return keyList;
}

- (NSMutableSet *)signingKeyListForAddresses:(NSArray *)senders {
    NSMutableSet *keyList = [NSMutableSet setWithCapacity:[senders count]];
    GPGKey *tmpKey;
    for(NSString *sender in senders) {
        sender = [sender gpgNormalizedEmail];
        tmpKey = [self.secretGPGKeysByEmail objectForKey:sender];
        if (tmpKey)
            [keyList addObject:tmpKey];
    }
    return keyList;
}


- (NSSet *)allGPGKeys {
    if (!gpgMailWorks) return nil;
    
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        allGPGKeys = [[NSMutableSet alloc] init];
        [self updateGPGKeys:nil];
    });
    
    return allGPGKeys;
}

- (GPGController *)gpgc {
    if (!gpgMailWorks) return nil;
    if (!gpgc) {
        updateLock = [NSLock new];
        gpgc = [[GPGController alloc] init];
        gpgc.verbose = NO; //(GPGMailLoggingLevel > 0);
        gpgc.delegate = self;
        
        [self allGPGKeys];
    }
    return gpgc;
}

- (void)gpgController:(GPGController *)gpgc keysDidChanged:(NSObject<EnumerationList> *)keys external:(BOOL)external {
    dispatch_async(keysUpdateQueue, ^(void) {
        [self updateGPGKeys:keys];
    });
}

- (void)updateGPGKeys:(NSObject <EnumerationList> *)keys {
    if (!gpgMailWorks) return;
    
	NSLog(@"updateGPGKeys: start");
	if (![updateLock tryLock]) {
		NSLog(@"updateGPGKeys: tryLock return");
		return;
	}
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@try {
		NSMutableSet *realKeys = [NSMutableSet setWithCapacity:[keys count]];
		
		//Fingerabdrücke wenn möglich durch die entsprechenden Schlüssel ersetzen.
		Class keyClass = [GPGKey class];
		for (GPGKey *key in keys) {
			if (![key isKindOfClass:keyClass]) {
				GPGKey *tempKey = [allGPGKeys member:key];
				if (tempKey) {
					key = tempKey;
				}
			}
			[realKeys addObject:key];
		}
		keys = realKeys;
        
		
		NSSet *updatedKeys;
		if ([keys count] == 0) {
            //Update all keys.
			updatedKeys = [self.gpgc updateKeys:allGPGKeys searchFor:nil withSigs:NO];
		} else {
            //Update only the keys in 'keys'.
			updatedKeys = [self.gpgc updateKeys:keys withSigs:NO];
		}
        
        if (gpgc.error) {
			@throw gpgc.error;
		}
		
		if ([keys count] == 0) {
			keys = allGPGKeys;
		}
		NSMutableSet *keysToRemove = [keys mutableCopy];
		[keysToRemove minusSet:updatedKeys];
		
        [allGPGKeys minusSet:keysToRemove];
        [allGPGKeys unionSet:updatedKeys];
        
        //Flush caches.
        self.secretGPGKeys = nil;
        self.publicGPGKeys = nil;
        self.secretGPGKeysByEmail = nil;
        self.publicGPGKeysByEmail = nil;
        
	} @catch (GPGException *e) {
		NSLog(@"updateGPGKeys: failed - %@ (ErrorText: %@)", e, e.gpgTask.errText);
	} @catch (NSException *e) {
		NSLog(@"updateGPGKeys: failed - %@", e);
	} @finally {
		[pool drain];
		[updateLock unlock];
	}
	
	NSLog(@"updateGPGKeys: end");
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

- (NSSet *)secretGPGKeys {
    NSSet *allKeys;
    
    if(!gpgMailWorks)
        return nil;
    if(!secretGPGKeys) {
        allKeys = [self allGPGKeys];
        self.secretGPGKeys = [allKeys filter:^(id obj) {
            return ((GPGKey *)obj).secret && [self canKeyBeUsedForSigning:obj] ? obj : nil;
        }];
        
        if ([secretGPGKeys count] == 0 && ![self warnedAboutMissingPrivateKeys]) {
			[self performSelector:@selector(warnUserForMissingPrivateKeys:) withObject:nil afterDelay:0];
		}
    }
    
    return secretGPGKeys;
}

- (NSDictionary *)secretGPGKeysByEmail {
    if(!_secretGPGKeysByEmail) {
        self.secretGPGKeysByEmail = [self emailMapForGPGKeys:self.secretGPGKeys];
    }
    return _secretGPGKeysByEmail;
}

- (NSDictionary *)publicGPGKeysByEmail {
    if(!_publicGPGKeysByEmail) {
        self.publicGPGKeysByEmail = [self emailMapForGPGKeys:self.publicGPGKeys];
    }
    return _publicGPGKeysByEmail;
}


- (NSSet *)publicGPGKeys {
    NSSet *allKeys;
    
    if(!gpgMailWorks)
        return nil;
    
    if(!publicGPGKeys) {
        allKeys = [self allGPGKeys];
        self.publicGPGKeys = [allKeys filter:^(id obj) {
            return [self canKeyBeUsedForEncryption:obj] ? obj : nil;
        }];
    }
    
    return publicGPGKeys;
}

- (BOOL)canKeyBeUsedForEncryption:(GPGKey *)key {
	// Only either the key or one of the subkeys has to be valid,
    // non-expired, non-disabled, non-revoked and be used for encryption.
    // We don't care about ownerTrust, validity
	return key.canAnyEncrypt && key.status < GPGKeyStatus_Invalid;
}

// TODO: Public key might not be available... how can this be?
- (BOOL)canKeyBeUsedForSigning:(GPGKey *)key {
	// Only either the key or one of the subkeys has to be valid,
    // non-expired, non-disabled, non-revoked and be used for encryption.
    // We don't care about ownerTrust, validity
	return key.canAnySign && key.status < GPGKeyStatus_Invalid;
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

+ (NSNumber *)bundleBuildNumber {
    return [[[NSBundle bundleForClass:self] infoDictionary] valueForKey:@"CFBuildNumber"];
}

+ (NSString *)agentHeader {
    return [NSString stringWithFormat:GPGMailAgent, [self bundleVersion]];
}

@end
