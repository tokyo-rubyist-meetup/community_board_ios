//
//  CBHTTPClient.h
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "AFOAuth2Client.h"

@interface CBHTTPClient : AFOAuth2Client

+ (CBHTTPClient *)sharedClient;

@end
