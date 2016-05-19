/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import <Mail/MFEWSRequestOperation.h>

@class EWSSearchExpressionType, NSArray;

@interface MFEWSFindItemsRequestOperation : MFEWSRequestOperation
{
    NSArray *_additionalProperties;
    NSArray *_EWSFolderIdStrings;
    EWSSearchExpressionType *_searchExpression;
}

+ (Class)classForResponse;
@property(readonly, nonatomic) EWSSearchExpressionType *searchExpression; // @synthesize searchExpression=_searchExpression;
@property(readonly, copy, nonatomic) NSArray *EWSFolderIdStrings; // @synthesize EWSFolderIdStrings=_EWSFolderIdStrings;
@property(readonly, copy, nonatomic) NSArray *additionalProperties; // @synthesize additionalProperties=_additionalProperties;
- (void).cxx_destruct;
- (id)prepareRequest;
- (id)activityString;
- (id)initWithGateway:(id)arg1 errorHandler:(id)arg2;
- (id)initWithSearchExpression:(id)arg1 EWSFolderIdStrings:(id)arg2 additionalProperties:(id)arg3 gateway:(id)arg4;

@end

