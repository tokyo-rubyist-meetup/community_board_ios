//
//  CBCommunityViewController.h
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBPostViewController;

#import <CoreData/CoreData.h>

@interface CBCommunityViewController : UITableViewController <NSFetchedResultsControllerDelegate>

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
