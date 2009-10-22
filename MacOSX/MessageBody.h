/* MessageBody.h created by dave on Sun 09-Jan-2000 */

#import <Cocoa/Cocoa.h>

//extern NSString	*MessageBodyWillBeDecodedNotification;
//extern NSString	*MessageBodyWasDecodedNotification;
//extern NSString	*MessageBodyWillBeEncodedNotification;
//extern NSString	*MessageBodyWasEncodedNotification;


/*
 This class is totally abstract (no instance created).
 Messages have all MimeBody bodies, sometimes with type/subtype = nil/nil.
 Newly created messages use a private direct subclass of MessageBody, _OutgoingMessageBody.
 */

#ifdef SNOW_LEOPARD

@class Message;

@interface MessageBody : NSObject
{
    BOOL _hideCalendarMimePart;
    Message *_message;
    long long _messageID;
}

- (id)init;
- (void)setMessage:(id)arg1;
- (id)message;
- (id)attributedString;
- (BOOL)isHTML;
- (BOOL)isRich;
- (BOOL)isSignedByMe;
- (void)calculateNumberOfAttachmentsIfNeeded;
- (void)calculateNumberOfAttachmentsDecodeIfNeeded;
- (unsigned long)numberOfAttachmentsSigned:(char *)arg1 encrypted:(char *)arg2;
- (id)attachments;
- (id)attachmentViewControllers;
- (id)attachmentFilenames;
- (id)textHtmlPart;
- (id)webArchive;
- (void)dealloc;
- (BOOL)hideCalendarMimePart;
- (void)setHideCalendarMimePart:(BOOL)arg1;
- (id)actualMessage;
- (void)setActualMessage:(id)arg1;
- (long long)messageID;
- (void)setMessageID:(long long)arg1;

@end

@interface MessageBody (StringRendering)
- (void)renderString:(id)arg1;
@end

@interface _OutgoingMessageBody : MessageBody
{
    NSMutableData *rawData;
}

- (void)setMessage:(id)arg1;
- (void)clearMessageWithoutReleasing;
- (void)dealloc;
- (id)rawData;
- (void)setRawData:(id)arg1;
- (id)mutableData;

@end

#elif defined(LEOPARD)

@class Message;

@interface MessageBody : NSObject
{
    Message *_message;
    unsigned int _messageID;
    BOOL _isMessageIDValid;
}

- (id)init;
- (void)setMessage:(id)fp8;
- (id)message;
- (id)attributedString;
- (BOOL)isHTML;
- (BOOL)isRich;
- (BOOL)isSignedByMe;
- (void)calculateNumberOfAttachmentsIfNeeded;
- (void)calculateNumberOfAttachmentsDecodeIfNeeded;
- (unsigned int)numberOfAttachmentsSigned:(char *)fp8 encrypted:(char *)fp12;
- (id)attachments;
- (id)attachmentFilenames;
- (id)textHtmlPart;
- (id)webArchive;
- (void)dealloc;
- (BOOL)isMessageIDValid;
- (void)setIsMessageIDValid:(BOOL)fp8;
- (id)actualMessage;
- (void)setActualMessage:(id)fp8;
- (unsigned int)messageID;
- (void)setMessageID:(unsigned int)fp8;

@end

@interface MessageBody (StringRendering)
- (void)renderString:(id)fp8;
@end

@interface _OutgoingMessageBody : MessageBody
{
    NSMutableData *rawData;
}

- (void)setMessage:(id)fp8;
- (void)clearMessageWithoutReleasing;
- (void)dealloc;
- (id)rawData;
- (void)setRawData:(id)fp8;
- (id)mutableData;

@end

#elif defined(TIGER)

@class Message;

@interface MessageBody : NSObject
{
    Message *_message;
}

- (id)rawData;
- (id)attributedString;
- (BOOL)isHTML;
- (BOOL)isRich;
- (id)stringValueForJunkEvaluation:(BOOL)fp8;
- (void)setMessage:(id)fp8;
- (id)message;
- (void)calculateNumberOfAttachmentsIfNeeded;
- (void)calculateNumberOfAttachmentsDecodeIfNeeded;
- (id)attachments;
- (id)textHtmlPart;
- (id)webArchive;
- (void)dealloc;

@end

@interface _OutgoingMessageBody : MessageBody
{
    NSMutableData *rawData;
}

- (void)dealloc;
- (void)finalize;
- (id)mutableData;
- (id)rawData;

@end

#else

@class Message;

@interface MessageBody:NSObject
{
    Message *_message;	// 4 = 0x4
    NSString *_attachPath;	// 8 = 0x8
}

+ defaultAttachmentDirectory;
+ (void)setDefaultAttachmentDirectory:fp8;
- rawData;
- attributedString;
- (char)isHTML;
- (char)isRich;
- (void)dealloc;
- stringForIndexing;
- (void)setMessage:fp8;
- message;
- (void)setAttachmentDirectory:fp8;
- attachmentDirectory;
- (void)calculateNumberOfAttachmentsIfNeeded;
- attachments;
- textHtmlPart;

@end

#endif
