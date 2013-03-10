//
//  NSDateFormatter+CommunityBoardExtensions.m
//  CommunityBoard
//
//  Created by Matt on 3/3/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "NSDateFormatter+CommunityBoardExtensions.h"

@implementation NSDateFormatter (CommunityBoardExtensions)

+ (NSDateFormatter *)RFC3339DateFormatter {
  static dispatch_once_t onceMark;
  static NSDateFormatter *sRFC3339DateFormatter = nil;
  dispatch_once(&onceMark, ^{
    sRFC3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
 
    [sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
    [sRFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  });
  
  return sRFC3339DateFormatter;
}

@end
