//
//  CBLoginViewController.m
//  CommunityBoard
//
//  Created by Matt on 3/10/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CBLoginViewController.h"
#import "CBCommunityViewController.h"

@interface CBLoginViewController ()
@end

@implementation CBLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nil bundle:nil]) {
    self.title = NSLocalizedString(@"Login", "Login");
  }
  return self;
}

- (void)loadView {
  self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  self.view.backgroundColor = [UIColor whiteColor];
  
  self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(
    10.0f,
    10.0f,
    self.view.bounds.size.width - 20.0f,
    (self.view.bounds.size.width - 20.0f) * 0.125f
  )];
  self.usernameTextField.borderStyle = UITextBorderStyleLine;
  [self.view addSubview:self.usernameTextField];

  self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(
    self.usernameTextField.frame.origin.x,
    self.usernameTextField.frame.origin.y + self.usernameTextField.frame.size.height + 10.0f,
    self.usernameTextField.bounds.size.width,
    self.usernameTextField.bounds.size.height
  )];
  self.passwordTextField.borderStyle = UITextBorderStyleLine;
  [self.view addSubview:self.passwordTextField];
  
  self.submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  self.submitButton.frame = CGRectMake(
    self.passwordTextField.frame.origin.x,
    self.passwordTextField.frame.origin.y + self.passwordTextField.frame.size.height + 10.0f,
    self.passwordTextField.bounds.size.width,
    44.0f
  );
  [self.submitButton addTarget:self action:@selector(submitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.submitButton];
}

- (void)submitButtonPressed:(id)sender {
  CBLoginViewController *__weak weakSelf = self;

  NSString *username = [self.usernameTextField.text copy];
  NSString *password = [self.passwordTextField.text copy];

  [(AFOAuth2Client*)[RKObjectManager sharedManager].HTTPClient authenticateUsingOAuthWithPath:@"/oauth/token"
    username:username
    password:password
    scope:nil
    success:^(AFOAuthCredential *credential){
      [AFOAuthCredential storeCredential:credential withIdentifier:@"identifier"];
      
      CBCommunityViewController *rootViewController = [[CBCommunityViewController alloc]
        initWithManagedObjectContext:[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext]];
      [weakSelf.navigationController setViewControllers:@[rootViewController] animated:YES];
    }
    failure:^(NSError *error){
      NSLog(@"Unable to authenticate: %@", [error localizedDescription]);
    }];
}

@end
