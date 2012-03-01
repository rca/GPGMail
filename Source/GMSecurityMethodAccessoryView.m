/* GMSecurityMethodAccessoryView.m created by Lukas Pitschl (@lukele) on Thu 01-Mar-2012 */

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

#import "CCLog.h"
#import "GPGConstants.h"
#import "NSBezierPath+StrokeExtensions.h"
#import "NSBezierPath_KBAdditions.h"
#import "NSWindow+GPGMail.h"
#import "GMSecurityMethodAccessoryView.h"

@interface GMSecurityMethodAccessoryView ()

@property (nonatomic, assign) BOOL fullscreen;
@property (nonatomic, assign) NSRect nonFullScreenFrame;

@property (nonatomic, retain) NSPopUpButton *popup;
@property (nonatomic, retain) NSImageView *arrow;

@end

@implementation GMSecurityMethodAccessoryView

@synthesize popup = _popup, fullscreen = _fullscreen, active = _active, arrow = _arrow, 
            nonFullScreenFrame = _nonFullScreenFrame, securityMethod = _securityMethod,
            delegate = _delegate;

- (id)init {
    self = [super initWithFrame:NSMakeRect(0.0f, 0.0f, GMSMA_DEFAULT_WIDTH, GMSMA_DEFAULT_HEIGHT)];
    if(self) {
        self.autoresizingMask = NSViewMinYMargin | NSViewMinXMargin;
        [self _configurePopupWithSecurityMethods:[NSArray arrayWithObjects:@"OpenPGP", @"S/MIME", nil]];
        [self _configureArrow];
    }
    return self;
}

- (void)_configurePopupWithSecurityMethods:(NSArray *)methods {
    NSPopUpButton *popup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 70, 17) pullsDown:NO];
    // The arrow is hidden, since it's strangely aligned by default.
    // GPGMail adds its own.
    [[popup cell] setArrowPosition:NSPopUpNoArrow];
    [popup setAutoresizingMask:NSViewMinYMargin];
    //popup.font = [NSFont systemFontOfSize:10.0f];
    // Make the popup border transparent.
    [popup setBordered:NO]; 
    
    NSMenu *menu = popup.menu;
    menu.autoenablesItems = NO;
    menu.delegate = self;
    
    for(NSString *method in methods) {
        NSMenuItem *item = [menu addItemWithTitle:method action:@selector(changeSecurityMethod:) keyEquivalent:@""];
        item.target = self;
        item.enabled = YES;
        item.tag = [methods indexOfObject:method] == 0 ? GPGMAIL_SECURITY_METHOD_OPENPGP : GPGMAIL_SECURITY_METHOD_SMIME;
        item.keyEquivalent = [methods indexOfObject:method] == 0 ? @"p" : @"s";
        item.keyEquivalentModifierMask = NSCommandKeyMask | NSAlternateKeyMask;
        item.attributedTitle = [self attributedTitle:method highlight:YES];
    }
    
    // Add the popup as subview.
    [self addSubview:popup];
    
    self.popup = popup;
    [popup release];
    
    // Center the menu item.
    [self centerMenuWithItem:self.popup.selectedItem];
}

- (void)changeSecurityMethod:(id)sender {
    [self.delegate securityMethodAccessoryView:self didChangeSecurityMethod:[sender tag]];
}

- (void)_configureArrow {
    NSImage *arrow = [NSImage imageNamed:@"MenuArrowWhite"];
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(60.0f, 4.0f, arrow.size.width, arrow.size.height)];
    imageView.image = arrow;
    
    // Add the arrow as subview.
    [self addSubview:imageView];
    
    self.arrow = imageView;
    
    [imageView release];
}

- (void)configureForFullScreenWindow:(NSWindow *)window {
    DebugLog(@"Enter fullscreen: move security method accessory view");
    self.fullscreen = YES;
    // Add the accessory view to the window.
    [window addAccessoryView:self];
    // Center the view within the window.
    [window centerAccessoryView:self];
    // Adjust the height to match the other fullscreen mail buttons.
    NSRect frame = self.frame;
    frame.size.height = 22.0f;
    // Align it vertically to match the other mail buttons.
    frame.origin.y = frame.origin.y - 16.0f;
    self.frame = frame;
    
    self.popup.menu.font = [NSFont systemFontOfSize:12.f];
    
    [self centerMenuWithItem:nil];
    
    // Adjust the origin of the pop up.
    NSRect popupFrame = self.popup.frame;
    popupFrame.origin.y = 4.0f;
    self.popup.frame = popupFrame;
    NSRect arrowFrame = self.arrow.frame;
    arrowFrame.origin.y = 6.0f;
    self.arrow.frame = arrowFrame;
    
    // Update the font size of every item.
    [self resetMenuItemTitles];
}

- (void)configureForWindow:(NSWindow *)window {
    DebugLog(@"Exit fullscreen: re-add security method accessory view");
    self.fullscreen = NO;
    [self retain];
    [self removeFromSuperview];
    [self release];
    
    NSRect arrowFrame = self.arrow.frame;
    arrowFrame.origin.y = 4.0f;
    self.arrow.frame = arrowFrame;
    
    NSRect frame = self.frame;
    frame.size.height = 17.0f;
    self.frame = frame;
    self.hidden = NO;
    
    self.popup.menu.font = [NSFont systemFontOfSize:10.f];
    
    [self centerMenuWithItem:nil];
    
    NSRect popupFrame = self.popup.frame;
    popupFrame.origin.y = 0.0f;
    self.popup.frame = popupFrame;
    [self.popup setNeedsDisplay];
    
    // Update the font size of every item.
    [self resetMenuItemTitles];
    
    [window addAccessoryView:self];
}

- (void)setSecurityMethod:(GPGMAIL_SECURITY_METHOD)securityMethod {
    _securityMethod = securityMethod;
    // Update the selection and center the menu title again.
    [self.popup selectItemAtIndex:securityMethod == GPGMAIL_SECURITY_METHOD_OPENPGP ? 0 : 1];
    [self centerMenuWithItem:nil];
    [self setNeedsDisplay:YES];
}

#pragma mark - NSMenuDelegate is repsonsible for adjusting the color of the menu titles.

- (void)resetMenuItemTitles {
    for(NSMenuItem *item in self.popup.menu.itemArray) {
        if(!item.title)
            continue;
        item.attributedTitle = [self attributedTitle:item.title highlight:YES];
    }
}

- (void)menuWillOpen:(NSMenu *)menu {
    for(NSMenuItem *item in menu.itemArray) {
        item.attributedTitle = [self attributedTitle:item.title highlight:YES];
    }
}

- (void)menuDidClose:(NSMenu *)menu {
    for(NSMenuItem *item in menu.itemArray) {
        item.attributedTitle = [self attributedTitle:item.title highlight:YES];
    }
}

- (void)menu:(NSMenu *)menu willHighlightItem:(NSMenuItem *)item {
    for(NSMenuItem *citem in menu.itemArray) {
        if(item != citem)
            citem.attributedTitle = [self attributedTitle:citem.title highlight:NO];
        else
            citem.attributedTitle = [self attributedTitle:citem.title highlight:YES];
    }
    [self centerMenuWithItem:item];
    
}

- (NSAttributedString *)attributedTitle:(NSString *)title highlight:(BOOL)highlight {
    // Title must never be nil!
    if(!title)
        title = @"";
    // Create the white shadow that sits behind the text
    NSShadow *shadow = [[NSShadow alloc] init];
    if(!highlight)
        [shadow setShadowColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.5]];
    else
        [shadow setShadowColor:[NSColor colorWithDeviceRed:0.0/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.5]];
    [shadow setShadowOffset:NSMakeSize(1.0, -1.1)];
    
    NSFont *font = nil;
    NSColor *color = nil;
    if(!highlight)
        color = [NSColor colorWithDeviceRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0];
    else
        color = [NSColor colorWithDeviceRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    
    // Font size is 12.0f for Fullscreen, 10.f for normal.
    font = !self.fullscreen ? [NSFont systemFontOfSize:10.0f] : [NSFont systemFontOfSize:12.0f];
    
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
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                                          attributes:attributes];
    return [attributedTitle autorelease];
}

- (void)centerMenuWithItem:(NSMenuItem *)item {
    item = item != nil ? item : self.popup.selectedItem;
    
    NSRect extFrame = self.frame;
    NSRect frame = self.popup.frame;
    NSAttributedString *title = [self attributedTitle:item.attributedTitle.string highlight:YES];
    float titleWithArrowWidth = title.size.width + 3.0f + 7.0f;
    float diff = roundf((extFrame.size.width - roundf(titleWithArrowWidth))/2);
    // x = 0 is 9px into the accessory view. so subtract 9 from x and you
    // get the value to center the text.
    float x = diff - 9;
    frame.origin.x = x;
    
    NSRect arrowFrame = self.arrow.frame;
    arrowFrame.origin.x = diff + roundf(title.size.width) + 3;
    
    self.arrow.frame = arrowFrame;
    self.popup.frame = frame;
}

- (NSGradient *)gradientSMIMEWithStrokeColor:(NSColor **)strokeColor {
    NSGradient *gradient = nil;
    
    NSUInteger redStart = 20.0f;
    NSUInteger greenStart = 80.0f;
    // Start for full screen.
    NSUInteger greenStartAlt = 128.0f;
    NSUInteger blueStart = 240.0f;
    NSUInteger redStep, greenStep, blueStep;
    redStep = greenStep = blueStep = 18.0f;
    
    if(!self.fullscreen) {
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:redStart/255.0f green:greenStart/255.0f blue:blueStart/255.0f alpha:1.0], 0.0f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 1))/255.0f green:(greenStart + (greenStep * 1))/255.0f blue:blueStart/255.0f alpha:1.0], 0.13f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 1))/255.0f green:(greenStart + (greenStep * 1))/255.0f blue:blueStart/255.0f alpha:1.0], 0.27f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 2))/255.0f green:(greenStart + (greenStep * 2))/255.0f blue:blueStart/255.0f alpha:1.0], 0.61f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 3))/255.0f green:(greenStart + (greenStep * 3))/255.0f blue:blueStart/255.0f alpha:1.0], 1.0f, nil];
    }
    else {
        redStep = greenStep = blueStep = 8.0f;
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:(redStart + (redStep * 2))/255.0f green:(greenStartAlt + (greenStep * 2))/255.0f blue:(blueStart + (blueStep * 1))/255.0f alpha:1.0], 0.0f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 3))/255.0f green:(greenStartAlt + (greenStep * 3))/255.0f blue:(blueStart + (blueStep * 1))/255.0f alpha:1.0], 0.13f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 4))/255.0f green:(greenStartAlt + (greenStep * 4))/255.0f blue:(blueStart + (blueStep * 1))/255.0f alpha:1.0], 0.27f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 5))/255.0f green:(greenStartAlt + (greenStep * 5))/255.0f blue:(blueStart + (blueStep * 1))/255.0f alpha:1.0], 0.61f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 6))/255.0f green:(greenStartAlt + (greenStep * 6))/255.0f blue:(blueStart + (blueStep * 1))/255.0f alpha:1.0], 1.0f, nil];
    }
    
    *strokeColor = [NSColor colorWithDeviceRed:redStart/255.0f green:greenStart/255.0f blue:blueStart/255.0f alpha:1.0];
    
    return [gradient autorelease];
}

- (NSGradient *)gradientPGPWithStrokeColor:(NSColor **)strokeColor {
    NSGradient *gradient = nil;
    
    NSUInteger greenStart = 128.0f;
    NSUInteger greenStep = 18.0f;
    
    if(!self.fullscreen) {
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:0/255.0f green:greenStart/255.0f blue:0/255.0f alpha:1.0], 0.0f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 1))/255.0f blue:0/255.0f alpha:1.0], 0.13f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 1))/255.0f blue:0/255.0f alpha:1.0], 0.27f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 2))/255.0f blue:0/255.0f alpha:1.0], 0.61f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 3))/255.0f blue:0/255.0f alpha:1.0], 1.0f, nil];
    }
    else {
        greenStep = 8.0f;
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 6))/255.0f blue:0/255.0f alpha:1.0], 0.0f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 7))/255.0f blue:0/255.0f alpha:1.0], 0.13f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 8))/255.0f blue:0/255.0f alpha:1.0], 0.27f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 9))/255.0f blue:0/255.0f alpha:1.0], 0.61f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 10))/255.0f blue:0/255.0f alpha:1.0], 1.0f, nil];
    }
    
    *strokeColor = [NSColor colorWithDeviceRed:0/255.0f green:greenStart/255.0f blue:0/255.0f alpha:1.0];
    
    return [gradient autorelease];
}

- (NSGradient *)gradientNotActiveWithStrokeColor:(NSColor **)strokeColor {
    NSGradient *gradient = nil;
    
    NSUInteger greyStart = 146.0f;
    NSUInteger greyStep = 18.0f;
    
    if(!self.fullscreen) {
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:greyStart/255.0f green:128.0f/255.0f blue:128.0f/255.0f alpha:1.0], 0.0f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 1))/255.0f green:(greyStart + (greyStep * 1))/255.0f blue:(greyStart + (greyStep * 1))/255.0f alpha:1.0], 0.13f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 1))/255.0f green:(greyStart + (greyStep * 1))/255.0f blue:(greyStart + (greyStep * 1))/255.0f alpha:1.0], 0.27f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 2))/255.0f green:(greyStart + (greyStep * 2))/255.0f blue:(greyStart + (greyStep * 2))/255.0f alpha:1.0], 0.61f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 3))/255.0f green:(greyStart + (greyStep * 3))/255.0f blue:(greyStart + (greyStep * 3))/255.0f alpha:1.0], 1.0f,
                    nil];
    }
    else {
        greyStep = 8.0f;
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:(greyStart + (greyStep * 4))/255.0f green:(greyStart + (greyStep * 4))/255.0f blue:(greyStart + (greyStep * 4))/255.0f alpha:1.0], 0.0f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 5))/255.0f green:(greyStart + (greyStep * 5))/255.0f blue:(greyStart + (greyStep * 5))/255.0f alpha:1.0], 0.13f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 6))/255.0f green:(greyStart + (greyStep * 6))/255.0f blue:(greyStart + (greyStep * 6))/255.0f alpha:1.0], 0.27f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 7))/255.0f green:(greyStart + (greyStep * 7))/255.0f blue:(greyStart + (greyStep * 7))/255.0f alpha:1.0], 0.61f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 8))/255.0f green:(greyStart + (greyStep * 8))/255.0f blue:(greyStart + (greyStep * 8))/255.0f alpha:1.0], 1.0f,
                    nil];
    }
    
    
    *strokeColor = [NSColor colorWithDeviceRed:greyStart/255.0f green:greyStart/255.0f blue:greyStart/255.0f alpha:1.0];
    
    return [gradient autorelease];
}

- (void)setActive:(BOOL)active {
    _active = active;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect rect = [self bounds];
    rect.origin = NSMakePoint(0, 0);  
    float cornerRadius = 4.0f;
    KBCornerType corners = self.fullscreen ? (KBTopLeftCorner | KBBottomLeftCorner | KBTopRightCorner | KBBottomRightCorner) : (KBTopRightCorner | KBBottomLeftCorner);
    NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:rect inCorners:corners cornerRadius:cornerRadius flipped:NO];
    
    NSGradient *gradient = nil;
    NSColor *strokeColor = nil;
    
    if(!self.active)
        gradient = [self gradientNotActiveWithStrokeColor:&strokeColor];
    else if(self.securityMethod == GPGMAIL_SECURITY_METHOD_OPENPGP)
        gradient = [self gradientPGPWithStrokeColor:&strokeColor];
    else if(self.securityMethod == GPGMAIL_SECURITY_METHOD_SMIME)
        gradient = [self gradientSMIMEWithStrokeColor:&strokeColor];
    
    [gradient drawInBezierPath:path angle:90.0f];
    [strokeColor setStroke];
    
    [path strokeInside];
}

@end
