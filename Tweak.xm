#import "Tweak.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


static BOOL enabled, sixonebar, sixfivebar, fuckmeupfam;


%hook _UIStatusBarVisualProvider_iOS
+ (Class)visualProviderSubclassForScreen:(id)arg1 {
  if (enabled && sixonebar && !sixfivebar) {
      return NSClassFromString(@"_UIStatusBarVisualProvider_Split61");
    } else if (enabled && sixfivebar && !sixonebar) {
      return NSClassFromString(@"_UIStatusBarVisualProvider_Split65");
    } else if (enabled && fuckmeupfam && !sixonebar && !sixfivebar) {
      return NSClassFromString(@"_UIStatusBarVisualProvider_SplitFuckMeUp");
    } else if (enabled) {
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
    sixonebar = ( [prefs objectForKey:@"sixonebar"] ? [[prefs objectForKey:@"sixonebar"] boolValue] : YES );
    sixfivebar = ( [prefs objectForKey:@"sixfivebar"] ? [[prefs objectForKey:@"sixfivebar"] boolValue] : YES );
    fuckmeupfam = ( [prefs objectForKey:@"fuckmeupfam"] ? [[prefs objectForKey:@"fuckmeupfam"] boolValue] : YES );
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
