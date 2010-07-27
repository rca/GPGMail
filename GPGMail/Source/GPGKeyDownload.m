/* GPGKeyDownload.m created by dave on Sat 23-Aug-2004 */

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

#import "GPGKeyDownload.h"
#import "GPGMEAdditions.h"


NSString	*GPGDidFindKeysNotification = @"GPGDidFindKeysNotification";


@implementation GPGKeyDownload

static GPGKeyDownload	*_sharedInstance = nil;

+ (void) load
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(missingKeysNotification:) name:GPGMissingKeysNotification object:nil];
}

+ (id) sharedInstance
{
    if(_sharedInstance == nil){
        _sharedInstance = [[self alloc] initWithWindowNibName:@"GPGKeyDownload"];
    }

    return _sharedInstance;
}

- (id) initWithWindowNibName:(NSString *)windowNibName
{
    if(self = [super initWithWindowNibName:windowNibName]){
        selectedKeys = [[NSMutableSet alloc] init];
        [self setWindowFrameAutosaveName:@"GPGKeySearch"];
        validEmailAddressCharset = [[NSMutableCharacterSet alphanumericCharacterSet] retain];
        [validEmailAddressCharset addCharactersInString:@"@_-."]; // FIXME: there are much more valid chars - maybe we shouldn't try to validate
        defaultServerList = [[NSArray alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"KeyServers" ofType:@"plist"]];
    }

    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GPGAsynchronousOperationDidTerminateNotification object:context];
    [context release];
    [selectedKeys release];
    [foundKeys release];
    [validEmailAddressCharset release];
    [defaultServerList release];

    [super dealloc];
}

- (void) refreshServerList
{
    GPGOptions      *options = [[GPGOptions alloc] init];
    NSString		*currentServer = [[serverComboBox stringValue] copy];
    unsigned		anIndex;
    NSMutableArray	*aList;
    NSEnumerator	*anEnum = [defaultServerList objectEnumerator];
    NSString		*aServer;

    [serverList release];
    aList = [[options allOptionValuesForName:@"keyserver"] mutableCopy];
    while(aServer = [anEnum nextObject]){
        if(![aList containsObject:aServer])
            [aList addObject:aServer];
    }
    serverList = aList;
    if([currentServer length] == 0){
        [currentServer release];
        currentServer = [[options activeOptionValuesForName:@"keyserver"] lastObject];
        if(!currentServer)
            currentServer = @"";
        [currentServer retain];
    }
    [serverComboBox reloadData];
    [serverComboBox setStringValue:currentServer];
    anIndex = [serverList indexOfObject:currentServer];
    if(anIndex != NSNotFound)
        [serverComboBox selectItemAtIndex:anIndex];
    [currentServer release];
    [options release];
}

- (void) windowDidLoad
{
    NSBundle    *aBundle = [NSBundle bundleForClass:[self class]];
    
    context = [[GPGContext alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(operationDidTerminate:) name:GPGAsynchronousOperationDidTerminateNotification object:context];
    
    [searchButton setTitle:NSLocalizedStringFromTableInBundle(@"SEARCH", @"GPGMail", aBundle, "")];
    [searchProgressField setStringValue:@""];
//    [importButton setTitle:NSLocalizedStringFromTableInBundle(@"DOWNLOAD", @"GPGMail", aBundle, "")];
    [titleField setStringValue:NSLocalizedStringFromTableInBundle(@"SEARCH_KEYS_ON_SERVER", @"GPGMail", aBundle, "")];
    [searchProgressIndicator setStyle:NSProgressIndicatorSpinningStyle];
    [searchProgressIndicator setDisplayedWhenStopped:NO];
    [importProgressIndicator setStyle:NSProgressIndicatorSpinningStyle];
    [importProgressIndicator setDisplayedWhenStopped:NO];
    [importProgressField setStringValue:@""];
    [tabView selectLastTabViewItem:nil];
    [self refreshServerList];

    [super windowDidLoad];
}

- (IBAction) gpgSearchKeys:(id)sender
{
    [self refreshServerList];
    [self showWindow:sender];
}

- (IBAction) cancel:(id)sender
{
    [titleField setStringValue:NSLocalizedStringFromTableInBundle(@"SEARCH_KEYS_ON_SERVER", @"GPGMail", [NSBundle bundleForClass:[self class]], "")];
    [tabView selectLastTabViewItem:nil];
    if(isSearching || isImporting){
        cancelled = YES;
        [emailCell setEnabled:NO];
        [serverComboBox setEnabled:NO];
        [searchButton setEnabled:NO];
        [context interruptAsyncOperation];
    }
    else
        cancelled = NO;
}

- (NSDictionary *) options
{
    NSString	*selectedServer = [serverComboBox stringValue];

    if([selectedServer rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]].length > 0)
        return [NSDictionary dictionaryWithObject:selectedServer forKey:@"keyserver"];
    else
        return nil;
}

- (IBAction) import:(id)sender
{
    NSDictionary	*options = [self options];

    if(!options || ([selectedKeys count] == 0))
        NSBeep();
    else{
        NSBundle	*aBundle = [NSBundle bundleForClass:[self class]];

//        [titleField setStringValue:NSLocalizedStringFromTableInBundle(@"DOWNLOAD_KEYS_FROM_SERVER", @"GPGMail", aBundle, "")];
//        [importButton setTitle:NSLocalizedStringFromTableInBundle(@"DOWNLOADING", @"GPGMail", aBundle, "")];
        [importProgressField setStringValue:NSLocalizedStringFromTableInBundle(@"DOWNLOADING", @"GPGMail", aBundle, "")];
        [importButton setEnabled:NO];
        [importProgressIndicator startAnimation:nil];
        isImporting = YES;

        [context asyncDownloadKeys:[selectedKeys allObjects] serverOptions:options];
    }
}

- (void) doSearchKeysMatchingPatterns:(NSArray *)patterns
{
    NSDictionary	*options = [self options];

    if(!options)
        NSBeep();
    else{
        NSBundle	*aBundle = [NSBundle bundleForClass:[self class]];

        [titleField setStringValue:NSLocalizedStringFromTableInBundle(@"SEARCH_KEYS_ON_SERVER", @"GPGMail", aBundle, "")];
        [emailCell setEnabled:NO];
        [serverComboBox setEnabled:NO];
        [searchButton setTitle:NSLocalizedStringFromTableInBundle(@"CANCEL_SEARCH", @"GPGMail", aBundle, "")];
        [searchButton setAction:@selector(cancelSearch:)];
        [searchProgressField setStringValue:NSLocalizedStringFromTableInBundle(@"SEARCHING", @"GPGMail", aBundle, "")];
//        [searchButton setEnabled:NO];
        [searchProgressIndicator startAnimation:nil];
        isSearching = YES;

        [context asyncSearchForKeysMatchingPatterns:patterns serverOptions:options];
    }
}

- (IBAction) cancelSearch:(id)sender
{
    NSBundle	*aBundle = [NSBundle bundleForClass:[self class]];

    [emailCell setEnabled:YES];
    [serverComboBox setEnabled:YES];
    [searchButton setTitle:NSLocalizedStringFromTableInBundle(@"SEARCH", @"GPGMail", aBundle, "")];
    [searchButton setAction:@selector(search:)];
    [searchProgressField setStringValue:@""];
    //        [searchButton setEnabled:NO];
    [searchProgressIndicator stopAnimation:nil];
    isSearching = NO;
    cancelled = YES;

    [context interruptAsyncOperation];
}

- (IBAction) search:(id)sender
{
    NSEnumerator	*anEnum = [[[emailCell stringValue] componentsSeparatedByString:@","] objectEnumerator];
    NSString		*aString;
    NSMutableArray	*patterns = [NSMutableArray array];

    while(aString = [anEnum nextObject]){
        // We trim space characters
        NSRange startRange = [aString rangeOfCharacterFromSet:validEmailAddressCharset];
        
        if(startRange.location != NSNotFound){
            NSRange endRange = [aString rangeOfCharacterFromSet:validEmailAddressCharset options:NSBackwardsSearch];
            
            aString = [aString substringWithRange:NSMakeRange(startRange.location, (endRange.location + 1) - startRange.location)];
            [patterns addObject:aString];
        }
    }

    if([patterns count] > 0)
        [self doSearchKeysMatchingPatterns:patterns];
    else
        NSBeep();
}

- (void) searchKeysMatchingPatterns:(NSArray *)patterns
{
    [self showWindow:nil];
    if(isSearching || isImporting)
        NSBeep();
    else{
        [emailCell setStringValue:[patterns componentsJoinedByString:@", "]];
        [titleField setStringValue:NSLocalizedStringFromTableInBundle(@"SEARCH_KEYS_ON_SERVER", @"GPGMail", [NSBundle bundleForClass:[self class]], "")];
        [tabView selectLastTabViewItem:nil];
        if([patterns count])
            [self doSearchKeysMatchingPatterns:patterns];
    }
}

- (void) foundKeys:(NSNotification *)notification
{
    NSBundle        *aBundle = [NSBundle bundleForClass:[self class]];
    GPGMailBundle   *mailBundle = [GPGMailBundle sharedInstance];
    
    [searchProgressIndicator stopAnimation:nil];
    [emailCell setEnabled:YES];
    [serverComboBox setEnabled:YES];
    [searchButton setTitle:NSLocalizedStringFromTableInBundle(@"SEARCH", @"GPGMail", aBundle, "")];
    [searchButton setAction:@selector(search:)];
    [searchProgressField setStringValue:@""];

    if(!cancelled){
        GPGError	anError = [[[notification userInfo] objectForKey:GPGErrorKey] intValue];

        [self showWindow:nil];
        if(anError != GPGErrorNoError){
            NSString    *errorMessage;
            
            if([mailBundle gpgErrorCodeFromError:anError] == GPGErrorKeyServerError){
                NSString    *additionalMessage = [[notification userInfo] objectForKey:GPGAdditionalReasonKey];

                if(additionalMessage != nil){
                    errorMessage = additionalMessage; // FIXME: Not localized
                }
                else
                    errorMessage = [mailBundle descriptionForError:anError];
            }
            else
                errorMessage = [mailBundle descriptionForError:anError];
            
            NSBeginAlertSheet(NSLocalizedStringFromTableInBundle(@"SEARCH_ERROR", @"GPGMail", aBundle, ""), nil, nil, nil, [self window], nil, NULL, NULL, NULL, @"%@", errorMessage);
        }
        else{
            NSDictionary	*aDict = [[notification object] operationResults];

            [foundKeys release];
            foundKeys = nil;
            [selectedKeys removeAllObjects];
            if([[aDict objectForKey:@"keys"] lastObject] == nil){
                [searchProgressField setStringValue:NSLocalizedStringFromTableInBundle(@"NO_MATCHING_KEYS", @"GPGMail", aBundle, "")];
                [outlineView reloadData];
            }
            else{
                NSEnumerator	*anEnum;
                GPGRemoteKey	*anItem;

                foundKeys = [[aDict objectForKey:@"keys"] retain];
                anEnum = [foundKeys objectEnumerator];
                while(anItem = [anEnum nextObject]){
                    // Don't add revoked/disabled/expired/invalid keys
                    if(![anItem hasKeyExpired] && ![anItem isKeyRevoked]/* && ![anItem isKeyInvalid] && ![anItem isKeyDisabled]*/)
                        [selectedKeys addObject:anItem];
                }
                [outlineView reloadData];
                anEnum = [foundKeys objectEnumerator];
                while(anItem = [anEnum nextObject])
                    [outlineView expandItem:anItem];
                [importButton setEnabled:([selectedKeys count] > 0)];
                [importProgressField setStringValue:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"FOUND_%d_KEYS", @"GPGMail", aBundle, ""), [foundKeys count]]];
                [titleField setStringValue:NSLocalizedStringFromTableInBundle(@"DOWNLOAD_KEYS_FROM_SERVER", @"GPGMail", aBundle, "")];
                [tabView selectFirstTabViewItem:nil];
            }
        }
    }
    else{
//        NSLog(@"$$$ Interrupted: %@", [notification userInfo]);
    }

    isSearching = NO;
    cancelled = NO;
}

- (void) downloadedKeys:(NSNotification *)notification
{
    // TODO: Show more information (optional) to user (signatures, etc.) in a summary drawer?
    NSBundle	*aBundle = [NSBundle bundleForClass:[self class]];
    
    [importProgressIndicator stopAnimation:nil];
    [importButton setEnabled:YES];
    [importProgressField setStringValue:@""];
//    [importButton setTitle:NSLocalizedStringFromTableInBundle(@"DOWNLOADING", @"GPGMail", aBundle, "")];
    [titleField setStringValue:NSLocalizedStringFromTableInBundle(@"SEARCH_KEYS_ON_SERVER", @"GPGMail", aBundle, "")];
    isImporting = NO;
    
    [foundKeys release];
    foundKeys = nil;
    [outlineView reloadData];

    [titleField setStringValue:NSLocalizedStringFromTableInBundle(@"SEARCH_KEYS_ON_SERVER", @"GPGMail", aBundle, "")];
    [tabView selectLastTabViewItem:nil];

    if(!cancelled){
        GPGError	anError = [[[notification userInfo] objectForKey:GPGErrorKey] intValue];

        if(anError != GPGErrorNoError){
            [self showWindow:nil];
            // FIXME: In MacGPGME, get real error message from stderr
            NSBeginAlertSheet(NSLocalizedStringFromTableInBundle(@"DOWNLOAD_ERROR", @"GPGMail", aBundle, ""), nil, nil, nil, [self window], nil, NULL, NULL, NULL, @"%@", [[GPGMailBundle sharedInstance] descriptionForError:anError]);
        }
        else{
            [searchProgressField setStringValue:NSLocalizedStringFromTableInBundle(@"DOWNLOADED", @"GPGMail", aBundle, "")];
            [[GPGMailBundle sharedInstance] gpgReloadPGPKeys:nil];
        }
    }
    else{
//        NSLog(@"$$$ Interrupted: %@", [notification userInfo]);
        [emailCell setEnabled:YES];
        [serverComboBox setEnabled:YES];
        [searchButton setEnabled:YES];
    }
    cancelled = NO;
}

- (void) operationDidTerminate:(NSNotification *)notification
{
    if(isSearching)
        [self foundKeys:notification];
    else
        [self downloadedKeys:notification];
}

- (int) numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return [serverList count];
}

- (id) comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(int)index
{
    if(index < 0 || index >= [serverList count]) {
        NSLog(@"[DEBUG] [GPGKeyDownload comboBox:objectValueForItemAtIndex:] - This shouldn't happen! NEVER!");
        return nil;
    }
    return [serverList objectAtIndex:index];
}

//- (unsigned int) comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string

//- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)string;

- (id) outlineView:(NSOutlineView *)theOutlineView child:(int)index ofItem:(id)item
{
    if(item == nil)
        return [foundKeys objectAtIndex:index];
    else
        return [[item userIDs] objectAtIndex:index];
}

- (BOOL) outlineView:(NSOutlineView *)theOutlineView isItemExpandable:(id)item
{
    return [item canHaveChildren];
}

- (int) outlineView:(NSOutlineView *)theOutlineView numberOfChildrenOfItem:(id)item
{
    if(item == nil)
        return [foundKeys count];
    else
        return [[item userIDs] count];
}

- (id) outlineView:(NSOutlineView *)theOutlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    // TODO: Use custom cells to display key and info
    if([[tableColumn identifier] isEqualToString:@"selection"])
        return [NSNumber numberWithBool:[selectedKeys containsObject:item]];
    else if([item canHaveChildren]){
        NSString		*resultString = [NSString stringWithFormat:@"0x%@", [item keyID]];
        NSString		*aString = [item algorithmDescription];
        NSCalendarDate	*aDate;
        NSBundle		*aBundle = [NSBundle bundleForClass:[self class]];

        if(aString){
            unsigned	aLength = [(GPGKey *)item length];
            
            resultString = [resultString stringByAppendingFormat:@", %@", aString];
            if(aLength > 0)
                resultString = [resultString stringByAppendingFormat:NSLocalizedStringFromTableInBundle(@" (%u bits)", @"GPGMail", aBundle, ""), aLength];
        }
        aDate = [item creationDate];
        if(aDate)
            resultString = [resultString stringByAppendingFormat:NSLocalizedStringFromTableInBundle(@", created on %@", @"GPGMail", aBundle, ""), [aDate descriptionWithCalendarFormat:NSLocalizedStringFromTableInBundle(@"SIGNATURE_CREATION_DATE_FORMAT", @"GPGMail", aBundle, "") locale:[(GPGMailBundle *)[GPGMailBundle sharedInstance] locale]]];
        aDate = [item expirationDate];
        if(aDate){
            if([item hasKeyExpired])
                resultString = [resultString stringByAppendingFormat:NSLocalizedStringFromTableInBundle(@", expired on %@", @"GPGMail", aBundle, ""), [aDate descriptionWithCalendarFormat:NSLocalizedStringFromTableInBundle(@"SIGNATURE_EXPIRATION_DATE_FORMAT", @"GPGMail", aBundle, "") locale:[(GPGMailBundle *)[GPGMailBundle sharedInstance] locale]]];
            else
                resultString = [resultString stringByAppendingFormat:NSLocalizedStringFromTableInBundle(@", expires on %@", @"GPGMail", aBundle, ""), [aDate descriptionWithCalendarFormat:NSLocalizedStringFromTableInBundle(@"SIGNATURE_EXPIRATION_DATE_FORMAT", @"GPGMail", aBundle, "") locale:[(GPGMailBundle *)[GPGMailBundle sharedInstance] locale]]];
        }
        if([item isKeyRevoked])
            resultString = [NSLocalizedStringFromTableInBundle(@"REVOKED_KEY - ", @"GPGMail", aBundle, "") stringByAppendingString:resultString];
        
        if([item hasKeyExpired] || [item isKeyRevoked]/* || [item isKeyInvalid] || [item isKeyDisabled]*/)
            // TODO: Prefix with warning icon
            return [[[NSAttributedString alloc] initWithString:resultString attributes:[NSDictionary dictionaryWithObject:[NSColor redColor] forKey:NSForegroundColorAttributeName]] autorelease];
        else
            return resultString;
    }
    else{
        return [item userID];
    }
}

- (void) outlineView:(NSOutlineView *)theOutlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if(isImporting){
    }
    else{
        if([object intValue])
            [selectedKeys addObject:item];
        else
            [selectedKeys removeObject:item];
    }
}

- (void) outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    [cell setEnabled:!isImporting];
}

#if defined(SNOW_LEOPARD) || defined(LEOPARD) || defined(TIGER)
// Not necessary on 10.3; on Tiger the switch cell is displayed!
- (void)outlineView:(NSOutlineView *)ov willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	if([[tableColumn identifier] isEqualToString:@"selection"])
		[cell setImagePosition:([self outlineView:ov isItemExpandable:item] ? NSImageOnly : NSNoImage)];
}

- (NSString *)outlineView:(NSOutlineView *)ov toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tc item:(id)item mouseLocation:(NSPoint)mouseLocation
{
	// Available only since Tiger
	if([[tc identifier] isEqualToString:@"description"])
		return [self outlineView:ov objectValueForTableColumn:tc byItem:item]; // TODO: Use multi-line display for readability?
	else
		return nil;
}
#endif

- (BOOL) shouldCloseDocument
{
    return !isSearching && !isImporting;
}

- (void) missingKeysNotification:(NSNotification *)notification
{
    if([GPGMailBundle gpgMailWorks] && !isSearching && !isImporting){
        NSArray *fingerprints = [[notification userInfo] objectForKey:@"fingerprints"];
        NSArray *emails = [[notification userInfo] objectForKey:@"emails"];
        NSArray *patterns = nil;
        
        if(fingerprints != nil && [fingerprints count] > 0)
            patterns = [NSArray arrayWithObject:[@"0x" stringByAppendingString:[fingerprints componentsJoinedByString:@", 0x"]]];
        if(patterns != nil && emails != nil)
            patterns = [patterns arrayByAddingObjectsFromArray:emails];
        else if(emails != nil)
            patterns = emails;
        
        [self window]; // Ensures nib has been loaded
        if(patterns != nil && [patterns count] > 0)
            [emailCell setStringValue:[patterns componentsJoinedByString:@", "]];
    }
}

+ (void) missingKeysNotification:(NSNotification *)notification
{
    [[self sharedInstance] missingKeysNotification:notification];
}

@end
