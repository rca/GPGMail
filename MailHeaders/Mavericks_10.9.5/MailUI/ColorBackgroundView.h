/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSView.h"

@class NSArray, NSColor, NSGradient, NSImage;

@interface ColorBackgroundView : NSView
{
    NSColor *_color;
    NSImage *_image;
    NSArray *_colors;
    BOOL _shouldTileImage;
    NSGradient *_gradient;
    BOOL _transparent;
    BOOL _isFlipped;
    double _gradientAngle;
    long long _tag;
    double _rowHeight;
    double _rowOffset;
    NSColor *_imageColor;
}

@property(nonatomic) BOOL transparent; // @synthesize transparent=_transparent;
@property(retain, nonatomic) NSColor *backgroundImageColor; // @synthesize backgroundImageColor=_imageColor;
@property(nonatomic, setter=setFlipped:) BOOL isFlipped; // @synthesize isFlipped=_isFlipped;
@property(nonatomic) double rowOffset; // @synthesize rowOffset=_rowOffset;
@property(nonatomic) double rowHeight; // @synthesize rowHeight=_rowHeight;
@property(nonatomic) long long tag; // @synthesize tag=_tag;
@property(nonatomic) double gradientAngle; // @synthesize gradientAngle=_gradientAngle;
- (id)colorForRow:(unsigned long long)arg1;
- (void)drawRect:(struct CGRect)arg1;
@property(nonatomic) BOOL shouldTileImage;
@property(retain, nonatomic) NSImage *backgroundImage;
- (void)updateBackgroundImageColor;
@property(retain, nonatomic) NSGradient *gradient;
@property(retain, nonatomic) NSColor *backgroundColor;
@property(retain, nonatomic) NSArray *backgroundColors;
- (id)hitTest:(struct CGPoint)arg1;
- (BOOL)isOpaque;
- (void)dealloc;

@end

