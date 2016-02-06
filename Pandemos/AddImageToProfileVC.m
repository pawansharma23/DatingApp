//
//  AddImageToProfileVC.m
//  Pandemos
//
//  Created by Michael Sevy on 2/4/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "AddImageToProfileVC.h"
#import <Foundation/Foundation.h>
#import <Bolts/BFTask.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <ParseFacebookUtilsV4.h>
#import <Parse/PFConstants.h>
#import <Parse/PFUser.h>
#import <Parse/Parse.h>
#import <FBSDKGraphRequest.h>
#import <FBSDKGraphRequestConnection.h>
#import "UserData.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <LXReorderableCollectionViewFlowLayout.h>

@interface AddImageToProfileVC ()
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIImageView *smallImage;

@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *saveImageButton;
@property (weak, nonatomic) IBOutlet UIButton *addMoreImages;
@property (weak, nonatomic) IBOutlet UIButton *backToProfileButton;

//global images
@property (strong, nonatomic) NSString *image1;
@property (strong, nonatomic) NSString *image2;
@property (strong, nonatomic) NSString *image3;
@property (strong, nonatomic) NSString *image4;
@property (strong, nonatomic) NSString *image5;
@property (strong, nonatomic) NSString *image6;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSMutableArray *pictures;



@end

@implementation AddImageToProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];

    self.loadingView.alpha = .75;
    [self.spinner startAnimating];
    self.mainImage.image = [UIImage imageWithData:self.imageData];
    self.smallImage.image = [UIImage imageWithData:self.imageData];
    NSLog(@"image url: %@", self.imageURL);

    //buttons
    UserData * userD = [UserData new];
    [userD setUpButtons:self.saveImageButton];
    [userD setUpButtons:self.addMoreImages];
    [userD setUpButtons:self.backToProfileButton];

    //get "no data" from backend
    PFQuery *query = [PFUser query];

    //this is quering the user info from the PFUser cached in sim, which is not the usr that is logged in??
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){

            //userImages
            self.image1 = [[objects firstObject] objectForKey:@"image1"];
            self.image2 = [[objects firstObject] objectForKey:@"image2"];
            self.image3 = [[objects firstObject] objectForKey:@"image3"];
            self.image4 = [[objects firstObject] objectForKey:@"image4"];
            self.image5 = [[objects firstObject] objectForKey:@"image5"];
            self.image6 = [[objects firstObject] objectForKey:@"image6"];

            if (self.image1) {
                [self.pictures addObject:self.image1];
            } if (self.image2) {
                [self.pictures addObject:self.image2];
            } if (self.image3) {
                [self.pictures addObject:self.image3];
            } if (self.image4) {
                [self.pictures addObject:self.image4];
            } if (self.image5) {
                [self.pictures addObject:self.image5];
            } if (self.image6) {
                [self.pictures addObject:self.image6];
            }
            //NSLog(@"picture array: %@", self.pictures);

           // [self.collectionView reloadData];
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];

    [self.spinner stopAnimating];
    self.loadingView.hidden = YES;
    self.spinner.hidden = YES;
    self.loadingLabel.hidden = YES;
}

- (IBAction)onSaveImage:(id)sender {

    UserData *userD = [UserData new];
    [userD changeButtonState:self.saveImageButton];

    if (!self.image1) {
        NSLog(@"nothing in 1");
        [self.currentUser setObject:self.imageURL forKey:@"image1"];

        [self.currentUser saveInBackground];
        [self.saveImageButton setTitle:@"Saved Image 1" forState:UIControlStateNormal];

       // [self.collectionView reloadData];

    } else if (self.image1 && !self.image2) {

        NSLog(@"1 occupied, 2 empty");
        [self.currentUser setObject:self.imageURL forKey:@"image2"];
        [self.currentUser saveInBackground];

        [self.saveImageButton setTitle:@"Saved Image 2" forState:UIControlStateNormal];
        //[self.collectionView reloadData];

    } else if (self.image1 && self.image2 && !self.image3){
        NSLog(@"1 & 2 occ, 3 empty");
        [self.currentUser setObject:self.imageURL forKey:@"image3"];
        [self.currentUser saveInBackground];
        [self.saveImageButton setTitle:@"Saved Image 3" forState:UIControlStateNormal];


        //[self.collectionView reloadData];

    } else if (self.image1 && self.image2 && self.image3 && !self.image4){
        NSLog(@"1, 2, 3 occ, 4 empty");
        [self.currentUser setObject:self.imageURL forKey:@"image4"];
        [self.currentUser saveInBackground];

        [self.saveImageButton setTitle:@"Saved Image 4" forState:UIControlStateNormal];

//        [self.collectionView reloadData];

    } else if (self.image1 && self.image2 && self.image3 && self.image4 && !self.image5){

        NSLog(@"1, 2, 3, 4 occ 5 empty");

        [self.currentUser setObject:self.imageURL forKey:@"image5"];
        [self.currentUser saveInBackground];
        [self.saveImageButton setTitle:@"Saved Image 5" forState:UIControlStateNormal];

      //  [self.collectionView reloadData];

    } else if (self.image1 && self.image2 && self.image3 && self.image4 && self.image5 && !self.image6){

        NSLog(@"1, 2, 3, 4, 5 occ 6 empty");
        [self.currentUser setObject:self.imageURL forKey:@"image6"];
        [self.currentUser saveInBackground];
        [self.saveImageButton setTitle:@"Save as Image 6" forState:UIControlStateNormal];

       // [self.collectionView reloadData];

    }else{
        NSLog(@"all images Filled");
        [self.saveImageButton setTitle:@"All Full :)" forState:UIControlStateNormal];
    }
}

- (IBAction)onAddMore:(id)sender {

    UserData *userD = [UserData new];
    [userD changeButtonState:self.addMoreImages];
    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)onProfile:(UIButton *)sender {
    UserData *userD = [UserData new];
    [userD changeButtonState:self.backToProfileButton];
    [self performSegueWithIdentifier:@"BackToProfile" sender:self];
}

@end







