//
//  CBHTTPClient.h
//  CommunityBoard
//
//  Created by Matt on 2/24/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "AFRESTClient.h"

@interface CBHTTPClient : AFRESTClient

+ (CBHTTPClient *)sharedClient;

@end
