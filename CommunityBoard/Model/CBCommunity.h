//
//  CBCommunity.h
//  CommunityBoard
//
//  Created by Matt on 3/17/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CBPost;

@interface CBCommunity : NSManagedObject

@property (nonatomic, retain) NSNumber * communityId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * postCount;
@property (nonatomic, retain) NSSet *posts;
@end

@interface CBCommunity (CoreDataGeneratedAccessors)

- (void)addPostsObject:(CBPost *)value;
- (void)removePostsObject:(CBPost *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
