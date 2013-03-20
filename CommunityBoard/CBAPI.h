//
//  CBAPI.h
//  CommunityBoard
//
//  Created by Matt on 3/20/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBCommunity.h"

@interface CBAPI : NSObject

+ (NSString *)authenticationPath;
+ (NSString *)communitiesPath;
+ (NSString*)postPathWithCommunity:(CBCommunity*)community;
+ (NSString*)postsPathPattern;

@end
