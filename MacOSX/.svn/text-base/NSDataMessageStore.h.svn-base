#ifdef LEOPARD

#import <MessageStore.h>

@interface NSDataMessageStore : MessageStore
{
    NSData *_data;
}

- (id)initWithData:(id)fp8;
- (void)dealloc;
- (void)finalize;
- (id)storePath;
- (void)writeUpdatedMessageDataToDisk;
- (id)message;
- (id)headerDataForMessage:(id)fp8;
- (id)bodyDataForMessage:(id)fp8;
- (id)_cachedBodyForMessage:(id)fp8 valueIfNotPresent:(id)fp12;
- (id)_cachedHeadersForMessage:(id)fp8 valueIfNotPresent:(id)fp12;

@end

#elif defined(TIGER)

#import <MessageStore.h>

@interface NSDataMessageStore : MessageStore
{
    NSData *_data;
}

- (id)initWithData:(id)fp8;
- (void)dealloc;
- (void)finalize;
- (id)storePath;
- (void)writeUpdatedMessageDataToDisk;
- (id)message;
- (id)headerDataForMessage:(id)fp8;
- (id)bodyDataForMessage:(id)fp8;
- (id)_cachedBodyForMessage:(id)fp8 valueIfNotPresent:(id)fp12;
- (id)_cachedHeadersForMessage:(id)fp8 valueIfNotPresent:(id)fp12;

@end

#endif
