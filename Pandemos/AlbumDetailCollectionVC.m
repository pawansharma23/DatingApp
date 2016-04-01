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
#import "User.h"
#import "CVSettingCell.h"
#import "PreferencesViewController.h"
#import <LXReorderableCollectionViewFlowLayout.h>
#import "SwapImagesCV.h"
#import "AFNetworking.h"
#import "AddImageToProfileVC.h"
#import "UIColor+Pandemos.h"
#import "Facebook.h"

@interface AlbumDetailCollectionVC ()
<UICollectionViewDataSource,
UICollectionViewDelegate>

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
    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
    self.navigationItem.title = self.albumName;

    //collection view
    self.collectionView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor grayColor]);
    self.collectionView.layer.borderWidth = 1.0;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];


    NSLog(@"album id %@ & album Name %@", self.albumID, self.albumName);
//    FacebookData *faceD = [FacebookData new];
//    [faceD loadFacebookAlbum:self.albumID withPhotoArray:self.pictureArray andCollectionView:self.collectionView];
}



#pragma mark -- CollectionView methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return self.pictureArray.count;
}

- (SwapImagesCV *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SwapImagesCV *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
//    FacebookData *faceD = [self.pictureArray objectAtIndex:indexPath.item];
//    cell.image.image = [UIImage imageWithData:faceD.photoData];

    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    //selects the image and pushes to the next VC for full idisplay(not sure if this is the 100x100 or full image
//    FacebookData *selectedImage = [self.pictureArray objectAtIndex:indexPath.item];
//    self.selectedImage = selectedImage.photoID;
//    self.selectedImageData = selectedImage.photoData;
//    NSLog(@"seleceted image: %@", selectedImage.photoID);

    [self performSegueWithIdentifier:@"AddImage" sender:self];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AddImageToProfileVC *aitpvc = segue.destinationViewController;
    aitpvc.imageURL = self.selectedImage;
    aitpvc.imageData = self.selectedImageData;
}


@end





