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
#import "CBPost.h"
#import "CBUser.h"
#import "CBAppDelegate.h"
#import "CBAPI.h"
#import "CBObjectManager.h"

@interface CBPostViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSArray *posts;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic, readwrite) CBCommunity *community;
@end

@implementation CBPostViewController

#pragma mark - Managing the detail item

- (id)initWithCommunity:(CBCommunity*)community managedObjectContext:(NSManagedObjectContext*)managedObjectContext {
  self = [super initWithNibName:nil bundle:nil];
  
  if (self) {
    self.title = community.name;
    self.community = community;
    self.managedObjectContext = managedObjectContext;
    [self loadPosts];
    
    // I did not use UIBarButtonSystemItemAdd because it doesn't reflect the appearance proxy changes
    UIBarButtonItem *newPostItem = [[UIBarButtonItem alloc]
      initWithTitle:NSLocalizedString(@"+", @"An add button")
      style:UIBarButtonItemStylePlain
      target:self
      action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItems = @[newPostItem];
  }
  
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tableView.allowsSelection = NO;

  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
  self.posts = [self.community.posts sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (void)addButtonPressed:(id)sender {
  CBCreatePostViewController *createPostViewController = [[CBCreatePostViewController alloc]
    initWithCommunity:self.community
    managedObjectContext:self.managedObjectContext];
  createPostViewController.delegate = self;
  UINavigationController *createPostNavigationController = [[UINavigationController alloc]
    initWithRootViewController:createPostViewController];
  [self presentViewController:createPostNavigationController animated:YES completion:nil];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.posts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  CBPost *post = [self.posts objectAtIndex:[indexPath row]];
  
  CGSize constraint = CGSizeMake(280.0 - (10.0f * 2), CGFLOAT_MAX);
  CGSize size = [post.text
    sizeWithFont:[UIFont fontWithName:CBFontName size:CBFontSmallSize]
    constrainedToSize:constraint
    lineBreakMode:UILineBreakModeWordWrap];
 
  CGFloat height = MAX(size.height, 44.0f);
 
  return height + (10.0f * 2);
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  CBPost *post = [self.posts objectAtIndex:[indexPath row]];
  cell.textLabel.text = post.text;
  cell.textLabel.font = [UIFont fontWithName:CBFontName size:CBFontSmallSize];
  cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
  cell.textLabel.numberOfLines = 0;
  
  NSURL *url = [NSURL URLWithString:post.user.avatarURL];
  [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

#pragma mark - CBCreatePostViewControllerDelegate
- (void)createPostViewControllerDidCreatePost:(CBCreatePostViewController *)viewController {
  [self dismissViewControllerAnimated:YES completion:^{
    [self.tableView reloadData];
    [self loadPosts];
  }];
}

- (void)createPostViewControllerDidCancelPost:(CBCreatePostViewController *)viewController {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createPostViewController:(CBCreatePostViewController *)viewController postDidFailWithError:(NSError *)error {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods
- (void)loadPosts {
//*** Load the posts from the network here.
}

@end
