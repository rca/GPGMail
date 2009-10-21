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

#if defined(LEOPARD) || defined(TIGER)

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
#ifdef SNOW_LEOPARD
- (struct CGSize)preferencesContentSize;
#else
- (struct _NSSize)preferencesContentSize;
#endif
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
#ifdef SNOW_LEOPARD
- (struct CGSize)windowWillResize:(id)fp8 toSize:(struct CGSize)fp12;
#else
- (struct _NSSize)windowWillResize:(id)fp8 toSize:(struct _NSSize)fp12;
#endif
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
#ifdef SNOW_LEOPARD
    struct CGSize _minSize;
#else
    struct _NSSize _minSize;
#endif
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
#ifdef SNOW_LEOPARD
- (struct CGSize)minSize;
- (void)setMinSize:(struct CGSize)fp8;
#else
- (struct _NSSize)minSize;
- (void)setMinSize:(struct _NSSize)fp8;
#endif
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
#ifdef SNOW_LEOPARD
- (struct CGSize)preferencesContentSize;
#else
- (struct _NSSize)preferencesContentSize;
#endif
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
#ifdef SNOW_LEOPARD
- (struct CGSize)windowWillResize:fp8 toSize:(struct CGSize)fp12;
#else
- (struct _NSSize)windowWillResize:fp8 toSize:(struct _NSSize)fp12;
#endif
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
#ifdef SNOW_LEOPARD
    struct CGSize _minSize;	// 8 = 0x8
#else
    struct _NSSize _minSize;	// 8 = 0x8
#endif
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
#ifdef SNOW_LEOPARD
- (struct CGSize)minSize;
- (void)setMinSize:(struct CGSize)fp8;
#else
- (struct _NSSize)minSize;
- (void)setMinSize:(struct _NSSize)fp8;
#endif
- (void)moduleWillBeRemoved;
- (void)moduleWasInstalled;
- (char)moduleCanBeRemoved;
- (char)preferencesWindowShouldClose;
- (char)isResizable;

@end

#endif
