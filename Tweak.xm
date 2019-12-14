#import "Tweak.h"
#import <spawn.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


static BOOL enabled, sixonebar, sixfivebar, fuckmeupfam, safeguard;
BOOL powerPressed = NO;
NSTimer *resetTimer;


/**if(betaimplementation) {
    @implementation MyHook
    - (NSClass *) betatest {
        return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
    }
    void MSHookMessageEx(Class _UIStatusBarVisualProvider_iOS, SEL visualProviderSubclassForScreen, IMP MyHook, IMP *old);
}**/

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

// the basis for the following code is https://github.com/gilshahar7/VolumeSongSkipper113 and /r/jailbreakdevelopers //


%hook SpringBoard

    
    -(_Bool)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1
    {
        if(safeguard)
        {
            BOOL hasLock = NO;


            for(UIPress* press in arg1.allPresses.allObjects) {
                if (press.type == 104 && press.force == 1) {
                    hasLock = YES;
                }
            }



            int type = arg1.allPresses.allObjects[0].type;
            int force = arg1.allPresses.allObjects[0].force;

            // type = 101 -> Home button
            // type = 104 -> Power button
            // if I remember well, 102 and 103 are volume buttons

            // force = 0 -> button released
            // force = 1 -> button pressed
            
            if(type == 104 && force == 1) //POWER PRESSED
            {
                powerPressed = YES;
                resetTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(resetResolution) userInfo:nil repeats:NO];

            }

            if(type == 104 && force == 0) //POWER RELEASED
            {
                powerPressed = NO;
                if (resetTimer != nil) {
                    [resetTimer invalidate];
                    resetTimer = nil;
                }
            }

            return %orig;
        } else {
            return %orig;
        }
    }

    %new
    - (void)resetResolution
    {
        if (powerPressed) {
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/iofbres"]) {
              pid_t pid;

              const char* args[] = {"iofbres", "r", NULL};

              posix_spawn(&pid, "/usr/bin/iofbres", NULL, NULL, (char* const*)args, NULL);
                
            } else {
                pid_t pid;
                const char* args[] = {"rm", "-f", "/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist", NULL};
                posix_spawn(&pid, "/bin/rm", NULL, NULL, (char* const*)args, NULL);
                
                pid_t pidtwo;

                const char* argstwo[] = {"killall", "backboardd", NULL};

                posix_spawn(&pidtwo, "/usr/bin/killall", NULL, NULL, (char* const*)argstwo, NULL);
            }
            powerPressed = NO;
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
    safeguard = ( [prefs objectForKey:@"safeguard"] ? [[prefs objectForKey:@"safeguard"] boolValue] : YES );
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
    //CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)resetvprov, CFSTR("com.arm64darwin1820.a12customresfix/resetvisualprovider"), NULL, CFNotificationSuspensionBehaviorCoalesce);
  initPrefs();
  loadPrefs();
}
