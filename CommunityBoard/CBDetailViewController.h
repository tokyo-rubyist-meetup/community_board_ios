//
//  CBDetailViewController.h
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBDetailViewController : UITableViewController <UISplitViewControllerDelegate,
  NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
