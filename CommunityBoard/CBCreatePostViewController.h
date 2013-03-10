//
//  CBCreatePostViewController.h
//  CommunityBoard
//
//  Created by Matt on 3/2/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Community.h"

@interface CBCreatePostViewController : UIViewController

- (id)initWithCommunity:(Community*)community managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *submitButton;

@end
