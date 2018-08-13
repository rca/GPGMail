/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */

#import "NSOutlineView.h"

@class FavoritesMenuController, NSTrackingArea;

@interface FavoritesMenuOutlineView : NSOutlineView
{
    FavoritesMenuController *_controller;
    NSTrackingArea *_trackingArea;
}

- (id)initWithFrame:(struct CGRect)arg1;
- (void)dealloc;
- (void)updateTrackingAreas;
- (void)mouseExited:(id)arg1;
- (void)mouseMoved:(id)arg1;
- (void)mouseDown:(id)arg1;
- (void)scrollWheel:(id)arg1;
- (void)highlightSelectionInClipRect:(struct CGRect)arg1;
@property FavoritesMenuController *controller; // @synthesize controller=_controller;

@end

