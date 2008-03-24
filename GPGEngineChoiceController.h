//
//  GPGEngineChoiceController.h
//  GPGMail
//
//  Created by Dave Lopper on 29/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GPGEngineChoiceController : NSObject {
    IBOutlet NSPanel            *panel;
    IBOutlet NSMatrix           *choiceMatrix;
    IBOutlet NSArrayController  *arrayController;
    NSImage                     *image;
    NSWindowController          *windowController;
    NSMutableArray              *choices;
    NSString                    *selectedExecutablePath;
}

+ (id)sharedController;

- (NSInteger)runModalForEngine:(GPGEngine *)engine;

- (NSString *)selectedExecutablePath;
- (void)setSelectedExecutablePath:(NSString *)value;

- (NSImage *)image;
- (void)setImage:(NSImage *)value;

- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)other:(id)sender;

@end
