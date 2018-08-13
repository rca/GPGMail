/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */



@class NSMutableDictionary, NSMutableSet, NSOutlineView;

@interface OutlineViewProgressIndicatorsController : NSObject
{
    NSOutlineView *_outlineView;
    NSMutableDictionary *_progressIndicators;
    NSMutableDictionary *_fractionsDone;
    NSMutableDictionary *_origins;
    NSMutableDictionary *_roundDeterminateColors;
    NSMutableSet *_scheduledUpdates;
    NSMutableSet *_scheduledRemovals;
    BOOL _updateScheduled;
}

- (id)init;
- (id)initWithOutlineView:(id)arg1;
- (void)dealloc;
- (void)showIndeterminateProgressIndicatorForItem:(id)arg1;
- (void)showDeterminateProgressIndicatorForItem:(id)arg1 fractionDone:(double)arg2;
- (void)removeProgressIndicatorForItem:(id)arg1;
- (void)removeOrphanProgressIndicators;
- (void)positionProgressIndicatorForItem:(id)arg1 inRect:(struct CGRect)arg2;
- (void)setRoundDeterminateColor:(id)arg1 forProgressIndicatorForItem:(id)arg2;
- (id)_keyForItem:(id)arg1;
- (id)_itemForKey:(id)arg1;
- (id)_progressIndicatorForKey:(id)arg1 createIfNeeded:(BOOL)arg2;
- (void)_setNeedsToUpdateProgressIndicatorForKey:(id)arg1;
- (void)_setNeedsToRemoveProgressIndicatorForKey:(id)arg1;
- (void)_scheduleUpdate;
- (void)_processUpdates;
- (void)_updateProgressIndicatorForKey:(id)arg1;
- (void)_removeProgressIndicatorForKey:(id)arg1;

@end

