//
//  UserData.h
//  Pandemos
//
//  Created by Michael Sevy on 12/19/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define APP_TITLE @"DoteOn"

@interface UserData : NSObject
//from FB public profile data
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *locale;
@property (strong, nonatomic) NSString *timezone;
@property (strong, nonatomic) NSString *verified;
//Ind. FB Categories
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *likes;
@property (strong, nonatomic) NSString *birthdayString;
@property (strong, nonatomic) NSString *hometown;
@property (strong, nonatomic) NSString *educationHistory;
@property (strong, nonatomic) NSString *location;

@property (strong, nonatomic) NSString *photoID;
@property (strong, nonatomic) NSURL *photoURL;
@property (strong, nonatomic) NSData *photosData;
@property (strong, nonatomic) NSString *albumId;
@property (strong, nonatomic) NSString *realAlbumId;

@property (strong, nonatomic) NSString *image1;
@property (strong, nonatomic) NSString *image2;
@property (strong, nonatomic) NSString *image3;

@property (strong, nonatomic) NSString *nextPageURL;

@property (strong, nonatomic) NSString *aboutMe;//user description
@property (strong, nonatomic) NSString *username;

+(UIColor *)facebookBlue;
+(UIColor *)rubyRed;
+(UIColor *)uclaBlue;
+(UIColor *)yellowGreen;

-(void)setUpButtons:(UIButton *)button;
-(void)changeButtonState:(UIButton *)button;
-(void)changeOtherButton:(UIButton *)button;

-(void)loadFacebookThumbnails:(UIButton *)nextButton arrayForPictures:(NSMutableArray *)picArray andCollectionView:(UICollectionView *)collection;

@end





