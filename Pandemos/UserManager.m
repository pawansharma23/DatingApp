//
//  UserNetwork.m
//  Pandemos
//
//  Created by Michael Sevy on 4/6/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//
#import "UserManager.h"
#import "User.h"
#import <Parse/Parse.h>
#import "UserBuilder.h"
#import "MatchRequest.h"

@implementation UserManager

static NSString * const kParseObjectId                     = @"objectId";
static NSString * const kFacebookId                        = @"faceID";
static NSString * const kParseGivenName                    = @"givenName";
static NSString * const kParseUserBirthday                 = @"birthday";
static NSString * const kParseUserGender                   = @"gender";
static NSString * const kParseUserSexPreference            = @"sexPref";
static NSString * const kParseUserMilesAwayPreferece       = @"milesAway";
static NSString * const kParseUserPreferenceMinAge         = @"minAge";
static NSString * const kParseUserPreferenceMaxAge         = @"maxAge";
static NSString * const kParseProfileImages                = @"profileImages";
static NSString * const kParseEducation                    = @"lastSchool";
static NSString * const kParseUserFBLocation               = @"facebookLocation";
static NSString * const kParseFacebookHometown             = @"facebookHometown";
static NSString * const kParseWork                         = @"work";
static NSString * const kParseConfidantEmail               = @"confidantEmail";
static NSString * const kParseAboutMe                      = @"aboutMe";
static NSString * const kParsePublic                       = @"publicProfile";

//PFGeoPoint * const kParseGeoPoint= @"GeoCode";

+ (id)sharedSettings
{
    static UserManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

-(void)signUp:(PFUser*)user
{
    [self saveToUserDefaultsWithObject:user.objectId andKey:@"objectId"];
    user.objectId = user.objectId;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error)
         {
             NSLog(@"SIGNUP SUCCESSFUL");
             PFInstallation *currentInstallation = [PFInstallation currentInstallation];
             currentInstallation[@"user"] = [User currentUser];
             [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
              {
                  if (!error)
                  {
                      [self.delegate didCreateUser:user withError:error];
                  }
              }];
         }
     }];
}

- (void)saveToUserDefaultsWithObject:(id)object andKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"SAVED %@ TO USER DEFAULTS", object);
}

-(void)loadUserData:(User *)user
{
    NSMutableArray *userData = [NSMutableArray new];
    User *ob = [User new];

    NSString *faceId = [user objectForKey:kFacebookId];
    NSString *lastName = [user objectForKey:@"lastName"];
    NSString *givenName = [user objectForKey:kParseGivenName];
    NSString *birthday = [user objectForKey:kParseUserBirthday];
    NSString *gender = [user objectForKey:kParseUserGender];
    NSString *sexPref = [user objectForKey:kParseUserSexPreference];
    NSString *facebookLocation = [user objectForKey:kParseUserFBLocation];
    NSString *milesAway = [user objectForKey:kParseUserMilesAwayPreferece];
    NSString *minAge = [user objectForKey:kParseUserPreferenceMinAge];
    NSString *maxAge = [user objectForKey:kParseUserPreferenceMaxAge];
    NSString *lastSchool = [user objectForKey:kParseEducation];
    NSString *faceHometown = [user objectForKey:kParseFacebookHometown];
    NSString *work = [user objectForKey:kParseWork];
    NSString *confidantEmail = [user objectForKey:kParseConfidantEmail];
    NSString *aboutMe = [user objectForKey:kParseAboutMe];
    NSString *pubProf = [user objectForKey:kParsePublic];
    //PFGeoPoint *geoPoint = [user objectForKey:kParseGeoPoint];

    if (faceId)
    {
        ob.faceID = faceId;
    }
    else
    {
        ob.faceID = nil;
    }
    if (givenName)
    {
        ob.givenName = givenName;
    }
    if (lastName)
    {
        ob.lastName = lastName;
    }
    if (birthday)
    {
        ob.birthday = birthday;
    }
    if (gender)
    {
        ob.gender = gender;
    }
    if (sexPref)
    {
        ob.sexPref = sexPref;
    }
    if (facebookLocation)
    {
        ob.facebookLocation = facebookLocation;
    }
    if (milesAway)
    {
        ob.milesAway = milesAway;
    }
    if (minAge)
    {
        ob.minAge = minAge;
    }
    if (maxAge)
    {
        ob.maxAge = maxAge;
    }
    if (lastSchool)
    {
        ob.lastSchool = lastSchool;
    }
    if (facebookLocation)
    {
        ob.facebookLocation = facebookLocation;
    }
    if (faceHometown)
    {
        ob.facebookHometown = faceHometown;
    }
    if (work)
    {
        ob.work = work;
    }
    if (confidantEmail)
    {
        ob.confidantEmail = confidantEmail;
    }
    if (aboutMe)
    {
        ob.aboutMe = aboutMe;
    }
    if (pubProf)
    {
        ob.publicProfile = pubProf;
    }

    [userData addObject:ob];
    NSArray *array = [NSArray arrayWithArray:userData];

    [self.delegate didReceiveUserData:array];
}

-(void)loadUserImages:(User *)user;
{
    NSArray *images = [user objectForKey:@"profileImages"];
    [self.delegate didReceiveUserImages:images];
}

-(void)loadUsersUnseenPotentialMatches:(NSString *)sexPref minAge:(NSString *)min maxAge:(NSString *)max
{
    PFQuery *query = [User query];
    [query whereKey:@"objectId" notEqualTo:[User currentUser].objectId];
    [query whereKey:@"gender" equalTo:sexPref];
    [query whereKey:@"userAge" greaterThan:min];
    [query whereKey:@"userAge" lessThan:max];
    //[query whereKey:miles nearGeoPoint:nil withinMiles:user.milesAwayInt];
    // there has not been a pfrelation established yet
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        if (objects)
        {
            self.allMatchedUsers = objects;
            [self.delegate didReceivePotentialMatchData:objects];
        }
        else
        {
            [self.delegate failedToFetchPotentialMatchData:error];
            //[self.delegate failedToFetchPotentialMatchImages:error];
        }
    }];
}

-(void)loadAlreadySeenMatches
{
    NSArray *alreadySeenStatus = @[@"boyYes",@"girlYes",@"denied", @"pending", @"girlVerified", @"confidantNo", @"confidantKibosh"];

    PFQuery *query = [PFQuery queryWithClassName:@"MatchRequest"];
    [query whereKey:@"fromUser" equalTo:[User currentUser]];
    [query whereKey:@"status" containedIn:alreadySeenStatus];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects)
        {
            self.alreadySeenUsers = objects;
            [self.delegate didLoadAlreadySeen:objects];
        }
    }];
}

-(void)fromMessaging:(User*)user
{
    if (user == [User currentUser])
    {
        [self.delegate didComeFromMessaging:NO withUser:user];
    }
    else
    {
        [self.delegate didComeFromMessaging:YES withUser:user];
    }
}
//private
-(void)queryForUserWithObjectId:(NSString *)objectId completion:(resultBlockWithUser)completion
{
    PFQuery *query = [User query];
    [query getObjectInBackgroundWithId:objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if ([object isKindOfClass:[User class]])
        {
            User *user = (User*)object;
            completion(user, nil);
        }
        else
        {
            NSLog(@"error querying for User data: %@", error);
        }
    }];
}

-(void)queryForUserData:(NSString *)objectId withUser:(resultBlockWithUser)user
{
    PFQuery *query = [User query];
    [query whereKey:@"objectId" equalTo:objectId];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        if (objects)
        {
//            User *dict = objects.firstObject;
            user(objects.firstObject, nil);
        }
        else
        {
            NSLog(@"error querying for User data: %@", error);
        }
    }];
}

-(void)queryForImageCount:(NSString *)objectId
{
    PFQuery *query = [User query];
    [query whereKey:@"objectId" equalTo:objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        if (objects)
        {
            [self.delegate didReturnImageDataCount:objects.firstObject];
        }
        else
        {
            NSLog(@"error querying for User data: %@", error);
        }
    }];
}

-(void)queryForUsersConfidant:(resultBlockWithUserConfidant)confidant
{
    PFQuery *query = [User query];
    [query whereKey:@"user" equalTo:[User currentUser]];
    [query whereKeyExists:@"confidantEmail"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        if (objects)
        {
            User *dict = objects.firstObject;
            confidant(dict[@"confidantEmail"], nil);
        }
        else
        {
            NSLog(@"error querying for User data: %@", error);
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
@end