//
//  CBPostViewController.h
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Community.h"

@interface CBPostViewController : UITableViewController <UISplitViewControllerDelegate,
  NSFetchedResultsControllerDelegate>

- (id)initWithCommunity:(Community*)community managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
