//
//  CBHTTPClient.m
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "CBHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "NSDateFormatter+CommunityBoardExtensions.h"
#import "Post.h"
#import "Community.h"

#define CLIENT_ID @"677ccca1152c8824b823dedfa40c30f4cf4b11ad55687299d0c218f303e40f6e"
#define APP_SECRET @"814172c277147ad83e9725ad14bf2b30966672200ae2362108b47751f407ab8b"

@implementation CBHTTPClient

static NSString *baseURLString = @"https://community-board.herokuapp.com/api/v1/";

+ (CBHTTPClient *)sharedClient {
  static CBHTTPClient *_sharedClient = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    _sharedClient = [[CBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]
      clientID:CLIENT_ID
      secret:APP_SECRET];
  });
    
  return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url clientID:(NSString*)clientID secret:(NSString*)secret {
  if (self = [super initWithBaseURL:url clientID:clientID secret:secret]) {
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFJSONParameterEncoding];
  }
  
  return self;
}

- (NSString*)pathForEntity:(NSEntityDescription *)entity {
  if ([entity.name isEqualToString:@"Community"]) {
    return @"communities";
  }
  
  if ([entity.name isEqualToString:@"Post"]) {
    return @"posts";
  }
  
  return nil;
}

- (NSString*)pathForObject:(NSManagedObject *)object {
  if ([object.entity.name isEqualToString:@"Community"]) {
    Community *community = (Community*)object;
    
    NSString *path = [self pathForEntity:community.entity];
    return path;
  }

  if ([object.entity.name isEqualToString:@"Post"]) {
    Post *post = (Post*)object;
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",
      [self pathForEntity:post.community.entity],
      post.community.communityId,
      [self pathForEntity:post.entity]];
    return path;
  }
  
  return nil;
}

- (NSString*)pathForRelationship:(NSRelationshipDescription *)relationship forObject:(NSManagedObject *)object {
  if ([object.entity.name isEqualToString:@"Community"]) {
    NSString *getPath = [NSString stringWithFormat:@"%@/%@/%@.json",
      [self pathForEntity:relationship.entity],
      [object valueForKeyPath:@"communityId"],
      [self pathForEntity:relationship.destinationEntity]];
    return getPath;
  }
  
  return nil;
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation
 ofEntity:(NSEntityDescription *)entity 
 fromResponse:(NSHTTPURLResponse *)response {
  NSMutableDictionary *mutablePropertyValues = [[super attributesForRepresentation:representation ofEntity:entity fromResponse:response] mutableCopy];
  
  if ([entity.name isEqualToString:@"Community"]) {
    NSString *entityId = [representation valueForKey:@"id"];
    [mutablePropertyValues setValue:entityId forKey:@"communityId"];
    
    NSString *entityCreatedAt = [representation valueForKey:@"created_at"];
    NSDate *entityCreatedAtDate = [[NSDateFormatter RFC3339DateFormatter] dateFromString:entityCreatedAt];
    [mutablePropertyValues setValue:entityCreatedAtDate forKey:@"createdAt"];
  }

  if ([entity.name isEqualToString:@"Post"]) {
    NSString *entityId = [representation valueForKey:@"id"];
    [mutablePropertyValues setValue:entityId forKey:@"postId"];
    
    NSString *entityCreatedAt = [representation valueForKey:@"created_at"];
    NSDate *entityCreatedAtDate = [[NSDateFormatter RFC3339DateFormatter] dateFromString:entityCreatedAt];
    [mutablePropertyValues setValue:entityCreatedAtDate forKey:@"createdAt"];
  }
  
  if ([entity.name isEqualToString:@"User"]) {
    NSString *entityId = [representation valueForKey:@"id"];
    [mutablePropertyValues setValue:entityId forKey:@"userId"];

    NSString *iconUrl = [representation valueForKey:@"avatar_url"];
    [mutablePropertyValues setValue:iconUrl forKey:@"iconURL"];
  }
  
  return mutablePropertyValues;
}

- (NSMutableURLRequest *)requestForInsertedObject:(NSManagedObject *)insertedObject {
  return [self requestWithMethod:@"POST"
    path:[self pathForObject:insertedObject]
    parameters:[self representationOfAttributes:[insertedObject dictionaryWithValuesForKeys:[insertedObject.entity.attributesByName allKeys]]
    ofManagedObject:insertedObject]];
}

- (NSMutableURLRequest *)requestForUpdatedObject:(NSManagedObject *)updatedObject {
  return nil;
}

- (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID *)objectID
 inManagedObjectContext:(NSManagedObjectContext *)context {
  return NO;
}

- (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship
 forObjectWithID:(NSManagedObjectID *)objectID
 inManagedObjectContext:(NSManagedObjectContext *)context {
  return [relationship.entity.name isEqualToString:@"Community"];
}


@end
