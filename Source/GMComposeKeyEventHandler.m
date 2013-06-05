#import "GMComposeKeyEventHandler.h"

@implementation GMComposeKeyEventHandler
@synthesize eventsAndSelectors;

- (id)initWithView:(NSView *)view {
	if (!(self = [super initWithFrame:NSMakeRect(0, 0, 0, 0)])) {
		return nil;
	}
	// Hang into the responder chain.
	[view addSubview:self];
	return self;
}


- (BOOL)performKeyEquivalent:(NSEvent *)event {
	for (NSDictionary *dict in self.eventsAndSelectors) {
		NSString *keyEquivalent = [dict objectForKey:@"keyEquivalent"];
		NSUInteger keyEquivalentModifierMask = [[dict objectForKey:@"keyEquivalentModifierMask"] unsignedIntegerValue];
		
		if ((event.modifierFlags & NSDeviceIndependentModifierFlagsMask) == keyEquivalentModifierMask && [keyEquivalent isEqualToString:event.charactersIgnoringModifiers]) {
			id target = [dict objectForKey:@"target"];
			SEL selector = [[dict objectForKey:@"selector"] pointerValue];
	
			[target performSelector:selector withObject:self];
			return YES;
		}
	}
	
	return [super performKeyEquivalent:event];
}


@end
