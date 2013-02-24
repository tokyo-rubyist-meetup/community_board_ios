//
//  CBAppDelegate.m
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "CBAppDelegate.h"

#import "CBMasterViewController.h"
#import "CBDetailViewController.h"
#import "CBIncrementalStore.h"

@implementation CBAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
 
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    CBMasterViewController *masterViewController = [[CBMasterViewController alloc]
      initWithNibName:@"CBMasterViewController_iPhone" bundle:nil];
    self.navigationController = [[UINavigationController alloc]
      initWithRootViewController:masterViewController];
    self.window.rootViewController = self.navigationController;
    masterViewController.managedObjectContext = self.managedObjectContext;
  } else {
    CBMasterViewController *masterViewController = [[CBMasterViewController alloc]
      initWithNibName:@"CBMasterViewController_iPad" bundle:nil];
    UINavigationController *masterNavigationController = [[UINavigationController alloc]
      initWithRootViewController:masterViewController];
      
    CBDetailViewController *detailViewController = [[CBDetailViewController alloc]
      initWithNibName:@"CBDetailViewController_iPad" bundle:nil];
    UINavigationController *detailNavigationController = [[UINavigationController alloc]
      initWithRootViewController:detailViewController];
  	
  	masterViewController.detailViewController = detailViewController;
      
    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = detailViewController;
    self.splitViewController.viewControllers = @[masterNavigationController, detailNavigationController];
      
    self.window.rootViewController = self.splitViewController;
  
    masterViewController.managedObjectContext = self.managedObjectContext;
    detailViewController.managedObjectContext = self.managedObjectContext;
  }
  
  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application{
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [self saveContext];
}

- (void)saveContext {
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext) {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
  }
}

#pragma mark - Core Data stack
- (NSManagedObjectContext *)managedObjectContext {
  if (_managedObjectContext) {
    return _managedObjectContext;
  }
    
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator) {
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  
  return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel) {
    return _managedObjectModel;
  }
  
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CommunityBoard" withExtension:@"momd"];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if (_persistentStoreCoordinator) {
    return _persistentStoreCoordinator;
  }
    
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CommunityBoard.sqlite"];
    
  NSError *error = nil;
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
    initWithManagedObjectModel:[self managedObjectModel]];
  
  AFIncrementalStore *incrementalStore = (AFIncrementalStore *)[_persistentStoreCoordinator
    addPersistentStoreWithType:[CBIncrementalStore type]
    configuration:nil
    URL:nil
    options:nil
    error:nil];

  NSDictionary *options = @{
    NSInferMappingModelAutomaticallyOption : @(YES),
    NSMigratePersistentStoresAutomaticallyOption: @(YES)
  };
  
  if (![incrementalStore.backingPersistentStoreCoordinator
   addPersistentStoreWithType:NSSQLiteStoreType
   configuration:nil
   URL:storeURL
   options:options
   error:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }

  return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
  NSArray *directories = [[NSFileManager defaultManager]
    URLsForDirectory:NSDocumentDirectory
    inDomains:NSUserDomainMask];
  
  return [directories lastObject];
}

@end
