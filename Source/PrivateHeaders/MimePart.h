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
- (BOOL)isType:(id) arg1 subtype:(id)arg2;
- (BOOL)isTypeCode:(int)arg1 subtypeCode:(int)arg2;
- (id)bodyParameterForKey:(id)arg1;
- (void)setBodyParameter:(id) arg1 forKey:(id)arg2;
- (id)bodyParameterKeys;
- (id)disposition;
- (void)setDisposition:(id)arg1;
- (id)dispositionParameterForKey:(id)arg1;
- (void)setDispositionParameter:(id) arg1 forKey:(id)arg2;
- (id)dispositionParameterKeys;
- (id)contentDescription;
- (void)setContentDescription:(id)arg1;
- (id)contentID;
- (void)setContentID:(id)arg1;
@property (readonly) NSString *contentIDURLString;
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
@property (readonly) BOOL isSigned;
@property (readonly) BOOL isEncrypted;
- (BOOL)hasCachedDataInStore;
- (unsigned int)numberOfAttachments;
- (void)getNumberOfAttachments:(unsigned int *)arg1 numberOfTNEFAttachments:(unsigned int *)arg2 isSigned:(char *)arg3 isEncrypted:(char *)arg4;
- (id)attachments;
- (id)attachmentFilenames;
- (unsigned int)textEncoding;
- (unsigned long long)approximateRawSize;
- (unsigned long long)approximateDecodedSize;
- (BOOL)isReadableText;
@property (readonly) BOOL isImage;
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
- (void)download:(id) arg1 didReceiveResponse:(id)arg2;
- (void)download:(id) arg1 didReceiveDataOfLength:(unsigned long long)arg2;
- (void)download:(id) arg1 didFailWithError:(id)arg2;
- (void)downloadDidFinish:(id)arg1;
- (void)configureFileWrapper:(id)arg1;
- (id)startPart;
- (long long)numberOfAlternatives;
- (id)alternativeAtIndex:(long long)arg1;
- (id)signedData;
- (id)textPart;
- (id)textHtmlPart;
- (void)htmlString:(id *)arg1 createWebResource:(id *)arg2 forFileWrapper:(id) arg3 partNumber:(id)arg4;
- (id)htmlStringForMimePart:(id) arg1 attachment:(id)arg2;
- (id)decodedContent;
- (id)_archiveForData:(id) arg1 URL:(id) arg2 MIMEType:(id) arg3 textEncodingName:(id) arg4 frameName:(id) arg5 subresources:(id) arg6 subframeArchives:(id)arg7;
- (id)_archiveForData:(id) arg1 URL:(id) arg2 MIMEType:(id) arg3 textEncodingName:(id) arg4 frameName:(id)arg5;
- (id)_archiveForString:(id) arg1 URL:(id) arg2 needsPlainTextBodyClass:(BOOL)arg3;
- (id)_archiveForFileWrapper:(id) arg1 URL:(id)arg2;
- (id)_createArchiveWithConvertedPlainTextBodyClassFromArchive:(id)arg1;
- (id)parsedMessage;
- (id)webArchive;
- (id)decryptedMessageBodyIsEncrypted:(char *)arg1 isSigned:(char *)arg2;
- (id)todoPart;
- (void)clearCachedDecryptedMessageBody;
- (void)_setDecryptedMessageBody:(id) arg1 isEncrypted:(BOOL) arg2 isSigned:(BOOL)arg3;
@property (retain, nonatomic) MessageStore *decryptedMessageStore;  // @synthesize decryptedMessageStore=_decryptedMessageStore;
@property (retain, nonatomic) Message *decryptedMessage;  // @synthesize decryptedMessage=_decryptedMessage;
@property (retain, nonatomic) MessageBody *decryptedMessageBody;  // @synthesize decryptedMessageBody=_decryptedMessageBody;
@property (nonatomic) BOOL isMimeSigned; // @synthesize isMimeSigned=_isMimeSigned;
@property (nonatomic) BOOL isMimeEncrypted; // @synthesize isMimeEncrypted=_isMimeEncrypted;
@property (copy) NSString *contentTransferEncoding;  // @synthesize contentTransferEncoding=_contentTransferEncoding;

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
- (id)createSignedPartWithData:(id) arg1 sender:(id) arg2 signatureData:(id *)arg3;
- (id)createEncryptedPartWithData:(id) arg1 recipients:(id) arg2 encryptedData:(id *)arg3;
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
- (BOOL)isType:(id) arg1 subtype:(id)arg2;
- (BOOL)isTypeCode:(int)arg1 subtypeCode:(int)arg2;
- (id)bodyParameterForKey:(id)arg1;
- (void)setBodyParameter:(id) arg1 forKey:(id)arg2;
- (id)bodyParameterKeys;
- (id)disposition;
- (void)setDisposition:(id)arg1;
- (id)dispositionParameterForKey:(id)arg1;
- (void)setDispositionParameter:(id) arg1 forKey:(id)arg2;
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
- (void)download:(id) arg1 didReceiveResponse:(id)arg2;
- (void)download:(id) arg1 didReceiveDataOfLength:(unsigned int)arg2;
- (void)download:(id) arg1 didFailWithError:(id)arg2;
- (void)downloadDidFinish:(id)arg1;
- (void)configureFileWrapper:(id)arg1;
- (id)startPart;
- (int)numberOfAlternatives;
- (id)alternativeAtIndex:(int)arg1;
- (id)signedData;
- (id)textPart;
- (id)textHtmlPart;
- (void)htmlString:(id *)arg1 createWebResource:(id *)arg2 forFileWrapper:(id) arg3 partNumber:(id)arg4;
- (id)htmlStringForMimePart:(id) arg1 attachment:(id)arg2;
- (id)decodedContent;
- (id)_archiveForData:(id) arg1 URL:(id) arg2 MIMEType:(id) arg3 textEncodingName:(id) arg4 frameName:(id) arg5 subresources:(id) arg6 subframeArchives:(id)arg7;
- (id)_archiveForData:(id) arg1 URL:(id) arg2 MIMEType:(id) arg3 textEncodingName:(id) arg4 frameName:(id)arg5;
- (id)_archiveForString:(id) arg1 URL:(id) arg2 needsPlainTextBodyClass:(BOOL)arg3;
- (id)_archiveForFileWrapper:(id) arg1 URL:(id)arg2;
- (id)_createArchiveWithConvertedPlainTextBodyClassFromArchive:(id)arg1;
- (id)parsedMessage;
- (id)webArchive;
- (id)decryptedMessageBodyIsEncrypted:(char *)arg1 isSigned:(char *)arg2;
- (id)todoPart;
- (void)clearCachedDecryptedMessageBody;
- (void)_setDecryptedMessageBody:(id) arg1 isEncrypted:(BOOL) arg2 isSigned:(BOOL)arg3;
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
- (id)createSignedPartWithData:(id) arg1 sender:(id) arg2 signatureData:(id *)arg3;
- (id)createEncryptedPartWithData:(id) arg1 recipients:(id) arg2 encryptedData:(id *)arg3;
@end

#endif // ifdef SNOW_LEOPARD_64
