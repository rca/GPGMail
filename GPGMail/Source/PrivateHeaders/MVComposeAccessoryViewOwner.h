/* MVComposeAccessoryViewOwner.h created by dave on Thu 29-Jun-2000 */

#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

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

#elif defined(SNOW_LEOPARD)

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

#endif
