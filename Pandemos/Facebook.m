//
//  FacebookData.m
//  Pandemos
//
//  Created by Michael Sevy on 2/18/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "Facebook.h"
#import <UIKit/UIKit.h>
#import <FBSDKGraphRequestConnection.h>
#import <FBSDKGraphRequest.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import "AFNetworking.h"
#import "User.h"

@implementation Facebook

-(NSData *)stringURLToData:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];

    return data;
}
@end
