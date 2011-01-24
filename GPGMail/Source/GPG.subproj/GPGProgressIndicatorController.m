/* GPGProgressIndicatorController.m created by dave on Mon 01-Jan-2001 */

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

#import "GPGProgressIndicatorController.h"
#import <AppKit/AppKit.h>


@interface NSColor (GPGRevealed)
+ (NSColor *)toolTipTextColor;
+ (NSColor *)toolTipColor;
@end


@implementation GPGProgressIndicatorController

static GPGProgressIndicatorController *_sharedController = nil;

+ (GPGProgressIndicatorController *)sharedController {
	if (_sharedController == nil) {
		_sharedController = [[self alloc] init];
	}

	return _sharedController;
}

- (id)init {
	if ((self = [super init]) != nil) {
		NSAssert([NSBundle loadNibNamed:@"GPGProgressIndicatorController" owner:self] == YES, @"### GPGMail: -[GPGProgressIndicatorController init]: Unable to load nib named 'GPGProgressIndicatorController'");
		[progressIndicator setUsesThreadedAnimation:YES];
		[enclosingBox retain];
		[backgroundTextField setBackgroundColor:[NSColor toolTipColor]];
		[titleTextField2 setTextColor:[NSColor toolTipTextColor]];
		[[enclosingBox window] release];
	}

	return self;
}

- (void)dealloc {
	[[progressIndicator window] release];
	[enclosingBox release];

	[super dealloc];
}

- (void)startWithTitle:(NSString *)title delegate:(id)aDelegate {
	delegate = aDelegate;
//    [cancelButton setEnabled:(delegate != nil)];
	// Currently, <cancel> does not work for gpg tasks
	[cancelButton setEnabled:NO];
	[[progressIndicator window] center];
	[titleTextField setStringValue:title];
	[[progressIndicator window] makeKeyAndOrderFront:nil];
	[progressIndicator startAnimation:nil];
}

- (void)startWithTitle:(NSString *)title view:(NSView *)view {
	NSRect newFrameRect = [enclosingBox frame];

	[titleTextField2 setStringValue:title];
	// Let's resize the box to accomodate to the ideal size of the title
	newFrameRect.size.width += [[titleTextField2 cell] cellSize].width - NSWidth([titleTextField2 frame]);
	newFrameRect.origin.x = NSMaxX([view frame]) - NSWidth(newFrameRect);
	if ([[view superview] isFlipped]) {
		newFrameRect.origin.y = 0.0;
	} else {
		newFrameRect.origin.y = NSMaxY([view frame]) - NSHeight(newFrameRect);
	}
	[enclosingBox setFrame:newFrameRect];

	[[view superview] addSubview:enclosingBox];

	[progressIndicator2 startAnimation:nil];
}

- (void)_stop {
	[progressIndicator stopAnimation:nil];
	[progressIndicator2 stopAnimation:nil];
	[[progressIndicator window] orderOut:nil];
	[enclosingBox removeFromSuperview];
}

- (void)stop {
	[self _stop];
	delegate = nil;
}

- (IBAction)cancel:(id)sender {
	[self _stop];
	[delegate progressIndicatorDidCancel:self];
	delegate = nil;
}

@end
