//
//  MatchViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 6/8/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MatchViewController.h"
#import "User.h"
#import "UIColor+Pandemos.h"
#import "UIImage+Additions.h"
#import "DragBackground.h"
#import "AppConstants.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MessageUI/MessageUI.h>
#import "ProfileViewController.h"
#import "SVProgressHUD.h"

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
        NSLog(@"logged in user: %@", [User currentUser].givenName);

        [self navigationItems];

        //[self currentLocationIdentifier];

        DragBackground *drag = [[DragBackground alloc]initWithFrame:self.view.frame];
        [self.view addSubview:drag];

        self.automaticallyAdjustsScrollViewInsets = NO;

        //*************for testing to original login**********
        self.button = [[UIButton alloc]initWithFrame:CGRectMake(10, 70, 50, 20)];
        [self.button setTitle:@"Setup" forState:UIControlStateNormal];
        self.button.backgroundColor = [UIColor blackColor];
        self.button.layer.cornerRadius = 10;
        self.button.layer.masksToBounds = YES;
        [self.view addSubview:self.button];
        [self.button addTarget:self action:@selector(segueToNoUser:) forControlEvents:UIControlEventTouchUpInside];

        self.button = [[UIButton alloc]initWithFrame:CGRectMake(10, 95, 50, 20)];
        [self.button setTitle:@"Email" forState:UIControlStateNormal];
        self.button.backgroundColor = [UIColor blackColor];
        self.button.layer.cornerRadius = 10;
        self.button.layer.masksToBounds = YES;
        [self.view addSubview:self.button];
        [self.button addTarget:self action:@selector(sendEmailForTesting:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [self performSegueWithIdentifier:@"NoUser" sender:self];
    }
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
    self.navigationItem.leftBarButtonItem.image = [UIImage imageWithImage:[UIImage imageNamed:@"filledSettings"] scaledToSize:CGSizeMake(30, 30)];
    [self performSegueWithIdentifier:@"Settings" sender:self];
}
- (IBAction)onMessagesTapped:(UIBarButtonItem *)sender
{
    [SVProgressHUD dismiss];
    self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"chatFilled2"];
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
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor mikeGray]}];
    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];

    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor mikeGray]];
    //self.navigationItem.rightBarButtonItem.title = @"Chats";
    self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"chatEmpty"];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor mikeGray];

    self.navigationItem.leftBarButtonItem.image = [UIImage imageWithImage:[UIImage imageNamed:@"emptySettings"] scaledToSize:CGSizeMake(30, 30)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor mikeGray];
}

-(void)sendEmailForTesting:(UIButton*)sender
{
    [self sendEmailForTesting];
}

-(void)sendEmailForTesting
{
    NSString *emailTitle = @"Feedback";
    NSString *messageBody = @"<h1>Matched User's Name</h1>";
    NSArray *reciepents = [NSArray arrayWithObject:@"michaelsevy@gmail.com"];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc]init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
    [mc setToRecipients:reciepents];

    [self presentViewController:mc animated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
