
#import <MessageHeaders.h>

#ifdef SNOW_LEOPARD_64

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
- (void)setHeader:(id) arg1 forKey:(id)arg2;
- (void)appendFromSpaceIfMissing;
- (void)_appendHeaderKey:(id) arg1 value:(id) arg2 toData:(id)arg3;
- (void)_appendAddedHeaderKey:(id) arg1 value:(id) arg2 toData:(id)arg3;
- (id)_encodedHeadersIncludingFromSpace:(BOOL)arg1;
- (void)setAddressList:(id) arg1 forKey:(id)arg2;
- (id)description;

@end

#elif defined(SNOW_LEOPARD)

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
- (void)setHeader:(id) arg1 forKey:(id)arg2;
- (void)appendFromSpaceIfMissing;
- (void)_appendHeaderKey:(id) arg1 value:(id) arg2 toData:(id)arg3;
- (void)_appendAddedHeaderKey:(id) arg1 value:(id) arg2 toData:(id)arg3;
- (id)_encodedHeadersIncludingFromSpace:(BOOL)arg1;
- (void)setAddressList:(id) arg1 forKey:(id)arg2;
- (id)description;

@end


#endif // ifdef SNOW_LEOPARD_64
