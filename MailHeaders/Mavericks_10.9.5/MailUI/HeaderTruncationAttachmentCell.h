/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSTextAttachmentCell.h"

@class NSColor;

@interface HeaderTruncationAttachmentCell : NSTextAttachmentCell
{
    NSColor *_textColor;
}

@property(copy, nonatomic) NSColor *textColor; // @synthesize textColor=_textColor;
- (void)drawWithFrame:(struct CGRect)arg1 inView:(id)arg2;
- (struct CGRect)cellFrameForTextContainer:(id)arg1 proposedLineFragment:(struct CGRect)arg2 glyphPosition:(struct CGPoint)arg3 characterIndex:(unsigned long long)arg4;
- (struct CGSize)cellSizeForBounds:(struct CGRect)arg1;
- (struct CGSize)cellSize;
- (struct CGPoint)cellBaselineOffset;
- (struct CGRect)titleRectForBounds:(struct CGRect)arg1;
- (id)_textAttributes;
- (void)dealloc;

@end

