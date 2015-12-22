//
//  ViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 12/13/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import "ViewController.h"
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


@interface ViewController ()<FBSDKGraphRequestConnectionDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) PFUser *currentUser;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];

    //self.user = [PFUser new];
//    UIView *descriptionView = [[UIView alloc]initWithFrame:CGRectMake(0,0, 100, 75)];
//    descriptionView.backgroundColor = [UIColor colorWithRed:74.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:1.0];
//    [self.view addConstraint:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(descriptionView)]];
//
//
//    UILabel *usernameLabel, *jobLabel, *schoolLabel, *interestLabel;
//    usernameLabel = [[UILabel alloc]init];
//    jobLabel = [[UILabel alloc]init];
//    schoolLabel = [[UILabel alloc]init];
//    interestLabel = [[UILabel alloc]init];
//
//    [descriptionView addSubview:usernameLabel];
//    [descriptionView addSubview:jobLabel];



    self.userImage.backgroundColor = [UIColor greenColor];




    //[self.view addSubview:descriptionView];



}

-(void)viewDidAppear:(BOOL)animated{
   

}



@end








