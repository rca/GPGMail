/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */

@protocol DynamicErrorWindowDelegate <NSObject>
- (BOOL)displayIndeterminateProgress;
- (id)errorMessageForErrorDiagnosis:(long long)arg1;
- (id)errorDescriptionForErrorDiagnosis:(long long)arg1;
- (id)leftButtonTextForErrorDiagnosis:(long long)arg1;
- (id)rightButtonTextForErrorDiagnosis:(long long)arg1;
- (void)leftActionSelectedWithDiagnosis:(long long)arg1;
- (void)rightActionSelectedWithDiagnosis:(long long)arg1;
- (unsigned long long)helpTopicForDiagnosis:(long long)arg1;
@end

