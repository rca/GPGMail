#ifdef SNOW_LEOPARD_64

#import <Message.h>

@interface OutgoingMessage : Message
{
    NSData *rawData;
    NSString *remoteID;
    NSString *existingRemoteID;
    unsigned long long bodyOffset;
    unsigned long long localAttachmentsSize;
    MessageBody *messageBody;
    MutableMessageHeaders *messageHeaders;
}

- (void)dealloc;
- (id)bodyData;
- (id)messageStore;
- (id)messageBodyIfAvailable;
- (id)messageDataIncludingFromSpace:(BOOL)arg1 newDocumentID:(id)arg2;
- (id)messageDataIncludingFromSpace:(BOOL)arg1;
- (id)mutableHeaders;
- (void)setMutableHeaders:(id)arg1;
- (id)headers;
- (id)headersIfAvailable;
- (unsigned long long)messageSize;
- (void)setRawData:(id)arg1 offsetOfBody:(unsigned long long)arg2;
- (void)setLocalAttachmentsSize:(unsigned long long)arg1;
- (void)setRemoteID:(id)arg1;
- (id)remoteID;
@property(retain, nonatomic) NSString *existingRemoteID; // @synthesize existingRemoteID;
@property(retain, nonatomic) MessageBody *messageBody; // @synthesize messageBody;

@end

#elif defined(SNOW_LEOPARD)

#import <Message.h>

@interface OutgoingMessage : Message
{
    NSData *rawData;
    NSString *remoteID;
    NSString *existingRemoteID;
    unsigned int bodyOffset;
    unsigned int localAttachmentsSize;
    MessageBody *messageBody;
    MutableMessageHeaders *messageHeaders;
}

- (void)dealloc;
- (id)bodyData;
- (id)messageStore;
- (id)messageBodyIfAvailable;
- (id)messageDataIncludingFromSpace:(BOOL)arg1 newDocumentID:(id)arg2;
- (id)messageDataIncludingFromSpace:(BOOL)arg1;
- (id)mutableHeaders;
- (void)setMutableHeaders:(id)arg1;
- (id)headers;
- (id)headersIfAvailable;
- (unsigned int)messageSize;
- (void)setRawData:(id)arg1 offsetOfBody:(unsigned int)arg2;
- (void)setLocalAttachmentsSize:(unsigned int)arg1;
- (void)setRemoteID:(id)arg1;
- (id)remoteID;
- (id)existingRemoteID;
- (void)setExistingRemoteID:(id)arg1;
- (id)messageBody;
- (void)setMessageBody:(id)arg1;

@end

#endif
