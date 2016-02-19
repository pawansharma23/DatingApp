//
//  UserData.m
//  Pandemos
//
//  Created by Michael Sevy on 12/19/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import "UserData.h"
#import <Foundation/Foundation.h>
#import <Bolts/BFTask.h>
#import <ParseFacebookUtilsV4.h>
#import <Parse/PFConstants.h>
#import <Parse/PFUser.h>
#import <Parse/Parse.h>
#import "AFNetworking.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <LXReorderableCollectionViewFlowLayout.h>
#import "ChooseImageInitialViewController.h"
#import "SuggestionsViewController.h"

#define FONT HELVETICA NEUE
NSString * const kParseObjectId                    = @"objectId";
NSString * const kFacebookId                        =@"faceID";
NSString * const kParseFullName                     = @"fullName";
NSString * const kParseFirstName                    = @"firstName";
NSString * const kParseUserBirthday                 = @"birthday";
NSString * const kParseUserGender                   = @"gender";
NSString * const kParseUserSexPreference            = @"sexPref";
NSString * const kParseUserCurrentLocation          = @"currentLocation";
NSString * const kParseUserMilesAwayPreferece       = @"milesAway";
NSString * const kParseUserPreferenceMinAge         = @"minAge";
NSString * const kParseUserPreferenceMaxAge         = @"maxAge";
NSString * const kParseUserImage1                   = @"image1";
NSString * const kParseUserImage2                   = @"image2";
NSString * const kParseUserImage3                   = @"image3";
NSString * const kParseUserImage4                   = @"image4";
NSString * const kParseUserImage5                   = @"image5";
NSString * const kParseUserImage6                   = @"image6";
NSString * const kParseEducation                    = @"scool";
NSString * const kParseFacebookLocation             = @"facebookLocation";
NSString * const kParseFacebookHometown             = @"facebookHometown";
NSString * const kParseWork                         = @"work";
NSString * const kParseConfidantEmail               = @"confidantEmail";
NSString * const kParseAboutMe                      = @"aboutMe";


//PFGeoPoint * const kParseGeoPoint   = @"GeoCode";

@implementation UserData
//unique colors
+(UIColor *)rubyRed {
    return [UIColor colorWithRed:255.0/255.0 green:84.0/255.0 blue:95.0/255.0 alpha:1.0];
}
+(UIColor *)uclaBlue    {
    return [UIColor colorWithRed:50.0/255.0 green:132.0/255.0 blue:191.0/255.0 alpha:1.0];
}
+(UIColor *)yellowGreen {
    return [UIColor colorWithRed:242.0/255.0 green:255.0/255.0 blue:118.0/255.0 alpha:1.0];
}
+(UIColor *)facebookBlue{
    return [UIColor colorWithRed:59.0/255.0 green:89.0/255.0 blue:152.0/255.0 alpha:1.0];
}


-(void)setUpButtons:(UIButton *)button
{
    button.layer.cornerRadius = 15;
    button.clipsToBounds = YES;
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[UIColor blackColor].CGColor];
}


-(void)changeButtonState:(UIButton *)button
{
    [button setHighlighted:YES];
    button.backgroundColor = [UIColor blackColor];
    [button setTitleColor:[UserData yellowGreen] forState:UIControlStateNormal];
}

-(void)changeOtherButton:(UIButton *)button
{
    [button setHighlighted:NO];
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}




-(void)loadUserDataFromParse:(PFUser *)user
{
    NSString *objectId = [user objectForKey:kParseObjectId];
    NSString *faceId = [user objectForKey:kFacebookId];
    NSString *userFullName = [user objectForKey:kParseFullName];
    NSString *userFirstName = [user objectForKey:kParseFirstName];
    NSString *userBirthdayDay = [user objectForKey:kParseUserBirthday];
    NSString *userGender = [user objectForKey:kParseUserGender];
    NSString *userSexPref = [user objectForKey:kParseUserSexPreference];
    NSString *userCurrentLocation = [user objectForKey:kParseUserCurrentLocation];
    NSString *userMilesAway = [user objectForKey:kParseUserMilesAwayPreferece];
    NSString *userMinAge = [user objectForKey:kParseUserPreferenceMinAge];
    NSString *userMaxAge = [user objectForKey:kParseUserPreferenceMaxAge];
    NSString *userImage1 = [user objectForKey:kParseUserImage1];
    NSString *userImage2 = [user objectForKey:kParseUserImage2];
    NSString *userImage3 = [user objectForKey:kParseUserImage3];
    NSString *userImage4 = [user objectForKey:kParseUserImage4];
    NSString *userImage5 = [user objectForKey:kParseUserImage5];
    NSString *userImage6 = [user objectForKey:kParseUserImage6];
    //PFGeoPoint *geoPoint = [user objectForKey:kParseGeoPoint];
    NSString *userEducation = [user objectForKey:kParseEducation];
    NSString *facebookLoc = [user objectForKey:kParseFacebookLocation];
    NSString *facebookHometown = [user objectForKey:kParseFacebookHometown];
    NSString *userWork = [user objectForKey:kParseWork];
    NSString *userConfidantEmail = [user objectForKey:kParseConfidantEmail];
    NSString *userAboutMe = [user objectForKey:kParseAboutMe];

    //assign
    if (objectId) {
        self.objectID = objectId;
    }
    if (faceId) {
        self.facebookID = faceId;
    }
    if (userFullName)
    {
        self.fullName = userFullName;
    }
    if (userFirstName)
    {
        self.firstName = userFirstName;
    }
    if (userBirthdayDay)
    {
        self.birthday = userBirthdayDay;
    }
    if (userGender)
    {
        self.gender = userGender;
    }
    if (userSexPref)
    {
        self.sexPref = userSexPref;
    }
    if (userCurrentLocation)
    {
        self.currentLocation = userCurrentLocation;
    }
    if (userMilesAway)
    {
        self.milesAway = userMilesAway;
    }
    if (userMinAge)
    {
        self.minAge = userMinAge;
    }
    if (userMaxAge)
    {
        self.maxAge = userMaxAge;
    }
    if (userImage1)
    {
        self.image1 = userImage1;
    }
    if (userImage2)
    {
        self.image2 = userImage2;
    }
    if (userImage3)
    {
        self.image3 = userImage3;
    }
    if (userImage4)
    {
        self.image4 = userImage4;
    }
    if (userImage5)
    {
        self.image5 = userImage5;
    }
    if (userImage6)
    {
        self.image6 = userImage6;
    }
    if (userEducation)
    {
        self.education = userEducation;
    }
    if (facebookLoc)
    {
        self.facebookLocation = facebookLoc;
    }
    if (facebookHometown)
    {
        self.facebookHometown = facebookHometown;
    }
    if (userWork)
    {
        self.work = userWork;
    }
    if (userConfidantEmail)
    {
        self.confidantEmail = userConfidantEmail;
    }
    if (userAboutMe)
    {
        self.aboutMe = userAboutMe;
    }

    self.age = [self ageFromBirthday:userBirthdayDay];
    self.milesAwayInt = [userMilesAway intValue];
}

-(NSString *)ageFromBirthday:(NSString *)birthday
{
    //Caculate age from birthday
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *todaysDate = [NSDate date];
    NSDate *birthdateNSDate = [formatter dateFromString:birthday];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:birthdateNSDate toDate:todaysDate options:0];
    NSUInteger age = ageComponents.year;
    NSString *ageStr = [NSString stringWithFormat:@"%lu", (unsigned long)age];

    return ageStr;
}
@end







