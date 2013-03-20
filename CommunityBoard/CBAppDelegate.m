//
//  CBAppDelegate.m
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "CBAppDelegate.h"

#import "CBCommunityViewController.h"
#import "CBLoginViewController.h"
#import "CBPostViewController.h"
#import "CBObjectManager.h"

#import "CBCommunity.h"
#import "CBPost.h"

NSString * const CBCredentialIdentifier = @"CBCredentialIdentifier";
NSString * const CBFontName = @"HelveticaNeue-Light";

const CGFloat CBFontLargeSize = 17.0f;
const CGFloat CBFontSmallSize = 13.0f;

static NSString * const baseURLString = @"";
static NSString * const applicationID = @"";
static NSString * const secret = @"";

@interface CBAppDelegate ()

@property (readwrite, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readwrite, strong, nonatomic) RKManagedObjectStore *managedObjectStore;

@end

@implementation CBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self setupAppearanceProxy];

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
 
  AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:CBCredentialIdentifier];
  
  NSURL *baseURL = [NSURL URLWithString:baseURLString];

  AFOAuth2Client *oauthClient = [AFOAuth2Client clientWithBaseURL:baseURL clientID:applicationID secret:secret];
  [oauthClient setParameterEncoding:AFJSONParameterEncoding];
  
  CBObjectManager *objectManager = [[CBObjectManager alloc] initWithHTTPClient:oauthClient];
  objectManager.managedObjectStore = self.managedObjectStore;
  [objectManager setup];
  
  UIViewController *rootViewController = nil;
 
  if (!credential) {
    rootViewController = [[CBLoginViewController alloc] initWithNibName:nil bundle:nil];
  } else {
    [oauthClient setAuthorizationHeaderWithCredential:credential];
    rootViewController = [[CBCommunityViewController alloc]
      initWithManagedObjectContext:self.managedObjectStore.mainQueueManagedObjectContext];
  }
  
  self.navigationController = [[UINavigationController alloc]
    initWithRootViewController:rootViewController];
  self.window.rootViewController = self.navigationController;
  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application{
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  NSError *error = nil;

  [[[self managedObjectStore] mainQueueManagedObjectContext] saveToPersistentStore:&error];
  
  if (error) {
    NSLog(@"%@", error.localizedDescription);
  }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
  NSError *error = nil;

  [[[self managedObjectStore] mainQueueManagedObjectContext] saveToPersistentStore:&error];
  
  if (error) {
    NSLog(@"%@", error.localizedDescription);
  }
}

#pragma mark - Private Methods
- (void)setupAppearanceProxy {
  // Community Board uses Twitter Bootstrap on the server, so a few simple changes will make the iOS App have a similar
  // theme.
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  [[UINavigationBar appearance] setTitleTextAttributes:@{
    UITextAttributeFont:[UIFont fontWithName:CBFontName size:CBFontLargeSize],
    UITextAttributeTextColor: [UIColor darkGrayColor],
    UITextAttributeTextShadowColor: [UIColor clearColor]
  }];
  [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
  [[UIBarButtonItem appearance] setTitleTextAttributes:@{
    UITextAttributeFont:[UIFont fontWithName:CBFontName size:CBFontSmallSize],
    UITextAttributeTextColor: [UIColor darkGrayColor],
    UITextAttributeTextShadowColor: [UIColor clearColor]
  } forState:UIControlStateNormal];
}

- (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel) {
    return _managedObjectModel;
  }
  
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CommunityBoard" withExtension:@"momd"];
  _managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
  return _managedObjectModel;
}

- (RKManagedObjectStore*)managedObjectStore {
  if (_managedObjectStore) {
    return _managedObjectStore;
  }
  
  _managedObjectStore = [[RKManagedObjectStore alloc]
    initWithManagedObjectModel:self.managedObjectModel];
  [_managedObjectStore createPersistentStoreCoordinator];

  NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"CommunityBoard.sqlite"];
  NSError *error = nil;
  NSPersistentStore *persistentStore = [_managedObjectStore
    addSQLitePersistentStoreAtPath:storePath
    fromSeedDatabaseAtPath:nil
    withConfiguration:nil
    options:nil
    error:&error];
  NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
  
  [_managedObjectStore createManagedObjectContexts];
  
  return _managedObjectStore;
}

@end
