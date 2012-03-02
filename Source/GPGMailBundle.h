/* GPGMailBundle.h created by dave on Thu 29-Jun-2000 */

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

#import <MVMailBundle.h>

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSMapTable.h>
#import <AppKit/NSNibDeclarations.h>
#import <Libmacgpg/Libmacgpg.h>

@class MessageHeaders;
@class NSMenu;
@class NSMutableDictionary;
@class Message;
@class SUUpdater;

typedef void (^gpgmail_decryption_task_t)(void);
typedef void (^gpgmail_verification_task_t)(void);

extern NSString *GPGMailKeyringUpdatedNotification;
extern NSString *gpgErrorIdentifier; // This identifier is used to set and find GPGErrorCodes in NSData.


@interface GPGMailBundle : NSObject <NSToolbarDelegate, GPGControllerDelegate> {
	NSArray *cachedPersonalKeys;
	NSArray *cachedPublicKeys;
	//NSDictionary *locale;
    
    NSSet *secretGPGKeys;
    NSSet *publicGPGKeys;
    NSMutableSet *allGPGKeys;
    
    // A serial queue which makes sure that only one pinentry
    // password request is run at once.
    dispatch_queue_t decryptionQueue;
    dispatch_queue_t verificationQueue;
    dispatch_queue_t collectingQueue;
    dispatch_queue_t keysUpdateQueue;
    
    BOOL accountExistsForSigning;
    
    // Map which uses the email address to lookup a personal key.
    NSDictionary *_secretGPGKeysByEmail;
    // Map which uses the email address to lookup a public key.
    NSDictionary *_publicGPGKeysByEmail;
    // Map which uses the key id to lookup a public key.
    NSDictionary *_publicGPGKeysByID;
    // Contains all groups which were disabled because they contained keys
    // which can not be used for encryption.
    NSArray *_disabledGroups;
    // Contains all user mapped keys which can't be used for encryption.
    NSArray *_disabledUserMappedKeys;
    
    GPGErrorCode gpgStatus;
    
	GPGController *gpgc;
	NSLock *updateLock;
    
	SUUpdater *updater;
}

// Install all methods used by GPGMail.
+ (void)_installGPGMail;
// Load all necessary images.
+ (void)_loadImages;
// Install the Sparkle Updater.
+ (void)_installSparkleUpdater;
// Returns the bundle version.
+ (NSString *)bundleVersion;
// Returns the string used for the x-pgp-agent message header.
+ (NSString *)agentHeader;

@property BOOL usesOpenPGPToSend; // use OpenPGP to send messages
@property BOOL usesOpenPGPToReceive; // use OpenPGP to receive messages


@property BOOL warnedAboutMissingPrivateKeys;

- (NSString *)buildNumberDescription;

@property (nonatomic, retain) NSArray *disabledGroups;
@property (nonatomic, retain) NSArray *disabledUserMappedKeys;
@property (readonly) GPGErrorCode gpgStatus;
@property (nonatomic, retain) NSSet *secretGPGKeys;
@property (nonatomic, retain) NSDictionary *secretGPGKeysByEmail;
@property (nonatomic, retain) NSSet *publicGPGKeys;
@property (nonatomic, retain) NSDictionary *publicGPGKeysByEmail;
@property (nonatomic, retain) NSDictionary *publicGPGKeysByID;
@property (readonly, retain) NSSet *allGPGKeys;
@property (readonly) GPGController *gpgc;

@property (nonatomic, readonly, retain) SUUpdater *updater;

@property (nonatomic, assign) BOOL accountExistsForSigning;

- (NSString *)version;
- (NSString *)versionDescription;
+ (BOOL)gpgMailWorks;
- (BOOL)gpgMailWorks;
- (BOOL)checkGPG;

- (BOOL)canKeyBeUsedForEncryption:(GPGKey *)key;
- (BOOL)canKeyBeUsedForSigning:(GPGKey *)key;
- (id)locale;

- (NSMutableSet *)publicKeyListForAddresses:(NSArray *)recipients;
- (BOOL)canEncryptMessagesToAddress:(NSString *)address;
- (BOOL)canSignMessagesFromAddress:(NSString *)address;
- (NSSet *)signingKeyListForAddress:(NSString *)sender;
- (GPGKey *)bestKeyOfUserIDs:(NSSet *)userIDs;


// Allows to schedule decryption tasks which will block as
// long as a second decryption task is running, but shouldn't
// block the main thread.
- (void)addDecryptionTask:(gpgmail_decryption_task_t)task;

/**
 Allows to schedule verification tasks which will block as
 long as second verification task is running.
 */
- (void)addVerificationTask:(gpgmail_verification_task_t)task;

/**
 Allows to schedule info collection tasks which will block
 as long as a second collection task is running, but shouldn't
 block the main thread.
 */
- (void)addCollectionTask:(gpgmail_verification_task_t)task;

/**
 Checks for public keys which share the same email address and returns
 a list only including the most trusted and newest key with the email address.
 */
- (NSSet *)sanitizedPublicGPGKeys:(NSSet *)publicKeys;

/**
 Checks a list of keys and returns the newest and most trusted key.
 */
- (GPGKey *)bestKeyOfUserIDs:(NSSet *)userIDs;

/**
 Returns all keys which were mapped by the user (email -> fingerprint).
 First removes all keys which can't be used for encryption and adds them to disabledUserMappedKeys.
 */
- (NSDictionary *)userMappedKeys;

/**
 Returns all groups defined in gpg.conf.
 First removes any groups where not all keys can't be used for encryption and adds them to disabledGroups.
*/
- (NSDictionary *)groups;

/**
 Finds a key by matching one of its properties. (internally uses textForFilter which contains information for the
 key and all subkeys)
 */
- (GPGKey *)findPublicKeyByKeyHint:(NSString *)hint;
- (GPGKey *)findSecretKeyByKeyHint:(NSString *)hint;


/**
 Create a map for the gpg keys which can be accessed by using
 an email address.
 All email addresses of user ids are taking into consideration.
 If duplicate emails are found, allow duplicates decides whether to discard them
 or keep them.
 */
- (NSMutableDictionary *)emailMapForGPGKeys:(NSSet *)keys allowDuplicates:(BOOL)allowDuplicates;

@end

@interface GPGMailBundle (NoImplementation)
// Prevent "incomplete implementation" warning.
+ (id)sharedInstance;
@end
