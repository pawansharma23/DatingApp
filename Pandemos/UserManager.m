//
//  UserNetwork.m
//  Pandemos
//
//  Created by Michael Sevy on 4/6/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//
#import "UserManager.h"
#import "User.h"

@implementation UserManager

static NSString * const kParseObjectId                     = @"objectId";
static NSString * const kFacebookId                        = @"faceID";
static NSString * const kParseGivenName                    = @"givenName";
static NSString * const kParseUserBirthday                 = @"birthday";
static NSString * const kParseUserGender                   = @"gender";
static NSString * const kParseUserSexPreference            = @"sexPref";
static NSString * const kParseUserFBLocation               = @"facebookLocation";
static NSString * const kParseUserMilesAwayPreferece       = @"milesAway";
static NSString * const kParseUserPreferenceMinAge         = @"minAge";
static NSString * const kParseUserPreferenceMaxAge         = @"maxAge";
static NSString * const kParseUserImage1                   = @"image1";
static NSString * const kParseUserImage2                   = @"image2";
static NSString * const kParseUserImage3                   = @"image3";
static NSString * const kParseUserImage4                   = @"image4";
static NSString * const kParseUserImage5                   = @"image5";
static NSString * const kParseUserImage6                   = @"image6";
static NSString * const kParseEducation                    = @"scool";
static NSString * const kParseFacebookHometown             = @"facebookHometown";
static NSString * const kParseWork                         = @"work";
static NSString * const kParseConfidantEmail               = @"confidantEmail";
static NSString * const kParseAboutMe                      = @"aboutMe";
static NSString * const kParsePublic                       = @"publicProfile";

//PFGeoPoint * const kParseGeoPoint= @"GeoCode";

-(void)loadUserData:(User *)user
{
    NSMutableArray *userData = [NSMutableArray new];
    User *ob = [User new];

    NSString *objectId = [user objectForKey:kParseObjectId];
    NSString *faceId = [user objectForKey:kFacebookId];
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

    if (objectId)
    {
        ob.objectID = objectId;
    }
    if (faceId)
    {
        ob.faceID = faceId;
    }
    if (givenName)
    {
        ob.givenName = givenName;
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
    if (birthday)
    {
        ob.birthday = birthday;
    }
    if (pubProf)
    {
        ob.publicProfile = pubProf;
    }

    [userData addObject:ob];
    //self.milesAwayInt = [userMilesAway intValue];
    NSArray *array = [NSArray arrayWithArray:userData];

    [self.delegate didReceiveUserData:array];
}

-(void)loadUserImages:(User *)user;
{
    NSArray *images = [user objectForKey:@"profileImages"];
    [self.delegate didReceiveUserImages:images];
}
@end
