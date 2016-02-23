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
#import "AFNetworking.h"

@implementation FacebookData

-(void)loadFacebookThumbnails:(UIButton *)nextButton arrayForPictures:(NSMutableArray *)picArray andCollectionView:(UICollectionView *)collection
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
                     self.photoData = mainPicData;
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

-(void)loadFacebookAlbum:(NSString *)albumID withPhotoArray:(NSMutableArray *)mutArray andCollectionView:(UICollectionView *)collectionView
{
    NSString *albumIdPath = [NSString stringWithFormat:@"/%@/photos", albumID];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:albumIdPath parameters:@{@"fields": @"source, updated_time"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error)
     {
         if (!error)
         {
             //NSLog(@"image data %@", result);
             NSArray *dataArr = result[@"data"];
             //next/previous page results
             NSDictionary *paging = result[@"paging"];
             NSString *nextPage = paging[@"next"];

             if (nextPage == nil)
             {
                 //self.nextButton.hidden = YES;
             }

             if (dataArr)
             {
                 NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataArr];
                 NSArray *uniqueArray = [orderedSet array];

                 for (NSDictionary *imageData in uniqueArray)
                 {
                     self.photoStr = imageData[@"source"];
                     self.photoTaken = imageData[@"updated_time"];
                     self.photoURL = [NSURL URLWithString:self.photoStr];
                     self.photoData = [NSData dataWithContentsOfURL:self.photoURL];

                     [mutArray addObject:self];
                     [collectionView reloadData];
                 }
             }
             else
             {
                 NSLog(@"no images");
             }

         } else
         {
             NSLog(@"error getting facebook images: %@", error);
         }
     }];
}

-(void)loadFacebookAlbumList:(NSMutableArray *)mutArray andTableView:(UITableView *)tableView
{
    //get images from user's facebook account and display them for user to sift through
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/albums" parameters:@{@"fields": @"picture, count, updated_time, name"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error)
        {
            NSArray *dataArr = result[@"data"];
            NSDictionary *paging = result[@"paging"];
            NSString *nextPage = paging[@"next"];
            if (!nextPage)
            {
                NSLog(@"only one page");
                //self.nextButton.hidden = YES;
            }
            if (dataArr)
            {
                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataArr];
                NSArray *uniqueArray = [orderedSet array];

                for (NSDictionary *imageData in uniqueArray)
                {
                    //image id and 100X100 thumbnail of image from "picture" field above the nsdata object is for the 100x100 image
                    self.albumId2 = imageData[@"id"];
                    NSNumber *albumCount = imageData[@"count"];
                    self.photoCount = [NSString stringWithFormat:@"%@", albumCount];
                    self.albumId = imageData[@"name"];
                    NSDictionary *picture = imageData[@"picture"];
                    NSDictionary *data = picture[@"data"];
                    self.photoStr = data[@"url"];
                    self.photoTaken = imageData[@"updated_time"];
                    self.photoURL = [NSURL URLWithString:self.photoStr];
                    self.photoData = [NSData dataWithContentsOfURL:self.photoURL];

                    [mutArray addObject:self];
                    [tableView reloadData];
                }
            }
            else
            {
                NSLog(@"no images");
            }

        }
        else
        {
            NSLog(@"error getting faceboko images: %@", error);
        }
    }];
}

-(void)loadNextPrevPage:(NSString *)pageURLString withPhotoArray:(NSMutableArray *)mutArray andCollectionView:(UICollectionView *)collectionView
{
    NSURL *URL = [NSURL URLWithString:pageURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionDataTask *dTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, NSData *data , NSError * _Nullable error) {

        if (!response)
        {
            NSLog(@"error: %@", error);
        }
        else
        {
            //remove the current images from the collectionview array
            [mutArray removeAllObjects];

            NSDictionary *objects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            //NSArray *dataFromJSON = objects[@"data"];
            NSDictionary *paging = objects[@"paging"];
            NSString *next = paging[@"next"];
            NSString *previous = paging[@"previous"];

            if (next)
            {
                self.nextPage = paging[@"next"];
            }

            if (previous)
            {
                self.previousPage = paging[@"previous"];
            }
            [collectionView setContentOffset:CGPointZero animated:YES];
            
        }
    }];
    
    [dTask resume];
}

@end
