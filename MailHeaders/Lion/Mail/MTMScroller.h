/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */

#import "NSScroller.h"

@interface MTMScroller : NSScroller
{
    BOOL _dontNotify;
    id _delegate;
    BOOL _isFakeScroller;
}

- (void)setDoubleValue:(double)arg1;
- (void)_notifyPostScrollPositionChanged;
@property(nonatomic) BOOL isFakeScroller;
- (void)drawKnob;
@property id delegate; // @synthesize delegate=_delegate;
@property BOOL dontNotify; // @synthesize dontNotify=_dontNotify;

@end

