/* MailDocumentEditor+GPGMail.m re-created by Lukas Pitschl (@lukele) on Sat 27-Aug-2011 */

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
#import "NSObject+LPDynamicIvars.h"
#import <MailAccount.h>
#import <HeadersEditor.h>
#import "ComposeBackEnd.h"
#import <MailDocumentEditor.h>
#import <MailNotificationCenter.h>
#import "GPGTitlebarAccessoryView.h"
#import "NSWindow+GPGMail.h"
#import "Message+GPGMail.h"
#import "HeadersEditor+GPGMail.h"
#import "MailDocumentEditor+GPGMail.h"
#import "ComposeBackEnd+GPGMail.h"
#import "GPGMailBundle.h"
#import <MFError.h>

@implementation MailDocumentEditor_GPGMail

- (void)_repositionSecurityMethodAccessoryViewForFullscreen:(NSNumber *)fullscreen {
    [self repositionSecurityMethodAccessoryViewForFullscreen:[fullscreen boolValue]];
}
- (void)repositionSecurityMethodAccessoryViewForFullscreen:(BOOL)fullscreen {
    // If backEndDidLoadInitialContent was not called yet, accessory view
    // is not yet available.
    // In that case, exit since we're gonna be called again.
    GPGTitlebarAccessoryView *accessoryView = [self getIvar:@"SecurityMethodHintAccessoryView"];
    if(!accessoryView)
        return;
    NSRect frame = accessoryView.frame;
    float originalY = [[self getIvar:@"AccessoryViewOriginalY"] floatValue];
    if(fullscreen) {
        frame.origin.y = originalY - 51.0f;
        frame.origin.x -= 14.0f;
        accessoryView.frame = frame;
    }
    else {
        NSWindow *window = [self valueForKey:@"_window"];
        [accessoryView retain];
        [accessoryView removeFromSuperview];
        [accessoryView release];
        [window addAccessoryView:accessoryView];
        accessoryView.hidden = NO;
    }
    accessoryView.fullscreen = fullscreen;
}

- (void)didExitFullScreen:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(_repositionSecurityMethodAccessoryViewForFullscreen:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
}

- (void)removeSecurityMethodAccessoryView {
    GPGTitlebarAccessoryView *accessoryView = [self getIvar:@"SecurityMethodHintAccessoryView"];
    accessoryView.hidden = YES;
    [accessoryView setNeedsDisplay:YES];
}

- (void)updateSecurityMethodHighlight {
    GPGTitlebarAccessoryView *accessoryView = [self getIvar:@"SecurityMethodHintAccessoryView"];
    ComposeBackEnd *backEnd = ((MailDocumentEditor *)self).backEnd;
    
    BOOL shouldEncrypt = [[backEnd getIvar:@"shouldEncrypt"] boolValue];
    BOOL shouldSign = [[backEnd getIvar:@"shouldSign"] boolValue];
    
    GPGMAIL_SECURITY_METHOD securityMethod = ((ComposeBackEnd_GPGMail *)backEnd).guessedSecurityMethod;
    if(((ComposeBackEnd_GPGMail *)backEnd).securityMethod)
        securityMethod = ((ComposeBackEnd_GPGMail *)backEnd).securityMethod;
    
    if(shouldEncrypt || shouldSign)
        accessoryView.color = securityMethod;
    else
        accessoryView.color = 0;
    
    [self updateSecurityMethodHint:securityMethod];
    [[((MailDocumentEditor *)self) headersEditor] fromHeaderDisplaySecretKeys:(securityMethod == GPGMAIL_SECURITY_METHOD_OPENPGP ? YES : NO)];
}

- (void)updateSecurityHintFromNotification:(NSNotification *)notification {
    NSNumber *securityMethod = [[notification userInfo] valueForKey:@"SecurityMethod"];
    [self updateSecurityHint:[securityMethod unsignedIntValue]];
}

- (void)updateSecurityHint:(GPGMAIL_SECURITY_METHOD)securityMethod {
    [self updateSecurityMethodHint:securityMethod];
}

- (void)MABackEndDidLoadInitialContent:(id)content {
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyringUpdated:) name:GPGMailKeyringUpdatedNotification object:nil];
    [(MailNotificationCenter *)[NSClassFromString(@"MailNotificationCenter") defaultCenter] addObserver:self selector:@selector(updateSecurityHintFromNotification:) name:@"SecurityMethodDidChangeNotification" object:nil];
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didExitFullScreen:) name:@"NSWindowDidExitFullScreenNotification" object:nil];
    
    // Setup security method hint accessory view in top right corner of the window.
    [self setupSecurityMethodHintAccessoryView];
    //[((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd) postSecurityMethodDidChangeNotification];
    GPGMAIL_SECURITY_METHOD securityMethod = ((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd).guessedSecurityMethod;
    if(((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd).securityMethod)
        securityMethod = ((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd).securityMethod;
    [self updateSecurityHint:securityMethod];
    [self MABackEndDidLoadInitialContent:content];
    // Set backend was initialized, so securityMethod changes will start to send notifications.
    ((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd).wasInitialized = YES;
}

- (void)setupSecurityMethodHintAccessoryView {
    GPGTitlebarAccessoryView *accessoryView = [[GPGTitlebarAccessoryView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 80.0f, 17.0f)];
    accessoryView.autoresizingMask = NSViewMinYMargin | NSViewMinXMargin;
    // Save accessoryView to hide and display it on demand.
    [self setIvar:@"SecurityMethodHintAccessoryView" value:accessoryView];
    NSPopUpButton *securityMethodHintPopUp = [self securityMethodHintPopUp];
    // Save the menu to change the selection later.
    [self setIvar:@"SecurityMethodHintPopUp" value:securityMethodHintPopUp];
    
    [accessoryView addSubview:securityMethodHintPopUp];
    
    NSImage *arrow = [NSImage imageNamed:@"MenuArrowWhite"];
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(60.0f, 4.0f, arrow.size.width, arrow.size.height)];
    imageView.image = arrow;
    [accessoryView addSubview:imageView];
    
    // Center the menu item.
    [self centerMenuWithItem:securityMethodHintPopUp.selectedItem];
    
    // Add the accessory view to the to the window.
    NSWindow *window = [self valueForKey:@"_window"];
    [window addAccessoryView:accessoryView];
    // Hide the accessory view per default.
    accessoryView.color = 0;
    
    // Store original accessory view frame y position, to restore after exiting
    // full screen.
    [self setIvar:@"AccessoryViewOriginalY" value:[NSNumber numberWithFloat:accessoryView.frame.origin.y]];
    
    if([window isModal])
        [self repositionSecurityMethodAccessoryViewForFullscreen:YES];
    
    [accessoryView release];
}

- (void)centerMenuWithItem:(NSMenuItem *)item {
    NSView *accessoryView = [self getIvar:@"SecurityMethodHintAccessoryView"];
    NSPopUpButton *securityMethodHintPopUp = [self getIvar:@"SecurityMethodHintPopUp"];
    item = item != nil ? item : securityMethodHintPopUp.selectedItem;
    
    NSRect extFrame = accessoryView.frame;
    NSRect frame = securityMethodHintPopUp.frame;
    NSAttributedString *title = [self coloredTitle:item.attributedTitle.string monochrome:NO];
    float titleWithArrowWidth = title.size.width + 3.0f + 7.0f;
    float diff = roundf((extFrame.size.width - roundf(titleWithArrowWidth))/2);
    // x = 0 is 9px into the accessory view. so subtract 9 from x and you
    // get the value to center the text.
    float x = diff - 9;
    frame.origin.x = x;
    
    NSImageView *imageView = [[accessoryView subviews] objectAtIndex:1];
    NSRect arrowFrame = imageView.frame;
    arrowFrame.origin.x = diff + roundf(title.size.width) + 3;
    
    imageView.frame = arrowFrame;
    securityMethodHintPopUp.frame = frame;
}

- (void)updateSecurityMethodHint:(GPGMAIL_SECURITY_METHOD)securityMethod {
    NSPopUpButton *securityMethodHintPopUp = [self getIvar:@"SecurityMethodHintPopUp"];
    if(securityMethod)
        [securityMethodHintPopUp selectItemAtIndex:securityMethod == GPGMAIL_SECURITY_METHOD_OPENPGP ? 0 : 1];
    [self centerMenuWithItem:nil];
}

- (NSPopUpButton *)securityMethodHintPopUp {
    NSPopUpButton *securityMethodPopup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 62, 17) pullsDown:NO];
    [[securityMethodPopup cell] setArrowPosition:NSPopUpNoArrow];
    [securityMethodPopup setAutoresizingMask:NSViewMinYMargin];
    
    securityMethodPopup.font = [NSFont systemFontOfSize:10.0f];
    [securityMethodPopup setBordered:NO]; 
    
    NSMenu *menu = securityMethodPopup.menu;
    menu.autoenablesItems = NO;
    menu.delegate = self;
    
    NSArray *titles = [[NSArray alloc] initWithObjects:@"OpenPGP", @"S/MIME", nil];
    
    for(NSString *title in titles) {
        NSMenuItem *item = [menu addItemWithTitle:title action:@selector(changeSecurityMethod:) keyEquivalent:@""];
        item.target = self;
        item.enabled = YES;
        item.tag = [titles indexOfObject:title] == 0 ? GPGMAIL_SECURITY_METHOD_OPENPGP : GPGMAIL_SECURITY_METHOD_SMIME;
        item.keyEquivalent = [titles indexOfObject:title] == 0 ? @"p" : @"s";
        item.keyEquivalentModifierMask = NSCommandKeyMask | NSAlternateKeyMask;
        item.attributedTitle = [self coloredTitle:title monochrome:NO];
    }
    
    [titles release];
    
    return [securityMethodPopup autorelease];
}

- (void)keyringUpdated:(NSNotification *)notification {
    // Reset the security method, since it might change due to the updated keyring.
    ((ComposeBackEnd_GPGMail *)[((MailDocumentEditor *)self) backEnd]).securityMethod = 0;
	[[(MailDocumentEditor *)self headersEditor] updateSecurityControls];
}

- (NSAttributedString *)coloredTitle:(NSString *)title monochrome:(BOOL)monochrome {
    // Title must never be nil!
    if(!title)
        title = @"";
    // Create the white shadow that sits behind the text
    NSShadow *shadow = [[NSShadow alloc] init];
    if(monochrome)
        [shadow setShadowColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.5]];
    else
        [shadow setShadowColor:[NSColor colorWithDeviceRed:0.0/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.5]];
    [shadow setShadowOffset:NSMakeSize(1.0, -1.1)];
    // Create the attributes dictionary, you can change the font size
    // to whatever is useful to you
    NSFont *font = nil;
    NSColor *color = nil;
    if(monochrome) {
        font = [NSFont systemFontOfSize:10.0f];
        color = [NSColor colorWithDeviceRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0];
    }
    else {
        font = [NSFont fontWithName:@"LucidaGrande-Bold" size:10.0f];
        color = [NSColor colorWithDeviceRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    }
    
    NSMutableParagraphStyle *mutParaStyle=[[NSMutableParagraphStyle alloc] init];
    [mutParaStyle setAlignment:NSLeftTextAlignment];
    
    NSMutableDictionary *attributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                      font ,NSFontAttributeName,
                                      shadow, NSShadowAttributeName, color,
                                        NSForegroundColorAttributeName, mutParaStyle, NSParagraphStyleAttributeName,
                                      nil] autorelease];
    [mutParaStyle release];
    // The shadow object has been assigned to the dictionary, so release
    [shadow release];
    // Create a new attributed string with your attributes dictionary attached
    NSAttributedString *coloredTitle = [[NSAttributedString alloc] initWithString:title
                                                            attributes:attributes];
    return [coloredTitle autorelease];
}

- (void)menuWillOpen:(NSMenu *)menu {
    for(NSMenuItem *item in menu.itemArray) {
        item.attributedTitle = [self coloredTitle:item.title monochrome:YES];
    }
}

- (void)menuDidClose:(NSMenu *)menu {
    for(NSMenuItem *item in menu.itemArray) {
        item.attributedTitle = [self coloredTitle:item.title monochrome:NO];
    }
}

- (void)menu:(NSMenu *)menu willHighlightItem:(NSMenuItem *)item {
    for(NSMenuItem *citem in menu.itemArray) {
        if(item != citem)
            citem.attributedTitle = [self coloredTitle:citem.title monochrome:YES];
        else
            citem.attributedTitle = [self coloredTitle:citem.title monochrome:NO];
    }
    [self centerMenuWithItem:item];
    
}

- (void)changeSecurityMethod:(id)sender {
    ((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd).securityMethod = [sender tag];
    ((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd).userDidChooseSecurityMethod = YES;
    [[(MailDocumentEditor *)self headersEditor] updateSecurityControls];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    return YES;
}



- (void)MADealloc {
    // Sometimes this fails, so simply ignore it.
    @try {
		[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] removeObserver:self];
        [(MailNotificationCenter *)[NSClassFromString(@"MailNotificationCenter") defaultCenter] removeObserver:self];
    }
    @catch(NSException *e) {
        
    }
    [self MADealloc];
}

- (void)MABackEnd:(id)arg1 didCancelMessageDeliveryForEncryptionError:(MFError *)error {
	if ([[(NSDictionary *)error.userInfo objectForKey:@"GPGErrorCode"] integerValue] == GPGErrorCancelled) {
		return;
	}
	[self MABackEnd:arg1 didCancelMessageDeliveryForEncryptionError:error];
}


@end
