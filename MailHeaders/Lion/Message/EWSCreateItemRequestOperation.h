/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */

#import <Message/EWSRequestOperation.h>

#import "NSCoding-Protocol.h"

@class NSString;

@interface EWSCreateItemRequestOperation : EWSRequestOperation <NSCoding>
{
    NSString *_EWSFolderIdString;
    NSString *_offlineCreatedEWSItemIdString;
    long long _disposition;
    BOOL _messageType;
    BOOL _wroteOfflineData;
}

+ (Class)classForResponse;
- (id)initWithFolderIdString:(id)arg1 messageType:(BOOL)arg2 disposition:(long long)arg3 gateway:(id)arg4 errorHandler:(id)arg5;
- (void)_ewsCreateItemRequestOperationCommonInitWithFolderIdString:(id)arg1 messageType:(BOOL)arg2 disposition:(long long)arg3;
- (id)initWithGateway:(id)arg1 errorHandler:(id)arg2;
- (id)initWithCoder:(id)arg1;
- (void)encodeWithCoder:(id)arg1;
- (void)dealloc;
- (id)activityString;
- (void)setupOfflineResponse;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
@property(nonatomic) BOOL wroteOfflineData; // @synthesize wroteOfflineData=_wroteOfflineData;
@property(retain) NSString *offlineCreatedEWSItemIdString; // @synthesize offlineCreatedEWSItemIdString=_offlineCreatedEWSItemIdString;
@property(nonatomic) long long disposition; // @synthesize disposition=_disposition;
@property(nonatomic) BOOL messageType; // @synthesize messageType=_messageType;
@property(retain, nonatomic) NSString *EWSFolderIdString; // @synthesize EWSFolderIdString=_EWSFolderIdString;

@end

