//
//  MatchRequest.m
//  Pandemos
//
//  Created by Michael Sevy on 2/28/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MatchRequest.h"

@implementation MatchRequest

@dynamic fromUser;
@dynamic toUser;
@dynamic status;

+ (NSString *)parseClassName
{
    return @"MatchRequest";
}
@end
