/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

#import "MFMessageConsumer.h"

@class NSMutableArray;

@interface _MFMessageCollector : NSObject <MFMessageConsumer>
{
    NSMutableArray *_messages;
    int _accessNumber;
    BOOL _didCancel;
}

- (void)finishedSendingMessages;
- (BOOL)didCancel;
@property(readonly) BOOL shouldCancel;
- (void)newMessagesAvailable:(id)arg1 conversationMembers:(id)arg2;
- (void)newMessagesAvailable:(id)arg1 conversationsMembersByConversationID:(id)arg2 options:(id)arg3;
- (void)newMessagesAvailable:(id)arg1 conversationsMembersByConversationID:(id)arg2;
- (id)messages;
- (void)dealloc;
- (id)init;

@end

