//
//  CBCreatePostViewController.h
//  CommunityBoard
//
//  Created by Matt on 3/2/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "CBCommunity.h"
#import "UIGlossyButton.h"

@class CBCreatePostViewController;

@protocol CBCreatePostViewControllerDelegate <NSObject>
@optional
- (void)createPostViewControllerDidCreatePost:(CBCreatePostViewController*)viewController;
- (void)createPostViewControllerDidCancelPost:(CBCreatePostViewController*)viewController;
- (void)createPostViewController:(CBCreatePostViewController*)viewController postDidFailWithError:(NSError*)error;
@end

@interface CBCreatePostViewController : UIViewController

- (id)initWithCommunity:(CBCommunity*)community managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIGlossyButton *submitButton;
@property (weak, nonatomic) id<CBCreatePostViewControllerDelegate> delegate;

@end
