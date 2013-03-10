//
//  CBCreatePostViewController.m
//  CommunityBoard
//
//  Created by Matt on 3/2/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CBCreatePostViewController.h"
#import "Post.h"

@interface CBCreatePostViewController ()
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Community *community;
@end

@implementation CBCreatePostViewController

- (id)initWithCommunity:(Community*)community managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
  self = [super initWithNibName:nil bundle:nil];

  if (self) {
    self.managedObjectContext = managedObjectContext;
    self.community = community;
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
  [self.view addSubview:self.textView];
  
  self.submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  self.submitButton.frame = CGRectMake(
    self.textView.frame.origin.x,
    self.textView.frame.origin.y + self.textView.frame.size.height + 10.0f,
    self.textView.bounds.size.width,
    44.0f
  );
  [self.submitButton addTarget:self action:@selector(submitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.submitButton];
}

- (void)submitButtonPressed:(id)sender {    
  NSString *text = [self.textView.text copy];
  self.textView.text = nil;
  [self.textView resignFirstResponder];
    
  [self.managedObjectContext performBlock:^{
    Post *post = [NSEntityDescription
      insertNewObjectForEntityForName:@"Post"
      inManagedObjectContext:self.managedObjectContext];
    post.text = text;
    
    [self.community addPostsObject:post];
    
    [self.managedObjectContext save:nil];
  }];
  
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
