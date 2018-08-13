/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "MessageListCell.h"

@interface RolloverButtonCell : MessageListCell
{
    id _target;
    SEL _action;
}

@property(nonatomic) SEL action; // @synthesize action=_action;
@property(nonatomic) __weak id target; // @synthesize target=_target;
- (void).cxx_destruct;
- (BOOL)accessibilityPerformPress;
- (id)accessibilityLabel;
- (BOOL)isAccessibilityEnabled;
- (id)accessibilityRole;
- (id)accessibilityValue;
- (BOOL)isAccessibilitySelectorAllowed:(SEL)arg1;
- (unsigned long long)hitTestForEvent:(id)arg1 inRect:(struct CGRect)arg2 ofView:(id)arg3;
- (BOOL)_mf_shouldSendAction;
- (BOOL)_sendActionFrom:(id)arg1;
- (BOOL)trackMouse:(id)arg1 inRect:(struct CGRect)arg2 ofView:(id)arg3 untilMouseUp:(BOOL)arg4;

@end

