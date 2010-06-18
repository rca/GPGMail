/* MimePart.h created by stephane on Thu 06-Jul-2000 */

#import <Cocoa/Cocoa.h>

/*
 * -bodyData: "This method must be called off the main thread", according to the (caught) assertion failure
 */

#ifdef SNOW_LEOPARD_64

@class MessageBody;
@class Message;
@class MessageStore;

@interface MimePart : NSObject
{
    int _typeCode;
    int _subtypeCode;
    NSString *_type;
    NSString *_subtype;
    NSMutableDictionary *_bodyParameters;
    NSString *_contentTransferEncoding;
    id _encryptSignLock;
    BOOL _isMimeEncrypted;
    BOOL _isMimeSigned;
    MessageBody *_decryptedMessageBody;
    Message *_decryptedMessage;
    MessageStore *_decryptedMessageStore;
    NSMutableDictionary *_otherIvars;
    struct _NSRange _range;
    id _parentOrBody;
    MimePart *_nextPart;
}

- (void)dealloc;
- (void)finalize;
- (id)init;
- (int)typeCode;
- (id)type;
- (void)setType:(id)arg1;
- (int)subtypeCode;
- (id)subtype;
- (void)setSubtype:(id)arg1;
- (BOOL)isType:(id)arg1 subtype:(id)arg2;
- (BOOL)isTypeCode:(int)arg1 subtypeCode:(int)arg2;
- (id)bodyParameterForKey:(id)arg1;
- (void)setBodyParameter:(id)arg1 forKey:(id)arg2;
- (id)bodyParameterKeys;
- (id)disposition;
- (void)setDisposition:(id)arg1;
- (id)dispositionParameterForKey:(id)arg1;
- (void)setDispositionParameter:(id)arg1 forKey:(id)arg2;
- (id)dispositionParameterKeys;
- (id)contentDescription;
- (void)setContentDescription:(id)arg1;
- (id)contentID;
- (void)setContentID:(id)arg1;
@property(readonly) NSString *contentIDURLString;
- (id)contentLocation;
- (void)setContentLocation:(id)arg1;
- (id)languages;
- (void)setLanguages:(id)arg1;
- (id)parentPart;
- (id)firstChildPart;
- (id)nextSiblingPart;
- (id)subparts;
- (id)subpartAtIndex:(long long)arg1;
- (void)setSubparts:(id)arg1;
- (void)addSubpart:(id)arg1;
- (struct _NSRange)range;
- (void)setRange:(struct _NSRange)arg1;
- (id)bodyData;
- (id)bodyConvertedFromFlowedText;
- (id)mimeBody;
- (void)setMimeBody:(id)arg1;
- (id)description;
- (id)attachmentFilenameWithHiddenExtension:(char *)arg1;
- (id)attachmentFilename;
@property(readonly) BOOL isSigned;
@property(readonly) BOOL isEncrypted;
- (BOOL)hasCachedDataInStore;
- (unsigned int)numberOfAttachments;
- (void)getNumberOfAttachments:(unsigned int *)arg1 numberOfTNEFAttachments:(unsigned int *)arg2 isSigned:(char *)arg3 isEncrypted:(char *)arg4;
- (id)attachments;
- (id)attachmentFilenames;
- (unsigned int)textEncoding;
- (unsigned long long)approximateRawSize;
- (unsigned long long)approximateDecodedSize;
- (BOOL)isReadableText;
@property(readonly) BOOL isImage;
- (BOOL)isCalendar;
- (BOOL)isToDo;
- (BOOL)isStationeryImage;
- (void)markAsStationeryImage;
- (id)_partThatIsAttachment;
- (BOOL)isMessageExternalBodyWithURL;
- (BOOL)shouldConsiderInlineOverridingExchangeServer;
- (BOOL)isAttachment;
- (BOOL)isRich;
- (BOOL)isHTML;
- (BOOL)usesKnownSignatureProtocol;
- (id)_createAttachment;
- (id)_createFileWrapper;
- (id)_getMessageAttachment:(unsigned long long)arg1;
- (id)attributedString;
- (id)fileWrapper;
- (id)_remoteFileWrapper;
- (void)download:(id)arg1 didReceiveResponse:(id)arg2;
- (void)download:(id)arg1 didReceiveDataOfLength:(unsigned long long)arg2;
- (void)download:(id)arg1 didFailWithError:(id)arg2;
- (void)downloadDidFinish:(id)arg1;
- (void)configureFileWrapper:(id)arg1;
- (id)startPart;
- (long long)numberOfAlternatives;
- (id)alternativeAtIndex:(long long)arg1;
- (id)signedData;
- (id)textPart;
- (id)textHtmlPart;
- (void)htmlString:(id *)arg1 createWebResource:(id *)arg2 forFileWrapper:(id)arg3 partNumber:(id)arg4;
- (id)htmlStringForMimePart:(id)arg1 attachment:(id)arg2;
- (id)decodedContent;
- (id)_archiveForData:(id)arg1 URL:(id)arg2 MIMEType:(id)arg3 textEncodingName:(id)arg4 frameName:(id)arg5 subresources:(id)arg6 subframeArchives:(id)arg7;
- (id)_archiveForData:(id)arg1 URL:(id)arg2 MIMEType:(id)arg3 textEncodingName:(id)arg4 frameName:(id)arg5;
- (id)_archiveForString:(id)arg1 URL:(id)arg2 needsPlainTextBodyClass:(BOOL)arg3;
- (id)_archiveForFileWrapper:(id)arg1 URL:(id)arg2;
- (id)_createArchiveWithConvertedPlainTextBodyClassFromArchive:(id)arg1;
- (id)parsedMessage;
- (id)webArchive;
- (id)decryptedMessageBodyIsEncrypted:(char *)arg1 isSigned:(char *)arg2;
- (id)todoPart;
- (void)clearCachedDecryptedMessageBody;
- (void)_setDecryptedMessageBody:(id)arg1 isEncrypted:(BOOL)arg2 isSigned:(BOOL)arg3;
@property(retain, nonatomic) MessageStore *decryptedMessageStore; // @synthesize decryptedMessageStore=_decryptedMessageStore;
@property(retain, nonatomic) Message *decryptedMessage; // @synthesize decryptedMessage=_decryptedMessage;
@property(retain, nonatomic) MessageBody *decryptedMessageBody; // @synthesize decryptedMessageBody=_decryptedMessageBody;
@property(nonatomic) BOOL isMimeSigned; // @synthesize isMimeSigned=_isMimeSigned;
@property(nonatomic) BOOL isMimeEncrypted; // @synthesize isMimeEncrypted=_isMimeEncrypted;
@property(copy) NSString *contentTransferEncoding; // @synthesize contentTransferEncoding=_contentTransferEncoding;

@end

@interface MimePart (DecodingSupport)
- (id)_fullMimeTypeEvenInsideAppleDouble;
- (id)decode;
- (id)decodeTextPlain;
- (id)decodeText;
- (id)decodeTextRichtext;
- (id)decodeTextRtf;
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
- (id)decodeApplicationSmil;
- (id)decodeMessageDelivery_status;
- (id)decodeMessageRfc822;
- (id)decodeMessagePartial;
- (id)decodeMessageExternal_body;
- (id)decodeApplicationMac_binhex40;
- (id)decodeApplicationApplefile;
- (id)decodeMultipartAppledouble;
@end

@interface MimePart (IMAPSupport)
- (BOOL)parseIMAPPropertyList:(id)arg1;
- (id)partNumber;
@end

@interface MimePart (MatadorSupport)
- (BOOL)writeAttachmentToSpotlightCacheIfNeededUnder:(id)arg1;
@end

@interface MimePart (MessageSupport)
- (BOOL)parseMimeBody;
@end

@interface MimePart (SMIMEExtensions)
- (void)verifySignature:(id *)arg1;
- (id)decodeMultipartSigned;
- (id)_decodeApplicationPkcs7_mime:(id *)arg1;
- (id)decodeApplicationPkcs7_mime;
- (id)copyMessageSigners;
- (id)copySigningCertificates;
- (id)copySignerLabels;
- (id)createSignedPartWithData:(id)arg1 sender:(id)arg2 signatureData:(id *)arg3;
- (id)createEncryptedPartWithData:(id)arg1 recipients:(id)arg2 encryptedData:(id *)arg3;
@end

@interface MimePart (StringRendering)
- (void)renderString:(id)arg1;
@end

#elif defined(SNOW_LEOPARD)

@class MessageBody;
@class Message;
@class MessageStore;

@interface MimePart : NSObject
{
    int _typeCode;
    int _subtypeCode;
    NSString *_type;
    NSString *_subtype;
    NSMutableDictionary *_bodyParameters;
    NSString *_contentTransferEncoding;
    id _encryptSignLock;
    BOOL _isMimeEncrypted;
    BOOL _isMimeSigned;
    MessageBody *_decryptedMessageBody;
    Message *_decryptedMessage;
    MessageStore *_decryptedMessageStore;
    NSMutableDictionary *_otherIvars;
    struct _NSRange _range;
    id _parentOrBody;
    MimePart *_nextPart;
}

- (void)dealloc;
- (void)finalize;
- (id)init;
- (int)typeCode;
- (id)type;
- (void)setType:(id)arg1;
- (int)subtypeCode;
- (id)subtype;
- (void)setSubtype:(id)arg1;
- (BOOL)isType:(id)arg1 subtype:(id)arg2;
- (BOOL)isTypeCode:(int)arg1 subtypeCode:(int)arg2;
- (id)bodyParameterForKey:(id)arg1;
- (void)setBodyParameter:(id)arg1 forKey:(id)arg2;
- (id)bodyParameterKeys;
- (id)disposition;
- (void)setDisposition:(id)arg1;
- (id)dispositionParameterForKey:(id)arg1;
- (void)setDispositionParameter:(id)arg1 forKey:(id)arg2;
- (id)dispositionParameterKeys;
- (id)contentDescription;
- (void)setContentDescription:(id)arg1;
- (id)contentID;
- (void)setContentID:(id)arg1;
- (id)contentIDURLString;
- (id)contentLocation;
- (void)setContentLocation:(id)arg1;
- (id)languages;
- (void)setLanguages:(id)arg1;
- (id)parentPart;
- (id)firstChildPart;
- (id)nextSiblingPart;
- (id)subparts;
- (id)subpartAtIndex:(int)arg1;
- (void)setSubparts:(id)arg1;
- (void)addSubpart:(id)arg1;
- (struct _NSRange)range;
- (void)setRange:(struct _NSRange)arg1;
- (id)bodyData;
- (id)bodyConvertedFromFlowedText;
- (id)mimeBody;
- (void)setMimeBody:(id)arg1;
- (id)description;
- (id)attachmentFilenameWithHiddenExtension:(char *)arg1;
- (id)attachmentFilename;
- (BOOL)isSigned;
- (BOOL)isEncrypted;
- (BOOL)hasCachedDataInStore;
- (unsigned long)numberOfAttachments;
- (void)getNumberOfAttachments:(unsigned int *)arg1 isSigned:(char *)arg2 isEncrypted:(char *)arg3;
- (id)attachments;
- (id)attachmentFilenames;
- (unsigned long)textEncoding;
- (unsigned int)approximateRawSize;
- (unsigned int)approximateDecodedSize;
- (BOOL)isReadableText;
- (BOOL)isImage;
- (BOOL)isCalendar;
- (BOOL)isToDo;
- (BOOL)isStationeryImage;
- (void)markAsStationeryImage;
- (id)_partThatIsAttachment;
- (BOOL)isMessageExternalBodyWithURL;
- (BOOL)shouldConsiderInlineOverridingExchangeServer;
- (BOOL)isAttachment;
- (BOOL)isRich;
- (BOOL)isHTML;
- (BOOL)usesKnownSignatureProtocol;
- (id)_createAttachment;
- (id)_createFileWrapper;
- (id)_getMessageAttachment:(unsigned int)arg1;
- (id)attributedString;
- (id)fileWrapper;
- (id)_remoteFileWrapper;
- (void)download:(id)arg1 didReceiveResponse:(id)arg2;
- (void)download:(id)arg1 didReceiveDataOfLength:(unsigned int)arg2;
- (void)download:(id)arg1 didFailWithError:(id)arg2;
- (void)downloadDidFinish:(id)arg1;
- (void)configureFileWrapper:(id)arg1;
- (id)startPart;
- (int)numberOfAlternatives;
- (id)alternativeAtIndex:(int)arg1;
- (id)signedData;
- (id)textPart;
- (id)textHtmlPart;
- (void)htmlString:(id *)arg1 createWebResource:(id *)arg2 forFileWrapper:(id)arg3 partNumber:(id)arg4;
- (id)htmlStringForMimePart:(id)arg1 attachment:(id)arg2;
- (id)decodedContent;
- (id)_archiveForData:(id)arg1 URL:(id)arg2 MIMEType:(id)arg3 textEncodingName:(id)arg4 frameName:(id)arg5 subresources:(id)arg6 subframeArchives:(id)arg7;
- (id)_archiveForData:(id)arg1 URL:(id)arg2 MIMEType:(id)arg3 textEncodingName:(id)arg4 frameName:(id)arg5;
- (id)_archiveForString:(id)arg1 URL:(id)arg2 needsPlainTextBodyClass:(BOOL)arg3;
- (id)_archiveForFileWrapper:(id)arg1 URL:(id)arg2;
- (id)_createArchiveWithConvertedPlainTextBodyClassFromArchive:(id)arg1;
- (id)parsedMessage;
- (id)webArchive;
- (id)decryptedMessageBodyIsEncrypted:(char *)arg1 isSigned:(char *)arg2;
- (id)todoPart;
- (void)clearCachedDecryptedMessageBody;
- (void)_setDecryptedMessageBody:(id)arg1 isEncrypted:(BOOL)arg2 isSigned:(BOOL)arg3;
- (id)decryptedMessageStore;
- (void)setDecryptedMessageStore:(id)arg1;
- (id)decryptedMessage;
- (void)setDecryptedMessage:(id)arg1;
- (id)decryptedMessageBody;
- (void)setDecryptedMessageBody:(id)arg1;
- (BOOL)isMimeSigned;
- (void)setIsMimeSigned:(BOOL)arg1;
- (BOOL)isMimeEncrypted;
- (void)setIsMimeEncrypted:(BOOL)arg1;
- (id)contentTransferEncoding;
- (void)setContentTransferEncoding:(id)arg1;

@end

@interface MimePart (MatadorSupport)
- (BOOL)writeAttachmentToSpotlightCacheIfNeededUnder:(id)arg1;
@end

@interface MimePart (StringRendering)
- (void)renderString:(id)arg1;
@end

@interface MimePart (DecodingSupport)
- (id)_fullMimeTypeEvenInsideAppleDouble;
- (id)decode;
- (id)decodeTextPlain;
- (id)decodeText;
- (id)decodeTextRichtext;
- (id)decodeTextRtf;
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
- (id)decodeApplicationSmil;
- (id)decodeMessageDelivery_status;
- (id)decodeMessageRfc822;
- (id)decodeMessagePartial;
- (id)decodeMessageExternal_body;
- (id)decodeApplicationMac_binhex40;
- (id)decodeApplicationApplefile;
- (id)decodeMultipartAppledouble;
@end

@interface MimePart (IMAPSupport)
- (BOOL)parseIMAPPropertyList:(id)arg1;
- (id)partNumber;
@end

@interface MimePart (MessageSupport)
- (BOOL)parseMimeBody;
@end

@interface MimePart (SMIMEExtensions)
- (void)verifySignature:(id *)arg1;
- (id)decodeMultipartSigned;
- (id)_decodeApplicationPkcs7_mime:(id *)arg1;
- (id)decodeApplicationPkcs7_mime;
- (id)copyMessageSigners;
- (id)copySigningCertificates;
- (id)copySignerLabels;
- (id)createSignedPartWithData:(id)arg1 sender:(id)arg2 signatureData:(id *)arg3;
- (id)createEncryptedPartWithData:(id)arg1 recipients:(id)arg2 encryptedData:(id *)arg3;
@end

#elif defined(LEOPARD)

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
- (id)_createAttachment;
- (id)_createFileWrapper;
- (id)attributedString;
- (id)fileWrapper;
- (id)_remoteFileWrapper;
- (void)download:(id)fp8 didReceiveResponse:(id)fp12;
- (void)download:(id)fp8 didReceiveDataOfLength:(unsigned int)fp12;
- (void)download:(id)fp8 didFailWithError:(id)fp12;
- (void)downloadDidFinish:(id)fp8;
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
