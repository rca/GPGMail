/* NSData+Message.h created by dave on Tue 21-Nov-2000 */

#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

@interface NSMutableData (MimeDataEncoding)
- (void)appendQuotedPrintableDataForHeaderBytes:(const char *)arg1 length:(unsigned long long)arg2;
@end

@interface NSMutableData (NSDataUtils)
- (void)appendCString:(const char *)arg1;
- (void)appendByte:(BOOL)arg1;
- (void)convertNetworkLineEndingsToUnix;
@end

@interface NSMutableData (RFC2231Support)
- (void)appendRFC2231CompliantValue:(id)arg1 forKey:(id)arg2 withEncodingHint:(unsigned int)arg3;
@end

@interface NSData (HFSDataConversion)
- (id)wrapperForAppleFileDataWithFileEncodingHint:(unsigned int)arg1;
- (id)wrapperForBinHex40DataWithFileEncodingHint:(unsigned int)arg1;
@end

@interface NSData (MimeDataEncoding)
+ (unsigned long long)quotedPrintableLengthOfHeaderBytes:(const char *)arg1 length:(unsigned long long)arg2;
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
- (id)subdataToIndex:(unsigned long long)arg1;
- (id)subdataFromIndex:(unsigned long long)arg1;
- (struct _NSRange)rangeOfData:(id)arg1;
- (struct _NSRange)rangeOfData:(id)arg1 options:(unsigned long long)arg2;
- (struct _NSRange)rangeOfData:(id)arg1 options:(unsigned long long)arg2 range:(struct _NSRange)arg3;
- (struct _NSRange)rangeOfByteFromSet:(id)arg1;
- (struct _NSRange)rangeOfByteFromSet:(id)arg1 options:(unsigned long long)arg2;
- (struct _NSRange)rangeOfByteFromSet:(id)arg1 options:(unsigned long long)arg2 range:(struct _NSRange)arg3;
- (struct _NSRange)rangeOfCString:(const char *)arg1;
- (struct _NSRange)rangeOfCString:(const char *)arg1 options:(unsigned long long)arg2;
- (struct _NSRange)rangeOfCString:(const char *)arg1 options:(unsigned long long)arg2 range:(struct _NSRange)arg3;
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

#elif defined(SNOW_LEOPARD)

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

#endif
