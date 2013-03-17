//
//  CBAppDelegate.m
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

#import "CBAppDelegate.h"

#import "CBCommunityViewController.h"
#import "CBLoginViewController.h"
#import "CBPostViewController.h"

#import "RKObjectManager.h"
#import "AFHTTPRequestOperationLogger.h"
#import "AFOAuth2Client.h"

#import "CBCommunity.h"
#import "CBPost.h"

static NSString *baseURLString = @"https://community-board.herokuapp.com/api/v1/";
static NSString *applicationID = @"677ccca1152c8824b823dedfa40c30f4cf4b11ad55687299d0c218f303e40f6e";
static NSString *secret = @"814172c277147ad83e9725ad14bf2b30966672200ae2362108b47751f407ab8b";

@interface CBAppDelegate ()

@property (readwrite, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@end

@implementation CBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  [[UINavigationBar appearance] setTitleTextAttributes:@{
    UITextAttributeFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f],
    UITextAttributeTextColor: [UIColor darkGrayColor],
    UITextAttributeTextShadowColor: [UIColor clearColor]
  }];
  [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
  [[UIBarButtonItem appearance] setTitleTextAttributes:@{
    UITextAttributeFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f],
    UITextAttributeTextColor: [UIColor darkGrayColor],
    UITextAttributeTextShadowColor: [UIColor clearColor]
  } forState:UIControlStateNormal];
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  [[AFHTTPRequestOperationLogger sharedLogger] setLevel:AFLoggerLevelDebug];
  [[AFHTTPRequestOperationLogger sharedLogger] startLogging];

  NSURL *baseURL = [NSURL URLWithString:baseURLString];
  
  AFOAuth2Client *oauthClient = [AFOAuth2Client clientWithBaseURL:baseURL clientID:applicationID secret:secret];
  AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:@"identifier"];
  [oauthClient setParameterEncoding:AFJSONParameterEncoding];
  
  RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:oauthClient];
  RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc]
    initWithManagedObjectModel:self.managedObjectModel];
  objectManager.managedObjectStore = managedObjectStore;
  
  RKEntityMapping *communityMapping = [RKEntityMapping
    mappingForEntityForName:@"Community"
    inManagedObjectStore:managedObjectStore];
  communityMapping.identificationAttributes = @[ @"communityId" ];
  [communityMapping addAttributeMappingsFromDictionary:@{
    @"id": @"communityId",
    @"created_at": @"createdAt",
    @"post_count": @"postCount"
  }];
  [communityMapping addAttributeMappingsFromArray:@[@"name"]];
  
  RKResponseDescriptor *communityResponseDescriptor = [RKResponseDescriptor
    responseDescriptorWithMapping:communityMapping
    pathPattern:@"communities.json"
    keyPath:@"communities"
    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  [objectManager addResponseDescriptor:communityResponseDescriptor];
  
  RKEntityMapping *postResponseMapping = [RKEntityMapping
    mappingForEntityForName:@"Post"
    inManagedObjectStore:managedObjectStore];
  postResponseMapping.identificationAttributes = @[ @"postId" ];
  [postResponseMapping addAttributeMappingsFromDictionary:@{
    @"id": @"postId",
    @"created_at": @"createdAt",
  }];
  [postResponseMapping addAttributeMappingsFromArray:@[@"text"]];
  
  RKResponseDescriptor *postResponseDescriptor = [RKResponseDescriptor
    responseDescriptorWithMapping:postResponseMapping
    pathPattern:@"communities/:communityId/posts.json"
    keyPath:@"posts"
    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  [objectManager addResponseDescriptor:postResponseDescriptor];
  
  RKObjectMapping *postRequestMapping = [RKObjectMapping requestMapping];
  [postRequestMapping addAttributeMappingsFromArray:@[@"text"]];
  
  RKRequestDescriptor *postRequestDescriptor = [RKRequestDescriptor
    requestDescriptorWithMapping:postRequestMapping
    objectClass:[CBPost class]
    rootKeyPath:@"post"];
  [objectManager addRequestDescriptor:postRequestDescriptor];

  RKEntityMapping *userMapping = [RKEntityMapping
    mappingForEntityForName:@"User"
    inManagedObjectStore:managedObjectStore];
  userMapping.identificationAttributes = @[ @"userId" ];
  [userMapping addAttributeMappingsFromDictionary:@{
    @"id": @"userId",
    @"avatar_url": @"avatarURL",
  }];
  [userMapping addAttributeMappingsFromArray:@[@"name"]];
  [postResponseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user"
    toKeyPath:@"user"
    withMapping:userMapping]];

  [objectManager.router.routeSet
    addRoute:[RKRoute
      routeWithName:@"communities"
      pathPattern:@"communities.json"
      method:RKRequestMethodGET]];
  [objectManager.router.routeSet
    addRoute:[RKRoute
      routeWithRelationshipName:@"posts"
      objectClass:[CBCommunity class]
      pathPattern:@"communities/:communityId/posts.json"
      method:RKRequestMethodGET]];
  [objectManager.router.routeSet
    addRoute:[RKRoute
      routeWithClass:[CBPost class]
      pathPattern:@"communities/:communityId/posts.json"
      method:RKRequestMethodPOST]];

  [managedObjectStore createPersistentStoreCoordinator];

  NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"CommunityBoard.sqlite"];
  NSError *error;
  NSPersistentStore *persistentStore = [managedObjectStore
    addSQLitePersistentStoreAtPath:storePath
    fromSeedDatabaseAtPath:nil
    withConfiguration:nil
    options:nil
    error:&error];
  NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);  
  
  [managedObjectStore createManagedObjectContexts];
 
  UIViewController *rootViewController = nil;
 
  if (!credential) {
    rootViewController = [[CBLoginViewController alloc] initWithNibName:nil bundle:nil];
  } else {
    [oauthClient setAuthorizationHeaderWithCredential:credential];
    rootViewController = [[CBCommunityViewController alloc]
      initWithManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel) {
    return _managedObjectModel;
  }
  
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CommunityBoard" withExtension:@"momd"];
  _managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
  return _managedObjectModel;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
  NSArray *directories = [[NSFileManager defaultManager]
    URLsForDirectory:NSDocumentDirectory
    inDomains:NSUserDomainMask];
  
  return [directories lastObject];
}

@end
