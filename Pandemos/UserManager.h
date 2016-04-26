//
//  UserNetwork.h
//  Pandemos
//
//  Created by Michael Sevy on 4/6/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "MatchRequest.h"

@class User;
@class PFQuery;

@protocol UserManagerDelegate <NSObject>

@optional
-(void)didCreateUser:(PFUser*)user withError:(NSError*)error;
-(void)didReceiveUserData:(NSArray*)data;
-(void)failedToFetchUserData:(NSError*)error;
-(void)didReceiveUserImages:(NSArray*)images;
-(void)failedToFetchImages:(NSError*)error;
-(void)didReceivePotentialMatchData:(NSArray*)data;
-(void)failedToFetchPotentialMatchData:(NSError *)error;
-(void)didReceivePotentialMatchImages:(NSArray *)images;
-(void)failedToFetchPotentialMatchImages:(NSError*)error;

-(void)didCreateMatchRequest:(MatchRequest*)matchRequest;
-(void)failedToCreateMatchRequest:(NSError*)error;
-(void)didUpdateMatchRequest:(User *)user;
-(void)failedToUpdateMatchRequest:(NSError*)error;
@end

@interface UserManager : NSObject
typedef void (^resultBlockWithMatchRequest)(MatchRequest *matchRequest, NSError *error);
typedef void (^resultBlockWithUser)(User *user, NSError *error);

@property (weak, nonatomic) id<UserManagerDelegate>delegate;

-(void)signUp:(PFUser*)user;
-(void)loadUserData:(User *)user;
-(void)loadUserImages:(User *)user;
-(void)loadUsersUnseenPotentialMatches:(User *)user withSexPreference:(NSString *)sexPref minAge:(NSString *)min maxAge:(NSString *)max;
-(void)createMatchRequest:(User*)user
           withCompletion:(resultBlockWithMatchRequest)result;
-(void)updateMatchRequest:(MatchRequest*)matchRequest withResponse:(NSString*)response withSuccess:(resultBlockWithUser)result;
@end
