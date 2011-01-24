/* GPGProgressIndicatorController.h created by dave on Mon 01-Jan-2001 */

/*
 * Copyright (c) 2000-2011, GPGTools Project Team <gpgmail-devel@lists.gpgmail.org>
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

#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h>


@class NSBox;
@class NSButton;
@class NSProgressIndicator;
@class NSTextField;
@class NSView;


@interface GPGProgressIndicatorController : NSObject
{
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSProgressIndicator *progressIndicator2;
	IBOutlet NSTextField *titleTextField;
	IBOutlet NSTextField *titleTextField2;
	IBOutlet NSTextField *backgroundTextField;
	IBOutlet NSButton *cancelButton;
	IBOutlet NSBox *enclosingBox;
	id delegate;
}

+ (GPGProgressIndicatorController *)sharedController;

- (void)startWithTitle:(NSString *)title delegate:(id)delegate;
// If delegate is nil, cancel is not possible; if delegate is set, it must respond to -progressIndicatorDidCancel:
- (void)startWithTitle:(NSString *)title view:(NSView *)view;
// Adds a subview in the view's superview, positionned at the upper right corner, to display the progress bar
- (void)stop;

- (IBAction)cancel:(id)sender;

@end

@interface NSObject (GPGProgressIndicatorControllerDelegate)
- (void)progressIndicatorDidCancel:(GPGProgressIndicatorController *)controller;
@end
