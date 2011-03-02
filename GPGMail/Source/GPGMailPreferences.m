/* GPGMailPreferences.m created by dave on Thu 29-Jun-2000 */

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

#import "GPGMailPreferences.h"
#import <Sparkle/Sparkle.h>
#import "GPGMailBundle.h"
#import "GPG.subproj/GPGPassphraseController.h"
#import "GPGDefaults.h"

@implementation GPGMailPreferences

- (GPGMailBundle *)bundle {
	return [GPGMailBundle sharedInstance];
}

- (SUUpdater *)updater {
	return [SUUpdater updaterForBundle:[NSBundle bundleForClass:[self class]]];
}


- (NSString *)copyright {
	return [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"NSHumanReadableCopyright"];
}

- (NSAttributedString *)credits {
	NSBundle *mailBundle = [NSBundle bundleForClass:[self class]];
	NSAttributedString *credits = [[[NSAttributedString alloc] initWithURL:[mailBundle URLForResource:@"Credits" withExtension:@"rtf"] documentAttributes:nil] autorelease];

	return credits;
}

- (NSAttributedString *)websiteLink {
	NSMutableParagraphStyle *pStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];

	[pStyle setAlignment:NSRightTextAlignment];

	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								pStyle, NSParagraphStyleAttributeName,
								@"http://www.gpgtools.org/", NSLinkAttributeName,
								[NSColor blueColor], NSForegroundColorAttributeName,
								[NSFont fontWithName:@"Lucida Grande" size:9], NSFontAttributeName,
								[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName,
								nil];

	return [[[NSAttributedString alloc] initWithString:@"http://www.gpgtools.org" attributes:attributes] autorelease];
}



- (void)refreshKeyIdentifiersDisplay {
	GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];
	NSEnumerator *anEnum;                    // = [[mailBundle allDisplayedKeyIdentifiers] objectEnumerator];
	NSString *anIdentifier;
	NSEnumerator *tableColumnEnum = [[NSArray arrayWithArray:[keyIdentifiersTableView tableColumns]] objectEnumerator];
	NSTableColumn *aColumn;

	while (aColumn = [tableColumnEnum nextObject])
		[keyIdentifiersTableView removeTableColumn:aColumn];

	anEnum = [[mailBundle displayedKeyIdentifiers] objectEnumerator];
	while (anIdentifier = [anEnum nextObject])
		[keyIdentifiersTableView addTableColumn:[tableColumnPerIdentifier objectForKey:anIdentifier]];
	[keyIdentifiersTableView sizeToFit];             // No effect...
	[mailBundle refreshKeyIdentifiersDisplayInMenu:[keyIdentifiersPopUpButton menu]];
}

- (void)refreshPersonalKeys {
	GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];
	NSEnumerator *keyEnum = [[mailBundle personalKeys] objectEnumerator];
	GPGKey *aKey;
	NSString *defaultKeyFingerprint = [[mailBundle defaultKey] fingerprint];
	BOOL displaysAllUserIDs = [mailBundle displaysAllUserIDs];

	[personalKeysPopUpButton removeAllItems];
	while (aKey = [keyEnum nextObject]) {
		NSMenuItem *anItem;

		[personalKeysPopUpButton addItemWithTitle:[mailBundle menuItemTitleForKey:aKey]];
		anItem = [personalKeysPopUpButton lastItem];
		[anItem setRepresentedObject:aKey];
		if (defaultKeyFingerprint && [[aKey fingerprint] isEqualToString:defaultKeyFingerprint]) {
			[personalKeysPopUpButton selectItem:anItem];
		}
		if (displaysAllUserIDs) {
			NSEnumerator *userIDEnum = [[mailBundle secondaryUserIDsForKey:aKey] objectEnumerator];
			GPGUserID *aUserID;

			while (aUserID = [userIDEnum nextObject]) {
				[personalKeysPopUpButton addItemWithTitle:[mailBundle menuItemTitleForUserID:aUserID indent:1]];
				[[personalKeysPopUpButton lastItem] setEnabled:NO];
			}
		}
	}
}

- (NSImage *)imageForPreferenceNamed:(NSString *)aName {
	return [NSImage imageNamed:@"GPGMailPreferences"];
}


- (IBAction)toggleAlwaysEncryptMessages:(id)sender {
	[[GPGMailBundle sharedInstance] setAlwaysEncryptMessages:([sender state] == NSOnState)];
}

- (IBAction)changeDefaultKey:(id)sender {
	[[GPGMailBundle sharedInstance] setDefaultKey:[[personalKeysPopUpButton selectedItem] representedObject]];
}

- (IBAction)toggleShowKeyInformation:(id)sender {
	[[GPGMailBundle sharedInstance] gpgToggleShowKeyInformation:sender];
}


- (int)numberOfRowsInTableView:(NSTableView *)tableView {
	return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	return nil;
}

- (void)tableViewColumnDidMove:(NSNotification *)notification {
	if (!initializingPrefs) {
		GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];
		NSMutableArray *anArray = [NSMutableArray arrayWithArray:[mailBundle displayedKeyIdentifiers]];
		int anIndex = [[[notification userInfo] objectForKey:@"NSOldColumn"] intValue];
		id anObject = [[anArray objectAtIndex:anIndex] retain];

		[anArray removeObjectAtIndex:anIndex];
		anIndex = [[[notification userInfo] objectForKey:@"NSNewColumn"] intValue];
		[anArray insertObject:anObject atIndex:anIndex];
		[anObject release];
		[mailBundle setDisplayedKeyIdentifiers:anArray];
		[self refreshKeyIdentifiersDisplay];
		[self refreshPersonalKeys];
	}
}


- (id)init {
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyListWasInvalidated:) name:GPGKeyListWasInvalidatedNotification object:[GPGMailBundle sharedInstance]];
	}

	return self;
}

- (void)dealloc {
	[tableColumnPerIdentifier release];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GPGPreferencesDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GPGKeyListWasInvalidatedNotification object:nil];

	[super dealloc];
}

- (void)keyListWasInvalidated:(NSNotification *)notification {
	[self refreshPersonalKeys];
}

- (void)awakeFromNib {
	NSEnumerator *anEnum = [[keyIdentifiersTableView tableColumns] objectEnumerator];
	NSTableColumn *aColumn;


	tableColumnPerIdentifier = [[NSMutableDictionary alloc] init];
	[personalKeysPopUpButton setAutoenablesItems:NO];

	while (aColumn = [anEnum nextObject])
		[tableColumnPerIdentifier setObject:aColumn forKey:[aColumn identifier]];
	[keyIdentifiersTableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];

	// Since 10.5, we can no longer reorder column when tableView data height is null.
	// As a workaround, we add 1 pixel.
	// FIXME: replace that tableView by NSTokenField
	NSRect aFrame = [[keyIdentifiersTableView enclosingScrollView] frame];

	aFrame.origin.y -= 1;
	aFrame.size.height += 1;
	[[keyIdentifiersTableView enclosingScrollView] setFrame:aFrame];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesDidChange:) name:GPGPreferencesDidChangeNotification object:[GPGMailBundle sharedInstance]];
}

- (void)initializeFromDefaults {
	initializingPrefs = YES;

	[super initializeFromDefaults];
	[self refreshPersonalKeys];
	[self refreshKeyIdentifiersDisplay];

	initializingPrefs = NO;
}

- (IBAction)flushCachedPassphrases:(id)sender {
	[GPGPassphraseController flushCachedPassphrases];
	[GPGAgentOptions gpgAgentFlush];
}

- (void)preferencesDidChange:(NSNotification *)notification {
	NSString *aKey = [[notification userInfo] objectForKey:@"key"];

	if ([aKey isEqualToString:@"displaysAllUserIDs"]) {
		[self refreshPersonalKeys];
	} else if ([aKey isEqualToString:@"displayedKeyIdentifiers"]) {
		[self refreshKeyIdentifiersDisplay];
		[self refreshPersonalKeys];
	} else if ([aKey isEqualToString:@"filtersOutUnusableKeys"]) {
		[self refreshPersonalKeys];
	}
}

- (IBAction)refreshKeys:(id)sender {
	[[GPGMailBundle sharedInstance] gpgReloadPGPKeys:sender];
	[sender setState:NSOffState];
}

@end

