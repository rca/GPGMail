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
	NSPopUpButton *popUp = [[self valueForKey:@"_composeHeaderView"] valueForKey:@"_accountPopUp"];
	NSMenu *menu = [popUp menu];
	NSArray *menuItems = [menu itemArray];
	GPGMailBundle *bundle = [GPGMailBundle sharedInstance];
	NSMenuItem *itemToSelect = nil;
	
	menu.autoenablesItems = NO;
	
	NSDictionary *attributes = [[[menuItems objectAtIndex:0] attributedTitle] fontAttributesInRange:NSMakeRange(0, 1)];
	
	for (NSMenuItem *item in menuItems) {
		if ([item getIvar:@"parentItem"]) {
			[menu removeItem:item];
		} else {
			NSSet *keys = [bundle signingKeyListForAddress:item.title];
			switch ([keys count]) {
				case 0:
					[item removeIvar:@"gpgKey"];
					break;
				case 1:
					[item setIvar:@"gpgKey" value:[keys anyObject]];
					break;
				default: {
					NSInteger index = [menu indexOfItem:item];
					
					BOOL firstSubitem = YES;
					for (GPGKey *key in keys) {
						
						NSString *title = [NSString stringWithFormat:@"– %@ (%@)", key.name, key.shortKeyID];
						NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];

						NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
						[newItem setAttributedTitle:attributedTitle];
						[newItem setIvar:@"gpgKey" value:key];
						[newItem setIvar:@"parentItem" value:item];
						
						
						[menu insertItem:newItem atIndex:++index];
						
						if (firstSubitem && item.state) {
							itemToSelect = newItem;
						}
						firstSubitem = NO;
					}
					item.enabled = NO;
					break; }
			}
		}
	}
	if (itemToSelect) {
		[popUp selectItem:itemToSelect];
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


@end


