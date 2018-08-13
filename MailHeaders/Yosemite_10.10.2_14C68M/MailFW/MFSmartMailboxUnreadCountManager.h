/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

#import "MCActivityTarget.h"

@class NSConditionLock, NSMutableArray, NSMutableDictionary, NSMutableSet, NSOperationQueue, NSString, _MFNonContentSmartMailboxUnreadCountManager;

@interface MFSmartMailboxUnreadCountManager : NSObject <MCActivityTarget>
{
    NSMutableArray *_smartMailboxes;
    NSMutableDictionary *_smartMailboxesOpenDates;
    BOOL _updateNeededAfterOpeningMailboxes;
    NSMutableDictionary *_unreadMessagesBySmartMailbox;
    NSMutableDictionary *_smartMailboxesUpdates;
    NSConditionLock *_watchedMessagesLock;
    NSMutableDictionary *_watchedMessages;
    NSMutableDictionary *_messagesNeedingToBeIndexed;
    NSConditionLock *_isUpdatingStateLock;
    NSConditionLock *_isDirtyStateLock;
    NSConditionLock *_obsoleteMessageKeysLock;
    NSMutableSet *_obsoleteMessageKeys;
    _MFNonContentSmartMailboxUnreadCountManager *_nonContentSmartMailboxUnreadCountManager;
    BOOL _suspendSmartMailboxUnreadCountCalculations;
    double _lastModificationToUpdate;
    long long _unreadQueryCount;
    NSOperationQueue *_spotlightQueue;
}

+ (id)sharedInstance;
+ (id)allocWithZone:(struct _NSZone *)arg1;
+ (void)initialize;
@property(readonly, nonatomic) NSOperationQueue *spotlightQueue; // @synthesize spotlightQueue=_spotlightQueue;
@property long long unreadQueryCount; // @synthesize unreadQueryCount=_unreadQueryCount;
@property BOOL suspendSmartMailboxUnreadCountCalculations; // @synthesize suspendSmartMailboxUnreadCountCalculations=_suspendSmartMailboxUnreadCountCalculations;
@property double lastModificationToUpdate; // @synthesize lastModificationToUpdate=_lastModificationToUpdate;
- (void).cxx_destruct;
- (void)_updateObsoleteMessageKeys;
- (void)_addObsoleteMessageKeys:(id)arg1;
- (id)_messageKeysWaitingToBeIndexes;
- (BOOL)_isMessageIndexed:(id)arg1;
- (void)_addMessagesWaitingToBeIndexed:(id)arg1;
- (void)_updateSmartMailboxUnreadCountsByRemovingMessagesWithKeys:(id)arg1;
- (void)_updateSmartMailboxUnreadCountsWithMessages:(id)arg1;
- (id)_filterMessages:(id)arg1 matchingCriterion:(id)arg2;
- (void)_updateUnreadCountsWithWatchedMessages;
- (void)_performUpdateNow;
- (void)_performDelayedUpdate:(id)arg1;
- (void)_watchMessages:(id)arg1 withUnreadState:(BOOL)arg2 onDate:(id)arg3;
- (unsigned long long)_uniqueCountOfMessages:(id)arg1;
- (void)_setUnreadMessages:(id)arg1 forSmartMailbox:(id)arg2 onDate:(id)arg3;
- (void)_searchedMailboxPreferencesChanged:(id)arg1;
- (void)_smartMailboxesDidSaveToDisk:(id)arg1;
- (void)_smartMailboxesWillSaveToDisk:(id)arg1;
- (void)_storeDidOpen:(id)arg1;
- (void)_storeWillOpen:(id)arg1;
- (void)_mailboxesDeleted:(id)arg1;
- (void)_messagesCompacted:(id)arg1;
- (void)_messageFlagsChanged:(id)arg1;
- (void)_messagesAdded:(id)arg1;
- (void)_stopObservingNotifications;
- (void)_startObservingNotifications;
- (BOOL)_isObservingSmartMailbox:(id)arg1;
- (void)_setSmartMailboxesWithSpotlightCriterion:(id)arg1;
- (id)_pathForMessage:(id)arg1;
- (void)_decomposeMessageKey:(id)arg1 intoRowID:(id *)arg2 messageIDHeader:(id *)arg3;
- (id)_keyForMessage:(id)arg1;
- (id)_keyForMailbox:(id)arg1;
- (void)_setIsDirty:(BOOL)arg1;
- (void)_setIsUpdating:(BOOL)arg1;
- (void)smartMailbox:(id)arg1 willReturnDictionaryRepresentation:(id)arg2;
- (void)smartMailbox:(id)arg1 didInitializeWithDictionaryRepresentation:(id)arg2;
- (void)setSmartMailboxes:(id)arg1;
- (void)updateMailboxesUnreadCountUsingSpotlight:(id)arg1 useTotalCount:(BOOL)arg2;
- (void)_libraryMessagesFlagsChanged:(id)arg1;
- (void)_updateSmartMailboxUnreadCountUsingSpotlight:(id)arg1 useTotalCount:(BOOL)arg2;
- (BOOL)_canCreateQuery;
- (void)dealloc;
- (id)init;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

