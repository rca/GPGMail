/* MimeBody.h created by stephane on Wed 05-Jul-2000 */

#import <MessageBody.h>

#ifdef LEOPARD

@class MimePart;

@interface MimeBody : MessageBody
{
    MimePart *_topLevelPart;
    unsigned int _preferredTextEncoding;
    NSData *_bodyData;
    unsigned int _preferredAlternative:16;
    unsigned int _numAlternatives:16;
}

+ (void)initialize;
+ (id)versionString;
+ (id)createMimeBoundary;
- (id)attributedString;
- (id)init;
- (void)dealloc;
- (id)topLevelPart;
- (void)setTopLevelPart:(id)fp8;
- (id)allPartsEnumerator;
- (id)attachmentPartsEnumerator;
- (unsigned long)preferredTextEncoding;
- (void)setPreferredTextEncoding:(unsigned long)fp8;
- (BOOL)isSignedByMe;
- (id)mimeType;
- (id)mimeSubtype;
- (id)partWithNumber:(id)fp8;
- (void)calculateNumberOfAttachmentsIfNeeded;
- (BOOL)_isPossiblySignedOrEncrypted;
- (void)decodeIfNecessary;
- (unsigned int)numberOfAttachmentsSigned:(char *)fp8 encrypted:(char *)fp12;
- (id)attachments;
- (id)attachmentFilenames;
- (BOOL)isHTML;
- (BOOL)isRich;
- (BOOL)isMultipartRelated;
- (BOOL)isTextPlain;
- (int)numberOfAlternatives;
- (void)setPreferredAlternative:(int)fp8;
- (int)preferredAlternative;
- (id)preferredAlternativePart;
- (id)preferredBodyPart;
- (id)textHtmlPart;
- (id)webArchive;
- (id)dataForMimePart:(id)fp8;
- (id)bodyData;
- (void)setBodyData:(id)fp8;
- (void)flushCachedData;

@end

@interface MimeBody (StringRendering)
- (void)renderStringForJunk:(id)fp8;
- (void)renderString:(id)fp8;
@end

#elif defined(TIGER)

@class MimePart;

@interface MimeBody : MessageBody
{
    MimePart *_topLevelPart;
    unsigned int _preferredTextEncoding;
    unsigned int _preferredAlternative:16;
    unsigned int _numAlternatives:16;
}

+ (void)initialize;
+ (id)versionString;
+ (id)createMimeBoundary;
- (id)init;
- (void)dealloc;
- (id)topLevelPart;
- (void)setTopLevelPart:(id)fp8;
- (unsigned long)preferredTextEncoding;
- (void)setPreferredTextEncoding:(unsigned long)fp8;
- (id)mimeType;
- (id)mimeSubtype;
- (id)partWithNumber:(id)fp8;
- (void)calculateNumberOfAttachmentsIfNeeded;
- (id)attachments;
- (BOOL)_isPossiblySignedOrEncrypted;
- (void)calculateNumberOfAttachmentsDecodeIfNeeded;
- (BOOL)isHTML;
- (BOOL)isRich;
- (id)attributedString;
- (id)stringValueForJunkEvaluation:(BOOL)fp8;
- (int)numberOfAlternatives;
- (void)setPreferredAlternative:(int)fp8;
- (int)preferredAlternative;
- (id)preferredBodyPart;
- (id)textHtmlPart;
- (id)webArchive;

@end

#else

@class MimePart;

@interface MimeBody:MessageBody
{
    MimePart *_topLevelPart;	// 12 = 0xc
    unsigned int _preferredTextEncoding;	// 16 = 0x10
    int _shouldDeleteAttachmentOnDealloc:1;	// 20 = 0x14
    int _preferredAlternative:15;	// 20 = 0x14
    int _numAlternatives:16;	// 22 = 0x16
}

+ (void)initialize;
+ versionString;
+ createMimeBoundary;
- init;
- (void)dealloc;
- (char)makeUniqueTemporaryAttachmentInDirectory:fp8;
- topLevelPart;
- (void)setTopLevelPart:fp8;
- (unsigned long)preferredTextEncoding;
- (void)setPreferredTextEncoding:(unsigned long)fp8;
- mimeType;
- mimeSubtype;
- (void)calculateNumberOfAttachmentsIfNeeded;
- attachments;
- (char)isHTML;
- (char)isRich;
- attachmentDirectory;
- attributedString;
- stringForIndexing;
- (int)numberOfAlternatives;
- (void)setPreferredAlternative:(int)fp8;
- (int)preferredAlternative;
- preferredBodyPart;
- textHtmlPart;

@end

#endif
