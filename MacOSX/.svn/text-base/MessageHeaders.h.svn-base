/* MessageHeaders.h created by dave on Sat 25-Sep-1999 */

#import <Cocoa/Cocoa.h>

#ifdef LEOPARD

@interface MessageHeaders : NSObject <NSCopying>
{
    NSData *_data;
    unsigned int _preferredEncoding;
}

+ (BOOL)isStructuredHeaderKey:(id)fp8;
+ (BOOL)_isImageHeaderKey:(id)fp8;
+ (const char *)cstringForKey:(id)fp8;
+ (id)localizedHeaders;
+ (id)localizedHeadersFromEnglishHeaders:(id)fp8;
+ (id)englishHeadersFromLocalizedHeaders:(id)fp8;
- (id)initWithHeaderData:(id)fp8 encoding:(unsigned long)fp12;
- (id)copyWithZone:(struct _NSZone *)fp8;
- (void)dealloc;
- (void)finalize;
- (id)mutableCopy;
- (id)headerData;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)fp8;
- (id)htmlHeaderKey:(id)fp8 useBold:(BOOL)fp12;
- (id)htmlValueWithKey:(id)fp8 value:(id)fp12 useBold:(BOOL)fp16;
- (id)htmlStringShowingHeaderDetailLevel:(int)fp8;
- (id)htmlStringShowingHeaderDetailLevel:(int)fp8 useBold:(BOOL)fp12;
- (id)attributedStringShowingHeaderDetailLevel:(int)fp8;
- (id)attributedStringShowingHeaderDetailLevel:(int)fp8 useHeadIndents:(BOOL)fp12 useBold:(BOOL)fp16 includeBCC:(BOOL)fp20;
- (id)headersDictionaryWithHeaderDetailLevel:(int)fp8;
- (id)headersDictionaryWithHeaderDetailLevel:(int)fp8 forMessageType:(int)fp12;
- (id)allHeaderKeys;
- (void)_setCapitalizedKey:(id)fp8 forKey:(id)fp12;
- (id)_capitalizedKeyForKey:(id)fp8;
- (id)_createHeaderValueForKey:(id)fp8 offset:(unsigned int *)fp12;
- (id)_createHeaderValueForKey:(id)fp8;
- (BOOL)hasHeaderForKey:(id)fp8;
- (id)headersForKey:(id)fp8;
- (id)firstHeaderForKey:(id)fp8;
- (id)_decodeHeaderKeysFromData:(id)fp8;
- (id)isoLatin1CharsetHint;
- (id)mailVersion;
- (BOOL)messageIsFromMicrosoft;
- (void)_appendAddressList:(id)fp8 toData:(id)fp12;
- (id)encodedHeaders;
- (id)encodedHeadersIncludingFromSpace:(BOOL)fp8;
- (void)_appendHeaderData:(id)fp8 andRecipients:(id)fp12 expandPrivate:(BOOL)fp16 includeComment:(BOOL)fp20;
- (void)appendHeaderData:(id)fp8 andRecipients:(id)fp12;
- (id)allRecipientsExpandPrivate:(BOOL)fp8 includeComment:(BOOL)fp12;
- (id)_encodedHeadersIncludingFromSpace:(BOOL)fp8;

@end

#elif defined(TIGER)

@class Message;

@interface MessageHeaders : NSObject <NSCopying>
{
    NSData *_data;
    unsigned int _preferredEncoding;
}

+ (id)localizedHeaders;
+ (id)localizedHeadersFromEnglishHeaders:(id)fp8;
+ (id)englishHeadersFromLocalizedHeaders:(id)fp8;
- (id)initWithHeaderData:(id)fp8 encoding:(unsigned long)fp12;
- (id)copyWithZone:(struct _NSZone *)fp8;
- (void)dealloc;
- (void)finalize;
- (id)mutableCopy;
- (id)headerData;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)fp8;
- (BOOL)_isStructuredHeaderKey:(id)fp8;
- (id)attributedStringShowingHeaderDetailLevel:(int)fp8;
- (id)headersDictionaryWithHeaderDetailLevel:(int)fp8;
- (id)allHeaderKeys;
- (void)_setCapitalizedKey:(id)fp8 forKey:(id)fp12;
- (id)_capitalizedKeyForKey:(id)fp8;
- (id)_headerValueForKey:(id)fp8 offset:(unsigned int *)fp12;
- (id)_headerValueForKey:(id)fp8;
- (BOOL)hasHeaderForKey:(id)fp8;
- (id)headersForKey:(id)fp8;
- (id)firstHeaderForKey:(id)fp8;
- (id)_decodeHeaderKeysFromData:(id)fp8;
- (id)isoLatin1CharsetHint;
- (id)mailVersion;
- (BOOL)messageIsFromEntourage;
- (void)_appendAddressList:(id)fp8 toData:(id)fp12;
- (id)encodedHeaders;
- (id)encodedHeadersIncludingFromSpace:(BOOL)fp8;
- (void)_appendHeaderData:(id)fp8 andRecipients:(id)fp12 expandPrivate:(BOOL)fp16 includeComment:(BOOL)fp20;
- (void)appendHeaderData:(id)fp8 andRecipients:(id)fp12;
- (id)allRecipientsExpandPrivate:(BOOL)fp8 includeComment:(BOOL)fp12;
- (id)_encodedHeadersIncludingFromSpace:(BOOL)fp8;

@end

#else

@interface MessageHeaders:NSObject <NSCopying>
{
    NSData *_data;	// 4 = 0x4
    unsigned int _preferredEncoding;	// 8 = 0x8
}

+ localizedHeaders;
+ localizedHeadersFromEnglishHeaders:fp8;
+ englishHeadersFromLocalizedHeaders:fp8;
- initWithHeaderData:fp8 encoding:(unsigned long)fp12;
- copyWithZone:(struct _NSZone *)fp8;
- (void)dealloc;
- mutableCopy;
- headerData;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)fp8;
- (char)_isStructuredHeaderKey:fp8;
- attributedStringShowingHeaderDetailLevel:(int)fp8;
- headersDictionaryWithHeaderDetailLevel:(int)fp8;
- allHeaderKeys;
- (void)_setCapitalizedKey:fp8 forKey:fp12;
- _capitalizedKeyForKey:fp8;
- _headerValueForKey:fp8;
- (char)hasHeaderForKey:fp8;
- headersForKey:fp8;
- firstHeaderForKey:fp8;
- _decodeHeaderKeysFromData:fp8;
- isoLatin1CharsetHint;
- (void)_appendAddressList:fp8 toData:fp12;
- encodedHeaders;
- encodedHeadersIncludingFromSpace:(char)fp8;
- (void)appendHeaderData:fp8 andRecipients:fp12;
- _encodedHeadersIncludingFromSpace:(char)fp8;

@end

#endif
