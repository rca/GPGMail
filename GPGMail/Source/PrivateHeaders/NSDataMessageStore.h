#ifdef SNOW_LEOPARD_64

#import <MessageStore.h>

@interface NSDataMessageStore : MessageStore
{
	NSData *_data;
}

- (id)initWithData:(id)arg1;
- (id)init;
- (id)initWithMailboxUid:(id) arg1 readOnly:(BOOL)arg2;
- (id)willDealloc;
- (void)dealloc;
- (id)storePath;
- (void)writeUpdatedMessageDataToDisk;
- (id)message;
- (id)headerDataForMessage:(id) arg1 fetchIfNotAvailable:(BOOL)arg2;
- (id)bodyDataForMessage:(id) arg1 fetchIfNotAvailable:(BOOL)arg2;
- (id)_cachedBodyForMessage:(id) arg1 valueIfNotPresent:(id)arg2;
- (id)_cachedHeadersForMessage:(id) arg1 valueIfNotPresent:(id)arg2;

@end

#elif defined(SNOW_LEOPARD)

@interface NSDataMessageStore : MessageStore
{
	NSData *_data;
}

- (id)initWithData:(id)arg1;
- (id)init;
- (id)initWithMailboxUid:(id) arg1 readOnly:(BOOL)arg2;
- (id)willDealloc;
- (void)dealloc;
- (id)storePath;
- (void)writeUpdatedMessageDataToDisk;
- (id)message;
- (id)headerDataForMessage:(id) arg1 fetchIfNotAvailable:(BOOL)arg2;
- (id)bodyDataForMessage:(id) arg1 fetchIfNotAvailable:(BOOL)arg2;
- (id)_cachedBodyForMessage:(id) arg1 valueIfNotPresent:(id)arg2;
- (id)_cachedHeadersForMessage:(id) arg1 valueIfNotPresent:(id)arg2;

@end


#endif // ifdef SNOW_LEOPARD_64
