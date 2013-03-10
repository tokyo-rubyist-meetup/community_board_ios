//
//  Community.h
//  CommunityBoard
//
//  Created by Matt on 3/3/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Community : NSManagedObject

@property (nonatomic, retain) NSNumber * communityId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * postCount;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSSet *posts;
@end

@interface Community (CoreDataGeneratedAccessors)

- (void)addPostsObject:(Post *)value;
- (void)removePostsObject:(Post *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
