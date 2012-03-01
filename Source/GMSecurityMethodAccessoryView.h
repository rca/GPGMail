/* GMSecurityMethodAccessoryView.m created by Lukas Pitschl (@lukele) on Thu 01-Mar-2012 */

/*
 * Copyright (c) 2000-2012, GPGTools Project Team <gpgtools-devel@lists.gpgtools.org>
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

#import <Cocoa/Cocoa.h>
#import "GPGConstants.h"

#define GMSMA_DEFAULT_HEIGHT 17.0f
#define GMSMA_DEFAULT_WIDTH 80.0f
#define GMSMA_FULLSCREEN_HEIGHT 22.0f

@class GMSecurityMethodAccessoryView;

@protocol GMSecurityMethodAccessoryViewDelegate <NSObject>

- (void)securityMethodAccessoryView:(GMSecurityMethodAccessoryView *)accessoryView didChangeSecurityMethod:(GPGMAIL_SECURITY_METHOD)securityMethod;

@end

@interface GMSecurityMethodAccessoryView : NSView <NSMenuDelegate> {
    BOOL _fullscreen;
    BOOL _active;
    GPGMAIL_SECURITY_METHOD _securityMethod;
    
    id <GMSecurityMethodAccessoryViewDelegate> _delegate;
    
    NSRect _nonFullScreenFrame;
    NSPopUpButton *_popup;
    NSImageView *_arrow;
}

@property (nonatomic, assign) GPGMAIL_SECURITY_METHOD securityMethod;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) id <GMSecurityMethodAccessoryViewDelegate> delegate;

- (id)init;

/**
 Configures the popup menu with the given security methods.
 */
- (void)_configurePopupWithSecurityMethods:(NSArray *)methods;

/**
 Is called if the user changes the selection of the popup.
 Calls the delegate to act on it.
 */
- (void)changeSecurityMethod:(id)sender;

/**
 Configures the custom arrow.
 */
- (void)_configureArrow;

/**
 Prepare the accessory view for full screen mode, by updating positions
 of the view, menu and background colors.
 */
- (void)configureForFullScreenWindow:(NSWindow *)window;

/**
 Prepare the accessory view for normal screen mode, by updating positions
 of the view, menu and background colors.
 */
- (void)configureForWindow:(NSWindow *)window;

/**
 Allows the MailDocumentEditor to automatically update the security method
 and reflect the changes in the popup menu.
 */
- (void)setSecurityMethod:(GPGMAIL_SECURITY_METHOD)securityMethod;

/**
 Returns an attributed title including shadows and the correct color based
 on the highlight status for a menu item.
 */
- (NSAttributedString *)attributedTitle:(NSString *)title highlight:(BOOL)highlight;

/**
 Horizontally center the popup menu.
 */
- (void)centerMenuWithItem:(NSMenuItem *)item;

/**
 Return the different gradients and strokes based on method
 and fullscreen mode.
 */
- (NSGradient *)gradientSMIMEWithStrokeColor:(NSColor **)strokeColor;
- (NSGradient *)gradientPGPWithStrokeColor:(NSColor **)strokeColor;
- (NSGradient *)gradientNotActiveWithStrokeColor:(NSColor **)strokeColor;

/**
 Changes the active status based on the ability to sign or encrypt.
 Update the background color based on the active status.
 */
- (void)setActive:(BOOL)active;

/**
 Center the menu item within the accessory view, taking the arrow into
 consideration.
 */
- (void)centerMenuWithItem:(NSMenuItem *)item;
- (void)configureForFullScreenWindow:(NSWindow *)window;
- (void)configureForWindow:(NSWindow *)window;

@end
