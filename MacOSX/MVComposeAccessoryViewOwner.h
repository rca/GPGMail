/* MVComposeAccessoryViewOwner.h created by dave on Thu 29-Jun-2000 */

#import <Cocoa/Cocoa.h>

#ifdef SLEOPARD

@interface MVComposeAccessoryViewOwner : NSObject
{
    NSView *accessoryView;
}

+ (id)composeAccessoryViewOwner;
+ (id)composeAccessoryViewNibName;
- (void)setupUIForMessage:(id)arg1;
- (id)composeAccessoryView;
- (BOOL)messageWillBeDelivered:(id)arg1;
- (BOOL)messageWillBeSaved:(id)arg1;

@end

#elif defined(TIGER)

@class Message;

@interface MVComposeAccessoryViewOwner : NSObject
{
    NSView *accessoryView;
}

+ (id)composeAccessoryViewOwner;
+ (id)composeAccessoryViewNibName;
- (id)init;
- (void)setupUIForMessage:(id)fp8;
- (id)composeAccessoryView;
- (BOOL)messageWillBeDelivered:(id)fp8;
- (BOOL)messageWillBeSaved:(id)fp8;

@end

#else

@interface MVComposeAccessoryViewOwner:NSObject
{
    NSView *accessoryView;	// 4 = 0x4
}

+ composeAccessoryViewOwner; // Creates a new instance at each invocation
+ composeAccessoryViewNibName;
- init;
- (void)setupUIForMessage:fp8;
- composeAccessoryView;
- (BOOL)messageWillBeDelivered:fp8; // No longer invoked; see GPGComposeBackEndPoser
- (BOOL)messageWillBeSaved:fp8;

@end

#endif
