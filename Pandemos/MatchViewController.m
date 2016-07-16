//
//  MatchViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 6/8/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MatchViewController.h"
#import "User.h"
#import "DragBackground.h"
#import "AppConstants.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MessageUI/MessageUI.h>
#import "ProfileViewController.h"
#import "SVProgressHUD.h"
#import "AllyAdditions.h"

@interface MatchViewController()<CLLocationManagerDelegate,
MFMailComposeViewControllerDelegate>

{
    CLLocation *currentLocation;
    CLLocationManager *locationManager;
}
@property (strong, nonatomic) UIButton *button;
@end

@implementation MatchViewController

-(void)viewDidLoad
{

    if ([User currentUser].givenName)
    {

        NSLog(@"logged in user: %@ %@", [User currentUser].givenName, [User currentUser].objectId   );

        DragBackground *drag = [[DragBackground alloc]initWithFrame:self.view.frame];
        [self.view addSubview:drag];
        self.automaticallyAdjustsScrollViewInsets = NO;

        //*************for testing to original login**********
        self.button = [[UIButton alloc]initWithFrame:CGRectMake(10, 70, 60, 30)];
        [self.button setTitle:@"Setup" forState:UIControlStateNormal];
        self.button.backgroundColor = [UIColor blackColor];
        self.button.layer.cornerRadius = 15;
        self.button.layer.masksToBounds = YES;
        [self.view addSubview:self.button];
        [self.button addTarget:self action:@selector(segueToNoUser:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [self performSegueWithIdentifier:@"NoUser" sender:self];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];

    [self navigationItems];

    //[self currentLocationIdentifier];

}

#pragma mark -- CLLOCATION
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *locationForCoder = [locations firstObject];

    [locationManager stopUpdatingLocation];

    //get city and location from a CLPlacemark object
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:locationForCoder completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"error: %@", error);
        }
        else
        {
            CLPlacemark *placemark = [placemarks firstObject];
            NSString *city = placemark.locality;
            NSDictionary *stateDict = placemark.addressDictionary;
            NSString *state = stateDict[@"State"];
            self.currentCityState = [NSString stringWithFormat:@"%@, %@", city, state];
        }
    }];

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location manager failed: %@", error);
}

#pragma mark -- NAV
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Settings"])
    {
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *pvc = (ProfileViewController*)([navController viewControllers][0]);
        pvc.cityAndState = self.currentCityState;
    }
}

-(void)segueToNoUser:(UIButton*)sender
{
    [self performSegueWithIdentifier:@"NoUser" sender:self.button];
}

- (IBAction)onSettingsTapped:(UIBarButtonItem *)sender
{
    self.navigationItem.leftBarButtonItem.image = [UIImage imageWithImage:[UIImage imageNamed:@"noun_355600_cc"] scaledToSize:CGSizeMake(30, 30)];
    [self performSegueWithIdentifier:@"Settings" sender:self];
}
- (IBAction)onMessagesTapped:(UIBarButtonItem *)sender
{
    [SVProgressHUD dismiss];
    self.navigationItem.rightBarButtonItem.image = [UIImage imageWithImage:[UIImage imageNamed:@"noun_40490_cc"] scaledToSize:CGSizeMake(30, 30)];
    [self performSegueWithIdentifier:@"Messaging" sender:self];
}

#pragma mark -- HELPERS
-(void)currentLocationIdentifier
{
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

-(void)navigationItems
{
    self.navigationItem.title = APP_TITLE;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];

    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor blackColor]];
    //self.navigationItem.rightBarButtonItem.title = @"Chats";
    self.navigationItem.rightBarButtonItem.image = [UIImage imageWithImage:[UIImage imageNamed:@"noun_40347_cc"] scaledToSize:CGSizeMake(30, 30)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];

    self.navigationItem.leftBarButtonItem.image = [UIImage imageWithImage:[UIImage imageNamed:@"noun_355444_cc"] scaledToSize:CGSizeMake(30, 30)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
}
@end
