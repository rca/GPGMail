/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "MCAccount.h"

@protocol MCMailAccount <MCAccount>
- (void)incrementTotalCountOfMessagesReceived:(unsigned long long)arg1;
- (void)incrementCountOfNewUnreadMessagesReceivedInInbox:(unsigned long long)arg1;
- (void)newUnreadMessagesHaveBeenReceivedInInbox;
- (id)remoteTaskQueue;
@end

