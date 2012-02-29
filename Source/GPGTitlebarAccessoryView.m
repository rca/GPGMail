/* GPGTitlebarAccessoryView.m created by Lukas Pitschl (lukele) on Sat 27-Aug-2011 */

/*
 * Copyright (c) 2000-2011, GPGTools Project Team <gpgtools-devel@lists.gpgtools.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGTools Project Team nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGTools Project Team ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGTools Project Team BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSBezierPath+StrokeExtensions.h"
#import "NSBezierPath_KBAdditions.h"
#import "GPGTitlebarAccessoryView.h"

@implementation GPGTitlebarAccessoryView

@synthesize color = _color, fullscreen = _fullscreen;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _color = 0;
        [self setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect rect = [self bounds];
    rect.origin = NSMakePoint(0, 0);  
    float cornerRadius = 4.0f;
    KBCornerType corners = self.fullscreen ? (KBTopLeftCorner | KBBottomLeftCorner | KBTopRightCorner | KBBottomRightCorner) : (KBTopRightCorner | KBBottomLeftCorner);
    NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:rect inCorners:corners cornerRadius:cornerRadius flipped:NO];
    
    NSGradient *gradient = nil;
    NSUInteger greenStartColor = 128.0f;
    NSUInteger greyStartColor = 146.0f;
    NSUInteger greenStep = 18.0f;
    NSUInteger greyStep = 18.0f;
    
    NSUInteger redStart = 20.0f;
    NSUInteger greenStart = 80.0f;
    NSUInteger blueStart = 240.0f;
    NSUInteger redStep = 18.0f;
    
    // Color 0 = grey (No security method),
    //       1 = green (PGP security method), 
    //       2 = blue (S/MIME security method).
    if(self.color == 1) {        
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:0/255.0f green:greenStartColor/255.0f blue:0/255.0f alpha:1.0], 0.0f,
                                [NSColor colorWithDeviceRed:0/255.0f green:(greenStartColor + (greenStep * 1))/255.0f blue:0/255.0f alpha:1.0], 0.13f,
                                [NSColor colorWithDeviceRed:0/255.0f green:(greenStartColor + (greenStep * 1))/255.0f blue:0/255.0f alpha:1.0], 0.27f,
                                [NSColor colorWithDeviceRed:0/255.0f green:(greenStartColor + (greenStep * 2))/255.0f blue:0/255.0f alpha:1.0], 0.61f,
                                [NSColor colorWithDeviceRed:0/255.0f green:(greenStartColor + (greenStep * 3))/255.0f blue:0/255.0f alpha:1.0], 1.0f, nil];
    }
    else if(self.color == 2) {
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:redStart/255.0f green:greenStart/255.0f blue:blueStart/255.0f alpha:1.0], 0.0f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 1))/255.0f green:(greenStart + (greenStep * 1))/255.0f blue:blueStart/255.0f alpha:1.0], 0.13f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 1))/255.0f green:(greenStart + (greenStep * 1))/255.0f blue:blueStart/255.0f alpha:1.0], 0.27f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 2))/255.0f green:(greenStart + (greenStep * 2))/255.0f blue:blueStart/255.0f alpha:1.0], 0.61f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 3))/255.0f green:(greenStart + (greenStep * 3))/255.0f blue:blueStart/255.0f alpha:1.0], 1.0f, nil];
    }
    else {
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:greyStartColor/255.0f green:128.0f/255.0f blue:128.0f/255.0f alpha:1.0], 0.0f,
                    [NSColor colorWithDeviceRed:(greyStartColor + (greyStep * 1))/255.0f green:(greyStartColor + (greyStep * 1))/255.0f blue:(greyStartColor + (greyStep * 1))/255.0f alpha:1.0], 0.13f,
                    [NSColor colorWithDeviceRed:(greyStartColor + (greyStep * 1))/255.0f green:(greyStartColor + (greyStep * 1))/255.0f blue:(greyStartColor + (greyStep * 1))/255.0f alpha:1.0], 0.27f,
                    [NSColor colorWithDeviceRed:(greyStartColor + (greyStep * 2))/255.0f green:(greyStartColor + (greyStep * 2))/255.0f blue:(greyStartColor + (greyStep * 2))/255.0f alpha:1.0], 0.61f,
                    [NSColor colorWithDeviceRed:(greyStartColor + (greyStep * 3))/255.0f green:(greyStartColor + (greyStep * 3))/255.0f blue:(greyStartColor + (greyStep * 3))/255.0f alpha:1.0], 1.0f,
                    nil];
    }
    [gradient drawInBezierPath:path angle:90.0f];
    if(self.color == 1)
        [[NSColor colorWithDeviceRed:0/255.0f green:greenStartColor/255.0f blue:0/255.0f alpha:1.0] setStroke];
    else if(self.color == 2)
        [[NSColor colorWithDeviceRed:redStart/255.0f green:greenStart/255.0f blue:blueStart/255.0f alpha:1.0] setStroke];
    else
        [[NSColor colorWithDeviceRed:greyStartColor/255.0f green:greyStartColor/255.0f blue:greyStartColor/255.0f alpha:1.0] setStroke];
    
    [path strokeInside];
    [gradient release];
}

- (void)setColor:(NSUInteger)color {
    _color = color;
    [self setNeedsDisplay:YES];
}

- (void)setFullscreen:(BOOL)fullscreen {
    _fullscreen = fullscreen;
    [self setNeedsDisplay:YES];
}

- (NSAttributedString *)coloredTitle:(NSString *)title monochrome:(BOOL)monochrome {
    // Create the white shadow that sits behind the text
    NSShadow *shadow = [[NSShadow alloc] init];
    if(monochrome)
        [shadow setShadowColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.5]];
    else
        [shadow setShadowColor:[NSColor colorWithDeviceRed:0.0/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.5]];
    [shadow setShadowOffset:NSMakeSize(1.0, -1.1)];
    // Create the attributes dictionary, you can change the font size
    // to whatever is useful to you
    NSFont *font = nil;
    NSColor *color = nil;
    if(monochrome) {
        font = [NSFont systemFontOfSize:10.0f];
        color = [NSColor colorWithDeviceRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0];
    }
    else {
        font = [NSFont fontWithName:@"LucidaGrande-Bold" size:10.0f];
        color = [NSColor colorWithDeviceRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    }
    
    NSMutableDictionary *attributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        font ,NSFontAttributeName,
                                        shadow, NSShadowAttributeName, color,
                                        NSForegroundColorAttributeName,
                                        nil] autorelease];
    // The shadow object has been assigned to the dictionary, so release
    [shadow release];
    // Create a new attributed string with your attributes dictionary attached
    NSAttributedString *coloredTitle = [[NSAttributedString alloc] initWithString:title
                                                                       attributes:attributes];
    return [coloredTitle autorelease];
}

- (void)addSubview:(NSView *)aView {
    [super addSubview:aView];
    return;
    NSRect frame = [self frame];
    NSUInteger maxWidth = 0;
    for(NSView *view in [self subviews]) {
        maxWidth = MAX(maxWidth, view.frame.size.width);
    }
    if(frame.size.width > maxWidth) {
        frame.size.width = maxWidth;
    }
    [self setFrame:frame];
}

@end
