/* HeadersEditor+GPGMail.m re-created by Lukas Pitschl (@lukele) on Wed 25-Aug-2011 */

/*
 * Copyright (c) 2000-2011, GPGTools Project Team <gpgtools-devel@lists.gpgtools.org>
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

#import <Libmacgpg/Libmacgpg.h>
#import <NSObject+LPDynamicIvars.h>
#import "CCLog.h"
#import <MailDocumentEditor.h>
#import "MailNotificationCenter.h"
#import "Message+GPGMail.h"
#import "MailDocumentEditor+GPGMail.h"
#import "HeadersEditor.h"
#import "ComposeHeaderView.h"
#import "HeadersEditor+GPGMail.h"
#import "ComposeBackEnd.h"
#import "ComposeBackEnd+GPGMail.h"
#import "GPGMailBundle.h"
#import "NSString+GPGMail.h"
#import "GMSecurityControl.h"
#import "NSObject+LPDynamicIvars.h"
#import <NSString-EmailAddressString.h>
#import "GMComposeKeyEventHandler.h"
#import "OptionalView.h"



@interface HeadersEditor_GPGMail (NoImplementation)
- (void)changeFromHeader:(NSPopUpButton *)sender;
@end

@implementation HeadersEditor_GPGMail


- (void)symmetricEncryptClicked:(id)sender {
	ComposeBackEnd *backEnd = [[self valueForKey:@"_documentEditor"] backEnd];
	BOOL oldValue = [[backEnd getIvar:@"shouldSymmetric"] boolValue];
	BOOL newValue = !oldValue;
	
	if (![[backEnd getIvar:@"SymmetricIsPossible"] boolValue]) {
		newValue = NO;
	}
	
	[backEnd setIvar:@"shouldSymmetric" value:@(newValue)];
	if (newValue != oldValue) {
		[backEnd setIvar:@"ForceSymmetric" value:@(newValue)];
	}
	
	[self updateSymmetricButton];
	[(MailDocumentEditor_GPGMail *)[backEnd delegate] updateSecurityMethodHighlight];
}

- (void)updateSymmetricButton {
	if (![[self getIvar:@"AllowSymmetricEncryption"] boolValue]) {
		return;
	}
	ComposeBackEnd *backEnd = [[self valueForKey:@"_documentEditor"] backEnd];
	
	NSSegmentedControl *symmetricButton = [self getIvar:@"_symmetricButton"];
	
	GPGMAIL_SECURITY_METHOD securityMethod = ((ComposeBackEnd_GPGMail *)backEnd).guessedSecurityMethod;
	if (((ComposeBackEnd_GPGMail *)backEnd).securityMethod)
		securityMethod = ((ComposeBackEnd_GPGMail *)backEnd).securityMethod;
	
	
	
	NSString *imageName;
	if ([[backEnd getIvar:@"SymmetricIsPossible"] boolValue] && securityMethod == GPGMAIL_SECURITY_METHOD_OPENPGP) {
		NSNumber *forceSymmetric = [backEnd getIvar:@"ForceSymmetric"];
		if (forceSymmetric) {
			[backEnd setIvar:@"shouldSymmetric" value:forceSymmetric];
		}
		
		[symmetricButton setEnabled:YES forSegment:0];
		if ([[backEnd getIvar:@"shouldSymmetric"] boolValue]) {
			imageName = @"SymmetricEncryptionOn";
		} else {
			imageName = @"SymmetricEncryptionOff";
		}
	} else {
		imageName = @"SymmetricEncryptionOff";
		[symmetricButton setEnabled:NO forSegment:0];
	}
	
	[symmetricButton setImage:[NSImage imageNamed:imageName] forSegment:0];
}


- (void)MAAwakeFromNib {
    [self MAAwakeFromNib];
	
    // This lock is used to prevent a SecurityMethodDidChange notification to
    // mess with an ongoing _updateSecurityStateInBackgroundForRecipients:recipients:
    // call.
	NSLock *updateSecurityStateLock = [[NSLock alloc] init];
    [self setIvar:@"SecurityStateLock" value:updateSecurityStateLock];
	[(MailNotificationCenter *)[NSClassFromString(@"MailNotificationCenter") defaultCenter] addObserver:self selector:@selector(securityMethodDidChange:) name:@"SecurityMethodDidChangeNotification" object:nil];
	[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyringUpdated:) name:GPGMailKeyringUpdatedNotification object:nil];

	
	NSSegmentedControl *symmetricButton = nil;
	OptionalView *optionalView = (OptionalView *)[[self valueForKey:@"_signButton"] superview];

	
	if ([[GPGOptions sharedOptions] boolForKey:@"AllowSymmetricEncryption"]) {
		symmetricButton = [[NSSegmentedControl alloc] initWithFrame:NSMakeRect(24, -1, 38, 24)];
		symmetricButton.segmentCount = 1;
		[symmetricButton setWidth:32 forSegment:0];
		symmetricButton.segmentStyle = NSSegmentStyleRounded;
		((NSSegmentedCell *)symmetricButton.cell).trackingMode = NSSegmentSwitchTrackingMomentary;
		symmetricButton.target = self;
		symmetricButton.action = @selector(symmetricEncryptClicked:);
		
		NSRect frame = optionalView.frame;
		frame.size.width += 44;
		optionalView.frame = frame;
		
		for (NSView *view in optionalView.subviews) {
			if (![view isKindOfClass:[NSButton class]]) {
				frame = view.frame;
				frame.origin.x += 44;
				view.frame = frame;
			}
		}
		
		
		[self setIvar:@"_symmetricButton" value:symmetricButton];
		[self setIvar:@"AllowSymmetricEncryption" value:@YES];
		[self updateSymmetricButton];
		
		[optionalView addSubview:symmetricButton];
		CFBridgingRetain(optionalView.primaryView); //TODO: Verursacht dieser Aufruf ein Leak?
		[optionalView setValue:symmetricButton forKey:@"primaryView"];
	}
	
	
	
	GMSecurityControl *signControl = [[GMSecurityControl alloc] initWithControl:[self valueForKey:@"_signButton"] tag:SECURITY_BUTTON_SIGN_TAG];
    [self setValue:signControl forKey:@"_signButton"];
    
    GMSecurityControl *encryptControl = [[GMSecurityControl alloc] initWithControl:[self valueForKey:@"_encryptButton"] tag:SECURITY_BUTTON_ENCRYPT_TAG];
    [self setValue:encryptControl forKey:@"_encryptButton"];
	
	GMComposeKeyEventHandler *handler = [[GMComposeKeyEventHandler alloc] initWithView:optionalView];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
	handler.eventsAndSelectors = [NSArray arrayWithObjects:
		@{@"keyEquivalent": @"y", @"keyEquivalentModifierMask": @(NSCommandKeyMask | NSAlternateKeyMask), @"target": encryptControl, @"selector": [NSValue valueWithPointer:@selector(performClick:)]},
		@{@"keyEquivalent": @"x", @"keyEquivalentModifierMask": @(NSCommandKeyMask | NSAlternateKeyMask), @"target": signControl, @"selector": [NSValue valueWithPointer:@selector(performClick:)]},
		symmetricButton ? @{@"keyEquivalent": @"Y", @"keyEquivalentModifierMask": @(NSCommandKeyMask | NSShiftKeyMask), @"target": symmetricButton, @"selector": [NSValue valueWithPointer:@selector(performClick:)]} : nil,
	nil];
#pragma clang diagnostic pop

	
}

- (void)MASecurityControlChanged:(id)securityControl {
    GMSecurityControl *signControl = [self valueForKey:@"_signButton"];
    GMSecurityControl *encryptControl = [self valueForKey:@"_encryptButton"];
    NSSegmentedControl *originalSecurityControl = securityControl;
	
	    
    securityControl = signControl.control == securityControl ? signControl : encryptControl;
    // The securityControl passed to this method is an NSSegmentControl.
	// So the only chance to find out what the new status of the control is,
	// is to check its current image. (I really thought I was crazy writing this code,
	// now it all makes sense again. WHAT A RELIEF)
	[securityControl updateStatusFromImage:[originalSecurityControl imageForSegment:0]];
    
    [self MASecurityControlChanged:securityControl];
}

- (void)MA_updateFromAndSignatureControls:(id)arg1 {
    [self MA_updateFromAndSignatureControls:arg1];
	// Thanks to Hopper (YES, it's fantastic) it's not clear that
	// _updateFromAndSignatureControls calls setAccountFieldEnabled|Visible
	// on the ComposeHeaderView.
	// Now to force the from (account field) it should suffice to simply
	// call both methods with YES.
	[(ComposeHeaderView *)[self valueForKey:@"_composeHeaderView"] setAccountFieldEnabled:YES];
	[(ComposeHeaderView *)[self valueForKey:@"_composeHeaderView"] setAccountFieldVisible:YES];
    // If any luck, the security option should be known by now.
    ComposeBackEnd *backEnd = [(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd];
    GPGMAIL_SECURITY_METHOD securityMethod = ((ComposeBackEnd_GPGMail *)backEnd).guessedSecurityMethod;
    if(((ComposeBackEnd_GPGMail *)backEnd).securityMethod)
        securityMethod = ((ComposeBackEnd_GPGMail *)backEnd).securityMethod;
    
    [self fromHeaderDisplaySecretKeys:securityMethod == GPGMAIL_SECURITY_METHOD_OPENPGP];
}

- (void)MAUpdateSecurityControls {
	[self updateSymmetricButton];
    [self MAUpdateSecurityControls];
}

- (void)_fromHeaderDisplaySecretKeys:(NSNumber *)display {
    [self fromHeaderDisplaySecretKeys:[display boolValue]];
}

- (void)fromHeaderDisplaySecretKeys:(BOOL)display {
    NSPopUpButton *popUp = [[self valueForKey:@"_composeHeaderView"] valueForKey:@"_accountPopUp"];
	NSMenu *menu = [popUp menu];
	NSArray *menuItems = [menu itemArray];
	GPGMailBundle *bundle = [GPGMailBundle sharedInstance];
	// Is used to properly truncate our own menu items.
    NSMutableParagraphStyle *truncateStyle = [[NSMutableParagraphStyle alloc] init];
    [truncateStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes addEntriesFromDictionary:[[menuItems[0] attributedTitle] fontAttributesInRange:NSMakeRange(0, [[menuItems[0] attributedTitle] length])]];
	attributes[NSParagraphStyleAttributeName] = truncateStyle;
    NSMenuItem *item, *parentItem, *selectedItem = [popUp selectedItem], *subItemToSelect = nil;
	GPGKey *defaultKey = [bundle preferredGPGKeyForSigning];
	BOOL useTitleFromAccount = [[GPGOptions sharedOptions] boolForKey:@"ShowAccountNameForKeysOfSameAddress"];
	
    // If menu items are not yet set, simply exit.
    // This might happen if securityMethodDidChange notification
    // is posted before the menu items have been configured.
    if(!menuItems.count)
        return;
    
	menu.autoenablesItems = NO;
	
	NSUInteger count = [menuItems count], i = 0;
	for (; i < count; i++) {
		item = menuItems[i];
		parentItem = [item getIvar:@"parentItem"];
		if (parentItem) {
			[menu removeItem:item]; // We remove all elements that represent a key.
		} else if (display) {
			NSString *itemTitle = item.title;
			
			NSString *email = nil;
			if (useTitleFromAccount == NO)
				email = [itemTitle uncommentedAddress];
				
			NSSet *keys = [bundle signingKeyListForAddress:itemTitle];
			switch ([keys count]) {
				case 0:
					// We have no key for this account.
					[item removeIvar:@"gpgKey"];
					item.hidden = NO;
					break;
				case 1:
					// We have only one key for this account: Set it.
					[item setIvar:@"gpgKey" value:[keys anyObject]];
					item.hidden = NO;
					break;
				default: {
					// We have more than one key for this account:
					// Add menu items to let the user choose.
					NSInteger index = [menu indexOfItem:item];
					
					for (GPGKey *key in keys) {
						NSMenuItem *subItem = nil;
						if (i + 1 < count && (subItem = menuItems[i + 1]) && [subItem getIvar:@"parentItem"] && [subItem getIvar:@"gpgKey"] == key) {
							// The next item is the item we want to create: Jump over.
							i++;
							index++;
						} else {
							NSString *title;
							if (useTitleFromAccount) {
								title = [NSString stringWithFormat:@"%@ (%@)", itemTitle, key.shortKeyID]; // Compose the title "Name <E-Mail> (KeyID)".
							} else {
								title = [NSString stringWithFormat:@"%@ <%@> (%@)", key.name, email, key.shortKeyID]; // Compose the title "key.Name <E-Mail> (KeyID)".
							}
							
							NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];

							// Create the menu item with the given title...
							subItem = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
							[subItem setAttributedTitle:attributedTitle];
							[subItem setIvar:@"gpgKey" value:key]; // GPGKey...
							[subItem setIvar:@"parentItem" value:item]; // and set the parentItem.
							
							[menu insertItem:subItem atIndex:++index]; // Insert it in the "From:" menu.
                        }
						if (item == selectedItem) {
							if (key == defaultKey) {
								subItemToSelect = subItem;
							}
						}
						
					}
					item.hidden = YES;
					break; }
			}
		} else { // display == NO
			// Restore all original items.
			[item removeIvar:@"gpgKey"];
			item.hidden = NO;
		}
	}
	
	ComposeBackEnd *backEnd = [[self valueForKey:@"_documentEditor"] backEnd];
	
    // Select a valid item if needed.
    if (selectedItem.isHidden) {
        [popUp setIvar:@"CalledFromGPGMail" value:@YES];
		NSUInteger index;
		if (subItemToSelect) {
			index = [menu indexOfItem:subItemToSelect];
		} else {
			index = [menu indexOfItem:selectedItem] + 1;
		}
        [popUp selectItemAtIndex:index];
        [self changeFromHeader:popUp];
    }
    else if ([popUp selectedItem] != selectedItem) {
        if ((parentItem = [selectedItem getIvar:@"parentItem"])) {
            selectedItem = parentItem;
        }
        [popUp setIvar:@"CalledFromGPGMail" value:@YES];
        [popUp selectItem:selectedItem];
        [self changeFromHeader:popUp];
    } else if (![backEnd getIvar:@"gpgKeyForSigning"]) {
		id gpgKey = [selectedItem getIvar:@"gpgKey"];
		if (gpgKey) {
			[backEnd setIvar:@"gpgKeyForSigning" value:gpgKey];
		}
	}
}

- (void)MAChangeFromHeader:(NSPopUpButton *)sender {
    BOOL calledFromGPGMail = [[sender getIvar:@"CalledFromGPGMail"] boolValue];
    [sender setIvar:@"CalledFromGPGMail" value:@NO];
    // If the newly selected item is the currently select item,
    // just bail out.
    // Update: this doesn't work, since the selected item of _accountPopup is of course already updated.
//    if(!calledFromGPGMail) {
//        NSPopUpButton *accountPopUp = [[self valueForKey:@"_composeHeaderView"] valueForKey:@"_accountPopUp"];
//        if(sender.selectedItem == accountPopUp.selectedItem)
//            return;
//    }
    
    // Create a new NSPopUpButton with only one item and the correct title.
	NSPopUpButton *button = [[NSPopUpButton alloc] init];
	NSMenuItem *item = [sender selectedItem];
	NSMenuItem *parentItem = [item getIvar:@"parentItem"];
	[button addItemWithTitle:(parentItem ? parentItem : item).title];
    // Set the selected key in the back-end.
	[[(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd] setIvar:@"gpgKeyForSigning" value:[item getIvar:@"gpgKey"]];
    
    // Only reset the status if this method is called from a user generated event.
    // Otherwise there's a notification loop, because the security method is set and reset again 
    // and again.
    // Also don't reset it, if the user chose the security method beforehand.
    if(!calledFromGPGMail && !((ComposeBackEnd_GPGMail *)[(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd]).userDidChooseSecurityMethod) {
        ((ComposeBackEnd_GPGMail *)[(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd]).securityMethod = 0;
    }

	[self MAChangeFromHeader:button/*sender*/];
}

- (void)resetSecurityButtons {
    GMSecurityControl *signControl = [self valueForKey:@"_signButton"];
    GMSecurityControl *encryptControl = [self valueForKey:@"_encryptButton"];
    
    // Reset the controls if the security method changes.
    signControl.forcedImageName = nil;
    encryptControl.forcedImageName = nil;
}

- (void)securityMethodDidChange:(NSNotification *)notification {
    // Reset the controls if the security method changes.
//    [self resetSecurityButtons];
}

- (void)keyringUpdated:(NSNotification *)notification {
    GPGMAIL_SECURITY_METHOD securityMethod = ((ComposeBackEnd_GPGMail *)[(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd]).guessedSecurityMethod;
    if(((ComposeBackEnd_GPGMail *)[(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd]).securityMethod)
        securityMethod = ((ComposeBackEnd_GPGMail *)[(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd]).securityMethod;
    if(securityMethod == GPGMAIL_SECURITY_METHOD_OPENPGP)
        [self performSelectorOnMainThread:@selector(_fromHeaderDisplaySecretKeys:) withObject:(id)kCFBooleanTrue waitUntilDone:NO];
}

- (void)MA_updateSignButtonTooltip {
    ComposeBackEnd_GPGMail *backEnd = ((ComposeBackEnd_GPGMail *)[(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd]);
    
    if(![[backEnd getIvar:@"SignIsPossible"] boolValue]) {
        NSPopUpButton *button = [self valueForKey:@"_fromPopup"];
        NSString *sender = [button.selectedItem.title uncommentedAddress];
        
        if([sender length] == 0 && [button.itemArray count])
            sender = [[(button.itemArray)[0] title] uncommentedAddress];
        
        GMSecurityControl *signControl = [self valueForKey:@"_signButton"];
        [((NSSegmentedControl *)signControl) setToolTip:[NSString stringWithFormat:GMLocalizedString(@"COMPOSE_WINDOW_TOOLTIP_CAN_NOT_PGP_SIGN"), sender]];
    }
    else {
        [self MA_updateSignButtonTooltip];
    }
}

- (void)MA_updateEncryptButtonTooltip {
    ComposeBackEnd_GPGMail *backEnd = ((ComposeBackEnd_GPGMail *)[(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd]);
    
    GPGMAIL_SECURITY_METHOD securityMethod = backEnd.guessedSecurityMethod;
    if(backEnd.securityMethod)
        securityMethod = backEnd.securityMethod;
    
    if(![[backEnd getIvar:@"EncryptIsPossible"] boolValue] && securityMethod == GPGMAIL_SECURITY_METHOD_OPENPGP) {
        NSArray *nonEligibleRecipients = [(ComposeBackEnd *)backEnd recipientsThatHaveNoKeyForEncryption];
        GMSecurityControl *encryptControl = [self valueForKey:@"_encryptButton"];
        NSString *toolTip = nil;
        if(![nonEligibleRecipients count])
            toolTip = GMLocalizedString(@"COMPOSE_WINDOW_TOOLTIP_CAN_NOT_PGP_ENCRYPT_NO_RECIPIENTS");
        else {
            NSString *recipients = [nonEligibleRecipients componentsJoinedByString:@", "];
            toolTip = [NSString stringWithFormat:GMLocalizedString(@"COMPOSE_WINDOW_TOOLTIP_CAN_NOT_PGP_ENCRYPT"), recipients];
        }
        [((NSSegmentedControl *)encryptControl) setToolTip:toolTip];
    }
    else {
        [self MA_updateEncryptButtonTooltip];
    }
}

- (void)MADealloc {
    @try {
        [(MailNotificationCenter *)[NSClassFromString(@"MailNotificationCenter") defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (id e) {
    }
	[self MADealloc];
}

@end


