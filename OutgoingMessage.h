#ifdef SNOW_LEOPARD

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

#elif defined(LEOPARD)

#import <Message.h>

@interface OutgoingMessage : Message
{
    NSData *rawData;
    NSString *remoteID;
    unsigned int bodyOffset;
    unsigned int localAttachmentsSize;
    MessageBody *messageBody;
    MutableMessageHeaders *messageHeaders;
}

- (void)dealloc;
- (id)bodyData;
- (id)messageStore;
- (id)messageBody;
- (id)messageBodyIfAvailable;
- (id)messageDataIncludingFromSpace:(BOOL)fp8 newDocumentID:(id)fp12;
- (id)messageDataIncludingFromSpace:(BOOL)fp8;
- (id)mutableHeaders;
- (void)setMutableHeaders:(id)fp8;
- (id)headers;
- (id)headersIfAvailable;
- (unsigned int)messageSize;
- (void)setRawData:(id)fp8 offsetOfBody:(unsigned int)fp12;
- (void)setLocalAttachmentsSize:(unsigned int)fp8;
- (void)setRemoteID:(id)fp8;
- (id)remoteID;

@end

#endif
