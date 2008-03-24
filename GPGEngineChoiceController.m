//
//  GPGEngineChoiceController.m
//  GPGMail
//
//  Created by Dave Lopper on 29/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GPGEngineChoiceController.h"


@implementation GPGEngineChoiceController

+ (id)sharedController
{
    static GPGEngineChoiceController    *sharedController = nil;
    
    if(sharedController == nil)
        sharedController = [[self alloc] init];
    
    return sharedController;
}

- (id)init
{
    if(self = [super init]){
        [self setImage:[[NSApplication sharedApplication] applicationIconImage]];
        choices = [[NSMutableArray alloc] init];
        windowController = [[NSWindowController alloc] initWithWindowNibName:@"GPGEngineChoiceController" owner:self];
    }
         
    return self;
}

- (void) dealloc
{
    [windowController release];
    [image release];
    [choices release];
    [selectedExecutablePath release];
    
    [super dealloc];
}

- (NSInteger)runModalForEngine:(GPGEngine *)engine
{
    NSParameterAssert(engine != nil);
    
    [self willChangeValueForKey:@"choices"];
    [choices removeAllObjects];
    NSEnumerator    *anEnum = [[engine knownExecutablePaths] objectEnumerator];
    NSString        *eachPath;
    NSArray         *availablePaths = [engine availableExecutablePaths];
    
    while(eachPath = [anEnum nextObject]){
        NSDictionary    *aDict = [NSDictionary dictionaryWithObjectsAndKeys:eachPath, @"path", [NSNumber numberWithBool:[availablePaths containsObject:eachPath]], @"enabled", nil];
        
        [choices addObject:aDict];
    }
    eachPath = [self selectedExecutablePath];
    if(eachPath != nil && ![knownExecutablePaths containsObject:eachPath]){
        NSDictionary    *aDict = [NSDictionary dictionaryWithObjectsAndKeys:eachPath, @"path", [NSNumber numberWithBool:[[NSFileManager defaultManager] isExecutableFileAtPath:eachPath]], @"enabled", nil];
        
        [choices addObject:aDict];
    }
    [self didChangeValueForKey:@"choices"];
    
    return [[NSApplication sharedApplication] runModalForWindow:panel];
}

- (IBAction)ok:(id)sender
{
    [panel orderOut:sender];
    [[NSApplication sharedApplication] stopModalWithCode:NSOKButton];
}

- (IBAction)cancel:(id)sender
{
    [panel orderOut:sender];
    [[NSApplication sharedApplication] stopModalWithCode:NSCancelButton];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
    if(returnCode == NSOKButton){
        if(![[choices valueForKey:@"path"] containsObject:[panel filename]]){
            NSDictionary    *aDict = [NSDictionary dictionaryWithObjectsAndKeys:[panel filename], @"path", [NSNumber numberWithBool:YES], @"enabled", nil];
            
            [[self mutableArrayValueForKey:@"choices"] addObject:aDict];
            [self setSelectedExecutablePath:[panel filename]];
            // TODO: resize window
        }
    }
}

- (IBAction)other:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setResolvesAliases:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setPrompt:NSLocalizedStringFromTableInBundle(@"SELECT_EXECUTABLE_PATH__PROMPT", nil, [NSBundle bundleForClass:[self class]], @"Prompt of executable choice panel")];
    [openPanel setTitle:NSLocalizedStringFromTableInBundle(@"SELECT_EXECUTABLE_PATH__TITLE", nil, [NSBundle bundleForClass:[self class]], @"Title of executable choice panel")];
    [openPanel beginSheetForDirectory:nil file:[self selectedExecutablePath] types:nil modalForWindow:panel modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (NSString *)selectedExecutablePath
{
    return [[arrayController selection] valueForKey:@"path"];
}

- (void)setSelectedExecutablePath:(NSString *)value
{
    // TODO: [[arrayController selection] valueForKey:@"path"];
}

- (NSImage *)image
{
    return image;
}

- (void)setImage:(NSImage *)value
{
    [value retain];
    [image release];
    image = value;
}

@end
