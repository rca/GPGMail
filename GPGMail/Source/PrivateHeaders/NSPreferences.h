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

#endif
