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

@synthesize title = _title, titleView = _titleView, monochrome = _monochrome;

- (void)dealloc {
    [_title release];
    [_titleView release];
    
    [super dealloc];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _monochrome = YES; 
        _titleView = [[NSTextField alloc] initWithFrame:NSMakeRect(11.0, -3.0, 120.0f, 17.0f)];
        _titleView.backgroundColor = [NSColor clearColor];
        
//        _titleView.font = [NSFont fontWithName:@"LucidaGrande-Bold" size:10.0f];
//        _titleView.textColor = [NSColor whiteColor];
//        _titleView.editable = NO;
//        _titleView.selectable = NO;
//        [_titleView
//        [_titleView sizeToFit];
        
        [self addSubview:_titleView];
        [self setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    if(_title != title)
        [_title release];
    _title = [title retain];
    
    // Create the white shadow that sits behind the text
    NSShadow *shadow = [[NSShadow alloc] init];
    if(self.monochrome)
        [shadow setShadowColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.5]];
    else
        [shadow setShadowColor:[NSColor colorWithDeviceRed:0.0/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.5]];
    [shadow setShadowOffset:NSMakeSize(1.0, -1.1)];
    // Create the attributes dictionary, you can change the font size
    // to whatever is useful to you
    NSFont *font = nil;
    NSColor *color = nil;
    if(self.monochrome) {
        font = [NSFont systemFontOfSize:12.0f];
        color = [NSColor colorWithDeviceRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0];
    }
    else {
        font = [NSFont fontWithName:@"LucidaGrande-Bold" size:10.0f];
        color = [NSColor colorWithDeviceRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    }
    
    NSMutableDictionary *sAttribs = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                      font ,NSFontAttributeName,
                                      shadow, NSShadowAttributeName, color,
                                      NSForegroundColorAttributeName,
                                      nil] autorelease];
    // The shadow object has been assigned to the dictionary, so release
    [shadow release];
    // Create a new attributed string with your attributes dictionary attached
    NSAttributedString *s = [[NSAttributedString alloc] initWithString:_title
                                                            attributes:sAttribs];
    // Set your text value
    [_titleView setAttributedStringValue:s];
    _titleView.selectable = NO;
    _titleView.editable = NO;
    [_titleView setBezeled:NO];
    // Clean up
    [s release];
}

- (void)drawRect:(NSRect)dirtyRect {
    if(self.monochrome)
        return;
    
    NSRect rect = [self bounds];
    rect.origin = NSMakePoint(0, 0);  
    float cornerRadius = 4.0f;
    NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:rect inCorners:KBTopRightCorner | KBBottomLeftCorner cornerRadius:cornerRadius flipped:NO];
    
    NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:0/255.0f green:128/255.0f blue:0/255.0f alpha:1.0], 0.0f,
                            [NSColor colorWithDeviceRed:0/255.0f green:146/255.0f blue:0/255.0f alpha:1.0], 0.13f,
                            [NSColor colorWithDeviceRed:0/255.0f green:146/255.0f blue:0/255.0f alpha:1.0], 0.27f,
                            [NSColor colorWithDeviceRed:0/255.0f green:164/255.0f blue:0/255.0f alpha:1.0], 0.61f,
                            [NSColor colorWithDeviceRed:0/255.0f green:182/255.0f blue:0/255.0f alpha:1.0], 1.0f,
                            nil];
    [gradient drawInBezierPath:path angle:90.0f];
    [[NSColor colorWithDeviceRed:0/255.0f green:128/255.0f blue:0/255.0f alpha:1.0] setStroke];
    [path strokeInside];
    [gradient release];
}

@end
