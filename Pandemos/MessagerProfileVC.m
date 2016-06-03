//
//  MessagerProfileVC.m
//  Pandemos
//
//  Created by Michael Sevy on 5/10/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MessagerProfileVC.h"
#import <Foundation/Foundation.h>
#import "MessagingViewController.h"
#import "UIColor+Pandemos.h"
#import "UIButton+Additions.h"
#import "NSString+Additions.h"
#import "UIImageView+Additions.h"
#import "UIImage+Additions.h"
#import "User.h"
#import "UserManager.h"
#import "ProfileImageView.h"

@interface MessagerProfileVC ()<UIScrollViewDelegate,
UserManagerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backToConversation;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendMessage;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;

@property (strong, nonatomic) NSString *currentCityAndState;
@property (strong, nonatomic) NSString *aboutMe;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) User *passedUser;
@property (strong, nonatomic) UserManager *userManager;
@property (strong, nonatomic) NSMutableArray *profileImages;
@property (strong, nonatomic) NSString *nameAndAgeGlobal;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) PFGeoPoint *pfGeoCoded;
@property int count;
@property (strong, nonatomic) UIScrollView *imageScroll;
@property (strong, nonatomic) ProfileImageView *piv;

@end

@implementation MessagerProfileVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.userManager = [UserManager new];
    self.userManager.delegate = self;
    self.currentUser = [User currentUser];
    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
    self.profileImages = [NSMutableArray new];

    //[self.userManager queryForImageCount:self.messagingUser.objectId];

    self.backToConversation.tintColor = [UIColor mikeGray];
    self.backToConversation.image = [UIImage imageWithImage:[UIImage imageNamed:@"Back"] scaledToSize:CGSizeMake(25.0, 25.0)];
    self.sendMessage.title = @"Matches";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];

    self.count = 0;

    [self setupManagersProfileVCForCurrentUser];

}

- (IBAction)onMatchController:(UIBarButtonItem *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)onCloseButton:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- USER MANAGER DELEGATE
-(void)setupManagersProfileVCForCurrentUser
{
    self.piv = [[ProfileImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.piv];

    [self.userManager queryForUserData:self.messagingUser.objectId withUser:^(User *user, NSError *error) {

        NSDictionary *userDict = user;
        NSString *bday = userDict[@"birthday"];
        NSString *nameAndAge = [NSString stringWithFormat:@"%@, %@", userDict[@"givenName"], [bday ageFromBirthday:bday]];
        self.piv.nameLabel.text = nameAndAge;
        self.piv.schoolLabel.text = @"aksjdf ;aklsdjfk ;lasjdfklajsdfl;kaj dfkja aksjdflak; sjdfk ;aljsdfk jasdl;k fj";

        //userDict[@"lastSchool"];
        self.navBar.title = userDict[@"givenName"];

        //send a usermanaer delegate the profileimagecount to call in View
        self.profileImages = userDict[@"profileImages"];

        switch ((int)self.profileImages.count) {
            case 1:
                self.piv.imageScroll.contentSize = CGSizeMake(self.piv.frame.size.width, self.piv.frame.size.height);
                self.piv.profileImageView.image = [UIImage imageWithImage:[UIImage imageWithString:[self.profileImages objectAtIndex:0]] scaledToSize:CGSizeMake(375, 667)];
                break;
            case 2:
                self.piv.imageScroll.contentSize = CGSizeMake(self.piv.frame.size.width, self.piv.frame.size.height * 2);
                self.piv.profileImageView.image = [UIImage imageWithString:[self.profileImages objectAtIndex:0]];
                self.piv.profileImageView2.image = [UIImage imageWithString:[self.profileImages objectAtIndex:1]];
                break;
            case 3:
                self.piv.imageScroll.contentSize = CGSizeMake(self.piv.frame.size.width, self.piv.frame.size.height * 3);
                self.piv.profileImageView.image = [UIImage imageWithString:[self.profileImages objectAtIndex:0]];
                self.piv.profileImageView2.image = [UIImage imageWithString:[self.profileImages objectAtIndex:1]];
                self.piv.profileImageView3.image = [UIImage imageWithString:[self.profileImages objectAtIndex:2]];
                break;
            case 4:
                self.piv.imageScroll.contentSize = CGSizeMake(self.piv.frame.size.width, self.piv.frame.size.height * 4);
                self.piv.profileImageView.image = [UIImage imageWithString:[self.profileImages objectAtIndex:0]];
                self.piv.profileImageView2.image = [UIImage imageWithString:[self.profileImages objectAtIndex:1]];
                self.piv.profileImageView3.image = [UIImage imageWithString:[self.profileImages objectAtIndex:2]];
                self.piv.profileImageView4.image = [UIImage imageWithString:[self.profileImages objectAtIndex:3]];
                break;
            case 5:
                self.piv.imageScroll.contentSize = CGSizeMake(self.piv.frame.size.width, self.piv.frame.size.height * 5);
                self.piv.profileImageView.image = [UIImage imageWithString:[self.profileImages objectAtIndex:0]];
                self.piv.profileImageView2.image = [UIImage imageWithString:[self.profileImages objectAtIndex:1]];
                self.piv.profileImageView3.image = [UIImage imageWithString:[self.profileImages objectAtIndex:2]];
                self.piv.profileImageView4.image = [UIImage imageWithString:[self.profileImages objectAtIndex:3]];
                self.piv.profileImageView5.image = [UIImage imageWithString:[self.profileImages objectAtIndex:4]];
                break;
            case 6:
                self.piv.imageScroll.contentSize = CGSizeMake(self.piv.frame.size.width, self.piv.frame.size.height * 6);
                self.piv.profileImageView.image = [UIImage imageWithString:[self.profileImages objectAtIndex:0]];
                self.piv.profileImageView2.image = [UIImage imageWithString:[self.profileImages objectAtIndex:1]];
                self.piv.profileImageView3.image = [UIImage imageWithString:[self.profileImages objectAtIndex:2]];
                self.piv.profileImageView4.image = [UIImage imageWithString:[self.profileImages objectAtIndex:3]];
                self.piv.profileImageView5.image = [UIImage imageWithString:[self.profileImages objectAtIndex:4]];
                self.piv.profileImageView6.image = [UIImage imageWithString:[self.profileImages objectAtIndex:5]];
                break;
            default:
                NSLog(@"no images for ProfileImageView switch");
                break;
        }

    }];
}
@end