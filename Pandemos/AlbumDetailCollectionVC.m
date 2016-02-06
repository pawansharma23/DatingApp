//
//  AlbumDetailCollectionVC.m
//  Pandemos
//
//  Created by Michael Sevy on 1/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

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
#import "AddImageToProfileVC.h"


@interface AlbumDetailCollectionVC ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) NSMutableArray *pictureArray;
@property (strong, nonatomic) NSString *nextURL;
@property (strong, nonatomic) NSString *previousURL;
@property (strong, nonatomic) NSString *selectedImage;
@property (strong, nonatomic) NSData *selectedImageData;


@end

@implementation AlbumDetailCollectionVC

static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.pictureArray = [NSMutableArray new];

    self.navigationController.navigationBar.barTintColor = [UserData yellowGreen];
    self.navigationItem.title = self.albumName;
    //collection view
    self.collectionView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor grayColor]);
    self.collectionView.layer.borderWidth = 1.0;
    self.collectionView.backgroundColor = [UIColor whiteColor];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];


   // [self.collectionView registerClass:[SwapImagesCV class]forCellWithReuseIdentifier:reuseIdentifier];
    NSLog(@"album id %@ & album Name %@", self.albumIdInAlbumDetail, self.albumName);
    //[self.view addSubview:self.collectionView];
    [self loadFacebookAlbum];
}



#pragma mark -- CollectionView methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pictureArray.count;
}

- (SwapImagesCV *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SwapImagesCV *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    UserData *userD = [self.pictureArray objectAtIndex:indexPath.item];
    cell.image.image = [UIImage imageWithData:userD.photosData];
    //NSLog(@"images from cell: %@", userD.photoID);
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {

    //selects the image and pushes to the next VC for full idisplay(not sure if this is the 100x100 or full image
    UserData *selectedImage = [self.pictureArray objectAtIndex:indexPath.item];
    self.selectedImage = selectedImage.photoID;
    self.selectedImageData = selectedImage.photosData;
    NSLog(@"seleceted image: %@", selectedImage.photoID);
    [self performSegueWithIdentifier:@"AddImage" sender:self];

}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    AddImageToProfileVC *aitpvc = segue.destinationViewController;
    aitpvc.imageURL = self.selectedImage;
    aitpvc.imageData = self.selectedImageData;

}
/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark -- load data Helpers
-(void)loadFacebookAlbum{

    //Images from specific album passed through
    NSString *albumIdPath = [NSString stringWithFormat:@"/%@/photos", self.albumIdInAlbumDetail];
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
                    //NSLog(@"URLs: %@", imageURL);
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





