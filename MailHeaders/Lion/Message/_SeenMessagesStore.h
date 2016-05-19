/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */



@class NSEntityDescription, NSPersistentStoreCoordinator, NSString;

@interface _SeenMessagesStore : NSObject
{
    NSPersistentStoreCoordinator *_coordinator;
    NSString *_storePath;
    NSEntityDescription *_accountEntity;
    NSEntityDescription *_seenMessageEntity;
}

+ (id)allocWithZone:(struct _NSZone *)arg1;
+ (id)sharedInstance;
- (id)init;
- (void)dealloc;
- (id)retain;
- (unsigned long long)retainCount;
- (void)release;
- (id)autorelease;
- (void)_configurePersistentStoreCoordinator;
@property(retain) NSPersistentStoreCoordinator *persistentStoreCoordinator; // @synthesize persistentStoreCoordinator=_coordinator;
- (id)_managedObjectModel;
@property(retain) NSEntityDescription *seenMessageEntity; // @synthesize seenMessageEntity=_seenMessageEntity;
@property(retain) NSEntityDescription *accountEntity; // @synthesize accountEntity=_accountEntity;
@property(retain) NSString *persistentStorePath; // @synthesize persistentStorePath=_storePath;

@end

