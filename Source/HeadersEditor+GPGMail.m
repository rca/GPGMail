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
#import "HeadersEditor+GPGMail.h"
#import "ComposeBackEnd.h"
#import "ComposeBackEnd+GPGMail.h"
#import "GPGMailBundle.h"
#import "NSString+GPGMail.h"
#import "GMSecurityControl.h"
#import "NSObject+LPDynamicIvars.h"

@interface HeadersEditor_GPGMail (NoImplementation)
- (void)changeFromHeader:(NSPopUpButton *)sender;
@end

@implementation HeadersEditor_GPGMail

- (void)MAAwakeFromNib {
    [self MAAwakeFromNib];

    GMSecurityControl *signControl = [[GMSecurityControl alloc] initWithControl:[self valueForKey:@"_signButton"] tag:SECURITY_BUTTON_SIGN_TAG];
    [self setValue:signControl forKey:@"_signButton"];
    [signControl release];
    
    GMSecurityControl *encryptControl = [[GMSecurityControl alloc] initWithControl:[self valueForKey:@"_encryptButton"] tag:SECURITY_BUTTON_ENCRYPT_TAG];
    [self setValue:encryptControl forKey:@"_encryptButton"];
    [encryptControl release];
}

- (void)MASecurityControlChanged:(id)securityControl {
    GMSecurityControl *signControl = [self valueForKey:@"_signButton"];
    GMSecurityControl *encryptControl = [self valueForKey:@"_encryptButton"];
    NSSegmentedControl *originalSecurityControl = securityControl;
    
    securityControl = signControl.control == securityControl ? signControl : encryptControl;
    [securityControl updateStatusFromImage:[originalSecurityControl imageForSegment:0]];
    
    [self MASecurityControlChanged:securityControl];
}

- (void)MA_updateFromAndSignatureControls:(id)arg1 {
    [self MA_updateFromAndSignatureControls:arg1];
    // If any luck, the security option should be known by now.
    ComposeBackEnd *backEnd = [(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd];
    GPGMAIL_SECURITY_METHOD securityMethod = ((ComposeBackEnd_GPGMail *)backEnd).guessedSecurityMethod;
    if(((ComposeBackEnd_GPGMail *)backEnd).securityMethod)
        securityMethod = ((ComposeBackEnd_GPGMail *)backEnd).securityMethod;
    
    [self fromHeaderDisplaySecretKeys:securityMethod == GPGMAIL_SECURITY_METHOD_OPENPGP];
}

- (void)MA_updateSecurityStateInBackgroundForRecipients:(NSArray *)recipients sender:(NSString *)sender {
    // Check for NoUpdateSecurityState. If that is set, do not again
    // update the state 'cause we're right in the middle of that.
    @try {
        [[self getIvar:@"SecurityStateLock"] lock];
        [self MA_updateSecurityStateInBackgroundForRecipients:recipients sender:sender];
    }
    @catch (id e) {
        DebugLog(@"Failed to acquire SecurityStateLock: %@", e);
    }
    @finally {
        [[self getIvar:@"SecurityStateLock"] unlock];
    }
}

- (void)MAUpdateSecurityControls {
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
    [attributes addEntriesFromDictionary:[[[menuItems objectAtIndex:0] attributedTitle] fontAttributesInRange:NSMakeRange(0, [[[menuItems objectAtIndex:0] attributedTitle] length])]];
	[attributes setObject:truncateStyle forKey:NSParagraphStyleAttributeName];
	[truncateStyle release];
    NSMenuItem *item, *parentItem, *selectedItem = [popUp selectedItem];
	
    // If menu items are not yet set, simply exit.
    // This might happen if securityMethodDidChange notification
    // is posted before the menu items have been configured.
    if(!menuItems.count)
        return;
    
	menu.autoenablesItems = NO;
	
	
	NSUInteger count = [menuItems count], i = 0;
	for (; i < count; i++) {
		item = [menuItems objectAtIndex:i];
		parentItem = [item getIvar:@"parentItem"];
		if (parentItem) {
			[menu removeItem:item]; // We remove all elements that represent a key.
		} else if (display) {
			NSSet *keys = [bundle signingKeyListForAddress:item.title];
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
						NSMenuItem *nextMenuItem = [menuItems objectAtIndex:i + 1];
						if (i + 1 < count && [nextMenuItem getIvar:@"parentItem"] && [nextMenuItem getIvar:@"gpgKey"] == key) {
							// The next item is the item we want to create: Jump over.
							i++;
							index++;
						} else {
							NSString *title = [NSString stringWithFormat:@"%@ (%@)", item.title, key.shortKeyID]; // Compose the title "Name <E-Mail> (KeyID)".
							NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];

							// Create the menu item with the given title...
							NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
							[newItem setAttributedTitle:attributedTitle];
                            [attributedTitle release];
							[newItem setIvar:@"gpgKey" value:key]; // GPGKey...
							[newItem setIvar:@"parentItem" value:item]; // and set the parentItem.
							
							[menu insertItem:newItem atIndex:++index]; // Insert it in the "From:" menu.
                            [newItem release];
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
	
    // Select a valid item if needed.
    if (selectedItem.isHidden) {
        [popUp setIvar:@"CalledFromGPGMail" value:[NSNumber numberWithBool:YES]];
        [popUp selectItemAtIndex:[menu indexOfItem:selectedItem] + 1];
        [self changeFromHeader:popUp];
    }
    else if ([popUp selectedItem] != selectedItem) {
        if ((parentItem = [selectedItem getIvar:@"parentItem"])) {
            selectedItem = parentItem;
        }
        [popUp setIvar:@"CalledFromGPGMail" value:[NSNumber numberWithBool:YES]];
        [popUp selectItem:selectedItem];
        [self changeFromHeader:popUp];
    }
}

- (void)MAChangeFromHeader:(NSPopUpButton *)sender {
    BOOL calledFromGPGMail = [[sender getIvar:@"CalledFromGPGMail"] boolValue];
    [sender setIvar:@"CalledFromGPGMail" value:[NSNumber numberWithBool:NO]];
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
    
    // Reset the sign and encrypt control if the sender
    // is by the user.
    if(!calledFromGPGMail) {
        GMSecurityControl *signControl = [self valueForKey:@"_signButton"];
        GMSecurityControl *encryptControl = [self valueForKey:@"_encryptButton"];
        
        // Reset the controls if the security method changes.
        signControl.forcedImageName = nil;
        encryptControl.forcedImageName = nil;
    }
    
    [self MAChangeFromHeader:button/*sender*/];
    [button release];
}

- (void)securityMethodDidChange:(NSNotification *)notification {
    GMSecurityControl *signControl = [self valueForKey:@"_signButton"];
    GMSecurityControl *encryptControl = [self valueForKey:@"_encryptButton"];
    
    // Reset the controls if the security method changes.
    signControl.forcedImageName = nil;
    encryptControl.forcedImageName = nil;
}

- (void)keyringUpdated:(NSNotification *)notification {
    GPGMAIL_SECURITY_METHOD securityMethod = ((ComposeBackEnd_GPGMail *)[(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd]).guessedSecurityMethod;
    if(((ComposeBackEnd_GPGMail *)[(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd]).securityMethod)
        securityMethod = ((ComposeBackEnd_GPGMail *)[(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd]).securityMethod;
    if(securityMethod == GPGMAIL_SECURITY_METHOD_OPENPGP)
        [self performSelectorOnMainThread:@selector(_fromHeaderDisplaySecretKeys:) withObject:(id)kCFBooleanTrue waitUntilDone:NO];
}

- (id)MAInit {
	self = [self MAInit];
    // This lock is used to prevent a SecurityMethodDidChange notification to
    // mess with an ongoing _updateSecurityStateInBackgroundForRecipients:recipients:
    // call.
    NSLock *updateSecurityStateLock = [[NSLock alloc] init];
    [self setIvar:@"SecurityStateLock" value:updateSecurityStateLock];
    [updateSecurityStateLock release];
	[(MailNotificationCenter *)[NSClassFromString(@"MailNotificationCenter") defaultCenter] addObserver:self selector:@selector(securityMethodDidChange:) name:@"SecurityMethodDidChangeNotification" object:nil];
	[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyringUpdated:) name:GPGMailKeyringUpdatedNotification object:nil];
	return self;
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


