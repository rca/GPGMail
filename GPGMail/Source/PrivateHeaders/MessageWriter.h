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


#endif
