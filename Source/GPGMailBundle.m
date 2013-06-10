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
#import "GPGMailPreferences.h"
#import "GPGMailBundle_Private.h"
#import "Message.h"
#define restrict
#import <RegexKit/RegexKit.h>

NSString *GPGMailSwizzledMethodPrefix = @"MA";
NSString *GPGMailAgent = @"GPGMail %@";
NSString *GPGMailKeyringUpdatedNotification = @"GPGMailKeyringUpdatedNotification";
NSString *gpgErrorIdentifier = @"^~::gpgmail-error-code::~^";

int GPGMailLoggingLevel = 1;
static BOOL gpgMailWorks = NO;




@implementation GPGMailBundle

@synthesize publicGPGKeys, secretGPGKeys, allGPGKeys, updater, accountExistsForSigning,
gpgc, publicGPGKeysByID, secretGPGKeysByID, gpgStatus, bundleImages = _bundleImages,
publicKeyMapping, secretKeyMapping;


- (void)_installGPGMail {
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
                             @"_saveThreadShouldCancel",
                             @"_configureLastDraftInformationFromHeaders:overwrite:",
                             nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"HeadersEditor", @"class",
                            @"HeadersEditor_GPGMail", @"gpgMailClass",
                            [NSArray arrayWithObjects:
                             @"securityControlChanged:",
                             @"_updateFromAndSignatureControls:",
                             @"changeFromHeader:",
                             @"init",
                             @"dealloc",
                             @"_updateSecurityStateInBackgroundForRecipients:sender:",
                             @"awakeFromNib",
                             @"_updateSignButtonTooltip",
                             @"_updateEncryptButtonTooltip",
                             nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"MessageAttachment", @"class",
                            @"MessageAttachment_GPGMail", @"gpgMailClass",
                            [NSArray arrayWithObjects:
                             @"filename", nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"MailDocumentEditor", @"class",
                            @"MailDocumentEditor_GPGMail", @"gpgMailClass",
                            [NSArray arrayWithObjects:
                             @"backEndDidLoadInitialContent:",
                             @"dealloc",
                             //                             @"windowForMailFullScreen",
                             @"backEnd:didCancelMessageDeliveryForEncryptionError:",
                             nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"NSWindow", @"class",
                            [NSArray arrayWithObjects:
                             @"toggleFullScreen:",
                             nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"MessageContentController", @"class",
                            @"MessageContentController_GPGMail", @"gpgMailClass",
                            [NSArray arrayWithObjects:
                             @"setMessageToDisplay:", nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"BannerController", @"class",
                            @"BannerController_GPGMail", @"gpgMailClass",
                            [NSArray arrayWithObjects:
                             @"updateBannerForViewingState:", nil], @"selectors", nil],
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
                             @"isSigned",
                             @"isMimeSigned",
                             @"isMimeEncrypted",
                             @"usesKnownSignatureProtocol",
                             @"clearCachedDecryptedMessageBody",
                             nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"MimeBody", @"class",
                            [NSArray arrayWithObjects:
                             @"isSignedByMe",
                             @"_isPossiblySignedOrEncrypted", nil], @"selectors", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"MailAccount", @"class",
                            [NSArray arrayWithObjects:
                             @"accountExistsForSigning", nil], @"selectors", nil],
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
                DebugLog(@"WARNING: Class %@ doesn't exist. GPGMail might behave weirdly!", [swizzleInfo objectForKey:@"class"]);
                continue;
            }
            if(!gpgMailClass) {
                DebugLog(@"WARNING: Class %@ doesn't exist. GPGMail might behave weirdly!", [swizzleInfo objectForKey:@"gpgMailClass"]);
                continue;
            }
            [mailClass jrlp_addMethodsFromClass:gpgMailClass error:&error];
            if(error)
                DebugLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
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
                    DebugLog(@"[DEBUG] %s Class Error: %@", __PRETTY_FUNCTION__, error);
            }
        }
    }
    
}

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
    [fileManager release];
    
    return (NSArray *)installations;
}

+ (void)showMultipleInstallationsErrorAndExit:(NSArray *)installations {
    NSAlert *errorModal = [[NSAlert alloc] init];
    
    errorModal.messageText = NSLocalizedStringFromTableInBundle(@"GPGMAIL_MULTIPLE_INSTALLATIONS_TITLE", @"GPGMail", [NSBundle bundleForClass:self], @"");
    errorModal.informativeText = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"GPGMAIL_MULTIPLE_INSTALLATIONS_MESSAGE", @"GPGMail", [NSBundle bundleForClass:self], @""), [installations componentsJoinedByString:@"\n"]];
    [errorModal addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"GPGMAIL_MULTIPLE_INSTALLATIONS_BUTTON", @"GPGMail", [NSBundle bundleForClass:self], @"")];
    [errorModal runModal];
    
    [errorModal release];
    
    // It's not at all a good idea to use exit and kill the app,
    // but in this case it's alright because otherwise the user would experience a
    // crash anyway.
    exit(0);
}

+ (void)initialize {
	// If one happens to have for any reason (like for example installed GPGMail
    // from the installer, which will reside in /Library and compiled with XCode
    // which will reside in ~/Library) two GPGMail.mailbundle's,
    // display an error message to the user and shutdown Mail.app.
    NSArray *installations = [self multipleInstallations];
    if([installations count] > 1) {
        [self showMultipleInstallationsErrorAndExit:installations];
        return;
    }
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
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
    class_setSuperclass([self class], mvMailBundleClass);
#pragma GCC diagnostic pop
    
    // Initialize the bundle by swizzling methods, loading keys, ...
    GPGMailBundle *instance = [GPGMailBundle sharedInstance];
    NSLog(@"Loaded GPGMail %@", [instance version]);
    
    [((MVMailBundle *)[self class]) registerBundle];             // To force registering composeAccessoryView and preferences
}

- (void)_loadImages {
    /**
     * Loads all images which are used in the GPGMail User interface.
     */
    // We need to load images and name them, because all images are searched by their name; as they are not located in the main bundle,
	// +[NSImage imageNamed:] does not find them.
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    
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
                                  @"CertLargeNotTrusted"];
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
        [image release];
    }
    
    self.bundleImages = bundleImages;
    
    [bundleImages release];
}

+ (BOOL)hasPreferencesPanel {
	return YES;             // LEOPARD Invoked on +initialize. Else, invoked from +registerBundle
}

+ (NSString *)preferencesOwnerClassName {
	return NSStringFromClass([GPGMailPreferences class]);
}

+ (NSString *)preferencesPanelName {
	return NSLocalizedStringFromTableInBundle(@"PGP_PREFERENCES", @"GPGMail", [NSBundle bundleForClass:self], "PGP preferences panel name");
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
    gpgmail_verification_task_t taskCopy = Block_copy(task);
    dispatch_async(collectingQueue, task);
    Block_release(taskCopy);
}

+ (BOOL)gpgMailWorks {
	return gpgMailWorks;
}
- (BOOL)gpgMailWorks {
	return gpgMailWorks;
}


- (BOOL)checkGPG {
    self.gpgStatus = (GPGErrorCode)[GPGController testGPG];
    switch (gpgStatus) {
        case GPGErrorNotFound:
            DebugLog(@"DEBUG: checkGPG - GPGErrorNotFound");
            break;
        case GPGErrorConfigurationError:
            DebugLog(@"DEBUG: checkGPG - GPGErrorConfigurationError");
        case GPGErrorNoError:
            return YES;
        default:
            DebugLog(@"DEBUG: checkGPG - %i", gpgStatus);
            break;
    }
    return NO;
}

- (void)cleanOldPlist {
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_7) {
        //Diese Methode kann nach dem Release 2.1 gelöscht werden.
        NSString *oldPlistPath = [@"~/Library/Preferences/org.gpgtools.gpgmail.plist" stringByExpandingTildeInPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:oldPlistPath]) {
            NSLog(@"Deleting old org.gpgtools.gpgmail.plist");
            [fileManager removeItemAtPath:oldPlistPath error:nil];
        }
    }
}

- (void)finishInitialization {
    // Create the decryption queue.
    decryptionQueue = dispatch_queue_create("org.gpgmail.decryption", NULL);
    verificationQueue = dispatch_queue_create("org.gpgmail.verification", NULL);
    collectingQueue = dispatch_queue_create("org.gpgmail.collection", NULL);
    keysUpdateQueue = dispatch_queue_create("org.gpgmail.update", DISPATCH_QUEUE_CONCURRENT);
    
    // Init GPGController.
    [self gpgc];
    
    // Swizzling the Mail classes.
    [self _installGPGMail];
    // Load all necessary images.
    [self _loadImages];
    // Install the Sparkle Updater.
    [self _installSparkleUpdater];
    
    self.accountExistsForSigning = YES;
    
    [NSThread detachNewThreadSelector:@selector(cleanOldPlist) toTarget:self withObject:nil]; //Siehe cleanOldPlist
}

- (id)init {
	if (self = [super init]) {
		NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
		NSDictionary *defaultsDictionary = [NSDictionary dictionaryWithContentsOfFile:[myBundle pathForResource:@"GPGMailBundle" ofType:@"defaults"]];
        
        [[GPGOptions sharedOptions] setStandardDomain:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
		if (defaultsDictionary) {
			[[GPGOptions sharedOptions] registerDefaults:defaultsDictionary];
		}
        
        GPGMailLoggingLevel = (int)[[GPGOptions sharedOptions] integerForKey:@"DebugLog"];
        NSLog(@"Debug Log enabled: %@", [[GPGOptions sharedOptions] integerForKey:@"DebugLog"] > 0 ? @"YES" : @"NO");
        
        gpgMailWorks = [self checkGPG];
        [self finishInitialization];
        
	}
    
	return self;
}

- (void)dealloc {
    // Release the dispatch queues.
    dispatch_release(decryptionQueue);
    dispatch_release(verificationQueue);
    dispatch_release(collectingQueue);
    dispatch_release(keysUpdateQueue);
    
    self.bundleImages = nil;
    self.secretGPGKeys = nil;
    self.publicGPGKeys = nil;
    self.updater = nil;
    [gpgc release];
    gpgc = nil;
    [updateLock release];
    updateLock = nil;
    [allGPGKeys release];
    allGPGKeys = nil;
    [_bundleImages release];
    _bundleImages = nil;
    
    
	struct objc_super s = { self, [self superclass] };
    objc_msgSendSuper(&s, @selector(dealloc));
    
    // Suppress the missing dealloc warning, since the real super dealloc
    // call uses the objc runtime calls directly.
    if(0)
        [super dealloc];
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


#pragma mark Sparkle

- (void)_installSparkleUpdater {
    /**
     Installs the sparkle updater.
     TODO: Sparkle should automatically start to check, but sometimes it doesn't work.
     */
    SUUpdater *sparkleUpdater = [SUUpdater updaterForBundle:[NSBundle bundleForClass:[self class]]];
	sparkleUpdater.delegate = self;
	[sparkleUpdater resetUpdateCycle];
    self.updater = sparkleUpdater;
}

- (NSString *)pathToRelaunchForUpdater:(SUUpdater *)updater {
	return @"/Applications/Mail.app";
}

- (BOOL)updater:(SUUpdater *)updater relaunchUsingPath:(NSString *)path arguments:(NSArray *)arguments {
    [GPGTask launchGeneralTask:path withArguments:arguments];
    return YES;
}

- (NSString *)feedURLStringForUpdater:(SUUpdater *)updater {
	NSString *updateSourceKey = @"UpdateSource";
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	
	NSString *feedURLKey = @"SUFeedURL";
	NSString *appcastSource = [[GPGOptions sharedOptions] stringForKey:updateSourceKey];
	if ([appcastSource isEqualToString:@"nightly"]) {
		feedURLKey = @"SUFeedURL_nightly";
	} else if ([appcastSource isEqualToString:@"prerelease"]) {
		feedURLKey = @"SUFeedURL_prerelease";
	} else if (![appcastSource isEqualToString:@"stable"]) {
		NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
		if ([version rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"nN"]].length > 0) {
			feedURLKey = @"SUFeedURL_nightly";
		} else if ([version rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"abAB"]].length > 0) {
			feedURLKey = @"SUFeedURL_prerelease";
		}
	}
	
	NSString *appcastURL = [bundle objectForInfoDictionaryKey:feedURLKey];
	if (!appcastURL) {
		appcastURL = [bundle objectForInfoDictionaryKey:@"SUFeedURL"];
	}
	return appcastURL;
}

- (id<SUUserDefaults>)userDefaults {
    return [GPGOptions sharedOptions];
}


#pragma mark "Updating keys"

- (GPGController *)gpgc {
    if (!gpgMailWorks) return nil;
    if (!gpgc) {
        updateLock = [NSLock new];
        gpgc = [[GPGController alloc] init];
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
    
	if (![updateLock tryLock])
		return;
	
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
            // Don't use self.gpgc here, since that calls allKeys which stalls
            // if it didn't complete once.
			updatedKeys = [gpgc updateKeys:allGPGKeys searchFor:nil withSigs:NO];
		} else {
            //Update only the keys in 'keys'.
			// Don't use self.gpgc here, since that calls allKeys which stalls
            // if it didn't complete once.
            updatedKeys = [gpgc updateKeys:keys withSigs:NO];
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
        
        [keysToRemove release];
        keysToRemove = nil;
        
        //Flush caches.
        [self flushGPGKeys];
        
	} @catch (GPGException *e) {
		DebugLog(@"updateGPGKeys: failed - %@ (ErrorText: %@)", e, e.gpgTask.errText);
	} @catch (NSException *e) {
		DebugLog(@"updateGPGKeys: failed - %@", e);
	} @finally {
		[pool drain];
		[updateLock unlock];
	}
	
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] postNotificationName:GPGMailKeyringUpdatedNotification object:self];
}


#pragma mark "Handling keys"

- (void)flushGPGKeys {
    self.secretGPGKeys = nil;
    self.publicGPGKeys = nil;
    self.secretGPGKeysByID = nil;
    self.publicGPGKeysByID = nil;
    self.publicKeyMapping = nil;
    self.secretKeyMapping = nil;
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

- (NSSet *)secretGPGKeys {
    if(!gpgMailWorks)
        return nil;
    
    if(!secretGPGKeys) {
        self.secretGPGKeys = [self.allGPGKeys filter:^id(GPGKey *key) {
            // Only either the key or one of the subkeys has to be valid,
            // non-expired, non-disabled, non-revoked and be used for signing.
            // We don't care about ownerTrust, validity.
            if (key.secret && key.canAnySign && key.status < GPGKeyStatus_Invalid) {
                return key;
            } else {
                return nil;
            }

        }];
    }
    
    return secretGPGKeys;
}

- (NSSet *)publicGPGKeys {
    if(!gpgMailWorks)
        return nil;
    
    if(!publicGPGKeys) {
        self.publicGPGKeys = [self.allGPGKeys filter:^id(GPGKey *key) {
            // Only either the key or one of the subkeys has to be valid,
            // non-expired, non-disabled, non-revoked and be used for encryption.
            // We don't care about ownerTrust, validity.
            if (key.canAnyEncrypt && key.status < GPGKeyStatus_Invalid) {
                return key;
            } else {
                return nil;
            }
        }];
    }
    
    return publicGPGKeys;
}

- (NSDictionary *)publicGPGKeysByID {
    if (!publicGPGKeysByID) {
        NSMutableDictionary *idMap = [[NSMutableDictionary alloc] initWithCapacity:0];
        for (GPGKey *key in self.publicGPGKeys) {
            [idMap setValue:key forKey:key.keyID];
            for (GPGKey *subkey in key.subkeys)
                [idMap setValue:subkey forKey:subkey.keyID];
        }
        self.publicGPGKeysByID = idMap;
        [idMap release];
    }
    return publicGPGKeysByID;
}

- (NSDictionary *)secretGPGKeysByID {
    if(!secretGPGKeysByID) {
        NSMutableDictionary *idMap = [[NSMutableDictionary alloc] initWithCapacity:0];
        for(GPGKey *key in self.secretGPGKeys) {
            [idMap setValue:key forKey:key.keyID];
            for(GPGKey *subkey in key.subkeys)
                [idMap setValue:subkey forKey:subkey.keyID];
        }
        self.secretGPGKeysByID = idMap;
        [idMap release];
    }
    return secretGPGKeysByID;
}

- (NSDictionary *)userMappedKeysSecretOnly:(BOOL)secretOnly {
    /* "KeyMapping" is a dictionary the form @{@"Address": @"KeyID", @"*@domain.com": @"Fingerprint", @"Address": @[@"KeyID", @"Name", @"Fingerprint"]} */
    NSMutableDictionary *mappedKeys = [[GPGOptions sharedOptions] valueInCommonDefaultsForKey:@"KeyMapping"];

	Class stringClass = [NSString class];
	Class arrayClass = [NSArray class];
    
    NSMutableDictionary *cleanMappedKeys = [NSMutableDictionary dictionary];
    for (NSString *pattern in mappedKeys) {
        id keyIdentifier = [mappedKeys objectForKey:pattern];
        id object = nil;
        
        if ([keyIdentifier isKindOfClass:stringClass]) {
            object = [self findKeyByHint:keyIdentifier onlySecret:secretOnly];
        } else if ([keyIdentifier isKindOfClass:arrayClass]) {
            NSMutableArray *keys = [NSMutableArray array];
            for (NSString *hint in keyIdentifier) {
                GPGKey *key = [self findKeyByHint:hint onlySecret:secretOnly];
                if (key) {
                    [keys addObject:key];
                    object = keys;
                }
            }
        }
        
        
        if ([pattern rangeOfString:@"*"].length > 0) {
            NSString *regexString =  [NSString stringWithFormat:@"^%@$", [[NSRegularExpression escapedPatternForString:pattern] stringByReplacingOccurrencesOfString:@"\\*" withString:@".*"]];
            pattern = [RKRegex regexWithRegexString:regexString library:RKRegexPCRELibrary options:RKCompileCaseless | RKCompileMultiline error:nil];
        } else {
            pattern = [pattern gpgNormalizedEmail];
        }
        
        if (object)
            [cleanMappedKeys setObject:object forKey:pattern];
    }
    
    return cleanMappedKeys;
}

- (NSDictionary *)groups {
    NSDictionary *groups = [[GPGOptions sharedOptions] valueForKey:@"group"];
    NSMutableDictionary *cleanGroups = [NSMutableDictionary dictionary];
    
    for (NSString *email in groups) {
        NSArray *keyHints = [groups objectForKey:email];
        BOOL allKeysValid = YES;
        NSMutableSet *keys = [NSMutableSet set];
        for (NSString *keyHint in keyHints) {
            GPGKey *key = [self findKeyByHint:keyHint onlySecret:NO];
            if (!key) {
                allKeysValid = NO;
                break;
            }
            [keys addObject:key];
        }
        if (allKeysValid)
            [cleanGroups setObject:keys forKey:[email gpgNormalizedEmail]];
    }
    
    return cleanGroups;
}

- (NSDictionary *)publicKeysByEmail {
    /**
     Checks for public keys which share the same email address and returns
     a dictionary only including the most trusted and newest key with the email address.
    */
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    
    // 1.) Create a dictionary with all user ids mapped by email address.
    NSMutableDictionary *userIDEmailMap = [[NSMutableDictionary alloc] init];
    for (GPGKey *key in self.publicGPGKeys) {
        for (GPGUserID *userID in key.userIDs) {
            NSString *email = [[userID email] gpgNormalizedEmail];
            if(!email)
                continue;
            
            if(![userIDEmailMap objectForKey:email]) {
                NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:1];
                [userIDEmailMap setObject:set forKey:email];
                [set release];
            }
            [[userIDEmailMap objectForKey:email] addObject:userID];
        }
    }
    
    // 2.) Loop through the whole map, skip any entry which doesn't have multiple entries.
    for (NSString *email in userIDEmailMap) {
        if([[userIDEmailMap objectForKey:email] count] == 1) {
            GPGKey *key = [[[userIDEmailMap objectForKey:email] anyObject] primaryKey];
            [mapping setObject:key forKey:email];
            continue;
        }
        GPGKey *key = [self bestKeyOfUserIDs:[userIDEmailMap objectForKey:email]];
        [mapping setObject:key forKey:email];
    }
    
    [userIDEmailMap release];
    
    return mapping;
}

- (NSDictionary *)secretKeysByEmail {
    NSMutableDictionary *keyEmailMap = [NSMutableDictionary dictionary];
    for (GPGKey *key in self.secretGPGKeys) {
        for (GPGUserID *userID in [key userIDs]) {
            NSString *email = [userID.email gpgNormalizedEmail];
            if(!email)
                continue;
            
            if(![keyEmailMap objectForKey:email])
                [keyEmailMap setObject:key forKey:email];
        }
    }
    return keyEmailMap;
}

- (NSDictionary *)publicKeyMapping {
    if (!publicKeyMapping) {
        NSMutableDictionary *keyMapping = [[NSMutableDictionary alloc] init];
        
        [keyMapping addEntriesFromDictionary:self.publicKeysByEmail];
        [keyMapping addEntriesFromDictionary:self.groups];
        [keyMapping addEntriesFromDictionary:[self userMappedKeysSecretOnly:NO]];
        
        self.publicKeyMapping = keyMapping;
        [keyMapping release];
    }
    return publicKeyMapping;
}

- (NSDictionary *)secretKeyMapping {
    if (!secretKeyMapping) {
        NSMutableDictionary *keyMapping = [[NSMutableDictionary alloc] init];
        
        [keyMapping addEntriesFromDictionary:self.secretKeysByEmail];
        [keyMapping addEntriesFromDictionary:[self userMappedKeysSecretOnly:YES]];
        
        self.secretKeyMapping = keyMapping;
        [keyMapping release];
    }
    return secretKeyMapping;
}

- (NSMutableSet *)keysForAddresses:(NSArray *)addresses onlySecret:(BOOL)onlySecret stopOnFound:(BOOL)stop {
    Class regexClass = [RKRegex class];
    NSDictionary *map = onlySecret ? self.secretKeyMapping : self.publicKeyMapping;
    NSString *allAdresses = [addresses componentsJoinedByString:@"\n"];
    NSMutableSet *keys = [NSMutableSet set];
    
    for (id identifier in map) {
        if ([identifier isKindOfClass:regexClass]) {
            if ([allAdresses isMatchedByRegex:identifier]) {
                [keys addObject:[map objectForKey:identifier]];
                if (stop) {
                    break;
                }
            }
        } else {
            if ([addresses containsObject:identifier]) {
                [keys addObject:[map objectForKey:identifier]];
                if (stop) {
                    break;
                }
            }
        }
    }
    return keys;
}

- (NSMutableSet *)signingKeyListForAddress:(NSString *)sender {
    return [self keysForAddresses:@[[sender gpgNormalizedEmail]] onlySecret:YES stopOnFound:NO];
}

- (NSMutableSet *)publicKeyListForAddresses:(NSArray *)recipients {
    NSMutableSet *addresses = [[NSMutableSet alloc] init];
    for (NSString *address in recipients) {
        [addresses addObject:[address gpgNormalizedEmail]];
    }
    recipients = [addresses allObjects];
    [addresses release];
    
    return [self keysForAddresses:recipients onlySecret:NO stopOnFound:NO];
}


- (BOOL)canSignMessagesFromAddress:(NSString *)address {
    return [self keysForAddresses:@[[address gpgNormalizedEmail]] onlySecret:YES stopOnFound:YES].count > 0;
}

- (BOOL)canEncryptMessagesToAddress:(NSString *)address {
    return [self keysForAddresses:@[[address gpgNormalizedEmail]] onlySecret:NO stopOnFound:YES].count > 0;
}


#pragma mark GPGKey helper methods

- (GPGKey *)findKeyByHint:(NSString *)hint onlySecret:(BOOL)onlySecret {
    GPGKey *foundKey = nil;
    if(!hint)
        return nil;
    
    NSSet *keys = onlySecret ? self.secretGPGKeys : self.publicGPGKeys;
    for (GPGKey *key in keys) {
        if([key.textForFilter rangeOfString:hint].location != NSNotFound) {
            foundKey = key;
            break;
        }
    }
    return foundKey;
}

- (GPGKey *)bestKeyOfUserIDs:(NSSet *)userIDs {
    // First check if any trusted keys are in there, if so, sort them by date.
    NSMutableArray *secretUserIDs = [[NSMutableArray alloc] init];
    NSMutableArray *trustedUserIDs = [[NSMutableArray alloc] init];
    NSMutableArray *untrustedUserIDs = [[NSMutableArray alloc] init];
    for(GPGUserID *userID in userIDs) {
        if (userID.primaryKey.secret) {
            [secretUserIDs addObject:userID];
        } else if(userID.validity >= 3) {
            [trustedUserIDs addObject:userID];
        } else {
            [untrustedUserIDs addObject:userID];
        }
    }
    
    NSSortDescriptor *dateSorter = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSDate *)obj1 compare:obj2];
    }];
    
    NSArray *sortedUserIDs = nil;
    if (secretUserIDs.count) {
        sortedUserIDs = secretUserIDs;
    } else if (trustedUserIDs.count) {
        sortedUserIDs = trustedUserIDs;
    } else {
        sortedUserIDs = untrustedUserIDs;
    }
    
    sortedUserIDs = [sortedUserIDs sortedArrayUsingDescriptors:[NSArray arrayWithObjects:dateSorter, nil]];
    
    [dateSorter release];
    [secretUserIDs release];
    [trustedUserIDs release];
    [untrustedUserIDs release];
    
    return ((GPGUserID *)[sortedUserIDs objectAtIndex:0]).primaryKey;
}


#pragma mark General Info

- (NSString *)version {
	return [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

/**
 Returns the version of the bundle as string.
 */
+ (NSString *)bundleVersion {
    return [[[NSBundle bundleForClass:self] infoDictionary] valueForKey:@"CFBundleVersion"];
}

+ (NSNumber *)bundleBuildNumber {
    return [[[NSBundle bundleForClass:self] infoDictionary] valueForKey:@"BuildNumber"];
}

+ (NSString *)agentHeader {
    return [NSString stringWithFormat:GPGMailAgent, [self bundleVersion]];
}

+ (BOOL)isMountainLion {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
    return [Message instancesRespondToSelector:@selector(dataSource)];
#pragma clang diagnostic pop
}

@end
