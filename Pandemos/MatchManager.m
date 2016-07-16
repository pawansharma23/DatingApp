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

-(void)createMatchRequest:(User *)matchedUser withStatus:(NSString*)status andBlock:(resultBlockWithMatch)match
{
    MatchRequest *matchRequest = [MatchRequest objectWithClassName:@"MatchRequest"];
    matchRequest.fromUser = [User currentUser];
    matchRequest.toUser = matchedUser;
    matchRequest.status = status;

    [matchRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

        if (succeeded)
        {
            match(matchRequest, nil);
        }
        else
        {
            match(nil, error);
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

//3b-2
//send email for girlYes and unseen by boy
//this will include the on YES "girlVerified" on NO: "confidantNo"
-(void)sendEmailForUnseen:(NSString*)matchId withEmail:(NSString*)confidantEmail matchedUser:(User*)matchedName
{
    NSString *yourName = [NSString stringWithFormat:@"%@ needs your approval", [User currentUser].givenName];
    NSString *testText = [NSString stringWithFormat:@"What do you think of %@ for %@?", matchedName.givenName, [User currentUser].givenName];
    PFFile *pf = matchedName.profileImages.firstObject;
    NSString *altImageDesription = @"Matched profile pic";

    NSString *yesEndpoint = [NSString stringWithFormat:@"myally.herokuapp.com/api/matchgirlverified/%@", matchId];
    NSString *noEndpoint = [NSString stringWithFormat:@"myally.herokuapp.com/api/noaction/%@",matchId];

    NSString *html = [NSString stringWithFormat:@"<b>%@</b><br><img src=%@ alt=%@ style=width:70px;height:70px><br><a href=%@ class=btn>YES</a><p style=text-indent: 5em;></p><a href=%@ class=btn>NO</a>", testText, pf.url, altImageDesription, yesEndpoint, noEndpoint];

    [PFCloud callFunctionInBackground:@"email" withParameters:@{@"email": confidantEmail, @"text": testText, @"username": yourName, @"htmlCode": html} block:^(NSString *result, NSError *error) {

        if (error)
        {
            NSLog(@"error cloud js code: %@", error);
        }
        else
        {
            NSLog(@"email sent :%@", result);
        }
    }];
}

//this will include the PFRelation on yes, on NO: confidantKibosh"
-(void)sendEmailForMatch:(NSString*)potMatchId withMatchId:(NSString*)matchId withEmail:(NSString*)confidantEmail matchedUser:(User*)matchedName
{
    NSString *yourName = [NSString stringWithFormat:@"%@ needs your approval", [User currentUser].givenName];
    NSString *testText = [NSString stringWithFormat:@"What do you think of %@ for %@?", matchedName.givenName, [User currentUser].givenName];
    PFFile *pf = matchedName.profileImages.firstObject;
    NSString *altImageDesription = @"Matched profile pic";

    NSString *yesEndpoint = [NSString stringWithFormat:@"myally.herokuapp.com/api/yesaction/%@,%@", potMatchId, [User currentUser].objectId];
    NSString *noEndpoint = [NSString stringWithFormat:@"myally.herokuapp.com/api/confidantKibosh/%@",matchId];

    NSString *html = [NSString stringWithFormat:@"<b>%@</b><br><img src=%@ alt=%@ style=width:70px;height:70px><br><a href=%@ class=btn>YES</a><p style=text-indent: 5em;></p><a href=%@ class=btn>NO</a>", testText, pf.url, altImageDesription, yesEndpoint, noEndpoint];

    [PFCloud callFunctionInBackground:@"email" withParameters:@{@"email": confidantEmail, @"text": testText, @"username": yourName, @"htmlCode": html} block:^(NSString *result, NSError *error) {

        if (error)
        {
            NSLog(@"error cloud js code: %@", error);
        }
        else
        {
            NSLog(@"email sent :%@", result);
        }
    }];
}

-(void)createVerifiedPFRelationWithPFCloud:(User*)recipientUser andMatchRequest:(MatchRequest*)match withMatchBlock:(resultBlockWithMatch)matchRequest
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
                     matchRequest(match,nil);
                 }
                 else
                 {
                     NSLog(@"could not save to parse: %@", error);
                 }
             }];
         }
         else
         {
             NSLog(@"failed to save final PFrelation");
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