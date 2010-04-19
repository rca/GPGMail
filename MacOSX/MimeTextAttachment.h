#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

@class MimePart;

@interface MimeTextAttachment : NSTextAttachment
{
    MimePart *_mimePart;
}

+ (id)attachmentWithInternalAppleAttachmentData:(id)arg1 mimeBody:(id)arg2;
- (void)dealloc;
- (id)initWithMimePart:(id)arg1 andFileWrapper:(id)arg2;
- (id)initWithFileWrapper:(id)arg1;
- (id)initWithMimePart:(id)arg1;
- (void)_forceDownloadOfFileWrapperInBackground:(id)arg1;
- (void)forceDownloadOfFileWrapperInBackground;
- (id)fileWrapperForcingDownload;
- (id)fileWrapperForcingDownloadEvenIfExternalBody:(BOOL)arg1;
- (id)mimePart;
- (void)setMimePart:(id)arg1;
- (unsigned long long)approximateSize;
- (BOOL)isPlaceholder;
- (BOOL)hasBeenDownloaded;
- (BOOL)shouldDownloadAttachmentOnDisplay;

@end

#elif defined(SNOW_LEOPARD)

@class MimePart;

@interface MimeTextAttachment : NSTextAttachment
{
    MimePart *_mimePart;
}

+ (id)attachmentWithInternalAppleAttachmentData:(id)arg1 mimeBody:(id)arg2;
- (void)dealloc;
- (id)initWithMimePart:(id)arg1 andFileWrapper:(id)arg2;
- (id)initWithFileWrapper:(id)arg1;
- (id)initWithMimePart:(id)arg1;
- (void)_forceDownloadOfFileWrapperInBackground:(id)arg1;
- (void)forceDownloadOfFileWrapperInBackground;
- (id)fileWrapperForcingDownload;
- (id)fileWrapperForcingDownloadEvenIfExternalBody:(BOOL)arg1;
- (id)mimePart;
- (void)setMimePart:(id)arg1;
- (unsigned int)approximateSize;
- (BOOL)isPlaceholder;
- (BOOL)hasBeenDownloaded;
- (BOOL)shouldDownloadAttachmentOnDisplay;

@end

#elif defined(LEOPARD)

@class MimePart;
@class MimeBody;

@interface MimeTextAttachment : NSTextAttachment
{
    MimeBody *_mimeBody;
    MimePart *_mimePart;
}

+ (id)attachmentWithInternalAppleAttachmentData:(id)fp8 mimeBody:(id)fp12;
- (void)dealloc;
- (void)finalize;
- (id)initWithMimePart:(id)fp8;
- (id)initWithMimePart:(id)fp8 andFileWrapper:(id)fp12;
- (void)_forceDownloadOfFileWrapperInBackground:(id)fp8;
- (void)forceDownloadOfFileWrapperInBackground;
- (id)fileWrapperForcingDownload;
- (id)fileWrapperForcingDownloadEvenIfExternalBody:(BOOL)fp8;
- (id)mimePart;
- (void)setMimePart:(id)fp8;
- (unsigned int)approximateSize;
- (BOOL)isPlaceholder;
- (BOOL)hasBeenDownloaded;
- (BOOL)shouldDownloadAttachmentOnDisplay;

@end

@interface MimeTextAttachment (IndexingSupport)
- (id)stringForIndexing;
@end

@interface MimeTextAttachment (ScriptingSupport)
- (id)appleScriptNameOfAttachment;
- (id)appleScriptMIMEType;
- (void)_loadFileWrapperForCommand:(id)fp8;
- (void)_finishSaveAttachmentCommand:(id)fp8;
- (id)handleSaveAttachmentCommand:(id)fp8;
- (id)appleScriptApproximateSize;
- (id)uniqueID;
- (id)objectSpecifier;
@end

#elif defined(TIGER)

@class MimePart;

@interface MimeTextAttachment : NSTextAttachment
{
    MimePart *_mimePart;
}

+ (id)attachmentWithInternalAppleAttachmentData:(id)fp8 mimeBody:(id)fp12;
- (void)dealloc;
- (void)finalize;
- (id)initWithMimePart:(id)fp8;
- (id)initWithMimePart:(id)fp8 andFileWrapper:(id)fp12;
- (id)mimePart;
- (void)setMimePart:(id)fp8;
- (unsigned int)approximateSize;
- (BOOL)isPlaceholder;
- (BOOL)hasBeenDownloaded;
- (BOOL)shouldDownloadAttachmentOnDisplay;

@end

@interface MimeTextAttachment (IndexingSupport)
- (id)stringForIndexing;
@end

#else

@class MimePart;

@interface MimeTextAttachment:NSTextAttachment
{
    MimePart *_mimePart;	// 16 = 0x10
}

- (void)dealloc;
- initWithMimePart:fp8;
- mimePart;
- (void)setMimePart:fp8;
- (unsigned int)approximateSize;
- (char)isPlaceholder;
- (char)hasBeenDownloaded;
- (char)shouldDownloadAttachmentOnDisplay;

@end

@interface MimeTextAttachment(IndexingSupport)
- stringForIndexing;
@end

#endif
