//
//  Post.h
//  CommunityBoard
//
//  Created by Matt on 3/3/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Community, User;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * postId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Community *community;
@property (nonatomic, retain) User *user;

@end
