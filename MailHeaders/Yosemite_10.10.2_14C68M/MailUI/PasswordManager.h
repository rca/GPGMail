/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

@class IAPasswordUIController, NSCondition, NSMutableArray, NSMutableSet, NSOperationQueue;

@interface PasswordManager : NSObject
{
    IAPasswordUIController *_passwordController;
    NSMutableArray *_pendingAccounts;
    NSMutableSet *_suppressedAccounts;
    NSCondition *_passwordChanged;
    long long _lastUserResponse;
    NSOperationQueue *_passwordChangeQueue;
}

+ (void)resetSuppressedAccount:(id)arg1;
+ (void)resetSuppressedAccounts;
+ (BOOL)isShowingPasswordUI;
+ (BOOL)promptForPassword:(id)arg1;
+ (id)_passwordManagerInstance;
+ (id)allocWithZone:(struct _NSZone *)arg1;
@property(readonly, nonatomic) NSOperationQueue *passwordChangeQueue; // @synthesize passwordChangeQueue=_passwordChangeQueue;
- (void).cxx_destruct;
- (void)_accountsChanged:(id)arg1;
- (void)_accountChanged:(id)arg1;
- (void)_mainWindowChanged:(id)arg1;
- (BOOL)_waitForPasswordCompletion:(id)arg1;
- (BOOL)_isSuppressedAccount:(id)arg1;
- (void)_resetSuppressedAccount:(id)arg1;
- (void)_resetAllSuppressedAccounts;
- (void)_finalizePasswordResult:(long long)arg1 forAccount:(id)arg2;
- (void)_displayPasswordSheetIfNeeded;
- (BOOL)_displayPasswordSheetForAccount:(id)arg1;
@property(retain) IAPasswordUIController *passwordController;
- (void)dealloc;
- (id)init;

@end

