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

//@protocol MatchManagerDelegate <NSObject>

//@end

@interface MatchManager : NSObject

typedef void (^resultBlockWithStatus)(NSString *status, NSError *error);
typedef void (^resultBlockWithMatch)(MatchRequest *matchRequest, NSError *error);
typedef void (^resultBlockWithMatchedUser)(NSArray<User*> *matchedUser, NSError *error);

+(MatchManager*)sharedSettings;

-(void)createMatchRequest:(User *)matchedUser
               withStatus:(NSString*)status
                 andBlock:(resultBlockWithMatch)match;

-(void)queryForMatchRequestWithUserSeen:(User*)matchedUser
                        withStatusBlock:(resultBlockWithStatus)status;

-(void)queryForRelationshipMatch:(User*)matchedUser
                       withBlock:(resultBlockWithMatchedUser)match;

//this method is in MatchViewController now as a dummy email that works
-(void)sendEmailWithPFCloudFunction:(NSString*)confidantEmail
                       withRelation:(PFRelation*)rela
                     andMatchedUser:(User*)user;

//do we need the matchRequest object here?
//-(void)createVerifiedPFRelationWithPFCloud:(User*)recipientUser
//                           andMatchRequest:(MatchRequest*)match;

//In Messsage Profile
//to block or unmatch user with match in profile(when they're already a match)
-(void)changePFRelationToDeniedWithPFCloudFunction:(User*)recipientUser;
@end