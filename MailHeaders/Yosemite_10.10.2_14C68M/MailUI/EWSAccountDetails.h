/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "AccountDetails.h"

@class NSButton, NSTextField;

@interface EWSAccountDetails : AccountDetails
{
    BOOL _warnedAboutCachingAndIndexing;
    NSButton *_cachePolicyCheckbox;
    NSTextField *_internalServerPath;
    NSTextField *_externalServerPath;
    NSTextField *_externalPortNumber;
    NSButton *_externalUseSSL;
}

@property(nonatomic) BOOL warnedAboutCachingAndIndexing; // @synthesize warnedAboutCachingAndIndexing=_warnedAboutCachingAndIndexing;
@property(nonatomic) __weak NSButton *externalUseSSL; // @synthesize externalUseSSL=_externalUseSSL;
@property(nonatomic) __weak NSTextField *externalPortNumber; // @synthesize externalPortNumber=_externalPortNumber;
@property(nonatomic) __weak NSTextField *externalServerPath; // @synthesize externalServerPath=_externalServerPath;
@property(nonatomic) __weak NSTextField *internalServerPath; // @synthesize internalServerPath=_internalServerPath;
@property(nonatomic) __weak NSButton *cachePolicyCheckbox; // @synthesize cachePolicyCheckbox=_cachePolicyCheckbox;
- (void).cxx_destruct;
- (void)cachePolicyChanged:(id)arg1;
- (void)didDisplayTabViewItem:(id)arg1;
- (id)portFieldForSSLCheckBox:(id)arg1;
- (BOOL)isAccountInformationDirty:(id)arg1;
- (void)setUIElementsEnabled:(BOOL)arg1;
- (void)setupAccountFromValuesInUI:(id)arg1 forValidation:(BOOL)arg2;
- (void)setupUIFromValuesInAccount:(id)arg1;

@end

