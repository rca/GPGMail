
#import <MessageHeaders.h>

#ifdef SNOW_LEOPARD

@interface MutableMessageHeaders : MessageHeaders
{
    NSMutableDictionary *_headersAdded;
    NSMutableArray *_headersRemoved;
}

- (id)mutableCopy;
- (void)dealloc;
- (void)finalize;
- (id)allHeaderKeys;
- (BOOL)hasHeaderForKey:(id)arg1;
- (id)_createHeaderValueForKey:(id)arg1;
- (id)firstHeaderForKey:(id)arg1;
- (void)removeHeaderForKey:(id)arg1;
- (void)setHeader:(id)arg1 forKey:(id)arg2;
- (void)appendFromSpaceIfMissing;
- (void)_appendHeaderKey:(id)arg1 value:(id)arg2 toData:(id)arg3;
- (void)_appendAddedHeaderKey:(id)arg1 value:(id)arg2 toData:(id)arg3;
- (id)_encodedHeadersIncludingFromSpace:(BOOL)arg1;
- (void)setAddressList:(id)arg1 forKey:(id)arg2;
- (id)description;

@end

#elif defined(LEOPARD)

@interface MutableMessageHeaders : MessageHeaders
{
    NSMutableDictionary *_headersAdded;
    NSMutableArray *_headersRemoved;
}

- (id)mutableCopy;
- (void)dealloc;
- (void)finalize;
- (id)allHeaderKeys;
- (BOOL)hasHeaderForKey:(id)fp8;
- (id)_createHeaderValueForKey:(id)fp8;
- (id)firstHeaderForKey:(id)fp8;
- (void)removeHeaderForKey:(id)fp8;
- (void)setHeader:(id)fp8 forKey:(id)fp12;
- (void)appendFromSpaceIfMissing;
- (void)_appendHeaderKey:(id)fp8 value:(id)fp12 toData:(id)fp16;
- (void)_appendAddedHeaderKey:(id)fp8 value:(id)fp12 toData:(id)fp16;
- (id)_encodedHeadersIncludingFromSpace:(BOOL)fp8;
- (void)setAddressList:(id)fp8 forKey:(id)fp12;
- (id)description;

@end

#elif defined(TIGER)

@class NSMutableDictionary;
@class NSMutableArray;
@class NSData;

@interface MutableMessageHeaders : MessageHeaders
{
    NSMutableDictionary *_headersAdded;
    NSMutableArray *_headersRemoved;
}

- (id)mutableCopy;
- (void)dealloc;
- (void)finalize;
- (id)allHeaderKeys;
- (BOOL)hasHeaderForKey:(id)fp8;
- (id)_headerValueForKey:(id)fp8;
- (id)firstHeaderForKey:(id)fp8;
- (void)removeHeaderForKey:(id)fp8;
- (void)setHeader:(id)fp8 forKey:(id)fp12;
- (void)appendFromSpaceIfMissing;
- (void)_appendHeaderKey:(id)fp8 value:(id)fp12 toData:(id)fp16;
- (void)_appendAddedHeaderKey:(id)fp8 value:(id)fp12 toData:(id)fp16;
- (id)_encodedHeadersIncludingFromSpace:(BOOL)fp8;
- (void)setAddressList:(id)fp8 forKey:(id)fp12;

@end

#else

@interface MutableMessageHeaders:MessageHeaders
{
    NSMutableDictionary *_headersAdded;	// 12 = 0xc
    NSMutableArray *_headersRemoved;	// 16 = 0x10
}

- mutableCopy;
- (void)dealloc;
- allHeaderKeys;
- (char)hasHeaderForKey:fp8;
- _headerValueForKey:fp8;
- (void)removeHeaderForKey:fp8;
- (void)setHeader:fp8 forKey:fp12;
- (void)appendFromSpaceIfMissing;
- (void)_appendHeaderKey:fp8 value:fp12 toData:fp16;
- (void)_appendAddedHeaderKey:fp8 value:fp12 toData:fp16;
- _encodedHeadersIncludingFromSpace:(char)fp8;
- (void)setAddressList:fp8 forKey:fp12;

@end

#endif
