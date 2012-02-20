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
#import <MailDocumentEditor.h>
#import "HeadersEditor+GPGMail.h"
#import "GPGMailBundle.h"
#import "NSString+GPGMail.h"
#import "NSObject+LPDynamicIvars.h"

@interface HeadersEditor_GPGMail (NoImplementation)
- (void)changeFromHeader:(NSPopUpButton *)sender;
@end

@implementation HeadersEditor_GPGMail

- (void)MASecurityControlChanged:(id)securityControl {
    if([[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToSend"])
        [[(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd] setIvar:@"shouldUpdateHasChanges" value:[NSNumber numberWithBool:YES]];
    [self MASecurityControlChanged:securityControl];
}

- (void)MA_updateFromAndSignatureControls:(id)arg1 {
	[self MA_updateFromAndSignatureControls:arg1];
	if([[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToSend"]) {
		[self fromHeaderDisplaySecretKeys:YES];
	}
}

- (void)fromHeaderDisplaySecretKeys:(BOOL)display {
	NSPopUpButton *popUp = [[self valueForKey:@"_composeHeaderView"] valueForKey:@"_accountPopUp"];
	NSMenu *menu = [popUp menu];
	NSArray *menuItems = [menu itemArray];
	GPGMailBundle *bundle = [GPGMailBundle sharedInstance];
	NSDictionary *attributes = [[[menuItems objectAtIndex:0] attributedTitle] fontAttributesInRange:NSMakeRange(0, 1)];
	NSMenuItem *item, *parentItem, *selectedItem = [popUp selectedItem];
	
	if ((parentItem = [selectedItem getIvar:@"parentItem"])) {
		selectedItem = parentItem;
	}
	if (!selectedItem) {
		NSRunAlertPanel(@"ERORO", @"KACKE", nil, nil, nil);
	}
	
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
							[newItem setIvar:@"gpgKey" value:key]; // GPGKey...
							[newItem setIvar:@"parentItem" value:item]; // and set the parentItem.
							
							[menu insertItem:newItem atIndex:++index]; // Insert it in the "From:" menu.
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
		[popUp selectItemAtIndex:[menu indexOfItem:selectedItem] + 1];
		[self changeFromHeader:popUp];
	} else if ([popUp selectedItem] != selectedItem) {
		[popUp selectItem:selectedItem];
		[self changeFromHeader:popUp];
	}	
}

- (void)MAChangeFromHeader:(NSPopUpButton *)sender {
	// Create a new NSPopUpButton with only one item and the correct title.
	NSPopUpButton *button = [[NSPopUpButton alloc] init];
	NSMenuItem *item = [sender selectedItem];
	NSMenuItem *parentItem = [item getIvar:@"parentItem"];
	[button addItemWithTitle:(parentItem ? parentItem : item).title];
	
	// Set the selected key in the back-end.
	[[(MailDocumentEditor *)[self valueForKey:@"_documentEditor"] backEnd] setIvar:@"gpgKeyForSigning" value:[item getIvar:@"gpgKey"]];
	
	
	[self MAChangeFromHeader:button];
}

- (void)securityMethodDidChange:(NSNotification *)notification {
	NSInteger securityMethod = [[[notification userInfo] objectForKey:@"SecurityMethod"] integerValue];
	[self fromHeaderDisplaySecretKeys:securityMethod == 1];
}

- (void)keyringUpdated:(NSNotification *)notification {
	if([[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToSend"]) {
		[self performSelectorOnMainThread:@selector(fromHeaderDisplaySecretKeys:) withObject:(id)kCFBooleanTrue waitUntilDone:NO];
	}
}

- (id)MAInit {
	[self MAInit];
	[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(securityMethodDidChange:) name:@"SecurityMethodDidChangeNotification" object:nil];
	[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyringUpdated:) name:GPGMailKeyringUpdatedNotification object:nil];
	return self;
}

- (void)MADealloc {
	[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] removeObserver:self];
	[self MADealloc];
}


@end


