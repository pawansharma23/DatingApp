//
//  FacebookData.m
//  Pandemos
//
//  Created by Michael Sevy on 2/18/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "FacebookData.h"
#import <UIKit/UIKit.h>
#import <FBSDKGraphRequestConnection.h>
#import <FBSDKGraphRequest.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>

@implementation FacebookData

-(void)retriveFacebookThumbnails:(UIButton *)nextButton arrayForPictures:(NSMutableArray *)picArray andCollectionView:(UICollectionView *)collection
{
    //Retrieve images from user's facebook account and display them for user to sift through
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/photos/uploaded" parameters:@{@"fields": @"picture, updated_time"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
     {
         if (!error)
         {
             NSArray *dataArr = result[@"data"];
             //next/previous page results
             NSDictionary *paging = result[@"paging"];
             if (paging[@"next"] == nil)
             {
                 nextButton.hidden = YES;
             }
             if (dataArr)
             {
                 NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataArr];
                 NSArray *uniqueArray = [orderedSet array];
                 for (NSDictionary *imageData in uniqueArray)
                 {
                     //image id and 100X100 thumbnail of image from "picture" field above the nsdata object is for the 100x100 image
                     NSString *pictureIds = imageData[@"id"];
                     NSString *pictureURL = imageData[@"picture"];
                     //image conversion
                     NSURL *mainPicURL = [NSURL URLWithString:pictureURL];
                     NSData *mainPicData = [NSData dataWithContentsOfURL:mainPicURL];
                     //add the images to class
                     self.photoID = pictureIds;
                     self.photosData = mainPicData;
                     self.photoURL = mainPicURL;

                     [picArray addObject:self];
                     [collection reloadData];
                 }
             } else
             {
                 NSLog(@"no images");
             }
         } else
         {
             NSLog(@"error getting facebook images: %@", error);
         }
     }];
}
@end
