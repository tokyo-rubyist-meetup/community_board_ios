//
//  CBAPI.m
//  CommunityBoard
//
//  Created by Matt on 3/20/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "CBAPI.h"
#import <RestKit/RestKit.h>

@implementation CBAPI

+ (NSString *)authenticationPath {
  return @"/oauth/token";
}

+ (NSString*)communitiesPath {
  return @"communities.json";
}

+ (NSString*)postPathWithCommunity:(CBCommunity *)community {
  return RKPathFromPatternWithObject([self postsPathPattern], community);
}

+ (NSString*)postsPathPattern {
  return @"communities/:communityId/posts.json";
}


@end
