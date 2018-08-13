/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

@class NSString, NSURL;

@interface MFJunkMailFilter : NSObject
{
    struct __LSMMap *_map;
    BOOL _isDirty;
    BOOL _useCleanMap;
    BOOL _isInTraining;
    NSURL *_oldMapFileURL;
    NSURL *_mapFileURL;
    NSString *_mapFilePath;
}

+ (void)resetJunkMailUsageCounters;
+ (void)resetJunkMailTrainingBalance;
+ (void)incrementJunkMailTrainingCreditBy:(long long)arg1;
+ (void)incrementJunkMailTrainingDebtBy:(long long)arg1;
+ (BOOL)shouldUpdateTrainingDebt;
+ (id)_junkFilterUsageCounterKeys;
+ (id)sharedInstance;
@property(nonatomic) BOOL isInTraining; // @synthesize isInTraining=_isInTraining;
@property(copy, nonatomic) NSString *mapFilePath; // @synthesize mapFilePath=_mapFilePath;
@property(retain, nonatomic) NSURL *mapFileURL; // @synthesize mapFileURL=_mapFileURL;
@property(retain, nonatomic) NSURL *oldMapFileURL; // @synthesize oldMapFileURL=_oldMapFileURL;
@property(nonatomic) BOOL useCleanMap; // @synthesize useCleanMap=_useCleanMap;
- (void).cxx_destruct;
- (void)_saveTrainingWithDelay;
@property(nonatomic) BOOL isDirty;
- (void)userDidReplyToMessage:(id)arg1;
- (id)trainOnMessages:(id)arg1 junkMailLevel:(long long)arg2;
- (long long)junkMailLevelForMessage:(id)arg1 junkRecorder:(id)arg2;
- (long long)junkMailLevelForMessage:(id)arg1;
- (id)_usageCounter;
@property(readonly, nonatomic) BOOL gatherUsageCounts;
- (id)state;
@property(readonly, nonatomic) BOOL isEnabled;
@property(readonly, nonatomic) long long junkMailTrainingCredit;
@property(readonly, nonatomic) long long junkMailTrainingDebt;
@property(readonly, nonatomic) long long junkMailTrainingBalance;
- (void)saveTraining;
- (void)reset;
@property(readonly, nonatomic) unsigned long long manuallyMarkedAsNotJunkMessageCount;
@property(readonly, nonatomic) unsigned long long manuallyMarkedAsJunkMessageCount;
@property(readonly, nonatomic) unsigned long long evaluatedAsJunkMessageCount;
@property(readonly, nonatomic) unsigned long long evaluatedMessageCount;
- (void)setMap:(struct __LSMMap *)arg1;
- (struct __LSMMap *)map;
- (void)dealloc;

@end

