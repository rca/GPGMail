/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import <Mail/MFRemoteStoreAccount.h>

@class MFEWSConnection, MFEWSDeliveryAccount, MFEWSGateway, NSDictionary, NSMutableDictionary, NSOperationQueue, NSString, NSTimer, NSURL, NSUUID;

@interface MFEWSAccount : MFRemoteStoreAccount
{
    MFEWSConnection *_connection;
    NSMutableDictionary *_folderIdsToMailboxes;
    id _connectionLock;
    id _folderHierarchySyncLock;
    BOOL _useExternalURL;
    MFEWSGateway *_gateway;
    NSDictionary *_distinguishedFolderIdsAndMailboxTypes;
    double _lastFullFetchDuration;
    double _lastFullFetchTime;
    NSUUID *_messageTracerUUID;
    NSString *_syncIssuesEntryID;
    long long _externalAudienceType;
    NSTimer *_autodiscoveryTimer;
    NSOperationQueue *_autodiscoverQueue;
    MFEWSDeliveryAccount *_ewsDeliveryAccount;
    NSOperationQueue *_remoteTaskQueue;
    NSOperationQueue *_remoteFetchQueue;
    NSOperationQueue *_requestResponseQueue;
    NSOperationQueue *_bodyFetchQueue;
}

+ (void)resetAllFolderHierarchySyncStates;
+ (id)existingAccountFromMailWithRootFolderId:(id)arg1;
+ (id)_contactsAccountWithRootFolderId:(id)arg1;
+ (BOOL)contactsAccountExistsWithRootFolderId:(id)arg1;
+ (BOOL)contactsAccountExistsForHostname:(id)arg1 username:(id)arg2;
+ (id)_contactsAccountForHostname:(id)arg1 username:(id)arg2;
+ (id)_calendarAccountWithRootFolderId:(id)arg1;
+ (BOOL)calendarAccountExistsWithRootFolderId:(id)arg1;
+ (BOOL)calendarAccountExistsForHostname:(id)arg1 username:(id)arg2;
+ (id)_calendarAccountForHostname:(id)arg1 username:(id)arg2;
+ (id)keyPathsForValuesAffectingExternalConnectionURL;
+ (id)keyPathsForValuesAffectingInternalConnectionURL;
+ (id)keyPathsForValuesAffecting_URLExternalConnectionScheme;
+ (id)keyPathsForValuesAffecting_URLInternalConnectionScheme;
+ (id)defaultPathNameForAccount;
+ (id)accountTypeString;
@property(readonly, nonatomic) NSOperationQueue *bodyFetchQueue; // @synthesize bodyFetchQueue=_bodyFetchQueue;
@property(readonly, nonatomic) NSOperationQueue *requestResponseQueue; // @synthesize requestResponseQueue=_requestResponseQueue;
@property(readonly, nonatomic) NSOperationQueue *remoteFetchQueue; // @synthesize remoteFetchQueue=_remoteFetchQueue;
@property(readonly, nonatomic) NSOperationQueue *remoteTaskQueue; // @synthesize remoteTaskQueue=_remoteTaskQueue;
@property(readonly, nonatomic) MFEWSDeliveryAccount *ewsDeliveryAccount; // @synthesize ewsDeliveryAccount=_ewsDeliveryAccount;
@property(readonly, nonatomic) NSOperationQueue *autodiscoverQueue; // @synthesize autodiscoverQueue=_autodiscoverQueue;
@property(readonly, nonatomic) NSTimer *autodiscoveryTimer; // @synthesize autodiscoveryTimer=_autodiscoveryTimer;
@property long long externalAudienceType; // @synthesize externalAudienceType=_externalAudienceType;
@property(retain) NSString *syncIssuesEntryID; // @synthesize syncIssuesEntryID=_syncIssuesEntryID;
@property BOOL useExternalURL; // @synthesize useExternalURL=_useExternalURL;
@property(retain) NSUUID *messageTracerUUID; // @synthesize messageTracerUUID=_messageTracerUUID;
@property double lastFullFetchTime; // @synthesize lastFullFetchTime=_lastFullFetchTime;
@property double lastFullFetchDuration; // @synthesize lastFullFetchDuration=_lastFullFetchDuration;
@property(retain) NSDictionary *distinguishedFolderIdsAndMailboxTypes; // @synthesize distinguishedFolderIdsAndMailboxTypes=_distinguishedFolderIdsAndMailboxTypes;
@property(retain) MFEWSConnection *connection; // @synthesize connection=_connection;
@property(retain, nonatomic) MFEWSGateway *gateway; // @synthesize gateway=_gateway;
- (void).cxx_destruct;
- (void)messageTraceEWSParameters;
- (BOOL)_setEWSError:(id)arg1;
- (id)_loadFolderIdForMailbox:(id)arg1;
- (void)_clearFolderId:(id)arg1 forMailbox:(id)arg2;
- (void)_saveFolderId:(id)arg1 forMailbox:(id)arg2;
- (void)_setMailbox:(id)arg1 forFolderId:(id)arg2;
- (id)_mailboxForFolderId:(id)arg1;
- (void)_setupMailbox:(id)arg1 forFolderId:(id)arg2;
- (void)updateEWSOfflineIdsToRealIds:(id)arg1 forFolders:(BOOL)arg2;
- (id)deletedEWSIdStringsFromStrings:(id)arg1 inFolderWithIdString:(id)arg2;
- (void)undeleteMessagesWithEWSItemIdStrings:(id)arg1 fromFolderWithIdString:(id)arg2;
- (void)deleteEWSItemsWithIdStrings:(id)arg1 fromFolderWithIdString:(id)arg2;
- (void)deleteMailboxForEWSFolderIdString:(id)arg1;
- (void)updateMailboxForEWSFolder:(id)arg1;
- (BOOL)_isSyncIssuesFolder:(id)arg1;
- (void)createMailboxFromEWSFolder:(id)arg1;
- (id)mailboxNameForFolderIdString:(id)arg1;
- (void)messageDeliveryDidFinish:(id)arg1;
- (BOOL)_autodiscoverWithEmailAddress:(id)arg1 error:(id *)arg2;
- (id)_autodiscoverForConnectionFailure:(BOOL)arg1;
- (void)_kickOffReautodiscovery:(id)arg1;
- (BOOL)_shouldHideMailbox:(id)arg1 withType:(int)arg2;
- (void)setUserOofSettingsState:(long long)arg1 internalReply:(id)arg2 externalReply:(id)arg3 startTime:(id)arg4 endTime:(id)arg5;
- (void)getUserOofSettings;
- (BOOL)_isSameAsCalGroup:(id)arg1;
@property(readonly) NSURL *connectionURL;
- (void)_setConnectionURL:(id)arg1 isExternal:(BOOL)arg2;
- (id)_connectionURL:(BOOL)arg1;
@property __weak NSURL *externalConnectionURL;
@property __weak NSURL *internalConnectionURL;
@property(retain) NSURL *lastUsedAutodiscoverURL;
@property(retain) NSString *rootFolderId;
@property(retain) NSString *folderHierarchySyncState;
- (void)_setServerPath:(id)arg1 accountInfoKey:(id)arg2;
- (id)_serverPathWithAccountInfoKey:(id)arg1;
@property(copy) NSString *externalServerPath;
@property(copy) NSString *internalServerPath;
@property BOOL externalUsesSSL;
@property long long externalPortNumber;
- (void)setExternalHostname:(id)arg1;
- (id)externalHostname;
- (BOOL)storeJunkOnServerDefault;
- (id)_specialMailboxWithType:(int)arg1 create:(BOOL)arg2 isLocal:(BOOL)arg3;
- (id)dynamicDeliveryAccount;
- (void)setDeliveryAccount:(id)arg1;
- (id)deliveryAccount;
- (id)_folderNameForMailboxDisplayName:(id)arg1;
- (id)_mailboxDisplayNameForFolderName:(id)arg1;
- (id)validNameForMailbox:(id)arg1 fromDisplayName:(id)arg2 error:(id *)arg3;
- (BOOL)supportsSlashesInMailboxName;
- (BOOL)_deleteMailbox:(id)arg1 reflectToServer:(BOOL)arg2;
- (BOOL)canMailboxBeDeleted:(id)arg1;
- (BOOL)renameMailbox:(id)arg1 newDisplayName:(id)arg2 parent:(id)arg3;
- (BOOL)canMailboxBeRenamed:(id)arg1;
- (id)_createMailboxWithParent:(id)arg1 displayName:(id)arg2 localizedDisplayName:(id)arg3 type:(int)arg4;
- (id)createMailboxWithParent:(id)arg1 displayName:(id)arg2 localizedDisplayName:(id)arg3;
- (void)setEmailAddresses:(id)arg1;
- (BOOL)_readMailboxCache;
- (void)_setSpecialMailboxRelativePath:(id)arg1 forType:(int)arg2;
- (id)_specialMailboxRelativePathForType:(int)arg1;
- (id)_defaultSpecialMailboxRelativePathForType:(int)arg1;
- (BOOL)_setChildren:(id)arg1 forMailbox:(id)arg2;
- (void)_synchronouslyLoadListingForParent:(id)arg1;
- (BOOL)_synchronizeMailboxListHighPriority:(BOOL)arg1;
- (BOOL)_supportsMailboxListInitialization;
@property(readonly) long long maximumConcurrentSyncFolderOperationCount;
- (void)_synchronizeMailboxesSynchronously;
- (BOOL)_shouldSynchronizeMailbox:(id)arg1;
- (void)synchronizeAllMailboxes;
- (void)fetchSynchronouslyIsAuto:(id)arg1;
- (void)respondToHostBecomingReachable;
- (BOOL)deleteConvertsStoreToFolder;
- (id)primaryMailbox;
- (void)setShouldMoveDeletedMessagesToTrash:(BOOL)arg1;
- (BOOL)shouldMoveDeletedMessagesToTrash;
- (id)mailboxPathExtension;
- (BOOL)defaultShouldShowNotesInInbox;
- (BOOL)supportsRichTextNotes;
- (Class)storeClassForMailbox:(id)arg1;
- (id)_URLExternalConnectionScheme;
- (id)_URLInternalConnectionScheme;
- (id)_URLPersistenceScheme;
- (BOOL)usesConnectionBasedAutodiscovery;
- (void)setIsWillingToGoOnline:(BOOL)arg1;
- (void)setIsOffline:(BOOL)arg1;
- (void)releaseAllConnections;
- (BOOL)canAuthenticateWithScheme:(id)arg1;
- (BOOL)connectAndAuthenticate:(id)arg1;
- (id)authenticatedConnection;
- (id)newConnectedConnectionDiscoveringBestSettings:(BOOL)arg1 withConnectTimeout:(double)arg2 readWriteTimeout:(double)arg3;
- (BOOL)autodiscoverSettings:(id *)arg1;
- (void)setConfigureDynamically:(BOOL)arg1;
- (void)_setPassword:(id)arg1 persistence:(unsigned long long)arg2;
- (id)_passwordWithPersistence:(unsigned long long)arg1;
- (void)setSessionPassword:(id)arg1;
- (id)sessionPassword;
- (void)setPermanentPassword:(id)arg1;
- (id)permanentPassword;
- (void)setPortNumber:(long long)arg1;
- (void)_setUsesSSL:(BOOL)arg1 releasingConnections:(BOOL)arg2;
- (void)setUsesSSL:(BOOL)arg1;
- (id)defaultsDictionary;
- (void)_setAccountInfo:(id)arg1;
- (void)setPreferredAuthScheme:(id)arg1;
- (id)preferredAuthScheme;
- (void)setSecurityLayerType:(long long)arg1;
- (long long)securityLayerType;
- (BOOL)requiresAuthentication;
- (void *)keychainProtocol;
- (long long)defaultSecurePortNumber;
- (long long)defaultPortNumber;
- (id)standardSSLPorts;
- (id)standardPorts;
- (id)iaServiceType;
- (id)syncableURLString;
- (id)_infoForMatchingURL:(id)arg1;
- (void)dealloc;
- (id)initWithAccountInfo:(id)arg1;

@end

