//
//  FacebookAlbumsTableVC.m
//  Pandemos
//
//  Created by Michael Sevy on 1/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "FacebookAlbumsTableVC.h"
#import "FacebookTableViewCell.h"
#import "PreferencesViewController.h"
#import "ProfileViewController.h"
#import <Foundation/Foundation.h>
#import <Bolts/BFTask.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <ParseFacebookUtilsV4.h>
#import <Parse/PFConstants.h>
#import <Parse/PFUser.h>
#import <FBSDKGraphRequest.h>
#import <FBSDKGraphRequestConnection.h>
#import "UserData.h"
#import <Parse/Parse.h>
#import "RangeSlider.h"
#import <MessageUI/MessageUI.h>
#import "CVSettingCell.h"
#import "PreferencesViewController.h"
#import <LXReorderableCollectionViewFlowLayout.h>
#import "SwapImagesCV.h"
#import "AFNetworking.h"
#import "AlbumCustomCell.h"
#import "AlbumDetailCollectionVC.h"
#import "FacebookDetailViewController.h"

@interface FacebookAlbumsTableVC ()

@property (strong, nonatomic) NSMutableArray *pictureArray;
@property (strong, nonatomic) NSString *albumName;
@property (strong, nonatomic) NSString *albumId;

@end

@implementation FacebookAlbumsTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Facebook Albums";
    self.navigationController.navigationBar.backgroundColor = [UserData yellowGreen];
    
    self.tableView.delegate = self;
    self.pictureArray = [NSMutableArray new];
    [self loadFacebookAlbumList];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.pictureArray.count;
}

-(FacebookTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    FacebookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UserData *userD = [self.pictureArray objectAtIndex:indexPath.row];
    cell.albumTitleLabel.text = userD.albumId;
    cell.albumCountLabel.text = userD.imageCount;
    cell.albumImage.layer.cornerRadius = 9;
    cell.albumImage.image = [UIImage imageWithData:userD.photosData];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    UserData *selectedPath = [self.pictureArray objectAtIndex:indexPath.row];
    self.albumId = selectedPath.realAlbumId;
    self.albumName = selectedPath.albumId;
    NSLog(@"album path selected to push on %@", self.albumId);
    [self performSegueWithIdentifier:@"FacebookDetail" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FacebookDetail"]) {
        NSLog(@"segueing: this: %@", self.albumId);

        FacebookDetailViewController *fdvc = segue.destinationViewController;
        fdvc.albumId = self.albumId;
        fdvc.albumName = self.albumName;
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark -- load Data helpers
-(void)loadFacebookAlbumList{

    //now get images from user's facebook account and display them for user to sift through
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/albums" parameters:@{@"fields": @"picture, count, updated_time, name"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
             NSLog(@"image data %@", result);
            NSArray *dataArr = result[@"data"];
            //next/previous page results
            NSDictionary *paging = result[@"paging"];
            if (paging[@"next"] == nil) {

                //self.nextButton.hidden = YES;
            }
            if (dataArr) {

                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataArr];
                NSArray *uniqueArray = [orderedSet array];

                for (NSDictionary *imageData in uniqueArray) {

                    //image id and 100X100 thumbnail of image from "picture" field above the nsdata object is for the 100x100 image
                    NSString *realAlbumId = imageData[@"id"];
                    NSString *name = imageData[@"name"];
                    NSNumber *countForImages = imageData[@"count"];
                    NSString *countForImageStr = [NSString stringWithFormat:@"%@", countForImages];
                    NSDictionary *picture = imageData[@"picture"];
                    NSDictionary *data = picture[@"data"];
                    NSString *pictureURL = data[@"url"];
                    NSLog(@"URLs: %@ & count: %@", pictureURL, countForImages);
                    // NSString *updatedtime = imageData[@"updated_time"];
                    //image conversion
                    NSURL *mainPicURL = [NSURL URLWithString:pictureURL];
                    NSData *mainPicData = [NSData dataWithContentsOfURL:mainPicURL];

                    UserData *userD = [UserData new];
                    userD.imageCount = countForImageStr;
                    userD.albumId = name;
                    userD.realAlbumId = realAlbumId;
                    userD.photosData = mainPicData;
                    userD.photoURL = mainPicURL;

                    [self.pictureArray addObject:userD];
                    [self.tableView reloadData];
                }
            } else{
                NSLog(@"no images");
            }

        } else{
            NSLog(@"error getting faceboko images: %@", error);
        }
    }];
}


@end
