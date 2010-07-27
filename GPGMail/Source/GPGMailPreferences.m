/* GPGMailPreferences.m created by dave on Thu 29-Jun-2000 */

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

#import <Sparkle/Sparkle.h>
#import "GPGMailPreferences.h"
#import "GPGMailBundle.h"

#import "GPG.subproj/GPGPassphraseController.h"

@implementation GPGMailPreferences

- (SUUpdater *)updater {
    return [SUUpdater updaterForBundle:[NSBundle bundleWithIdentifier:@"org.gpgmail"]];
}


- (void) refreshKeyIdentifiersDisplay
{
    GPGMailBundle	*mailBundle = [GPGMailBundle sharedInstance];
    NSEnumerator	*anEnum; // = [[mailBundle allDisplayedKeyIdentifiers] objectEnumerator];
    NSString		*anIdentifier;
    NSEnumerator	*tableColumnEnum = [[NSArray arrayWithArray:[keyIdentifiersTableView tableColumns]] objectEnumerator];
    NSTableColumn	*aColumn;

    while(aColumn = [tableColumnEnum nextObject])
        [keyIdentifiersTableView removeTableColumn:aColumn];

    anEnum = [[mailBundle displayedKeyIdentifiers] objectEnumerator];
    while(anIdentifier = [anEnum nextObject])
        [keyIdentifiersTableView addTableColumn:[tableColumnPerIdentifier objectForKey:anIdentifier]];
    [keyIdentifiersTableView sizeToFit]; // No effect...
    [mailBundle refreshKeyIdentifiersDisplayInMenu:[keyIdentifiersPopUpButton menu]];
}

- (void) refreshPersonalKeys
{
    GPGMailBundle	*mailBundle = [GPGMailBundle sharedInstance];
    NSEnumerator	*keyEnum = [[mailBundle personalKeys] objectEnumerator];
    GPGKey          *aKey;
    NSString		*defaultKeyFingerprint = [[mailBundle defaultKey] fingerprint];
    BOOL			displaysAllUserIDs = [mailBundle displaysAllUserIDs];

    [personalKeysPopUpButton removeAllItems];
    while(aKey = [keyEnum nextObject]){
        NSMenuItem  *anItem;
        
        [personalKeysPopUpButton addItemWithTitle:[mailBundle menuItemTitleForKey:aKey]];
        anItem = [personalKeysPopUpButton lastItem];
        [anItem setRepresentedObject:aKey];
        if(defaultKeyFingerprint && [[aKey fingerprint] isEqualToString:defaultKeyFingerprint])
            [personalKeysPopUpButton selectItem:anItem];
        if(displaysAllUserIDs){
            NSEnumerator	*userIDEnum = [[mailBundle secondaryUserIDsForKey:aKey] objectEnumerator];
            GPGUserID       *aUserID;

            while(aUserID = [userIDEnum nextObject]){
                [personalKeysPopUpButton addItemWithTitle:[mailBundle menuItemTitleForUserID:aUserID indent:1]];
                [[personalKeysPopUpButton lastItem] setEnabled:NO];
            }
        }
    }
}

- (NSImage *) imageForPreferenceNamed:(NSString *)aName
{
    return [NSImage imageNamed:@"GPGMailPreferences"];
}

- (IBAction) toggleAlwaysSignMessages:(id)sender
{
    [[GPGMailBundle sharedInstance] setAlwaysSignMessages:([sender state] == NSOnState)];
}

- (IBAction) toggleAlwaysEncryptMessages:(id)sender
{
    [[GPGMailBundle sharedInstance] setAlwaysEncryptMessages:([sender state] == NSOnState)];
}

- (IBAction) toggleBCCRecipientsUse:(id)sender
{
    [[GPGMailBundle sharedInstance] setUsesBCCRecipients:([sender state] == NSOnState)];
}

- (IBAction) toggleTrustAllKeys:(id)sender
{
    [[GPGMailBundle sharedInstance] setTrustsAllKeys:([sender state] == NSOnState)];
}

- (IBAction) toggleOpenPGPMIME:(id)sender
{
    [[GPGMailBundle sharedInstance] setUsesOnlyOpenPGPStyle:([sender state] == NSOnState)];
}

- (IBAction) toggleAuthenticatesMessagesAutomatically:(id)sender
{
    BOOL	flag = ([sender state] == NSOnState);

    [[GPGMailBundle sharedInstance] setAuthenticatesMessagesAutomatically:flag];
    [authenticateUnreadMessagesSwitchButton setEnabled:flag];
}

- (IBAction) toggleExtendedInformation:(id)sender
{
    [[GPGMailBundle sharedInstance] setAutomaticallyShowsAllInfo:([sender state] == NSOnState)];
}

- (IBAction) toggleDecryptsMessagesAutomatically:(id)sender
{
    BOOL	flag = ([sender state] == NSOnState);

    [[GPGMailBundle sharedInstance] setDecryptsMessagesAutomatically:flag];
    [decryptUnreadMessagesSwitchButton setEnabled:flag];
}

- (IBAction) changeDefaultKey:(id)sender
{
    [[GPGMailBundle sharedInstance] setDefaultKey:[[personalKeysPopUpButton selectedItem] representedObject]];
}

- (IBAction) toggleAutomaticPersonalKeyChoice:(id)sender
{
    [[GPGMailBundle sharedInstance] setChoosesPersonalKeyAccordingToAccount:([sender state] == NSOnState)];
}

- (IBAction) changePassphraseStrategy:(id)sender
{
    switch([sender selectedRow]){
        case 0:
            [[GPGMailBundle sharedInstance] setUsesKeychain:YES];
            [[GPGMailBundle sharedInstance] setRemembersPassphrasesDuringSession:NO];
            [passphraseTimeoutFormCell setEnabled:NO];
            break;
        case 1:
            [[GPGMailBundle sharedInstance] setUsesKeychain:NO];
            [[GPGMailBundle sharedInstance] setRemembersPassphrasesDuringSession:NO];
            [passphraseTimeoutFormCell setEnabled:NO];
            break;
        case 2:
            [[GPGMailBundle sharedInstance] setUsesKeychain:NO];
            [[GPGMailBundle sharedInstance] setRemembersPassphrasesDuringSession:YES];
            [passphraseTimeoutFormCell setEnabled:YES];
    }
}

- (IBAction) changePassphraseTimeout:(id)sender
{
    [[GPGMailBundle sharedInstance] setPassphraseFlushTimeout:[passphraseTimeoutFormCell floatValue]];
}

- (IBAction) toggleEncryptToSelf:(id)sender
{
    [[GPGMailBundle sharedInstance] setEncryptsToSelf:([sender state] == NSOnState)];
}

- (IBAction) toggleDecryptsUnreadMessagesAutomatically:(id)sender
{
    [[GPGMailBundle sharedInstance] setDecryptsOnlyUnreadMessagesAutomatically:([sender state] == NSOnState)];
}

- (IBAction) toggleAuthenticateUnreadMessagesAutomatically:(id)sender
{
    [[GPGMailBundle sharedInstance] setAuthenticatesOnlyUnreadMessagesAutomatically:([sender state] == NSOnState)];
}

- (IBAction) toggleDisplayAccessoryView:(id)sender
{
    [[GPGMailBundle sharedInstance] setDisplaysButtonsInComposeWindow:([sender state] == NSOnState)];
}

- (IBAction) toggleButtonsBehavior:(id)sender
{
    [[GPGMailBundle sharedInstance] setButtonsShowState:([sender state] == NSOnState)];
}

- (IBAction) toggleSignWhenEncrypting:(id)sender
{
    [[GPGMailBundle sharedInstance] setSignWhenEncrypting:([sender state] == NSOnState)];
}

- (IBAction) toggleShowUserIDs:(id)sender
{
    [[GPGMailBundle sharedInstance] setDisplaysAllUserIDs:([sender state] == NSOnState)];
}

- (IBAction) toggleShowKeyInformation:(id)sender
{
    [[GPGMailBundle sharedInstance] gpgToggleShowKeyInformation:sender];
}

- (IBAction) toggleFilterKeys:(id)sender
{
    [[GPGMailBundle sharedInstance] setFiltersOutUnusableKeys:([sender state] == NSOnState)];
}

- (IBAction) toggleShowPassphrase:(id)sender
{
    [[GPGMailBundle sharedInstance] setShowsPassphrase:([sender state] == NSOnState)];
}

- (IBAction) changeLineWrapping:(id)sender
{
    [[GPGMailBundle sharedInstance] setLineWrappingLength:[lineWrappingFormCell intValue]];
}

- (IBAction) toggleSmartRules:(id)sender
{
    [[GPGMailBundle sharedInstance] setUsesABEntriesRules:([sender state] == NSOnState)];
}

- (IBAction) toggleSignedReplyToSignedMessage:(id)sender
{
    [[GPGMailBundle sharedInstance] setSignsReplyToSignedMessage:([sender state] == NSOnState)];
}

- (IBAction) toggleEncryptedReplyToEncryptedMessage:(id)sender
{
    [[GPGMailBundle sharedInstance] setEncryptsReplyToEncryptedMessage:([sender state] == NSOnState)];
}

- (IBAction) toggleEncryptWhenPossible:(id)sender
{
    [[GPGMailBundle sharedInstance] setEncryptMessagesWhenPossible:([sender state] == NSOnState)];
}

- (IBAction) toggleSeparatePGPOperations:(id)sender
{
    [[GPGMailBundle sharedInstance] setUsesEncapsulatedSignature:([sender state] == NSOnState)];
}

- (IBAction) toggleKeyRefresh:(id)sender
{
    [[GPGMailBundle sharedInstance] setRefreshesKeysOnVolumeMount:([sender state] == NSOnState)];
}

- (IBAction) toggleSMIME:(id)sender
{
    [[GPGMailBundle sharedInstance] setDisablesSMIME:([sender state] == NSOnState)];
}

- (int) numberOfRowsInTableView:(NSTableView *)tableView
{
    return 0;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    return nil;
}

- (void) tableViewColumnDidMove:(NSNotification *)notification
{
    if(!initializingPrefs){
        GPGMailBundle	*mailBundle = [GPGMailBundle sharedInstance];
        NSMutableArray	*anArray = [NSMutableArray arrayWithArray:[mailBundle displayedKeyIdentifiers]];
        int				anIndex = [[[notification userInfo] objectForKey:@"NSOldColumn"] intValue];
        id				anObject = [[anArray objectAtIndex:anIndex] retain];

        [anArray removeObjectAtIndex:anIndex];
        anIndex = [[[notification userInfo] objectForKey:@"NSNewColumn"] intValue];
        [anArray insertObject:anObject atIndex:anIndex];
        [anObject release];
        [mailBundle setDisplayedKeyIdentifiers:anArray];
        [self refreshKeyIdentifiersDisplay];
        [self refreshPersonalKeys];
    }
}

- (id) init
{
    if(self = [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyListWasInvalidated:) name:GPGKeyListWasInvalidatedNotification object:[GPGMailBundle sharedInstance]];
    }

    return self;
}

- (void) dealloc
{
    [tableColumnPerIdentifier release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GPGPreferencesDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GPGKeyListWasInvalidatedNotification object:nil];
    
    [super dealloc];
}

- (void) keyListWasInvalidated:(NSNotification *)notification
{
    [self refreshPersonalKeys];
}

- (void) awakeFromNib
{
    NSEnumerator            *anEnum = [[keyIdentifiersTableView tableColumns] objectEnumerator];
    NSTableColumn           *aColumn;
    NSAttributedString      *anAttributedString;
    NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];

    [pStyle setAlignment:NSRightTextAlignment];
    [versionTextField setStringValue:[[GPGMailBundle sharedInstance] versionDescription]];
    anAttributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:[contactTextField stringValue], @"gpgmail@sente.ch"] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSURL URLWithString:@"mailto:gpgmail@sente.ch"], NSLinkAttributeName, pStyle, NSParagraphStyleAttributeName, nil]];
    [contactTextField setAttributedStringValue:anAttributedString]; // FIXME: No effect on Panther!
    [anAttributedString release];
    anAttributedString = [[NSAttributedString alloc] initWithString:[webSiteTextField stringValue] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSURL URLWithString:[webSiteTextField stringValue]], NSLinkAttributeName, pStyle, NSParagraphStyleAttributeName, nil]];
    [webSiteTextField setAttributedStringValue:anAttributedString]; // FIXME: No effect on Panther!
    [anAttributedString release];
    [pStyle release];
    tableColumnPerIdentifier = [[NSMutableDictionary alloc] init];
    [personalKeysPopUpButton setAutoenablesItems:NO];

    while(aColumn = [anEnum nextObject])
        [tableColumnPerIdentifier setObject:aColumn forKey:[aColumn identifier]];
#if defined(SNOW_LEOPARD) || defined(LEOPARD) || defined(TIGER)
    [keyIdentifiersTableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
#else
    [keyIdentifiersTableView setAutoresizesAllColumnsToFit:YES];
#endif
#if defined(SNOW_LEOPARD) || defined(LEOPARD)
    // Since 10.5, we can no longer reorder column when tableView data height is null.
    // As a workaround, we add 1 pixel.
    // FIXME: replace that tableView by NSTokenField
    NSRect  aFrame = [[keyIdentifiersTableView enclosingScrollView] frame];
    
    aFrame.origin.y -= 1;
    aFrame.size.height += 1;
    [[keyIdentifiersTableView enclosingScrollView] setFrame:aFrame];
#endif
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesDidChange:) name:GPGPreferencesDidChangeNotification object:[GPGMailBundle sharedInstance]];
}

- (void) initializeFromDefaults
{
    GPGMailBundle	*mailBundle = [GPGMailBundle sharedInstance];
    BOOL			flag;

    initializingPrefs = YES;
    [super initializeFromDefaults];
    [choosesPersonalKeyAccordingToAccountSwitchButton setState:([mailBundle choosesPersonalKeyAccordingToAccount] ? NSOnState:NSOffState)];
    flag = [mailBundle usesKeychain];
    if([mailBundle remembersPassphrasesDuringSession]){
        [passphraseTimeoutFormCell setEnabled:YES];
        [passphraseStrategyMatrix selectCellAtRow:2 column:0];
    }
    else{
        [passphraseTimeoutFormCell setEnabled:NO];
        [passphraseStrategyMatrix selectCellAtRow:(flag ? 0:1) column:0];
    }
    [passphraseTimeoutFormCell setFloatValue:[mailBundle passphraseFlushTimeout]];
    [alwaysSignSwitchButton setState:([mailBundle alwaysSignMessages] ? NSOnState:NSOffState)];
    [alwaysEncryptSwitchButton setState:([mailBundle alwaysEncryptMessages] ? NSOnState:NSOffState)];
    [useBCCRecipientsSwitchButton setState:([mailBundle usesBCCRecipients] ? NSOnState:NSOffState)];
    [trustAllKeysSwitchButton setState:([mailBundle trustsAllKeys] ? NSOnState:NSOffState)];
    [openPGPMIMESwitchButton setState:([mailBundle usesOnlyOpenPGPStyle] ? NSOnState:NSOffState)];
    flag = [mailBundle authenticatesMessagesAutomatically];
    [automaticallyAuthenticateMessagesSwitchButton setState:(flag ? NSOnState:NSOffState)];
    [authenticateUnreadMessagesSwitchButton setEnabled:flag];
    [authenticateUnreadMessagesSwitchButton setState:([mailBundle authenticatesOnlyUnreadMessagesAutomatically] ? NSOnState:NSOffState)];
    [self refreshPersonalKeys];
    flag = [mailBundle decryptsMessagesAutomatically];
    [automaticallyDecryptMessagesSwitchButton setState:(flag ? NSOnState:NSOffState)];
    [decryptUnreadMessagesSwitchButton setEnabled:flag];
    [decryptUnreadMessagesSwitchButton setState:([mailBundle decryptsOnlyUnreadMessagesAutomatically] ? NSOnState:NSOffState)];
    [encryptToSelfSwitchButton setState:([mailBundle encryptsToSelf] ? NSOnState:NSOffState)];
    [displayButtonInComposeWindowSwitchButton setState:([mailBundle displaysButtonsInComposeWindow] ? NSOnState:NSOffState)];
    [extendedInfoSwitchButton setState:([mailBundle automaticallyShowsAllInfo] ? NSOnState:NSOffState)];
    [buttonsShowStateSwitchButton setState:([mailBundle buttonsShowState] ? NSOnState:NSOffState)];
    [signWhenEncryptingSwitchButton setState:([mailBundle signWhenEncrypting] ? NSOnState:NSOffState)];
    [showUserIDsSwitchButton setState:([mailBundle displaysAllUserIDs] ? NSOnState:NSOffState)];
    [filtersKeysSwitchButton setState:([mailBundle filtersOutUnusableKeys] ? NSOnState:NSOffState)];
    [showsPassphraseSwitchButton setState:([mailBundle showsPassphrase] ? NSOnState:NSOffState)];
    [self refreshKeyIdentifiersDisplay];
    [lineWrappingFormCell setIntValue:[mailBundle lineWrappingLength]];
    [useSmartRulesSwitchButton setState:([mailBundle usesABEntriesRules] ? NSOnState:NSOffState)];
    [signReplyToSignedMessageSwitchButton setState:([mailBundle signsReplyToSignedMessage] ? NSOnState:NSOffState)];
    [encryptReplyToEncryptedMessageSwitchButton setState:([mailBundle encryptsReplyToEncryptedMessage] ? NSOnState:NSOffState)];
    [encryptWhenAllKeysAvailableSwitchButton setState:([mailBundle encryptMessagesWhenPossible] ? NSOnState:NSOffState)];
    [separateSignAndEncryptOperationsSwitchButton setState:([mailBundle usesEncapsulatedSignature] ? NSOnState:NSOffState)];
    [refreshKeysOnVolumeChangeSwitchButton setState:([mailBundle refreshesKeysOnVolumeMount] ? NSOnState:NSOffState)];
    [disableSMIMESwitchButton setState:([mailBundle disablesSMIME] ? NSOnState:NSOffState)];

    initializingPrefs = NO;
}

- (IBAction) flushCachedPassphrases:(id)sender
{
    [GPGPassphraseController flushCachedPassphrases];
}

- (void) preferencesDidChange:(NSNotification *)notification
{
    NSString		*aKey = [[notification userInfo] objectForKey:@"key"];
    GPGMailBundle	*mailBundle = [GPGMailBundle sharedInstance];

    if([aKey isEqualToString:@"displaysAllUserIDs"]){
        [showUserIDsSwitchButton setState:([mailBundle displaysAllUserIDs] ? NSOnState:NSOffState)];
        [self refreshPersonalKeys];
    }
    else if([aKey isEqualToString:@"displayedKeyIdentifiers"]){
        [self refreshKeyIdentifiersDisplay];
        [self refreshPersonalKeys];
    }
    else if([aKey isEqualToString:@"filtersOutUnusableKeys"]){
        [self refreshPersonalKeys];
    }
}

- (IBAction) refreshKeys:(id)sender
{
    [[GPGMailBundle sharedInstance] gpgReloadPGPKeys:sender];
    [sender setState:NSOffState];
}

- (IBAction) exportGPGMailConfiguration:(id)sender
{
    NSDictionary        *aDict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSEnumerator        *keyEnum = [aDict keyEnumerator];
    NSString            *aKey;
    NSMutableDictionary *exportedDict = [NSMutableDictionary dictionaryWithCapacity:20];
    
    while(aKey = [keyEnum nextObject]){
        if([aKey hasPrefix:@"GPG"])
            [exportedDict setObject:[aDict objectForKey:aKey] forKey:aKey];
    }
    NSLog(@"GPGMail %@ configuration:\n%@", [(GPGMailBundle *)[GPGMailBundle sharedInstance] version], exportedDict);
}

@end
