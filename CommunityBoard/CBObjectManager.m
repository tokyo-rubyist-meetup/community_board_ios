//
//  CBObjectManager.m
//  CommunityBoard
//
//  Created by Matt on 3/18/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "CBObjectManager.h"
#import "CBAPI.h"

@implementation CBObjectManager

- (void)setup {
  RKEntityMapping *communityResponseMapping = [RKEntityMapping
    mappingForEntityForName:@"Community"
    inManagedObjectStore:self.managedObjectStore];
  communityResponseMapping.identificationAttributes = @[ @"communityId" ];
  [communityResponseMapping addAttributeMappingsFromDictionary:@{
    @"id": @"communityId",
    @"created_at": @"createdAt",
    @"post_count": @"postCount"
  }];
  [communityResponseMapping addAttributeMappingsFromArray:@[@"name"]];
  
  RKObjectMapping *postRequestMapping = [RKObjectMapping requestMapping];
  [postRequestMapping addAttributeMappingsFromArray:@[@"text"]];
  
  RKEntityMapping *postsResponseMapping = [RKEntityMapping
    mappingForEntityForName:@"Post"
    inManagedObjectStore:self.managedObjectStore];
  postsResponseMapping.identificationAttributes = @[ @"postId" ];
  [postsResponseMapping addAttributeMappingsFromDictionary:@{
    @"id": @"postId",
    @"created_at": @"createdAt",
  }];
  [postsResponseMapping addAttributeMappingsFromArray:@[@"text"]];
  
  RKEntityMapping *userResponseMapping = [RKEntityMapping
    mappingForEntityForName:@"User"
    inManagedObjectStore:self.managedObjectStore];
  userResponseMapping.identificationAttributes = @[ @"userId" ];
  [userResponseMapping addAttributeMappingsFromDictionary:@{
    @"id": @"userId",
    @"avatar_url": @"avatarURL",
  }];
  [userResponseMapping addAttributeMappingsFromArray:@[@"name"]];
  [postsResponseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user"
    toKeyPath:@"user"
    withMapping:userResponseMapping]];
  
  RKResponseDescriptor *communityResponseDescriptor = [RKResponseDescriptor
    responseDescriptorWithMapping:communityResponseMapping
    pathPattern:[CBAPI communitiesPath]
    keyPath:@"communities"
    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  [self addResponseDescriptor:communityResponseDescriptor];
  
  RKRequestDescriptor *postRequestDescriptor = [RKRequestDescriptor
    requestDescriptorWithMapping:postRequestMapping
    objectClass:[CBPost class]
    rootKeyPath:@"post"];
  [self addRequestDescriptor:postRequestDescriptor];

  RKResponseDescriptor *postsResponseDescriptor = [RKResponseDescriptor
    responseDescriptorWithMapping:postsResponseMapping
    pathPattern:[CBAPI postsPathPattern]
    keyPath:@"posts"
    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  [self addResponseDescriptor:postsResponseDescriptor];
  
  RKResponseDescriptor *postResponseDescriptor = [RKResponseDescriptor
    responseDescriptorWithMapping:postsResponseMapping
    pathPattern:[CBAPI postsPathPattern]
    keyPath:@"post"
    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
  [self addResponseDescriptor:postResponseDescriptor];
}

@end
