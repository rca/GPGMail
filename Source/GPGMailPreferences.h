/* GPGMailPreferences.h created by dave on Thu 29-Jun-2000 */

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

#import <NSPreferences.h>
#import <AppKit/AppKit.h>
#import "NSPreferencesModule.h"

@class GPGMailBundle;
@class SUUpdater;
@class GPGOptions;
@class GMSpecialBox;


@interface GPGMailPreferences : NSPreferencesModule {}

/* Open FAQ page. */
- (IBAction)openFAQ:(id)sender;
/* Open donation page. */
- (IBAction)openDonation:(id)sender;
/* Open contact page. */
- (IBAction)openContact:(id)sender;

- (IBAction)openGPGStatusHelp:(id)sender;


@property (readonly) NSString *copyright;
@property (readonly) NSAttributedString *credits;
@property (readonly) NSAttributedString *websiteLink;
@property (readonly) GPGMailBundle *bundle;
@property (readonly) SUUpdater *updater;
@property (readonly) NSImage *gpgStatusImage;
@property (readonly) NSString *gpgStatusToolTip;
@property (readonly) NSString *gpgStatusTitle;
@property (readonly) GPGOptions *options;

@end


@interface NSButton_LinkCursor : NSButton
@end

@interface GMSpecialBox : NSBox {
	NSMapTable *viewPositions;
	BOOL working;
	BOOL positionsFilled;
	BOOL displayed;
	WebView *webView;
}
@end
