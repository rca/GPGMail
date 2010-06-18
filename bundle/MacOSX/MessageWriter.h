#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

@interface MessageWriter : NSObject
{
    unsigned int _createsMimeAlternatives:1;
    unsigned int _createsRichText:1;
    unsigned int _createsPlainTextOnly:1;
    unsigned int _allows8BitMimeParts:1;
    unsigned int _allowsBinaryMimeParts:1;
    unsigned int _allowsAppleDoubleAttachments:1;
    unsigned int _signsOutput:1;
    unsigned int _encryptsOutput:1;
    unsigned int _shouldConvertCompositeImages:1;
    BOOL _shouldMarkNonresizableAttachmentData;
    unsigned int _preferredEncoding;
    unsigned int _encodingHint;
}

+ (id)domainHintForResentIDFromHeaders:(id)arg1 hasResentFromHeaders:(char *)arg2;
- (id)init;
- (id)createDataForAttributedString:(id)arg1;
- (void)appendDataForMimePart:(id)arg1 toData:(id)arg2 withPartData:(id)arg3;
- (id)createBounceMessageForMessage:(id)arg1;
- (id)createMessageByRemovingAttachmentsFromMessage:(id)arg1;
- (id)createMessageWithAttributedString:(id)arg1 headers:(id)arg2;
- (id)createMessageWithHtmlString:(id)arg1 plainTextAlternative:(id)arg2 otherHtmlStringsAndAttachments:(id)arg3 headers:(id)arg4;
- (id)createMessageWithHtmlString:(id)arg1 attachments:(id)arg2 headers:(id)arg3;
- (id)createMessageWithBodyData:(id)arg1 headers:(id)arg2;
- (BOOL)createsMimeAlternatives;
- (void)setCreatesMimeAlternatives:(BOOL)arg1;
- (BOOL)createsPlainTextOnly;
- (void)setCreatesPlainTextOnly:(BOOL)arg1;
- (BOOL)createsRichText;
- (void)setCreatesRichText:(BOOL)arg1;
- (BOOL)allows8BitMimeParts;
- (void)setAllows8BitMimeParts:(BOOL)arg1;
- (BOOL)allowsBinaryMimeParts;
- (void)setAllowsBinaryMimeParts:(BOOL)arg1;
- (BOOL)allowsAppleDoubleAttachments;
- (void)setAllowsAppleDoubleAttachments:(BOOL)arg1;
- (unsigned int)preferredEncoding;
- (void)setPreferredEncoding:(unsigned int)arg1;
- (unsigned int)encodingHint;
- (void)setEncodingHint:(unsigned int)arg1;
- (unsigned int)_preferredEncodingUsingHintIfNecessary;
- (BOOL)signsOutput;
- (void)setSignsOutput:(BOOL)arg1;
- (BOOL)encryptsOutput;
- (void)setEncryptsOutput:(BOOL)arg1;
- (void)setShouldConvertCompositeImages:(BOOL)arg1;
- (void)setShouldMarkNonresizableAttachmentData:(BOOL)arg1;

@end

#elif defined(SNOW_LEOPARD)

@interface MessageWriter : NSObject
{
    unsigned int _createsMimeAlternatives:1;
    unsigned int _createsRichText:1;
    unsigned int _createsPlainTextOnly:1;
    unsigned int _allows8BitMimeParts:1;
    unsigned int _allowsBinaryMimeParts:1;
    unsigned int _allowsAppleDoubleAttachments:1;
    unsigned int _signsOutput:1;
    unsigned int _encryptsOutput:1;
    unsigned int _shouldConvertCompositeImages:1;
    BOOL _shouldMarkNonresizableAttachmentData;
    unsigned int _preferredEncoding;
    unsigned int _encodingHint;
}

+ (id)domainHintForResentIDFromHeaders:(id)arg1 hasResentFromHeaders:(char *)arg2;
- (id)init;
- (id)createDataForAttributedString:(id)arg1;
- (void)appendDataForMimePart:(id)arg1 toData:(id)arg2 withPartData:(id)arg3;
- (id)createBounceMessageForMessage:(id)arg1;
- (id)createMessageByRemovingAttachmentsFromMessage:(id)arg1;
- (id)createMessageWithAttributedString:(id)arg1 headers:(id)arg2;
- (id)createMessageWithHtmlString:(id)arg1 plainTextAlternative:(id)arg2 otherHtmlStringsAndAttachments:(id)arg3 headers:(id)arg4;
- (id)createMessageWithHtmlString:(id)arg1 attachments:(id)arg2 headers:(id)arg3;
- (id)createMessageWithBodyData:(id)arg1 headers:(id)arg2;
- (BOOL)createsMimeAlternatives;
- (void)setCreatesMimeAlternatives:(BOOL)arg1;
- (BOOL)createsPlainTextOnly;
- (void)setCreatesPlainTextOnly:(BOOL)arg1;
- (BOOL)createsRichText;
- (void)setCreatesRichText:(BOOL)arg1;
- (BOOL)allows8BitMimeParts;
- (void)setAllows8BitMimeParts:(BOOL)arg1;
- (BOOL)allowsBinaryMimeParts;
- (void)setAllowsBinaryMimeParts:(BOOL)arg1;
- (BOOL)allowsAppleDoubleAttachments;
- (void)setAllowsAppleDoubleAttachments:(BOOL)arg1;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)arg1;
- (unsigned long)encodingHint;
- (void)setEncodingHint:(unsigned long)arg1;
- (unsigned long)_preferredEncodingUsingHintIfNecessary;
- (BOOL)signsOutput;
- (void)setSignsOutput:(BOOL)arg1;
- (BOOL)encryptsOutput;
- (void)setEncryptsOutput:(BOOL)arg1;
- (void)setShouldConvertCompositeImages:(BOOL)arg1;
- (void)setShouldMarkNonresizableAttachmentData:(BOOL)arg1;

@end

#elif defined(LEOPARD)

@interface MessageWriter : NSObject
{
    unsigned int _createsMimeAlternatives:1;
    unsigned int _createsRichText:1;
    unsigned int _createsPlainTextOnly:1;
    unsigned int _allows8BitMimeParts:1;
    unsigned int _allowsBinaryMimeParts:1;
    unsigned int _allowsAppleDoubleAttachments:1;
    unsigned int _signsOutput:1;
    unsigned int _encryptsOutput:1;
    unsigned int _writeImageSize:1;
    unsigned int _shouldConvertCompositeImages:1;
    BOOL _shouldMarkNonresizableAttachmentData;
    unsigned int _preferredEncoding;
    unsigned int _encodingHint;
}

- (id)init;
- (id)createDataForAttributedString:(id)fp8;
- (void)appendDataForMimePart:(id)fp8 toData:(id)fp12 withPartData:(id)fp16;
- (id)createBounceMessageForMessage:(id)fp8;
- (id)createMessageByRemovingAttachmentsFromMessage:(id)fp8;
- (id)createMessageWithAttributedString:(id)fp8 headers:(id)fp12;
- (id)createMessageWithHtmlString:(id)fp8 plainTextAlternative:(id)fp12 otherHtmlStringsAndAttachments:(id)fp16 headers:(id)fp20;
- (id)createMessageWithHtmlString:(id)fp8 attachments:(id)fp12 headers:(id)fp16;
- (id)createMessageWithBodyData:(id)fp8 headers:(id)fp12;
- (BOOL)createsMimeAlternatives;
- (void)setCreatesMimeAlternatives:(BOOL)fp8;
- (BOOL)createsPlainTextOnly;
- (void)setCreatesPlainTextOnly:(BOOL)fp8;
- (BOOL)createsRichText;
- (void)setCreatesRichText:(BOOL)fp8;
- (BOOL)allows8BitMimeParts;
- (void)setAllows8BitMimeParts:(BOOL)fp8;
- (BOOL)allowsBinaryMimeParts;
- (void)setAllowsBinaryMimeParts:(BOOL)fp8;
- (BOOL)allowsAppleDoubleAttachments;
- (void)setAllowsAppleDoubleAttachments:(BOOL)fp8;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)fp8;
- (unsigned long)encodingHint;
- (void)setEncodingHint:(unsigned long)fp8;
- (unsigned long)_preferredEncodingUsingHintIfNecessary;
- (BOOL)signsOutput;
- (void)setSignsOutput:(BOOL)fp8;
- (BOOL)encryptsOutput;
- (void)setEncryptsOutput:(BOOL)fp8;
- (BOOL)writeImageSize;
- (void)setWriteImageSize:(BOOL)fp8;
- (void)setShouldConvertCompositeImages:(BOOL)fp8;
- (void)setShouldMarkNonresizableAttachmentData:(BOOL)fp8;

@end

#elif defined(TIGER)

@interface MessageWriter : NSObject
{
    unsigned int _createsMimeAlternatives:1;
    unsigned int _createsRichText:1;
    unsigned int _createsPlainTextOnly:1;
    unsigned int _allows8BitMimeParts:1;
    unsigned int _allowsBinaryMimeParts:1;
    unsigned int _allowsAppleDoubleAttachments:1;
    unsigned int _signsOutput:1;
    unsigned int _encryptsOutput:1;
    unsigned int _writeImageSize:1;
    unsigned int _preferredEncoding;
}

- (id)init;
- (id)createDataForAttributedString:(id)fp8;
- (void)appendDataForMimePart:(id)fp8 toData:(id)fp12 withPartData:(id)fp16;
- (id)createBounceMessageForMessage:(id)fp8;
- (id)createMessageByRemovingAttachmentsFromMessage:(id)fp8;
- (id)createMessageWithAttributedString:(id)fp8 headers:(id)fp12;
- (id)createMessageWithHtmlString:(id)fp8 plainTextAlternative:(id)fp12 otherHtmlStringsAndAttachments:(id)fp16 headers:(id)fp20;
- (id)createMessageWithHtmlString:(id)fp8 attachments:(id)fp12 headers:(id)fp16;
- (id)createMessageWithBodyData:(id)fp8 headers:(id)fp12;
- (BOOL)createsMimeAlternatives;
- (void)setCreatesMimeAlternatives:(BOOL)fp8;
- (BOOL)createsPlainTextOnly;
- (void)setCreatesPlainTextOnly:(BOOL)fp8;
- (BOOL)createsRichText;
- (void)setCreatesRichText:(BOOL)fp8;
- (BOOL)allows8BitMimeParts;
- (void)setAllows8BitMimeParts:(BOOL)fp8;
- (BOOL)allowsBinaryMimeParts;
- (void)setAllowsBinaryMimeParts:(BOOL)fp8;
- (BOOL)allowsAppleDoubleAttachments;
- (void)setAllowsAppleDoubleAttachments:(BOOL)fp8;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)fp8;
- (BOOL)signsOutput;
- (void)setSignsOutput:(BOOL)fp8;
- (BOOL)encryptsOutput;
- (void)setEncryptsOutput:(BOOL)fp8;
- (BOOL)writeImageSize;
- (void)setWriteImageSize:(BOOL)fp8;

@end

#else

@interface MessageWriter:NSObject
{
    int _createsMimeAlternatives:1;	// 4 = 0x4
    int _createsRichText:1;	// 4 = 0x4
    int _createsPlainTextOnly:1;	// 4 = 0x4
    int _allows8BitMimeParts:1;	// 4 = 0x4
    int _allowsBinaryMimeParts:1;	// 4 = 0x4
    int _allowsAppleDoubleAttachments:1;	// 4 = 0x4
    int _signsOutput:1;	// 4 = 0x4
    int _encryptsOutput:1;	// 4 = 0x4
    unsigned int _preferredEncoding;	// 8 = 0x8
}

- init;
- createDataForAttributedString:fp8;
- (void)appendDataForMimePart:fp8 toData:fp12 withPartData:fp16;
- createBounceMessageForMessage:fp8;
- createMessageByRemovingAttachmentsFromMessage:fp8;
- createMessageWithAttributedString:fp8 headers:fp12;
- createMessageWithHtmlString:fp8 attachments:fp12 headers:fp16;
- (char)createsMimeAlternatives;
- (void)setCreatesMimeAlternatives:(char)fp8;
- (char)createsPlainTextOnly;
- (void)setCreatesPlainTextOnly:(char)fp8;
- (char)createsRichText;
- (void)setCreatesRichText:(char)fp8;
- (char)allows8BitMimeParts;
- (void)setAllows8BitMimeParts:(char)fp8;
- (char)allowsBinaryMimeParts;
- (void)setAllowsBinaryMimeParts:(char)fp8;
- (char)allowsAppleDoubleAttachments;
- (void)setAllowsAppleDoubleAttachments:(char)fp8;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)fp8;
- (char)signsOutput;
- (void)setSignsOutput:(char)fp8;
- (char)encryptsOutput;
- (void)setEncryptsOutput:(char)fp8;

@end

#endif
