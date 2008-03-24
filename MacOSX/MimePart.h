/* MimePart.h created by stephane on Thu 06-Jul-2000 */

#import <Cocoa/Cocoa.h>

#ifdef LEOPARD

@interface MimePart : NSObject
{
    NSString *_type;
    NSString *_subtype;
    NSMutableDictionary *_bodyParameters;
    NSString *_contentTransferEncoding;
    NSMutableDictionary *_otherIvars;
    struct _NSRange _range;
    id _parentOrBody;
    MimePart *_nextPart;
}

+ (void)initialize;
- (void)dealloc;
- (void)finalize;
- (id)init;
- (id)type;
- (void)setType:(id)fp8;
- (id)subtype;
- (void)setSubtype:(id)fp8;
- (id)bodyParameterForKey:(id)fp8;
- (void)setBodyParameter:(id)fp8 forKey:(id)fp12;
- (id)bodyParameterKeys;
- (id)contentTransferEncoding;
- (void)setContentTransferEncoding:(id)fp8;
- (id)disposition;
- (void)setDisposition:(id)fp8;
- (id)dispositionParameterForKey:(id)fp8;
- (void)setDispositionParameter:(id)fp8 forKey:(id)fp12;
- (id)dispositionParameterKeys;
- (id)contentDescription;
- (void)setContentDescription:(id)fp8;
- (id)contentID;
- (void)setContentID:(id)fp8;
- (id)contentIDURLString;
- (id)contentLocation;
- (void)setContentLocation:(id)fp8;
- (id)languages;
- (void)setLanguages:(id)fp8;
- (id)parentPart;
- (id)firstChildPart;
- (id)nextSiblingPart;
- (id)subparts;
- (id)subpartAtIndex:(int)fp8;
- (void)setSubparts:(id)fp8;
- (void)addSubpart:(id)fp8;
- (struct _NSRange)range;
- (void)setRange:(struct _NSRange)fp8;
- (id)bodyData;
- (id)bodyConvertedFromFlowedText;
- (id)mimeBody;
- (void)setMimeBody:(id)fp8;
- (id)description;
- (id)attachmentFilenameWithHiddenExtension:(char *)fp8;
- (id)attachmentFilename;
- (BOOL)isSigned;
- (BOOL)isEncrypted;
- (BOOL)hasCachedDataInStore;
- (unsigned int)numberOfAttachments;
- (void)getNumberOfAttachments:(unsigned int *)fp8 isSigned:(char *)fp12 isEncrypted:(char *)fp16;
- (id)attachments;
- (id)attachmentFilenames;
- (unsigned long)textEncoding;
- (unsigned int)approximateRawSize;
- (BOOL)isReadableText;
- (BOOL)isImage;
- (BOOL)isCalendar;
- (BOOL)isToDo;
- (BOOL)isStationeryImage;
- (void)markAsStationeryImage;
- (id)_partThatIsAttachment;
- (BOOL)isMessageExternalBodyWithURL;
- (BOOL)isAttachment;
- (BOOL)isRich;
- (BOOL)isHTML;
- (BOOL)usesKnownSignatureProtocol;
- (id)createFileWrapper;
- (id)attributedString;
- (id)fileWrapper;
- (id)safeFileWrapper;
- (void)configureFileWrapper:(id)fp8;
- (id)startPart;
- (int)numberOfAlternatives;
- (id)alternativeAtIndex:(int)fp8;
- (id)signedData;
- (id)textPart;
- (id)textHtmlPart;
- (void)htmlString:(id *)fp8 createWebResource:(id *)fp12 forFileWrapper:(id)fp16 partNumber:(id)fp20;
- (id)decodedContent;
- (id)_archiveForData:(id)fp8 URL:(id)fp12 MIMEType:(id)fp16 textEncodingName:(id)fp20 frameName:(id)fp24 subresources:(id)fp28 subframeArchives:(id)fp32;
- (id)_archiveForData:(id)fp8 URL:(id)fp12 MIMEType:(id)fp16 textEncodingName:(id)fp20 frameName:(id)fp24;
- (id)_archiveForString:(id)fp8 URL:(id)fp12 needsPlainTextBodyClass:(BOOL)fp16;
- (id)_archiveForFileWrapper:(id)fp8 URL:(id)fp12;
- (id)_createArchiveWithConvertedPlainTextBodyClassFromArchive:(id)fp8;
- (id)webArchive;
- (id)decryptedMessageBodyIsEncrypted:(char *)fp8 isSigned:(char *)fp12;
- (id)todoPart;
- (void)clearCachedDescryptedMessageBody;
- (void)_setDecryptedMessageBody:(id)fp8 isEncrypted:(BOOL)fp12 isSigned:(BOOL)fp16;

@end

@interface MimePart (DecodingSupport)
- (id)_fullMimeTypeEvenInsideAppleDouble;
- (id)contentsForTextSystem;
- (id)decodeTextPlain;
- (id)decodeText;
- (id)decodeTextRichtext;
- (id)decodeTextEnriched;
- (id)decodeTextHtml;
- (id)decodeTextCalendar;
- (id)decodeMultipart;
- (id)decodeMultipartAlternative;
- (id)decodeMultipartRelated;
- (id)decodeMultipartFolder;
- (id)decodeApplicationApple_msg_composite_image;
- (id)decodeApplicationOctet_stream;
- (id)decodeApplicationZip;
- (id)decodeMessageDelivery_status;
- (id)decodeMessageRfc822;
- (id)decodeMessagePartial;
- (id)decodeMessageExternal_body;
- (id)decodeApplicationMac_binhex40;
- (id)decodeApplicationApplefile;
- (id)decodeMultipartAppledouble;
@end

@interface MimePart (IMAPSupport)
- (BOOL)parseIMAPPropertyList:(id)fp8;
- (id)partNumber;
@end

@interface MimePart (MessageSupport)
- (BOOL)parseMimeBody;
@end

@interface MimePart (SMIMEExtensions)
- (void)verifySignature:(id *)fp8;
- (id)decodeMultipartSigned;
- (id)_decodeApplicationPkcs7_mime:(id *)fp8;
- (id)decodeApplicationPkcs7_mime;
- (id)copyMessageSigners;
- (id)copySigningCertificates;
- (id)copySignerLabels;
- (id)createSignedPartWithData:(id)fp8 sender:(id)fp12 signatureData:(id *)fp16;
- (id)createEncryptedPartWithData:(id)fp8 recipients:(id)fp12 encryptedData:(id *)fp16;
@end

@interface MimePart (MatadorSupport)
- (BOOL)writeAttachmentToSpotlightCacheIfNeededUnder:(id)fp8;
@end

@interface MimePart (StringRendering)
- (void)renderString:(id)fp8;
@end

#elif defined(TIGER)

@class NSMutableArray;
@class NSMutableData;
@class NSMutableDictionary;
@class MessageHeaders;

@interface MimePart : NSObject
{
    NSString *_type;
    NSString *_subtype;
    NSMutableDictionary *_bodyParameters;
    NSString *_contentTransferEncoding;
    NSMutableDictionary *_otherIvars;
    struct _NSRange _range;
    id _parentOrBody;
    MimePart *_nextPart;
}

+ (void)initialize;
- (void)dealloc;
- (void)finalize;
- (id)init;
- (id)type;
- (void)setType:(id)fp8;
- (id)subtype;
- (void)setSubtype:(id)fp8;
- (id)bodyParameterForKey:(id)fp8;
- (void)setBodyParameter:(id)fp8 forKey:(id)fp12;
- (id)bodyParameterKeys;
- (id)contentTransferEncoding;
- (void)setContentTransferEncoding:(id)fp8;
- (id)disposition;
- (void)setDisposition:(id)fp8;
- (id)dispositionParameterForKey:(id)fp8;
- (void)setDispositionParameter:(id)fp8 forKey:(id)fp12;
- (id)dispositionParameterKeys;
- (id)contentDescription;
- (void)setContentDescription:(id)fp8;
- (id)contentID;
- (void)setContentID:(id)fp8;
- (id)contentLocation;
- (void)setContentLocation:(id)fp8;
- (id)languages;
- (void)setLanguages:(id)fp8;
- (id)parentPart;
- (id)firstChildPart;
- (id)nextSiblingPart;
- (id)subparts;
- (id)subpartAtIndex:(int)fp8;
- (void)setSubparts:(id)fp8;
- (void)addSubpart:(id)fp8;
- (struct _NSRange)range;
- (void)setRange:(struct _NSRange)fp8;
- (id)bodyData;
- (id)mimeBody;
- (void)setMimeBody:(id)fp8;
- (id)description;
- (id)attachmentFilename;
- (BOOL)hasCachedDataInStore;
- (unsigned int)numberOfAttachments;
- (void)getNumberOfAttachments:(unsigned int *)fp8 isSigned:(char *)fp12 isEncrypted:(char *)fp16;
- (id)attachments;
- (unsigned long)textEncoding;
- (unsigned int)approximateRawSize;
- (BOOL)isReadableText;
- (BOOL)isAttachment;
- (BOOL)isRich;
- (BOOL)isHTML;
- (BOOL)usesKnownSignatureProtocol;
- (id)attributedString;
- (id)fileWrapper;
- (void)configureFileWrapper:(id)fp8;
- (id)stringValueForJunkEvaluation:(BOOL)fp8;
- (id)startPart;
- (int)numberOfAlternatives;
- (id)alternativeAtIndex:(int)fp8;
- (id)signedData;
- (id)textHtmlPart;
- (id)webArchive;
- (id)decryptedMessageBody;
- (void)clearCachedDescryptedMessageBody;
- (void)_setDecryptedMessageBody:(id)fp8;

@end

@interface MimePart (DecodingSupport)
- (id)_fullMimeTypeEvenInsideAppleDouble;
- (id)contentsForTextSystem;
- (id)decodeTextPlain;
- (id)decodeText;
- (id)decodeTextRichtext;
- (id)decodeTextEnriched;
- (id)decodeTextHtml;
- (id)decodeTextCalendar;
- (id)decodeMultipart;
- (id)decodeMultipartAlternative;
- (id)decodeMultipartFolder;
- (id)decodeApplicationOctet_stream;
- (id)decodeApplicationZip;
- (id)decodeMessageDelivery_status;
- (id)decodeMessageRfc822;
- (id)decodeMessagePartial;
- (id)decodeMessageExternal_body;
- (id)decodeApplicationMac_binhex40;
- (id)decodeApplicationApplefile;
- (id)decodeMultipartAppledouble;
@end

@interface MimePart (IMAPSupport)
- (BOOL)parseIMAPPropertyList:(id)fp8;
- (id)partNumber;
@end

@interface MimePart (MessageSupport)
- (void)_fixSubparts;
- (BOOL)parseMimeBody;
@end

@interface MimePart (SMIMEExtensions)
- (id)decodeMultipartSigned;
- (id)decodeApplicationPkcs7_mime;
- (id)createSignedPartWithData:(id)fp8 sender:(id)fp12 signatureData:(id *)fp16;
- (id)createEncryptedPartWithData:(id)fp8 recipients:(id)fp12 encryptedData:(id *)fp16;
@end

#else

@interface MimePart:NSObject
{
    NSString *_type;	// 4 = 0x4
    NSString *_subtype;	// 8 = 0x8
    NSMutableDictionary *_bodyParameters;	// 12 = 0xc
    NSString *_contentTransferEncoding;	// 16 = 0x10
    NSMutableDictionary *_otherIvars;	// 20 = 0x14
    struct _NSRange _range;	// 24 = 0x18
    id _parentOrBody;	// 32 = 0x20
    MimePart *_nextPart;	// 36 = 0x24
}

+ (void)initialize;
- (void)dealloc;
- init;
- type;
- (void)setType:fp8;
- subtype;
- (void)setSubtype:fp8;
- bodyParameterForKey:fp8;
- (void)setBodyParameter:fp8 forKey:fp12;
- bodyParameterKeys;
- contentTransferEncoding;
- (void)setContentTransferEncoding:fp8;
- disposition;
- (void)setDisposition:fp8;
- dispositionParameterForKey:fp8;
- (void)setDispositionParameter:fp8 forKey:fp12;
- dispositionParameterKeys;
- contentDescription;
- (void)setContentDescription:fp8;
- contentID;
- (void)setContentID:fp8;
- contentLocation;
- (void)setContentLocation:fp8;
- languages;
- (void)setLanguages:fp8;
- parentPart;
- firstChildPart;
- nextSiblingPart;
- subparts;
- subpartAtIndex:(int)fp8;
- (void)setSubparts:fp8;
- (void)addSubpart:fp8;
- (struct _NSRange)range;
- (void)setRange:(struct _NSRange)fp8;
- bodyData;
- mimeBody;
- (void)setMimeBody:fp8;
- description;
- attachmentFilename;
- (char)hasCachedDataInStore;
- (unsigned int)numberOfAttachments;
- (void)getNumberOfAttachments:(unsigned int *)fp8 isSigned:(char *)fp12 isEncrypted:(char *)fp16;
- attachments;
- (unsigned long)textEncoding;
- (unsigned int)approximateRawSize;
- (char)isReadableText;
- (char)isAttachment;
- (char)isRich;
- (char)isHTML;
- (char)usesKnownSignatureProtocol;
- attributedString;
- fileWrapper;
- (void)configureFileWrapper:fp8;
- stringForIndexing;
- startPart;
- (int)numberOfAlternatives;
- alternativeAtIndex:(int)fp8;
- signedData;
- textHtmlPart;
- decryptedMessageBody;
- (void)_setDecryptedMessageBody:fp8;

@end

@interface MimePart(DecodingSupport)
- _fullMimeTypeEvenInsideAppleDouble;
- contentsForTextSystem;
- decodeTextPlain;
- decodeText;
- decodeTextRichtext;
- decodeTextEnriched;
- decodeTextHtml;
- decodeMultipart;
- decodeMultipartAlternative;
- decodeMultipartFolder;
- decodeApplicationOctet_stream;
- decodeApplicationZip;
- decodeMessageDelivery_status;
- decodeMessageRfc822;
- decodeMessagePartial;
- decodeMessageExternal_body;
- decodeApplicationMac_binhex40;
- decodeApplicationApplefile;
- decodeMultipartAppledouble;
@end

@interface MimePart(IMAPSupport)
- (char)parseIMAPPropertyList:fp8;
- partNumber;
@end

@interface MimePart(MessageSupport)
- (char)parseMimeBody;
@end

@interface MimePart(SMIMEExtensions)
- decodeMultipartSigned;
- decodeApplicationPkcs7_mime;
- createSignedPartWithData:fp8 sender:fp12 signatureData:(id *)fp16;
- createEncryptedPartWithData:fp8 recipients:fp12 encryptedData:(id *)fp16;
@end

#endif
