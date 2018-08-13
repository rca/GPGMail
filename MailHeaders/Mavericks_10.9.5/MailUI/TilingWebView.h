/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "WebView.h"

@interface TilingWebView : WebView
{
    unsigned int _isAdjusting:1;
    unsigned int _disableSizeToFit:1;
    double _minHeight;
    double _leftMargin;
}

@property double minHeight; // @synthesize minHeight=_minHeight;
@property double leftMargin; // @synthesize leftMargin=_leftMargin;
- (void)sizeToFit;
- (id)initWithFrame:(struct CGRect)arg1 frameName:(id)arg2 groupName:(id)arg3;
@property BOOL disableSizeToFit;

@end

