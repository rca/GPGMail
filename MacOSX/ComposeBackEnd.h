#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

@class StationeryController;
@class ParsedMessage;
@class MFUUID;
@class InvocationQueue;
@class MailboxUid;
@class EditableWebMessageDocument;
@class ParsedMessage;
@class MailAccount;

@interface ComposeBackEnd : NSObject
{
    id _delegate;
    NSPort *_initializationPort;
    StationeryController *_stationeryController;
    NSArray *_originalMessages;
    NSArray *generatedParsedMessages;
    long long backgroundResourcesLeft;
    DOMNode *stationerySignatureNode;
    NSMutableDictionary *_originalMessageHeaders;
    NSMutableDictionary *_originalMessageBodies;
    ParsedMessage *_originalMessageParsedMessage;
    NSURL *_originalMessageBaseURL;
    NSMutableDictionary *_cleanHeaders;
    NSMutableDictionary *_extraRecipients;
    NSMutableDictionary *_directoriesByAttachment;
    NSUndoManager *_undoManager;
    MFUUID *_documentID;
    NSMutableSet *_knownMessageIds;
    InvocationQueue *_saveQueue;
    BOOL _saveThreadCancelFlag;
    NSString *_saveThreadMessageId;
    MailboxUid *_saveThreadMailboxUid;
    struct {
        unsigned int type:4;
        unsigned int sendFormat:2;
        unsigned int contentIsLink:1;
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
        unsigned int preferredEncoding;
        unsigned int encodingHint;
    } _flags;
    NSString *_contentForAddressBookUpdate;
    NSString *_vcardPathForAddressBookUpdate;
    BOOL _willCloseEditor;
    BOOL _isSettingSenderFromGetter;
    EditableWebMessageDocument *_document;
    NSMutableDictionary *_contentsByMessage;
    ParsedMessage *_initialParsedMessage;
    ParsedMessage *_restoredParsedMessage;
    NSMutableDictionary *_attachmentMimeBodiesByURL;
    NSNumber *_uniqueID;
}

+ (void)initialize;
+ (id)supportedMailboxUidTypes;
+ (id)keyPathsForValuesAffectingAccount;
- (void)dealloc;
- (id)initCreatingDocumentEditor:(BOOL)arg1;
- (id)init;
- (void)setStateFromBackEnd:(id)arg1;
- (void)setGeneratedParsedMessages:(id)arg1;
- (void)editorHasInitialized:(id)arg1;
- (void)setWillCloseEditor:(BOOL)arg1;
- (id)description;
- (id)delegate;
- (void)setDelegate:(id)arg1;
- (BOOL)hasStationery;
- (id)stationeryController;
- (BOOL)hasChanges;
- (void)setHasChanges:(BOOL)arg1;
- (id)undoManager;
- (void)setUndoManager:(id)arg1;
- (void)setType:(int)arg1;
- (int)type;
- (BOOL)isRedirecting;
- (void)setShouldDownloadRemoteAttachments:(BOOL)arg1;
- (void)setIsUndeliverable:(BOOL)arg1;
- (BOOL)isUndeliverable;
- (BOOL)sendWindowsFriendlyAttachments;
- (void)setSendWindowsFriendlyAttachments:(BOOL)arg1;
- (id)originalMessage;
- (id)originalMessageHeaders;
- (id)originalMessageBody;
- (id)_knownMessageIds;
- (void)setOriginalMessage:(id)arg1;
- (void)setOriginalMessages:(id)arg1;
- (id)attachments;
- (id)directoryForAttachment:(id)arg1;
- (BOOL)preserveAddedArchiveBody;
@property(retain) ParsedMessage *initialParsedMessage;
- (id)restoredParsedMessage;
- (void)setRestoredParsedMessage:(id)arg1;
@property(readonly) EditableWebMessageDocument *document;
- (void)generateParsedMessageFromOriginalMessages;
- (void)configureLoadingOfRemoteAttachments;
- (void)setTypeAndConfigureLoadingOfRemoteAttachments:(int)arg1;
- (void)setupContentsForView:(id)arg1;
@property(readonly) BOOL defaultFormatIsRich;
- (void)_continueToSetupContentsForView:(id)arg1 withParsedMessages:(id)arg2;
- (BOOL)restoredMessageIsRich;
- (id)_parsedMessageForMessage:(id)arg1;
- (id)mimeBodyForAttachmentWithURL:(id)arg1;
- (unsigned int)_encodingHint;
- (id)_makeMessageWithContents:(id)arg1 isDraft:(BOOL)arg2 shouldSign:(BOOL)arg3 shouldEncrypt:(BOOL)arg4 shouldSkipSignature:(BOOL)arg5 shouldBePlainText:(BOOL)arg6;
- (id)draftMessage;
- (id)plainTextMessage;
- (id)message;
@property(retain) MailAccount *account;
- (void)setDeliveryAccount:(id)arg1;
- (id)deliveryAccount;
@property(retain) NSString *sender;
- (id)cleanHeaders;
- (void)setCleanHeaders:(id)arg1;
@property(retain) NSString *subject;
- (id)messageID;
- (void)setShowAllHeaders:(BOOL)arg1;
@property BOOL includeHeaders;
@property int sendFormat;
@property BOOL contentIsLink;
- (BOOL)okToAddSignatureAutomatically;
- (BOOL)okToLetUserAddSignature;
- (id)signatureId;
- (id)signature;
- (void)setSignature:(id)arg1;
- (void)setStationerySignatureNode:(id)arg1;
- (void)getSignatureElement:(id *)arg1 parent:(id *)arg2 nextSibling:(id *)arg3;
- (id)htmlStringForSignature:(id)arg1;
- (void)setMessagePriority:(long long)arg1;
- (long long)displayableMessagePriority;
- (void)addHeaders:(id)arg1;
- (id)addressListForHeader:(id)arg1;
- (void)setAddressList:(id)arg1 forHeader:(id)arg2;
- (void)insertAddress:(id)arg1 forHeader:(id)arg2 atIndex:(unsigned long long)arg3;
- (void)removeAddressForHeader:(id)arg1 atIndex:(unsigned long long)arg2;
- (BOOL)isAddressHeaderKey:(id)arg1;
- (BOOL)deliverMessage;
- (BOOL)isDeliveringMessage;
- (void)_synchronouslyAppendMessageToOutboxWithContents:(id)arg1;
- (void)_backgroundAppendEnded:(id)arg1;
- (void)_backgroundSaveEnded:(id)arg1;
- (void)_backgroundSaveDidChangeMessageId:(id)arg1;
- (id)saveTaskName;
- (BOOL)saveMessage;
- (id)defaultMessageStore;
- (void)removeLastDraft;
- (BOOL)isEditingMessage:(id)arg1;
- (void)setSignIfPossible:(BOOL)arg1;
- (void)setEncryptIfPossible:(BOOL)arg1;
- (id)allRecipients;
- (id)recipientsThatHaveNoKeyForEncryption;
- (unsigned int)preferredEncoding;
- (void)setPreferredEncoding:(unsigned int)arg1;
- (BOOL)canSign;
- (BOOL)canEncryptForAllRecipients;
- (BOOL)isValidSaveDestination:(id)arg1;
- (void)_configureLastDraftInformationFromHeaders:(id)arg1 overwrite:(BOOL)arg2;
- (void)_configureLastDraftInformationFromHeaders:(id)arg1;
- (void)updateDocumentReference:(id)arg1;
- (void)updateSaveDestinationAccount:(id)arg1 mailbox:(id)arg2;
- (void)finishPreparingContentWithEditorSettings:(id)arg1;
- (void)notifyDelegateMonitor:(id)arg1 alreadyDone:(char *)arg2;
- (void)fetchAndCacheMessages;
- (void)generateMessageParsedMessages;
- (BOOL)hasContents;
- (BOOL)containsRichText;
- (id)outgoingMessageUsingWriter:(id)arg1 contents:(id)arg2 headers:(id)arg3 isDraft:(BOOL)arg4 shouldBePlainText:(BOOL)arg5;
- (id)htmlStringFromRange:(id)arg1 htmlDocument:(id)arg2 removeCustomAttributes:(BOOL)arg3 convertObjectsToImages:(BOOL)arg4 convertEditableElements:(BOOL)arg5;
- (id)_createPlainTextRepresentationIncludeAttachments:(BOOL)arg1;
- (void)addBaseURLTagToNode:(id)arg1;
- (void)recursivelyURLifyNode:(id)arg1;
- (void)getContentsForMessage:(id)arg1 body:(id)arg2;
- (id)originalMessageParsedMessage;
- (void)setOriginalMessageParsedMessage:(id)arg1;
- (id)htmlDocumentForSave;
- (id)makeCopyOfContentsForDraft:(BOOL)arg1 shouldBePlainText:(BOOL)arg2;
- (BOOL)attachmentCanBeSentInline:(id)arg1;
- (BOOL)containsAttachments;
- (BOOL)containsAttachmentsThatCouldConfuseWindowsClients;
- (void)_ccOrBccMyselfGivenOriginalMessage:(id)arg1 uniquedRecipientsTable:(id)arg2;
- (void)_setupDefaultRecipientsFirstTime:(BOOL)arg1;
- (id)_allRecipients;
- (void)saveRecipients;
- (id)_fallbackReplyAddress;
- (id)replyAddressForMessage:(id)arg1;
- (id)mailboxUidCreateIfNeeded:(BOOL)arg1;
- (int)convertSaveOrSendResultFromResultCodeT:(int)arg1;
@property(readonly) BOOL isSavingMessage;
- (BOOL)isContentSignificant;
@property BOOL saveThreadCancelFlag; // @synthesize saveThreadCancelFlag=_saveThreadCancelFlag;
- (BOOL)_saveThreadShouldCancel;
- (void)_saveThreadUpdateAccount:(id)arg1 mailbox:(id)arg2;
- (void)_saveThreadSetMessageId:(id)arg1 mailboxUid:(id)arg2 overwrite:(id)arg3;
- (void)_saveThreadRemoveLastSave;
- (void)_saveThreadSaveContents:(id)arg1;
- (void)_markForOverwrite:(id)arg1;
- (BOOL)isExchangeNote;
@property(retain) MailboxUid *saveThreadMailboxUid; // @synthesize saveThreadMailboxUid=_saveThreadMailboxUid;
@property(copy) NSString *saveThreadMessageId; // @synthesize saveThreadMessageId=_saveThreadMessageId;
@property(retain) MFUUID *documentID; // @synthesize documentID=_documentID;
@property(retain) NSURL *originalMessageBaseURL; // @synthesize originalMessageBaseURL=_originalMessageBaseURL;

@end

@interface ComposeBackEnd (ScriptingSupport)
+ (id)composeBackEndForUniqueID:(id)arg1;
+ (void)registerComposeBackEnd:(id)arg1;
+ (void)unregisterComposeBackEnd:(id)arg1;
+ (id)_messageEditorForComposeBackEnd:(id)arg1 window:(id *)arg2;
- (id)uniqueID;
- (BOOL)isVisible;
- (void)setIsVisible:(BOOL)arg1;
- (id)appleScriptSender;
- (void)setAppleScriptSender:(id)arg1;
- (id)appleScriptSubject;
- (void)setAppleScriptSubject:(id)arg1;
- (id)content;
- (void)setContent:(id)arg1;
- (id)messageSignature;
- (void)setMessageSignature:(id)arg1;
- (void)_addRecipientsForKey:(id)arg1 toArray:(id)arg2;
- (id)recipients;
- (id)toRecipients;
- (id)ccRecipients;
- (id)bccRecipients;
- (void)insertRecipient:(id)arg1 atIndex:(unsigned long long)arg2 inHeaderWithKey:(id)arg3;
- (void)insertInToRecipients:(id)arg1 atIndex:(unsigned long long)arg2;
- (void)insertInToRecipients:(id)arg1;
- (void)insertInCcRecipients:(id)arg1 atIndex:(unsigned long long)arg2;
- (void)insertInCcRecipients:(id)arg1;
- (void)insertInBccRecipients:(id)arg1 atIndex:(unsigned long long)arg2;
- (void)insertInBccRecipients:(id)arg1;
- (void)removeFromToRecipientsAtIndex:(unsigned long long)arg1;
- (void)removeFromCcRecipientsAtIndex:(unsigned long long)arg1;
- (void)removeFromBccRecipientsAtIndex:(unsigned long long)arg1;
- (void)replaceFormattedAddress:(id)arg1 withAddress:(id)arg2 forKey:(id)arg3;
- (id)handleSaveMessageCommand:(id)arg1;
- (id)handleSendMessageCommand:(id)arg1;
- (id)handleCloseScriptCommand:(id)arg1;
- (id)objectSpecifier;
- (void)setHtmlContent:(id)arg1;
- (void)setVcardPath:(id)arg1;
@end

@interface ComposeBackEnd (ScriptingSupportInternal)
+ (id)composeBackEndsByUniqueID;
- (void)createUniqueID;
@end

@interface ComposeBackEnd_Scripting : ComposeBackEnd
{
    NSTextStorage *_textStorage;
}

- (void)dealloc;
- (void)setTextStorage:(id)arg1;
- (id)textStorage;
- (id)content;
- (void)setContent:(id)arg1;
- (void)_pushTextStorage;
- (void)_convertTextStorage;
- (void)_coalescedConvertTextStorage;

@end

#elif defined(SNOW_LEOPARD)

@class StationeryController;
@class DOMNode;
@class ParsedMessage;
@class MFUUID;
@class InvocationQueue;
@class MailboxUid;
@class EditableWebMessageDocument;

@interface ComposeBackEnd : NSObject
{
    id _delegate;
    NSPort *_initializationPort;
    StationeryController *_stationeryController;
    NSArray *_originalMessages;
    NSArray *generatedParsedMessages;
    int backgroundResourcesLeft;
    DOMNode *stationerySignatureNode;
    NSMutableDictionary *_originalMessageHeaders;
    NSMutableDictionary *_originalMessageBodies;
    ParsedMessage *_originalMessageParsedMessage;
    NSURL *_originalMessageBaseURL;
    NSMutableDictionary *_cleanHeaders;
    NSMutableDictionary *_extraRecipients;
    NSMutableDictionary *_directoriesByAttachment;
    NSUndoManager *_undoManager;
    MFUUID *_documentID;
    NSMutableSet *_knownMessageIds;
    InvocationQueue *_saveQueue;
    BOOL _saveThreadCancelFlag;
    NSString *_saveThreadMessageId;
    MailboxUid *_saveThreadMailboxUid;
    struct {
        unsigned int type:4;
        unsigned int sendFormat:2;
        unsigned int contentIsLink:1;
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
        unsigned int preferredEncoding;
        unsigned int encodingHint;
    } _flags;
    NSString *_contentForAddressBookUpdate;
    NSString *_vcardPathForAddressBookUpdate;
    BOOL _willCloseEditor;
    BOOL _isSettingSenderFromGetter;
    EditableWebMessageDocument *_document;
    NSMutableDictionary *_contentsByMessage;
    ParsedMessage *_initialParsedMessage;
    ParsedMessage *_restoredParsedMessage;
    NSMutableDictionary *_attachmentMimeBodiesByURL;
    NSNumber *_uniqueID;
}

+ (void)initialize;
+ (id)supportedMailboxUidTypes;
+ (id)keyPathsForValuesAffectingAccount;
- (void)dealloc;
- (id)initCreatingDocumentEditor:(BOOL)arg1;
- (id)init;
- (void)setStateFromBackEnd:(id)arg1;
- (void)setGeneratedParsedMessages:(id)arg1;
- (void)editorHasInitialized:(id)arg1;
- (void)setWillCloseEditor:(BOOL)arg1;
- (id)description;
- (id)delegate;
- (void)setDelegate:(id)arg1;
- (BOOL)hasStationery;
- (id)stationeryController;
- (BOOL)hasChanges;
- (void)setHasChanges:(BOOL)arg1;
- (id)undoManager;
- (void)setUndoManager:(id)arg1;
- (void)setType:(int)arg1;
- (int)type;
- (BOOL)isRedirecting;
- (void)setShouldDownloadRemoteAttachments:(BOOL)arg1;
- (void)setIsUndeliverable:(BOOL)arg1;
- (BOOL)isUndeliverable;
- (BOOL)sendWindowsFriendlyAttachments;
- (void)setSendWindowsFriendlyAttachments:(BOOL)arg1;
- (id)originalMessage;
- (id)originalMessageHeaders;
- (id)originalMessageBody;
- (id)_knownMessageIds;
- (void)setOriginalMessage:(id)arg1;
- (void)setOriginalMessages:(id)arg1;
- (id)attachments;
- (id)directoryForAttachment:(id)arg1;
- (BOOL)preserveAddedArchiveBody;
- (id)initialParsedMessage;
- (void)setInitialParsedMessage:(id)arg1;
- (id)restoredParsedMessage;
- (void)setRestoredParsedMessage:(id)arg1;
- (id)document;
- (void)generateParsedMessageFromOriginalMessages;
- (void)configureLoadingOfRemoteAttachments;
- (void)setTypeAndConfigureLoadingOfRemoteAttachments:(int)arg1;
- (void)setupContentsForView:(id)arg1;
- (BOOL)defaultFormatIsRich;
- (void)_continueToSetupContentsForView:(id)arg1 withParsedMessages:(id)arg2;
- (BOOL)restoredMessageIsRich;
- (id)_parsedMessageForMessage:(id)arg1;
- (id)mimeBodyForAttachmentWithURL:(id)arg1;
- (unsigned long)_encodingHint;
- (id)_makeMessageWithContents:(id)arg1 isDraft:(BOOL)arg2 shouldSign:(BOOL)arg3 shouldEncrypt:(BOOL)arg4 shouldSkipSignature:(BOOL)arg5 shouldBePlainText:(BOOL)arg6;
- (id)draftMessage;
- (id)plainTextMessage;
- (id)message;
- (id)account;
- (void)setAccount:(id)arg1;
- (void)setDeliveryAccount:(id)arg1;
- (id)deliveryAccount;
- (id)sender;
- (id)cleanHeaders;
- (void)setCleanHeaders:(id)arg1;
- (void)setSender:(id)arg1;
- (id)subject;
- (void)setSubject:(id)arg1;
- (id)messageID;
- (void)setShowAllHeaders:(BOOL)arg1;
- (BOOL)includeHeaders;
- (void)setIncludeHeaders:(BOOL)arg1;
- (void)setSendFormat:(int)arg1;
- (int)sendFormat;
- (void)setContentIsLink:(BOOL)arg1;
- (BOOL)contentIsLink;
- (BOOL)okToAddSignatureAutomatically;
- (BOOL)okToLetUserAddSignature;
- (id)signatureId;
- (id)signature;
- (void)setSignature:(id)arg1;
- (void)setStationerySignatureNode:(id)arg1;
- (void)getSignatureElement:(id *)arg1 parent:(id *)arg2 nextSibling:(id *)arg3;
- (id)htmlStringForSignature:(id)arg1;
- (void)setMessagePriority:(long)arg1;
- (long)displayableMessagePriority;
- (void)addHeaders:(id)arg1;
- (id)addressListForHeader:(id)arg1;
- (void)setAddressList:(id)arg1 forHeader:(id)arg2;
- (void)insertAddress:(id)arg1 forHeader:(id)arg2 atIndex:(unsigned long)arg3;
- (void)removeAddressForHeader:(id)arg1 atIndex:(unsigned long)arg2;
- (BOOL)isAddressHeaderKey:(id)arg1;
- (BOOL)deliverMessage;
- (BOOL)isDeliveringMessage;
- (void)_synchronouslyAppendMessageToOutboxWithContents:(id)arg1;
- (void)_backgroundAppendEnded:(id)arg1;
- (void)_backgroundSaveEnded:(id)arg1;
- (void)_backgroundSaveDidChangeMessageId:(id)arg1;
- (id)saveTaskName;
- (BOOL)saveMessage;
- (id)defaultMessageStore;
- (void)removeLastDraft;
- (BOOL)isEditingMessage:(id)arg1;
- (void)setSignIfPossible:(BOOL)arg1;
- (void)setEncryptIfPossible:(BOOL)arg1;
- (id)allRecipients;
- (id)recipientsThatHaveNoKeyForEncryption;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)arg1;
- (BOOL)canSign;
- (BOOL)canEncryptForAllRecipients;
- (BOOL)isValidSaveDestination:(id)arg1;
- (void)_configureLastDraftInformationFromHeaders:(id)arg1 overwrite:(BOOL)arg2;
- (void)_configureLastDraftInformationFromHeaders:(id)arg1;
- (void)updateDocumentReference:(id)arg1;
- (void)updateSaveDestinationAccount:(id)arg1 mailbox:(id)arg2;
- (void)finishPreparingContentWithEditorSettings:(id)arg1;
- (void)notifyDelegateMonitor:(id)arg1 alreadyDone:(char *)arg2;
- (void)fetchAndCacheMessages;
- (void)generateMessageParsedMessages;
- (BOOL)hasContents;
- (BOOL)containsRichText;
- (id)outgoingMessageUsingWriter:(id)arg1 contents:(id)arg2 headers:(id)arg3 isDraft:(BOOL)arg4 shouldBePlainText:(BOOL)arg5;
- (id)htmlStringFromRange:(id)arg1 htmlDocument:(id)arg2 removeCustomAttributes:(BOOL)arg3 convertObjectsToImages:(BOOL)arg4 convertEditableElements:(BOOL)arg5;
- (id)_createPlainTextRepresentationIncludeAttachments:(BOOL)arg1;
- (void)addBaseURLTagToNode:(id)arg1;
- (void)recursivelyURLifyNode:(id)arg1;
- (void)getContentsForMessage:(id)arg1 body:(id)arg2;
- (id)originalMessageParsedMessage;
- (void)setOriginalMessageParsedMessage:(id)arg1;
- (id)htmlDocumentForSave;
- (id)makeCopyOfContentsForDraft:(BOOL)arg1 shouldBePlainText:(BOOL)arg2;
- (BOOL)attachmentCanBeSentInline:(id)arg1;
- (BOOL)containsAttachments;
- (BOOL)containsAttachmentsThatCouldConfuseWindowsClients;
- (void)_ccOrBccMyselfGivenOriginalMessage:(id)arg1 uniquedRecipientsTable:(id)arg2;
- (void)_setupDefaultRecipientsFirstTime:(BOOL)arg1;
- (id)_allRecipients;
- (void)saveRecipients;
- (id)_fallbackReplyAddress;
- (id)replyAddressForMessage:(id)arg1;
- (id)mailboxUidCreateIfNeeded:(BOOL)arg1;
- (int)convertSaveOrSendResultFromResultCodeT:(int)arg1;
- (BOOL)isSavingMessage;
- (BOOL)isContentSignificant;
- (BOOL)saveThreadCancelFlag;
- (void)setSaveThreadCancelFlag:(BOOL)arg1;
- (BOOL)_saveThreadShouldCancel;
- (void)_saveThreadUpdateAccount:(id)arg1 mailbox:(id)arg2;
- (void)_saveThreadSetMessageId:(id)arg1 mailboxUid:(id)arg2 overwrite:(id)arg3;
- (void)_saveThreadRemoveLastSave;
- (void)_saveThreadSaveContents:(id)arg1;
- (void)_markForOverwrite:(id)arg1;
- (BOOL)isExchangeNote;
- (id)saveThreadMailboxUid;
- (void)setSaveThreadMailboxUid:(id)arg1;
- (id)saveThreadMessageId;
- (void)setSaveThreadMessageId:(id)arg1;
- (id)documentID;
- (void)setDocumentID:(id)arg1;
- (id)originalMessageBaseURL;
- (void)setOriginalMessageBaseURL:(id)arg1;

@end

@interface ComposeBackEnd_Scripting : ComposeBackEnd
{
    NSTextStorage *_textStorage;
}

- (void)dealloc;
- (void)setTextStorage:(id)arg1;
- (id)textStorage;
- (id)content;
- (void)setContent:(id)arg1;
- (void)_pushTextStorage;
- (void)_convertTextStorage;
- (void)_coalescedConvertTextStorage;

@end

@interface ComposeBackEnd (ScriptingSupport)
+ (id)composeBackEndForUniqueID:(id)arg1;
+ (void)registerComposeBackEnd:(id)arg1;
+ (void)unregisterComposeBackEnd:(id)arg1;
+ (id)_messageEditorForComposeBackEnd:(id)arg1 window:(id *)arg2;
- (id)uniqueID;
- (BOOL)isVisible;
- (void)setIsVisible:(BOOL)arg1;
- (id)appleScriptSender;
- (void)setAppleScriptSender:(id)arg1;
- (id)appleScriptSubject;
- (void)setAppleScriptSubject:(id)arg1;
- (id)content;
- (void)setContent:(id)arg1;
- (id)messageSignature;
- (void)setMessageSignature:(id)arg1;
- (void)_addRecipientsForKey:(id)arg1 toArray:(id)arg2;
- (id)recipients;
- (id)toRecipients;
- (id)ccRecipients;
- (id)bccRecipients;
- (void)insertRecipient:(id)arg1 atIndex:(unsigned long)arg2 inHeaderWithKey:(id)arg3;
- (void)insertInToRecipients:(id)arg1 atIndex:(unsigned long)arg2;
- (void)insertInToRecipients:(id)arg1;
- (void)insertInCcRecipients:(id)arg1 atIndex:(unsigned long)arg2;
- (void)insertInCcRecipients:(id)arg1;
- (void)insertInBccRecipients:(id)arg1 atIndex:(unsigned long)arg2;
- (void)insertInBccRecipients:(id)arg1;
- (void)removeFromToRecipientsAtIndex:(unsigned long)arg1;
- (void)removeFromCcRecipientsAtIndex:(unsigned long)arg1;
- (void)removeFromBccRecipientsAtIndex:(unsigned long)arg1;
- (void)replaceFormattedAddress:(id)arg1 withAddress:(id)arg2 forKey:(id)arg3;
- (id)handleSaveMessageCommand:(id)arg1;
- (id)handleSendMessageCommand:(id)arg1;
- (id)handleCloseScriptCommand:(id)arg1;
- (id)objectSpecifier;
- (void)setHtmlContent:(id)arg1;
- (void)setVcardPath:(id)arg1;
@end

@interface ComposeBackEnd (ScriptingSupportInternal)
+ (id)composeBackEndsByUniqueID;
- (void)createUniqueID;
@end

#elif defined(LEOPARD)

@class StationeryController;
@class DOMNode;
@class MFUUID;
@class InvocationQueue;
@class MailboxUid;
@class EditableWebMessageDocument;
@class WebArchive;
@class MessageTextStorage;

@interface ComposeBackEnd : NSObject
{
    id _delegate;
    StationeryController *stationeryController;
    NSArray *_originalMessages;
    NSArray *generatedWebArchives;
    int backgroundResourcesLeft;
    DOMNode *stationerySignatureNode;
    NSMutableDictionary *_originalMessageHeaders;
    NSMutableDictionary *_originalMessageBodies;
    WebArchive *_originalMessageWebArchive;
    NSString *_originalMessageBaseURL;
    NSMutableDictionary *_cleanHeaders;
    NSMutableDictionary *_extraRecipients;
    NSMutableDictionary *_directoriesByAttachment;
    NSUndoManager *_undoManager;
    MFUUID *_documentID;
    NSMutableSet *_knownMessageIds;
    InvocationQueue *_saveQueue;
    BOOL _saveThreadCancelFlag;
    NSString *_saveThreadMessageId;
    MailboxUid *_saveThreadMailboxUid;
    struct {
        unsigned int type:4;
        unsigned int sendFormat:2;
        unsigned int contentIsLink:1;
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
        unsigned int preferredEncoding;
        unsigned int encodingHint;
    } _flags;
    NSString *_contentForAddressBookUpdate;
    NSString *_vcardPathForAddressBookUpdate;
    BOOL _willCloseEditor;
    EditableWebMessageDocument *_document;
    NSMutableDictionary *_contentsByMessage;
    NSMutableDictionary *_documentsByMessage;
    WebArchive *_initialWebArchive;
    WebArchive *_restoredWebArchive;
    NSMutableDictionary *_attachmentMimeBodiesByURL;
}

+ (id)supportedMailboxUidTypes;
- (void)dealloc;
- (id)init;
- (void)setStateFromBackEnd:(id)fp8;
- (void)setGeneratedWebArchives:(id)fp8;
- (void)editorHasInitialized:(id)fp8;
- (void)setWillCloseEditor:(BOOL)fp8;
- (id)description;
- (id)delegate;
- (void)setDelegate:(id)fp8;
- (BOOL)hasStationery;
- (id)stationeryController;
- (BOOL)hasChanges;
- (void)setHasChanges:(BOOL)fp8;
- (id)undoManager;
- (void)setUndoManager:(id)fp8;
- (void)setType:(int)fp8;
- (int)type;
- (void)setShouldDownloadRemoteAttachments:(BOOL)fp8;
- (void)setIsUndeliverable:(BOOL)fp8;
- (BOOL)isUndeliverable;
- (BOOL)sendWindowsFriendlyAttachments;
- (void)setSendWindowsFriendlyAttachments:(BOOL)fp8;
- (id)originalMessage;
- (id)originalMessageHeaders;
- (id)originalMessageBody;
- (id)_knownMessageIds;
- (void)setOriginalMessage:(id)fp8;
- (void)setOriginalMessages:(id)fp8;
- (id)attachments;
- (id)directoryForAttachment:(id)fp8;
- (BOOL)preserveAddedArchiveBody;
- (id)initialWebArchive;
- (void)setInitialWebArchive:(id)fp8;
- (id)restoredWebArchive;
- (void)setRestoredWebArchive:(id)fp8;
- (id)document;
- (void)generateWebArchiveFromOriginalMessages;
- (void)configureLoadingOfRemoteAttachments;
- (void)setupContentsForView:(id)fp8;
- (BOOL)defaultFormatIsRich;
- (void)_continueToSetupContentsForView:(id)fp8 withArchives:(id)fp12;
- (id)mimeBodyForAttachmentWithURL:(id)fp8;
- (unsigned long)_encodingHint;
- (id)_makeMessageWithContents:(id)fp8 isDraft:(BOOL)fp12 shouldSign:(BOOL)fp16 shouldEncrypt:(BOOL)fp20 shouldSkipSignature:(BOOL)fp24;
- (id)draftMessage;
- (id)message;
- (id)account;
- (void)setAccount:(id)fp8;
- (void)setDeliveryAccount:(id)fp8;
- (id)deliveryAccount;
- (id)sender;
- (id)cleanHeaders;
- (void)setCleanHeaders:(id)fp8;
- (void)setSender:(id)fp8;
- (id)subject;
- (void)setSubject:(id)fp8;
- (id)messageID;
- (void)setShowAllHeaders:(BOOL)fp8;
- (BOOL)includeHeaders;
- (void)setIncludeHeaders:(BOOL)fp8;
- (void)setSendFormat:(int)fp8;
- (int)sendFormat;
- (void)setContentIsLink:(BOOL)fp8;
- (BOOL)contentIsLink;
- (BOOL)okToAddSignatureAutomatically;
- (BOOL)okToLetUserAddSignature;
- (id)signatureId;
- (id)signature;
- (void)setSignature:(id)fp8;
- (void)setStationerySignatureNode:(id)fp8;
- (void)getSignatureElement:(id *)fp8 parent:(id *)fp12 nextSibling:(id *)fp16;
- (id)webArchiveForSignature:(id)fp8;
- (void)setMessagePriority:(int)fp8;
- (int)displayableMessagePriority;
- (void)addHeaders:(id)fp8;
- (id)addressListForHeader:(id)fp8;
- (void)setAddressList:(id)fp8 forHeader:(id)fp12;
- (void)insertAddress:(id)fp8 forHeader:(id)fp12 atIndex:(unsigned int)fp16;
- (void)removeAddressForHeader:(id)fp8 atIndex:(unsigned int)fp12;
- (BOOL)isAddressHeaderKey:(id)fp8;
- (BOOL)deliverMessage;
- (BOOL)isDeliveringMessage;
- (void)_synchronouslyAppendMessageToOutboxWithContents:(id)fp8;
- (void)_backgroundAppendEnded:(id)fp8;
- (void)_backgroundSaveEnded:(id)fp8;
- (void)_backgroundSaveDidChangeMessageId:(id)fp8;
- (id)saveTaskName;
- (BOOL)saveMessage;
- (id)defaultMessageStore;
- (void)removeLastDraft;
- (BOOL)isEditingMessage:(id)fp8;
- (void)setSignIfPossible:(BOOL)fp8;
- (void)setEncryptIfPossible:(BOOL)fp8;
- (id)allRecipients;
- (id)recipientsThatHaveNoKeyForEncryption;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)fp8;
- (BOOL)canSign;
- (BOOL)canEncryptForAllRecipients;
- (BOOL)isValidSaveDestination:(id)fp8;
- (void)_configureLastDraftInformationFromHeaders:(id)fp8 overwrite:(BOOL)fp12;
- (void)_configureLastDraftInformationFromHeaders:(id)fp8;
- (void)updateDocumentReference:(id)fp8;
- (void)updateSaveDestinationAccount:(id)fp8 mailbox:(id)fp12;
- (void)finishPreparingContentWithEditorSettings:(id)fp8;
- (void)notifyDelegateMonitor:(id)fp8 alreadyDone:(char *)fp12;
- (void)fetchAndCacheMessages;
- (void)generateMessageWebArchives;
- (BOOL)hasContents;
- (BOOL)containsRichText;
- (id)outgoingMessageUsingWriter:(id)fp8 contents:(id)fp12 headers:(id)fp16 isDraft:(BOOL)fp20;
- (id)htmlStringFromRange:(id)fp8 htmlDocument:(id)fp12 removeCustomAttributes:(BOOL)fp16 convertObjectsToImages:(BOOL)fp20 convertEditableElements:(BOOL)fp24;
- (id)_createPlainTextRepresentationIncludeAttachments:(BOOL)fp8;
- (id)plainTextRepresentationOfContents:(id)fp8;
- (void)addBaseURLTagToNode:(id)fp8;
- (void)recursivelyURLifyNode:(id)fp8;
- (void)getContentsForMessage:(id)fp8 body:(id)fp12;
- (id)originalMessageWebArchive;
- (void)setOriginalMessageWebArchive:(id)fp8;
- (id)htmlDocumentForSave;
- (id)makeCopyOfContentsForDraft:(BOOL)fp8;
- (BOOL)attachmentCanBeSentInline:(id)fp8;
- (BOOL)containsAttachments;
- (BOOL)containsAttachmentsThatCouldConfuseWindowsClients;
- (void)_ccOrBccMyselfGivenOriginalMessage:(id)fp8 uniquedRecipientsTable:(id)fp12;
- (void)_setupDefaultRecipientsFirstTime:(BOOL)fp8;
- (id)_allRecipients;
- (void)saveRecipients;
- (id)_fallbackReplyAddress;
- (id)replyAddressForMessage:(id)fp8;
- (id)mailboxUidCreateIfNeeded:(BOOL)fp8;
- (int)convertSaveOrSendResultFromResultCodeT:(int)fp8;
- (BOOL)isSavingMessage;
- (BOOL)isContentSignificant;
- (BOOL)saveThreadCancelFlag;
- (void)setSaveThreadCancelFlag:(BOOL)fp8;
- (BOOL)_saveThreadShouldCancel;
- (void)_saveThreadUpdateAccount:(id)fp8 mailbox:(id)fp12;
- (void)_saveThreadSetMessageId:(id)fp8 mailboxUid:(id)fp12 overwrite:(id)fp16;
- (void)_saveThreadRemoveLastSave;
- (void)_saveThreadSaveContents:(id)fp8;
- (id)saveThreadMailboxUid;
- (void)setSaveThreadMailboxUid:(id)fp8;
- (id)saveThreadMessageId;
- (void)setSaveThreadMessageId:(id)fp8;
- (id)documentID;
- (void)setDocumentID:(id)fp8;
- (id)originalMessageBaseURL;
- (void)setOriginalMessageBaseURL:(id)fp8;

@end

@interface ComposeBackEnd_Scripting : ComposeBackEnd
{
    MessageTextStorage *_textStorage;
}

- (id)init;
- (void)dealloc;
- (void)setTextStorage:(id)fp8;
- (id)textStorage;
- (id)content;
- (void)setContent:(id)fp8;
- (void)_pushTextStorage;
- (void)_convertTextStorage;
- (void)_coalescedConvertTextStorage;

@end

@interface ComposeBackEnd (ScriptingSupport)
+ (id)_messageEditorForComposeBackEnd:(id)fp8 window:(id *)fp12;
- (BOOL)isVisible;
- (void)setIsVisible:(BOOL)fp8;
- (id)appleScriptSender;
- (void)setAppleScriptSender:(id)fp8;
- (id)appleScriptSubject;
- (void)setAppleScriptSubject:(id)fp8;
- (id)content;
- (void)setContent:(id)fp8;
- (id)messageSignature;
- (void)setMessageSignature:(id)fp8;
- (void)_addRecipientsForKey:(id)fp8 toArray:(id)fp12;
- (id)recipients;
- (id)toRecipients;
- (id)ccRecipients;
- (id)bccRecipients;
- (void)insertRecipient:(id)fp8 atIndex:(unsigned int)fp12 inHeaderWithKey:(id)fp16;
- (void)insertInToRecipients:(id)fp8 atIndex:(unsigned int)fp12;
- (void)insertInToRecipients:(id)fp8;
- (void)insertInCcRecipients:(id)fp8 atIndex:(unsigned int)fp12;
- (void)insertInCcRecipients:(id)fp8;
- (void)insertInBccRecipients:(id)fp8 atIndex:(unsigned int)fp12;
- (void)insertInBccRecipients:(id)fp8;
- (void)removeFromToRecipientsAtIndex:(unsigned int)fp8;
- (void)removeFromCcRecipientsAtIndex:(unsigned int)fp8;
- (void)removeFromBccRecipientsAtIndex:(unsigned int)fp8;
- (void)replaceFormattedAddress:(id)fp8 withAddress:(id)fp12 forKey:(id)fp16;
- (id)handleSaveMessageCommand:(id)fp8;
- (id)handleSendMessageCommand:(id)fp8;
- (id)handleCloseScriptCommand:(id)fp8;
- (id)uniqueID;
- (id)objectSpecifier;
- (void)setHtmlContent:(id)fp8;
- (void)setVcardPath:(id)fp8;
@end

#elif defined(TIGER)

@class Message;
@class ActivityMonitor;
@class MailboxUid;
@class WebArchive;


@interface ComposeBackEnd : NSObject
{
    id _delegate;
    NSArray *_originalMessages;
    NSMutableDictionary *_originalMessageHeaders;
    NSMutableDictionary *_originalMessageBodies;
    NSArray *_originalMessageStores;
    WebArchive *_originalMessageWebArchive;
    NSMutableDictionary *_cleanHeaders;
    NSMutableDictionary *_extraRecipients;
    NSMutableDictionary *_directoriesByAttachment;
    NSUndoManager *_undoManager;
    ActivityMonitor *_backgroundSaveActivity;
    MailboxUid *_lastDraftsMailboxUid;
    NSString *_lastMessageId;
    NSData *_lastMessageIdDigest;
    struct {
        unsigned int type:4;
        unsigned int sendFormat:2;
        unsigned int contentIsLink:1;
        unsigned int hadChangesBeforeSave:1;
        unsigned int hasChanges:1;
        unsigned int showAllHeaders:1;
        unsigned int isUndeliverable:1;
        unsigned int isDeliveringMessage:1;
        unsigned int isSavingMessage:1;
        unsigned int sendWindowsFriendlyAttachments:2;
        unsigned int contentsWasEditedByUser:1;
        unsigned int delegateRespondsToDidChange:1;
        unsigned int delegateRespondsToDidAppendMessage:1;
        unsigned int delegateRespondsToDidSaveMessage:1;
        unsigned int delegateRespondsToDidBeginLoad:1;
        unsigned int delegateRespondsToDidEndLoad:1;
        unsigned int delegateRespondsToShouldSaveMessage:1;
        unsigned int delegateRespondsToShouldDeliverMessage:1;
        unsigned int delegateRespondsToDidCancelMessageDeliveryForMissingCertificatesForRecipients:1;
        unsigned int delegateRespondsToDidCancelMessageDeliveryForEncryptionError:1;
        unsigned int delegateRespondsToDidCancelMessageDeliveryForError:1;
        unsigned int signIfPossible:1;
        unsigned int encryptIfPossible:1;
        unsigned int knowsCanSign:1;
        unsigned int canSign:1;
        unsigned int preferredEncoding;
    } _flags;
    NSString *_contentForAddressBookUpdate;
    NSString *_vcardPathForAddressBookUpdate;
    BOOL didAbortReply;
}

- (void)dealloc;
- (id)init;
- (void)setDidAbortReply:(BOOL)fp8;
- (id)delegate;
- (void)setDelegate:(id)fp8;
- (BOOL)hasChanges;
- (void)setHasChanges:(BOOL)fp8;
- (id)undoManager;
- (void)setUndoManager:(id)fp8;
- (void)setType:(int)fp8;
- (int)type;
- (void)setIsUndeliverable:(BOOL)fp8;
- (BOOL)isUndeliverable;
- (BOOL)sendWindowsFriendlyAttachments;
- (void)setSendWindowsFriendlyAttachments:(BOOL)fp8;
- (id)originalMessage;
- (id)originalMessageHeaders;
- (id)originalMessageBody;
- (void)setOriginalMessage:(id)fp8;
- (void)setOriginalMessages:(id)fp8;
- (id)directoryForAttachment:(id)fp8;
- (id)message;
- (id)account;
- (id)deliveryAccount;
- (id)sender;
- (void)setSender:(id)fp8;
- (id)subject;
- (void)setSubject:(id)fp8;
- (id)messageID;
- (void)setShowAllHeaders:(BOOL)fp8;
- (void)setSendFormat:(int)fp8;
- (int)sendFormat;
- (void)setContentIsLink:(BOOL)fp8;
- (BOOL)contentIsLink;
- (BOOL)okToAddSignature;
- (id)signatureId;
- (id)signature;
- (void)setSignature:(id)fp8;
- (void)setMessagePriority:(int)fp8;
- (int)displayableMessagePriority;
- (void)addHeaders:(id)fp8;
- (id)addressListForHeader:(id)fp8;
- (void)setAddressList:(id)fp8 forHeader:(id)fp12;
- (void)insertAddress:(id)fp8 forHeader:(id)fp12 atIndex:(unsigned int)fp16;
- (void)removeAddressForHeader:(id)fp8 atIndex:(unsigned int)fp12;
- (BOOL)isAddressHeaderKey:(id)fp8;
- (BOOL)deliverMessage;
- (BOOL)isDeliveringMessage;
- (void)_synchronouslyAppendMessageToOutboxWithContents:(id)fp8;
- (void)_backgroundAppendEnded:(id)fp8;
- (void)_backgroundSaveEnded:(id)fp8;
- (BOOL)saveMessage;
- (BOOL)isSavingMessage;
- (void)removeLastDraft;
- (BOOL)isEditingMessage:(id)fp8;
- (void)setSignIfPossible:(BOOL)fp8;
- (void)setEncryptIfPossible:(BOOL)fp8;
- (id)allRecipients;
- (id)recipientsThatHaveNoKeyForEncryption;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)fp8;
- (BOOL)canSign;
- (BOOL)canEncryptForAllRecipients;
- (void)_configureLastDraftInformationFromHeaders:(id)fp8;
- (void)_finishedLoadingEditorSettings:(id)fp8;
- (void)_synchronouslyLoadForEditorSettings:(id)fp8;
- (void)loadWithEditorSettings:(id)fp8;
- (BOOL)hasContents;
- (BOOL)containsRichText;
- (id)outgoingMessageUsingWriter:(id)fp8 contents:(id)fp12 headers:(id)fp16 isDraft:(BOOL)fp20;
- (void)loadContentsForMessage:(id)fp8 body:(id)fp12;
- (id)makeCopyOfContentsForDraft:(BOOL)fp8;

@end

@interface ComposeBackEnd (Internal)
- (void)_setupDefaultRecipientsFirstTime:(BOOL)fp8;
- (void)_synchronouslySaveMessageWithContents:(id)fp8;
- (id)_allRecipients;
- (void)saveRecipients;
- (id)replyAddressForMessage:(id)fp8;
@end

#else

@class Message;
@class ActivityMonitor;
@class MailboxUid;

@interface ComposeBackEnd:NSObject
{
    id _delegate;	// 4 = 0x4
    Message *_originalMessage;	// 8 = 0x8
    NSMutableDictionary *_cleanHeaders;	// 12 = 0xc
    NSMutableDictionary *_extraRecipients;	// 16 = 0x10
    NSAttributedString *_messageContents;	// 20 = 0x14
    NSMutableDictionary *_directoriesByAttachment;	// 24 = 0x18
    NSString *_encodingType;	// 28 = 0x1c
    NSUndoManager *_undoManager;	// 32 = 0x20
    ActivityMonitor *_backgroundSaveActivity;	// 36 = 0x24
    MailboxUid *_lastDraftsMailboxUid;	// 40 = 0x28
    NSString *_lastMessageId;	// 44 = 0x2c
    struct {
        int type:4;
        int hadChangesBeforeSave:1;
        int hasChanges:1;
        int showAllHeaders:1;
        int isUndeliverable:1;
        int isDeliveringMessage:1;
        int isSavingMessage:1;
        int sendWindowsFriendlyAttachments:2;
        int contentsWasEditedByUser:1;
        int delegateRespondsToDidChange:1;
        int delegateRespondsToDidAppendMessage:1;
        int delegateRespondsToDidSaveMessage:1;
        int delegateRespondsToShouldSaveMessage:1;
        int delegateRespondsToShouldDeliverMessage:1;
        int delegateRespondsToDidCancelMessageDeliveryForMissingCertificatesForRecipients:1;
        int delegateRespondsToDidCancelMessageDeliveryForEncryptionError:1;
        int delegateRespondsToDidCancelMessageDeliveryForError:1;
        int signIfPossible:1;
        int encryptIfPossible:1;
        unsigned int preferredEncoding;
    } _flags;	// 48 = 0x30
    NSString *_contentForAddressBookUpdate;	// 56 = 0x38
    NSString *_vcardPathForAddressBookUpdate;	// 60 = 0x3c
}

- (void)dealloc;
- init;
- delegate;
- (void)setDelegate:fp8;
- (char)hasChanges;
- (void)setHasChanges:(char)fp8;
- undoManager;
- (void)setUndoManager:fp8;
- (void)setType:(int)fp8;
- (int)type;
- (void)setIsUndeliverable:(char)fp8;
- (char)isUndeliverable;
- (char)sendWindowsFriendlyAttachments;
- (void)setSendWindowsFriendlyAttachments:(char)fp8;
- (void)_configureLastDraftInformationFromHeaders:fp8;
- originalMessage;
- (void)setOriginalMessage:fp8;
- directoryForAttachment:fp8;
- message;
- account;
- deliveryAccount;
- sender;
- (void)setSender:fp8;
- subject;
- (void)setSubject:fp8;
- messageID;
- (void)setShowAllHeaders:(char)fp8;
- (void)setEncodingType:fp8;
- encodingType;
- defaultTextAttributes;
- messageContents;
- messageContentsForInitialText:fp8;
- (void)setMessageContents:fp8;
- _findSignatureInAttributedString:fp8;
- signatureName;
- signature;
- (void)setSignature:fp8;
- (void)addHeaders:fp8;
- addressListForHeader:fp8;
- (void)setAddressList:fp8 forHeader:fp12;
- (void)insertAddress:fp8 forHeader:fp12 atIndex:(unsigned int)fp16;
- (void)removeAddressForHeader:fp8 atIndex:(unsigned int)fp12;
- (char)isAddressHeaderKey:fp8;
- (char)deliverMessage;
- (char)isDeliveringMessage;
- (void)_synchronouslyAppendMessageToOutbox:fp8;
- (void)_backgroundAppendEnded:fp8;
- (void)_backgroundSaveEnded:fp8;
- (char)saveMessage;
- (char)isSavingMessage;
- (void)removeLastDraft;
- lastMessageID;
- (void)setSignIfPossible:(char)fp8;
- (void)setEncryptIfPossible:(char)fp8;
- allRecipients;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)fp8;
- (char)canSign;
- (char)canEncryptForAllRecipients;

@end

@interface ComposeBackEnd(Internal)
- (void)_textStorageChanged:fp8;
- (void)_setupDefaultRecipientsFromOriginalMessage:fp8;
- (void)_saveMessageSynchronously:fp8;
- _allRecipients;
- _recipientsThatHaveNoKeyForEncryption;
- (void)saveRecipients;
- replyAddressForMessage:fp8;
@end

@interface ComposeBackEnd(ScriptingSupport)
+ _messageEditorForComposeBackEnd:fp8 window:(id *)fp12;
- (char)isVisible;
- (void)setIsVisible:(char)fp8;
- appleScriptSender;
- (void)setAppleScriptSender:fp8;
- appleScriptSubject;
- (void)setAppleScriptSubject:fp8;
- content;
- (void)setContent:fp8;
- messageSignature;
- (void)setMessageSignature:fp8;
- (void)_addRecipientsForKey:fp8 toArray:fp12;
- recipients;
- toRecipients;
- ccRecipients;
- bccRecipients;
- (void)insertRecipient:fp8 atIndex:(unsigned int)fp12 inHeaderWithKey:fp16;
- (void)insertInToRecipients:fp8 atIndex:(unsigned int)fp12;
- (void)insertInToRecipients:fp8;
- (void)insertInCcRecipients:fp8 atIndex:(unsigned int)fp12;
- (void)insertInCcRecipients:fp8;
- (void)insertInBccRecipients:fp8 atIndex:(unsigned int)fp12;
- (void)insertInBccRecipients:fp8;
- (void)removeFromToRecipientsAtIndex:(unsigned int)fp8;
- (void)removeFromCcRecipientsAtIndex:(unsigned int)fp8;
- (void)removeFromBccRecipientsAtIndex:(unsigned int)fp8;
- (void)replaceFormattedAddress:fp8 withAddress:fp12 forKey:fp16;
- handleSaveMessageCommand:fp8;
- handleSendMessageCommand:fp8;
- uniqueID;
- objectSpecifier;
- (void)setHtmlContent:fp8;
- (void)setVcardPath:fp8;
@end

#endif
