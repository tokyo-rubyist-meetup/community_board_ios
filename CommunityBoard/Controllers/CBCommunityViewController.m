//
//  CBCommunityViewController.m
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "CBCommunityViewController.h"
#import "CBPostViewController.h"
#import "CBObjectManager.h"
#import "CBAPI.h"
#import "CBAppDelegate.h"

@interface CBCommunityViewController ()

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation CBCommunityViewController

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
  self = [super initWithNibName:nil bundle:nil];
  
  if (self) {
    self.title = NSLocalizedString(@"Community Board", @"Community Board");
    self.managedObjectContext = managedObjectContext;
  }
  return self;
}
							
- (void)viewDidLoad {
  [super viewDidLoad];
      
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Community"];
  fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
    
  self.fetchedResultsController = [[NSFetchedResultsController alloc]
    initWithFetchRequest:fetchRequest
    managedObjectContext:self.managedObjectContext
    sectionNameKeyPath:nil
    cacheName:nil];
  self.fetchedResultsController.delegate = self;
  [self.fetchedResultsController performFetch:nil];
  
  [self loadCommunities];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
    
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }

  [self configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  CBCommunity *community = (CBCommunity*)[[self fetchedResultsController] objectAtIndexPath:indexPath];
  
  CBPostViewController *postViewController = [[CBPostViewController alloc]
    initWithCommunity:community
    managedObjectContext:self.managedObjectContext];
        
  [self.navigationController pushViewController:postViewController animated:YES];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
  if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
  }
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  
  NSEntityDescription *entity = [NSEntityDescription
    entityForName:@"Community"
    inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
    
  [fetchRequest setFetchBatchSize:20];
    
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
  NSArray *sortDescriptors = @[sortDescriptor];
    
  [fetchRequest setSortDescriptors:sortDescriptors];
  
  _fetchedResultsController = [[NSFetchedResultsController alloc]
    initWithFetchRequest:fetchRequest
    managedObjectContext:self.managedObjectContext
    sectionNameKeyPath:nil
    cacheName:@"Master"];
  _fetchedResultsController.delegate = self;
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    
  return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
 didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
 atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView
        insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
            
    case NSFetchedResultsChangeDelete:
      [self.tableView
        deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller
 didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
 forChangeType:(NSFetchedResultsChangeType)type
 newIndexPath:(NSIndexPath *)newIndexPath {
  UITableView *tableView = self.tableView;
    
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
            
    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
            
    case NSFetchedResultsChangeUpdate:
      [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;
            
    case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView endUpdates];
}

#pragma mark - Private Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  CBCommunity *community = (CBCommunity*)[self.fetchedResultsController objectAtIndexPath:indexPath];
  cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
  cell.textLabel.text = community.name;
  cell.textLabel.font = [UIFont fontWithName:CBFontName size:CBFontLargeSize];
}

- (void)loadCommunities {
  CBCommunityViewController *__weak weakSelf = self;

  [[CBObjectManager sharedManager]
    getObjectsAtPath:[CBAPI communitiesPath]
    parameters:nil
    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    }
    failure:^(RKObjectRequestOperation *operation, NSError *error) {
      NSLog(@"Error loading communities: %@", error.localizedDescription);
    }];
}

@end
