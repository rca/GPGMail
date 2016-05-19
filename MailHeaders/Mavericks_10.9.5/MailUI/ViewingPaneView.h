/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSView.h"

@class CALayer, NSImageView, NSMutableArray;

@interface ViewingPaneView : NSView
{
    BOOL _showTopDividerEdgeOnly;
    NSImageView *_snapshotView;
    NSView *_contentView;
    NSMutableArray *_subviewConstraints;
    CALayer *_edgeLayer;
    CALayer *_shadowLayer;
}

@property(nonatomic) CALayer *shadowLayer; // @synthesize shadowLayer=_shadowLayer;
@property(nonatomic) CALayer *edgeLayer; // @synthesize edgeLayer=_edgeLayer;
@property(retain, nonatomic) NSMutableArray *subviewConstraints; // @synthesize subviewConstraints=_subviewConstraints;
@property(retain, nonatomic) NSImageView *snapshotView; // @synthesize snapshotView=_snapshotView;
@property(nonatomic) BOOL showTopDividerEdgeOnly;
@property(nonatomic) BOOL showDividerEdge;
@property(nonatomic) BOOL showingSnapshot;
@property(retain, nonatomic) NSView *contentView; // @synthesize contentView=_contentView;
- (void)didAddSubview:(id)arg1;
- (void)updateLayer;
- (BOOL)wantsUpdateLayer;
- (void)dealloc;
- (id)_buildShadowLayer;
- (id)_buildEdgeLayer;
- (id)makeBackingLayer;
- (void)_createSnapshotView;
- (void)_viewingPaneViewCommonInit;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;

@end

