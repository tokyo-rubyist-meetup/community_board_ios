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
//*** Replace this with the code to the OAuth authentication path
  return nil;
}

+ (NSString*)communitiesPath {
//*** Replace this with the code to load the communities list
  return nil;
}

+ (NSString*)postPathWithCommunity:(CBCommunity *)community {
//*** Replace this with the code to load the posts list for a given community
  return nil;
}

+ (NSString*)postsPathPattern {
//*** Replace this with the path pattern to load posts
  return nil;
}


@end
