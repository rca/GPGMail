/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

@class MFRemoteStore, NSMutableArray;

@interface _MFLibraryThreadRequest : NSObject
{
    BOOL _isFollowOnToProgressTask;
    NSMutableArray *_messages;
    MFRemoteStore *_store;
}

@property(nonatomic) BOOL isFollowOnToProgressTask; // @synthesize isFollowOnToProgressTask=_isFollowOnToProgressTask;
@property(readonly, nonatomic) MFRemoteStore *store; // @synthesize store=_store;
@property(retain, nonatomic) NSMutableArray *messages; // @synthesize messages=_messages;
- (void).cxx_destruct;
- (id)init;
- (id)initWithStore:(id)arg1 andMessages:(id)arg2;

@end

