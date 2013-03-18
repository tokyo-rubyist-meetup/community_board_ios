//
//  CBLoginViewController.h
//  CommunityBoard
//
//  Created by Matt on 3/10/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "AFOAuth2Client.h"
#import "UIGlossyButton.h"

@interface CBLoginViewController : UIViewController

@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UITextField *usernameTextField;

@property (strong, nonatomic) UILabel *passwordLabel;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIGlossyButton *submitButton;

@end
