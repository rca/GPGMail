/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */

#import "NSFontManager.h"

@interface _MailNSFontManager : NSFontManager
{
    double _fontSize;
    BOOL _isMultiple;
}

- (void)postSelectedFontChangeNotification;
- (void)setSelectedFont:(id)arg1 isMultiple:(BOOL)arg2;
- (void)modifyFontSize:(double)arg1;
- (unsigned long long)currentFontAction;
- (id)convertFont:(id)arg1;

@end

