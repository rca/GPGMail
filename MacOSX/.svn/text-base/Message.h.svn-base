/* Message.h created by dave on Mon 20-Sep-1999 */
// File: /System/Library/Frameworks/Message.framework/Versions/B/Message

#import <Cocoa/Cocoa.h>

#ifdef LEOPARD

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
} CDAnonymousStruct5;

@interface Message : NSObject
{
    MessageStore *_store;
    unsigned int _messageFlags;
    CDAnonymousStruct5 _flags;
    unsigned int _preferredEncoding;
    NSString *_senderAddressComment;
    unsigned int _dateSentInterval;
    unsigned int _dateReceivedInterval;
    unsigned int _dateLastViewedInterval;
    NSString *_subject;
    unsigned char _subjectPrefixLength;
    NSString *_to;
    NSString *_sender;
    NSString *_author;
    NSData *_messageIDHeaderDigest;
    NSData *_inReplyToHeaderDigest;
    int _type;
    MFUUID *_documentID;
}

+ (void)initialize;
+ (id)verboseVersion;
+ (id)frameworkVersion;
+ (void)setUserAgent:(id)fp8;
+ (id)userAgent;
+ (id)messageWithRFC822Data:(id)fp8;
+ (id)forwardedMessagePrefixWithSpacer:(BOOL)fp8;
+ (id)replyPrefixWithSpacer:(BOOL)fp8;
+ (id)descriptionForType:(int)fp8 plural:(BOOL)fp12;
+ (id)messageTypeKeyForMessageType:(int)fp8;
+ (int)_messageTypeForMessageTypeKey:(id)fp8;
+ (id)unreadMessagesFromMessages:(id)fp8;
+ (BOOL)allMessages:(id)fp8 areSameType:(int)fp12;
+ (unsigned int)validatePriority:(int)fp8;
+ (unsigned int)displayablePriorityForPriority:(int)fp8;
+ (BOOL)isMessageURL:(id)fp8;
+ (id)messageWithURL:(id)fp8;
+ (id)messageWithPersistentID:(id)fp8;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)fp8;
- (id)messageStore;
- (void)setMessageStore:(id)fp8;
- (BOOL)messageStoreShouldBeSet;
- (id)mailbox;
- (id)headers;
- (id)headersIfAvailable;
- (int)type;
- (void)setType:(int)fp8;
- (BOOL)isEditable;
- (BOOL)isAnnotatable;
- (BOOL)isMetadataMessage;
- (id)documentID;
- (void)setDocumentID:(id)fp8;
- (unsigned long)messageFlags;
- (void)setMessageFlags:(unsigned long)fp8;
- (id)messageBody;
- (id)messageBodyIfAvailable;
- (id)messageBodyUpdatingFlags:(BOOL)fp8;
- (id)messageBodyForIndexingAttachments;
- (id)messageBodyIfAvailableUpdatingFlags:(BOOL)fp8;
- (id)messageDataIncludingFromSpace:(BOOL)fp8;
- (id)messageDataIncludingFromSpace:(BOOL)fp8 newDocumentID:(id)fp12;
- (BOOL)colorHasBeenEvaluated;
- (id)color;
- (BOOL)isMarkedForOverwrite;
- (void)setMarkedForOverwrite:(BOOL)fp8;
- (void)setColor:(id)fp8;
- (void)setColorHasBeenEvaluated:(BOOL)fp8;
- (void)setColor:(id)fp8 hasBeenEvaluated:(BOOL)fp12 flags:(unsigned long)fp16;
- (void)dealloc;
- (void)finalize;
- (unsigned int)messageSize;
- (id)attributedString;
- (id)preferredEmailAddressToReplyWith;
- (id)messageID;
- (id)messageIDHeaderDigest;
- (void)unlockedSetMessageIDHeaderDigest:(id)fp8;
- (void)setMessageIDHeaderDigest:(id)fp8;
- (id)_messageIDHeaderDigestIvar;
- (BOOL)needsMessageIDHeader;
- (id)inReplyToHeaderDigest;
- (void)unlockedSetInReplyToHeaderDigest:(id)fp8;
- (void)setInReplyToHeaderDigest:(id)fp8;
- (id)_inReplyToHeaderDigestIvar;
- (int)compareByNumberWithMessage:(id)fp8;
- (BOOL)isMessageContentsLocallyAvailable;
- (id)stringValueRenderMode:(int)fp8 updateBodyFlags:(BOOL)fp12 junkRecorder:(id)fp16;
- (id)stringForIndexing;
- (id)stringForIndexingUpdatingBodyFlags:(BOOL)fp8;
- (id)stringForJunk;
- (id)stringForJunk:(id)fp8;
- (BOOL)hasCalculatedNumberOfAttachments;
- (unsigned int)numberOfAttachments;
- (int)junkMailLevel;
- (void)setPriorityFromHeaders:(id)fp8;
- (int)priority;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)fp8;
- (id)rawSourceFromHeaders:(id)fp8 body:(id)fp12;
- (BOOL)_doesDateAppearToBeSane:(id)fp8;
- (id)_createDateFromReceivedHeadersInHeaders:(id)fp8;
- (id)_createDateFromHeader:(id)fp8 inHeaders:(id)fp12;
- (id)_createDateFromDateHeaderInHeaders:(id)fp8;
- (id)_createDateFromCreatedDateHeaderInHeaders:(id)fp8;
- (void)_setDateReceivedFromHeaders:(id)fp8;
- (void)_setDateSentFromHeaders:(id)fp8;
- (void)loadCachedHeaderValuesFromHeaders:(id)fp8 type:(int)fp12;
- (id)subjectAndPrefixLength:(unsigned int *)fp8;
- (id)subjectNotIncludingReAndFwdPrefix;
- (id)subjectAddition;
- (id)subject;
- (void)setSubject:(id)fp8;
- (id)dateReceived;
- (id)dateSent;
- (void)setDateReceivedTimeIntervalSince1970:(double)fp8;
- (double)dateReceivedAsTimeIntervalSince1970;
- (BOOL)needsDateReceived;
- (double)dateSentAsTimeIntervalSince1970;
- (void)setDateSentTimeIntervalSince1970:(double)fp8;
- (id)dateLastViewed;
- (double)dateLastViewedAsTimeIntervalSince1970;
- (id)sender;
- (void)setSender:(id)fp8;
- (id)senderAddressComment;
- (id)to;
- (void)setTo:(id)fp8;
- (id)author;
- (void)setAuthor:(id)fp8;
- (void)setMessageInfo:(id)fp8 to:(id)fp12 sender:(id)fp16 type:(int)fp20 dateReceivedTimeIntervalSince1970:(double)fp24 dateSentTimeIntervalSince1970:(double)fp32 messageIDHeaderDigest:(id)fp40 inReplyToHeaderDigest:(id)fp44;
- (void)setMessageInfo:(id)fp8 to:(id)fp12 sender:(id)fp16 type:(int)fp20 dateReceivedTimeIntervalSince1970:(double)fp24 dateSentTimeIntervalSince1970:(double)fp32 messageIDHeaderDigest:(id)fp40 inReplyToHeaderDigest:(id)fp44 dateLastViewedTimeIntervalSince1970:(double)fp48;
- (void)setMessageInfoFromMessage:(id)fp8;
- (id)references;
- (id)note;
- (void)setNote:(id)fp8;
- (id)todos;
- (void)setTodos:(id)fp8;
- (id)remoteID;
- (unsigned long)uid;
- (CDAnonymousStruct5)moreMessageFlags;
- (id)path;
- (id)account;
- (void)markAsViewed;
- (id)remoteMailboxURL;
- (id)originalMailboxURL;
- (id)URL;
- (id)persistentID;
- (id)bodyData;
- (id)headerData;
- (id)dataForMimePart:(id)fp8;
- (BOOL)hasCachedDataForMimePart:(id)fp8;
- (id)matadorAttributes;
- (void)_calculateAttachmentInfoFromBody:(id)fp8;
- (void)forceSetAttachmentInfoFromBody:(id)fp8;
- (void)setAttachmentInfoFromBody:(id)fp8;
- (void)setAttachmentInfoFromBody:(id)fp8 forced:(BOOL)fp12;
- (BOOL)calculateAttachmentInfoFromBody:(id)fp8 numberOfAttachments:(unsigned int *)fp12 isSigned:(char *)fp16 isEncrypted:(char *)fp20;
- (BOOL)calculateAttachmentInfoFromBody:(id)fp8 numberOfAttachments:(unsigned int *)fp12 isSigned:(char *)fp16 isEncrypted:(char *)fp20 force:(BOOL)fp24;
- (void)setNumberOfAttachments:(unsigned int)fp8 isSigned:(BOOL)fp12 isEncrypted:(BOOL)fp16;
- (double)dateCreatedAsTimeIntervalSince1970;
- (double)dateModifiedAsTimeIntervalSince1970;

@end

@interface Message (Threads)
- (BOOL)isThread;
- (BOOL)containsOnlyNotes;
- (BOOL)shouldUseSubjectForThreading;
@end

@interface Message (ScriptingSupport)
- (id)objectSpecifier;
- (void)_setAppleScriptFlag:(id)fp8 state:(BOOL)fp12;
- (BOOL)isRead;
- (void)setIsRead:(BOOL)fp8;
- (BOOL)wasRepliedTo;
- (void)setWasRepliedTo:(BOOL)fp8;
- (BOOL)wasForwarded;
- (void)setWasForwarded:(BOOL)fp8;
- (BOOL)wasRedirected;
- (void)setWasRedirected:(BOOL)fp8;
- (BOOL)isJunk;
- (void)setIsJunk:(BOOL)fp8;
- (BOOL)isDeleted;
- (void)setIsDeleted:(BOOL)fp8;
- (BOOL)isFlagged;
- (void)setIsFlagged:(BOOL)fp8;
- (id)replyTo;
- (id)scriptedMessageSize;
- (id)content;
- (void)_addRecipientsForKey:(id)fp8 toArray:(id)fp12;
- (id)recipients;
- (id)toRecipients;
- (id)ccRecipients;
- (id)bccRecipients;
- (id)container;
- (void)setContainer:(id)fp8;
- (id)messageIDHeader;
- (id)rawSource;
- (id)allHeaders;
- (int)actionColorMessage;
- (void)setBackgroundColor:(int)fp8;
- (int)backgroundColor;
- (id)appleScriptHeaders;
- (id)appleScriptAttachments;
- (id)valueInAppleScriptAttachmentsWithUniqueID:(id)fp8;
@end

@interface Message (LibraryAdditions)
- (id)metadataDictionary;
- (id)metadataPlist;
@end

@interface Message (ParentalControl)
- (BOOL)isParentResponseMessage:(char *)fp8 isRejected:(char *)fp12 requestedAddresses:(id)fp16 requestIsForSenders:(char *)fp20;
- (BOOL)isChildRequestMessage:(id)fp8 requestIsForSenders:(char *)fp12 childAddress:(id *)fp16 permissionRequestState:(int *)fp20;
- (BOOL)isChildRequestMessage;
@end

@interface Message (BackupAdditions)
- (id)backupID;
@end

@interface Message (StringRendering)
- (void)renderHeaders:(id)fp8;
- (void)renderBody:(id)fp8;
- (void)renderString:(id)fp8;
@end

@interface Message (MailViewerAdditions)
- (void)handleOpenAppleEvent:(id)fp8;
- (id)handleReplyToMessage:(id)fp8;
- (id)handleForwardMessage:(id)fp8;
- (id)handleRedirectMessage:(id)fp8;
- (void)handleBounceMessage:(id)fp8;
@end

@interface Message (Chat)
+ (id)chatURLForEmails:(id)fp8;
@end

#elif defined(TIGER)

@class MessageHeaders;
@class MessageStore;

typedef struct {
    unsigned int colorHasBeenEvaluated:1;
    unsigned int colorWasSetManually:1;
    unsigned int redColor:8;
    unsigned int greenColor:8;
    unsigned int blueColor:8;
    unsigned int loadingBody:1;
    unsigned int unused:5;
} CDAnonymousStruct3;

@interface Message : NSObject
{
    MessageStore *_store;
    unsigned int _messageFlags;
    CDAnonymousStruct3 _flags;
    unsigned int _preferredEncoding;
    NSString *_senderAddressComment;
    unsigned int _dateSentInterval;
    unsigned int _dateReceivedInterval;
    unsigned int _dateLastViewedInterval;
    NSString *_subject;
    unsigned char _subjectPrefixLength;
    NSString *_to;
    NSString *_sender;
    NSData *_messageIDHeaderDigest;
    NSData *_inReplyToHeaderDigest;
}

+ (void)initialize;
+ (id)verboseVersion;
+ (id)frameworkVersion;
+ (void)setUserAgent:(id)fp8;
+ (id)userAgent;
+ (id)messageWithRFC822Data:(id)fp8;
+ (id)forwardedMessagePrefixWithSpacer:(BOOL)fp8;
+ (id)replyPrefixWithSpacer:(BOOL)fp8;
+ (unsigned int)validatePriority:(int)fp8;
+ (unsigned int)displayablePriorityForPriority:(int)fp8;
+ (id)messageWithPersistentID:(id)fp8;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)fp8;
- (id)messageStore;
- (void)setMessageStore:(id)fp8;
- (id)mailbox;
- (id)headers;
- (id)headersIfAvailable;
- (unsigned long)messageFlags;
- (void)setMessageFlags:(unsigned long)fp8;
- (id)messageBody;
- (id)messageBodyIfAvailable;
- (id)messageBodyUpdatingFlags:(BOOL)fp8;
- (id)messageBodyIfAvailableUpdatingFlags:(BOOL)fp8;
- (id)messageDataIncludingFromSpace:(BOOL)fp8;
- (BOOL)colorHasBeenEvaluated;
- (id)color;
- (void)setColor:(id)fp8;
- (void)setColorHasBeenEvaluated:(BOOL)fp8;
- (void)setColor:(id)fp8 hasBeenEvaluated:(BOOL)fp12 flags:(unsigned long)fp16;
- (void)dealloc;
- (void)finalize;
- (unsigned int)messageSize;
- (id)attributedString;
- (id)preferredEmailAddressToReplyWith;
- (id)messageID;
- (id)messageIDHeaderDigest;
- (void)unlockedSetMessageIDHeaderDigest:(id)fp8;
- (void)setMessageIDHeaderDigest:(id)fp8;
- (id)_messageIDHeaderDigestIvar;
- (BOOL)needsMessageIDHeader;
- (id)inReplyToHeaderDigest;
- (void)unlockedSetInReplyToHeaderDigest:(id)fp8;
- (void)setInReplyToHeaderDigest:(id)fp8;
- (id)_inReplyToHeaderDigestIvar;
- (int)compareByNumberWithMessage:(id)fp8;
- (BOOL)isMessageContentsLocallyAvailable;
- (id)headersForIndexingIncludingFullNamesAndDomains:(BOOL)fp8;
- (id)headersForIndexing;
- (id)headersForJunk;
- (id)stringForIndexingGettingHeadersIfAvailable:(id *)fp8 forJunk:(BOOL)fp12 updateBodyFlags:(BOOL)fp16;
- (id)stringForIndexingGettingHeadersIfAvailable:(id *)fp8 forJunk:(BOOL)fp12;
- (id)stringForIndexingGettingHeadersIfAvailable:(id *)fp8;
- (id)stringForIndexing;
- (id)stringForIndexingUpdatingBodyFlags:(BOOL)fp8;
- (id)stringForJunk;
- (unsigned int)numberOfAttachments;
- (int)junkMailLevel;
- (void)setPriorityFromHeaders:(id)fp8;
- (int)priority;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)fp8;
- (id)rawSourceFromHeaders:(id)fp8 body:(id)fp12;
- (BOOL)_doesDateAppearToBeSane:(id)fp8;
- (id)_dateFromReceivedHeadersInHeaders:(id)fp8;
- (id)_dateFromDateHeaderInHeaders:(id)fp8;
- (void)_setDateReceivedFromHeaders:(id)fp8;
- (void)_setDateSentFromHeaders:(id)fp8;
- (void)loadCachedHeaderValuesFromHeaders:(id)fp8;
- (id)subjectAndPrefixLength:(unsigned int *)fp8;
- (id)subjectNotIncludingReAndFwdPrefix;
- (id)subject;
- (void)setSubject:(id)fp8;
- (id)dateReceived;
- (id)dateSent;
- (void)setDateReceivedTimeIntervalSince1970:(double)fp8;
- (double)dateReceivedAsTimeIntervalSince1970;
- (BOOL)needsDateReceived;
- (double)dateSentAsTimeIntervalSince1970;
- (void)setDateSentTimeIntervalSince1970:(double)fp8;
- (id)dateLastViewed;
- (double)dateLastViewedAsTimeIntervalSince1970;
- (id)sender;
- (void)setSender:(id)fp8;
- (id)senderAddressComment;
- (id)to;
- (void)setTo:(id)fp8;
- (void)setMessageInfo:(id)fp8 to:(id)fp12 sender:(id)fp16 dateReceivedTimeIntervalSince1970:(double)fp20 dateSentTimeIntervalSince1970:(double)fp28 messageIDHeaderDigest:(id)fp36 inReplyToHeaderDigest:(id)fp40;
- (void)setMessageInfo:(id)fp8 to:(id)fp12 sender:(id)fp16 dateReceivedTimeIntervalSince1970:(double)fp20 dateSentTimeIntervalSince1970:(double)fp28 messageIDHeaderDigest:(id)fp36 inReplyToHeaderDigest:(id)fp40 dateLastViewedTimeIntervalSince1970:(double)fp44;
- (void)setMessageInfoFromMessage:(id)fp8;
- (id)references;
- (id)remoteID;
- (unsigned long)uid;
- (CDAnonymousStruct3)moreMessageFlags;
- (id)path;
- (id)account;
- (void)markAsViewed;
- (id)persistentID;
- (id)bodyData;
- (id)headerData;
- (id)dataForMimePart:(id)fp8;
- (id)matadorAttributes;

@end

@interface Message (Threads)
- (BOOL)isThread;
@end

@interface Message (ScriptingSupport)
- (id)objectSpecifier;
- (void)_setAppleScriptFlag:(id)fp8 state:(BOOL)fp12;
- (BOOL)isRead;
- (void)setIsRead:(BOOL)fp8;
- (BOOL)wasRepliedTo;
- (void)setWasRepliedTo:(BOOL)fp8;
- (BOOL)wasForwarded;
- (void)setWasForwarded:(BOOL)fp8;
- (BOOL)wasRedirected;
- (void)setWasRedirected:(BOOL)fp8;
- (BOOL)isJunk;
- (void)setIsJunk:(BOOL)fp8;
- (BOOL)isDeleted;
- (void)setIsDeleted:(BOOL)fp8;
- (BOOL)isFlagged;
- (void)setIsFlagged:(BOOL)fp8;
- (id)replyTo;
- (id)scriptedMessageSize;
- (id)content;
- (void)_addRecipientsForKey:(id)fp8 toArray:(id)fp12;
- (id)recipients;
- (id)toRecipients;
- (id)ccRecipients;
- (id)bccRecipients;
- (id)container;
- (void)setContainer:(id)fp8;
- (id)messageIDHeader;
- (id)rawSource;
- (id)allHeaders;
- (int)actionColorMessage;
- (void)setBackgroundColor:(int)fp8;
- (id)appleScriptHeaders;
@end

@interface Message (LibraryAdditions)
- (id)metadataDictionary;
- (id)metadataPlist;
- (BOOL)writeToDiskWithLibraryID:(unsigned int)fp8 bodyData:(id)fp12;
@end

@interface Message (ParentalControl)
- (BOOL)isParentResponseMessage:(char *)fp8 isRejected:(char *)fp12 requestedAddresses:(id)fp16 requestIsForSenders:(char *)fp20;
- (BOOL)isChildRequestMessage:(id)fp8 requestIsForSenders:(char *)fp12 permissionRequestState:(int *)fp16;
- (BOOL)isChildRequestMessage;
@end

#else

@class MessageHeaders;
@class MessageStore;

@interface Message:NSObject
{
    MessageStore *_store;	// 4 = 0x4
    unsigned int _messageFlags;	// 8 = 0x8
    struct {
        int colorHasBeenEvaluated:1;
        int colorWasSetManually:1;
        int redColor:8;
        int greenColor:8;
        int blueColor:8;
        int loadingBody:1;
        int unused:5;
    } _flags;	// 12 = 0xc
    unsigned int _preferredEncoding;	// 16 = 0x10
    NSString *_senderAddressComment;	// 20 = 0x14
    unsigned int _dateSentInterval;	// 24 = 0x18
    unsigned int _dateReceivedInterval;	// 28 = 0x1c
    NSString *_subject;	// 32 = 0x20
    unsigned char _subjectPrefixLength;	// 36 = 0x24
    NSString *_to;	// 40 = 0x28
    NSString *_sender;	// 44 = 0x2c
    NSData *_messageIDHeaderDigest;	// 48 = 0x30
    NSData *_inReplyToHeaderDigest;	// 52 = 0x34
}

+ (void)initialize;
+ verboseVersion;
+ frameworkVersion;
+ (void)setUserAgent:fp8;
+ userAgent;
+ messageWithRFC822Data:fp8;
+ _filenameFromSubject:fp8 inDirectory:fp12 ofType:fp16;
+ makeUniqueAttachmentNamed:fp8 inDirectory:fp12;
+ makeUniqueAttachmentNamed:fp8 withExtension:fp12 inDirectory:fp16;
- init;
- copyWithZone:(struct _NSZone *)fp8;
- messageStore;
- (void)setMessageStore:fp8;
- headers;
- (unsigned long)messageFlags;
- (void)setMessageFlags:(unsigned long)fp8;
- messageBody;
- messageBodyIfAvailable;
- messageDataIncludingFromSpace:(char)fp8;
- (char)colorHasBeenEvaluated;
- color;
- (void)setColor:fp8;
- (void)setColorHasBeenEvaluated:(char)fp8;
- (void)dealloc;
- (unsigned int)messageSize;
- attributedString;
- preferredEmailAddressToReplyWith;
- messageID;
- messageIDHeaderDigest;
- (void)unlockedSetMessageIDHeaderDigest:fp8;
- (void)setMessageIDHeaderDigest:fp8;
- _messageIDHeaderDigestIvar;
- (char)needsMessageIDHeader;
- inReplyToHeaderDigest;
- (void)unlockedSetInReplyToHeaderDigest:fp8;
- (void)setInReplyToHeaderDigest:fp8;
- _inReplyToHeaderDigestIvar;
- (int)compareByNumberWithMessage:fp8;
- (char)isMessageContentsLocallyAvailable;
- headersForIndexingIncludingFullNames:(char)fp8;
- headersForIndexing;
- headersForJunk;
- stringForIndexingGettingHeadersIfAvailable:(id *)fp8 forJunk:(char)fp12;
- stringForIndexingGettingHeadersIfAvailable:(id *)fp8;
- stringForIndexing;
- stringForJunk;
- (unsigned int)numberOfAttachments;
- (int)junkMailLevel;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)fp8;
- rawSourceFromHeaders:fp8 body:fp12;
- (char)_doesDateAppearToBeSane:fp8;
- _dateFromReceivedHeadersInHeaders:fp8;
- _dateFromDateHeaderInHeaders:fp8;
- (void)_setDateReceivedFromHeaders:fp8;
- (void)_setDateSentFromHeaders:fp8;
- (void)loadCachedHeaderValuesFromHeaders:fp8;
- subjectAndPrefixLength:(unsigned int *)fp8;
- subjectNotIncludingReAndFwdPrefix;
- subject;
- (void)setSubject:fp8;
- dateReceived;
- dateSent;
- (void)setDateReceivedTimeIntervalSince1970:(double)fp8;
- (double)dateReceivedAsTimeIntervalSince1970;
- (char)needsDateReceived;
- (double)dateSentAsTimeIntervalSince1970;
- (void)setDateSentTimeIntervalSince1970:(double)fp8;
- sender;
- (void)setSender:fp8;
- senderAddressComment;
- to;
- (void)setTo:fp8;
- (void)setMessageInfo:fp8 to:fp12 sender:fp16 dateReceivedTimeIntervalSince1970:(double)fp20 dateSentTimeIntervalSince1970:(double)fp28 messageIDHeaderDigest:fp36 inReplyToHeaderDigest:fp40;
- (void)setMessageInfoFromMessage:fp8;

@end

@interface Message(Threads)
- (char)isThread;
@end

@interface Message(ScriptingSupport)
- objectSpecifier;
- (void)_setAppleScriptFlag:fp8 state:(char)fp12;
- (char)isRead;
- (void)setIsRead:(char)fp8;
- (char)wasRepliedTo;
- (void)setWasRepliedTo:(char)fp8;
- (char)wasForwarded;
- (void)setWasForwarded:(char)fp8;
- (char)wasRedirected;
- (void)setWasRedirected:(char)fp8;
- (char)isJunk;
- (void)setIsJunk:(char)fp8;
- (char)isDeleted;
- (void)setIsDeleted:(char)fp8;
- (char)isFlagged;
- (void)setIsFlagged:(char)fp8;
- replyTo;
- scriptedMessageSize;
- content;
- (void)_addRecipientsForKey:fp8 toArray:fp12;
- recipients;
- toRecipients;
- ccRecipients;
- bccRecipients;
- container;
- (void)setContainer:fp8;
- messageIDHeader;
- rawSource;
- allHeaders;
- (int)actionColorMessage;
- (void)setBackgroundColor:(int)fp8;
- appleScriptHeaders;
@end

@interface Message(MailViewerAdditions)
- (void)handleOpenAppleEvent:fp8;
- handleReplyToMessage:fp8;
- handleForwardMessage:fp8;
- handleRedirectMessage:fp8;
- (void)handleBounceMessage:fp8;
@end

@interface Message(Chat)
+ chatURLForEmails:fp8;
@end

#endif
