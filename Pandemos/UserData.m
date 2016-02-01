//
//  UserData.m
//  Pandemos
//
//  Created by Michael Sevy on 12/19/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import "UserData.h"
#import <FBSDKGraphRequestConnection.h>
#import <FBSDKGraphRequest.h>
#import <Foundation/Foundation.h>
#import <Bolts/BFTask.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <ParseFacebookUtilsV4.h>
#import <Parse/PFConstants.h>
#import <Parse/PFUser.h>
#import <Parse/Parse.h>
#import "AFNetworking.h"
#import "RangeSlider.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <LXReorderableCollectionViewFlowLayout.h>
#import "ChooseImageInitialViewController.h"
#import "SuggestionsViewController.h"

#define FONT HELVETICA NEUE
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
//navBar


-(void)setUpButtons:(UIButton *)button{
    button.layer.cornerRadius = 15;
    button.clipsToBounds = YES;
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[UIColor blackColor].CGColor];
}


-(void)changeButtonState:(UIButton *)button {
    [button setHighlighted:YES];
    button.backgroundColor = [UIColor blackColor];
    [button setTitleColor:[UserData yellowGreen] forState:UIControlStateNormal];

}

-(void)changeOtherButton:(UIButton *)button{
    [button setHighlighted:NO];
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}


-(void)loadFacebookThumbnails:(UIButton *)nextButton arrayForPictures:(NSMutableArray *)picArray andCollectionView:(UICollectionView *)collection {
    //Retrieve images from user's facebook account and display them for user to sift through
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/photos/uploaded" parameters:@{@"fields": @"picture, updated_time"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSArray *dataArr = result[@"data"];
            //next/previous page results
            NSDictionary *paging = result[@"paging"];
            if (paging[@"next"] == nil) {
                nextButton.hidden = YES;
            }
            if (dataArr) {
                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataArr];
                NSArray *uniqueArray = [orderedSet array];
                for (NSDictionary *imageData in uniqueArray) {
                    //image id and 100X100 thumbnail of image from "picture" field above the nsdata object is for the 100x100 image
                    NSString *pictureIds = imageData[@"id"];
                    NSString *pictureURL = imageData[@"picture"];
                    //image conversion
                    NSURL *mainPicURL = [NSURL URLWithString:pictureURL];
                    NSData *mainPicData = [NSData dataWithContentsOfURL:mainPicURL];
                    //add the images to class
                    UserData *userD = [UserData new];
                    self.photoID = pictureIds;
                    userD.photosData = mainPicData;
                    self.photoURL = mainPicURL;

                    [picArray addObject:userD];
                    [collection reloadData];
                }
            } else{
                NSLog(@"no images");
            }
        } else{
            NSLog(@"error getting facebook images: %@", error);
        }
    }];
}



@end






