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
    
    NSSet *secretGPGKeys;
    NSSet *publicGPGKeys;
    NSMutableSet *allGPGKeys;
	BOOL needGPGKeysUpdate;
    
    // A serial queue which makes sure that only one pinentry
    // password request is run at once.
    dispatch_queue_t decryptionQueue;
    dispatch_queue_t verificationQueue;
    dispatch_queue_t collectingQueue;
    dispatch_queue_t keysUpdateQueue;
    
    BOOL accountExistsForSigning;
    BOOL _warnedAboutMissingPrivateKeys;
    
	// Map which uses the key id to lookup a private key.
	NSDictionary *secretGPGKeysByID;
    // Map which uses the email address to lookup a public key.
    NSDictionary *publicGPGKeysByID;
	
	NSDictionary *publicKeyMapping;
	NSDictionary *secretKeyMapping;
	    
    GPGErrorCode gpgStatus;
    
	GPGController *gpgc;
	NSLock *updateLock;
    
	SUUpdater *updater;
    
    NSMutableArray *_bundleImages;
	
	/*
	 Holds an array of message ID's which already have had their
	 rules applied, so we don't create too much overhead.
	 */
	NSMutableArray *_messagesRulesWereAppliedTo;
	dispatch_queue_t _rulesQueue;
	
	dispatch_source_t _checkGPGTimer;
}

/**
 Checks for multiple installations of GPGMail.mailbundle in
 all Library folders.
 */
+ (NSArray *)multipleInstallations;

/**
 Warn the user that multiple installations were found and 
 bail out.
 */
+ (void)showMultipleInstallationsErrorAndExit:(NSArray *)installations;

// Install all methods used by GPGMail.
- (void)_installGPGMail;
// Load all necessary images.
- (void)_loadImages;
// Install the Sparkle Updater.
- (void)_installSparkleUpdater;
// Returns the bundle version.
+ (NSString *)bundleVersion;
// Returns the string used for the x-pgp-agent message header.
+ (NSString *)agentHeader;

@property BOOL usesOpenPGPToSend; // use OpenPGP to send messages
@property BOOL usesOpenPGPToReceive; // use OpenPGP to receive messages


@property (readonly) GPGErrorCode gpgStatus;
@property (readonly, retain) NSSet *allGPGKeys;
@property (readonly, nonatomic, retain) NSSet *secretGPGKeys;
@property (readonly, nonatomic, retain) NSSet *publicGPGKeys;
@property (readonly, nonatomic, retain) NSDictionary *publicGPGKeysByID;
@property (readonly, nonatomic, retain) NSDictionary *secretGPGKeysByID;

@property (nonatomic, retain) NSArray *messagesRulesWereAppliedTo;

@property (nonatomic, readonly, retain) SUUpdater *updater;

@property (nonatomic, assign) BOOL accountExistsForSigning;

@property (nonatomic, retain) NSMutableArray *bundleImages;

- (NSString *)version;
+ (BOOL)gpgMailWorks;
- (BOOL)gpgMailWorks;
- (BOOL)checkGPG;

- (NSMutableSet *)publicKeyListForAddresses:(NSArray *)recipients;
- (NSMutableSet *)signingKeyListForAddress:(NSString *)sender;
- (BOOL)canEncryptMessagesToAddress:(NSString *)address;
- (BOOL)canSignMessagesFromAddress:(NSString *)address;


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
 Checks a list of keys and returns the newest and most trusted key.
 */
- (GPGKey *)bestKeyOfUserIDs:(NSSet *)userIDs;


/**
 Finds a key by matching one of its properties. (internally uses textForFilter which contains information for the
 key and all subkeys)
 */
- (GPGKey *)findKeyByHint:(NSString *)hint onlySecret:(BOOL)onlySecret;


/**
 Return if we're running on Mountain Lion or not.
 */
+ (BOOL)isMountainLion;

/**
 Message rules should only be applied once per session.
 For this matter, all messages which have had their rules applied
 are attached to an array.
 */
- (void)addMessageRulesWereAppliedTo:(id)message;

/**
 Check if a message has already had their rules applied.
 */
- (BOOL)wereRulesAppliedToMessage:(id)message;

@end

@interface GPGMailBundle (NoImplementation)
// Prevent "incomplete implementation" warning.
+ (id)sharedInstance;
@end
