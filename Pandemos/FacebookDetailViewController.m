//
//  FacebookDetailViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "FacebookDetailViewController.h"
#import "AlbumDetailCollectionVC.h"
#import "SwapImagesCV.h"
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
#import "FacebookCVCell.h"
#import "ChooseImageInitialViewController.h"


@interface FacebookDetailViewController ()<UICollectionViewDataSource,
UICollectionViewDelegate>

@property (strong, nonatomic) NSMutableArray *pictureArray;
@property (strong, nonatomic) NSString *nextURL;
@property (strong, nonatomic) NSString *previousURL;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString *photoURL;
@property (strong, nonatomic) NSData *photoData;


@end

@implementation FacebookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;

    self.navigationItem.title = self.albumName;
    self.navigationController.navigationBar.backgroundColor = [UserData yellowGreen];
    
    self.collectionView.delegate = self;
    self.pictureArray = [NSMutableArray new];

    //collection view
    self.collectionView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor grayColor]);
    self.collectionView.layer.borderWidth = 1.0;
    self.collectionView.backgroundColor = [UIColor whiteColor];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];

    [self loadFacebookAlbum];

}


#pragma mark -- collectionView delegate Methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pictureArray.count;
}

-(FacebookCVCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    UserData *userD = [self.pictureArray objectAtIndex:indexPath.item];
    static NSString *cellIdentifier = @"Cell";
    FacebookCVCell *cell = (FacebookCVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.image.image = [UIImage imageWithData:userD.photosData];

    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {

    UserData *selectedPath = [self.pictureArray objectAtIndex:indexPath.row];
    self.photoURL = selectedPath.photoID;
    self.photoData = selectedPath.photosData;
    NSLog(@"photo URL: %@", self.photoURL);
    [self performSegueWithIdentifier:@"ChooseImageVC" sender:self];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ChooseImageVC"]) {

        ChooseImageInitialViewController *civc = segue.destinationViewController;
        civc.photoID = self.photoURL;
        civc.photoData = self.photoData;
    }
}

#pragma mark -- load data Helpers
-(void)loadFacebookAlbum{

    //Images from specific album passed through
    NSString *albumIdPath = [NSString stringWithFormat:@"/%@/photos", self.albumId];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:albumIdPath parameters:@{@"fields": @"source, updated_time"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
            //NSLog(@"image data %@", result);
            NSArray *dataArr = result[@"data"];
            //next/previous page results
            NSDictionary *paging = result[@"paging"];
            self.nextURL = paging[@"next"];
            if (paging[@"next"] == nil) {

                //self.nextButton.hidden = YES;
            }
            if (dataArr) {

                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataArr];
                NSArray *uniqueArray = [orderedSet array];

                for (NSDictionary *imageData in uniqueArray) {
                    //get the source url
                    NSString *imageURL = imageData[@"source"];
                    NSLog(@"URLs: %@", imageURL);
                    // NSString *updatedtime = imageData[@"updated_time"];
                    //image conversion
                    NSURL *mainPicURL = [NSURL URLWithString:imageURL];
                    NSData *mainPicData = [NSData dataWithContentsOfURL:mainPicURL];

                    UserData *userD = [UserData new];
                    userD.photosData = mainPicData;
                    userD.photoID = imageURL;

                    [self.pictureArray addObject:userD];
                    [self.collectionView reloadData];
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






