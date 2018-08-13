/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

#import "MCActivityTarget.h"
#import "MessageDeletionTransfer.h"

@class NSArray, NSMutableArray, NSString;

@interface MessageTransfer : NSObject <MCActivityTarget, MessageDeletionTransfer>
{
    NSMutableArray *_operations;
    BOOL _deleteOriginals;
    BOOL _allowsUndo;
    BOOL _registeredForUndo;
    BOOL _isDeleteOperation;
    BOOL _isArchiveOperation;
    BOOL _undoInProgress;
    BOOL _needToUndoTransfer;
    id <MessageTransferDelegate> _delegate;
    NSArray *_sourceLabels;
}

+ (void)queueMailboxDeletions:(id)arg1;
+ (BOOL)_shouldProceedWithMailboxDeletions:(id)arg1;
+ (void)_redo:(id)arg1;
+ (void)_undo:(id)arg1;
+ (void)initialize;
@property(nonatomic) BOOL needToUndoTransfer; // @synthesize needToUndoTransfer=_needToUndoTransfer;
@property(nonatomic) BOOL undoInProgress; // @synthesize undoInProgress=_undoInProgress;
@property(nonatomic) BOOL isArchiveOperation; // @synthesize isArchiveOperation=_isArchiveOperation;
@property(nonatomic) BOOL isDeleteOperation; // @synthesize isDeleteOperation=_isDeleteOperation;
@property(nonatomic) BOOL registeredForUndo; // @synthesize registeredForUndo=_registeredForUndo;
@property(copy) NSArray *sourceLabels; // @synthesize sourceLabels=_sourceLabels;
@property BOOL allowsUndo; // @synthesize allowsUndo=_allowsUndo;
@property BOOL deleteOriginals; // @synthesize deleteOriginals=_deleteOriginals;
@property __weak id <MessageTransferDelegate> delegate; // @synthesize delegate=_delegate;
- (void).cxx_destruct;
- (id)_undoActionNameForMessageCount:(unsigned long long)arg1;
- (BOOL)anySourceStoreAllowsDeleteInPlace;
- (id)sourceStores;
- (id)destinationMailboxes;
- (void)_synchronouslyPerformTransfer;
- (void)_postDidEndDocumentTransferNotification:(id)arg1 result:(long long)arg2 destinationAccount:(id)arg3 missedMessages:(id)arg4;
- (void)_postWillBeginDocumentTransferNotification:(id)arg1;
- (void)_redo;
- (void)_undoSettingFlags:(id)arg1 transferringMessages:(id)arg2;
- (void)_undoSettingFlagsCompletedWithMessages:(id)arg1;
- (void)_undo;
- (void)_registerForUndoType:(int)arg1;
- (void)_completedTransferWithError:(id)arg1;
- (void)beginTransfer;
- (BOOL)canBeginTransfer;
- (id)initWithMessages:(id)arg1 targetMailbox:(id)arg2 isDeleteOperation:(BOOL)arg3 isArchiveOperation:(BOOL)arg4;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

