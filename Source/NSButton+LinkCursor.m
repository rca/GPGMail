#import "NSButton+LinkCursor.h"

@implementation NSButton_LinkCursor
- (void)resetCursorRects {
	[self addCursorRect:[self bounds] cursor:[NSCursor pointingHandCursor]];
}
@end
