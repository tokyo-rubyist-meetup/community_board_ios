//
//  CBPostViewController.m
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "CBPostViewController.h"
#import "CBCreatePostViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFIncrementalStore.h"

@interface CBPostViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) id postsUpdatedObserver;
@property (strong, nonatomic) NSArray *posts;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, readonly) Community *community;
@end

@implementation CBPostViewController

#pragma mark - Managing the detail item

- (id)initWithCommunity:(Community*)community managedObjectContext:(NSManagedObjectContext*)managedObjectContext {
  self = [super initWithNibName:nil bundle:nil];
  
  if (self) {
    self.title = NSLocalizedString(@"Posts", @"Posts");
    _community = community;
    self.managedObjectContext = managedObjectContext;
    [self loadPosts];
    
    UIBarButtonItem *newPostItem = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
      target:self
      action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItems = @[newPostItem];
    
    self.postsUpdatedObserver = [[NSNotificationCenter defaultCenter]
      addObserverForName:NSManagedObjectContextObjectsDidChangeNotification
      object:nil
      queue:nil
      usingBlock:^(NSNotification *notification){
        [self loadPosts];
        [self.tableView reloadData];
      }];
  }
  
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self.postsUpdatedObserver];
  self.postsUpdatedObserver = nil;
}

- (void)loadPosts {
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
  self.posts = [self.community.posts sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender {
  CBCreatePostViewController *createPostViewController = [[CBCreatePostViewController alloc]
    initWithCommunity:self.community
    managedObjectContext:self.managedObjectContext];
  [self presentViewController:createPostViewController animated:YES completion:nil];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.posts count];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  NSManagedObject *object = [self.posts objectAtIndex:[indexPath row]];

  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [self.managedObjectContext deleteObject:object];
        
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
  }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  NSManagedObject *object = [self.posts objectAtIndex:[indexPath row]];
  cell.textLabel.text = [[object valueForKey:@"text"] description];
  
  NSURL *url = [NSURL URLWithString:[object valueForKeyPath:@"user.iconURL"]];
  [cell.imageView setImageWithURL:url];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController
 willHideViewController:(UIViewController *)viewController
 withBarButtonItem:(UIBarButtonItem *)barButtonItem
 forPopoverController:(UIPopoverController *)popoverController {
  barButtonItem.title = NSLocalizedString(@"Community", @"Community");
  
  [self.navigationItem setLeftBarButtonItems:@[barButtonItem] animated:YES];
  self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
 willShowViewController:(UIViewController *)viewController
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
  [self.navigationItem setLeftBarButtonItem:nil animated:YES];
  self.masterPopoverController = nil;
}

@end
