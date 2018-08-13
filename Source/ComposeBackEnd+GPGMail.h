/* ComposeBack+GPGMail.h created by dave on Sun 13-Apr-2004 */
/* ComposeBackEnd+GPGMail.h re-created by Lukas Pitschl (@lukele) on Wed 03-Aug-2011 */

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

#import <Subdata.h>
#import <MutableMessageHeaders.h>
#import <WebComposeMessageContents.h>
#import "GPGConstants.h"

typedef struct {
	unsigned int type:4;
	unsigned int composeMode:2;
	unsigned int hadChangesBeforeSave:1;
	unsigned int hasChanges:1;
	unsigned int showAllHeaders:1;
	unsigned int includeHeaders:1;
	unsigned int isUndeliverable:1;
	unsigned int isDeliveringMessage:1;
	unsigned int sendWindowsFriendlyAttachments:2;
	unsigned int contentsWasEditedByUser:1;
	unsigned int delegateRespondsToDidChange:1;
	unsigned int delegateRespondsToSenderDidChange:1;
	unsigned int delegateRespondsToDidAppendMessage:1;
	unsigned int delegateRespondsToDidSaveMessage:1;
	unsigned int delegateRespondsToDidBeginLoad:1;
	unsigned int delegateRespondsToDidEndLoad:1;
	unsigned int delegateRespondsToWillCreateMessageWithHeaders:1;
	unsigned int delegateRespondsToShouldSaveMessage:1;
	unsigned int delegateRespondsToShouldDeliverMessage:1;
	unsigned int delegateRespondsToDidCancelMessageDeliveryForMissingCertificatesForRecipients:1;
	unsigned int delegateRespondsToDidCancelMessageDeliveryForEncryptionError:1;
	unsigned int delegateRespondsToDidCancelMessageDeliveryForError:1;
	unsigned int delegateRespondsToDidCancelMessageDeliveryForAttachmentError:1;
	unsigned int signIfPossible:1;
	unsigned int encryptIfPossible:1;
	unsigned int knowsCanSign:1;
	unsigned int canSign:1;
	unsigned int shouldDownloadRemoteAttachments:1;
	unsigned int overrideRemoteAttachmentsPreference:1;
	unsigned int editorHasInitialized:1;
	unsigned int isEditing:1;
	unsigned int isSendFormatInitialized:1;
	unsigned int isAppleScriptMessage:1;
	unsigned long long encodingHint;
} mailFlags;

@interface ComposeBackEnd_GPGMail : NSObject

- (BOOL)setupSecurityPropertiesQueue;

/**
 Is called by Mail.app when the user clicks on the encrypt button in the
 compose window.
 
 When a message should be saved as draft, the encrypted and signed flags are
 not send along as arguments to the _makeContents method and there's no way
 to access the information since it is internally stored in a struct, which 
 unfortunately can't be easily accessed on runtime.
 
 This entry point allows GPGMail to save the encrypted status in a dynamic ivar,
 which can later be accessed when the message is saved as draft.
 */
- (void)MASetEncryptIfPossible:(BOOL)encryptIfPossible;

/**
 Is called by Mail.app when the user clicks on the sign button in the
 compose window.
 
 See -[self MASetEncryptIfPossible:] for further information why this is an important
 entry point.
 */
- (void)MASetSignIfPossible:(BOOL)signIfPossible;

/**
 This method is called by Mail.app when a new message is to be sent or a draft
 is to be saved.
 Based on the message contents it creates all necessary mime parts, signs 
 and/or encrypts the message and creates the outgoing message which is then returned.
 
 If the message is neither to be encrypted or signed, the original method is called
 and the resulting outgoing message returned.
 Otherwise Mail's original method is used too, since internally it calls the methods
 for signing and encrypting the message (see MimePart.newEncryptedPartWithData:data recipients:encryptedData: and MimePart.newSignedPartWithData:sender:signatureData:).
 Unfortunately S/MIME uses different mime parts, so the encrypted data is retrieved
 from the created outgoing message and a new message with the PGP MIME/inline 
 mime parts is created and the encrypted data added.
 
 The same happens for only PGP signed messages.
 */
- (id)MA_makeMessageWithContents:(WebComposeMessageContents *)contents isDraft:(BOOL)isDraft shouldSign:(BOOL)shouldSign shouldEncrypt:(BOOL)shouldEncrypt shouldSkipSignature:(BOOL)shouldSkipSignature shouldBePlainText:(BOOL)shouldBePlainText;


/**
 Creates a new message with pgp-keys attached on it.
 */
- (Subdata *)_newPGPBodyDataWithOriginalData:(NSData *)originalData headers:(MutableMessageHeaders *)headers keysToAttach:(NSData *)keysToAttach;



/**
 Creates the new gpg message data which will replace the original outgoing message
 body data and sets the correct headers.
 
 shouldBeMIME decides whether the returned message data is a inline gpg message or a mime
 gpg message.
 */
- (Subdata *)_newPGPBodyDataWithEncryptedData:(NSData *)encryptedData headers:(MutableMessageHeaders *)headers shouldBeMIME:(BOOL)shouldBeMIME keysToAttach:(NSData *)keysToAttach;

/**
 This method adds some info to the original method headers which is relevant
 for the encryption and signing methods.
 
 Unfortunately within MimePart.newEncryptedPartWithData:recipients:encryptedData: and 
 MimePart.newSignedPartWithData:sender:signatureData: there's no way of knowing 
 whether the message should be S/MIME signed/encrypted or PGP signed/encrypted, since
 only the relevant email addresses from the original headers are passed in.
 
 To guess the method to be used within these methods, the email addresses are prefixed
 with 'gpg-flagged-<id>-<header-key>::' if the OpenPGP checkbox is checked.
 
 In addition this prefix is used to distinguish bcc recipients from normal recipients.
 GPG allows to add bcc recipients which receive the message, but the encrypted
 or signed data contains no information that these recipients exist.
 As it seems it's not necessary for S/MIME to treat the two types of recipients 
 differentely.
 
 Based on what operations are performed (signing, encrypting, encrypting+signing)
 different info is added to the original headers.
 forEncrypting and forSigning decide which headers are added.
 */
- (void)_addGPGFlaggedStringsToHeaders:(NSMutableDictionary *)headers forEncrypting:(BOOL)forEncrypting forSigning:(BOOL)forSigning forSymmetric:(BOOL)forSymmetric isDraft:(BOOL)isDraft;

/**
 Is called whenever a recipient is added to the message and decides
 whether or not the encrypt button in the security view is activated or not.
 
 If the OpenPGP checkbox is not checked it calls the original method for S/MIME support.
 Otherwise each recipient is checked against GPGMail's internal list of
 recipients a public key exists for.
 Only if public keys for all recipients are found it returns true.
 */
- (BOOL)MACanEncryptForRecipients:(NSArray *)recipients sender:(NSString *)sender;

/**
 Is called whenever the 'from' account is changed
 and decides whether or not the sign button in the security view is activated 
 or not.
 
 If the OpenPGP checkbox is not checked it calls the original method for S/MIME support.
 Otherwise the sender is checked against GPGMail's internal list to find
 a matching sender with a valid private key.
 If a matching sender and valid private key is found, returns true.
 
 The email address might include the name which is extracted using uncommentedAddress. 
 */
- (BOOL)MACanSignFromAddress:(NSString *)address;

/* 
 Is called whenever the user clicks on the encrypt button
 in the security view.
 
 If it doesn't return an empty list, an alert panel is displayed telling
 the user, that no public key was found for a recipient of the message.
 
 If the OpenPGP checkbox is not checked it calls the original method for S/MIME support.
 */
- (id)MARecipientsThatHaveNoKeyForEncryption;

- (Subdata *)_newPGPInlineBodyDataWithData:(NSData *)data headers:(MutableMessageHeaders *)headers shouldSign:(BOOL)shouldSign shouldEncrypt:(BOOL)shouldEncrypt;

/**
 Determines whether or not the -[MailDocumentEditor backEndDidLoadInitialContent:] method was already called.
 When a new security method is set, this flag is first checked, so that no notification
 of a security method change is sent, before the editor was fully initialized.
 */
@property (nonatomic, assign) BOOL wasInitialized;

/**
 Holds and sets the security method to be used.
 If the security method is changed, it sents a SecurityMethodDidChangeNotification,
 so the Account list and the security method hint accessory view can be updated
 appropiately.
 */
@property (nonatomic, assign) GPGMAIL_SECURITY_METHOD securityMethod;
@property (nonatomic, assign) GPGMAIL_SECURITY_METHOD guessedSecurityMethod;
@property (nonatomic, copy) NSMutableDictionary *securityProperties;
- (void)updateSecurityProperties:(NSDictionary *)updates;

/**
 Sets the flag that the user has chosen a security method.
 From this point on GPGMail will no longer automatically select
 the best method.
 */
@property (nonatomic, assign) BOOL userDidChooseSecurityMethod;

/**
 Returns if the user writing a reply to a message.
 */
- (BOOL)messageIsBeingReplied;

/**
 Returns if the user is continuing to edit a draft.
 */
- (BOOL)draftIsContinued;

/**
 This hook is necessary to determine whether or not a user continues editing a draft.
 Unfortunately the -[ComposeBackEnd type] doesn't reflect that.
 */
- (void)MA_configureLastDraftInformationFromHeaders:(id)headers overwrite:(BOOL)overwrite;

/**
 Posts the SecurityMethodDidChange notification.
 */
- (void)postSecurityMethodDidChangeNotification:(GPGMAIL_SECURITY_METHOD)securityMethod;

/**
 Checks the contents of a message and tries to determine, whether the sent action
 was invoked by iCal, in which case, the message is not to be encrypted nor signed.
 */
- (BOOL)sentActionInvokedFromiCalWithContents:(WebComposeMessageContents *)contents;

/**
 Helper method to access the encryptIfPossible flag. On OS X before Yosemite, this flag
 is set in a _flags struct. On Yosemite, there's a bool property which is used.
 */
- (BOOL)GMEncryptIfPossible;

/**
 Helper method to access the signIfPossible flag. On OS X before Yosemite, this flag
 is set in a _flags struct. On Yosemite, there's a bool property which is used.
 */
- (BOOL)GMSignIfPossible;

@end

/**
 Under Lion GCD Dispatch Queues are not represented as Objective-C objects, which leads to
 massive problems and a crash when trying to store a dispatch queue as associated objected.
 In order to fix that issue, we simply wrap the dispatch queue in an object ourseveles.
 Let's see how well that goes.
 */
@interface GMDispatchQueueObject : NSObject {
	NSString *_name;
	dispatch_queue_t _dispatchQueue;
}

- (id)initWithName:(const char *)name queueAttributes:(dispatch_queue_attr_t)attributes;

@property (nonatomic, readonly) dispatch_queue_t dispatchQueue;

@end
