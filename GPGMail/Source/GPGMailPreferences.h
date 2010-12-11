/* GPGMailPreferences.h created by dave on Thu 29-Jun-2000 */

/*
 * Copyright (c) 2000-2010, GPGMail Project Team <gpgmail-devel@lists.gpgmail.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGMail Project Team nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGMAIL PROJECT TEAM ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGMAIL PROJECT TEAM BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <NSPreferences.h>

#import <AppKit/AppKit.h>

@class GPGMailBundle;

@interface GPGMailPreferences : NSPreferencesModule {
    IBOutlet NSPopUpButton	*personalKeysPopUpButton;
    IBOutlet NSButton		*choosesPersonalKeyAccordingToAccountSwitchButton;
    IBOutlet NSMatrix		*passphraseStrategyMatrix;
    IBOutlet NSFormCell		*passphraseTimeoutFormCell;
    IBOutlet NSButton		*showsPassphraseSwitchButton;

    IBOutlet NSButton		*useSmartRulesSwitchButton;
    IBOutlet NSButton		*alwaysSignSwitchButton;
    IBOutlet NSButton		*signReplyToSignedMessageSwitchButton;
    IBOutlet NSButton		*signWhenEncryptingSwitchButton;
    IBOutlet NSButton		*alwaysEncryptSwitchButton;
    IBOutlet NSButton		*encryptReplyToEncryptedMessageSwitchButton;
    IBOutlet NSButton		*encryptWhenAllKeysAvailableSwitchButton;
    IBOutlet NSButton		*encryptToSelfSwitchButton;
    IBOutlet NSButton		*trustAllKeysSwitchButton;
    IBOutlet NSButton		*filtersKeysSwitchButton;
    IBOutlet NSButton		*openPGPMIMESwitchButton;
    IBOutlet NSButton		*useBCCRecipientsSwitchButton;
    IBOutlet NSButton		*buttonsShowStateSwitchButton;
    IBOutlet NSButton		*displayButtonInComposeWindowSwitchButton;
    IBOutlet NSButton		*separateSignAndEncryptOperationsSwitchButton;

    IBOutlet NSButton		*automaticallyAuthenticateMessagesSwitchButton;
    IBOutlet NSButton		*authenticateUnreadMessagesSwitchButton;
    IBOutlet NSButton		*decryptUnreadMessagesSwitchButton;
    IBOutlet NSButton		*automaticallyDecryptMessagesSwitchButton;
    IBOutlet NSButton		*extendedInfoSwitchButton;

    NSMutableDictionary		*tableColumnPerIdentifier;
    IBOutlet NSTableView	*keyIdentifiersTableView;
    IBOutlet NSButton		*showUserIDsSwitchButton;
    IBOutlet NSPopUpButton	*keyIdentifiersPopUpButton;
    IBOutlet NSFormCell		*lineWrappingFormCell;
    IBOutlet NSButton       *refreshKeysOnVolumeChangeSwitchButton;
    IBOutlet NSButton       *disableSMIMESwitchButton;
    
    //IBOutlet NSTextField	*versionTextField;
    //IBOutlet NSTextField	*contactTextField;
    //IBOutlet NSTextField	*webSiteTextField;

    BOOL					initializingPrefs;
}

- (IBAction) changeDefaultKey:(id)sender;
- (IBAction) toggleAutomaticPersonalKeyChoice:(id)sender;
- (IBAction) changePassphraseStrategy:(id)sender;
- (IBAction) changePassphraseTimeout:(id)sender;
- (IBAction) flushCachedPassphrases:(id)sender;
- (IBAction) toggleShowPassphrase:(id)sender;
- (IBAction) refreshKeys:(id)sender;

- (IBAction) toggleDisplayAccessoryView:(id)sender;
- (IBAction) toggleEncryptToSelf:(id)sender;
- (IBAction) toggleAlwaysSignMessages:(id)sender;
- (IBAction) toggleAlwaysEncryptMessages:(id)sender;
- (IBAction) toggleBCCRecipientsUse:(id)sender;
- (IBAction) toggleTrustAllKeys:(id)sender;
- (IBAction) toggleOpenPGPMIME:(id)sender;
- (IBAction) toggleSignWhenEncrypting:(id)sender;
- (IBAction) toggleButtonsBehavior:(id)sender;
- (IBAction) toggleFilterKeys:(id)sender;
- (IBAction) toggleSmartRules:(id)sender;
- (IBAction) toggleSignedReplyToSignedMessage:(id)sender;
- (IBAction) toggleEncryptedReplyToEncryptedMessage:(id)sender;
- (IBAction) toggleEncryptWhenPossible:(id)sender;
- (IBAction) toggleSeparatePGPOperations:(id)sender;

- (IBAction) toggleAuthenticatesMessagesAutomatically:(id)sender;
- (IBAction) toggleAuthenticateUnreadMessagesAutomatically:(id)sender;
- (IBAction) toggleDecryptsMessagesAutomatically:(id)sender;
- (IBAction) toggleDecryptsUnreadMessagesAutomatically:(id)sender;
- (IBAction) toggleExtendedInformation:(id)sender;

- (IBAction) toggleShowUserIDs:(id)sender;
- (IBAction) toggleShowKeyInformation:(id)sender;
- (IBAction) changeLineWrapping:(id)sender;
- (IBAction) toggleKeyRefresh:(id)sender;
- (IBAction) toggleSMIME:(id)sender;

- (IBAction) exportGPGMailConfiguration:(id)sender;

@property (readonly) NSString *versionDescription;
@property (readonly) NSString *copyright;
@property (readonly) NSAttributedString *credits;
@property (readonly) NSAttributedString *websiteLink;



@end
