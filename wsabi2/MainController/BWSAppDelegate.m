// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#include "BWSDDLog.h"

#import "BWSAppDelegate.h"

#import "BWSCrashHandler.h"
#import "BWSViewController.h"

@interface BWSAppDelegate()
- (void)initializeSettings;
@end

@implementation BWSAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize viewController = _viewController;

@synthesize fileLogger;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if !(TARGET_IPHONE_SIMULATOR)
    [BWSCrashHandler setupCrashHandling];
#endif
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[BWSViewController alloc] initWithNibName:@"BWSViewController" bundle:nil];
    self.viewController.managedObjectContext = self.managedObjectContext;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.viewController];

    self.window.rootViewController = nav;

    //Set up logging
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Based on Lumberjack's WebServerIPhone example.

    // We also want to direct our log messages to a file.
	// So we're going to setup file logging.
	// 
	// We start by creating a file logger.
#if TARGET_OS_IPHONE
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	NSString *logsDirectory = baseDir;//[baseDir stringByAppendingPathComponent:@"Logs"];
    fileLogger = [[DDFileLogger alloc] initWithLogFileManager:[[DDLogFileManagerDefault alloc] initWithLogsDirectory:logsDirectory]];
#else
    
	fileLogger = [[DDFileLogger alloc] init];
#endif
    
	// Configure some sensible defaults for an iPhone application.
	// 
	// Roll the file when it gets to be 1024 KB or 24 Hours old (whichever comes first).
	// 
	// Also, only keep up to 8 archived log files around at any given time.
	// We don't want to take up too much disk space.
	
	fileLogger.maximumFileSize = 1024 * 1024;    // 1024 KB
	fileLogger.rollingFrequency = 60 * 60 * 24; //  24 Hours
	
	fileLogger.logFileManager.maximumNumberOfLogFiles = 8;
	
	// Add our file logger to the logging system.
	
	[DDLog addLogger:fileLogger];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [self saveContext];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [self initializeSettings];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"wsabi2" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"wsabi2.sqlite"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, 
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        DDLogBWSVerbose(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

- (void)saveContext
{
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         */
        DDLogBWSVerbose(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}

# pragma mark - Settings

- (void)initializeSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    // Default values for settings
    if ([defaults objectForKey:kSettingsLoggingPanelEnabled] == nil)
        [defaults setBool:kSettingsLoggingPanelEnabledDefault forKey:kSettingsLoggingPanelEnabled];
    if ([defaults objectForKey:kSettingsMotionLoggingEnabled] == nil)
        [defaults setBool:kSettingsMotionLoggingEnabledDefault forKey:kSettingsMotionLoggingEnabled];
    if ([defaults objectForKey:kSettingsNetworkLoggingEnabled] == nil)
        [defaults setBool:kSettingsNetworkLoggingEnabledDefault forKey:kSettingsNetworkLoggingEnabled];
    if ([defaults objectForKey:kSettingsTouchLoggingEnabled] == nil)
        [defaults setBool:kSettingsTouchLoggingEnabledDefault forKey:kSettingsTouchLoggingEnabled];
    if ([defaults objectForKey:kSettingsDeviceLoggingEnabled] == nil)
        [defaults setBool:kSettingsDeviceLoggingEnabledDefault forKey:kSettingsDeviceLoggingEnabled];
    if ([defaults objectForKey:kSettingsAdvancedOptionsEnabled] == nil)
        [defaults setBool:NO forKey:kSettingsAdvancedOptionsEnabled];
    if ([defaults objectForKey:kSettingsCancelCaptureOnDismiss] == nil)
        [defaults setBool:NO forKey:kSettingsCancelCaptureOnDismiss];
    if ([defaults objectForKey:kSettingsVerboseLoggingEnabled] == nil)
        [defaults setBool:kSettingsVerboseLoggingEnabledDefault forKey:kSettingsVerboseLoggingEnabled];
    
    // Show or hide the advanced settings button
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsAdvancedOptionsEnabled] == YES)
        [[[self viewController] navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:[self viewController] action:@selector(showAdvancedOptionsPopover:)]];
    else
        [[[self viewController] navigationItem] setRightBarButtonItem:nil];
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
