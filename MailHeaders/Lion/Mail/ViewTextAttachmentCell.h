/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */

#import "NSViewTextAttachmentCell.h"

@class NSView;

@interface ViewTextAttachmentCell : NSViewTextAttachmentCell
{
    NSView *_view;
    NSView *_containingView;
    struct CGSize _viewSize;
}

- (void)_viewFrameChanged;
- (void)_viewFrameChanged:(id)arg1;
- (id)initWithView:(id)arg1;
- (id)controlView;
- (void)setControlView:(id)arg1;
- (id)view;
- (id)viewWithFrame:(struct CGRect)arg1 forView:(id)arg2 characterIndex:(unsigned long long)arg3 layoutManager:(id)arg4;
- (struct CGSize)cellSize;
- (void)releaseView:(id)arg1;
- (void)dealloc;

@end

