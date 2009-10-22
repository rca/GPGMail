/* NSData+Message.h created by dave on Tue 21-Nov-2000 */

#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD

@interface NSMutableData (MimeDataEncoding)
- (void)appendQuotedPrintableDataForHeaderBytes:(const char *)arg1 length:(unsigned int)arg2;
@end

@interface NSMutableData (RFC2231Support)
- (void)appendRFC2231CompliantValue:(id)arg1 forKey:(id)arg2 withEncodingHint:(unsigned long)arg3;
@end

@interface NSMutableData (NSDataUtils)
- (void)appendCString:(const char *)arg1;
- (void)appendByte:(BOOL)arg1;
- (void)convertNetworkLineEndingsToUnix;
@end

@interface NSData (HFSDataConversion)
- (id)wrapperForAppleFileDataWithFileEncodingHint:(unsigned long)arg1;
- (id)wrapperForBinHex40DataWithFileEncodingHint:(unsigned long)arg1;
@end

@interface NSData (MimeDataEncoding)
+ (unsigned int)quotedPrintableLengthOfHeaderBytes:(const char *)arg1 length:(unsigned int)arg2;
- (id)decodeQuotedPrintableForText:(BOOL)arg1;
- (id)encodeQuotedPrintableForText:(BOOL)arg1;
- (id)encodeQuotedPrintableForText:(BOOL)arg1 allowCancel:(BOOL)arg2;
- (id)decodeBase64;
- (BOOL)isValidBase64Data;
- (id)encodeBase64WithoutLineBreaks;
- (id)encodeBase64;
- (id)encodeBase64AllowCancel:(BOOL)arg1;
- (id)decodeModifiedBase64;
- (id)encodeModifiedBase64;
- (id)encodeBase64HeaderData;
@end

@interface NSData (NSDataUtils)
- (id)unquotedFromSpaceDataWithRange:(struct _NSRange)arg1;
- (id)quotedFromSpaceDataForMessage;
- (struct _NSRange)rangeOfRFC822HeaderData;
- (id)subdataToIndex:(unsigned int)arg1;
- (id)subdataFromIndex:(unsigned int)arg1;
- (struct _NSRange)rangeOfData:(id)arg1;
- (struct _NSRange)rangeOfData:(id)arg1 options:(unsigned int)arg2;
- (struct _NSRange)rangeOfData:(id)arg1 options:(unsigned int)arg2 range:(struct _NSRange)arg3;
- (struct _NSRange)rangeOfByteFromSet:(id)arg1;
- (struct _NSRange)rangeOfByteFromSet:(id)arg1 options:(unsigned int)arg2;
- (struct _NSRange)rangeOfByteFromSet:(id)arg1 options:(unsigned int)arg2 range:(struct _NSRange)arg3;
- (struct _NSRange)rangeOfCString:(const char *)arg1;
- (struct _NSRange)rangeOfCString:(const char *)arg1 options:(unsigned int)arg2;
- (struct _NSRange)rangeOfCString:(const char *)arg1 options:(unsigned int)arg2 range:(struct _NSRange)arg3;
- (id)componentsSeparatedByData:(id)arg1;
- (id)dataByConvertingUnixNewlinesToNetwork;
- (id)MD5Digest;
@end

@interface NSData (ToDoPasteboardUnarchiving)
- (id)todosFromPasteboardData;
@end

@interface NSData (UuEnDecode)
- (id)uudecodedDataIntoFile:(id *)arg1 mode:(unsigned int *)arg2;
- (id)uuencodedDataWithFile:(id)arg1 mode:(unsigned int)arg2;
@end

#elif defined(LEOPARD)

@interface NSMutableData (MimeDataEncoding)
- (void)appendQuotedPrintableDataForHeaderBytes:(const char *)fp8 length:(unsigned int)fp12;
@end

@interface NSMutableData (RFC2231Support)
- (void)appendRFC2231CompliantValue:(id)fp8 forKey:(id)fp12 withEncodingHint:(unsigned long)fp16;
@end

@interface NSMutableData (NSDataUtils)
- (void)appendCString:(const char *)fp8;
- (void)appendByte:(BOOL)fp8;
- (void)convertNetworkLineEndingsToUnix;
@end

@interface NSData (MimeDataEncoding)
+ (unsigned int)quotedPrintableLengthOfHeaderBytes:(const char *)fp8 length:(unsigned int)fp12;
- (id)decodeQuotedPrintableForText:(BOOL)fp8;
- (id)encodeQuotedPrintableForText:(BOOL)fp8;
- (id)encodeQuotedPrintableForText:(BOOL)fp8 allowCancel:(BOOL)fp12;
- (id)decodeBase64;
- (BOOL)isValidBase64Data;
- (id)encodeBase64WithoutLineBreaks;
- (id)encodeBase64;
- (id)encodeBase64AllowCancel:(BOOL)fp8;
- (id)decodeModifiedBase64;
- (id)encodeModifiedBase64;
- (id)encodeBase64HeaderData;
@end

@interface NSData (HFSDataConversion)
- (id)wrapperForAppleFileDataWithFileEncodingHint:(unsigned long)fp8;
- (id)wrapperForBinHex40DataWithFileEncodingHint:(unsigned long)fp8;
@end

@interface NSData (NSDataUtils)
- (id)unquotedFromSpaceDataWithRange:(struct _NSRange)fp8;
- (id)quotedFromSpaceDataForMessage;
- (struct _NSRange)rangeOfRFC822HeaderData;
- (id)subdataToIndex:(unsigned int)fp8;
- (id)subdataFromIndex:(unsigned int)fp8;
- (struct _NSRange)rangeOfData:(id)fp8;
- (struct _NSRange)rangeOfData:(id)fp8 options:(unsigned int)fp12;
- (struct _NSRange)rangeOfData:(id)fp8 options:(unsigned int)fp12 range:(struct _NSRange)fp16;
- (struct _NSRange)rangeOfByteFromSet:(id)fp8;
- (struct _NSRange)rangeOfByteFromSet:(id)fp8 options:(unsigned int)fp12;
- (struct _NSRange)rangeOfByteFromSet:(id)fp8 options:(unsigned int)fp12 range:(struct _NSRange)fp16;
- (struct _NSRange)rangeOfCString:(const char *)fp8;
- (struct _NSRange)rangeOfCString:(const char *)fp8 options:(unsigned int)fp12;
- (struct _NSRange)rangeOfCString:(const char *)fp8 options:(unsigned int)fp12 range:(struct _NSRange)fp16;
- (id)componentsSeparatedByData:(id)fp8;
- (id)dataByConvertingUnixNewlinesToNetwork;
- (id)MD5Digest;
@end

@interface NSData (UuEnDeCode)
- (id)uudecodedDataIntoFile:(id *)fp8 mode:(unsigned int *)fp12;
- (id)uuencodedDataWithFile:(id)fp8 mode:(unsigned int)fp12;
@end

@interface NSData (ToDoPasteboardUnarchiving)
- (id)todosFromPasteboardData;
@end

#elif defined(TIGER)

@interface NSMutableData (MimeDataEncoding)
- (void)appendQuotedPrintableDataForHeaderBytes:(const char *)fp8 length:(unsigned int)fp12;
@end

@interface NSMutableData (RFC2231Support)
- (void)appendRFC2231CompliantValue:(id)fp8 forKey:(id)fp12;
@end

@interface NSMutableData (NSDataUtils)
- (void)appendCString:(const char *)fp8;
- (void)appendByte:(BOOL)fp8;
- (void)convertNetworkLineEndingsToUnix;
@end

@interface NSData (MimeDataEncoding)
+ (unsigned int)quotedPrintableLengthOfHeaderBytes:(const char *)fp8 length:(unsigned int)fp12;
- (id)decodeQuotedPrintableForText:(BOOL)fp8;
- (id)encodeQuotedPrintableForText:(BOOL)fp8;
- (id)encodeQuotedPrintableForText:(BOOL)fp8 allowCancel:(BOOL)fp12;
- (id)decodeBase64;
- (BOOL)isValidBase64Data;
- (id)encodeBase64WithoutLineBreaks;
- (id)encodeBase64;
- (id)encodeBase64AllowCancel:(BOOL)fp8;
- (id)decodeModifiedBase64;
- (id)encodeModifiedBase64;
- (id)encodeBase64HeaderData;
@end

@interface NSData (HFSDataConversion)
- (id)wrapperForAppleFileDataWithFileEncodingHint:(unsigned long)fp8;
- (id)wrapperForBinHex40DataWithFileEncodingHint:(unsigned long)fp8;
@end

@interface NSData (NSDataUtils)
- (id)unquotedFromSpaceDataWithRange:(struct _NSRange)fp8;
- (id)quotedFromSpaceDataForMessage;
- (struct _NSRange)rangeOfRFC822HeaderData;
- (id)subdataToIndex:(unsigned int)fp8;
- (id)subdataFromIndex:(unsigned int)fp8;
- (struct _NSRange)rangeOfData:(id)fp8;
- (struct _NSRange)rangeOfData:(id)fp8 options:(unsigned int)fp12;
- (struct _NSRange)rangeOfData:(id)fp8 options:(unsigned int)fp12 range:(struct _NSRange)fp16;
- (struct _NSRange)rangeOfByteFromSet:(id)fp8;
- (struct _NSRange)rangeOfByteFromSet:(id)fp8 options:(unsigned int)fp12;
- (struct _NSRange)rangeOfByteFromSet:(id)fp8 options:(unsigned int)fp12 range:(struct _NSRange)fp16;
- (struct _NSRange)rangeOfCString:(const char *)fp8;
- (struct _NSRange)rangeOfCString:(const char *)fp8 options:(unsigned int)fp12;
- (struct _NSRange)rangeOfCString:(const char *)fp8 options:(unsigned int)fp12 range:(struct _NSRange)fp16;
- (id)componentsSeparatedByData:(id)fp8;
- (id)dataByConvertingUnixNewlinesToNetwork;
- (id)MD5Digest;
@end

@interface NSData (UuEnDeCode)
- (id)uudecodedDataIntoFile:(id *)fp8 mode:(unsigned int *)fp12;
- (id)uuencodedDataWithFile:(id)fp8 mode:(unsigned int)fp12;
@end

#else

@interface NSMutableData(MimeDataEncoding)
- (void)appendQuotedPrintableDataForHeaderBytes:(const STR)fp8 length:(unsigned int)fp12;
@end

@interface NSData(MimeDataEncoding)
+ (unsigned int)quotedPrintableLengthOfHeaderBytes:(const STR)fp8 length:(unsigned int)fp12;
- decodeQuotedPrintableForText:(char)fp8;
- encodeQuotedPrintableForText:(char)fp8;
- decodeBase64;
- (char)isValidBase64Data;
- encodeBase64WithoutLineBreaks;
- encodeBase64;
- decodeModifiedBase64;
- encodeModifiedBase64;
- encodeBase64HeaderData;
@end

@interface NSMutableData(RFC2231Support)
- (void)appendRFC2231CompliantValue:fp8 forKey:fp12;
@end

@interface NSMutableData(NSDataUtils)
- (void)appendCString:(const STR)fp8;
- (void)appendByte:(char)fp8;
- (void)convertNetworkLineEndingsToUnix;
@end

@interface NSData(NSDataUtils)
- unquotedFromSpaceDataWithRange:(struct _NSRange)fp8;
- quotedFromSpaceDataForMessage;
- (struct _NSRange)rangeOfRFC822HeaderData;
- subdataToIndex:(unsigned int)fp8;
- subdataFromIndex:(unsigned int)fp8;
- (struct _NSRange)rangeOfData:fp8;
- (struct _NSRange)rangeOfData:fp8 options:(unsigned int)fp12;
- (struct _NSRange)rangeOfData:fp8 options:(unsigned int)fp12 range:(struct _NSRange)fp16;
- (struct _NSRange)rangeOfByteFromSet:fp8;
- (struct _NSRange)rangeOfByteFromSet:fp8 options:(unsigned int)fp12;
- (struct _NSRange)rangeOfByteFromSet:fp8 options:(unsigned int)fp12 range:(struct _NSRange)fp16;
- (struct _NSRange)rangeOfCString:(const STR)fp8;
- (struct _NSRange)rangeOfCString:(const STR)fp8 options:(unsigned int)fp12;
- (struct _NSRange)rangeOfCString:(const STR)fp8 options:(unsigned int)fp12 range:(struct _NSRange)fp16;
- componentsSeparatedByData:fp8;
- dataByConvertingUnixNewlinesToNetwork;
- MD5Digest;
@end

@interface NSData(HFSDataConversion)
- wrapperForAppleFileDataWithFileEncodingHint:(unsigned long)fp8;
- wrapperForBinHex40DataWithFileEncodingHint:(unsigned long)fp8;
@end

@interface NSData(UuEnDeCode)
- uudecodedDataIntoFile:(id *)fp8 mode:(unsigned int *)fp12;
- uuencodedDataWithFile:fp8 mode:(unsigned int)fp12;
@end

#endif
