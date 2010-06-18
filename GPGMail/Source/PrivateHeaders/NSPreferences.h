/* NSPreferences.h created by dave on Tue 14-Sep-1999 */

#import <Cocoa/Cocoa.h>

// Taken from /System/Library/Frameworks/AppKit.framework/AppKit

/*
 * Preferences are read from mainBundle's PreferencePanels.plist file:
 * Keys are
 *  ContentSize (string representation of a NSSize),
 *  UsesButtons (string with 0 or 1)
 *  PreferencePanels (array of dictionaries):
 *   Class (string)
 *   Identifier (string)
 */

#ifdef SNOW_LEOPARD_64

@protocol NSPreferencesModule
- (id)viewForPreferenceNamed:(id)arg1;
- (id)imageForPreferenceNamed:(id)arg1;
- (BOOL)hasChangesPending;
- (void)saveChanges;
- (void)willBeDisplayed;
- (void)initializeFromDefaults;
- (void)didChange;
- (void)moduleWillBeRemoved;
- (void)moduleWasInstalled;
- (BOOL)moduleCanBeRemoved;
- (BOOL)preferencesWindowShouldClose;
@end

@interface NSPreferences : NSObject
{
    NSWindow *_preferencesPanel;
    NSBox *_preferenceBox;
    NSMatrix *_moduleMatrix;
    NSButtonCell *_okButton;
    NSButtonCell *_cancelButton;
    NSButtonCell *_applyButton;
    NSMutableArray *_preferenceTitles;
    NSMutableArray *_preferenceModules;
    NSMutableDictionary *_masterPreferenceViews;
    NSMutableDictionary *_currentSessionPreferenceViews;
    NSBox *_originalContentView;
    BOOL _isModal;
    double _constrainedWidth;
    id _currentModule;
    void *_reserved;
}

+ (id)sharedPreferences;
+ (void)setDefaultPreferencesClass:(Class)arg1;
+ (Class)defaultPreferencesClass;
- (id)init;
- (void)dealloc;
- (void)addPreferenceNamed:(id)arg1 owner:(id)arg2;
- (void)_setupToolbar;
- (void)_setupUI;
- (struct CGSize)preferencesContentSize;
- (void)showPreferencesPanel;
- (void)showPreferencesPanelForOwner:(id)arg1;
- (long long)showModalPreferencesPanelForOwner:(id)arg1;
- (long long)showModalPreferencesPanel;
- (void)ok:(id)arg1;
- (void)cancel:(id)arg1;
- (void)apply:(id)arg1;
- (void)_selectModuleOwner:(id)arg1;
- (id)windowTitle;
- (void)confirmCloseSheetIsDone:(id)arg1 returnCode:(long long)arg2 contextInfo:(void *)arg3;
- (BOOL)windowShouldClose:(id)arg1;
- (void)windowDidResize:(id)arg1;
- (struct CGSize)windowWillResize:(id)arg1 toSize:(struct CGSize)arg2;
- (BOOL)usesButtons;
- (id)_itemIdentifierForModule:(id)arg1;
- (void)toolbarItemClicked:(id)arg1;
- (id)toolbar:(id)arg1 itemForItemIdentifier:(id)arg2 willBeInsertedIntoToolbar:(BOOL)arg3;
- (id)toolbarDefaultItemIdentifiers:(id)arg1;
- (id)toolbarAllowedItemIdentifiers:(id)arg1;
- (id)toolbarSelectableItemIdentifiers:(id)arg1;

@end

@interface NSPreferencesModule : NSObject <NSPreferencesModule>
{
    NSBox *_preferencesView;
    struct CGSize _minSize;
    BOOL _hasChanges;
    void *_reserved;
}

+ (id)sharedInstance;
- (void)dealloc;
- (void)finalize;
- (id)init;
- (id)preferencesNibName;
- (void)setPreferencesView:(id)arg1;
- (id)viewForPreferenceNamed:(id)arg1;
- (id)imageForPreferenceNamed:(id)arg1;
- (id)titleForIdentifier:(id)arg1;
- (BOOL)hasChangesPending;
- (void)saveChanges;
- (void)willBeDisplayed;
- (void)initializeFromDefaults;
- (void)didChange;
- (struct CGSize)minSize;
- (void)setMinSize:(struct CGSize)arg1;
- (void)moduleWillBeRemoved;
- (void)moduleWasInstalled;
- (BOOL)moduleCanBeRemoved;
- (BOOL)preferencesWindowShouldClose;
- (BOOL)isResizable;

@end

#elif defined(SNOW_LEOPARD)

@protocol NSPreferencesModule
- (id)viewForPreferenceNamed:(id)arg1;
- (id)imageForPreferenceNamed:(id)arg1;
- (BOOL)hasChangesPending;
- (void)saveChanges;
- (void)willBeDisplayed;
- (void)initializeFromDefaults;
- (void)didChange;
- (void)moduleWillBeRemoved;
- (void)moduleWasInstalled;
- (BOOL)moduleCanBeRemoved;
- (BOOL)preferencesWindowShouldClose;
@end

@interface NSPreferences : NSObject
{
    NSWindow *_preferencesPanel;
    NSBox *_preferenceBox;
    NSMatrix *_moduleMatrix;
    NSButtonCell *_okButton;
    NSButtonCell *_cancelButton;
    NSButtonCell *_applyButton;
    NSMutableArray *_preferenceTitles;
    NSMutableArray *_preferenceModules;
    NSMutableDictionary *_masterPreferenceViews;
    NSMutableDictionary *_currentSessionPreferenceViews;
    NSBox *_originalContentView;
    BOOL _isModal;
    float _constrainedWidth;
    id _currentModule;
    void *_reserved;
}

+ (id)sharedPreferences;
+ (void)setDefaultPreferencesClass:(Class)arg1;
+ (Class)defaultPreferencesClass;
- (id)init;
- (void)dealloc;
- (void)addPreferenceNamed:(id)arg1 owner:(id)arg2;
- (void)_setupToolbar;
- (void)_setupUI;
- (struct _NSSize)preferencesContentSize;
- (void)showPreferencesPanel;
- (void)showPreferencesPanelForOwner:(id)arg1;
- (int)showModalPreferencesPanelForOwner:(id)arg1;
- (int)showModalPreferencesPanel;
- (void)ok:(id)arg1;
- (void)cancel:(id)arg1;
- (void)apply:(id)arg1;
- (void)_selectModuleOwner:(id)arg1;
- (id)windowTitle;
- (void)confirmCloseSheetIsDone:(id)arg1 returnCode:(int)arg2 contextInfo:(void *)arg3;
- (BOOL)windowShouldClose:(id)arg1;
- (void)windowDidResize:(id)arg1;
- (struct _NSSize)windowWillResize:(id)arg1 toSize:(struct _NSSize)arg2;
- (BOOL)usesButtons;
- (id)_itemIdentifierForModule:(id)arg1;
- (void)toolbarItemClicked:(id)arg1;
- (id)toolbar:(id)arg1 itemForItemIdentifier:(id)arg2 willBeInsertedIntoToolbar:(BOOL)arg3;
- (id)toolbarDefaultItemIdentifiers:(id)arg1;
- (id)toolbarAllowedItemIdentifiers:(id)arg1;
- (id)toolbarSelectableItemIdentifiers:(id)arg1;

@end

@interface NSPreferencesModule : NSObject <NSPreferencesModule>
{
    NSBox *_preferencesView;
    struct _NSSize _minSize;
    BOOL _hasChanges;
    void *_reserved;
}

+ (id)sharedInstance;
- (void)dealloc;
- (void)finalize;
- (id)init;
- (id)preferencesNibName;
- (void)setPreferencesView:(id)arg1;
- (id)viewForPreferenceNamed:(id)arg1;
- (id)imageForPreferenceNamed:(id)arg1;
- (id)titleForIdentifier:(id)arg1;
- (BOOL)hasChangesPending;
- (void)saveChanges;
- (void)willBeDisplayed;
- (void)initializeFromDefaults;
- (void)didChange;
- (struct _NSSize)minSize;
- (void)setMinSize:(struct _NSSize)arg1;
- (void)moduleWillBeRemoved;
- (void)moduleWasInstalled;
- (BOOL)moduleCanBeRemoved;
- (BOOL)preferencesWindowShouldClose;
- (BOOL)isResizable;

@end

#elif defined(LEOPARD) || defined(TIGER)

@protocol NSPreferencesModule
- (id)viewForPreferenceNamed:(id)fp8;
- (id)imageForPreferenceNamed:(id)fp8;
- (BOOL)hasChangesPending;
- (void)saveChanges;
- (void)willBeDisplayed;
- (void)initializeFromDefaults;
- (void)didChange;
- (void)moduleWillBeRemoved;
- (void)moduleWasInstalled;
- (BOOL)moduleCanBeRemoved;
- (BOOL)preferencesWindowShouldClose;
@end

@interface NSPreferences : NSObject
{
    NSWindow *_preferencesPanel;
    NSBox *_preferenceBox;
    NSMatrix *_moduleMatrix;
    NSButtonCell *_okButton;
    NSButtonCell *_cancelButton;
    NSButtonCell *_applyButton;
    NSMutableArray *_preferenceTitles;
    NSMutableArray *_preferenceModules;
    NSMutableDictionary *_masterPreferenceViews;
    NSMutableDictionary *_currentSessionPreferenceViews;
    NSBox *_originalContentView;
    BOOL _isModal;
    float _constrainedWidth;
    id _currentModule;
    void *_reserved;
}

+ (id)sharedPreferences;
+ (void)setDefaultPreferencesClass:(Class)fp8;
+ (Class)defaultPreferencesClass;
- (id)init;
- (void)dealloc;
- (void)addPreferenceNamed:(id)fp8 owner:(id)fp12;
- (void)_setupToolbar;
- (void)_setupUI;
- (struct _NSSize)preferencesContentSize;
- (void)showPreferencesPanel;
- (void)showPreferencesPanelForOwner:(id)fp8;
- (int)showModalPreferencesPanelForOwner:(id)fp8;
- (int)showModalPreferencesPanel;
- (void)ok:(id)fp8;
- (void)cancel:(id)fp8;
- (void)apply:(id)fp8;
- (void)_selectModuleOwner:(id)fp8;
- (id)windowTitle;
- (void)confirmCloseSheetIsDone:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (BOOL)windowShouldClose:(id)fp8;
- (void)windowDidResize:(id)fp8;
- (struct _NSSize)windowWillResize:(id)fp8 toSize:(struct _NSSize)fp12;
- (BOOL)usesButtons;
- (id)_itemIdentifierForModule:(id)fp8;
- (void)toolbarItemClicked:(id)fp8;
- (id)toolbar:(id)fp8 itemForItemIdentifier:(id)fp12 willBeInsertedIntoToolbar:(BOOL)fp16;
- (id)toolbarDefaultItemIdentifiers:(id)fp8;
- (id)toolbarAllowedItemIdentifiers:(id)fp8;
- (id)toolbarSelectableItemIdentifiers:(id)fp8;

@end

@interface NSPreferencesModule : NSObject <NSPreferencesModule>
{
    NSBox *_preferencesView;
    struct _NSSize _minSize;
    BOOL _hasChanges;
    void *_reserved;
}

+ (id)sharedInstance;
- (void)dealloc;
- (void)finalize;
- (id)init;
- (id)preferencesNibName;
- (void)setPreferencesView:(id)fp8;
- (id)viewForPreferenceNamed:(id)fp8;
- (id)imageForPreferenceNamed:(id)fp8;
- (id)titleForIdentifier:(id)fp8;
- (BOOL)hasChangesPending;
- (void)saveChanges;
- (void)willBeDisplayed;
- (void)initializeFromDefaults;
- (void)didChange;
- (struct _NSSize)minSize;
- (void)setMinSize:(struct _NSSize)fp8;
- (void)moduleWillBeRemoved;
- (void)moduleWasInstalled;
- (BOOL)moduleCanBeRemoved;
- (BOOL)preferencesWindowShouldClose;
- (BOOL)isResizable;

@end

#else

@protocol NSPreferencesModule
- (char)preferencesWindowShouldClose;
- (char)moduleCanBeRemoved;
- (void)moduleWasInstalled;
- (void)moduleWillBeRemoved;
- (void)didChange;
- (void)initializeFromDefaults;
- (void)willBeDisplayed;
- (void)saveChanges;
- (char)hasChangesPending;
- imageForPreferenceNamed:fp8;
- viewForPreferenceNamed:fp8;
@end

@interface NSPreferences:NSObject
{
    NSWindow *_preferencesPanel;	// 4 = 0x4
    NSBox *_preferenceBox;	// 8 = 0x8
    NSMatrix *_moduleMatrix;	// 12 = 0xc
    NSButtonCell *_okButton;	// 16 = 0x10
    NSButtonCell *_cancelButton;	// 20 = 0x14
    NSButtonCell *_applyButton;	// 24 = 0x18
    NSMutableArray *_preferenceTitles;	// 28 = 0x1c
    NSMutableArray *_preferenceModules;	// 32 = 0x20
    NSMutableDictionary *_masterPreferenceViews;	// 36 = 0x24
    NSMutableDictionary *_currentSessionPreferenceViews;	// 40 = 0x28
    NSBox *_originalContentView;	// 44 = 0x2c
    char _isModal;	// 48 = 0x30
    float _constrainedWidth;	// 52 = 0x34
    id _currentModule;	// 56 = 0x38
    void *_reserved;	// 60 = 0x3c
}

+ sharedPreferences;
+ (void)setDefaultPreferencesClass:(Class)fp8;
+ (Class)defaultPreferencesClass;
- init;
- (void)dealloc;
- (void)addPreferenceNamed:fp8 owner:fp12;
- (void)_setupToolbar;
- (void)_setupUI;
- (struct _NSSize)preferencesContentSize;
- (void)showPreferencesPanel;
- (void)showPreferencesPanelForOwner:fp8;
- (int)showModalPreferencesPanelForOwner:fp8;
- (int)showModalPreferencesPanel;
- (void)ok:fp8;
- (void)cancel:fp8;
- (void)apply:fp8;
- (void)_selectModuleOwner:fp8;
- windowTitle;
- (void)confirmCloseSheetIsDone:fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (char)windowShouldClose:fp8;
- (void)windowDidResize:fp8;
- (struct _NSSize)windowWillResize:fp8 toSize:(struct _NSSize)fp12;
- (char)usesButtons;
- _itemIdentifierForModule:fp8;
- (void)toolbarItemClicked:fp8;
- toolbar:fp8 itemForItemIdentifier:fp12 willBeInsertedIntoToolbar:(BOOL)fp16;
- toolbarDefaultItemIdentifiers:fp8;
- toolbarAllowedItemIdentifiers:fp8;
- toolbarSelectableItemIdentifiers:fp8;

@end

@interface NSPreferencesModule:NSObject <NSPreferencesModule>
{
    NSBox *_preferencesView;	// 4 = 0x4
    struct _NSSize _minSize;	// 8 = 0x8
    char _hasChanges;	// 16 = 0x10
    void *_reserved;	// 20 = 0x14
}

+ sharedInstance;
- (void)dealloc;
- init;
- preferencesNibName;
- (void)setPreferencesView:fp8;
- viewForPreferenceNamed:fp8;
- imageForPreferenceNamed:fp8;
- titleForIdentifier:fp8;
- (char)hasChangesPending;
- (void)saveChanges;
- (void)willBeDisplayed;
- (void)initializeFromDefaults;
- (void)didChange;
- (struct _NSSize)minSize;
- (void)setMinSize:(struct _NSSize)fp8;
- (void)moduleWillBeRemoved;
- (void)moduleWasInstalled;
- (char)moduleCanBeRemoved;
- (char)preferencesWindowShouldClose;
- (char)isResizable;

@end

#endif
