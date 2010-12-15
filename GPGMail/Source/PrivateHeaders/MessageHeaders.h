/* MessageHeaders.h created by dave on Sat 25-Sep-1999 */

#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

@interface MessageHeaders : NSObject <NSCopying>
{
    NSData *_data;
    unsigned int _preferredEncoding;
}

+ (void)initialize;
+ (BOOL)isStructuredHeaderKey:(id)arg1;
+ (BOOL)_isImageHeaderKey:(id)arg1;
+ (const char *)cstringForKey:(id)arg1;
+ (id)localizedHeaders;
+ (id)localizedHeadersFromEnglishHeaders:(id)arg1;
+ (id)englishHeadersFromLocalizedHeaders:(id)arg1;
- (id)initWithHeaderData:(id)arg1 encoding:(unsigned int)arg2;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)dealloc;
- (void)finalize;
- (id)mutableCopy;
- (id)headerData;
- (unsigned int)preferredEncoding;
- (void)setPreferredEncoding:(unsigned int)arg1;
- (id)htmlHeaderKey:(id)arg1 useBold:(BOOL)arg2 useGray:(BOOL)arg3;
- (id)htmlValueWithKey:(id)arg1 value:(id)arg2 useBold:(BOOL)arg3;
- (id)htmlStringShowingHeaderDetailLevel:(int)arg1;
- (id)htmlStringShowingHeaderDetailLevel:(int)arg1 useBold:(BOOL)arg2 useGray:(BOOL)arg3;
- (id)attributedStringShowingHeaderDetailLevel:(int)arg1;
- (id)attributedStringShowingHeaderDetailLevel:(int)arg1 useHeadIndents:(BOOL)arg2 useBold:(BOOL)arg3 includeBCC:(BOOL)arg4;
- (id)headersDictionaryWithHeaderDetailLevel:(int)arg1;
- (id)headersDictionaryWithHeaderDetailLevel:(int)arg1 forMessageType:(BOOL)arg2;
- (id)allHeaderKeys;
- (void)_setCapitalizedKey:(id)arg1 forKey:(id)arg2;
- (id)_capitalizedKeyForKey:(id)arg1;
- (id)_createHeaderValueForKey:(id)arg1 offset:(unsigned long long *)arg2;
- (id)_createHeaderValueForKey:(id)arg1;
- (BOOL)hasHeaderForKey:(id)arg1;
- (id)headersForKey:(id)arg1;
- (id)firstHeaderForKey:(id)arg1;
- (id)_decodeHeaderKeysFromData:(id)arg1;
- (id)isoLatin1CharsetHint;
- (id)mailVersion;
- (BOOL)messageIsFromMicrosoft;
- (void)_appendAddressList:(id)arg1 toData:(id)arg2;
- (id)encodedHeaders;
- (id)encodedHeadersIncludingFromSpace:(BOOL)arg1;
- (void)appendHeaderData:(id)arg1 andRecipients:(id)arg2 recipientsByHeaderKey:(id)arg3 expandPrivate:(BOOL)arg4 includeComment:(BOOL)arg5;
- (void)appendHeaderData:(id)arg1 andRecipients:(id)arg2 recipientsByHeaderKey:(id)arg3;
- (id)allRecipientsExpandPrivate:(BOOL)arg1 includeComment:(BOOL)arg2;
- (id)_encodedHeadersIncludingFromSpace:(BOOL)arg1;

@end

#elif defined(SNOW_LEOPARD)

@interface MessageHeaders : NSObject <NSCopying>
{
    NSData *_data;
    unsigned int _preferredEncoding;
}

+ (void)initialize;
+ (BOOL)isStructuredHeaderKey:(id)arg1;
+ (BOOL)_isImageHeaderKey:(id)arg1;
+ (const char *)cstringForKey:(id)arg1;
+ (id)localizedHeaders;
+ (id)localizedHeadersFromEnglishHeaders:(id)arg1;
+ (id)englishHeadersFromLocalizedHeaders:(id)arg1;
- (id)initWithHeaderData:(id)arg1 encoding:(unsigned long)arg2;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)dealloc;
- (void)finalize;
- (id)mutableCopy;
- (id)headerData;
- (unsigned long)preferredEncoding;
- (void)setPreferredEncoding:(unsigned long)arg1;
- (id)htmlHeaderKey:(id)arg1 useBold:(BOOL)arg2 useGray:(BOOL)arg3;
- (id)htmlValueWithKey:(id)arg1 value:(id)arg2 useBold:(BOOL)arg3;
- (id)htmlStringShowingHeaderDetailLevel:(int)arg1;
- (id)htmlStringShowingHeaderDetailLevel:(int)arg1 useBold:(BOOL)arg2 useGray:(BOOL)arg3;
- (id)attributedStringShowingHeaderDetailLevel:(int)arg1;
- (id)attributedStringShowingHeaderDetailLevel:(int)arg1 useHeadIndents:(BOOL)arg2 useBold:(BOOL)arg3 includeBCC:(BOOL)arg4;
- (id)headersDictionaryWithHeaderDetailLevel:(int)arg1;
- (id)headersDictionaryWithHeaderDetailLevel:(int)arg1 forMessageType:(BOOL)arg2;
- (id)allHeaderKeys;
- (void)_setCapitalizedKey:(id)arg1 forKey:(id)arg2;
- (id)_capitalizedKeyForKey:(id)arg1;
- (id)_createHeaderValueForKey:(id)arg1 offset:(unsigned int *)arg2;
- (id)_createHeaderValueForKey:(id)arg1;
- (BOOL)hasHeaderForKey:(id)arg1;
- (id)headersForKey:(id)arg1;
- (id)firstHeaderForKey:(id)arg1;
- (id)_decodeHeaderKeysFromData:(id)arg1;
- (id)isoLatin1CharsetHint;
- (id)mailVersion;
- (BOOL)messageIsFromMicrosoft;
- (void)_appendAddressList:(id)arg1 toData:(id)arg2;
- (id)encodedHeaders;
- (id)encodedHeadersIncludingFromSpace:(BOOL)arg1;
- (void)appendHeaderData:(id)arg1 andRecipients:(id)arg2 recipientsByHeaderKey:(id)arg3 expandPrivate:(BOOL)arg4 includeComment:(BOOL)arg5;
- (void)appendHeaderData:(id)arg1 andRecipients:(id)arg2 recipientsByHeaderKey:(id)arg3;
- (id)allRecipientsExpandPrivate:(BOOL)arg1 includeComment:(BOOL)arg2;
- (id)_encodedHeadersIncludingFromSpace:(BOOL)arg1;

@end

#endif
