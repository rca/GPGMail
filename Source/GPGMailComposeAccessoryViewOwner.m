/* GPGMailComposeAccessoryViewOwner.m created by dave on Thu 29-Jun-2000 */

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

#import "GPGMailComposeAccessoryViewOwner.h"
#import "GPGMailBundle.h"
#import "GPGKeyDownload.h"
#import "Message+GPGMail.h"
#import "MessageBody+GPGMail.h"
#import "MessageEditor+GPGMail.h"
#import "ComposeBackEnd+GPGMail.h"
#import "GPGMEAdditions.h"
#import "NSString+GPGMail.h"
#import "GPGMailPatching.h"
#import "MailDocumentEditor.h"
#import "GPG.subproj/GPGPassphraseController.h"
#import "GPG.subproj/GPGProgressIndicatorController.h"
#import "SegmentedToolbarItem.h"

#import <OutgoingMessage.h>
#import <MutableMessageHeaders.h>
#import <OptionalView.h>
#import <ColorBackgroundView.h>
#import <AddressBook/AddressBook.h>
#import <Libmacgpg/Libmacgpg.h>

#import "GPGDefaults.h"

// Encoded/decoded Body: perhaps we should use notif MessageBodyWasEncodedNotification
// On messageWillBeDelivered:, let's be observer of MessageBodyWasEncodedNotification and call -[MessageBody setEncodedBody:] when
// receiving notification, instead of modifying decodedBody? No, it wouldn't work: we couldn't stop message to be delivered
// if user cannot provide a password, for example.

// IMPORTANT: we cannot use key userIDs without retaining them, due to NSProxy:
// we need to retain every distant object, we cannot rely on this object's distant retain count,
// that's why we use a cache for userIDs.

@interface GPGMailComposeAccessoryViewOwner (Private)
- (void)doSetEncryptsMessage:(BOOL)flag;
- (void)doSetSignsMessage:(BOOL)flag;
- (void)refreshPublicKeysMenu:(NSMenu *)aSubmenu fromIndex:(int)index andFillIn:(BOOL)flag;
- (void)refreshPersonalKeysMenuAccordingToSelf:(BOOL)flag;
- (void)changeFromHeader:(id)sender;
- (void)senderAccountDidChange;
- (void)findMatchingPublicKeys;
// - (void) findMatchingPublicKeysIfNecessary;

- (BOOL)hasValidSigningKeys;
- (void)reloadPersonalKeys;
- (void)refreshPublicKeysMenu;
- (void)refreshPublicKeysPopDownButton:(NSNotification *)notification;
- (MailDocumentEditor *)messageEditor;
- (void)toggleEncryptionForNewMessage;
- (void)searchKnownPersonsOptions;
- (void)setUsesOnlyOpenPGPStyle:(BOOL)flag;
- (NSArray *)allPublicKeys;
- (NSString *)senderEmail;
@end

@interface NSView (InFactTilingView)
- (void)setTitle:fp12 forView:fp16;
@end


@implementation GPGMailComposeAccessoryViewOwner

+ (void)initialize {
	[super initialize];

	if (class_getSuperclass([self class]) != NSClassFromString(@"MVComposeAccessoryViewOwner")) {
		Class parentClass = NSClassFromString(@"MVComposeAccessoryViewOwner");
		if (parentClass) {
			// use class_addMethod and method_setImplementation instead
			class_setSuperclass([self class], parentClass);
		}
	}
}

+ (NSString *)composeAccessoryViewNibName {
	return @"GPGMailCompose";             // Invoked by -[MVComposeAccessoryViewOwner setupUIForMessage:]
}

- (BOOL)displaysButtonsInComposeWindow {
	return [[GPGMailBundle sharedInstance] gpgMailWorks] && displaysButtonsInComposeWindow;
}

- (void)setDisplaysButtonsInComposeWindow:(BOOL)value {
	if (displaysButtonsInComposeWindow != value) {
		displaysButtonsInComposeWindow = value;
	}
}

- (void)updateMenusAccordingToSelf:(BOOL)accordingToSelf {
	// Invoked when Compose window becomes/resigns main
	GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];

	if (accordingToSelf) {
		[[mailBundle signsNewMessageMenuItem] setState:(signsMessage ? NSOnState:NSOffState)];
		[[mailBundle encryptsNewMessageMenuItem] setState:(encryptsMessage ? NSOnState:NSOffState)];
		[[mailBundle automaticPublicKeysMenuItem] setState:(!useCustomPublicKeys ? NSOnState:NSOffState)];
		[self refreshPublicKeysMenu:[[mailBundle choosePublicKeysMenuItem] menu] fromIndex:GPGENCRYPTION_MENU_ITEMS_COUNT andFillIn:(encryptsMessage && !usesSymetricEncryption)];
		[self refreshPersonalKeysMenuAccordingToSelf:YES];
		[[mailBundle symetricEncryptionMenuItem] setState:usesSymetricEncryption];
	} else {
		[[mailBundle signsNewMessageMenuItem] setState:([mailBundle alwaysSignMessages] ? NSOnState:NSOffState)];
		[[mailBundle encryptsNewMessageMenuItem] setState:([mailBundle alwaysEncryptMessages] ? NSOnState:NSOffState)];
		[[mailBundle automaticPublicKeysMenuItem] setState:NSOnState];
		[self refreshPublicKeysMenu:[[mailBundle choosePublicKeysMenuItem] menu] fromIndex:GPGENCRYPTION_MENU_ITEMS_COUNT andFillIn:NO];
		[self refreshPersonalKeysMenuAccordingToSelf:NO];
		[[mailBundle symetricEncryptionMenuItem] setState:NSOffState];
	}
}

- (void)dealloc {
	[publicKeysOutlineView setDataSource:nil];
	[publicKeysOutlineView setDelegate:nil];
	[publicKeysPanel setDelegate:nil];

//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidEndEditingNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSPopUpButtonWillPopUpNotification object:publicKeysPopDownButton];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeMainNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSToolbarWillAddItemNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GPGKeyListWasInvalidatedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GPGPreferencesDidChangeNotification object:nil];
	[publicKeysPanel release];
	[selectedPublicKeys release];
	[selectedPersonalKey release];
	[selectedPersonalPublicKey release];
	[missingPublicKeyEmails release];
#warning Check memory leaks
	[emptyView release];
	[fullView release];
	[allTableColumns release];
	[allPublicKeys release];
	[ascendingOrderImage release];
	[descendingOrderImage release];
	[pgpOptionsPerEmail release];
	[replyOptions release];
	[[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];

	// Runtime super call - CORRECT !
	struct objc_super s = { self, [self superclass] };
	objc_msgSendSuper(&s, @selector(dealloc));
}

- (GPGKey *)selectedPersonalPublicKey {
	if (!selectedPersonalPublicKey) {
		// Do not invoke -[GPGKey publicKey], because it will perform a gpg op
		// Get key from cached public keys
		NSEnumerator *keyEnum = [[self allPublicKeys] objectEnumerator];
		NSString *aFingerprint = [selectedPersonalKey fingerprint];

		while (selectedPersonalPublicKey = [keyEnum nextObject]) {
			if ([[selectedPersonalPublicKey fingerprint] isEqualToString:aFingerprint]) {
				[selectedPersonalPublicKey retain];
				break;
			}
		}
	}

	return selectedPersonalPublicKey;
}

- (void)windowDidResignMain:(NSNotification *)notification {
	// Note that we cannot compare windows, because we registered ourself
	// as observer of all windows, and when the compose panel is closed,
	// the composeWindow is released, but not us, and we might
	// receive other notifications after our composeAccessoryView
	// has been freed! That's why we retain our composeAccessoryView

	if ([[self composeAccessoryView] isDescendantOf:[[notification object] contentView]]) {
		[self updateMenusAccordingToSelf:NO];
	}
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
	if ([[self composeAccessoryView] isDescendantOf:[[notification object] contentView]]) {
		[self updateMenusAccordingToSelf:YES];
	}
}

- (void)windowWillClose:(NSNotification *)notification {
	windowWillClose = YES;
	[NSRunLoop cancelPreviousPerformRequestsWithTarget:self selector:@selector(evaluateRules) object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:[notification name] object:[notification object]];
}

static NSComparisonResult compareKeysAccordingToSelection(id key, id otherKey, void *context){
	BOOL ascendingOrder = [[(NSDictionary *) context objectForKey:@"ascending"] boolValue];
	NSArray *selectedKeys = [(NSDictionary *) context objectForKey:@"selectedPublicKeys"];
	BOOL leftValue = [selectedKeys containsObject:key];
	BOOL rightValue = [selectedKeys containsObject:otherKey];
	NSComparisonResult result = (leftValue == rightValue ? NSOrderedSame : (leftValue ? NSOrderedDescending : NSOrderedAscending));

	if (!ascendingOrder && result != NSOrderedSame) {
		result = (result == NSOrderedAscending ? NSOrderedDescending : NSOrderedAscending);
	}

	return result;
}

static NSComparisonResult compareKeysWithSelector(id key, id otherKey, void *context){
	BOOL ascendingOrder = [[(NSDictionary *) context objectForKey:@"ascending"] boolValue];
	SEL selector = NSSelectorFromString([(NSDictionary *) context objectForKey:@"selector"]);
	id leftValue = [key performSelector:selector];
	id rightValue = [otherKey performSelector:selector];
	NSComparisonResult result;

	if ([leftValue isKindOfClass:[NSString class]]) {
		result = [(NSString *) leftValue caseInsensitiveCompare:rightValue];
	} else {
		result = [(NSNumber *) leftValue compare:rightValue];                          // Cast is not correct; we put it just to avoid a gcc warning

	}
	if (!ascendingOrder && result != NSOrderedSame) {
		result = (result == NSOrderedAscending ? NSOrderedDescending : NSOrderedAscending);
	}

	return result;
}

- (void)invalidateAllPublicKeys {
	[allPublicKeys release];
	allPublicKeys = nil;
	publicKeysAreSorted = NO;
	cachedPublicKeyCount = -1;
}

- (NSArray *)allPublicKeys {
	// Loading and sorting could be done asynchronously,
	// in another thread => not slow.
	// We could also filter out unusable keys (disabled,
	// expired, cannot encrypt, be it userID or subkey);
	// this should be optional.
	// We could also filter out keys without a full trust level (opt.).
	// Instead of removing them, we could mark them with an icon
	// in the menus.
	if (allPublicKeys == nil) {
		allPublicKeys = [[[GPGMailBundle sharedInstance] publicKeys] retain];
	}

	return allPublicKeys;
}

- (int)cachedPublicKeyCount {
	if (cachedPublicKeyCount < 0) {
		cachedPublicKeyCount = [[self allPublicKeys] count];
	}

	return cachedPublicKeyCount;
}

- (NSArray *)sortedPublicKeys {
	if (!publicKeysAreSorted) {
		NSArray *sortedPublicKeys;

		if ([[sortingTableColumn identifier] isEqualToString:@"isSelected"]) {
			sortedPublicKeys = [[[self allPublicKeys] sortedArrayUsingFunction:compareKeysAccordingToSelection context:[NSDictionary dictionaryWithObjectsAndKeys:selectedPublicKeys, @"selectedPublicKeys", [NSNumber numberWithBool:ascendingOrder], @"ascending", nil]] retain];
		} else if ([[sortingTableColumn identifier] isEqualToString:@"validityDescription"]) {
			sortedPublicKeys = [[[self allPublicKeys] sortedArrayUsingFunction:compareKeysWithSelector context:[NSDictionary dictionaryWithObjectsAndKeys:@"validityNumber", @"selector", [NSNumber numberWithBool:ascendingOrder], @"ascending", nil]] retain];
		} else if ([[sortingTableColumn identifier] isEqualToString:@"additionalInfo"]) {
			sortedPublicKeys = [[[self allPublicKeys] sortedArrayUsingFunction:compareKeysWithSelector context:[NSDictionary dictionaryWithObjectsAndKeys:@"additionalInfoValue", @"selector", [NSNumber numberWithBool:ascendingOrder], @"ascending", nil]] retain];
		} else {
			sortedPublicKeys = [[[self allPublicKeys] sortedArrayUsingFunction:compareKeysWithSelector context:[NSDictionary dictionaryWithObjectsAndKeys:[sortingTableColumn identifier], @"selector", [NSNumber numberWithBool:ascendingOrder], @"ascending", nil]] retain];
		}

		[allPublicKeys release];
		allPublicKeys = sortedPublicKeys;
		publicKeysAreSorted = YES;
	}

	return allPublicKeys;
}

- (void)updateWarningImage {
	DebugLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
#if 0
#warning FIXME: Should not modify any encrypt/sign/MIME setting, but only update UI
	GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];

	if (encryptsMessage || [mailBundle encryptMessagesWhenPossible]) {
		BOOL hasAtLeastOneInvalidKey = NO;

		if (!usesSymetricEncryption) {
			NSEnumerator *anEnum = [selectedPublicKeys objectEnumerator];
			GPGKey *aKey;

			while (aKey = [anEnum nextObject]) {
				if (![mailBundle canKeyBeUsedForEncryption:aKey]) {
					hasAtLeastOneInvalidKey = YES;
					break;
				}
			}
		}

		if (hasAtLeastOneInvalidKey || (!usesSymetricEncryption && !useCustomPublicKeys && [missingPublicKeyEmails count] != 0)) {
			if ([mailBundle encryptMessagesWhenPossible]) {
				if (explicitlySetEncryption) {
					if (encryptsMessage) {
						needsWarning = YES;
					}
				} else if (encryptsMessage) {
					if ([mailBundle alwaysEncryptMessages]) {
						needsWarning = YES;
					} else {
						// Turn off encryption
						[self toggleEncryptionForNewMessage];
					}
				}
			} else {
				needsWarning = YES;
			}
		} else {
			// Turn on encryption
			if (!encryptsMessage && !explicitlySetEncryption && [[self recipients] count] > 0) {
#warning FIXME: Checking [[self recipients] count] > 0 is not enough, because if we add then remove recipients, encryption is not set back to off
				if (!somePeopleDontWantEncryption) {
					[self toggleEncryptionForNewMessage];
				}
			}
		}
	}
#endif /* if 0 */

	if (needsWarning) {
		[[[publicKeysPopDownButton itemArray] objectAtIndex:0] setImage:[NSImage imageNamed:@"gpgSmallAlert16"]];
	} else {
		[[[publicKeysPopDownButton itemArray] objectAtIndex:0] setImage:nil];
	}
}

- (void)refreshPublicKeysMenu {
#if 0
	[self findMatchingPublicKeys];
#endif
	[self refreshPublicKeysMenu:[[[GPGMailBundle sharedInstance] choosePublicKeysMenuItem] menu] fromIndex:GPGENCRYPTION_MENU_ITEMS_COUNT andFillIn:encryptsMessage && !usesSymetricEncryption];
}

- (NSArray *)recipients {
	return [[[self messageEditor] backEnd] gpgRecipients];
}

// TODO: Fix me for libmacgpg
//- (void)findMatchingPublicKeys {
//#warning FIXME: It seems that group name addresses are enclosed in "", i.e. if group name is dummy@x.y, then recipient will be "dummy@x.y", litterally
//	// Find keys according to recipients
//	// If it misses a key, it will prepend the email with a question mark
//	// in the menus, and item will be disabled. Not done in that method.
//	// Updates internal lists AND imageView
//	GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];
//	NSArray *recipients = [self recipients];                     // Normalized
//
//	[selectedPublicKeys removeAllObjects];
//	[missingPublicKeyEmails removeAllObjects];
//
//	if ([recipients count] > 0) {
//		NSString *aRecipient;
//		NSEnumerator *anEnum;
//		GPGKey *aKey;
//		BOOL filterKeys = [mailBundle filtersOutUnusableKeys];
//		NSMutableArray *fetchedKeys = [[NSMutableArray alloc] init];
//		NSArray *keyGroups = [mailBundle keyGroups];
//
//		anEnum = [[mailBundle keysForSearchPatterns:recipients attributeName:@"normalizedEmail" secretKeys:NO] objectEnumerator];
//		while (aKey = [anEnum nextObject])
//			if (!filterKeys || [mailBundle canKeyBeUsedForEncryption:aKey]) {
//				[fetchedKeys addObject:aKey];
//			}
//
//		// Now find whether we miss key; matching needs to be done manually
//		anEnum = [recipients objectEnumerator];
//		while (aRecipient = [anEnum nextObject]) {
//			NSEnumerator *keyEnum = [fetchedKeys objectEnumerator];
//			BOOL found = NO;
//			NSString *normalizedRecipient = aRecipient;
//
//			// If there a multiple keys with the same
//			// emails, we want to list them all!
//			while (/*!found &&*/ (aKey = [keyEnum nextObject])) {
//				NSEnumerator *userIDEnum = [[aKey userIDs] objectEnumerator];
//				GPGUserID *aUserID;
//
//				while (aUserID = [userIDEnum nextObject]) {
//					// FIXME: If multiple keys with matching email address, take the first one which is valid
//					if ([[aUserID normalizedEmail] isEqualToString:normalizedRecipient] && (!filterKeys || [mailBundle canUserIDBeUsed:aUserID])) {
//						if (![selectedPublicKeys containsObject:aKey]) {
//							[selectedPublicKeys addObject:aKey];
//						}
//						found = YES;
//						break;
//					}
//				}
//			}
//
//			// WARNING Support for groups: we use gpg groups, but as we're in Mail, we suppose
//			// the group name is a valid email address, expanded to the same persons as with the keys!
//
//			// If there is a group with the same email address as a key, we don't search for that group.
//			// That should be very unlikely.
//			if (!found) {
//				GPGKeyGroup *aKeyGroup;
//				NSEnumerator *groupEnum = [keyGroups objectEnumerator];
//
//				while (!found && (aKeyGroup = [groupEnum nextObject])) {
//					// We compare case-insensitively now
//					if ([[[aKeyGroup name] lowercaseString] isEqualToString:aRecipient]) {
//						keyEnum = [[aKeyGroup keys] objectEnumerator];
//
//						while ((aKey = [keyEnum nextObject])) {
//							if (!filterKeys || [mailBundle canKeyBeUsedForEncryption:aKey]) {
//								if (![selectedPublicKeys containsObject:aKey]) {
//									[selectedPublicKeys addObject:aKey];
//								}
//							}
//						}
//						found = YES;                                                                         // Even when no key patched criteria
//						// TODO: It would be nice to display groups in some way in the UI (menus)
//					}
//				}
//
//				if (!found) {
//					[missingPublicKeyEmails addObject:aRecipient];
//				}
//			}
//		}
//		[fetchedKeys release];
//
//		if ([mailBundle encryptsToSelf] && selectedPersonalKey) {
//			GPGKey *aKey = [self selectedPersonalPublicKey];
//
//			if (aKey && (!filterKeys || [mailBundle canKeyBeUsedForEncryption:aKey])) {
//				// We have to test that, because it might happen that there's no
//				// public counterpart to the secret key.
//				if (![selectedPublicKeys containsObject:aKey]) {
//					[selectedPublicKeys addObject:aKey];
//				}
//			} else {
//				NSString *aRecipient;
//
//				// WARNING A disabled key can sign but not encrypt
//				// We always need to verify that even user's key can be used
//				if ([mailBundle choosesPersonalKeyAccordingToAccount]) {
//					MailDocumentEditor *editor = [self messageEditor];
//
//					aRecipient = [[[editor gpgFromPopup] selectedItem] title];
//				} else {
//					aRecipient = [selectedPersonalKey email];
//				}
//
//				[missingPublicKeyEmails addObject:[aRecipient gpgNormalizedEmail]];
//			}
//		}
//	}
//	if ([missingPublicKeyEmails count] > 0) {
//		[[NSNotificationCenter defaultCenter] postNotificationName:GPGMissingKeysNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[missingPublicKeyEmails allObjects] forKey:@"emails"]];
//	}
//#if 0
//	[self updateWarningImage];             // Warning only when encrypting and missing keys
//#endif
//}
/*
 * - (void) findMatchingPublicKeysIfNecessary
 * {
 *  if(encryptsMessage && !usesSymetricEncryption && !useCustomPublicKeys)
 *      [self findMatchingPublicKeys];
 * }
 */
- (void)reloadPersonalKeys {
	GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];
	NSEnumerator *keyEnum = [[mailBundle personalKeys] objectEnumerator];
	GPGKey *aKey;
	GPGKey *defaultKey = [[[personalKeysPopUpButton selectedItem] representedObject] retain];
	BOOL displaysAllUserIDs = [mailBundle displaysAllUserIDs];
	BOOL hasAtLeastOneKey = NO;

	if (!defaultKey) {
		defaultKey = [[mailBundle defaultKey] retain];
	}
	[personalKeysPopUpButton removeAllItems];
	while (aKey = [keyEnum nextObject]) {
		NSMenuItem *anItem;

		[personalKeysPopUpButton addItemWithTitle:[mailBundle menuItemTitleForKey:aKey]];
		hasAtLeastOneKey = YES;
		anItem = [personalKeysPopUpButton lastItem];
		[anItem setRepresentedObject:aKey];
		if (![mailBundle canKeyBeUsedForSigning:aKey]) {
			[anItem setEnabled:NO];
		}

		if (defaultKey && [aKey isEqual:defaultKey]) {
			[personalKeysPopUpButton selectItem:anItem];
		}

		if (displaysAllUserIDs) {
			NSEnumerator *userIDEnum = [[mailBundle secondaryUserIDsForKey:aKey] objectEnumerator];
			GPGUserID *aUserID;

			while (aUserID = [userIDEnum nextObject]) {
				[personalKeysPopUpButton addItemWithTitle:[mailBundle menuItemTitleForUserID:aUserID indent:1]];
				anItem = [personalKeysPopUpButton lastItem];
				[anItem setEnabled:NO];
			}
		}
	}
	[self refreshPersonalKeysMenuAccordingToSelf:YES];
	[defaultKey release];
	[personalKeysPopUpButton setEnabled:hasAtLeastOneKey];
}

- (void)fillInPublicKeysMenu:(NSMenu *)menu {
	if ([selectedPublicKeys count] > 0) {
		NSEnumerator *anEnum = [selectedPublicKeys objectEnumerator];
		GPGKey *aKey;
		GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];
		BOOL displaysAllUserIDs = [mailBundle displaysAllUserIDs];

		while (aKey = [anEnum nextObject]) {
			id anItem = [menu addItemWithTitle:[mailBundle menuItemTitleForKey:aKey] action:@selector(gpgChoosePublicKey:) keyEquivalent:@""];

			[anItem setTarget:[GPGMailBundle sharedInstance]];
			[anItem setImage:nil];
			if (![mailBundle canKeyBeUsedForEncryption:aKey]) {
				[anItem setEnabled:NO];
				[anItem setAction:NULL];
				[anItem setTarget:nil];
			}

			if (displaysAllUserIDs) {
				NSEnumerator *userIDEnum = [[mailBundle secondaryUserIDsForKey:aKey] objectEnumerator];
				GPGUserID *aUserID;

				while (aUserID = [userIDEnum nextObject]) {
					anItem = [menu addItemWithTitle:[mailBundle menuItemTitleForUserID:aUserID indent:1] action:NULL keyEquivalent:@""];
					[anItem setEnabled:NO];
				}
			}
		}
	}
	if (!useCustomPublicKeys && [missingPublicKeyEmails count] > 0) {
		NSEnumerator *anEnum = [missingPublicKeyEmails objectEnumerator];
		NSString *anEmail;

		while (anEmail = [anEnum nextObject]) {
			id anItem = [menu addItemWithTitle:[anEmail lowercaseString] action:NULL keyEquivalent:@""];

			[anItem setImage:[NSImage imageNamed:@"gpgQuestionMark"]];
			[anItem setEnabled:NO];
			[anItem setTarget:[GPGMailBundle sharedInstance]];                                     // Necessary, to control automaticValidation behavior
		}
	}
}

- (void)refreshPersonalKeysMenuAccordingToSelf:(BOOL)flag {
	// Selected personal key could also be sync'ed with
	// selected account. Optional.
	// Sign switch, as well as popup, should be disabled
	// when no (valid) signing key exists.
	GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];
	NSEnumerator *anEnum = [[[[mailBundle personalKeysMenuItem] submenu] itemArray] objectEnumerator];
	NSMenuItem *anItem;
	GPGKey *selectedKey = (flag ? selectedPersonalKey : [mailBundle defaultKey]);

	while (anItem = [anEnum nextObject]) {
		GPGKey *aKey = [anItem representedObject];

		[anItem setState:((selectedKey && [aKey isEqual:selectedKey]) ? NSOnState:NSOffState)];
		[anItem setEnabled:[mailBundle canKeyBeUsedForSigning:aKey]];
	}
}

- (void)refreshAutomaticChoiceInfo {
	DebugLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
	[[[[publicKeysPopDownButton menu] itemArray] objectAtIndex:3] setState:!useCustomPublicKeys];
	[[[GPGMailBundle sharedInstance] automaticPublicKeysMenuItem] setState:!useCustomPublicKeys];
}

- (void)refreshSymetricEncryption {
	[[[[publicKeysPopDownButton menu] itemArray] objectAtIndex:1] setState:usesSymetricEncryption];
	[[[[publicKeysPopDownButton menu] itemArray] objectAtIndex:3] setEnabled:!usesSymetricEncryption];
	[[[[publicKeysPopDownButton menu] itemArray] objectAtIndex:4] setEnabled:!usesSymetricEncryption];
	[[[[publicKeysPopDownButton menu] itemArray] objectAtIndex:5] setEnabled:!usesSymetricEncryption];
	[[[GPGMailBundle sharedInstance] symetricEncryptionMenuItem] setState:usesSymetricEncryption];
}

- (void)refreshPublicKeysMenu:(NSMenu *)aSubmenu fromIndex:(int)index andFillIn:(BOOL)flag {
#warning Duplicated code!
	DebugLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
	NSEnumerator *anEnum = [[NSArray arrayWithArray:[aSubmenu itemArray]] objectEnumerator];
	NSMenuItem *anItem;
	int i;

	for (i = 0; i < index; i++) {
		[anEnum nextObject];
	}
	while (anItem = [anEnum nextObject])
		[aSubmenu removeItem:anItem];

	if (flag) {
		if (!usesSymetricEncryption) {
			[self fillInPublicKeysMenu:aSubmenu];
		}
	} else {
		GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];
		GPGKey *defaultKey = [mailBundle defaultKey];

		if ([mailBundle encryptsToSelf] && defaultKey) {
			[aSubmenu addItemWithTitle:[mailBundle menuItemTitleForKey:defaultKey] action:NULL keyEquivalent:@""];
			if (![mailBundle canKeyBeUsedForEncryption:defaultKey]) {
				[[[aSubmenu itemArray] lastObject] setEnabled:NO];
			}

			if ([mailBundle displaysAllUserIDs]) {
				NSEnumerator *userIDEnum = [[mailBundle secondaryUserIDsForKey:defaultKey] objectEnumerator];
				GPGUserID *aUserID;

				while (aUserID = [userIDEnum nextObject]) {
					anItem = [aSubmenu addItemWithTitle:[mailBundle menuItemTitleForUserID:aUserID indent:1] action:NULL keyEquivalent:@""];
					[anItem setEnabled:NO];
				}
			}
		}
	}
}

- (void)refreshPublicKeysPopDownButton:(NSNotification *)notification {
	[self refreshPublicKeysMenu:[publicKeysPopDownButton menu] fromIndex:/*GPGENCRYPTION_MENU_ITEMS_COUNT*/ 7 andFillIn:YES];
	[self refreshAutomaticChoiceInfo];
}

- (void)setupTableColumns {
	NSArray *visibleTableColumnTags, *tableColumnWidths;
	NSEnumerator *anEnum;
	int i;
	int tableColumnCount;
	NSMutableArray *columnIdentifiers;
	NSTableColumn *aColumn;
	NSNumber *aNumber;

	ascendingOrderImage = [[NSImage imageNamed:@"NSAscendingSortIndicator"] retain];
	descendingOrderImage = [[NSImage imageNamed:@"NSDescendingSortIndicator"] retain];
	allTableColumns = [[NSArray alloc] initWithArray:[publicKeysOutlineView tableColumns]];
	tableColumnCount = [allTableColumns count];
	columnIdentifiers = [NSMutableArray arrayWithCapacity:tableColumnCount];

	anEnum = [allTableColumns objectEnumerator];
	while (aColumn = [anEnum nextObject])
		[columnIdentifiers addObject:[aColumn identifier]];

	sortingTableColumn = [[allTableColumns objectAtIndex:[[GPGDefaults standardDefaults] integerForKey:@"GPGSortingTableColumnTag"]] retain];
	ascendingOrder = [[GPGDefaults standardDefaults] boolForKey:@"GPGAscendingSorting"];

	// Let's restore column widths
	tableColumnWidths = [[GPGDefaults standardDefaults] arrayForKey:@"GPGTableColumnWidths"];
	anEnum = [tableColumnWidths objectEnumerator];
	if ([tableColumnWidths count] != tableColumnCount) {
		// Seems we lost the widths! Let's use the default ones
		[[GPGDefaults standardDefaults] removeObjectForKey:@"GPGTableColumnWidths"];
	} else {
		i = 0;
		// Table column order is always the same
		while (aNumber = [anEnum nextObject])
			[[allTableColumns objectAtIndex:i++] setWidth:[aNumber floatValue]];
	}

	// Let's reorder visible columns
	visibleTableColumnTags = [[GPGDefaults standardDefaults] arrayForKey:@"GPGVisibleTableColumnTags"];
	if (GPGMailLoggingLevel)
		NSLog(@"[DEBUG] : visible columns %i", (int)[visibleTableColumnTags count]);
	if ([visibleTableColumnTags count] <= 1) {
		NSMutableArray *visibleTableColumnTags2 = [NSMutableArray arrayWithArray:visibleTableColumnTags];
		[visibleTableColumnTags2 addObject:[NSString stringWithFormat:@"%u", 0]];
		[visibleTableColumnTags2 addObject:[NSString stringWithFormat:@"%u", 1]];
		[visibleTableColumnTags2 addObject:[NSString stringWithFormat:@"%u", 2]];
		visibleTableColumnTags = visibleTableColumnTags2;
	}
	anEnum = [visibleTableColumnTags objectEnumerator];
	i = 0;
	while (aNumber = [anEnum nextObject]) {
		NSTableColumn *aColumn = [allTableColumns objectAtIndex:[aNumber intValue]];
		int currentColumn = [[publicKeysOutlineView tableColumns] indexOfObject:aColumn];

		if (currentColumn != i) {
			[publicKeysOutlineView moveColumn:currentColumn toColumn:i];
		}
		if (aColumn == sortingTableColumn) {
			[publicKeysOutlineView setIndicatorImage:(ascendingOrder ? ascendingOrderImage:descendingOrderImage) inTableColumn:aColumn];
			[publicKeysOutlineView setHighlightedTableColumn:aColumn];
		} else {
			[publicKeysOutlineView setIndicatorImage:nil inTableColumn:aColumn];
		}
		[[popDownButton itemAtIndex:[popDownButton indexOfItemWithTag:[aNumber intValue]]] setState:NSOnState];
		i++;
	}

	// And remove the invisible ones
	for (i = 1; i < tableColumnCount; i++) {
		NSString *aString = [NSString stringWithFormat:@"%d", i];

		if (![visibleTableColumnTags containsObject:aString]) {
			aColumn = [allTableColumns objectAtIndex:i];
			[publicKeysOutlineView removeTableColumn:aColumn];
		}
	}

	publicKeysOutlineViewHasBeenInitialized = YES;
}

- (id)init {
	if (self = [super init]) {
		cachedPublicKeyCount = -1;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyListWasInvalidated:) name:GPGKeyListWasInvalidatedNotification object:[GPGMailBundle sharedInstance]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesDidChange:) name:GPGPreferencesDidChangeNotification object:[GPGMailBundle sharedInstance]];
		verifyRulesConflicts = YES;
		pgpOptionsPerEmail = [[NSMutableDictionary alloc] init];
		displaysButtonsInComposeWindow = [[GPGMailBundle sharedInstance] displaysButtonsInComposeWindow];
	}
	
	return self;
}

- (void)finishUISetupWithStates:(NSArray *)savedStates {
	// Called only once, after composeAccessoryView has been placed onto Compose window
	NSView *view = [self composeAccessoryView];
	NSWindow *window = [view window];
	MailDocumentEditor *messageEditor;

	NSAssert(window != nil, @"### GPGMail: expects view to be in final window!");
	// Let's force GPGMailComposeAccessoryViewOwner be the last
	// accessory view owner of the list, to be sure that nobody else
	// will modify the message after us.
	messageEditor = [self messageEditor];
	if ([[messageEditor gpgAccessoryViewOwners] lastObject] != self) {
		NSMutableArray *owners = [NSMutableArray arrayWithArray:[messageEditor gpgAccessoryViewOwners]];

		[self retain];
		[owners removeObject:self];
		[owners addObject:self];
		[self release];
		[messageEditor gpgSetAccessoryViewOwners:owners];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignMain:) name:NSWindowDidResignMainNotification object:window];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:window];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:window];
	// It is not possible to set an iconView at the left of our accessoryView
	// because the superview, a TilingView, forces alignement of its subviews.
	// We'd need to place our iconView over the TilingView, but in this case we should
	// take care of moving it when the textfields grow up!
	NSAssert([window toolbar] != nil, @"### GPGMail: expected window to have a toolbar");
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toolbarWillAddItem:) name:NSToolbarWillAddItemNotification object:[window toolbar]];

	if (![window isKeyWindow]) {
		[self updateMenusAccordingToSelf:NO];
	}

	// TODO: Save/restore more states, like keys
	if ([savedStates containsObject:@"signed"]) {
		explicitlySetSignature = YES;
		signsMessage = YES;
//        [self doSetSignsMessage:YES];
	} else if ([savedStates containsObject:@"!signed"]) {
		explicitlySetSignature = YES;
		signsMessage = NO;
	} else if ([savedStates containsObject:@"encrypted"]) {
		explicitlySetEncryption = YES;
		encryptsMessage = YES;
	} else if ([savedStates containsObject:@"!encrypted"]) {
		explicitlySetEncryption = YES;
		encryptsMessage = NO;
	} else if ([savedStates containsObject:@"mime"]) {
		explicitlySetOpenPGPStyle = YES;
		usesOnlyOpenPGPStyle = YES;
	} else if ([savedStates containsObject:@"!mime"]) {
		explicitlySetOpenPGPStyle = YES;
		usesOnlyOpenPGPStyle = NO;
	}
//        [self doSetSignsMessage:[[GPGMailBundle sharedInstance] alwaysSignMessages]];
#if 0
	if ([savedStates containsObject:@"encrypted"]) {
		[self doSetEncryptsMessage:NO];                          // FIXME: Will sign too, if defaults ask to sign when encrypting, thus bypassing previous "signed" setting
	} else {
		[self doSetEncryptsMessage:![[GPGMailBundle sharedInstance] alwaysEncryptMessages]];
	}
	[self toggleEncryptionForNewMessage];
#endif

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidEndEditing:) name:NSControlTextDidEndEditingNotification object:nil];
	[self senderAccountDidChange];

#if 0
	[self searchKnownPersonsOptions];
	[self refreshPublicKeysMenu];
#endif
	[self evaluateRules];
}

- (void)toolbarWillAddItem:(NSNotification *)notif {
	if ([notif object] == [[[self composeAccessoryView] window] toolbar]) {
		SegmentedToolbarItem *anItem = [[notif userInfo] objectForKey:@"item"];

		if ([[anItem itemIdentifier] isEqualToString:GPGEncryptMessageToolbarItemIdentifier] || [[anItem itemIdentifier] isEqualToString:GPGSignMessageToolbarItemIdentifier]) {
			[anItem setTarget:self forSegment:0];
			[self performSelector:@selector(updateToolbarAndMenuItems) withObject:nil afterDelay:0.0];                                     // If we don't delay call, then call -[NSToolbar items] will recursively send the toolbarWillAddItem: notification!
		}
	}
}

- (void)updateToolbarAndMenuItems {
#if 0
#warning FIXME: Should not modify any encrypt/sign/MIME setting???
	[self doSetEncryptsMessage:[[GPGMailBundle sharedInstance] alwaysEncryptMessages]];
	[self doSetSignsMessage:[[GPGMailBundle sharedInstance] alwaysSignMessages]];
#else
	[self doSetEncryptsMessage:encryptsMessage];
	[self doSetSignsMessage:signsMessage];
#endif
}

- (void)refreshAccessoryView:(NSNotification *)notif {
	// Sometimes, when To/CC fields are adapted to new height, our view is not refreshed (why?), that's
	// why we force refresh each time our superview changes its frame. Seems to work, though too many refreshes are done.
	[[self composeAccessoryView] setNeedsDisplay:YES];
}

#ifdef SNOW_LEOPARD_64
- (void)awakeFromNib {
	if (!setupUI) {
		if (GPGMailLoggingLevel) {
			NSLog(@"Not yet ready to setup UI");
		}
		return;
	}

	GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];

	verifyRulesConflicts = YES;
	selectedPublicKeys = [[NSMutableArray allocWithZone:[self zone]] init];
	missingPublicKeyEmails = [[NSMutableSet allocWithZone:[self zone]] init];
	selectedPersonalKey = [[mailBundle defaultKey] retain];
	[selectedPersonalPublicKey release];
	selectedPersonalPublicKey = nil;

	[self setupTableColumns];
	[[publicKeysPopDownButton menu] setAutoenablesItems:NO];

	struct objc_super s = { self, [self superclass] };
	// Call the super implementation to access the super class's accessoryView.
	[objc_msgSendSuper (&s, @selector(composeAccessoryView)) setFrame:[[optionalView primaryView] frame]];
	[[[optionalView primaryView] superview] replaceSubview:[optionalView primaryView] with:objc_msgSendSuper(&s, @selector(composeAccessoryView))];
	[optionalViewBackgroundView setBackgroundColor:[NSColor windowBackgroundColor]];
	[optionalViewTitleField setStringValue:NSLocalizedStringFromTableInBundle(@"PGP:", @"GPGMail", [NSBundle bundleForClass:[self class]], "Title of PGP accessory view")];
	[[optionalView optionSwitch] setState:[self displaysButtonsInComposeWindow] ? NSOnState:NSOffState];
	// After this point, the original accessoryView is replaced with the views of our
	// Nib file, hence every further call to composeAccessoryView will use our own implementation
	// of composeAccessoryView, which will return the one of the views from our NIB.

	[personalKeysPopUpButton setAutoenablesItems:NO];             // Needed!

	[self reloadPersonalKeys];
	[self refreshPersonalKeysMenuAccordingToSelf:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPublicKeysPopDownButton:) name:NSPopUpButtonWillPopUpNotification object:publicKeysPopDownButton];
	// We need to delay the following call, after our composeAccessoryView has been moved to the Compose window
	[self performSelector:@selector(finishUISetupWithStates:) withObject:currentStates afterDelay:0.0];
}
#endif /* ifdef SNOW_LEOPARD_64 */

- (void)setupUIForMessage:(Message *)message {
	// At that time, composeAccessoryView, which is going to be loaded, is not/cannot be in message view window
	GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];
	NSArray *states = [[[message headers] firstHeaderForKey:@"X-Gpgmail-State"] componentsSeparatedByString:@","];

	// FIXME: Leopard: at that time, headers lost their custom entries

	setupUI = YES;
	currentStates = states;

	// Runtime super call - CORRECT !
	struct objc_super s = { self, [self superclass] };
	objc_msgSendSuper(&s, @selector(setupUIForMessage:), message);

#ifndef SNOW_LEOPARD_64
	verifyRulesConflicts = YES;
	selectedPublicKeys = [[NSMutableArray allocWithZone:[self zone]] init];
	missingPublicKeyEmails = [[NSMutableSet allocWithZone:[self zone]] init];
	selectedPersonalKey = [[mailBundle defaultKey] retain];
	[selectedPersonalPublicKey release];
	selectedPersonalPublicKey = nil;
//    usesOnlyOpenPGPStyle = [mailBundle usesOnlyOpenPGPStyle];

	[self setupTableColumns];
//    [self updateWarningImage];
	[[publicKeysPopDownButton menu] setAutoenablesItems:NO];

	[[self composeAccessoryView] setFrame:[[optionalView primaryView] frame]];
	[[[optionalView primaryView] superview] replaceSubview:[optionalView primaryView] with:[self composeAccessoryView]];
	[optionalViewBackgroundView setBackgroundColor:[NSColor windowBackgroundColor]];
/*    {
 *      ColorBackgroundView *aView = [[ColorBackgroundView alloc] initWithFrame:[optionalView bounds]];
 *
 *      [aView setBackgroundColor:[NSColor windowBackgroundColor]];
 *      [[[self composeAccessoryView] superview] addSubview:aView positioned:NSWindowBelow relativeTo:nil]; // Let's make sure our whole view is opaque; probably not needed once we're using a real optional view; if we don't do that, there are some display problems (cache?) when superview is resized
 *      [aView release];
 *      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAccessoryView:) name:NSViewFrameDidChangeNotification object:[[optionalView primaryView] superview]]; // Needed too
 *  }*/
	[optionalViewTitleField setStringValue:NSLocalizedStringFromTableInBundle(@"PGP:", @"GPGMail", [NSBundle bundleForClass:[self class]], "Title of PGP accessory view")];
	[[optionalView optionSwitch] setState:[self displaysButtonsInComposeWindow] ? NSOnState:NSOffState];
//	accessoryView = [optionalView retain];
	if (![self displaysButtonsInComposeWindow]) {
		accessoryView = [emptyView retain];
	} else {
		accessoryView = [optionalView retain];
	}

	[personalKeysPopUpButton setAutoenablesItems:NO];             // Needed!

	[self reloadPersonalKeys];
	[self refreshPersonalKeysMenuAccordingToSelf:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPublicKeysPopDownButton:) name:NSPopUpButtonWillPopUpNotification object:publicKeysPopDownButton];
	// We need to delay the following call, after our composeAccessoryView has been moved to the Compose window
	[self performSelector:@selector(finishUISetupWithStates:) withObject:states afterDelay:0.0];
#endif /* ifndef SNOW_LEOPARD_64 */
}

- (void)doSetEncryptsMessage:(BOOL)flag {
	DebugLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
	NSEnumerator *anEnum = [[[[[self composeAccessoryView] window] toolbar] items] objectEnumerator];
	SegmentedToolbarItem *anItem;
	NSBundle *aBundle = [NSBundle bundleForClass:[self class]];
	BOOL buttonsShowState = [[GPGMailBundle sharedInstance] buttonsShowState];

	encryptsMessage = flag;
	if (!flag) {
		usesSymetricEncryption = NO;
		[self refreshSymetricEncryption];
#if 0
		if (signatureTurnedOnBecauseEncrypted) {
			signatureTurnedOnBecauseEncrypted = NO;
			if (signsMessage && !explicitlySetSignature && !somePeopleWantSigning) {
				[self doSetSignsMessage:NO];
			}
		}
#endif
	}

	while (anItem = [anEnum nextObject])
		if ([[anItem itemIdentifier] isEqualToString:GPGEncryptMessageToolbarItemIdentifier]) {
			if (buttonsShowState) {
				[anItem setLabel:NSLocalizedStringFromTableInBundle(encryptsMessage ? @"ENCRYPTED_ITEM":@"CLEAR_ITEM", @"GPGMail", aBundle, "") forSegment:0];
				[anItem setPaletteLabel:NSLocalizedStringFromTableInBundle(@"ENCRYPTED_ITEM", @"GPGMail", aBundle, "") forSegment:0];
				[[[anItem subitems] objectAtIndex:0] setImage:[NSImage imageNamed:(encryptsMessage ? @"gpgEncrypted":@"gpgClear")]];
				[anItem setToolTip:NSLocalizedStringFromTableInBundle(encryptsMessage ? @"ENCRYPTED_ITEM_TOOLTIP":@"CLEAR_ITEM_TOOLTIP", @"GPGMail", aBundle, "") forSegment:0];
			} else {
				[anItem setLabel:NSLocalizedStringFromTableInBundle(encryptsMessage ? @"MAKE_CLEAR_ITEM":@"MAKE_ENCRYPTED_ITEM", @"GPGMail", aBundle, "") forSegment:0];
				[anItem setPaletteLabel:NSLocalizedStringFromTableInBundle(@"MAKE_ENCRYPTED_ITEM", @"GPGMail", aBundle, "") forSegment:0];
				[[[anItem subitems] objectAtIndex:0] setImage:[NSImage imageNamed:(encryptsMessage ? @"gpgClear":@"gpgEncrypted")]];
				[anItem setToolTip:NSLocalizedStringFromTableInBundle(encryptsMessage ? @"MAKE_CLEAR_ITEM_TOOLTIP":@"MAKE_ENCRYPTED_ITEM_TOOLTIP", @"GPGMail", aBundle, "") forSegment:0];
			}
		}

	[[[GPGMailBundle sharedInstance] encryptsNewMessageMenuItem] setState:(encryptsMessage ? NSOnState:NSOffState)];
	[publicKeysPopDownButton setEnabled:encryptsMessage];
	[encryptionSwitch setState:(encryptsMessage ? NSOnState:NSOffState)];
//    [self updateWarningImage]; // No longer necessary
}

#ifdef SNOW_LEOPARD_64
- (NSView *)composeAccessoryView {
	return [self displaysButtonsInComposeWindow] ? [optionalView retain] : [emptyView retain];
}
#endif

- (void)doSetSignsMessage:(BOOL)flag {
	DebugLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
	NSEnumerator *anEnum = [[[[[self composeAccessoryView] window] toolbar] items] objectEnumerator];
	SegmentedToolbarItem *anItem;
	NSBundle *aBundle = [NSBundle bundleForClass:[self class]];
	BOOL buttonsShowState = [[GPGMailBundle sharedInstance] buttonsShowState];

	signsMessage = flag;

	while (anItem = [anEnum nextObject])
		if ([[anItem itemIdentifier] isEqualToString:GPGSignMessageToolbarItemIdentifier]) {
			if (buttonsShowState) {
				[anItem setLabel:NSLocalizedStringFromTableInBundle(signsMessage ? @"SIGNED_ITEM":@"UNSIGNED_ITEM", @"GPGMail", aBundle, "") forSegment:0];
				[anItem setPaletteLabel:NSLocalizedStringFromTableInBundle(@"SIGNED_ITEM", @"GPGMail", aBundle, "") forSegment:0];
				[[[anItem subitems] objectAtIndex:0] setImage:[NSImage imageNamed:(signsMessage ? @"gpgSigned":@"gpgUnsigned")]];
				[anItem setToolTip:NSLocalizedStringFromTableInBundle(signsMessage ? @"SIGNED_ITEM_TOOLTIP":@"UNSIGNED_ITEM_TOOLTIP", @"GPGMail", aBundle, "") forSegment:0];
			} else {
				[anItem setLabel:NSLocalizedStringFromTableInBundle(signsMessage ? @"MAKE_UNSIGNED_ITEM":@"MAKE_SIGNED_ITEM", @"GPGMail", aBundle, "") forSegment:0];
				[anItem setPaletteLabel:NSLocalizedStringFromTableInBundle(@"MAKE_SIGNED_ITEM", @"GPGMail", aBundle, "") forSegment:0];
				[[[anItem subitems] objectAtIndex:0] setImage:[NSImage imageNamed:(signsMessage ? @"gpgUnsigned":@"gpgSigned")]];
				[anItem setToolTip:NSLocalizedStringFromTableInBundle(signsMessage ? @"MAKE_UNSIGNED_ITEM_TOOLTIP":@"MAKE_SIGNED_ITEM_TOOLTIP", @"GPGMail", aBundle, "") forSegment:0];
			}
		}

	[[[GPGMailBundle sharedInstance] signsNewMessageMenuItem] setState:(signsMessage ? NSOnState:NSOffState)];
	[personalKeysPopUpButton setEnabled:signsMessage];
	[signSwitch setState:(signsMessage ? NSOnState:NSOffState)];
}
/*
 * - (void) toggleEncryptionForNewMessage
 * {
 *  // NO LONGER USED
 *  NSLog(@"%s", __PRETTY_FUNCTION__);
 *  [self doSetEncryptsMessage:!encryptsMessage];
 *  [self findMatchingPublicKeys]; // FIXME: Do not look for keys when user toggled encryption off?
 *  [self refreshAutomaticChoiceInfo];
 *  [self refreshPublicKeysMenu];
 *  if(encryptsMessage && !signsMessage && [[GPGMailBundle sharedInstance] signWhenEncrypting]){
 *      signatureTurnedOnBecauseEncrypted = YES;
 *      [self doSetSignsMessage:YES];
 *  }
 * }
 */
- (IBAction)gpgToggleEncryptionForNewMessage:(id)sender {
	// Forwarded by GPGMailBundle when sent by menuItem, or sent by checkbox, or toolbarItem
	explicitlySetEncryption = YES;
#if 0
	[self toggleEncryptionForNewMessage];
#else
	encryptsMessage = !encryptsMessage;
	[self evaluateRules];
#endif
}
/*
 * - (void) toggleSignatureForNewMessage
 * {
 *  [self doSetSignsMessage:!signsMessage];
 * }
 */
- (IBAction)gpgToggleSignatureForNewMessage:(id)sender {
	// Forwarded by GPGMailBundle when sent by menuItem, or sent by checkbox, or toolbarItem
	explicitlySetSignature = YES;
#if 0
	[self toggleSignatureForNewMessage];
#else
	signsMessage = !signsMessage;
	[self evaluateRules];
#endif
}

- (void)gpgSetOptions:(NSDictionary *)options {
	// Forwarded by GPGMessageEditorPoser via MessageEditor, on reply to a PGP message
	// FIXME: not implemented for Leopard!
#if 0
#warning FIXME: Should not modify any encrypt/sign/MIME setting???
	NSNumber *aNumber;

//    NSLog(@"$$$ Flags derived from replied message: %@", options);
	aNumber = [options objectForKey:@"signed"];
	if (aNumber) {
		[self doSetSignsMessage:[aNumber boolValue]];
	}

	aNumber = [options objectForKey:@"encrypted"];
	if (aNumber) {
		[self doSetEncryptsMessage:[aNumber boolValue]];                         // Will sign too, if defaults ask to sign when encrypting
	}

	aNumber = [options objectForKey:@"MIME"];
	if (aNumber) {
		[self setUsesOnlyOpenPGPStyle:[aNumber boolValue]];
	}
#else
	[replyOptions release];
	replyOptions = [options retain];
	[self evaluateRules];
#endif /* if 0 */
}

- (void)retryDelivery {
	id target = [self messageEditor];
	SEL selector = NSSelectorFromString(@"send:");

	if (target && [target respondsToSelector:selector]) {
		[target performSelector:selector withObject:nil];
	}
}

- (void)sheetDidDismiss:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (selectedPersonalKey) {
		[GPGPassphraseController flushCachedPassphraseForUser:selectedPersonalKey];
	}
	if (returnCode == NSAlertDefaultReturn) {
		[self retryDelivery];
	}
}

- (void)displayException:(NSException *)exception {
	NSString *aTitle;

	if (encryptsMessage) {
		aTitle = NSLocalizedStringFromTableInBundle(@"MSG_ENCRYPTION_ALERT_TITLE", @"GPGMail", [NSBundle bundleForClass:[self class]], "");
	} else {
		aTitle = NSLocalizedStringFromTableInBundle(@"MSG_SIGNING_ALERT_TITLE", @"GPGMail", [NSBundle bundleForClass:[self class]], "");
	}
	if ([[exception reason] rangeOfString:@" failed: bad passphrase"].length > 0) {           /* sign+encrypt or signing */
		NSBeginAlertSheet(aTitle, NSLocalizedStringFromTableInBundle(@"TRY_AGAIN", @"GPGMail", [NSBundle bundleForClass:[self class]], ""), NSLocalizedStringFromTableInBundle(@"CANCEL_DELIVERY", @"GPGMail", [NSBundle bundleForClass:[self class]], ""), nil, [[self composeAccessoryView] window], self, NULL, @selector(sheetDidDismiss:returnCode:contextInfo:), NULL, @"%@", [exception reason]);
	} else {
		NSBeginAlertSheet(aTitle, nil, nil, nil, [[self composeAccessoryView] window], nil, NULL, NULL, NULL, @"%@", [[GPGMailBundle sharedInstance] descriptionForException:exception]);
	}
}

- (void)unmatchedAddressesSheetDidDismiss:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	NSArray *addresses = (NSArray *)contextInfo;

	if (returnCode == NSAlertDefaultReturn) {
		[[GPGKeyDownload sharedInstance] searchKeysMatchingPatterns:addresses];
	} else if (returnCode == NSAlertOtherReturn) {
		[self gpgToggleEncryptionForNewMessage:nil];
		[self retryDelivery];
	}
	[addresses release];
}

- (void)missingKeysAlert:(NSArray *)addresses {
	NSString *aTitle = NSLocalizedStringFromTableInBundle(@"MISSING_KEYS: DOWNLOAD", @"GPGMail", [NSBundle bundleForClass:[self class]], "");
	NSString *cancelTitle = NSLocalizedStringFromTableInBundle(@"CANCEL_DELIVERY", @"GPGMail", [NSBundle bundleForClass:[self class]], "");
	NSString *okTitle = NSLocalizedStringFromTableInBundle(@"SEARCH_MATCHING_KEYS", @"GPGMail", [NSBundle bundleForClass:[self class]], "");
	NSString *inClearTitle = NSLocalizedStringFromTableInBundle(@"SEND_IN_CLEAR", @"GPGMail", [NSBundle bundleForClass:[self class]], "");
	NSString *aMessage = NSLocalizedStringFromTableInBundle(@"UNMATCHED_ADDRESSES: %@", @"GPGMail", [NSBundle bundleForClass:[self class]], "");

	NSBeginAlertSheet(aTitle, okTitle, cancelTitle, inClearTitle, [[self composeAccessoryView] window], self, NULL, @selector(unmatchedAddressesSheetDidDismiss:returnCode:contextInfo:), [addresses retain], aMessage, [addresses componentsJoinedByString:@"\n"]);
}

- (BOOL)messageWillBeSaved:(OutgoingMessage *)message {
	// Invoked when message is saved in drafts; we have the opportunity to add our own headers
	// that we can get back when draft is converted back to message for delivery.
	// This way we can save the encryption/signature flags (as well as OpenPGP/MIME,
	// and chosen keys, maybe later).
	// WARNING Also called when message is delivered!
	if (![[[self messageEditor] backEnd] isDeliveringMessage]) {
		NSMutableArray *states = [NSMutableArray array];

		if (explicitlySetEncryption) {
			[states addObject:(encryptsMessage ? @"encrypted":@"!encrypted")];
		}
		if (explicitlySetSignature) {
			[states addObject:(signsMessage ? @"signed":@"!signed")];
		}
		if (explicitlySetOpenPGPStyle) {
			[states addObject:(usesOnlyOpenPGPStyle ? @"mime":@"!mime")];
		}
		if ([states count] > 0) {
			[(MutableMessageHeaders *)[message headers] setHeader:[states componentsJoinedByString:@","] forKey:@"X-Gpgmail-State"];
		} else {
			[(MutableMessageHeaders *)[message headers] removeHeaderForKey:@"X-Gpgmail-State"];
		}
		MutableMessageHeaders *newHeaders = [message headers];
		NSData *bodyData = [[message bodyData] copy];
		newHeaders = [[MutableMessageHeaders alloc] initWithHeaderData:[newHeaders encodedHeadersIncludingFromSpace:NO] encoding:[newHeaders preferredEncoding]];                         // Needed, to ensure _data ivar is updated
		[message setMutableHeaders:newHeaders];

		// We need to recreate the whole raw data, headers + body.
		NSMutableData *newRawData = [NSMutableData dataWithData:[newHeaders headerData]];
		[newRawData appendData:bodyData];
		[message setRawData:newRawData offsetOfBody:[(NSData *)[newHeaders headerData] length]];
		[newHeaders release];
		[bodyData release];
	}

	// Runtime super call - CORRECT !
	struct objc_super s = { self, [self superclass] };
	return (BOOL)objc_msgSendSuper(&s, @selector(messageWillBeSaved:), message);
}

- (BOOL)messageHasAlreadyBeenEncryptedOrSigned:(Message *)message {
	// We use that in order to avoid re-encrypting/signing a message
	// after delivery failed.
// #warning FIXME: This will not work when we do not add custom headers!
#if 0
	// Even on Tiger we have the same problem: our header customization has been lost
	if ([[message headers] hasHeaderForKey:GPGMailHeaderKey] /*|| ([[message headers] hasHeaderForKey:@"content-type"] && [[message headers] headersForKey:@"content-type"])*/) {           /* array of data */
		return YES;
	} else {
		return NO;
	}
#else
#warning TODO: this does not work, because Mail removes all our custom headers!
	// Hence, a PGP-MIME message is now invalid! We should maybe cache message before encryption/signing,
	// and restore it after delivery failure in case of re-sending. We need to be notified when we
	// can clear our cache (or is it in the dealloc?)

	// See MessageEditor?
	// - (void)backEndDidAppendMessageToOutbox:(id)fp8 result:(int)fp12;
	// - (void)backEnd:(id)fp8 didCancelMessageDeliveryForError:(id)fp12;

/*    if([[message headers] hasHeaderForKey:GPGMailHeaderKey])
 *      return YES;
 *  else*/
	return NO;
#endif
}

- (BOOL)hasRulesConflicts {
	// Warn user in following cases: user can choose to go on or cancel. We'll need an additional flag showing that user acknowledged
	// In alert, display info per user:
	// user1 always encrypt, never sign, accepts/always MIME
	// user2 never encrypt
	// Maybe in a tableview with checkboxes, not textual - show only always/never
	BOOL logging = (GPGMailLoggingLevel > 0);

	if (somePeopleDontWantEncryption && somePeopleWantEncryption) {
		if (logging) {
			NSLog(@"WARNING: some people want encryption, some refuse");
		}
		return YES;
	} else if (somePeopleDontWantEncryption && !somePeopleWantEncryption && encryptsMessage) {
		if (logging) {
			NSLog(@"WARNING: some people refuse encryption, but you want it");
		}
		return YES;
	} else if (!somePeopleDontWantEncryption && somePeopleWantEncryption && !encryptsMessage) {
		if (logging) {
			NSLog(@"WARNING: some people want encryption, but you don't want it");
		}
		return YES;
	} else if (somePeopleDontWantMIME && somePeopleWantMIME) {
		if (logging) {
			NSLog(@"WARNING: some people want MIME, some refuse");
		}
		return YES;
	} else if (somePeopleDontWantSigning && somePeopleWantSigning) {
		if (logging) {
			NSLog(@"WARNING: some people want signature, some refuse");
		}
		return YES;
	} else {
		// If user explicitly disables signing/encryption but a recipient wants some,
		// warn user on delivery that options are not respected; let him accept encryption/MIME settings,
		// or change them. But do NOT recompute these options after user manually set them!
		// We could also display some icons next to user entry in the public keys popdown to show these options?
		if (explicitlySetEncryption) {
			if (encryptsMessage && somePeopleDontWantEncryption) {
				return YES;
			} else if (!encryptsMessage && somePeopleWantEncryption) {
				return YES;
			}
		}

		if (explicitlySetSignature) {
			if (signsMessage && somePeopleDontWantSigning) {
				return YES;
			} else if (!signsMessage && somePeopleWantSigning) {
				return YES;
			}
		}

		if (explicitlySetOpenPGPStyle) {
			if (usesOnlyOpenPGPStyle && somePeopleDontWantMIME) {
				return YES;
			}
		}
	}

	return NO;
}

// TODO: Fix me for Libmacgpg
//- (BOOL)messageWillBeDelivered:(OutgoingMessage *)message {
//	DebugLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
//	// Runtime super call - CORRECT !
//	struct objc_super s = { self, [self superclass] };
//	BOOL result = (BOOL)objc_msgSendSuper(&s, @selector(messageWillBeDelivered:), message);
//
//	// Remove draft headers
//#warning CHECKME LEOPARD
//	[(MutableMessageHeaders *)[message headers] removeHeaderForKey:@"X-Gpgmail-State"];
//	MutableMessageHeaders *newHeaders = [message headers];
//	NSData *bodyData = [[message bodyData] copy];
//	newHeaders = [[MutableMessageHeaders alloc] initWithHeaderData:[newHeaders encodedHeadersIncludingFromSpace:NO] encoding:[newHeaders preferredEncoding]];             // Needed, to ensure _data ivar is updated
//	[message setMutableHeaders:newHeaders];
//
//	// We need to recreate the whole raw data, headers + body.
//	NSMutableData *newRawData = [NSMutableData dataWithData:[newHeaders headerData]];
//	[newRawData appendData:bodyData];
//	[message setRawData:newRawData offsetOfBody:[(NSData *)[newHeaders headerData] length]];
//	[newHeaders release];
//	[bodyData release];
//
//#if 0
//	// Look for keys
//	[self findMatchingPublicKeys];
//	// Look for custom PGP rules in recipients list
//	[self searchKnownPersonsOptions];
//#else
//	[self evaluateRules];
//#endif
//
//	// Now, verify rules conflicts
//	if (verifyRulesConflicts) {
//		if ([self hasRulesConflicts]) {
//			[self performSelector:@selector(resolveRulesConflicts:) withObject:nil afterDelay:0];
//
//			return NO;
//		}
//	}
////    [self findMatchingPublicKeys]; // Again??
//
//	if (result && ((encryptsMessage || signsMessage) && ![self messageHasAlreadyBeenEncryptedOrSigned:message])) {
//		NSBundle *aBundle = [NSBundle bundleForClass:[self class]];
//		GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];
//		GPGMailFormat mailFormat;
//		NSMutableArray *recipients = nil;
//		BOOL trustsAllKeys = [mailBundle trustsAllKeys];
//
//#warning S/MIME & PGP
//		// Disable S/MIME if still possible, or at least warn user.
//		// Maybe we should allow double-signature (opt.), as it seems to work,
//		// but not double-encryption! (except if we can have separate MIME parts)
//		if (usesOnlyOpenPGPStyle) {
//			mailFormat = GPGOpenPGPMailFormat;
//		} else {
//			// TODO: Support forcing inline
//			mailFormat = GPGAutomaticMailFormat;
//		}
//
//		// First, prepare arguments (recipients, etc.)
//		if (encryptsMessage) {
//			// Messages are indexed after having been encrypted or signed, i.e. after sending
//			if (!usesSymetricEncryption) {
//				GPGKey *aKey;
//				NSEnumerator *anEnum;
//
//				recipients = [NSMutableArray array];
//				if (!useCustomPublicKeys) {
//					if ([missingPublicKeyEmails count]) {
//						// Method is invoked in the main thread
//						// => Impossible to block it by asking something to the user
//						// We display missing keys, and tell user to assign them manually
//						// before trying to send message again
//						[self performSelector:@selector(missingKeysAlert:) withObject:[missingPublicKeyEmails allObjects] afterDelay:0.0];
//
//						return NO;
//					}
//				}
//				anEnum = [selectedPublicKeys objectEnumerator];
//				while (aKey = [anEnum nextObject])
//					if ([mailBundle canKeyBeUsedForEncryption:aKey]) {
//						[recipients addObject:aKey];
//					}
//				if ([recipients count] == 0) {
//					// Can happen, in some error situation (proxy died), that we have no selectedPublicKeys!
//					NSException *anException = [[NSException alloc] initWithName:GPGMailException reason:@"NO_VALID_PUBLIC_KEY" userInfo:nil];
//
//					[self performSelector:@selector(displayException:) withObject:anException afterDelay:0.0];
//					[anException release];
//
//					return NO;
//				}
//			}
//
//			if (signsMessage && ![mailBundle canKeyBeUsedForSigning:selectedPersonalKey]) {
//				// Can happen, in some error situation (proxy died), that we have no selectedPersonalKey!
//				NSException *anException = [[NSException alloc] initWithName:GPGMailException reason:@"NO_VALID_PRIVATE_KEY" userInfo:nil];
//
//				[self performSelector:@selector(displayException:) withObject:anException afterDelay:0.0];
//				[anException release];
//
//				return NO;
//			}
//		} else {
//			if (![mailBundle canKeyBeUsedForSigning:selectedPersonalKey]) {
//				// Can happen, in some error situation (proxy died), that we have no selectedPersonalKey!
//				NSException *anException = [[NSException alloc] initWithName:GPGMailException reason:@"NO_VALID_PRIVATE_KEY" userInfo:nil];
//
//				[self performSelector:@selector(displayException:) withObject:anException afterDelay:0.0];
//				[anException release];
//
//				return NO;
//			}
//		}
//
//		// Finally, prepare PGP message for delivery
//		if (encryptsMessage) {
//			GPGProgressIndicatorController *aController = [GPGProgressIndicatorController sharedController];
//
//#warning TODO: Use a sheet (-> no longer shared instance)
//			[aController startWithTitle:NSLocalizedStringFromTableInBundle(@"ENCRYPTING", @"GPGMail", aBundle, "") delegate:self];
//
//			@try {
//				[message gpgEncryptForRecipients:recipients trustAllKeys:trustsAllKeys signWithKey:(signsMessage ? selectedPersonalKey : nil) passphraseDelegate:self format:mailFormat];
//			} @catch (NSException *localException) {
//				result = NO;
//				if (![[localException name] isEqualToString:GPGException] || [mailBundle gpgErrorCodeFromError:[[[localException userInfo] objectForKey:GPGErrorKey] intValue]] != /*GPGErrorNoData*/ GPGErrorCancelled) {
//					[self performSelector:@selector(displayException:) withObject:localException afterDelay:0.0];
//				}
//				// Else, user cancelled passphrase entry; do nothing special, return.
//			}
//			[aController stop];
//		} else {
//			@try {
//				[message gpgSignWithKey:selectedPersonalKey passphraseDelegate:self format:mailFormat];
//			} @catch (NSException *localException) {
//				result = NO;
//				if (![[localException name] isEqualToString:GPGException] || [mailBundle gpgErrorCodeFromError:[[[localException userInfo] objectForKey:GPGErrorKey] unsignedIntValue]] != /*GPGErrorNoData*/ GPGErrorCancelled) {
//					[self performSelector:@selector(displayException:) withObject:localException afterDelay:0.0];
//				}
//				// Else, user cancelled passphrase entry; do nothing special, return.
//			}
//		}
//
//		// There is a problem with Compose window: it is not redisplayed correctly
//		if (!result) {
//// #warning VERIFY Is it still the case in 10.3?
//			[[[self composeAccessoryView] window] makeKeyAndOrderFront:nil];
//			// Even this call is not enough: the window shadow/border is not redisplayed
//			// This is probably due to the alert panel raised by -[GPGHandler displayException:]
//		}
//	}
//
//	verifyRulesConflicts = YES;
//
//	return result;
//}

- (void)progressIndicatorDidCancel:(GPGProgressIndicatorController *)controller {
	// Currently it is not possible to cancel a running operation
//    [[GPGHandler defaultHandler] cancelOperation];
}

- (IBAction)toggleColumnDisplay:(id)sender {
	if ([sender state] != NSOnState) {
		int anIndex = [sender tag];
		NSTableColumn *aColumn = [allTableColumns objectAtIndex:anIndex];
		NSArray *defaultColumnWidths = [[GPGDefaults standardDefaults] arrayForKey:@"GPGTableColumnWidths"];

		if (defaultColumnWidths != nil) {
			[aColumn setWidth:[[defaultColumnWidths objectAtIndex:anIndex] floatValue]];
		}
		[publicKeysOutlineView addTableColumn:aColumn];
		[sender setState:NSOnState];
	} else {
		int anIndex = [sender tag];
		NSTableColumn *aColumn = [allTableColumns objectAtIndex:anIndex];

		[publicKeysOutlineView removeTableColumn:aColumn];
		[sender setState:NSOffState];
	}
}

- (IBAction)choosePersonalKey:(id)sender {
	// Sent by personalKeysPopUpButton
	[selectedPersonalKey release];
	[selectedPersonalPublicKey release];
	selectedPersonalPublicKey = nil;
	selectedPersonalKey = [[[sender selectedItem] representedObject] retain];
	[self refreshPersonalKeysMenuAccordingToSelf:YES];
#if 0
	[self refreshPublicKeysMenu];
#else
	[self evaluateRules];             // Necessary?
#endif
}

- (IBAction)gpgChoosePublicKey:(id)sender {
	// Do nothing; this is a dummy method, used to enable/disable
	// main menu's public keys list items...
	// It might be used to display an utility window containing
	// extended info on selected key.
}

- (void)keyChoiceSheetDidDismiss:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	NSSet *originalPublicKeys = (NSSet *)contextInfo;

	if (returnCode == NSAlertDefaultReturn) {
		// User clicked on 'Choose' button, thus automatic choice must be disabled
		useCustomPublicKeys = YES;
	} else {
		// User cancelled panel
		[selectedPublicKeys setArray:[originalPublicKeys allObjects]];
		useCustomPublicKeys = cachedUseCustomPublicKeys;
	}
	[originalPublicKeys release];
	if (returnCode == NSAlertDefaultReturn || returnCode == NSAlertAlternateReturn) {
		[self evaluateRules];
	}
}

- (IBAction)gpgChoosePublicKeys:(id)sender {
	// Sent by popup menu item, or forwarded by ComposeWindowStore
	NSSet *originalPublicKeys;

	if (!useCustomPublicKeys) {           // Do not recompute list when was manually set
		[self findMatchingPublicKeys];
	}
	[publicKeysOutlineView reloadData];
	originalPublicKeys = [[NSSet alloc] initWithArray:selectedPublicKeys];
	cachedUseCustomPublicKeys = useCustomPublicKeys;
	[[NSApplication sharedApplication] beginSheet:publicKeysPanel modalForWindow:[[self composeAccessoryView] window] modalDelegate:self didEndSelector:@selector(keyChoiceSheetDidDismiss:returnCode:contextInfo:) contextInfo:originalPublicKeys];
}

- (IBAction)gpgUseDefaultPublicKeys:(id)sender {
	useCustomPublicKeys = NO;
#if 0
	[self findMatchingPublicKeys];
#else
	[self evaluateRules];
#endif
	[publicKeysOutlineView reloadData];
}

- (IBAction)gpgChoosePersonalKey:(id)sender {
	// Forwarded by GPGComposeWindowStorePoser
	NSEnumerator *anEnum = [[personalKeysPopUpButton itemArray] objectEnumerator];
	NSMenuItem *anItem;
	BOOL found = NO;

#warning FIXME: Should not modify any encrypt/sign/MIME setting???
	[selectedPersonalKey release];
	[selectedPersonalPublicKey release];
	selectedPersonalPublicKey = nil;
	selectedPersonalKey = [[sender representedObject] retain];
	while (anItem = [anEnum nextObject]) {
		if ([[anItem representedObject] isEqual:selectedPersonalKey]) {
			found = YES;
			[personalKeysPopUpButton selectItem:anItem];
			break;
		}
	}
	NSAssert(found, @"### Unable to find corresponding personal key in popup!");
	[self refreshPersonalKeysMenuAccordingToSelf:YES];
	[self refreshPublicKeysMenu];
}

- (IBAction)gpgToggleAutomaticPublicKeysChoice:(id)sender {
	useCustomPublicKeys = ([sender state] == NSOnState);
#if 0
	[self findMatchingPublicKeys];
	[self refreshAutomaticChoiceInfo];
	[self refreshPublicKeysMenu];
	[self updateWarningImage];
#else
	[self evaluateRules];
#endif
}

- (IBAction)gpgToggleSymetricEncryption:(id)sender {
	usesSymetricEncryption = ([sender state] != NSOnState);
	[self refreshSymetricEncryption];
#if 0
	[self doSetSignsMessage:(usesSymetricEncryption ? NO:signsMessage)];
	if (!usesSymetricEncryption && encryptsMessage && !signsMessage && [[GPGMailBundle sharedInstance] signWhenEncrypting]) {
		signatureTurnedOnBecauseEncrypted = YES;
		[self doSetSignsMessage:YES];
	}
	[signSwitch setEnabled:!usesSymetricEncryption];
	[self refreshPublicKeysMenu];
	[self updateWarningImage];
#else
	[signSwitch setEnabled:!usesSymetricEncryption];
	[self evaluateRules];
#endif
}

- (void)setUsesOnlyOpenPGPStyle:(BOOL)flag {
	usesOnlyOpenPGPStyle = flag;
}

- (IBAction)gpgToggleUsesOnlyOpenPGPStyle:(id)sender {
	explicitlySetOpenPGPStyle = YES;
	[self setUsesOnlyOpenPGPStyle:([sender state] != NSOnState)];
	[self evaluateRules];
}

- (IBAction)endModal:(id)sender {
	NSEnumerator *anEnum = [[publicKeysOutlineView tableColumns] objectEnumerator];
	NSTableColumn *aColumn;
	NSMutableArray *visibleColumnTags = [NSMutableArray array];

	[[GPGDefaults standardDefaults] setInteger:[allTableColumns indexOfObject:sortingTableColumn] forKey:@"GPGSortingTableColumnTag"];
	[[GPGDefaults standardDefaults] setBool:ascendingOrder forKey:@"GPGAscendingSorting"];
	
	
	while (aColumn = [anEnum nextObject])
		[visibleColumnTags addObject:[NSString stringWithFormat:@"%u", [allTableColumns indexOfObject:aColumn]]];

	[[GPGDefaults standardDefaults] setObject:visibleColumnTags forKey:@"GPGVisibleTableColumnTags"];

	[publicKeysPanel orderOut:sender];
	[[NSApplication sharedApplication] endSheet:publicKeysPanel returnCode:[[sender selectedCell] tag]];
}

- (void)outlineView:(NSOutlineView *)outlineView didClickTableColumn:(NSTableColumn *)tableColumn {
	if (tableColumn != sortingTableColumn) {
		[outlineView setIndicatorImage:nil inTableColumn:sortingTableColumn];
		[sortingTableColumn release];
		sortingTableColumn = [tableColumn retain];
	} else {
		ascendingOrder = !ascendingOrder;
	}
	[outlineView setHighlightedTableColumn:tableColumn];
	[outlineView setIndicatorImage:(ascendingOrder ? ascendingOrderImage:descendingOrderImage) inTableColumn:tableColumn];

	[self invalidateAllPublicKeys];
	[outlineView reloadData];
}

- (void)outlineViewColumnDidResize:(NSNotification *)aNotification {
	NSEnumerator *anEnum = [allTableColumns objectEnumerator];
	NSTableColumn *aColumn;
	NSMutableArray *widths = [NSMutableArray array];

	while (aColumn = [anEnum nextObject])
		[widths addObject:[NSNumber numberWithFloat:[aColumn width]]];
	[[GPGDefaults standardDefaults] setObject:widths forKey:@"GPGTableColumnWidths"];
}


- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
	if (item == nil) {
		return [[self sortedPublicKeys] objectAtIndex:index];
	} else {
		return [[[GPGMailBundle sharedInstance] secondaryUserIDsForKey:item] objectAtIndex:index];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	if (![item respondsToSelector:@selector(userIDs)]) {
		return NO;
	} else {
		return [[[GPGMailBundle sharedInstance] secondaryUserIDsForKey:item] lastObject] != nil;
	}
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	if (!publicKeysOutlineViewHasBeenInitialized) {
		return 0;
	}
	if (item == nil) {
		return [self cachedPublicKeyCount];
	} else {
		if (![item respondsToSelector:@selector(userIDs)]) {
			return 0;
		} else {
			return [[[GPGMailBundle sharedInstance] secondaryUserIDsForKey:item] count];
		}
	}
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if (![item respondsToSelector:@selector(userIDs)]) {
		if ([[tableColumn identifier] isEqualToString:@"isSelected"]) {
			return nil;
		} else {
			// FIXME: Use red color for expired/revoked/etc.
			if ([[tableColumn identifier] isEqualToString:@"validityDescription"]) {
				NSNumber *aValue = [NSNumber numberWithInt:[item validity]];
				NSString *aDesc = [NSString stringWithFormat:@"Validity=%@", aValue];

				return NSLocalizedStringFromTableInBundle(aDesc, @"GPGMail", [NSBundle bundleForClass:[self class]], "");
			} else {
				SEL aSelector = NSSelectorFromString([tableColumn identifier]);

				if ([item respondsToSelector:aSelector]) {
					return [item performSelector:aSelector];
				} else {
					return @"";
				}
			}
		}
	} else {
		if ([[tableColumn identifier] isEqualToString:@"isSelected"]) {
			return [NSNumber numberWithBool:[selectedPublicKeys containsObject:item]];
		} else {
			// FIXME: Use red color for expired/revoked/etc.
			if ([[tableColumn identifier] isEqualToString:@"validityDescription"]) {
				NSNumber *aValue = [NSNumber numberWithInt:[item validity]];
				NSString *aDesc = [NSString stringWithFormat:@"Validity=%@", aValue];

				return NSLocalizedStringFromTableInBundle(aDesc, @"GPGMail", [NSBundle bundleForClass:[self class]], "");
			} else {
				return [item performSelector:NSSelectorFromString([tableColumn identifier])];
			}
		}
	}
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if ([[tableColumn identifier] isEqualToString:@"isSelected"] && !![item respondsToSelector:@selector(userIDs)]) {
		if ([object intValue]) {
			if (![selectedPublicKeys containsObject:item]) {
				[selectedPublicKeys addObject:item];
			}
		} else {
			[selectedPublicKeys removeObject:item];
		}
		useCustomPublicKeys = YES;
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	return !![item respondsToSelector:@selector(userIDs)] && [[tableColumn identifier] isEqualToString:@"isSelected"];
}


- (void)outlineView:(NSOutlineView *)ov willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	if ([[tableColumn identifier] isEqualToString:@"isSelected"]) {
		[cell setImagePosition:([item respondsToSelector:@selector(userIDs)] ? NSImageOnly:NSNoImage)];
	}
}
/*
 * - (NSString *)outlineView:(NSOutlineView *)ov toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tc item:(id)item mouseLocation:(NSPoint)mouseLocation
 * {
 *      // Available only since Tiger
 *      if([[tc identifier] isEqualToString:@"description"])
 *              return [self outlineView:ov objectValueForTableColumn:tc byItem:item]; // TODO: Use multi-line display for readability?
 *      else
 *              return nil;
 * }*/


- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
	// Forwarded by GPGComposeWindowStorePoser or MessageEditor
	SEL anAction = ([theItem isKindOfClass:NSClassFromString(@"SegmentedToolbarItem")] ? [(SegmentedToolbarItem *) theItem actionForSegment:0] : [theItem action]);

	if (anAction == @selector(gpgToggleEncryptionForNewMessage:)) {
		return YES;
	} else if (anAction == @selector(gpgToggleSignatureForNewMessage:)) {
		return !usesSymetricEncryption;
	} else {
		return NO;
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	// Forwarded by GPGComposeWindowStorePoser or MessageEditor
	SEL anAction = [menuItem action];

	if (anAction == @selector(gpgChoosePublicKeys:) || anAction == @selector(gpgChoosePublicKey:) || anAction == @selector(gpgToggleAutomaticPublicKeysChoice:)) {
		// If reached too often, we could use a BOOL indicating
		// WHEN we need to refresh menu (pubkey list changed,
		// window did resign, auto changed)
		[self refreshAutomaticChoiceInfo];
		// Note that we may not modify menuItem's menu (list of items),
		// because list of items is being enumerated at that time!
		// => No (easy) way to do lazy loading of menu items?!

		// Items for non-matching keys are already disabled
		return !usesSymetricEncryption && encryptsMessage;
	} else if (anAction == @selector(gpgChoosePersonalKey:)) {
		// Let's update selected key
		[menuItem setState:([[menuItem representedObject] isEqual:selectedPersonalKey] ? NSOnState:NSOffState)];

		return (usesSymetricEncryption ? NO : signsMessage);
	} else if (anAction == @selector(toggleColumnDisplay:)) {
		return YES;
	} else if (anAction == @selector(gpgToggleEncryptionForNewMessage:)) {
		return YES;
	} else if (anAction == @selector(gpgToggleSignatureForNewMessage:)) {
		return !usesSymetricEncryption;
	} else if (anAction == @selector(gpgToggleUsesOnlyOpenPGPStyle:)) {
		[menuItem setState:(usesOnlyOpenPGPStyle ? NSOnState:NSOffState)];

		return encryptsMessage || signsMessage;
	} else if (anAction == @selector(gpgToggleSymetricEncryption:)) {
		[menuItem setState:(usesSymetricEncryption ? NSOnState:NSOffState)];

		return encryptsMessage;
	}
//    else if(anAction == @selector(changeFromHeader:))
//        return [[self messageEditor] validateMenuItem:menuItem];
	else if (anAction == @selector(gpgDownloadMissingKeys:)) {
		return !usesSymetricEncryption && encryptsMessage;
	} else {
		return NO;
	}
}

- (void)searchKnownPersonsOptions {
	GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];
	NSString *senderEmail = [self senderEmail];

	// Reset everything
	somePeopleWantEncryption = NO;
	somePeopleDontWantEncryption = NO;
	somePeopleWantSigning = NO;
	somePeopleDontWantSigning = NO;
	somePeopleWantMIME = NO;
	somePeopleDontWantMIME = NO;
	[pgpOptionsPerEmail removeAllObjects];

	if (![mailBundle usesABEntriesRules]) {
		return;
	}

	// Look in AB for records matching user names AND having PGP-specific options,
	// set by Robert Goldsmith's ABKeyManager bundle

	if ([ABPerson typeOfProperty:@"GPGOptions"] == kABDictionaryProperty) {
		NSArray *recipients = [self recipients];
		NSEnumerator *anEnum = [recipients objectEnumerator];
		NSString *anEmail;
		NSMutableDictionary *optionDict = [[NSMutableDictionary alloc] initWithCapacity:3];

		// FIXME: We don't support groups!

		// First, compare against cachedRecipients (case-insensitive email)
		while ((anEmail = [anEnum nextObject])) {                         // Email addresses are already normalized
			// FIXME: We don't evaluate sender's email address. Maybe optional.
			if ([anEmail isEqualToString:senderEmail]) {
				continue;
			}

			ABSearchElement *anElement = [ABPerson searchElementForProperty:kABEmailProperty label:nil key:nil value:anEmail comparison:kABEqualCaseInsensitive];
			NSArray *matchingPersons = [[ABAddressBook sharedAddressBook] recordsMatchingSearchElement:anElement];
			NSEnumerator *personEnum = [matchingPersons objectEnumerator];
			ABPerson *aPerson;

			while ((aPerson = [personEnum nextObject])) {
				NSDictionary *aDict = [aPerson valueForProperty:@"GPGOptions"];
				NSNumber *aBoolNumber;

				[optionDict removeAllObjects];
				aBoolNumber = [aDict objectForKey:@"GPGMailSign"];
				if (aBoolNumber) {
					somePeopleWantSigning = somePeopleWantSigning || [aBoolNumber boolValue];
					somePeopleDontWantSigning = somePeopleDontWantSigning || ![aBoolNumber boolValue];
					[optionDict setObject:aBoolNumber forKey:@"sign"];
				}

				aBoolNumber = [aDict objectForKey:@"GPGMailEncrypt"];
				if (aBoolNumber) {
					NSArray *someKeys = [mailBundle keysForSearchPatterns:[NSArray arrayWithObject:anEmail] attributeName:@"normalizedEmail" secretKeys:NO];                                                                 // Returns only valid (for encryption) keys

					// If there is no (valid or not) PGP key for user, ignore option!
					if ([someKeys count] > 0) {
						somePeopleWantEncryption = somePeopleWantEncryption || [aBoolNumber boolValue];
						somePeopleDontWantEncryption = somePeopleDontWantEncryption || ![aBoolNumber boolValue];
						[optionDict setObject:aBoolNumber forKey:@"encrypt"];
					}
				}

				aBoolNumber = [aDict objectForKey:@"GPGMailUseMime"];
				if (aBoolNumber) {
#if 0
					NSArray *someKeys = [mailBundle keysForSearchPatterns:[NSArray arrayWithObject:anEmail] attributeName:@"normalizedEmail" secretKeys:NO];                                                                 // Returns only valid (for encryption) keys

					// If there is no (valid or not) PGP key for user, ignore option!
					// PROBLEM We shouldn't care about keys, when only signing, but at that
					// time we can't know whether message will be encrypted or not.
					if ([someKeys count] > 0) {
						somePeopleWantMIME = somePeopleWantMIME || [aBoolNumber boolValue];
						somePeopleDontWantMIME = somePeopleDontWantMIME || ![aBoolNumber boolValue];
						[optionDict setObject:aBoolNumber forKey:@"mime"];
					}
#else
					somePeopleWantMIME = somePeopleWantMIME || [aBoolNumber boolValue];
					somePeopleDontWantMIME = somePeopleDontWantMIME || ![aBoolNumber boolValue];
					[optionDict setObject:aBoolNumber forKey:@"mime"];
#endif
				}

				if ([optionDict count]) {
					NSDictionary *aDict = [optionDict copy];

					[pgpOptionsPerEmail setObject:aDict forKey:anEmail];                                                             // FIXME: We don't support having multiple AB records for the same email address
					[aDict release];
				}
			}
		}
		[optionDict release];
	}
	// Else, user hasn't used that bundle
}

- (void)textDidEndEditing:(NSNotification *)notification {
	// It is not possible to use NSTextDidChangeNotification or
	// NSControlTextDidChangeNotification because receiver list
	// is not updated before textDidEndEditing.
	// Side-effect: menu and popdown menu are not updated before
	// user moves insertion point out of the To: or CC: (or BCC:)
	// textfields.
	if ([[notification object] window] != [[self composeAccessoryView] window]) {
		return;
	}

#if 0
	[NSRunLoop cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchKnownPersonsOptions) object:nil];
	[self performSelector:@selector(searchKnownPersonsOptions) withObject:nil afterDelay:0.0];

	if ((!encryptsMessage && ![[GPGMailBundle sharedInstance] encryptMessagesWhenPossible]) || usesSymetricEncryption) {
		return;
	}

/*    if(!useCustomPublicKeys){
 *      [NSRunLoop cancelPreviousPerformRequestsWithTarget:self selector:@selector(findMatchingPublicKeysIfNecessary) object:nil];
 *      if(!useCustomPublicKeys && encryptsMessage)
 *          [self performSelector:@selector(findMatchingPublicKeysIfNecessary) withObject:nil afterDelay:0.0]; // Delay is necessary, because we need all objects to be notified first!
 *  }*/
	[NSRunLoop cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshPublicKeysMenu) object:nil];
	[self performSelector:@selector(refreshPublicKeysMenu) withObject:nil afterDelay:0.0];
#else
	[NSRunLoop cancelPreviousPerformRequestsWithTarget:self selector:@selector(evaluateRules) object:nil];
	if (!windowWillClose) {
		[self performSelector:@selector(evaluateRules) withObject:nil afterDelay:0.0];
	}
#endif
}


// TODO: Fix me for libmacgpg
//- (NSString *)context:(GPGContext *)context passphraseForKey:(GPGKey *)key again:(BOOL)again {
//	NSString *passphrase;
//
//	if (again && key != nil) {
//		[GPGPassphraseController flushCachedPassphraseForUser:key];
//	}
//
//	passphrase = [[GPGPassphraseController controller] passphraseForUser:key title:NSLocalizedStringFromTableInBundle(@"MESSAGE_AUTHENTICATION_TITLE", @"GPGMail", [NSBundle bundleForClass:[self class]], "") window:[[self composeAccessoryView] window]];
//
//	return passphrase;
//}

- (NSString *)senderEmail {
	NSString *mailAddress = [[[[self messageEditor] gpgFromPopup] selectedItem] title];
	if (!mailAddress) {
		mailAddress = [[[[self messageEditor] backEnd] account] firstEmailAddress];
	}
	return [mailAddress gpgNormalizedEmail];
}

- (GPGKey *)evaluatedPersonalKey {
	GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];
	GPGKey *evaluatedPersonalKey = nil;

	if ([mailBundle choosesPersonalKeyAccordingToAccount]) {
		NSEnumerator *anEnum = [[personalKeysPopUpButton itemArray] objectEnumerator];
		NSMenuItem *anItem;
		NSString *fromAddress = [self senderEmail];
		BOOL found = NO;
		BOOL filterKeys = [mailBundle filtersOutUnusableKeys];

		while (!found && (anItem = [anEnum nextObject])) {
			// We NEED to check that key is usable too: verifying only userID is not enough.
			// Keys not valid for signature have disabled menu items.
			// See -reloadPersonalKeys
			if ([anItem isEnabled]) {
				NSEnumerator *uidEnum = [[[anItem representedObject] userIDs] objectEnumerator];
				GPGUserID *aUserID;

				while (!found && (aUserID = [uidEnum nextObject])) {
					if (!filterKeys || [mailBundle canUserIDBeUsed:aUserID]) {
						if ([[aUserID normalizedEmail] isEqualToString:fromAddress]) {
							evaluatedPersonalKey = [anItem representedObject];
							found = YES;
						}
					}
				}
			}
		}
	} else {
		evaluatedPersonalKey = selectedPersonalKey;
	}

	return evaluatedPersonalKey;
}

- (void)senderAccountDidChange {
	GPGKey *evaluatedPersonalKey = [self evaluatedPersonalKey];

	if (evaluatedPersonalKey) {
		NSEnumerator *anEnum = [[personalKeysPopUpButton itemArray] objectEnumerator];
		NSMenuItem *anItem;
		BOOL found = NO;

		while (!found && (anItem = [anEnum nextObject])) {
			if ([anItem representedObject] == evaluatedPersonalKey) {
				[personalKeysPopUpButton selectItem:anItem];
				[self choosePersonalKey:personalKeysPopUpButton];
				found = YES;
			}
		}
	}

#if 0
	if (!found) {
		// If there is no matching key for the account, do not sign message
		// unless user explicitly asked to sign
#warning FIXME: Should not modify any encrypt/sign/MIME setting
		if (!explicitlySetSignature && signsMessage) {
			[self doSetSignsMessage:GPGNoSignature];
			explicitlySetSignature = YES;                                         // We do that to avoid our rules to compute signature and override that one
		}
	}
}
#endif
}

- (void)changeFromHeader:(id)sender {
	// Action is forwarded by MessageEditor/HeadersEditor when user changes account
	// BUG: if personalKeysPopUpButton is disabled and user changes account,
	// account popup is displayed as disabled, though it is enabled!
	// The simple _presence_ of our personalKeysPopUpButton is enough to cause the problem:
	// disabling everything in code doesn't solve issue
	[self senderAccountDidChange];
	[self evaluateRules];
	// FIX: restores enabled appearance to popup - seems it doesn't work in all cases
	[self performSelector:@selector(delayedFixPopUp) withObject:nil afterDelay:0];
}

- (void)delayedFixPopUp {
	// FIX: restores enabled appearance to popup
	[[[[self messageEditor] gpgFromPopup] selectedItem] setEnabled:YES];
}

- (void)keyListWasInvalidated:(NSNotification *)notification {
	[self invalidateAllPublicKeys];
	[self reloadPersonalKeys];
	if (selectedPersonalKey == nil) {
		[self senderAccountDidChange];                         // Updates according to account, if option selected
		if (selectedPersonalKey == nil) {
#warning FIXME: Ensure that key may be used
			selectedPersonalKey = [[[GPGMailBundle sharedInstance] defaultKey] retain];
			[selectedPersonalPublicKey release];
			selectedPersonalPublicKey = nil;
		}
	}
//    [self refreshPublicKeysMenu];
	[self evaluateRules];
	if ([[publicKeysOutlineView window] isVisible]) {
		[publicKeysOutlineView reloadData];
	}
}

- (void)preferencesDidChange:(NSNotification *)notification {
	// Do not change current choices (selected personal key, sign/encrypt)
	[self reloadPersonalKeys];             // We reload them, because maybe user changed the way to display them
//    [self refreshPublicKeysMenu]; // We reload them, because maybe user changed the way to display them
	[self evaluateRules];
}


- (BOOL)hasValidSigningKeys {
	return [personalKeysPopUpButton lastItem] != nil;
}

- (IBAction)gpgDownloadMissingKeys:(id)sender {
	[[GPGKeyDownload sharedInstance] searchKeysMatchingPatterns:[missingPublicKeyEmails allObjects]];
}

- (MailDocumentEditor *)messageEditor {
	return [[[self composeAccessoryView] window] delegate];
}

- (IBAction)endConflictResolution:(id)sender {
	int returnCode = [[sender selectedCell] tag];

	if (returnCode == NSOKButton) {
		if ([conflictEncryptionButton state] == NSMixedState || [conflictSignatureButton state] == NSMixedState || [conflictMIMEButton state] == NSMixedState) {
			NSBeep();
			return;
		}
	}

	[[sender window] orderOut:sender];
	[[NSApplication sharedApplication] endSheet:[sender window] returnCode:returnCode];
}

- (void)conflictSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSOKButton) {
		verifyRulesConflicts = NO;
		explicitlySetEncryption = YES;
		explicitlySetSignature = YES;
		explicitlySetOpenPGPStyle = YES;
		[self performSelector:@selector(retryDelivery) withObject:nil afterDelay:0];
	} else {
		verifyRulesConflicts = YES;
	}
}

- (void)resolveRulesConflicts:(id)dummy {
	[conflictTableView reloadData];
	if (!somePeopleDontWantEncryption && encryptsMessage) {
		[conflictEncryptionButton setState:NSOnState];
	} else if (!somePeopleWantEncryption && !encryptsMessage) {
		[conflictEncryptionButton setState:NSOffState];
	} else {
		[conflictEncryptionButton setState:NSMixedState];
	}
	if (!somePeopleDontWantSigning && signsMessage) {
		[conflictSignatureButton setState:NSOnState];
	} else if (!somePeopleWantSigning && !signsMessage) {
		[conflictSignatureButton setState:NSOffState];
	} else {
		[conflictSignatureButton setState:NSMixedState];
	}
	if (!somePeopleDontWantMIME && usesOnlyOpenPGPStyle) {
		[conflictMIMEButton setState:NSOnState];
	} else if (!somePeopleWantMIME && !usesOnlyOpenPGPStyle) {
		[conflictMIMEButton setState:NSOffState];
	} else {
		[conflictMIMEButton setState:NSMixedState];
	}

	[NSApp beginSheet:conflictPanel modalForWindow:[[self composeAccessoryView] window] modalDelegate:self didEndSelector:@selector(conflictSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [[self recipients] count] + 1;             // WARNING Can be invoked before in UI -> no recipients
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
	// FIXME: No support for symmetric encryption!
	// First row is user's choice
	// Then recipients'
	NSString *anIdentifier = [aTableColumn identifier];
	NSBundle *aBundle = [NSBundle bundleForClass:[self class]];

	if (rowIndex == 0) {
		if ([anIdentifier isEqualToString:@"email"]) {
			return NSLocalizedStringFromTableInBundle(@"<ME>", @"GPGMail", aBundle, @"");
		}
		if ([anIdentifier isEqualToString:@"encrypt"]) {
			if (explicitlySetEncryption) {
				return NSLocalizedStringFromTableInBundle((encryptsMessage ? @"<YES>" : @"<NO>"), @"GPGMail", aBundle, @"");
			} else {
				return nil;
			}
		}
		if ([anIdentifier isEqualToString:@"sign"]) {
			if (explicitlySetSignature) {
				return NSLocalizedStringFromTableInBundle((signsMessage ? @"<YES>" : @"<NO>"), @"GPGMail", aBundle, @"");
			} else {
				return nil;
			}
		}
		if ([anIdentifier isEqualToString:@"mime"]) {
			if (explicitlySetOpenPGPStyle) {
				return NSLocalizedStringFromTableInBundle((usesOnlyOpenPGPStyle ? @"<YES>" : @"<NO>"), @"GPGMail", aBundle, @"");
			} else {
				return nil;
			}
		}
		return nil;
	} else {
//            GPGKey          *aKey = [selectedPublicKeys objectAtIndex:(rowIndex - 1)];
//            NSEnumerator    *uidEnum = [[aKey userIDs] objectEnumerator];
		NSString *anEmail = [[self recipients] objectAtIndex:rowIndex - 1];
		NSDictionary *options = [pgpOptionsPerEmail objectForKey:anEmail];
		id aValue;

		if ([anIdentifier isEqualToString:@"email"]) {
			return anEmail;
		} else if ([anIdentifier isEqualToString:@"encrypt"]) {
			aValue = [options objectForKey:@"encrypt"];

			// FIXME: If there is no (valid or not) PGP key for user, ignore option!
			if (aValue) {
				return NSLocalizedStringFromTableInBundle(([aValue boolValue] ? @"<ALWAYS>" : @"<NEVER>"), @"GPGMail", aBundle, @"");
			} else {
				return nil;
			}
		} else if ([anIdentifier isEqualToString:@"sign"]) {
			aValue = [options objectForKey:@"sign"];

			if (aValue) {
				return NSLocalizedStringFromTableInBundle(([aValue boolValue] ? @"<ALWAYS>" : @"<NEVER>"), @"GPGMail", aBundle, @"");
			} else {
				return nil;
			}
		} else if ([anIdentifier isEqualToString:@"mime"]) {
			aValue = [options objectForKey:@"mime"];

			// FIXME: If there is no (valid or not) PGP key for user, ignore option!
			if (aValue) {
				return NSLocalizedStringFromTableInBundle(([aValue boolValue] ? @"<ACCEPTS>" : @"<NEVER>"), @"GPGMail", aBundle, @"");
			} else {
				return nil;
			}
		}
		return nil;
	}
}

- (void)evaluateRules {
	GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];
	BOOL willEncrypt = NO;
	BOOL willSign = NO;
	BOOL willUseMIME = NO;
	BOOL warnOnMissingKeys = NO;
	BOOL logging = (GPGMailLoggingLevel > 0);

	if (logging) {
		NSLog(@"[DEBUG] evaluateRules:");
	}
	needsWarning = NO;
	signatureTurnedOnBecauseEncrypted = NO;
	[self searchKnownPersonsOptions];             // This sets the somePeople* and pgpOptionsPerEmail ivars

	if (explicitlySetEncryption) {
		willEncrypt = encryptsMessage;            // Respect user's choice
		if (logging) {
			NSLog(@"explicitlySetEncryption: willEncrypt = %@", (willEncrypt ? @"YES" : @"NO"));
		}
		if (willEncrypt && !usesSymetricEncryption && !useCustomPublicKeys) {
			[self findMatchingPublicKeys];
			warnOnMissingKeys = YES;
			if (logging) {
				NSLog(@"willEncrypt && !usesSymetricEncryption && !useCustomPublicKeys: warnOnMissingKeys = %@", (warnOnMissingKeys ? @"YES" : @"NO"));
			}
		}
	} else {
		willEncrypt = [mailBundle alwaysEncryptMessages];
		if (logging) {
			NSLog(@"!explicitlySetEncryption: willEncrypt = alwaysEncryptMessages = %@", (willEncrypt ? @"YES" : @"NO"));
		}

		if (replyOptions) {
			NSNumber *aNumber = [replyOptions objectForKey:@"encrypted"];

			if (aNumber && [aNumber boolValue] && [mailBundle encryptsReplyToEncryptedMessage]) {
				willEncrypt = YES;
				if (logging) {
					NSLog(@"replyOptions - was encrypted && encryptsReplyToEncryptedMessage: willEncrypt = %@", (willEncrypt ? @"YES" : @"NO"));
				}
			}
		}

		if (!usesSymetricEncryption && !useCustomPublicKeys) {
			[self findMatchingPublicKeys];
		}

		if (willEncrypt) {
			// If not all people have valid key, willEncrypt = NO
			if (!useCustomPublicKeys) {
				if ([missingPublicKeyEmails count] != 0) {
					if ([mailBundle encryptMessagesWhenPossible]) {
						willEncrypt = NO;
					} else if (!usesSymetricEncryption) {
						warnOnMissingKeys = YES;
					}
					if (logging) {
						NSLog(@"willEncrypt - !useCustomPublicKeys && missingPublicKeyEmails.count > 0 && encryptMessagesWhenPossible: willEncrypt = %@", (willEncrypt ? @"YES" : @"NO"));
						NSLog(@"willEncrypt - !useCustomPublicKeys && missingPublicKeyEmails.count > 0 && (!encryptMessagesWhenPossible && !usesSymetricEncryption): warnOnMissingKeys = %@", (warnOnMissingKeys ? @"YES" : @"NO"));
					}
				}
			}
		} else if ([mailBundle encryptMessagesWhenPossible]) {
			// Apply encryption only when at least one recipient
			if ((useCustomPublicKeys || [missingPublicKeyEmails count] == 0) && [[self recipients] count] > 0) {
				willEncrypt = YES;
				if (!usesSymetricEncryption) {
					warnOnMissingKeys = YES;
				}
				if (logging) {
					NSLog(@"!willEncrypt && encryptMessagesWhenPossible - !useCustomPublicKeys && missingPublicKeyEmails.count == 0 && recipients.count > 0: willEncrypt = %@", (willEncrypt ? @"YES" : @"NO"));
					NSLog(@"!willEncrypt && encryptMessagesWhenPossible - !useCustomPublicKeys && missingPublicKeyEmails.count == 0 && recipients.count > 0 && !usesSymetricEncryption: warnOnMissingKeys = %@", (warnOnMissingKeys ? @"YES" : @"NO"));
				}
			}
		}

		if (somePeopleWantEncryption) {
			willEncrypt = YES;
			if (!usesSymetricEncryption && !useCustomPublicKeys) {
				warnOnMissingKeys = YES;
			}
			if (logging) {
				NSLog(@"somePeopleWantEncryption: willEncrypt = %@", (willEncrypt ? @"YES" : @"NO"));
				NSLog(@"somePeopleWantEncryption && !usesSymetricEncryption && !useCustomPublicKeys: warnOnMissingKeys = %@", (warnOnMissingKeys ? @"YES" : @"NO"));
			}
		}
		if (somePeopleDontWantEncryption) {
			willEncrypt = NO;
			warnOnMissingKeys = NO;
			if (logging) {
				NSLog(@"somePeopleDontWantEncryption: willEncrypt = %@", (willEncrypt ? @"YES" : @"NO"));
				NSLog(@"somePeopleDontWantEncryption: warnOnMissingKeys = %@", (warnOnMissingKeys ? @"YES" : @"NO"));
			}
		}
	}

	if (warnOnMissingKeys) {
		if ([missingPublicKeyEmails count] != 0) {
			needsWarning = YES;
			if (logging) {
				NSLog(@"warnOnMissingKeys && missingPublicKeyEmails.count > 0: needsWarning = %@", (needsWarning ? @"YES" : @"NO"));
			}
		}
	}

	// Currently we disable signing when using symmetrical encryption
	// FIXME: Should we allow signature?
	if (usesSymetricEncryption) {
		willSign = NO;
		if (logging) {
			NSLog(@"usesSymetricEncryption: willSign = %@", (willSign ? @"YES" : @"NO"));
		}
	} else if (explicitlySetSignature) {
		willSign = signsMessage;                             // Respect user's choice
		if (logging) {
			NSLog(@"explicitlySetSignature: willSign = signsMessage = %@", (willSign ? @"YES" : @"NO"));
		}
	} else {
		if (willEncrypt && [mailBundle signWhenEncrypting]) {
			willSign = YES;
			signatureTurnedOnBecauseEncrypted = YES;             // FIXME: No longer used
			if (logging) {
				NSLog(@"willEncrypt && signWhenEncrypting: willSign = %@", (willSign ? @"YES" : @"NO"));
			}
		}
		willSign = willSign || [mailBundle alwaysSignMessages];
		if (logging) {
			NSLog(@"willSign || alwaysSignMessages: willSign = %@", (willSign ? @"YES" : @"NO"));
		}

		if (replyOptions) {
			NSNumber *aNumber = [replyOptions objectForKey:@"signed"];

			if (aNumber && [aNumber boolValue] && [mailBundle signsReplyToSignedMessage]) {
				willSign = YES;
				if (logging) {
					NSLog(@"replyOptions: signed && signsReplyToSignedMessage: willSign = %@", (willSign ? @"YES" : @"NO"));
				}
			}
		}

		if (somePeopleWantSigning) {
			willSign = YES;
			if (logging) {
				NSLog(@"somePeopleWantSigning: willSign = %@", (willSign ? @"YES" : @"NO"));
			}
		}
		if (somePeopleDontWantSigning) {
			willSign = NO;
			if (logging) {
				NSLog(@"somePeopleDontWantSigning: willSign = %@", (willSign ? @"YES" : @"NO"));
			}
		}

		// If there is no matching key for the account, do not sign message
		if ([mailBundle choosesPersonalKeyAccordingToAccount]) {
			GPGKey *evaluatedPersonalKey = [self evaluatedPersonalKey];

			if (evaluatedPersonalKey == nil) {
				willSign = NO;
				if (logging) {
					NSLog(@"choosesPersonalKeyAccordingToAccount && evaluatedPersonalKey == nil: willSign = %@", (willSign ? @"YES" : @"NO"));
				}
				if (!explicitlySetEncryption) {
					willEncrypt = NO;
					if (logging) {
						NSLog(@"choosesPersonalKeyAccordingToAccount && evaluatedPersonalKey == nil && !explicitlySetEncryption: willEncrypt = %@", (willEncrypt ? @"YES" : @"NO"));
					}
				}
			}
		}
	}

	if (explicitlySetOpenPGPStyle) {
		willUseMIME = usesOnlyOpenPGPStyle;                         // Respect user's choice
		if (logging) {
			NSLog(@"explicitlySetOpenPGPStyle: willUseMIME = usesOnlyOpenPGPStyle = %@", (willUseMIME ? @"YES" : @"NO"));
		}
	} else {
		willUseMIME = [mailBundle usesOnlyOpenPGPStyle];
		if (logging) {
			NSLog(@"!explicitlySetOpenPGPStyle: willUseMIME = usesOnlyOpenPGPStyle = %@", (willUseMIME ? @"YES" : @"NO"));
		}

		if (replyOptions) {
			// TODO: We don't use that information for the moment
		}

		if (somePeopleWantMIME) {
			willUseMIME = YES;
			if (logging) {
				NSLog(@"somePeopleWantMIME: willUseMIME = %@", (willUseMIME ? @"YES" : @"NO"));
			}
		}
		if (somePeopleDontWantMIME) {
			willUseMIME = NO;
			if (logging) {
				NSLog(@"somePeopleDontWantMIME: willUseMIME = %@", (willUseMIME ? @"YES" : @"NO"));
			}
		}
	}

	if (logging) {
		NSLog(@"RESULTS: willEncrypt = %@, willSign = %@, willUseMIME = %@", (willEncrypt ? @"YES" : @"NO"), (willSign ? @"YES" : @"NO"), (willUseMIME ? @"YES" : @"NO"));
	}
	[self doSetEncryptsMessage:willEncrypt];
	[self doSetSignsMessage:willSign];
	[self setUsesOnlyOpenPGPStyle:willUseMIME];
	[self refreshAutomaticChoiceInfo];
	[self refreshPublicKeysMenu];
	[self updateWarningImage];             // Warning only when encrypting and missing keys
}

@end
