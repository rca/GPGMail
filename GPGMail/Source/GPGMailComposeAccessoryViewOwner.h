/* GPGMailComposeAccessoryViewOwner.h created by dave on Thu 29-Jun-2000 */

/*
 * Copyright (c) 2000-2011, GPGTools Project Team <gpgmail-devel@lists.gpgmail.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGTools Project Team nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGTools Project Team ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGTools Project Team BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <MVComposeAccessoryViewOwner.h>
#import "GPG.subproj/GPGHandler.h"
#import <MacGPGME/MacGPGME.h>
#import <AppKit/AppKit.h>


@class OptionalView;
@class ColorBackgroundView;

#ifdef SNOW_LEOPARD_64
@interface GPGMailComposeAccessoryViewOwner : NSObject
#else
@interface GPGMailComposeAccessoryViewOwner : MVComposeAccessoryViewOwner
#endif
{
	BOOL encryptsMessage;
	BOOL signsMessage;
	IBOutlet NSButton *encryptionSwitch;
	IBOutlet NSButton *signSwitch;
	IBOutlet NSView *emptyView;
	IBOutlet NSView *fullView;
	IBOutlet NSPopUpButton *personalKeysPopUpButton;
	IBOutlet NSPopUpButton *publicKeysPopDownButton;
	IBOutlet NSPanel *publicKeysPanel;
	IBOutlet NSOutlineView *publicKeysOutlineView;
	NSMutableArray *selectedPublicKeys;
	NSMutableSet *missingPublicKeyEmails;
	GPGKey *selectedPersonalKey;
	GPGKey *selectedPersonalPublicKey;
	BOOL useCustomPublicKeys;
	BOOL cachedUseCustomPublicKeys;
	NSTableColumn *sortingTableColumn;
	BOOL ascendingOrder;
	IBOutlet NSPopUpButton *popDownButton;
	NSMutableArray *allTableColumns;
	NSArray *allPublicKeys;
	int cachedPublicKeyCount;
	BOOL publicKeysAreSorted;
	NSImage *ascendingOrderImage;
	NSImage *descendingOrderImage;
	BOOL publicKeysOutlineViewHasBeenInitialized;
	BOOL usesSymetricEncryption;
	BOOL usesOnlyOpenPGPStyle;
	BOOL explicitlySetEncryption;
	BOOL explicitlySetSignature;
	BOOL explicitlySetOpenPGPStyle;
	BOOL somePeopleWantSigning;
	BOOL somePeopleDontWantSigning;
	BOOL somePeopleWantEncryption;
	BOOL somePeopleDontWantEncryption;
	BOOL somePeopleWantMIME;
	BOOL somePeopleDontWantMIME;
	BOOL signatureTurnedOnBecauseEncrypted;
	NSMutableSet *cachedRecipients;
	NSDictionary *replyOptions;
	BOOL needsWarning;

	BOOL verifyRulesConflicts;
	IBOutlet NSPanel *conflictPanel;
	IBOutlet NSTableView *conflictTableView;
	IBOutlet NSButton *conflictEncryptionButton;
	IBOutlet NSButton *conflictSignatureButton;
	IBOutlet NSButton *conflictMIMEButton;
	NSMutableDictionary *pgpOptionsPerEmail;
	IBOutlet OptionalView *optionalView;
	IBOutlet NSTextField *optionalViewTitleField;
	IBOutlet ColorBackgroundView *optionalViewBackgroundView;
	BOOL displaysButtonsInComposeWindow;
	BOOL windowWillClose;
	BOOL setupUI;
	NSArray *currentStates;
}

- (IBAction)gpgToggleEncryptionForNewMessage:(id)sender;
- (IBAction)gpgToggleSignatureForNewMessage:(id)sender;
- (IBAction)choosePersonalKey:(id)sender;
- (IBAction)gpgChoosePublicKeys:(id)sender;
- (IBAction)gpgChoosePublicKey:(id)sender;
- (IBAction)gpgDownloadMissingKeys:(id)sender;
- (IBAction)gpgChoosePersonalKey:(id)sender;
- (IBAction)gpgUseDefaultPublicKeys:(id)sender;
- (IBAction)gpgToggleAutomaticPublicKeysChoice:(id)sender;
- (IBAction)gpgToggleSymetricEncryption:(id)sender;
- (IBAction)gpgToggleUsesOnlyOpenPGPStyle:(id)sender;
- (IBAction)endModal:(id)sender;
- (IBAction)toggleColumnDisplay:(id)sender;

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem;

- (void)gpgSetOptions:(NSDictionary *)options;

- (IBAction)endConflictResolution:(id)sender;

- (BOOL)displaysButtonsInComposeWindow;
- (void)setDisplaysButtonsInComposeWindow:(BOOL)value;

- (void)evaluateRules;

@end
