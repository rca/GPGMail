/* MimeBody.h created by stephane on Wed 05-Jul-2000 */

#import <MessageBody.h>

#ifdef SNOW_LEOPARD_64

@class MimePart;

@interface MimeBody : MessageBody
{
	MimePart *_topLevelPart;
	unsigned int _preferredTextEncoding;
	NSData *_bodyData;
	unsigned int _preferredAlternative : 16;
	unsigned int _numAlternatives : 16;
}

+ (void)initialize;
+ (id)versionString;
+ (id)createMimeBoundary;
- (id)attributedString;
- (id)init;
- (void)dealloc;
- (id)topLevelPart;
- (void)setTopLevelPart:(id)arg1;
- (id)allPartsEnumerator;
- (id)attachmentPartsEnumerator;
- (unsigned int)preferredTextEncoding;
- (void)setPreferredTextEncoding:(unsigned int)arg1;
- (BOOL)isSignedByMe;
- (id)mimeType;
- (id)mimeSubtype;
- (id)partWithNumber:(id)arg1;
- (void)calculateNumberOfAttachmentsIfNeeded;
- (BOOL)_isPossiblySignedOrEncrypted;
- (void)decodeIfNecessary;
- (BOOL)hasAttachments;
- (unsigned int)numberOfAttachmentsSigned:(char *)arg1 encrypted:(char *)arg2 numberOfTNEFAttachments:(unsigned int *)arg3;
- (id)attachments;
- (id)attachmentViewControllers;
- (id)attachmentFilenames;
- (BOOL)isHTML;
- (BOOL)isRich;
- (BOOL)isMultipartRelated;
- (BOOL)isTextPlain;
- (int)numberOfAlternatives;
- (void)setPreferredAlternative:(int)arg1;
- (int)preferredAlternative;
- (id)preferredAlternativePart;
- (id)preferredBodyPart;
- (id)textHtmlPart;
- (id)webArchive;
- (id)parsedMessage;
- (id)dataForMimePart:(id)arg1;
- (id)bodyData;
- (void)setBodyData:(id)arg1;
- (void)flushCachedData;

@end

@interface MimeBody (StringRendering)
- (void)renderStringForJunk:(id)arg1;
- (void)renderString:(id)arg1;
@end

#elif defined(SNOW_LEOPARD)

@class MimePart;

@interface MimeBody : MessageBody
{
	MimePart *_topLevelPart;
	unsigned int _preferredTextEncoding;
	NSData *_bodyData;
	unsigned int _preferredAlternative : 16;
	unsigned int _numAlternatives : 16;
}

+ (void)initialize;
+ (id)versionString;
+ (id)createMimeBoundary;
- (id)attributedString;
- (id)init;
- (void)dealloc;
- (id)topLevelPart;
- (void)setTopLevelPart:(id)arg1;
- (id)allPartsEnumerator;
- (id)attachmentPartsEnumerator;
- (unsigned long)preferredTextEncoding;
- (void)setPreferredTextEncoding:(unsigned long)arg1;
- (BOOL)isSignedByMe;
- (id)mimeType;
- (id)mimeSubtype;
- (id)partWithNumber:(id)arg1;
- (void)calculateNumberOfAttachmentsIfNeeded;
- (BOOL)_isPossiblySignedOrEncrypted;
- (void)decodeIfNecessary;
- (BOOL)hasAttachments;
- (unsigned long)numberOfAttachmentsSigned:(char *)arg1 encrypted:(char *)arg2;
- (id)attachments;
- (id)attachmentViewControllers;
- (id)attachmentFilenames;
- (BOOL)isHTML;
- (BOOL)isRich;
- (BOOL)isMultipartRelated;
- (BOOL)isTextPlain;
- (int)numberOfAlternatives;
- (void)setPreferredAlternative:(int)arg1;
- (int)preferredAlternative;
- (id)preferredAlternativePart;
- (id)preferredBodyPart;
- (id)textHtmlPart;
- (id)webArchive;
- (id)parsedMessage;
- (id)dataForMimePart:(id)arg1;
- (id)bodyData;
- (void)setBodyData:(id)arg1;
- (void)flushCachedData;

@end

@interface MimeBody (StringRendering)
- (void)renderStringForJunk:(id)arg1;
- (void)renderString:(id)arg1;
@end


#endif // ifdef SNOW_LEOPARD_64
