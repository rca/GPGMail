//
//  NSBezierPath_KBAdditions.m
//  --------------------------
//
//  Created by Keith Blount on 06/05/2006.
//  Copyright 2006 Keith Blount. All rights reserved.
//

#import "NSBezierPath_KBAdditions.h"


@implementation NSBezierPath(KBAdditions)

+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)aRect
								  inCorners:(KBCornerType)corners
							   cornerRadius:(float)radius
									flipped:(BOOL)isFlipped
{
	NSBezierPath* path = [self bezierPath];
	radius = MIN(radius, 0.5f * MIN(NSWidth(aRect), NSHeight(aRect)));
	NSRect rect = NSInsetRect(aRect, radius, radius);
	
	if (corners & (isFlipped ? KBTopLeftCorner : KBBottomLeftCorner))
	{
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect))
										 radius:radius
									 startAngle:180.0
									   endAngle:270.0];
	}
	else
	{
		NSPoint cornerPoint = NSMakePoint(NSMinX(aRect), NSMinY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
	
	if (corners & (isFlipped ? KBTopRightCorner : KBBottomRightCorner))
	{
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMinY(rect))
										 radius:radius
									 startAngle:270.0
									   endAngle:360.0];
	}
	else
	{
		NSPoint cornerPoint = NSMakePoint(NSMaxX(aRect), NSMinY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
	
	if (corners & (isFlipped ? KBBottomRightCorner : KBTopRightCorner))
	{
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMaxY(rect))
										 radius:radius
									 startAngle:0.0
									   endAngle:90.0];
	}
	else
	{
		NSPoint cornerPoint = NSMakePoint(NSMaxX(aRect), NSMaxY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
	
	if (corners & (isFlipped ? KBBottomLeftCorner : KBTopLeftCorner))
	{
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMaxY(rect))
										 radius:radius
									 startAngle:90.0
									   endAngle:180.0];
	}
	else
	{
		NSPoint cornerPoint = NSMakePoint(NSMinX(aRect), NSMaxY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
	
	[path closePath];
	return path;	
}

+ (NSBezierPath*)bezierPathWithRoundedRect:(NSRect)aRect cornerRadius:(float)radius
{
	return [NSBezierPath bezierPathWithRoundedRect:aRect
										 inCorners:KBTopLeftCorner|KBTopRightCorner|KBBottomRightCorner|KBBottomLeftCorner
									  cornerRadius:radius
										   flipped:NO];
}

@end
