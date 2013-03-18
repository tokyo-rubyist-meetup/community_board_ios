//
//  CBAppDelegate.h
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

extern NSString * const CBCredentialIdentifier;
extern NSString * const CBFontName;
extern const CGFloat CBFontLargeSize;
extern const CGFloat CBFontSmallSize;

@interface CBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) RKManagedObjectStore *managedObjectStore;
@property (strong, nonatomic) UINavigationController *navigationController;

@end
