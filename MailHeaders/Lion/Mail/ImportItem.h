/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */



@class NSString;

@interface ImportItem : NSObject
{
    BOOL _isEnabled;
    NSString *_displayName;
    double _progressValue;
    double _progressStart;
    NSString *_fullPath;
    NSString *_relativePath;
    long long _itemCount;
    id _identifier;
    long long _subfolderCount;
    id _importFields;
}

- (void)dealloc;
- (BOOL)isEnabled;
- (void)setIsEnabled:(BOOL)arg1;
- (id)displayName;
- (void)setDisplayName:(id)arg1;
- (double)progressValue;
- (void)setProgressValue:(double)arg1;
- (double)progressStart;
- (void)setProgressStart:(double)arg1;
- (id)fullPath;
- (void)setFullPath:(id)arg1;
- (id)relativePath;
- (void)setRelativePath:(id)arg1;
- (long long)itemCount;
- (void)setItemCount:(long long)arg1;
- (id)identifier;
- (void)setIdentifier:(id)arg1;
- (long long)subfolderCount;
- (void)setSubfolderCount:(long long)arg1;
- (id)importFields;
- (void)setImportFields:(id)arg1;

@end

