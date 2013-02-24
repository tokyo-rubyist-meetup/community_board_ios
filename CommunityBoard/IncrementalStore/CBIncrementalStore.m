//
//  CBIncrementalStore.m
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "CBIncrementalStore.h"
#import "CBHTTPClient.h"

@implementation CBIncrementalStore

+ (void)initialize {
  [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:[self type]];
}

+ (NSString *)type {
  return NSStringFromClass(self);
}

+ (NSManagedObjectModel *)model {
  return [[NSManagedObjectModel alloc]
    initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"CommunityBoard" withExtension:@"xcdatamodeld"]];
}

- (id <AFIncrementalStoreHTTPClient>)HTTPClient {
  return [CBHTTPClient sharedClient];
}

@end
