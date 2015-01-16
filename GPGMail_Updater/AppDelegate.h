#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>
#import <Libmacgpg/Libmacgpg.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
	SUUpdater *updater;
}
- (void)terminateIfIdle;

@end
