//
//  CBPostViewController.h
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "CBCommunity.h"
#import "CBCreatePostViewController.h"

@interface CBPostViewController : UITableViewController <UISplitViewControllerDelegate,
  NSFetchedResultsControllerDelegate, CBCreatePostViewControllerDelegate>

- (id)initWithCommunity:(CBCommunity*)community managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
