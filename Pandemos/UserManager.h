//
//  UserNetwork.h
//  Pandemos
//
//  Created by Michael Sevy on 4/6/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@class User;

@protocol UserManagerDelegate <NSObject>

@optional
-(void)didReceiveUserData:(NSArray *)data;
-(void)failedToFetchUserData:(NSError *)error;
-(void)didReceiveUserImages:(NSArray *)images;
-(void)failedToFetchImages:(NSError *)error;
@end

@interface UserManager : NSObject

@property (weak, nonatomic) id<UserManagerDelegate>delegate;

-(void)loadUserData:(User *)user;
-(void)loadUserImages:(User *)user;
@end
