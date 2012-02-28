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

#define localized(key) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:(key) table:@"GPGMail"]


@implementation GPGMailPreferences

- (GPGMailBundle *)bundle {
	return [GPGMailBundle sharedInstance];
}

- (SUUpdater *)updater {
	return [[GPGMailBundle sharedInstance] updater];
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

- (NSImage *)imageForPreferenceNamed:(NSString *)aName {
	return [NSImage imageNamed:@"GPGMailPreferences"];
}

/* Open FAQ page. */
- (IBAction)openFAQ:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://gpgtools.org/faq.html"]];
}
/* Open donation page. */
- (IBAction)openDonation:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://gpgtools.org/donate.html"]];
}
/* Open contact page. */
- (IBAction)openContact:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://gpgtools.org/about.html"]];
}

- (IBAction)openGPGStatusHelp:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://support.gpgtools.org/kb/how-to/gpg-status"]];
}

- (void)willBeDisplayed {
	[[GPGMailBundle sharedInstance] checkGPG];
}

- (NSImage *)gpgStatusImage {
	switch ([[GPGMailBundle sharedInstance] gpgStatus]) {
		case GPGErrorNotFound:
			return [NSImage imageNamed:@"RedDot"];
		case GPGErrorNoError:
			return [NSImage imageNamed:@"GreenDot"];
		default:
			return [NSImage imageNamed:@"YellowDot"];
	}
}
- (NSString *)gpgStatusToolTip {
	switch ([[GPGMailBundle sharedInstance] gpgStatus]) {
		case GPGErrorNotFound:
			return localized(@"GPG_STATUS_NOT_FOUND_TOOLTIP");
		case GPGErrorNoError:
			return localized(@"GPG_STATUS_NO_ERROR_TOOLTIP");
		default:
			return localized(@"GPG_STATUS_OTHER_ERROR_TOOLTIP");
	}
}

- (NSString *)gpgStatusTitle {
    NSString *statusTitle = nil;
    switch ([[GPGMailBundle sharedInstance] gpgStatus]) {
		case GPGErrorNotFound:
			statusTitle = localized(@"GPG_STATUS_NOT_FOUND_TITLE");
            break;
		case GPGErrorNoError:
			statusTitle = localized(@"GPG_STATUS_NO_ERROR_TITLE");
            break;
        default:
			statusTitle = localized(@"GPG_STATUS_OTHER_ERROR_TITLE");
	}
    return statusTitle;
}

+ (NSSet*)keyPathsForValuesAffectingGpgStatusImage {
	return [NSSet setWithObject:@"bundle.gpgStatus"];
}
+ (NSSet*)keyPathsForValuesAffectingGpgStatusToolTip {
	return [NSSet setWithObject:@"bundle.gpgStatus"];
}
+ (NSSet*)keyPathsForValuesAffectingGpgStatusTitle {
	return [NSSet setWithObject:@"bundle.gpgStatus"];
}


@end
