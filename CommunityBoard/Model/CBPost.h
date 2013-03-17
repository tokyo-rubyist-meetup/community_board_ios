//
//  CBPost.h
//  CommunityBoard
//
//  Created by Matt on 3/17/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CBCommunity, CBUser;

@interface CBPost : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * postId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) CBCommunity *community;
@property (nonatomic, retain) CBUser *user;

@end
