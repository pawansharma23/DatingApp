//
//  AddMoreImagesViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "AddMoreImagesViewController.h"
#import <FBSDKGraphRequestConnection.h>
#import "UserData.h"
#import "AddImageCell.h"
#import "InitialWalkThroughViewController.h"
#import <Foundation/Foundation.h>
#import <Bolts/BFTask.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <ParseFacebookUtilsV4.h>
#import <Parse/PFConstants.h>
#import <Parse/PFUser.h>
#import <Parse/Parse.h>
#import <FBSDKGraphRequest.h>
#import "CVCell.h"
#import "AFNetworking.h"
#import "RangeSlider.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <LXReorderableCollectionViewFlowLayout.h>
#import "ChooseImageInitialViewController.h"
#import "SuggestionsViewController.h"


@interface AddMoreImagesViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *otherFacebookButton;
@property (strong, nonatomic) NSString *nextURL;
@property (strong, nonatomic) NSString *previousURL;

@property (strong, nonatomic) NSMutableArray *pictureArray;

@end

@implementation AddMoreImagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionView.delegate = self;
    self.pictureArray = [NSMutableArray new];

    self.navigationItem.title = @"Add more";
    self.navigationController.navigationBar.backgroundColor = [UserData yellowGreen];

    self.automaticallyAdjustsScrollViewInsets = NO;


    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];

    UserData *userD = [UserData new];
    [userD loadFacebookThumbnails:self.nextButton arrayForPictures:self.pictureArray andCollectionView:self.collectionView];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pictureArray.count;
}

-(AddImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"AddImageCell";
    AddImageCell *cell = (AddImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UserData *userData = [self.pictureArray objectAtIndex:indexPath.row];
    cell.image.image = [UIImage imageWithData:userData.photosData];

    return cell;
}

- (IBAction)onOtherFacebookAlbums:(UIButton *)sender {
    [self performSegueWithIdentifier:@"FacebookAlbums" sender:self];
}


- (IBAction)onNextButton:(UIButton *)sender {
    [self onNextPrevPage:self.nextURL];
}


- (IBAction)onPreviousButton:(UIButton *)sender {
    [self onNextPrevPage:self.previousURL];
}

#pragma mark -- Next/Previous Page
-(void)onNextPrevPage:(NSString *)pageURLString {
    NSURL *URL = [NSURL URLWithString:pageURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionDataTask *dTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, NSData *data , NSError * _Nullable error) {

        if (!response) {
            NSLog(@"error: %@", error);
        } else{
            //remove the current images from the collectionview array
            [self.pictureArray removeAllObjects];
            NSDictionary *objects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSArray *dataFromJSON = objects[@"data"];

            //get next and previous urls
            NSDictionary *paging = objects[@"paging"];
            //store em globally
            self.nextURL = paging[@"next"];
            self.previousURL = paging[@"previous"];

            //arrange image array
            NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataFromJSON];
            NSArray *uniqueArray = [orderedSet array];
            //run loop to get images data
            for (NSDictionary *imageData in uniqueArray) {
                NSString *picURLString = imageData[@"picture"];
                //image conversion to NSData and stored in UserData object
                NSURL *mainPicURL = [NSURL URLWithString:picURLString];
                NSData *mainPicData = [NSData dataWithContentsOfURL:mainPicURL];
                // NSString *updatedTime = imageData[@"updated_time"];
                UserData *userD = [UserData new];
                userD.photosData = mainPicData;

                [self.pictureArray addObject:userD];
                [self.collectionView reloadData];
                //pops cursor to the top of the collectionView
                [self.collectionView setContentOffset:CGPointZero animated:YES];
            }
        }
    }];
    
    [dTask resume];
}

@end










