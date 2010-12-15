/* Message.h created by dave on Mon 20-Sep-1999 */
// File: /System/Library/Frameworks/Message.framework/Versions/B/Message

/*
 -messageBody, -messageBodyIfAvailable always return a new instance on each invocation!
 */

#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

typedef struct {
    unsigned int colorHasBeenEvaluated:1;
    unsigned int colorWasSetManually:1;
    unsigned int redColor:8;
    unsigned int greenColor:8;
    unsigned int blueColor:8;
    unsigned int loadingBody:1;
    unsigned int firstUnused:2;
    unsigned int isMarkedForOverwrite:1;
    unsigned int unused:2;
} CDStruct_accefccd;

@class MessageStore;
@class MFUUID;

@interface Message : NSObject
{
    long long _mf_retainCount;
    double _dateSentInterval;
    double _dateReceivedInterval;
    double _dateLastViewedInterval;
    MessageStore *_store;
    NSString *_senderAddressComment;
    NSString *_subject;
    NSString *_to;
    NSString *_sender;
    NSString *_author;
    NSData *_messageIDHeaderDigest;
    NSData *_inReplyToHeaderDigest;
    MFUUID *_documentID;
    unsigned int _messageFlags;
    CDStruct_accefccd _flags;
    unsigned int _preferredEncoding;
    BOOL _type;
    unsigned char _subjectPrefixLength;
}

+ (void)initialize;
+ (id)verboseVersion;
+ (id)frameworkVersion;
+ (void)setUserAgent:(id)arg1;
+ (id)userAgent;
+ (id)messageWithRFC822Data:(id)arg1;
+ (id)forwardedMessagePrefixWithSpacer:(BOOL)arg1;
+ (id)replyPrefixWithSpacer:(BOOL)arg1;
+ (id)descriptionForType:(BOOL)arg1 plural:(BOOL)arg2;
+ (id)messageTypeKeyForMessageType:(BOOL)arg1;
+ (BOOL)_messageTypeForMessageTypeKey:(id)arg1;
+ (id)unreadMessagesFromMessages:(id)arg1;
+ (BOOL)allMessages:(id)arg1 areSameType:(BOOL)arg2;
+ (BOOL)colorIsSetInMoreFlags:(CDStruct_accefccd)arg1;
+ (unsigned int)validatePriority:(unsigned int)arg1;
+ (unsigned long long)displayablePriorityForPriority:(unsigned int)arg1;
+ (BOOL)isMessageURL:(id)arg1;
+ (id)messageWithURL:(id)arg1;
+ (id)messagesWithURL:(id)arg1;
+ (id)messageWithPersistentID:(id)arg1;
+ (id)availableMatadorAttributeNames;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)retain;
- (void)release;
- (unsigned long long)retainCount;
- (id)messageStore;
- (void)setMessageStore:(id)arg1;
- (BOOL)messageStoreShouldBeSet;
- (id)mailbox;
- (id)headers;
- (id)headersIfAvailable;
- (BOOL)isKnownToBeNote;
- (BOOL)type;
- (void)setType:(BOOL)arg1;
- (BOOL)isEditable;
- (BOOL)isAnnotatable;
- (BOOL)isMessageMeeting;
- (id)documentID;
- (void)setDocumentID:(id)arg1;
- (unsigned int)messageFlags;
- (void)setMessageFlags:(unsigned int)arg1 mask:(unsigned int)arg2;
- (id)attachmentNamesIfAvailable;
- (id)messageBody;
- (id)messageBodyIfAvailable;
- (id)messageBodyUpdatingFlags:(BOOL)arg1;
- (id)messageBodyForIndexingAttachments;
- (id)messageBodyIfAvailableUpdatingFlags:(BOOL)arg1;
- (id)messageDataIncludingFromSpace:(BOOL)arg1;
- (id)messageDataIncludingFromSpace:(BOOL)arg1 newDocumentID:(id)arg2;
- (BOOL)colorHasBeenEvaluated;
- (id)color;
- (int)colorIntValue;
- (BOOL)isMarkedForOverwrite;
- (void)setMarkedForOverwrite:(BOOL)arg1;
- (void)setColor:(id)arg1;
- (void)setColorHasBeenEvaluated:(BOOL)arg1;
- (void)setColor:(id)arg1 hasBeenEvaluated:(BOOL)arg2 flags:(unsigned int)arg3 mask:(unsigned int)arg4;
- (void)dealloc;
- (void)finalize;
- (unsigned long long)messageSize;
- (id)attributedString;
- (id)preferredEmailAddressToReplyWith;
- (id)messageID;
- (id)messageIDHeaderDigest;
- (void)unlockedSetMessageIDHeaderDigest:(id)arg1;
- (void)setMessageIDHeaderDigest:(id)arg1;
- (id)_messageIDHeaderDigestIvar;
- (id)inReplyToHeaderDigest;
- (void)unlockedSetInReplyToHeaderDigest:(id)arg1;
- (void)setInReplyToHeaderDigest:(id)arg1;
- (id)_inReplyToHeaderDigestIvar;
- (long long)compareByNumberWithMessage:(id)arg1;
- (BOOL)isMessageContentsLocallyAvailable;
- (id)stringValueRenderMode:(int)arg1 updateBodyFlags:(BOOL)arg2 junkRecorder:(id)arg3;
- (id)stringForIndexing;
- (id)stringForIndexingUpdatingBodyFlags:(BOOL)arg1;
- (id)stringForJunk;
- (id)stringForJunk:(id)arg1;
- (BOOL)hasCalculatedNumberOfAttachments;
- (unsigned long long)numberOfAttachments;
- (int)junkMailLevel;
- (void)setPriorityFromHeaders:(id)arg1;
- (int)priority;
- (unsigned int)preferredEncoding;
- (void)setPreferredEncoding:(unsigned int)arg1;
- (id)rawSourceFromHeaders:(id)arg1 body:(id)arg2;
- (BOOL)_doesDateAppearToBeSane:(id)arg1;
- (id)_createDateFromReceivedHeadersInHeaders:(id)arg1;
- (id)_createDateFromHeader:(id)arg1 inHeaders:(id)arg2;
- (id)_createDateFromDateHeaderInHeaders:(id)arg1;
- (id)_createDateFromCreatedDateHeaderInHeaders:(id)arg1;
- (void)_setDateReceivedFromHeaders:(id)arg1;
- (void)_setDateSentFromHeaders:(id)arg1;
- (void)loadCachedHeaderValuesFromHeaders:(id)arg1 type:(BOOL)arg2;
- (id)subjectAndPrefixLength:(unsigned long long *)arg1;
- (id)subjectNotIncludingReAndFwdPrefix;
- (id)subjectAddition;
- (id)subject;
- (void)setSubject:(id)arg1;
- (id)dateReceived;
- (id)dateSent;
- (void)setDateReceivedTimeIntervalSince1970:(double)arg1;
- (double)dateReceivedAsTimeIntervalSince1970;
- (double)dateSentAsTimeIntervalSince1970;
- (void)setDateSentTimeIntervalSince1970:(double)arg1;
- (id)dateLastViewed;
- (double)dateLastViewedAsTimeIntervalSince1970;
- (id)sender;
- (void)setSender:(id)arg1;
- (id)senderAddressComment;
- (id)to;
- (void)setTo:(id)arg1;
- (id)author;
- (void)setAuthor:(id)arg1;
- (void)setMessageInfo:(id)arg1 to:(id)arg2 sender:(id)arg3 type:(BOOL)arg4 dateReceivedTimeIntervalSince1970:(double)arg5 dateSentTimeIntervalSince1970:(double)arg6 messageIDHeaderDigest:(id)arg7 inReplyToHeaderDigest:(id)arg8;
- (void)setMessageInfo:(id)arg1 to:(id)arg2 sender:(id)arg3 type:(BOOL)arg4 dateReceivedTimeIntervalSince1970:(double)arg5 dateSentTimeIntervalSince1970:(double)arg6 messageIDHeaderDigest:(id)arg7 inReplyToHeaderDigest:(id)arg8 dateLastViewedTimeIntervalSince1970:(double)arg9;
- (void)setMessageInfoFromMessage:(id)arg1;
- (id)references;
@property(retain) Message *note;
@property(retain) NSArray *todos;
- (void)invalidateTodos;
- (id)remoteID;
- (unsigned int)uid;
- (CDStruct_accefccd)moreMessageFlags;
- (id)path;
- (id)account;
- (void)markAsViewed;
- (id)remoteMailboxURL;
- (id)originalMailboxURL;
- (id)_URLFetchIfNotAvailable:(BOOL)arg1;
- (id)URL;
- (id)URLIfAvailable;
- (id)persistentID;
- (id)bodyData;
- (id)headerData;
- (id)dataForMimePart:(id)arg1;
- (BOOL)hasCachedDataForMimePart:(id)arg1;
- (id)matadorAttributes;
- (void)_calculateAttachmentInfoFromBody:(id)arg1;
- (void)forceSetAttachmentInfoFromBody:(id)arg1;
- (void)setAttachmentInfoFromBody:(id)arg1;
- (void)setAttachmentInfoFromBody:(id)arg1 forced:(BOOL)arg2;
- (BOOL)calculateAttachmentInfoFromBody:(id)arg1 numberOfAttachments:(unsigned int *)arg2 isSigned:(char *)arg3 isEncrypted:(char *)arg4;
- (BOOL)calculateAttachmentInfoFromBody:(id)arg1 numberOfAttachments:(unsigned int *)arg2 isSigned:(char *)arg3 isEncrypted:(char *)arg4 force:(BOOL)arg5;
- (void)setNumberOfAttachments:(unsigned int)arg1 isSigned:(BOOL)arg2 isEncrypted:(BOOL)arg3;
@property BOOL messageTypeInternal; // @synthesize messageTypeInternal=_type;

@end

@interface Message (BackupAdditions)
- (id)backupID;
@end

@interface Message (LibraryAdditions)
- (id)metadataDictionary;
@end

@interface Message (ParentalControl)
- (BOOL)isParentResponseMessage:(char *)arg1 isRejected:(char *)arg2 requestedAddresses:(id)arg3 requestIsForSenders:(char *)arg4;
- (BOOL)isChildRequestMessage:(id)arg1 requestIsForSenders:(char *)arg2 childAddress:(id *)arg3 permissionRequestState:(int *)arg4;
- (BOOL)isChildRequestMessage;
@end

@interface Message (ScriptingSupport)
- (id)objectSpecifier;
- (void)_setAppleScriptFlag:(id)arg1 state:(BOOL)arg2;
- (BOOL)isRead;
- (void)setIsRead:(BOOL)arg1;
- (BOOL)wasRepliedTo;
- (void)setWasRepliedTo:(BOOL)arg1;
- (BOOL)wasForwarded;
- (void)setWasForwarded:(BOOL)arg1;
- (BOOL)wasRedirected;
- (void)setWasRedirected:(BOOL)arg1;
- (BOOL)isJunk;
- (void)setIsJunk:(BOOL)arg1;
- (BOOL)isDeleted;
- (void)setIsDeleted:(BOOL)arg1;
- (BOOL)isFlagged;
- (void)setIsFlagged:(BOOL)arg1;
- (id)replyTo;
- (id)scriptedMessageSize;
- (id)content;
- (void)_addRecipientsForKey:(id)arg1 toArray:(id)arg2;
- (id)recipients;
- (id)toRecipients;
- (id)ccRecipients;
- (id)bccRecipients;
- (id)container;
- (void)_performBackgroundSetContainer:(id)arg1 command:(id)arg2;
- (void)setContainer:(id)arg1;
- (id)messageIDHeader;
- (id)rawSource;
- (id)allHeaders;
- (int)actionColorMessage;
- (void)setBackgroundColor:(int)arg1;
- (int)backgroundColor;
- (id)appleScriptHeaders;
- (id)appleScriptAttachments;
- (id)valueInAppleScriptAttachmentsWithUniqueID:(id)arg1;
@end

@interface Message (StringRendering)
- (void)renderHeaders:(id)arg1;
- (void)renderBody:(id)arg1;
- (void)renderString:(id)arg1;
@end

@interface Message (Threads)
@property(readonly) BOOL isThread;
@property(readonly) BOOL containsOnlyNotes;
@property(readonly) BOOL shouldUseSubjectForThreading;
@end

#elif defined(SNOW_LEOPARD)

@class MessageStore;
@class MFUUID;

typedef struct {
    unsigned int colorHasBeenEvaluated:1;
    unsigned int colorWasSetManually:1;
    unsigned int redColor:8;
    unsigned int greenColor:8;
    unsigned int blueColor:8;
    unsigned int loadingBody:1;
    unsigned int firstUnused:2;
    unsigned int isMarkedForOverwrite:1;
    unsigned int unused:2;
} CDStruct_accefccd;

@interface Message : NSObject
{
    int _mf_retainCount;
    double _dateSentInterval;
    double _dateReceivedInterval;
    double _dateLastViewedInterval;
    MessageStore *_store;
    NSString *_senderAddressComment;
    NSString *_subject;
    NSString *_to;
    NSString *_sender;
    NSString *_author;
    NSData *_messageIDHeaderDigest;
    NSData *_inReplyToHeaderDigest;
    MFUUID *_documentID;
    unsigned int _messageFlags;
    CDStruct_accefccd _flags;
    unsigned int _preferredEncoding;
    BOOL _type;
    unsigned char _subjectPrefixLength;
}

+ (void)initialize;
+ (id)verboseVersion;
+ (id)frameworkVersion;
+ (void)setUserAgent:(id)arg1;
+ (id)userAgent;
+ (id)messageWithRFC822Data:(id)arg1;
+ (id)forwardedMessagePrefixWithSpacer:(BOOL)arg1;
+ (id)replyPrefixWithSpacer:(BOOL)arg1;
+ (id)descriptionForType:(BOOL)arg1 plural:(BOOL)arg2;
+ (id)messageTypeKeyForMessageType:(BOOL)arg1;
+ (BOOL)_messageTypeForMessageTypeKey:(id)arg1;
+ (id)unreadMessagesFromMessages:(id)arg1;
+ (BOOL)allMessages:(id)arg1 areSameType:(BOOL)arg2;
+ (BOOL)colorIsSetInMoreFlags:(CDStruct_accefccd)arg1;
+ (unsigned long)validatePriority:(unsigned long)arg1;
+ (unsigned int)displayablePriorityForPriority:(unsigned long)arg1;
+ (BOOL)isMessageURL:(id)arg1;
+ (id)messageWithURL:(id)arg1;
+ (id)messagesWithURL:(id)arg1;
+ (id)messageWithPersistentID:(id)arg1;
+ (id)availableMatadorAttributeNames;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)retain;
- (void)release;
- (unsigned int)retainCount;
- (id)messageStore;
- (void)setMessageStore:(id)arg1;
- (BOOL)messageStoreShouldBeSet;
- (id)mailbox;
- (id)headers;
- (id)headersIfAvailable;
- (BOOL)isKnownToBeNote;
- (BOOL)type;
- (void)setType:(BOOL)arg1;
- (BOOL)isEditable;
- (BOOL)isAnnotatable;
- (BOOL)isMessageMeeting;
- (id)documentID;
- (void)setDocumentID:(id)arg1;
- (unsigned long)messageFlags;
- (void)setMessageFlags:(unsigned long)arg1 mask:(unsigned long)arg2;
- (id)attachmentNamesIfAvailable;
- (id)messageBody;
- (id)messageBodyIfAvailable;
- (id)messageBodyUpdatingFlags:(BOOL)arg1;
- (id)messageBodyForIndexingAttachments;
- (id)messageBodyIfAvailableUpdatingFlags:(BOOL)arg1;
- (id)messageDataIncludingFromSpace:(BOOL)arg1;
- (id)messageDataIncludingFromSpace:(BOOL)arg1 newDocumentID:(id)arg2;
- (BOOL)colorHasBeenEvaluated;
- (id)color;
- (int)colorIntValue;
- (BOOL)isMarkedForOverwrite;
- (void)setMarkedForOverwrite:(BOOL)arg1;
- (void)setColor:(id)arg1;
- (void)setColorHasBeenEvaluated:(BOOL)arg1;
- (void)setColor:(id)arg1 hasBeenEvaluated:(BOOL)arg2 flags:(unsigned long)arg3 mask:(unsigned long)arg4;
- (void)dealloc;
- (void)finalize;
- (unsigned int)messageSize;
- (id)attributedString;
- (id)preferredEmailAddressToReplyWith;
- (id)messageID;
- (id)messageIDHeaderDigest;
- (void)unlockedSetMessageIDHeaderDigest:(id)arg1;
- (void)setMessageIDHeaderDigest:(id)arg1;
- (id)_messageIDHeaderDigestIvar;
- (id)inReplyToHeaderDigest;
- (void)unlockedSetInReplyToHeaderDigest:(id)arg1;
- (void)setInReplyToHeaderDigest:(id)arg1;
- (id)_inReplyToHeaderDigestIvar;
- (int)compareByNumberWithMessage:(id)arg1;
- (BOOL)isMessageContentsLocallyAvailable;
- (id)stringValueRenderMode:(int)arg1 updateBodyFlags:(BOOL)arg2 junkRecorder:(id)arg3;
- (id)stringForIndexing;
- (id)stringForIndexingUpdatingBodyFlags:(BOOL)arg1;
- (id)stringForJunk;
- (id)stringForJunk:(id)arg1;
- (BOOL)hasCalculatedNumberOfAttachments;
- (unsigned int)numberOfAttachments;
- (int)junkMailLevel;
- (void)setPriorityFromHeaders:(id)arg1;
- (int)priority;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)arg1;
- (id)rawSourceFromHeaders:(id)arg1 body:(id)arg2;
- (BOOL)_doesDateAppearToBeSane:(id)arg1;
- (id)_createDateFromReceivedHeadersInHeaders:(id)arg1;
- (id)_createDateFromHeader:(id)arg1 inHeaders:(id)arg2;
- (id)_createDateFromDateHeaderInHeaders:(id)arg1;
- (id)_createDateFromCreatedDateHeaderInHeaders:(id)arg1;
- (void)_setDateReceivedFromHeaders:(id)arg1;
- (void)_setDateSentFromHeaders:(id)arg1;
- (void)loadCachedHeaderValuesFromHeaders:(id)arg1 type:(BOOL)arg2;
- (id)subjectAndPrefixLength:(unsigned int *)arg1;
- (id)subjectNotIncludingReAndFwdPrefix;
- (id)subjectAddition;
- (id)subject;
- (void)setSubject:(id)arg1;
- (id)dateReceived;
- (id)dateSent;
- (void)setDateReceivedTimeIntervalSince1970:(double)arg1;
- (double)dateReceivedAsTimeIntervalSince1970;
- (double)dateSentAsTimeIntervalSince1970;
- (void)setDateSentTimeIntervalSince1970:(double)arg1;
- (id)dateLastViewed;
- (double)dateLastViewedAsTimeIntervalSince1970;
- (id)sender;
- (void)setSender:(id)arg1;
- (id)senderAddressComment;
- (id)to;
- (void)setTo:(id)arg1;
- (id)author;
- (void)setAuthor:(id)arg1;
- (void)setMessageInfo:(id)arg1 to:(id)arg2 sender:(id)arg3 type:(BOOL)arg4 dateReceivedTimeIntervalSince1970:(double)arg5 dateSentTimeIntervalSince1970:(double)arg6 messageIDHeaderDigest:(id)arg7 inReplyToHeaderDigest:(id)arg8;
- (void)setMessageInfo:(id)arg1 to:(id)arg2 sender:(id)arg3 type:(BOOL)arg4 dateReceivedTimeIntervalSince1970:(double)arg5 dateSentTimeIntervalSince1970:(double)arg6 messageIDHeaderDigest:(id)arg7 inReplyToHeaderDigest:(id)arg8 dateLastViewedTimeIntervalSince1970:(double)arg9;
- (void)setMessageInfoFromMessage:(id)arg1;
- (id)references;
- (id)note;
- (void)setNote:(id)arg1;
- (id)todos;
- (void)setTodos:(id)arg1;
- (void)invalidateTodos;
- (id)remoteID;
- (unsigned long)uid;
- (CDStruct_accefccd)moreMessageFlags;
- (id)path;
- (id)account;
- (void)markAsViewed;
- (id)remoteMailboxURL;
- (id)originalMailboxURL;
- (id)_URLFetchIfNotAvailable:(BOOL)arg1;
- (id)URL;
- (id)URLIfAvailable;
- (id)persistentID;
- (id)bodyData;
- (id)headerData;
- (id)dataForMimePart:(id)arg1;
- (BOOL)hasCachedDataForMimePart:(id)arg1;
- (id)matadorAttributes;
- (void)_calculateAttachmentInfoFromBody:(id)arg1;
- (void)forceSetAttachmentInfoFromBody:(id)arg1;
- (void)setAttachmentInfoFromBody:(id)arg1;
- (void)setAttachmentInfoFromBody:(id)arg1 forced:(BOOL)arg2;
- (BOOL)calculateAttachmentInfoFromBody:(id)arg1 numberOfAttachments:(unsigned int *)arg2 isSigned:(char *)arg3 isEncrypted:(char *)arg4;
- (BOOL)calculateAttachmentInfoFromBody:(id)arg1 numberOfAttachments:(unsigned int *)arg2 isSigned:(char *)arg3 isEncrypted:(char *)arg4 force:(BOOL)arg5;
- (void)setNumberOfAttachments:(unsigned long)arg1 isSigned:(BOOL)arg2 isEncrypted:(BOOL)arg3;
- (BOOL)messageTypeInternal;
- (void)setMessageTypeInternal:(BOOL)arg1;

@end

@interface Message (BackupAdditions)
- (id)backupID;
@end

@interface Message (LibraryAdditions)
- (id)metadataDictionary;
@end

@interface Message (ScriptingSupport)
- (id)objectSpecifier;
- (void)_setAppleScriptFlag:(id)arg1 state:(BOOL)arg2;
- (BOOL)isRead;
- (void)setIsRead:(BOOL)arg1;
- (BOOL)wasRepliedTo;
- (void)setWasRepliedTo:(BOOL)arg1;
- (BOOL)wasForwarded;
- (void)setWasForwarded:(BOOL)arg1;
- (BOOL)wasRedirected;
- (void)setWasRedirected:(BOOL)arg1;
- (BOOL)isJunk;
- (void)setIsJunk:(BOOL)arg1;
- (BOOL)isDeleted;
- (void)setIsDeleted:(BOOL)arg1;
- (BOOL)isFlagged;
- (void)setIsFlagged:(BOOL)arg1;
- (id)replyTo;
- (id)scriptedMessageSize;
- (id)content;
- (void)_addRecipientsForKey:(id)arg1 toArray:(id)arg2;
- (id)recipients;
- (id)toRecipients;
- (id)ccRecipients;
- (id)bccRecipients;
- (id)container;
- (void)_performBackgroundSetContainer:(id)arg1 command:(id)arg2;
- (void)setContainer:(id)arg1;
- (id)messageIDHeader;
- (id)rawSource;
- (id)allHeaders;
- (int)actionColorMessage;
- (void)setBackgroundColor:(int)arg1;
- (int)backgroundColor;
- (id)appleScriptHeaders;
- (id)appleScriptAttachments;
- (id)valueInAppleScriptAttachmentsWithUniqueID:(id)arg1;
@end

@interface Message (StringRendering)
- (void)renderHeaders:(id)arg1;
- (void)renderBody:(id)arg1;
- (void)renderString:(id)arg1;
@end

@interface Message (Threads)
- (BOOL)isThread;
- (BOOL)containsOnlyNotes;
- (BOOL)shouldUseSubjectForThreading;
@end

@interface Message (ParentalControl)
- (BOOL)isParentResponseMessage:(char *)arg1 isRejected:(char *)arg2 requestedAddresses:(id)arg3 requestIsForSenders:(char *)arg4;
- (BOOL)isChildRequestMessage:(id)arg1 requestIsForSenders:(char *)arg2 childAddress:(id *)arg3 permissionRequestState:(int *)arg4;
- (BOOL)isChildRequestMessage;
@end

@interface Message (Chat)
+ (id)chatURLForEmails:(id)arg1;
@end

@interface Message (MailViewerAdditions)
- (void)handleOpenAppleEvent:(id)arg1;
- (id)handleReplyToMessage:(id)arg1;
- (id)handleForwardMessage:(id)arg1;
- (id)handleRedirectMessage:(id)arg1;
- (void)handleBounceMessage:(id)arg1;
@end

#endif
