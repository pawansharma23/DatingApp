//
//  MatchManager.m
//  Pandemos
//
//  Created by Michael Sevy on 7/12/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MatchManager.h"

@implementation MatchManager

+ (id)sharedSettings
{
    static MatchManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

-(void)createMatchRequest:(User *)matchedUser withStatus:(NSString*)status withMatchRequest:(resultBlockWithMatch)match
{
    MatchRequest *matchRequest = [MatchRequest objectWithClassName:@"MatchRequest"];
    matchRequest.fromUser = [User currentUser];
    matchRequest.toUser = matchedUser;
    matchRequest.status = status;

    [matchRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

        if (succeeded)
        {
            match(matchRequest, nil);
            //[self.delegate didCreateMatchRequest:matchRequest];
        }
        else
        {
            match(nil, error);
//            [self.delegate failedToCreateMatchRequest:error];
        }
    }];
}

-(void)queryForMatchRequestWithUserSeen:(User *)matchedUser withStatusBlock:(resultBlockWithStatus)status
{//query to see if matched has already seen and swiped on user
    PFQuery *query = [PFQuery queryWithClassName:@"MatchRequest"];
    [query whereKey:@"toUser" equalTo:[User currentUser]];
    [query whereKey:@"fromUser" equalTo:matchedUser];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects)
        {
            NSDictionary *matchDict = objects.firstObject;
            NSString *matchStatus = matchDict[@"status"];

            status(matchStatus, nil);
        }
        else
        {
            status(nil, error);
        }
    }];
}

-(void)queryForRelationshipMatch:(User*)matchedUser withBlock:(resultBlockWithMatchedUser)match
{
    PFRelation *relation = [matchedUser relationForKey:@"match"];
    PFQuery *query = [relation query];

    [query whereKey:@"objectId" notEqualTo:[User currentUser].objectId];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        if (error)
        {
            NSLog(@"error: %@", error);
            match(objects, error);
        }
        else
        {
            match(objects, nil);
        }
    }];
}
//dummy email from cloud
-(void)sendEmailWithPFCloudFunction:(NSString *)confidantEmail withRelation:(PFRelation *)rela andMatchedUser:(User *)user
{
    NSString *testEmail = @"michaelsevy@gmail.com";
    //NSString *confidantEmail = [[User currentUser] objectForKey:@"confidantEmail"];
    NSString *yourName = [NSString stringWithFormat:@"%@ needs your approval", [User currentUser].givenName];
    //relation info for email

    NSString *siteHtml = [NSString stringWithFormat:@"https://api.parse.com/1/classes/"];
    //%@", approvedRela];
    NSString *cssButton = [NSString stringWithFormat:@"button"];
    NSString *htmlString = [NSString stringWithFormat:@"<a href=%@ class=%@>Aprrove %@ for %@</a>", siteHtml, cssButton, @"John", yourName];

    [PFCloud callFunctionInBackground:@"email" withParameters:@{@"email": testEmail, @"text": @"What do you think of this user for your friend", @"username": yourName, @"htmlCode": htmlString} block:^(NSString *result, NSError *error) {
        if (error)
        {
            NSLog(@"error cloud js code: %@", error);
        }
        else
        {
            NSLog(@"result :%@", result);
        }
    }];

}
//dummy creates PFRelation, this will be done in Heroku now
-(void)createVerifiedPFRelationWithPFCloud:(User*)recipientUser andMatchRequest:(MatchRequest*)match
{
    User *fromUser = match.fromUser;

    //call the cloud function addFriendToFriendRelation which adds the current user to the from users friends:
    //we pass in the object id of the friendRequest as a parameter (you cant pass in objects, so we pass in the id)
    [PFCloud callFunctionInBackground:@"addMatchToMatchRelation" withParameters:@{@"matchRequest" : match.objectId} block:^(id object, NSError *error)
     {
         if (!error)
         {
             //add the from user to the currentUsers friends
             PFRelation *matchRelation = [[User currentUser] relationForKey:@"match"];
             [matchRelation addObject:fromUser];

             //save the current user
             [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)    {

                 if (succeeded)
                 {
                     NSLog(@"save final pfrelation to parse, between %@ & %@", [User currentUser].givenName, recipientUser.givenName);
                     //[self.delegate didUpdateMatchRequest:recipientUser];
                     //send delegate to throw UIView taht says it was a match?
                 }
             }];
         }
         else
         {
             NSLog(@"failed to save final PFrelation");
             //[self.delegate failedToCreateMatchRequest:error];
         }
     }];
}

-(void)changePFRelationToDeniedWithPFCloudFunction:(User*)recipientUser
{
    //call the cloud function addFriendToFriendRelation which adds the current user to the from users friends:
    //we pass in the object id of the friendRequest as a parameter (you cant pass in objects, so we pass in the id)
    [PFCloud callFunctionInBackground:@"addMatchToMatchRelation" withParameters:@{@"matchRequest" : [User currentUser].objectId} block:^(id object, NSError *error)
     {
         if (!error)
         {
             //add the from user to the currentUsers friends
             PFRelation *matchRelation = [[User currentUser] relationForKey:@"blocked"];
             [matchRelation addObject:[User currentUser]];

             //save the current user
             [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)    {

                 if (succeeded)
                 {
                     NSLog(@"save final pfrelation to parse, between %@ & %@", [User currentUser].givenName, recipientUser.givenName);
                     //[self.delegate didUpdateMatchRequest:recipientUser];
                 }
             }];
         }
         else
         {
             NSLog(@"failed to save final PFrelation");
             //[self.delegate failedToCreateMatchRequest:error];
         }
     }];
}
@end