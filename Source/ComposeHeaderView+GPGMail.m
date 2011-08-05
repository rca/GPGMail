//
//  ComposeHeaderView+GPGMail.m
//  GPGMail
//
//  Created by Lukas Pitschl on 31.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <ComposeBackEnd.h>
#import <DocumentEditor.h>
#import <OptionalView.h>
#import "CCLog.h"
#import "NSObject+LPDynamicIvars.h"
#import "ComposeBackEnd+GPGMail.h"
#import "ComposeHeaderView+GPGMail.h"

@implementation ComposeHeaderView_GPGMail

- (void)MAAwakeFromNib {
    ComposeBackEnd *backEnd = [(DocumentEditor *)[[((ComposeHeaderView *)self) delegate] valueForKey:@"_documentEditor"] backEnd];
    [backEnd setIvar:@"PGPEnabled" value:[NSNumber numberWithBool:YES]];
    
    DebugLog(@"Setup comes before... or later?");
    DebugLog(@"security view subviews: %@", [[self valueForKey:@"_securityOptionalView"] subviews]);
    
    // Get the position of each element in the security optional view
    // and reposition it accordingly.
    DebugLog(@"[DEBUG] %s This should be a back end: %@", __PRETTY_FUNCTION__, backEnd);
    OptionalView *securityOptionalView = (OptionalView *)[self valueForKey:@"_securityOptionalView"];
    
    NSSegmentedControl *lockView = [[securityOptionalView subviews] objectAtIndex:0];
    NSSegmentedControl *signView = [[securityOptionalView subviews] objectAtIndex:1];
    NSRect encryptFrame;
    NSRect signFrame = [signView frame];
    
    // Creating the NSButton based checkbox.
    NSButton *gpgCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(0.0f, 2.0f, 0.0f, 0.0f)];
    [gpgCheckbox setButtonType:NSSwitchButton];
    [gpgCheckbox setTitle:@"OpenPGP"];
    [gpgCheckbox setBezelStyle:NSRegularSquareBezelStyle];
    [gpgCheckbox setToolTip:@"Choose whether you want to encrypt the message with OpenPGP or not"];
    [gpgCheckbox setTarget:backEnd];
    [gpgCheckbox setAction:@selector(setPGPState:)];
    // By default GPG checkbox is enabled.
    [gpgCheckbox setState:NSOnState];
    [gpgCheckbox sizeToFit];
    DebugLog(@"[DEBUG] %s gpgCheckbox: %@", __PRETTY_FUNCTION__, NSStringFromRect([gpgCheckbox frame]));
    // 1.) Adjust the frame.
    [lockView setFrameOrigin:NSMakePoint((gpgCheckbox.frame.origin.x + gpgCheckbox.frame.size.width + 4.0f), 0.0f)];
    encryptFrame = [lockView frame];
    // 2.) Adjust the frame.
    [signView setFrame:NSMakeRect(encryptFrame.origin.x + encryptFrame.size.width + 5.0f, -1.0f, signFrame.size.width, signFrame.size.height)];
    signFrame = [signView frame];
    
    [securityOptionalView addSubview:gpgCheckbox];
    [gpgCheckbox release];
    
    [securityOptionalView setIvar:@"securityViewWidth" value:[NSNumber numberWithFloat:signFrame.origin.x + signFrame.size.width]];
    
    [self MAAwakeFromNib];
}

- (CGRect)MA_calculateSecurityFrame:(CGRect)frame {
    if([[self valueForKey:@"_securityOptionalView"] ivarExists:@"securityViewWidth"])
        frame.size.width = [[[self valueForKey:@"_securityOptionalView"] getIvar:@"securityViewWidth"] floatValue];
    CGRect newRect = [self MA_calculateSecurityFrame:frame];
    return newRect;
}

@end
