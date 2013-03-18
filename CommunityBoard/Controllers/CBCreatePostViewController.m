//
//  CBCreatePostViewController.m
//  CommunityBoard
//
//  Created by Matt on 3/2/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CBCreatePostViewController.h"
#import "CBPost.h"
#import "CBAppDelegate.h"

@interface CBCreatePostViewController ()
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) CBCommunity *community;
@end

@implementation CBCreatePostViewController

- (id)initWithCommunity:(CBCommunity*)community managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
  self = [super initWithNibName:nil bundle:nil];

  if (self) {
    self.managedObjectContext = managedObjectContext;
    self.community = community;
    self.title = NSLocalizedString(@"Create Post", @"Create a new post");
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
      target:self
      action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItems = @[cancelButtonItem];
  }
  
  return self;
}

- (void)loadView {
  self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  self.view.backgroundColor = [UIColor whiteColor];
  
  self.textView = [[UITextView alloc] initWithFrame:CGRectMake(
    10.0f,
    10.0f,
    self.view.bounds.size.width - 20.0f,
    (self.view.bounds.size.width - 20.0f) * 0.25f
  )];
  self.textView.layer.borderColor = [UIColor blackColor].CGColor;
  self.textView.layer.borderWidth = 1.0f;
  self.textView.font = [UIFont fontWithName:CBFontName size:CBFontSmallSize];
  [self.view addSubview:self.textView];
  
  self.submitButton = [[UIGlossyButton alloc] initWithFrame:CGRectMake(
    self.textView.frame.origin.x,
    self.textView.frame.origin.y + self.textView.frame.size.height + 10.0f,
    self.textView.bounds.size.width,
    44.0f
  )];
  [self.submitButton addTarget:self action:@selector(submitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  self.submitButton.titleLabel.font = [UIFont fontWithName:CBFontName size:CBFontSmallSize];
  [self.submitButton setGradientType:kUIGlossyButtonGradientTypeLinearGlossyStandard];
  [self.submitButton setTitle:NSLocalizedString(@"Post", @"Post") forState:UIControlStateNormal];
  [self.submitButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
  [self.view addSubview:self.submitButton];
}

- (void)cancelButtonPressed:(id)sender {
  if ([self.delegate respondsToSelector:@selector(createPostViewControllerDidCancelPost:)]) {
    [self.delegate createPostViewControllerDidCancelPost:self];
  }
}

- (void)submitButtonPressed:(id)sender {
  CBCreatePostViewController *__weak weakSelf = self;
  
  NSString *text = [self.textView.text copy];
  self.textView.text = nil;
  [self.textView resignFirstResponder];
    
  CBPost *post = [NSEntityDescription
    insertNewObjectForEntityForName:@"Post"
    inManagedObjectContext:self.managedObjectContext];
  post.text = text;
        
  [[RKObjectManager sharedManager]
    postObject:post
    path:RKPathFromPatternWithObject(@"communities/:communityId/posts.json", self.community)
    parameters:nil
    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
      CBCreatePostViewController *strongSelf = weakSelf;
      
      if (!strongSelf) {
        return;
      }
    
      [strongSelf.community addPostsObject:post];
      [strongSelf.managedObjectContext saveToPersistentStore:nil];
      
      if ([strongSelf.delegate respondsToSelector:@selector(createPostViewControllerDidCreatePost:)]) {
        [strongSelf.delegate createPostViewControllerDidCreatePost:strongSelf];
      }
    }
    failure:^(RKObjectRequestOperation *operation, NSError *error) {
      CBCreatePostViewController *strongSelf = weakSelf;
      
      if (!strongSelf) {
        return;
      }
      
      if ([strongSelf.delegate respondsToSelector:@selector(createPostViewController:postDidFailWithError:)]) {
        [strongSelf.delegate createPostViewController:strongSelf postDidFailWithError:error];
      }
  }];
}

@end
