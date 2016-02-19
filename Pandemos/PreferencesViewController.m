//
//  PreferencesViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 12/19/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

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

@interface PreferencesViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *pictureArray;
@property (strong, nonatomic) NSString *nextURL;
@property (strong, nonatomic) NSString *albumId;
@property (strong, nonatomic) NSString *albumName;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *activityBackView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;


@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pictureArray = [NSMutableArray new];
    self.tableView.delegate = self;
    
    self.navigationItem.title = @"Change Pics";
    self.navigationController.navigationBar.backgroundColor = [UserData yellowGreen];

    self.automaticallyAdjustsScrollViewInsets = NO;

    self.activityBackView.alpha = .75;
    self.activityBackView.layer.cornerRadius = 10;
    [self.spinner startAnimating];


    //former didAppear
    [self.pictureArray removeAllObjects];
    [self loadFacebookAlbumList];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.pictureArray.count;
}

-(AlbumCustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlbumCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    UserData *userD = [self.pictureArray objectAtIndex:indexPath.row];
    cell.albumNames.text = userD.albumId;
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
    [self performSegueWithIdentifier:@"AlbumDetail" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AlbumDetail"]) {
        NSLog(@"segueing: this: %@", self.albumId);

        AlbumDetailCollectionVC *advc = segue.destinationViewController;
        advc.albumIdInAlbumDetail = self.albumId;
        advc.albumName = self.albumName;
    }
}



#pragma mark -- load Data helpers
-(void)loadFacebookAlbumList{

    //now get images from user's facebook account and display them for user to sift through
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/albums" parameters:@{@"fields": @"picture, count, updated_time, name"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
            //NSLog(@"image data %@", result);
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
                    NSNumber *albumCount = imageData[@"count"];
                    NSString *albumCountStr = [NSString stringWithFormat:@"%@", albumCount];
                    NSString *name = imageData[@"name"];
                    NSDictionary *picture = imageData[@"picture"];
                    NSDictionary *data = picture[@"data"];
                    NSString *pictureURL = data[@"url"];
                    NSLog(@"URLs: %@", pictureURL);
                    // NSString *updatedtime = imageData[@"updated_time"];
                    //image conversion
                    NSURL *mainPicURL = [NSURL URLWithString:pictureURL];
                    NSData *mainPicData = [NSData dataWithContentsOfURL:mainPicURL];

                    UserData *userD = [UserData new];
                    userD.imageCount = albumCountStr;
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
            [self.spinner stopAnimating];
            self.activityBackView.hidden = YES;
            self.loadingLabel.hidden = YES;
            self.spinner.hidden = YES;
}

-(NSData *)imageData:(NSString *)imageString{

    NSURL *url = [NSURL URLWithString:imageString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}

@end






