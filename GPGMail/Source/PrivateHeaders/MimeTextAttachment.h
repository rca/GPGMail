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


#endif
