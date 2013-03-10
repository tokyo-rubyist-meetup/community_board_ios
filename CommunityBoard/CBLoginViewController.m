//
//  CBLoginViewController.m
//  CommunityBoard
//
//  Created by Matt on 3/10/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CBLoginViewController.h"
#import "CBHTTPClient.h"

@interface CBLoginViewController ()
@end

@implementation CBLoginViewController

- (void)loadView {
  self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  self.view.backgroundColor = [UIColor whiteColor];
  
  self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(
    10.0f,
    10.0f,
    self.view.bounds.size.width - 20.0f,
    (self.view.bounds.size.width - 20.0f) * 0.125f
  )];
  self.usernameTextField.layer.borderColor = [UIColor blackColor].CGColor;
  self.usernameTextField.layer.borderWidth = 1.0f;
  [self.view addSubview:self.usernameTextField];

  self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(
    self.usernameTextField.frame.origin.x,
    self.usernameTextField.frame.origin.y + self.usernameTextField.frame.size.height + 10.0f,
    self.usernameTextField.bounds.size.width,
    self.usernameTextField.bounds.size.height
  )];
  self.passwordTextField.layer.borderColor = [UIColor blackColor].CGColor;
  self.passwordTextField.layer.borderWidth = 1.0f;
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
  NSString *username = [self.usernameTextField.text copy];
  NSString *password = [self.passwordTextField.text copy];

  [[CBHTTPClient sharedClient]
    authenticateUsingOAuthWithPath:@"/oauth/token"
    username:username
    password:password
    scope:nil
    success:^(AFOAuthCredential *credential){
      [AFOAuthCredential storeCredential:credential withIdentifier:@"token"];
    }
    failure:nil];
}

@end
