//
//  Run_in_MailAppDelegate.h
//  Run in Mail
//
//  Created by Lukas Pitschl on 10.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Run_in_MailAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *_window;
}

@property (strong) IBOutlet NSWindow *window;

@end
