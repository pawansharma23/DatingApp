//
//  MatchManager.h
//  Pandemos
//
//  Created by Michael Sevy on 7/12/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "MatchRequest.h"

@protocol MatchManagerDelegate <NSObject>

-(void)didCreateMatchRequest:(MatchRequest*)matchRequest;
-(void)failedToCreateMatchRequest:(NSError*)error;
//not in use yet
//-(void)didCreateDenyMatchRequest:(MatchRequest*)matchRequest;
//-(void)failedToCreateDenyMatchRequest:(NSError*)error;

@end

@interface MatchManager : NSObject

typedef void (^resultBlockWithStatus)(NSString *status, NSError *error);
typedef void (^resultBlockWithMatch)(MatchRequest *matchRequest, NSError *error);
typedef void (^resultBlockWithMatchedUser)(NSArray<User*> *matchedUser, NSError *error);


@property (weak, nonatomic) id<MatchManagerDelegate>delegate;

+(MatchManager*)sharedSettings;

-(void)createMatchRequest:(User *)matchedUser withStatus:(NSString*)status withMatchRequest:(resultBlockWithMatch)match;
-(void)queryForMatchRequestWithUserSeen:(User*)matchedUser withStatusBlock:(resultBlockWithStatus)status;

-(void)queryForRelationshipMatch:(User*)matchedUser withBlock:(resultBlockWithMatchedUser)match;

//this method is in MatchViewController now as a dummy email that works
-(void)sendEmailWithPFCloudFunction:(NSString*)confidantEmail
                       withRelation:(PFRelation*)rela
                     andMatchedUser:(User*)user;

//do we need the matchRequest object here?
-(void)createVerifiedPFRelationWithPFCloud:(User*)recipientUser
                           andMatchRequest:(MatchRequest*)match;

//In Messsage Profile
//to block or unmatch user with match in profile(when they're already a match)
-(void)changePFRelationToDeniedWithPFCloudFunction:(User*)recipientUser;
@end