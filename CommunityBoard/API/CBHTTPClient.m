//
//  CBHTTPClient.m
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "CBHTTPClient.h"
#import "AFJSONRequestOperation.h"

@implementation CBHTTPClient

static NSString *baseURLString = @"https://community-board.herokuapp.com/";

+ (CBHTTPClient *)sharedClient {
  static CBHTTPClient *_sharedClient = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    _sharedClient = [[CBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
  });
    
  return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {  
  if (self = [super initWithBaseURL:url]) {
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
  }
  
  return self;
}

- (NSString *)pathForEntity:(NSEntityDescription *)entity {
  if ([entity.name isEqualToString:@"Community"]) {
    return @"communities.json";
  }  

  if ([entity.name isEqualToString:@"Post"]) {
    return @"communities/0/post.json";
  }

  return nil;
}

- (id)representationOrArrayOfRepresentationsFromResponseObject:(id)responseObject {
  return responseObject;
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation
 ofEntity:(NSEntityDescription *)entity 
 fromResponse:(NSHTTPURLResponse *)response {
  NSMutableDictionary *mutablePropertyValues = [[super attributesForRepresentation:representation ofEntity:entity fromResponse:response] mutableCopy];
  
  if ([entity.name isEqualToString:@"Community"]) {
    NSString *entityId = [representation valueForKey:@"id"];
    [mutablePropertyValues setValue:entityId forKey:@"communityId"];
  }

  if ([entity.name isEqualToString:@"Post"]) {
    NSString *entityId = [representation valueForKey:@"id"];
    [mutablePropertyValues setValue:entityId forKey:@"postId"];
  }
  
  if ([entity.name isEqualToString:@"User"]) {
    NSString *entityId = [representation valueForKey:@"id"];
    [mutablePropertyValues setValue:entityId forKey:@"userId"];

    NSString *iconUrl = [representation valueForKey:@"icon-url"];
    [mutablePropertyValues setValue:iconUrl forKey:@"iconURL"];
  }
  
  return mutablePropertyValues;
}

- (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID *)objectID
 inManagedObjectContext:(NSManagedObjectContext *)context {
  return NO;
}

- (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship
 forObjectWithID:(NSManagedObjectID *)objectID
 inManagedObjectContext:(NSManagedObjectContext *)context {
  return NO;
}


@end
