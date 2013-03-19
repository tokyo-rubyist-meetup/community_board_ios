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
#import "CBAppDelegate.h"
#import "UIGlossyButton.h"

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
  
  self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(
    10.0f,
    10.0f,
    self.view.bounds.size.width - 20.0f,
    (self.view.bounds.size.width - 20.0f) * 0.125f
  )];
  self.usernameLabel.text = NSLocalizedString(@"E-Mail", @"E-Mail");
  self.usernameLabel.font = [UIFont fontWithName:CBFontName size:CBFontSmallSize];
  self.usernameLabel.textColor = [UIColor darkGrayColor];
  [self.view addSubview:self.usernameLabel];
  
  self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(
    self.usernameLabel.frame.origin.x,
    self.usernameLabel.frame.origin.y + self.usernameLabel.frame.size.height,
    self.view.bounds.size.width - 20.0f,
    31.0f
  )];
  self.usernameTextField.font = [UIFont fontWithName:CBFontName size:CBFontLargeSize];
  self.usernameTextField.borderStyle = UITextBorderStyleLine;
  [self.view addSubview:self.usernameTextField];

  self.passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(
    self.usernameTextField.frame.origin.x,
    self.usernameTextField.frame.origin.y + self.usernameTextField.frame.size.height + 10.0f,
    self.usernameTextField.bounds.size.width,
    (self.view.bounds.size.width - 20.0f) * 0.125f
  )];
  self.passwordLabel.text = NSLocalizedString(@"Password", @"Password");
  self.passwordLabel.font = [UIFont fontWithName:CBFontName size:CBFontSmallSize];
  self.passwordLabel.textColor = [UIColor darkGrayColor];
  [self.view addSubview:self.passwordLabel];

  self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(
    self.passwordLabel.frame.origin.x,
    self.passwordLabel.frame.origin.y + self.passwordLabel.frame.size.height,
    self.passwordLabel.bounds.size.width,
    31.0f
  )];
  self.passwordTextField.borderStyle = UITextBorderStyleLine;
  self.passwordTextField.font = [UIFont fontWithName:CBFontName size:CBFontLargeSize];
  self.passwordTextField.secureTextEntry = YES;
  [self.view addSubview:self.passwordTextField];
  
  self.submitButton = [(UIGlossyButton*)[UIGlossyButton alloc] initWithFrame:CGRectMake(
    self.passwordTextField.frame.origin.x,
    self.passwordTextField.frame.origin.y + self.passwordTextField.frame.size.height + 4 * 10.0f,
    self.passwordTextField.bounds.size.width,
    44.0f
  )];
  [self.submitButton addTarget:self action:@selector(submitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [self.submitButton setTitle:NSLocalizedString(@"Login", @"Login") forState:UIControlStateNormal];
  self.submitButton.titleLabel.font = [UIFont fontWithName:CBFontName size:CBFontSmallSize];
  [self.submitButton setGradientType:kUIGlossyButtonGradientTypeLinearGlossyStandard];
  [self.submitButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

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
      [AFOAuthCredential storeCredential:credential withIdentifier:CBCredentialIdentifier];
      
      CBCommunityViewController *rootViewController = [[CBCommunityViewController alloc]
        initWithManagedObjectContext:[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext]];
      [weakSelf.navigationController setViewControllers:@[rootViewController] animated:YES];
    }
    failure:^(NSError *error){
      [[[UIAlertView alloc]
        initWithTitle:NSLocalizedString(@"Error", @"Error")
        message:[error localizedDescription]
        delegate:nil
        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
        otherButtonTitles:nil, nil] show];
    }];
}

@end