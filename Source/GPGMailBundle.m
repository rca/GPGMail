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
    
    // Load the executable data for later verification with the gpg-signature.
    NSString *path = [[GPGMailBundle bundle] executablePath];
    NSData *executableData = [NSData dataWithContentsOfFile:path];
    char *executableBytes = (char *)[executableData bytes];
    
    if([[[NSProcessInfo processInfo] arguments] containsObject:@"-DebugLog"])
        GPGMailLoggingLevel = 1;
    
    NSString *lan = @"AB20981DE345FGHIJMNOPQLSRTUVWZYX67C-.";
    
    static dispatch_once_t onceToken;

    // Function which presents the expired error message and unloads GPGMail.
    void(^e)() = ^{
        
        void(^_e)() = ^{
            NSString *message = @"You can no longer use this version of GPGMail. Please visit https://gpgtools.org to download the newest version.";
            NSRunAlertPanel(@"Your GPGMail beta has expired", @"%@", nil, nil, nil, message);
        };
        
        dispatch_once(&onceToken, ^{
            __autoreleasing NSError *error = nil;
            DebugLog(@"Swizzling out important classes.");
            [GPGMailBundle jrlp_swizzleMethod:@selector(gpgMailWorks) newMethodName:(SEL)NSSelectorFromString(@"GMGpgMailWorks") withBlock:^BOOL {
                return NO;
            } error:&error];
            Class messageClass = [GPGMailBundle isMavericks] || [GPGMailBundle isYosemite] ? NSClassFromString(@"MCMessage") : NSClassFromString(@"Message");
            [messageClass jrlp_swizzleMethod:@selector(collectPGPInformationStartingWithMimePart:decryptedBody:) newMethodName:(SEL)NSSelectorFromString(@"GMCollectPGPInformationStartingWithMimePart:decryptedBody:") withBlock:^{} error:&error];
            [messageClass jrlp_swizzleMethod:@selector(shouldCreateSnippetWithData:) newMethodName:NSSelectorFromString(@"GMShouldCreateSnippetWithData:") withBlock:^BOOL(NSData *data) {
                return NO;
            } error:&error];
            Class mimePartClass = [GPGMailBundle isMavericks] || [GPGMailBundle isYosemite] ? NSClassFromString(@"MCMimePart") : NSClassFromString(@"MimePart");
            [mimePartClass jrlp_swizzleMethod:@selector(isPGPMimeEncrypted) newMethodName:(SEL)NSSelectorFromString(@"GMisPGPMimeEncrypted") withBlock:^BOOL {
                return NO;
            } error:&error];
            [mimePartClass jrlp_swizzleMethod:@selector(verifyData:signatureData:) newMethodName:(SEL)NSSelectorFromString(@"GMVerifyData:signatureData:") withBlock:^{} error:&error];
        
            if(![NSThread isMainThread])
                dispatch_async(dispatch_get_main_queue(), ^{
                    _e();
                });
            else
                _e();
        });
        
        return;
    };
    
    // Verifies the executable data returns an error if verification failed.
    NSDictionary *(^v)(NSData *d) = ^NSDictionary *(NSData *d){
        NSString *ic = @"";
        NSMutableDictionary *icd = [@{} mutableCopy];
        for(unsigned int n = 0; n < [lan length]; n++) {
            if(n == 18) // N
                icd[[[NSString stringWithFormat:@"%c", [lan characterAtIndex:18]] lowercaseString]] = @[@3, @13];
            else if(n == 13) // G
                icd[[[NSString stringWithFormat:@"%c", [lan characterAtIndex:13]] lowercaseString]] = @[@2, @15];
            else if(n == 8) // E
                icd[[[NSString stringWithFormat:@"%c", [lan characterAtIndex:8]] lowercaseString]] = @[@8];
            else if(n == 12) // F
                icd[[[NSString stringWithFormat:@"%c", [lan characterAtIndex:12]] lowercaseString]] = @[@17];
            else if(n == 23) // S
                icd[[[NSString stringWithFormat:@"%c", [lan characterAtIndex:23]] lowercaseString]] = @[@0];
            else if(n == 0) // A
                icd[[[NSString stringWithFormat:@"%c", [lan characterAtIndex:0]] lowercaseString]] = @[@4];
            else if(n == 36) // .
                icd[[[NSString stringWithFormat:@"%c", [lan characterAtIndex:36]] lowercaseString]] = @[@14];
            else if(n == 25) // T
                icd[[[NSString stringWithFormat:@"%c", [lan characterAtIndex:25]] lowercaseString]] = @[@5];
            else if(n == 26) // U
                icd[[[NSString stringWithFormat:@"%c", [lan characterAtIndex:26]] lowercaseString]] = @[@6];
            else if(n == 34) // C
                icd[[[NSString stringWithFormat:@"%c", [lan characterAtIndex:34]] lowercaseString]] = @[@11];
            else if(n == 15) // I
                icd[[[NSString stringWithFormat:@"%c", [lan characterAtIndex:15]] lowercaseString]] = @[@1, @10, @16];
            else if(n == 24) // R
                icd[[[NSString stringWithFormat:@"%c", [lan characterAtIndex:24]] lowercaseString]] = @[@7];
            else if(n == 35) // -
                icd[[[NSString stringWithFormat:@"%c", [lan characterAtIndex:35]] lowercaseString]] = @[@9];
            else if(n == 19) // O
                icd[[[NSString stringWithFormat:@"%c", [lan characterAtIndex:19]] lowercaseString]] = @[@12];
        }
        NSMutableArray *icp = [NSMutableArray array];
        for(unsigned int m = 0; m < 18 ; m++) {
            [icp addObject:@0];
        }
        for(NSString *key in icd) {
            for(NSNumber *p in icd[key]) {
                icp[[p integerValue]] = key;
            }
        }
        
        ic = [icp componentsJoinedByString:@""];
        
        NSArray *s = nil;
        NSString *vf = [[GPGMailBundle bundle] pathForResource:ic ofType:@""];
        GPGController *gpgc = [[GPGController alloc] init];
        @try {
            s = [gpgc verifySignature:[NSData dataWithContentsOfFile:vf]
                         originalData:d];
        }
        @catch (NSException *exception) {
            DebugLog(@"Exception: %@", exception);
            
            e();
        }
        NSMutableDictionary *r = [@{@"sA": s, @"sD": gpgc.statusDict} mutableCopy];
        if(gpgc.error)
            r[@"e"] = gpgc.error;
        return r;
    };
    
    // Signature verification completed. Now on to check the expiration date.
    // Find the expiration date in the binary segment.
    uint32_t imageCount = _dyld_image_count();
    NSMutableString *ed = [@"" mutableCopy];
    signed int imIdx = -1;
    for(unsigned int z = 0; z < imageCount; z++) {
        const char *imn = _dyld_get_image_name(z);
        NSString *imno = [NSString stringWithUTF8String:imn];
        if([imno rangeOfString:@"GPGMail.mailbundle/Contents/MacOS/GPGMail"].location != NSNotFound) {
            imIdx = z;
            break;
        }
    }
    
    NSData *verifiableData = [NSData data];
    NSMutableData *tmpData = [NSMutableData data];
    
    if(imIdx > -1) {
        // Load the mach header which will be used to read out the interesting segments
        // and sections.
        const struct mach_header *header = _dyld_get_image_header(imIdx);
        // Find the address where the image data starts.
        intptr_t offset = _dyld_get_image_vmaddr_slide(imIdx);
        
        // Read out the expiration date as unix timestamp.
        uint64_t gmLength = 0;
        char *edData = getsectdatafromheader_64(header, "__TEXT", "__gmed_xx", &gmLength);
        if(edData != NULL) {
            for(unsigned long p = 0; p < gmLength; p++) {
                char num = (char)*(offset + edData + p);
                if(isdigit(num) && [ed length] < 10)
                    [ed appendFormat:@"%c", (char)*(offset + edData + p)];
            }
        }
        
        // Read out the not code-signed part of the binary.
        uint64_t length = 0;
        
        char *signedData = getsectdatafromheader_64(header, "__TEXT", "__text", &length);
        char *actualData = (char *)(((intptr_t)executableBytes) + signedData);
        // Add the expiration time to the actual executable data,
        // since when creating the signature, we've added the expiration time as well.
        [tmpData appendBytes:actualData length:length];
        [tmpData appendBytes:(offset + edData) length:gmLength];
        
        verifiableData = tmpData;
        DebugLog(@"Data length: %ld", [verifiableData length]);
    }
    
    NSDictionary *sA = v(verifiableData);
    
    DebugLog(@"Signatures: %@", sA);
    
    // Create the key used to verify the signature.
    NSMutableDictionary *kd = [@{} mutableCopy];
    for(unsigned int j = 0; j < [lan length]; j++) {
        if(j == 8) // E
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:8]]] = @[@2, @16];
        else if(j == 12) // F
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:12]]] = @[@5, @19, @29];
        else if(j == 3) // 0
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:3]]] = @[@8, @21, @30, @32, @33, @35];
        else if(j == 5) // 8
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:5]]] = @[@0, @4, @28];
        else if(j == 11) // 5
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:11]]] = @[@1, @31];
        else if(j == 32) // 6
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:32]]] = @[@6, @10, @25, @37];
        else if(j == 10) // 4
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:10]]] = @[@9, @12, @13, @39];
        else if(j == 34) // C
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:34]]] = @[@14, @17, @38];
        else if(j == 1) // B
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:1]]] = @[@11, @20, @23];
        else if(j == 7) // D
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:7]]] = @[@26, @34];
        else if(j == 6) // 1
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:6]]] = @[@15];
        else if(j == 4) // 9
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:4]]] = @[@7, @18];
        else if(j == 33) // 7
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:33]]] = @[@22, @24, @27];
        else if(j == 2) // 2
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:2]]] = @[@36];
        else if(j == 9) // 3
            kd[[NSString stringWithFormat:@"%c", [lan characterAtIndex:9]]] = @[@3];
    }
    NSString *k = @"";
    NSMutableArray *kp = [NSMutableArray array];
    for(unsigned int m = 0; m < 40; m++) {
        [kp addObject:@0];
    }
    for(NSString *key in kd) {
        for(NSNumber *p in kd[key]) {
            kp[[p integerValue]] = key;
        }
    }
    
    k = [kp componentsJoinedByString:@""];
    
    // Check the result of the verification.
    void(^c)(NSDictionary *) = ^(NSDictionary *sR) {
        NSArray *sAc = sR[@"sA"];
        NSDictionary *stD = sR[@"sD"];
        
        if([sR[@"e"] isKindOfClass:[GPGException class]]) {
            int cc = 100;
            for(cc = 0; cc < 200; cc++) {
                if(cc == GPGErrorNotFound && ((GPGException *)sR[@"e"]).errorCode == cc)
                    break;
                if(cc == GPGErrorGeneralError && ((GPGException *)sR[@"e"]).errorCode == cc)
                    break;
                if(cc == GPGErrorCancelled &&  ((GPGException *)sR[@"e"]).errorCode == cc)
                    break;
                if(cc == GPGErrorConfigurationError &&  ((GPGException *)sR[@"e"]).errorCode == cc)
                    break;
                if(cc == GPGErrorEOF &&  ((GPGException *)sR[@"e"]).errorCode == cc)
                    break;
            }
            if(cc == GPGErrorGeneralError) {
                DebugLog(@"Some unknown GPG error found when checking signature.");
            }
            if(cc == GPGErrorNotFound) {
                DebugLog(@"GnuPG doesn't seem to be installed on this system.");
            }
            if(cc == GPGErrorConfigurationError) {
                DebugLog(@"Configuration error detected.");
            }
            if(cc == GPGErrorEOF) {
                DebugLog(@"End of file detected.");
            }
            if(cc != GPGErrorNotFound && cc != GPGErrorGeneralError && cc != GPGErrorConfigurationError && cc != GPGErrorCancelled && cc != GPGErrorEOF)
                @throw [NSException exceptionWithName:@"GMCorrupedDataException" reason:@"Your installation of GPGMail seems to be broken. Please re-install." userInfo:nil];
            
            DebugLog(@"Is GPGException! %@", sR[@"e"]);
            return;
        }
        else if([sR[@"e"] isKindOfClass:[NSException class]]) {
            DebugLog(@"Is NSException: %@", sR[@"e"]);
            return;
        }
        
        if([sAc count] != 1) {
            DebugLog(@"Not found exactly one signature! %ld", [sAc count]);
            @throw [NSException exceptionWithName:@"GMCorrupedDataException" reason:@"Your installation of GPGMail seems to be broken. Please re-install." userInfo:nil];
            return;
        }
        else {
            DebugLog(@"[GOOD] we only have one signature");
        }
        GPGSignature *sAcK = [sAc objectAtIndex:0];
        if(![sAcK.primaryKey.fingerprint isEqualToString:k]) {
            DebugLog(@"KeyID doesn't match key: %@ - %@", sAcK.primaryKey.fingerprint, k);
            @throw [NSException exceptionWithName:@"GMCorrupedDataException" reason:@"Your installation of GPGMail seems to be broken. Please re-install." userInfo:nil];
            return;
        }
        else {
            DebugLog(@"[GOOD] KeyID matches one our key ID");
        }
        NSArray *isn = stD[@"VALIDSIG"];
        if(!isn || [isn count] != 1) {
            DebugLog(@"Valid sig entry missing or not only one present.");
            @throw [NSException exceptionWithName:@"GMCorrupedDataException" reason:@"Your installation of GPGMail seems to be broken. Please re-install." userInfo:nil];
            return;
        }
        else {
            DebugLog(@"[GOOD] Valid sig entry is available.");
        }
        if(![isn[0][[isn[0] count] - 1] isEqualToString:k] ||
           ![sAcK.primaryKey.fingerprint isEqualToString:isn[0][[isn[0] count] - 1]]) {
            DebugLog(@"Sig key not matching required key.");
            @throw [NSException exceptionWithName:@"GMCorrupedDataException" reason:@"Your installation of GPGMail seems to be broken. Please re-install." userInfo:nil];
            return;
        }
        else {
            DebugLog(@"[GOOD] Sig key matching required key.");
        }
    };
    
    @try {
        c(sA);
    }
    @catch (NSException *exception) {
        DebugLog(@"Exception: %@", exception);
        
        e();
        return;
    }
    
    //NSData *d2 = [d subdataWithRange:NSMakeRange([d length] - 10, 10)];
    NSUInteger f = [ed integerValue]; //[[[NSString alloc] initWithData:d2 encoding:NSUTF8StringEncoding] integerValue];
    
    if(f < 1414769547) {
        DebugLog(@"Expiration date too early!");
        e();
        return;
    }
    else {
        DebugLog(@"[GOOD] Expiration date alright");
    }
    
    NSDate *cd = [NSDate dateWithTimeIntervalSince1970:f];
    NSDate *od = [NSDate date];
    
    // Check if  the beta has actually expired.
    if([cd compare:od] == NSOrderedAscending) {
        DebugLog(@"Beta has expired!");
        e();
        return;
    }
    else {
        DebugLog(@"[GOOD] Beta has not yet expired. Expires on: %@", cd);
    }
    
    NSUInteger intv = 10;
    // Setup a loop which will check every intv minutes if the beta has expired
    // and if it has, disables GPGMail.
    dispatch_source_t vT = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(vT, dispatch_time(DISPATCH_TIME_NOW, (60 * intv * NSEC_PER_SEC)), 60 * intv * NSEC_PER_SEC, 60 * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(vT, ^{
        NSDate *odd = [NSDate date];
        if([cd compare:odd] == NSOrderedAscending) {
            DebugLog(@"Beta expired!");
            e();
            dispatch_suspend(vT);
            return;
        }
        else {
            DebugLog(@"[GOOD] Beta has not yet expired.");
        }
    });
    dispatch_resume(vT);
    
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


@end
