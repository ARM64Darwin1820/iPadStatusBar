#import "Tweak.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


static BOOL enabled;


%hook _UIStatusBarVisualProvider_iOS
+ (Class)visualProviderSubclassForScreen:(id)arg1 {
  if (enabled) {
      return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
    } else {
      return %orig;
    }
}

%end


// ===== PREFERENCE HANDLING ===== //

static void loadPrefs() {
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.arm64darwin1820.a12customresfix.plist"];

  if (prefs) {
    enabled = ( [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES );
  }

}

static void update() {
  loadPrefs();

  SBStatusBarStateAggregator *stateAggregator = [%c(SBStatusBarStateAggregator) sharedInstance];
  for (int i = 1; i <= 40; i++) {
      [stateAggregator updateStatusBarItem:i];
  }

}

static void initPrefs() {
  // Copy the default preferences file when the actual preference file doesn't exist
  NSString *path = @"/User/Library/Preferences/com.arm64darwin1820.a12customresfix.plist";
  NSString *pathDefault = @"/Library/PreferenceBundles/A12CustomResFix.bundle/defaults.plist";
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:path]) {
    [fileManager copyItemAtPath:pathDefault toPath:path error:nil];
  }
}

%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)update, CFSTR("com.arm64darwin1820.a12customresfix/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
  initPrefs();
  loadPrefs();
}
