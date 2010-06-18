/* GPGPassphraseController.m created by stephane on Fri 30-Jun-2000 */

/*
 * Copyright (c) 2000-2008, Stéphane Corthésy <stephane at sente.ch>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of Stéphane Corthésy nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY STÉPHANE CORTHÉSY AND CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL STÉPHANE CORTHÉSY AND CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <Carbon/Carbon.h>
#include <Security/Security.h>
#import "GPGPassphraseController.h"
#import <MacGPGME/MacGPGME.h>
#import <GPGMailBundle.h>


#warning NOT thread-safe!!!

@interface GPGPassphraseController(Private)
+ (void) controllerNoLongerUsed:(GPGPassphraseController *)controller;
- (BOOL) isInUse;
- (void) setIsInUse:(BOOL)flag;
@end

@interface GPGPassphraseController (KeychainSupport)
- (BOOL) usesKeychain;
- (NSString *) retrievePassphraseForKey:(GPGKey *)key item:(SecKeychainItemRef *)itemPtr;
- (void) storePassphrase:(NSString *)aPhrase forKey:(GPGKey *)key;
- (void) deletePassphraseForKey:(GPGKey *)key;
@end

@implementation GPGPassphraseController
#warning Modify that class: instances should be direct context delegates
// They would be initialized with parent window (if we can use sheets),
// and eventually key (in case we still can't fetch a key during passphrase delegation)

static NSMutableSet			*_controllerPool = nil;
static NSMutableDictionary	*_cachedPassphrases = nil;
static NSTimer				*_flushTimer = nil;

+ (void) initialize
{
    [super initialize];
    if(!_controllerPool){
        _controllerPool = [[NSMutableSet allocWithZone:[self zone]] initWithCapacity:2];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:[NSApplication sharedApplication]];
    }
}

+ (id) controller
{
    NSEnumerator			*anEnum = [_controllerPool objectEnumerator];
    GPGPassphraseController	*aController;
    
    while((aController = [anEnum nextObject]) != nil){
        if(![aController isInUse]){
            [aController setIsInUse:YES];
            return aController;
        }
    }
    
	aController = [[GPGPassphraseController alloc] init];
	[_controllerPool addObject:aController];
    [aController release];
    
    return aController;
}

+ (void) applicationWillTerminate:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[notification name] object:[notification object]];
    [_controllerPool release];
    _controllerPool = nil;
    [self flushCachedPassphrases];
    [_cachedPassphrases release];
    _cachedPassphrases = nil;
    if(_flushTimer != nil){
        [_flushTimer invalidate];
        [_flushTimer release];
        _flushTimer = nil;
    }
}

- (id) init
{
    if((self = [super init]) != nil){
        isInUse = YES;
        lock = [[NSConditionLock alloc] initWithCondition:0];
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceWillSleep:) name:NSWorkspaceWillSleepNotification object:[NSWorkspace sharedWorkspace]];
    }
    
    return self;
}

- (void) dealloc
{
    [panel release];
    [lock release];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceWillSleepNotification object:[NSWorkspace sharedWorkspace]];
    
    [super dealloc];
}

- (void) workspaceWillSleep:(NSNotification *)notification
{
    [GPGPassphraseController flushCachedPassphrases];
}

+ (void) controllerNoLongerUsed:(GPGPassphraseController *)controller
{
    if([_controllerPool count] > 1)
        [_controllerPool removeObject:controller];
}

- (BOOL) isInUse
{
    return isInUse;
}

- (void) setIsInUse:(BOOL)flag
{
    isInUse = flag;
    if(!isInUse)
        [GPGPassphraseController controllerNoLongerUsed:self];
}

- (NSString *) passphraseForUser:(id)user title:(NSString *)title window:(NSWindow *)parentWindow
{
    // user is nil for symetric encryption
    NSString	*passphrase;
    GPGKey      *aKey = nil;
    BOOL		usesPGPKey = (user != nil && ![user isKindOfClass:[NSString class]]);

//#warning The following assertion is no longer true!
//    NSParameterAssert(title != nil);
    if(title == nil)
        title = @"";

    if(usesPGPKey){
        aKey = user;
        if([self usesKeychain])
            passphrase = [self retrievePassphraseForKey:aKey item:NULL];
        else
            passphrase = [_cachedPassphrases objectForKey:[aKey fingerprint]];
    }
    else
#warning Should we cache/store passphrase for symetric encryption?
        passphrase = nil; // Symetric encryption; we don't cache passphrases
    
    // WARNING: if cached passphrase is invalid, user cannot modify it without flushing cache!
    if(!passphrase){
        if(!panel){
            NSAssert([NSBundle loadNibNamed:@"GPGPassphrase" owner:self], @"### GPGMail: -[GPGPassphraseController passphraseForUser:title:window:]: Unable to load nib named GPGPassphrase");
            NSAssert(panel != nil, @"### GPGMail: -[GPGPassphraseController passphraseForUser:title:window:]: Could not connect <panel> outlet");
        }
        
        if([[GPGMailBundle sharedInstance] showsPassphrase]){
            [clearPassphraseTextField setStringValue:@""];
            [clearPassphraseTextField setNeedsDisplay:YES];
            [passphraseCheckBox setState:NSOnState];
            [passphraseCheckBox setNeedsDisplay:YES];
            [passphraseTabView selectTabViewItemAtIndex:1];
        }
        else{
            [passphraseTextField setStringValue:@""];
            [passphraseTextField setNeedsDisplay:YES];
            [passphraseCheckBox setState:NSOffState];
            [passphraseCheckBox setNeedsDisplay:YES];
            [passphraseTabView selectTabViewItemAtIndex:0];
        }

        if(!usesPGPKey)
            [messageTextField setStringValue:NSLocalizedStringFromTableInBundle(@"Enter passphrase for this message:", @"GPG", [NSBundle bundleForClass:[self class]], "Passphrase entry message (no key)")];
        else
            [messageTextField setStringValue:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Enter passphrase for %@:", @"GPG", [NSBundle bundleForClass:[self class]], "Passphrase entry message"), [[GPGMailBundle sharedInstance] menuItemTitleForKey:aKey]]];
        [titleTextField setStringValue:title];

#if 0
        // It is not possible to use a sheet if we are already in the main thread!
        if(parentWindow != nil){
            int	returnCode;

            [lock lock];
//            [parentWindow orderFront:nil];
            [[NSApplication sharedApplication] beginSheet:panel modalForWindow:parentWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:&returnCode];
            [lock lockWhenCondition:1];
            if(returnCode == NSOKButton){
//        	if([[NSApplication sharedApplication] runModalForWindow:panel] == NSOKButton)
                if([passphraseCheckBox state])
                    passphrase = [[[clearPassphraseTextField stringValue] copy] autorelease];
                else
                    passphrase = [[[passphraseTextField stringValue] copy] autorelease];
                if(usesPGPKey){
                    if([self usesKeychain])
                        [self storePassphrase:passphrase forKey:aKey];
                    else
                        if(_cachedPassphrases != nil)
                            [_cachedPassphrases setObject:passphrase forKey:[aKey fingerprint]];
                }
            }
//            [parentWindow orderOut:nil];
            [lock unlock];
        }
        else{
        }
#else
        if([[NSApplication sharedApplication] runModalForWindow:panel] == NSOKButton){
            if([passphraseCheckBox state])
                passphrase = [[[clearPassphraseTextField stringValue] copy] autorelease];
            else
                passphrase = [[[passphraseTextField stringValue] copy] autorelease];
            if(usesPGPKey){
                if([self usesKeychain])
                    [self storePassphrase:passphrase forKey:aKey];
                else
                    if(_cachedPassphrases != nil)
                        [_cachedPassphrases setObject:passphrase forKey:[aKey fingerprint]];
            }
        }
#endif
        [passphraseTextField setStringValue:@""];
        [clearPassphraseTextField setStringValue:@""];
    }

    if(_flushTimer != nil){
        [_flushTimer invalidate];
        [_flushTimer release];
        _flushTimer = nil;
    }
    if([GPGPassphraseController cachesPassphrases]){
        // Problem: fire date we pass is actually a time interval,
        // computed from computer's awake time, i.e. when computer
        // sleeps, that time is not counted. E.g. if you set timeout
        // to be 5 min. and your computer sleeps before timeout,
        // during 5 hours, then total timeout will be 5 hours and
        // some minutes! Not very good for passphrase caching...
        // What we do is to check firedate every 10 seconds.
        NSDate	*flushTime = [NSDate dateWithTimeIntervalSinceNow:[[GPGMailBundle sharedInstance] passphraseFlushTimeout]];

        _flushTimer = [[NSTimer scheduledTimerWithTimeInterval:10. target:self selector:@selector(flushTimeoutHasArrived) userInfo:flushTime repeats:YES] retain];
        [[NSRunLoop currentRunLoop] addTimer:_flushTimer forMode:NSModalPanelRunLoopMode];
    }

    [self setIsInUse:NO];

    return passphrase;
}

- (IBAction) endModal:(id)sender
{
    [panel orderOut:sender];
    [[NSApplication sharedApplication] stopModalWithCode:[sender tag]];
//    [[NSApplication sharedApplication] endSheet:panel returnCode:[sender tag]];
}

- (IBAction) toggleShowPassphrase:(id)sender
{
    if([sender state]){
        [clearPassphraseTextField setStringValue:[passphraseTextField stringValue]];
        [passphraseTextField setStringValue:@""];
        [clearPassphraseTextField setNeedsDisplay:YES];
        [passphraseTabView selectTabViewItemAtIndex:1];
    }
    else{
        [passphraseTextField setStringValue:[clearPassphraseTextField stringValue]];
        [clearPassphraseTextField setStringValue:@""];
        [passphraseTextField setNeedsDisplay:YES];
        [passphraseTabView selectTabViewItemAtIndex:0];
    }
}

- (void) sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    *((int *)contextInfo) = returnCode;
    [sheet orderOut:nil];
    [lock unlockWithCondition:1];
}

+ (void) setCachesPassphrases:(BOOL)flag
{
    if(flag){
        if(!_cachedPassphrases)
            _cachedPassphrases = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:1];
    }
    else{
        [self flushCachedPassphrases];
        [_cachedPassphrases release];
        _cachedPassphrases = nil;
    }
}

+ (BOOL) cachesPassphrases
{
    return _cachedPassphrases != nil;
}

- (void) flushTimeoutHasArrived
{
    if([(NSDate *)[_flushTimer userInfo] compare:[NSDate date]] <= 0){
        [_flushTimer invalidate];
        [_flushTimer release];
        _flushTimer = nil;
        [GPGPassphraseController flushCachedPassphrases];
    }
}

+ (void) flushCachedPassphrases
{
    if(_cachedPassphrases)
        [_cachedPassphrases removeAllObjects];
}

/*!
 * Called after cached passphrase was invalid.
 */
+ (void) flushCachedPassphraseForUser:(id)user
{
    GPGKey      *aKey;
    NSString	*userID;

    NSParameterAssert(user != nil);

    if([user isKindOfClass:[GPGKey class]]){
        aKey = user;
        userID = [aKey fingerprint];
    }
    else{
        userID = user;
        aKey = nil;
    }

    if(_cachedPassphrases)
        [_cachedPassphrases removeObjectForKey:userID];
    // Don't forget to flush passphrase
    if(aKey != nil && [[GPGMailBundle sharedInstance] usesKeychain])
        [[self controller] deletePassphraseForKey:aKey];
}

@end

@implementation GPGPassphraseController (KeychainSupport)
// I should put that into MacGPGME/GPGAppKit...

// Constants for Keychain support
#define PASSPHRASE_DATA_LENGTH 1024
#define GPG_SERVICE_NAME       "GPGMail"
// Should be "PGP" or "GnuPG" instead

- (BOOL) usesKeychain
{
    return [[GPGMailBundle sharedInstance] usesKeychain];
}

- (NSString *) retrievePassphraseForKey:(GPGKey *)key item:(SecKeychainItemRef *)itemPtr
// Retrieve the passphrase from the keychain using key's fingerprint and
// the name of this application to find it.
{
    SecKeychainRef	keychain = NULL;
    NSString		*aPassphrase = nil;

    if(SecKeychainCopyDefault(&keychain) != errSecNoDefaultKeychain){
        void		*passphraseData;
        OSStatus	retVal = noErr;
        const char	*serviceName = GPG_SERVICE_NAME;
        const char	*accountName = [[key fingerprint] UTF8String];
        UInt32		passphraseDataLen = 0;

#warning Memory leak with passphraseData?
        retVal = SecKeychainFindGenericPassword(NULL, strlen(serviceName), serviceName, strlen(accountName), accountName, &passphraseDataLen, &passphraseData, itemPtr);
        switch(retVal){
            case noErr:{
                NSData	*pData;

//                pData = [NSData dataWithBytes:passphraseData length:passphraseDataLen];
                pData = [NSData dataWithBytesNoCopy:passphraseData length:passphraseDataLen freeWhenDone:YES];
                // Assume the encoding of the passphrase is done using utf8 (is going to be
                // the default for gnupg anyway)
#warning Check encoding
                aPassphrase = [[NSString alloc] initWithData:pData encoding:NSUTF8StringEncoding];
                [aPassphrase autorelease];
                break;
            }
            case errSecItemNotFound:
//                if(GPGMailLoggingLevel)
//                    NSLog(@"[DEBUG] Couldn't find password in keychain for %@@%@", userStr, aHostStr);
                break;
            case errSecNoDefaultKeychain:
                [NSException raise:NSGenericException format:NSLocalizedStringFromTableInBundle(@"Can't get default keychain!", @"GPG", [NSBundle bundleForClass:[self class]], "")];
                break;
            case errSecBufferTooSmall:
                [NSException raise:NSInvalidArgumentException format:NSLocalizedStringFromTableInBundle(@"Password buffer too small for keychain!", @"GPG", [NSBundle bundleForClass:[self class]], "")];
                break;
            default:
                // The user most probably clicked "Deny", so return nada
                break;
        }
    }
    else
        [NSException raise:NSGenericException format:NSLocalizedStringFromTableInBundle(@"Can't get default keychain!", @"GPG", [NSBundle bundleForClass:[self class]], "")];

    return aPassphrase;
}

- (void) deletePassphraseForKey:(GPGKey *)key
{
    OSStatus			retVal = 0;
    SecKeychainRef		keychain = NULL;
    NSString			*passphraseStr = nil;
    SecKeychainItemRef	keychainItem = NULL;

    // Find the password
    if(SecKeychainCopyDefault(&keychain) != errSecNoDefaultKeychain)
        passphraseStr = [self retrievePassphraseForKey:key item:&keychainItem];

    // if it is there and the same, bail
    if(passphraseStr){
        if(keychainItem != NULL){
            retVal = SecKeychainItemDelete(keychainItem);
            CFRelease(keychainItem);
        }
    }
    
    if(keychain != NULL)
        CFRelease(keychain);
}

- (void) storePassphrase:(NSString *)aPhrase forKey:(GPGKey *)key
    // Store aPhrase in the keychain for key, using a generic password key.
{
    OSStatus                    retVal = 0;
    const char                  *serviceName = GPG_SERVICE_NAME;
    NSString                    *accountName = [key fingerprint];
    const char                  *passphraseData;
    SecKeychainRef              keychain = NULL;
    NSString                    *passphraseStr = nil;
    BOOL                        canceled = NO;
    SecKeychainItemRef          keychainItem = NULL;
    SecAccessRef                accessRef;
    SecKeychainAttributeList	attrList;
    SecKeychainAttribute		*attributes;
    
    if(![aPhrase length] || !key)
        return;

    // Find the password
    if(SecKeychainCopyDefault(&keychain) != errSecNoDefaultKeychain)
        passphraseStr = [self retrievePassphraseForKey:key item:&keychainItem];

    // if it is there and the same, bail
    if(passphraseStr && ([passphraseStr isEqualToString:aPhrase])){
        if(keychainItem != NULL)
            CFRelease(keychainItem);
        if(keychain != NULL)
            CFRelease(keychain);
        return;
    }

    // if it is there, and not the same we erase the old one
    if(([passphraseStr length] > 0) && ![passphraseStr isEqualToString:aPhrase]){
        retVal = SecKeychainItemDelete(keychainItem);
        switch(retVal){
            case noErr:
//                if(GPGMailLoggingLevel)
//                    NSLog(@"[DEBUG] Password deleted in keychain for %s:%@", GPG_SERVICE_NAME, userStr);
                break;
            case errSecNoDefaultKeychain:
                if(keychainItem != NULL)
                    CFRelease(keychainItem);
                if(keychain != NULL)
                    CFRelease(keychain);
                [NSException raise:NSGenericException format:NSLocalizedStringFromTableInBundle(@"Can't get default keychain!", @"GPG", [NSBundle bundleForClass:[self class]], "")];
                break;
            case errSecInvalidItemRef:
                if(keychainItem != NULL)
                    CFRelease(keychainItem);
                if(keychain != NULL)
                    CFRelease(keychain);
                [NSException raise:NSInvalidArgumentException format:NSLocalizedStringFromTableInBundle(@"Invalid reference to the keychain item for %s:%@", @"GPG", [NSBundle bundleForClass:[self class]], "1st argument is service, 2nd argument is user name"), serviceName, accountName];
                break;
            case userCanceledErr:
                canceled = YES;
                break;
            default:
                if(keychainItem != NULL)
                    CFRelease(keychainItem);
                if(keychain != NULL)
                    CFRelease(keychain);
                [NSException raise:NSGenericException format:NSLocalizedStringFromTableInBundle(@"Unknown problem accessing keychain! Error %d", @"GPG", [NSBundle bundleForClass:[self class]], ""), retVal];
                break;
        }
    }
    // End of kluge
    if(keychainItem != NULL){
        CFRelease(keychainItem);
        keychainItem = NULL;
    }

    // if there is no new passwd, bail...
    if([aPhrase length] < 1 || canceled){
        if(keychain != NULL)
            CFRelease(keychain);
        return;
    }
    
    // Add a new passphrase
#warning Check encoding
    passphraseData = [aPhrase UTF8String]; // Use utf8 encoding for passphrase!

//    retVal = SecKeychainAddGenericPassword(keychain, strlen(serviceName), serviceName, strlen(accountName), accountName, strlen(passphraseData), passphraseData, &keychainItem);
    retVal = SecAccessCreate((CFStringRef)@"GPGMail", NULL, &accessRef);
    if(retVal != noErr){
        if(keychain != NULL)
            CFRelease(keychain);
        [NSException raise:NSGenericException format:NSLocalizedStringFromTableInBundle(@"Can't get new accessRef!", @"GPG", [NSBundle bundleForClass:[self class]], "")];
    }
    attributes = (SecKeychainAttribute *)NSZoneMalloc(NSDefaultMallocZone(), 5 * sizeof(SecKeychainAttribute));
    attrList.count = 5;
    attrList.attr = attributes;
    attributes[0].tag = kSecDescriptionItemAttr; // Represents the 'kind' field
    attributes[0].data = (void *)[@"PGP Key passphrase" UTF8String]; // Localize it?
    attributes[0].length = strlen(attributes[0].data);
    attributes[1].tag = kSecCommentItemAttr;
    {
        NSEnumerator	*anEnum = [[key userIDs] objectEnumerator];
        GPGUserID       *aUID;
        NSMutableArray	*uids = [NSMutableArray array];

        while((aUID = [anEnum nextObject]) != nil)
            [uids addObject:[aUID userID]];
        attributes[1].data = (void *)[[uids componentsJoinedByString:@"\n"] UTF8String];
    }
    attributes[1].length = strlen(attributes[1].data);
    attributes[2].tag = kSecLabelItemAttr; // Represents the 'name' field
    attributes[2].data = (void *)[[NSString stringWithFormat:@"0x%@ - %@", [key shortKeyID], [key userID]] UTF8String];
    attributes[2].length = strlen(attributes[2].data);
    attributes[3].tag = kSecAccountItemAttr;
    attributes[3].data = (void *)[[key fingerprint] UTF8String];
    attributes[3].length = strlen(attributes[3].data);
    attributes[4].tag = kSecServiceItemAttr; // Represents the 'where' field
    attributes[4].data = (void *)GPG_SERVICE_NAME;
    attributes[4].length = strlen(attributes[4].data);
//    attributes[5].tag = kSecGenericItemAttr; // What is it for?
//    attributes[5].data = (void *)[[key userID] UTF8String];
//    attributes[5].length = strlen(attributes[5].data);
    
    retVal = SecKeychainItemCreateFromContent(kSecGenericPasswordItemClass, &attrList, strlen(passphraseData), passphraseData, keychain, accessRef, &keychainItem);
    NSZoneFree(NSDefaultMallocZone(), attributes);
    switch(retVal){
        case noErr:
//            if(GPGMailLoggingLevel)
//                NSLog(@"[DEBUG] Password stored in keychain for  %s:%@", GPG_SERVICE_NAME, userStr);
            break;
        case errSecNoDefaultKeychain:
            if(keychainItem != NULL)
                CFRelease(keychainItem);
            if(keychain != NULL)
                CFRelease(keychain);
            [NSException raise:NSGenericException format:NSLocalizedStringFromTableInBundle(@"Can't get default keychain!", @"GPG", [NSBundle bundleForClass:[self class]], "")];
            break;
        case errSecDuplicateItem:
//            if(GPGMailLoggingLevel)
//                NSLog(@"[DEBUG] The password you entered is already stored in the keychain for %s:%@", GPG_SERVICE_NAME, userStr);
            // [NSException raise: NSInvalidArgumentException format: NSLocalizedString (@"The password you entered is already stored in the keychain for %s:%@", "1st argument is service, 2nd argument is user name"), GPG_SERVICE_NAME, userStr];
            break;
        case errSecDataTooLarge:
            if(keychainItem != NULL)
                CFRelease(keychainItem);
            if(keychain != NULL)
                CFRelease(keychain);
            [NSException raise:NSInvalidArgumentException format:NSLocalizedStringFromTableInBundle(@"Can't store the password for %s:%@: it is too long for the keychain!", @"GPG", [NSBundle bundleForClass:[self class]], "1st argument is service, 2nd argument is user name"), serviceName, accountName];
            break;
        case userCanceledErr:
            break;
        default:
            if(keychainItem != NULL)
                CFRelease(keychainItem);
            if(keychain != NULL)
                CFRelease(keychain);
            [NSException raise:NSGenericException format:NSLocalizedStringFromTableInBundle(@"Unknown problem accessing keychain! Error %d", @"GPG", [NSBundle bundleForClass:[self class]], ""), retVal];
            break;
    }
    if(keychain != NULL)
        CFRelease(keychain);
}

@end
