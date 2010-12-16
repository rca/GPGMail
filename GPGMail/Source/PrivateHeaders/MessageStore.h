#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

#import <SafeObserver.h>

@class MailboxUid;
@class MailAccount;
@class ObjectCache;
@class ActivityMonitor;

@interface MessageStore : SafeObserver
{
	BOOL _isReadOnly;
	BOOL _hasUnsavedChangesToMessageData;
	BOOL _haveOpenLockFile;
	BOOL _forceInvalidation;
	BOOL _isWritingChangesToDisk;
	BOOL _isTryingToClose;
	BOOL _compactOnClose;
	MailboxUid * _mailboxUid;
	MailAccount * _account;
	NSMutableArray * _allMessages;
	id _messageCountsAndSizesLock;
	struct {
		unsigned long long unreadCount;
		unsigned long long unseenCount;
		unsigned long long deletedCount;
		unsigned long long totalSize;
		unsigned long long deletedSize;
	} _messageCountsAndSizes;
	id _cacheLock;
	NSCache * _headerDataCache;
	NSCache * _headerCache;
	NSCache * _bodyDataCache;
	NSCache * _bodyCache;
	NSMutableSet * _uniqueStrings;
	int _storeState;
	NSTimer * _timer;
	ActivityMonitor * _openMonitor;
	NSMutableDictionary * _fetchLockMap;
}

+ (void)initialize;
+ (id)_storeCacheMapTable;
+ (unsigned long long)numberOfCurrentlyOpenStores;
+ (id)descriptionOfOpenStores;
+ (id)_storeCreationMarker;
+ (id)_copyRawAvailableStoreForUid:(id) arg1 wantsCreate:(BOOL) arg2 shouldCreate:(char *)arg3;
+ (id)currentlyAvailableStoreForUid:(id)arg1;
+ (id)currentlyAvailableStoresForAccount:(id)arg1;
+ (void)registerAvailableStore:(id) arg1 forUid:(id)arg2;
+ (void)removeStoreFromCache:(id)arg1;
+ (BOOL)createEmptyStoreIfNeededForPath:(id) arg1 notIndexable:(BOOL)arg2;
+ (BOOL)createEmptyStoreForPath:(id)arg1;
+ (BOOL)storeAtPathIsWritable:(id)arg1;
+ (BOOL)cheapStoreAtPathIsEmpty:(id)arg1;
+ (id)succesfulMessagesFromMessages:(id) arg1 unsuccessfulOnes:(id)arg2;
+ (int)copyMessages:(id) arg1 toMailboxUid:(id) arg2 shouldDelete:(BOOL)arg3;
- (void)queueSaveChangesInvocation;
- (id)willDealloc;
- (id)init;
- (id)initWithMailboxUid:(id) arg1 readOnly:(BOOL)arg2;
- (void)_messageStoreCommonInit;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)dealloc;
- (void)finalize;
- (void)openAsynchronously;
- (void)openAsynchronouslyWithOptions:(unsigned int)arg1;
- (void)openSynchronously;
- (void)openSynchronouslyUpdatingMetadata:(BOOL)arg1;
- (void)updateMetadataAsynchronously;
- (void)updateMetadata;
- (void)cleanupAsynchronously;
- (void)cleanupSynchronously;
- (void)willOpen;
- (void)didOpenWithMessages:(id)arg1;
- (void)cancelOpen;
- (void)writeUpdatedMessageDataToDisk;
- (void)invalidateSavingChanges:(BOOL)arg1;
- (id)account;
- (id)mailboxUid;
- (id)allMailboxUidRepresentations;
- (BOOL)isOpened;
- (id)displayName;
- (const char *)displayNameForLogging;
- (id)description;
- (BOOL)isTrash;
- (void)messageFlagsDidChange:(id) arg1 flags:(id)arg2;
- (void)structureDidChange;
- (void)messagesWereAdded:(id)arg1;
- (void)messagesWereCompacted:(id)arg1;
- (void)messagesWereUpdated:(id)arg1;
- (void)updateUserInfoToLatestValues;
- (unsigned long long)totalMessageSize;
- (void)deletedCount:(unsigned long long *)arg1 andSize:(unsigned long long *)arg2;
- (unsigned long long)totalCount;
- (unsigned long long)_totalNonDeletedCount;
- (unsigned long long)unreadCount;
- (unsigned long long)unseenCount;
- (unsigned long long)indexOfMessage:(id)arg1;
- (id)copyOfAllMessages;
- (id)mutableCopyOfAllMessages;
- (id)copyOfAllMessagesWithOptions:(unsigned int)arg1;
- (void)addMessagesToAllMessages:(id)arg1;
- (id)_defaultRouterDestination;
- (id)routeMessages:(id)arg1;
- (id)finishRoutingMessages:(id) arg1 routed:(id)arg2;
- (id)routeMessages:(id) arg1 isUserAction:(BOOL)arg2;
- (BOOL)canRebuild;
- (void)rebuildTableOfContentsAsynchronously;
- (BOOL)canCompact;
- (void)doCompact;
- (void)deleteMessagesOlderThanNumberOfDays:(long long)arg1 compact:(BOOL)arg2;
- (void)deleteMessages:(id) arg1 moveToTrash:(BOOL)arg2;
- (id)undeleteMessages:(id) arg1 movedToStore:(id) arg2 newMessageIDs:(id)arg3;
- (void)undeleteMessages:(id)arg1;
- (void)deleteLastMessageWithHeaders:(id) arg1 compactWhenDone:(BOOL)arg2;
- (BOOL)allowsAppend;
- (BOOL)allowsOverwrite;
- (BOOL)allowsDeleteInPlace;
- (int)undoAppendOfMessageIDs:(id)arg1;
- (void)finishCopyOfMessages:(id) arg1 fromStore:(id) arg2 originalsWereDeleted:(BOOL)arg3;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id) arg2 newMessageIDs:(id) arg3 newMessages:(id) arg4 newDocumentIDsByOld:(id) arg5 flagsToSet:(id) arg6 forMove:(BOOL) arg7 error:(id *)arg8;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id) arg2 newMessageIDs:(id) arg3 newMessages:(id) arg4 flagsToSet:(id) arg5 forMove:(BOOL) arg6 error:(id *)arg7;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id) arg2 newMessageIDs:(id) arg3 newMessages:(id) arg4 flagsToSet:(id) arg5 forMove:(BOOL)arg6;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id) arg2 newMessageIDs:(id) arg3 newMessages:(id) arg4 flagsToSet:(id)arg5;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id) arg2 newMessageIDs:(id) arg3 newMessages:(id) arg4 forMove:(BOOL)arg5;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id) arg2 newMessageIDs:(id) arg3 newMessages:(id)arg4;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id) arg2 newMessageIDs:(id)arg3;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id)arg2;
- (id)messageWithValue:(id) arg1 forHeader:(id) arg2 options:(unsigned long long)arg3;
- (id)messageForMessageID:(id)arg1;
- (unsigned long long)_numberOfMessagesToCache;
- (id)headerDataForMessage:(id) arg1 fetchIfNotAvailable:(BOOL)arg2;
- (id)headerDataForMessage:(id)arg1;
- (id)bodyDataForMessage:(id) arg1 fetchIfNotAvailable:(BOOL)arg2;
- (id)bodyDataForMessage:(id)arg1;
- (id)fullBodyDataForMessage:(id) arg1 andHeaderDataIfReadilyAvailable:(id *)arg2 fetchIfNotAvailable:(BOOL)arg3;
- (id)fullBodyDataForMessage:(id) arg1 andHeaderDataIfReadilyAvailable:(id *)arg2;
- (id)fullBodyDataForMessage:(id)arg1;
- (id)bodyForMessage:(id) arg1 fetchIfNotAvailable:(BOOL)arg2;
- (id)bodyForMessage:(id) arg1 fetchIfNotAvailable:(BOOL) arg2 updateFlags:(BOOL)arg3;
- (id)headersForMessage:(id)arg1;
- (id)headersForMessage:(id) arg1 fetchIfNotAvailable:(BOOL)arg2;
- (id)dataForMimePart:(id)arg1;
- (BOOL)hasCachedDataForMimePart:(id)arg1;
- (id)uniquedString:(id)arg1;
- (id)colorForMessage:(id)arg1;
- (id)setFlagsFromDictionary:(id) arg1 forMessages:(id)arg2;
- (id)setFlagsFromDictionary:(id) arg1 forToDos:(id)arg2;
- (void)setFlag:(id) arg1 state:(BOOL) arg2 forMessages:(id)arg3;
- (void)setColor:(id) arg1 highlightTextOnly:(BOOL) arg2 forMessages:(id)arg3;
- (void)messageColorsNeedToBeReevaluated;
- (void)startSynchronization;
- (id)_getSerialNumberString;
- (void)setNumberOfAttachments:(unsigned int)arg1 isSigned:(BOOL) arg2 isEncrypted:(BOOL) arg3 forMessage:(id)arg4;
- (void)updateNumberOfAttachmentsForMessages:(id)arg1;
- (void)updateNumberOfAttachmentsAndColorsForMessages:(id)arg1;
- (void)updateMessageColorsSynchronouslyForMessages:(id)arg1;
- (void)updateMessageColorsAsynchronouslyForMessages:(id)arg1;
- (void)setJunkMailLevel:(int)arg1 forMessages:(id)arg2;
- (void)setJunkMailLevel:(int)arg1 forMessages:(id) arg2 trainJunkMailDatabase:(BOOL)arg3;
- (void)setJunkMailLevel:(int)arg1 forMessages:(id) arg2 trainJunkMailDatabase:(BOOL) arg3 userRecorded:(BOOL)arg4;
- (void)sendResponseType:(BOOL) arg1 forMeetingMessage:(id)arg2;
- (id)status;
- (void)fetchSynchronously;
- (void)fetchSynchronouslyForKnownChanges;
- (BOOL)setPreferredEncoding:(unsigned int)arg1 forMessage:(id)arg2;
- (void)suggestSortOrder:(id) arg1 ascending:(BOOL)arg2;
- (id)sortOrder;
- (BOOL)isSortedAscending;
- (void)todosDidChangeForMessages:(id) arg1 oldToDosByMessage:(id) arg2 newToDosByMessage:(id)arg3;
- (int)setToDo:(id) arg1 forMessage:(id) arg2 oldToDo:(id)arg3;
- (void)invalidateMessage:(id)arg1;
- (void)invalidateMessages:(id)arg1;
- (id)_aquireFetchLockForMessage:(id)arg1;
- (void)_releaseFetchLock:(id) arg1 forMessage:(id)arg2;
@property BOOL forceInvalidation; // @synthesize forceInvalidation=_forceInvalidation;
@property BOOL hasUnsavedChangesToMessageData; // @synthesize hasUnsavedChangesToMessageData=_hasUnsavedChangesToMessageData;
@property (retain) ActivityMonitor * openMonitor; // @synthesize openMonitor=_openMonitor;
@property BOOL isReadOnly; // @synthesize isReadOnly=_isReadOnly;

@end

@interface MessageStore (MessageFrameworkOnly)
+ (void)_autosaveMessageStore:(void *)arg1;
- (void)_cancelAutosave;
- (void)_setNeedsAutosave;
- (id)_fetchHeaderDataForMessage:(id) arg1 fetchIfNotAvailable:(BOOL)arg2;
- (id)_fetchBodyDataForMessage:(id) arg1 andHeaderDataIfReadilyAvailable:(id *)arg2 fetchIfNotAvailable:(BOOL)arg3;
- (id)_fetchBodyForMessage:(id) arg1 updateFlags:(BOOL)arg2;
- (BOOL)_shouldCallCompactWhenClosing;
- (BOOL)_isReadyToBeInvalidated;
- (void)_saveChanges;
- (BOOL)setStoreState:(int)arg1 fromState:(int)arg2;
- (int)storeState;
- (void)_invalidate;
- (void)_invalidateInBackground;
- (void)_countUnreadAndDeletedInMessages:(id)arg1;
- (id)_lockFilePath;
- (BOOL)_acquireLockFile;
- (void)_removeLockFile;
- (void)_flushAllCaches;
- (void)_flushAllMessageData;
- (void)_rebuildTableOfContentsSynchronously;
- (void)updateBodyFlagsForMessage:(id) arg1 body:(id)arg2;
- (id)_setOrGetBody:(id) arg1 forMessage:(id) arg2 updateFlags:(BOOL)arg3;
- (void)_invalidateObjectCachesForKey:(id)arg1;
- (id)_setOrGetValue:(id) arg1 forKey:(id) arg2 inCache:(id *)arg3;
- (id)_cachedBodyForMessage:(id) arg1 valueIfNotPresent:(id)arg2;
- (id)_cachedHeadersForMessage:(id) arg1 valueIfNotPresent:(id)arg2;
- (id)_cachedBodyDataForMessage:(id) arg1 valueIfNotPresent:(id)arg2;
- (id)_cachedHeaderDataForMessage:(id) arg1 valueIfNotPresent:(id)arg2;
- (void)updateMessageColorsSynchronouslyForMessages:(id) arg1 postingNotification:(BOOL)arg2;
- (void)updateMessages:(id) arg1 updateColor:(BOOL) arg2 updateNumberOfAttachments:(BOOL)arg3;
- (void)_setBackgroundColorForMessages:(id) arg1 textColorForMessages:(id)arg2;
- (void)_invalidateColorForAllMessages;
- (void)_setFlagsForMessages:(id) arg1 mask:(unsigned int)arg2;
- (void)_setFlagsAndColorForMessages:(id)arg1;
- (void)messagesWereAdded:(id) arg1 forIncrementalLoading:(BOOL)arg2;
- (BOOL)_updateFlagForMessage:(id) arg1 key:(id) arg2 value:(BOOL)arg3;

// Remaining properties
@property BOOL forceInvalidation;
@property BOOL hasUnsavedChangesToMessageData;
@property BOOL isReadOnly;
@end

@interface MessageStore (ParentalControl)
- (void)setPermissionRequestState:(int)arg1 forMessage:(id)arg2;
@end

@interface MessageStore (RSSAdditions)
+ (void)deleteUnflaggedEntriesCreatedBeforeDate:(id)arg1;
- (void)updateEntries:(id) arg1 fromFeed:(id)arg2;
- (void)changeFlagsForEntries:(id) arg1 fromFeed:(id)arg2;
- (void)updateStatusFromFeed:(id) arg1 error:(id) arg2 errorMessage:(id)arg3;
@end

@interface MessageStore (ScriptingSupport)
- (id)objectSpecifier;
- (id)objectSpecifierForMessage:(id)arg1;
@end



#elif defined(SNOW_LEOPARD)

#import <SafeObserver.h>

@class MailboxUid;
@class MailAccount;
@class NSCache;
@class ActivityMonitor;

@interface MessageStore : SafeObserver
{
	BOOL _isReadOnly;
	BOOL _hasUnsavedChangesToMessageData;
	BOOL _haveOpenLockFile;
	BOOL _forceInvalidation;
	BOOL _isWritingChangesToDisk;
	BOOL _isTryingToClose;
	BOOL _compactOnClose;
	MailboxUid * _mailboxUid;
	MailAccount * _account;
	NSMutableArray * _allMessages;
	id _messageCountsAndSizesLock;
	struct {
		unsigned int unreadCount;
		unsigned int unseenCount;
		unsigned int deletedCount;
		unsigned int totalSize;
		unsigned int deletedSize;
	} _messageCountsAndSizes;
	id _cacheLock;
	NSCache * _headerDataCache;
	NSCache * _headerCache;
	NSCache * _bodyDataCache;
	NSCache * _bodyCache;
	NSMutableSet * _uniqueStrings;
	int _storeState;
	NSTimer * _timer;
	ActivityMonitor * _openMonitor;
	NSMutableDictionary * _fetchLockMap;
}

+ (void)initialize;
+ (id)_storeCacheMapTable;
+ (unsigned int)numberOfCurrentlyOpenStores;
+ (id)descriptionOfOpenStores;
+ (id)_storeCreationMarker;
+ (id)_copyRawAvailableStoreForUid:(id) arg1 wantsCreate:(BOOL) arg2 shouldCreate:(char *)arg3;
+ (id)currentlyAvailableStoreForUid:(id)arg1;
+ (id)currentlyAvailableStoresForAccount:(id)arg1;
+ (void)registerAvailableStore:(id) arg1 forUid:(id)arg2;
+ (void)removeStoreFromCache:(id)arg1;
+ (BOOL)createEmptyStoreIfNeededForPath:(id) arg1 notIndexable:(BOOL)arg2;
+ (BOOL)createEmptyStoreForPath:(id)arg1;
+ (BOOL)storeAtPathIsWritable:(id)arg1;
+ (BOOL)cheapStoreAtPathIsEmpty:(id)arg1;
+ (id)succesfulMessagesFromMessages:(id) arg1 unsuccessfulOnes:(id)arg2;
+ (int)copyMessages:(id) arg1 toMailboxUid:(id) arg2 shouldDelete:(BOOL)arg3;
- (void)queueSaveChangesInvocation;
- (id)willDealloc;
- (id)init;
- (id)initWithMailboxUid:(id) arg1 readOnly:(BOOL)arg2;
- (void)_messageStoreCommonInit;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)dealloc;
- (void)finalize;
- (void)openAsynchronously;
- (void)openAsynchronouslyWithOptions:(unsigned int)arg1;
- (void)openSynchronously;
- (void)openSynchronouslyUpdatingMetadata:(BOOL)arg1;
- (void)updateMetadataAsynchronously;
- (void)updateMetadata;
- (void)cleanupAsynchronously;
- (void)cleanupSynchronously;
- (void)willOpen;
- (void)didOpenWithMessages:(id)arg1;
- (void)cancelOpen;
- (void)writeUpdatedMessageDataToDisk;
- (void)invalidateSavingChanges:(BOOL)arg1;
- (id)account;
- (id)mailboxUid;
- (id)allMailboxUidRepresentations;
- (BOOL)isOpened;
- (id)displayName;
- (const char *)displayNameForLogging;
- (id)description;
- (BOOL)isTrash;
- (void)messageFlagsDidChange:(id) arg1 flags:(id)arg2;
- (void)structureDidChange;
- (void)messagesWereAdded:(id)arg1;
- (void)messagesWereCompacted:(id)arg1;
- (void)messagesWereUpdated:(id)arg1;
- (void)updateUserInfoToLatestValues;
- (unsigned int)totalMessageSize;
- (void)deletedCount:(unsigned int *)arg1 andSize:(unsigned int *)arg2;
- (unsigned int)totalCount;
- (unsigned int)_totalNonDeletedCount;
- (unsigned int)unreadCount;
- (unsigned int)unseenCount;
- (unsigned int)indexOfMessage:(id)arg1;
- (id)copyOfAllMessages;
- (id)mutableCopyOfAllMessages;
- (id)copyOfAllMessagesWithOptions:(unsigned int)arg1;
- (void)addMessagesToAllMessages:(id)arg1;
- (id)_defaultRouterDestination;
- (id)routeMessages:(id)arg1;
- (id)finishRoutingMessages:(id) arg1 routed:(id)arg2;
- (id)routeMessages:(id) arg1 isUserAction:(BOOL)arg2;
- (BOOL)canRebuild;
- (void)rebuildTableOfContentsAsynchronously;
- (BOOL)canCompact;
- (void)doCompact;
- (void)deleteMessagesOlderThanNumberOfDays:(int)arg1 compact:(BOOL)arg2;
- (void)deleteMessages:(id) arg1 moveToTrash:(BOOL)arg2;
- (id)undeleteMessages:(id) arg1 movedToStore:(id) arg2 newMessageIDs:(id)arg3;
- (void)undeleteMessages:(id)arg1;
- (void)deleteLastMessageWithHeaders:(id) arg1 compactWhenDone:(BOOL)arg2;
- (BOOL)allowsAppend;
- (BOOL)allowsOverwrite;
- (BOOL)allowsDeleteInPlace;
- (int)undoAppendOfMessageIDs:(id)arg1;
- (void)finishCopyOfMessages:(id) arg1 fromStore:(id) arg2 originalsWereDeleted:(BOOL)arg3;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id) arg2 newMessageIDs:(id) arg3 newMessages:(id) arg4 newDocumentIDsByOld:(id) arg5 flagsToSet:(id) arg6 forMove:(BOOL) arg7 error:(id *)arg8;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id) arg2 newMessageIDs:(id) arg3 newMessages:(id) arg4 flagsToSet:(id) arg5 forMove:(BOOL) arg6 error:(id *)arg7;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id) arg2 newMessageIDs:(id) arg3 newMessages:(id) arg4 flagsToSet:(id) arg5 forMove:(BOOL)arg6;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id) arg2 newMessageIDs:(id) arg3 newMessages:(id) arg4 flagsToSet:(id)arg5;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id) arg2 newMessageIDs:(id) arg3 newMessages:(id) arg4 forMove:(BOOL)arg5;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id) arg2 newMessageIDs:(id) arg3 newMessages:(id)arg4;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id) arg2 newMessageIDs:(id)arg3;
- (int)appendMessages:(id) arg1 unsuccessfulOnes:(id)arg2;
- (id)messageWithValue:(id) arg1 forHeader:(id) arg2 options:(unsigned int)arg3;
- (id)messageForMessageID:(id)arg1;
- (unsigned int)_numberOfMessagesToCache;
- (id)headerDataForMessage:(id) arg1 fetchIfNotAvailable:(BOOL)arg2;
- (id)headerDataForMessage:(id)arg1;
- (id)bodyDataForMessage:(id) arg1 fetchIfNotAvailable:(BOOL)arg2;
- (id)bodyDataForMessage:(id)arg1;
- (id)fullBodyDataForMessage:(id) arg1 andHeaderDataIfReadilyAvailable:(id *)arg2 fetchIfNotAvailable:(BOOL)arg3;
- (id)fullBodyDataForMessage:(id) arg1 andHeaderDataIfReadilyAvailable:(id *)arg2;
- (id)fullBodyDataForMessage:(id)arg1;
- (id)bodyForMessage:(id) arg1 fetchIfNotAvailable:(BOOL)arg2;
- (id)bodyForMessage:(id) arg1 fetchIfNotAvailable:(BOOL) arg2 updateFlags:(BOOL)arg3;
- (id)headersForMessage:(id)arg1;
- (id)headersForMessage:(id) arg1 fetchIfNotAvailable:(BOOL)arg2;
- (id)dataForMimePart:(id)arg1;
- (BOOL)hasCachedDataForMimePart:(id)arg1;
- (id)uniquedString:(id)arg1;
- (id)colorForMessage:(id)arg1;
- (id)setFlagsFromDictionary:(id) arg1 forMessages:(id)arg2;
- (id)setFlagsFromDictionary:(id) arg1 forToDos:(id)arg2;
- (void)setFlag:(id) arg1 state:(BOOL) arg2 forMessages:(id)arg3;
- (void)setColor:(id) arg1 highlightTextOnly:(BOOL) arg2 forMessages:(id)arg3;
- (void)messageColorsNeedToBeReevaluated;
- (void)startSynchronization;
- (id)_getSerialNumberString;
- (void)setNumberOfAttachments:(unsigned long)arg1 isSigned:(BOOL) arg2 isEncrypted:(BOOL) arg3 forMessage:(id)arg4;
- (void)updateNumberOfAttachmentsForMessages:(id)arg1;
- (void)updateNumberOfAttachmentsAndColorsForMessages:(id)arg1;
- (void)updateMessageColorsSynchronouslyForMessages:(id)arg1;
- (void)updateMessageColorsAsynchronouslyForMessages:(id)arg1;
- (void)setJunkMailLevel:(int)arg1 forMessages:(id)arg2;
- (void)setJunkMailLevel:(int)arg1 forMessages:(id) arg2 trainJunkMailDatabase:(BOOL)arg3;
- (void)setJunkMailLevel:(int)arg1 forMessages:(id) arg2 trainJunkMailDatabase:(BOOL) arg3 userRecorded:(BOOL)arg4;
- (void)sendResponseType:(BOOL) arg1 forMeetingMessage:(id)arg2;
- (id)status;
- (void)fetchSynchronously;
- (void)fetchSynchronouslyForKnownChanges;
- (BOOL)setPreferredEncoding:(unsigned long)arg1 forMessage:(id)arg2;
- (void)suggestSortOrder:(id) arg1 ascending:(BOOL)arg2;
- (id)sortOrder;
- (BOOL)isSortedAscending;
- (void)todosDidChangeForMessages:(id) arg1 oldToDosByMessage:(id) arg2 newToDosByMessage:(id)arg3;
- (int)setToDo:(id) arg1 forMessage:(id) arg2 oldToDo:(id)arg3;
- (void)invalidateMessage:(id)arg1;
- (void)invalidateMessages:(id)arg1;
- (id)_aquireFetchLockForMessage:(id)arg1;
- (void)_releaseFetchLock:(id) arg1 forMessage:(id)arg2;
- (BOOL)forceInvalidation;
- (void)setForceInvalidation:(BOOL)arg1;
- (BOOL)hasUnsavedChangesToMessageData;
- (void)setHasUnsavedChangesToMessageData:(BOOL)arg1;
- (id)openMonitor;
- (void)setOpenMonitor:(id)arg1;
- (BOOL)isReadOnly;
- (void)setIsReadOnly:(BOOL)arg1;

@end

@interface MessageStore (MessageFrameworkOnly)
+ (void)_autosaveMessageStore:(void *)arg1;
- (void)_cancelAutosave;
- (void)_setNeedsAutosave;
- (id)_fetchHeaderDataForMessage:(id) arg1 fetchIfNotAvailable:(BOOL)arg2;
- (id)_fetchBodyDataForMessage:(id) arg1 andHeaderDataIfReadilyAvailable:(id *)arg2 fetchIfNotAvailable:(BOOL)arg3;
- (id)_fetchBodyForMessage:(id) arg1 updateFlags:(BOOL)arg2;
- (BOOL)_shouldCallCompactWhenClosing;
- (BOOL)_isReadyToBeInvalidated;
- (void)_saveChanges;
- (BOOL)setStoreState:(int)arg1 fromState:(int)arg2;
- (int)storeState;
- (void)_invalidate;
- (void)_invalidateInBackground;
- (void)_countUnreadAndDeletedInMessages:(id)arg1;
- (id)_lockFilePath;
- (BOOL)_acquireLockFile;
- (void)_removeLockFile;
- (void)_flushAllCaches;
- (void)_flushAllMessageData;
- (void)_rebuildTableOfContentsSynchronously;
- (void)updateBodyFlagsForMessage:(id) arg1 body:(id)arg2;
- (id)_setOrGetBody:(id) arg1 forMessage:(id) arg2 updateFlags:(BOOL)arg3;
- (void)_invalidateObjectCachesForKey:(id)arg1;
- (id)_setOrGetValue:(id) arg1 forKey:(id) arg2 inCache:(id *)arg3;
- (id)_cachedBodyForMessage:(id) arg1 valueIfNotPresent:(id)arg2;
- (id)_cachedHeadersForMessage:(id) arg1 valueIfNotPresent:(id)arg2;
- (id)_cachedBodyDataForMessage:(id) arg1 valueIfNotPresent:(id)arg2;
- (id)_cachedHeaderDataForMessage:(id) arg1 valueIfNotPresent:(id)arg2;
- (void)updateMessageColorsSynchronouslyForMessages:(id) arg1 postingNotification:(BOOL)arg2;
- (void)updateMessages:(id) arg1 updateColor:(BOOL) arg2 updateNumberOfAttachments:(BOOL)arg3;
- (void)_setBackgroundColorForMessages:(id) arg1 textColorForMessages:(id)arg2;
- (void)_invalidateColorForAllMessages;
- (void)_setFlagsForMessages:(id) arg1 mask:(unsigned long)arg2;
- (void)_setFlagsAndColorForMessages:(id)arg1;
- (void)messagesWereAdded:(id) arg1 forIncrementalLoading:(BOOL)arg2;
- (BOOL)_updateFlagForMessage:(id) arg1 key:(id) arg2 value:(BOOL)arg3;
@end

@interface MessageStore (ScriptingSupport)
- (id)objectSpecifier;
- (id)objectSpecifierForMessage:(id)arg1;
@end

@interface MessageStore (ParentalControl)
- (void)setPermissionRequestState:(int)arg1 forMessage:(id)arg2;
@end

@interface MessageStore (RSSAdditions)
+ (void)deleteUnflaggedEntriesCreatedBeforeDate:(id)arg1;
- (void)updateEntries:(id) arg1 fromFeed:(id)arg2;
- (void)changeFlagsForEntries:(id) arg1 fromFeed:(id)arg2;
- (void)updateStatusFromFeed:(id) arg1 error:(id) arg2 errorMessage:(id)arg3;
@end

#endif // ifdef SNOW_LEOPARD_64
