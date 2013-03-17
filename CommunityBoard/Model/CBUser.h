//
//  CBUser.h
//  CommunityBoard
//
//  Created by Matt on 3/17/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CBPost;

@interface CBUser : NSManagedObject

@property (nonatomic, retain) NSString * avatarURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSSet *posts;
@end

@interface CBUser (CoreDataGeneratedAccessors)

- (void)addPostsObject:(CBPost *)value;
- (void)removePostsObject:(CBPost *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
