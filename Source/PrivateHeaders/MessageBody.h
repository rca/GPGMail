/* MessageBody.h created by dave on Sun 09-Jan-2000 */

#import <Cocoa/Cocoa.h>

// extern NSString	*MessageBodyWillBeDecodedNotification;
// extern NSString	*MessageBodyWasDecodedNotification;
// extern NSString	*MessageBodyWillBeEncodedNotification;
// extern NSString	*MessageBodyWasEncodedNotification;


/*
 * This class is totally abstract (no instance created).
 * Messages have all MimeBody bodies, sometimes with type/subtype = nil/nil.
 * Newly created messages use a private direct subclass of MessageBody, _OutgoingMessageBody.
 */

#ifdef SNOW_LEOPARD_64

@class Message;

@interface MessageBody : NSObject
{
	BOOL _hideCalendarMimePart;
	Message *_message;
	long long _messageID;
}

- (id)init;
@property Message *message;
- (id)attributedString;
- (BOOL)isHTML;
- (BOOL)isRich;
@property (readonly) BOOL isSignedByMe;
- (void)calculateNumberOfAttachmentsIfNeeded;
- (void)calculateNumberOfAttachmentsDecodeIfNeeded;
- (unsigned int)numberOfAttachmentsSigned:(char *)arg1 encrypted:(char *)arg2 numberOfTNEFAttachments:(unsigned int *)arg3;
- (id)attachments;
- (id)attachmentViewControllers;
- (id)attachmentFilenames;
- (id)textHtmlPart;
- (id)webArchive;
- (void)dealloc;
@property BOOL hideCalendarMimePart; // @synthesize hideCalendarMimePart=_hideCalendarMimePart;
@property Message *actualMessage;  // @synthesize actualMessage=_message;
@property long long messageID; // @synthesize messageID=_messageID;

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

#elif defined(SNOW_LEOPARD)

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


#endif // ifdef SNOW_LEOPARD_64
