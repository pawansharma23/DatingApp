//
//  PreviewUserProfileVC.m
//  Pandemos
//
//  Created by Michael Sevy on 2/1/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "PreviewUserProfileVC.h"
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MessagingViewController.h"
#import <MessageUI/MessageUI.h>
#import "UIColor+Pandemos.h"
#import "UIButton+Additions.h"
#import "NSString+Additions.h"
#import "UIImageView+Additions.h"
#import "UIImage+Additions.h"
#import "User.h"
#import "UserManager.h"

@interface PreviewUserProfileVC ()<
UIGestureRecognizerDelegate,
UserManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *image1Indicator;
@property (weak, nonatomic) IBOutlet UIButton *image2Indicator;
@property (weak, nonatomic) IBOutlet UIButton *image3Indicator;
@property (weak, nonatomic) IBOutlet UIButton *image4Indicator;
@property (weak, nonatomic) IBOutlet UIButton *image5Indicator;
@property (weak, nonatomic) IBOutlet UIButton *image6Indicator;

@property (weak, nonatomic) IBOutlet UIView *userInfoView;
@property (weak, nonatomic) IBOutlet UILabel *nameAndAge;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *educationLabel;

@property (weak, nonatomic) IBOutlet UIView *fullDescView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameAndAge;
@property (weak, nonatomic) IBOutlet UILabel *fullAboutMe;
@property (weak, nonatomic) IBOutlet UILabel *fullMilesAway;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeBarButton;

@property (strong, nonatomic) NSString *currentCityAndState;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) User *passedUser;
@property (strong, nonatomic) UserManager *userManager;
@property (strong, nonatomic) NSMutableArray *profileImages;
@property (strong, nonatomic) NSString *nameAndAgeGlobal;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) PFGeoPoint *pfGeoCoded;
@property int count;
@end

@implementation PreviewUserProfileVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.userManager = [UserManager new];
    self.userManager.delegate = self;
    self.currentUser = [User currentUser];
    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
    self.fullDescView.hidden = YES;
    self.profileImages = [NSMutableArray new];

    [self setupManagersProfileVCForCurrentUser];

    self.userInfoView.layer.cornerRadius = 10;

    [self setupButtonsAndViews];

    UIImage *closeNavBarButton = [UIImage imageWithImage:[UIImage imageNamed:@"Close"] scaledToSize:CGSizeMake(25.0, 25.0)];
    [self.navigationItem.leftBarButtonItem setImage:closeNavBarButton];
    self.closeBarButton.tintColor = [UIColor darkGrayColor];
     //to get your location
    //PFGeoPoint *geo = [self.currentUser objectForKey:@"GeoCode"];
//  using age object instead
//    NSString *birthdayStr = [self.currentUser objectForKey:@"birthday"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];

    self.count = 0;

    [self setLightForImage:self.count];

    [self.userImage setUserInteractionEnabled:YES];
    UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(swipeGestureUp:)];
    [swipeGestureUp setDelegate:self];
    swipeGestureUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.userImage addGestureRecognizer:swipeGestureUp];
    //down
    UISwipeGestureRecognizer *swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(swipeGestureDown:)];
    [swipeGestureDown setDelegate:self];
    swipeGestureDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.userImage addGestureRecognizer:swipeGestureDown];
}



//#pragma mark -- CLLocation delegate methods
//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
//{
//
//    //current location .............. Works in iPhone, not in Sim
//    CLLocation *currentLocation = [locations firstObject];
//    NSLog(@"array of cuurent locations: %@", locations);
//    //double latitude = self.locationManager.location.coordinate.latitude;
//    //double longitude = self.locationManager.location.coordinate.longitude;
//
//    [self.locationManager stopUpdatingLocation];
//
//    //get city and location from a CLPlacemark object
//    CLGeocoder *geoCoder = [CLGeocoder new];
//    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"error: %@", error);
//        } else {
//            CLPlacemark *placemark = [placemarks firstObject];
//            NSString *city = placemark.locality;
//            NSDictionary *stateDict = placemark.addressDictionary;
//            NSString *state = stateDict[@"State"];
//            self.currentCityAndState = [NSString stringWithFormat:@"%@, %@", city, state];
//        }
//    }];
//}

#pragma mark -- SWIPE GESTURES
- (IBAction)swipeGestureUp:(UISwipeGestureRecognizer *)sender
{
    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *) sender direction];
    if (direction == UISwipeGestureRecognizerDirectionUp)
    {
        NSLog(@"swipe up");
    
        [UIView transitionWithView:self.userImage duration:0.2 options:UIViewAnimationOptionTransitionCurlUp animations:^{

            self.count++;

            if (self.count < self.profileImages.count - 1)
            {
                self.userImage.image = [UIImage imageWithString:[self.profileImages objectAtIndex:self.count]];

                [self setLightForImage:self.count];

                self.fullDescView.hidden = YES;

            }
            else if (self.count == self.profileImages.count - 1)
            {
                self.userImage.image = [UIImage imageWithString:[self.profileImages objectAtIndex:self.count]];

                NSLog(@"last image, count: %zd", self.count);

                [self setLightForImage:self.count];

                [self lastImageBringUpDesciptionView];
            }
        } completion:^(BOOL finished) {
        }];
    }
}

- (IBAction)swipeGestureDown:(UISwipeGestureRecognizer *)sender
{

    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *) sender direction];
    if (direction == UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"swipe down");

        [UIView transitionWithView:self.userImage duration:0.2 options:UIViewAnimationOptionTransitionCurlDown animations:^{

            self.count--;

            if (self.count == 0)
            {
                NSLog(@"first image, count: %zd", self.count);
                self.userImage.image = [UIImage imageWithString:[self.profileImages objectAtIndex:self.count]];
                //indicator lights
                [self setLightForImage:self.count];
                //re-hide full view on the way back up
                self.fullDescView.hidden = YES;

            }
            else if(self.count > 0)
            {
                self.userImage.image = [UIImage imageWithString:[self.profileImages objectAtIndex:self.count]];

                [self setLightForImage:self.count];

                self.fullDescView.hidden = YES;
            }
        } completion:^(BOOL finished) {
            NSLog(@"animated");
        }];
    }
}

- (IBAction)onCloseButton:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- USER MANAGER DELEGATE
-(void)didReceiveUserImages:(NSArray *)images
{
    self.profileImages = [NSMutableArray arrayWithArray:images];
    self.userImage.image = [UIImage imageWithString:[self.profileImages objectAtIndex:self.count]];
    [self loadIndicatorLights:(int)self.profileImages.count];
    self.image1Indicator.backgroundColor = [UIColor rubyRed];
}

-(void)failedToFetchImages:(NSError *)error
{
    NSLog(@"cannot fetch user profile images: %@", error);
}

-(void)didReceiveUserData:(NSArray *)data
{
    NSDictionary *userData = [data firstObject];
    NSString *bday = userData[@"birthday"];
    self.nameAndAgeGlobal = [NSString stringWithFormat:@"%@, %@", userData[@"givenName"], [bday ageFromBirthday:bday]];
    self.nameAndAge.text = self.nameAndAgeGlobal;
    self.educationLabel.text = userData[@"work"];
    self.jobLabel.text = userData[@"lastSchool"];
    self.navigationItem.title = userData[@"givenName"];
}

-(void)failedToFetchUserData:(NSError *)error
{
    NSLog(@"failed to fetch data: %@", error);
}

#pragma mark -- HELPERS
-(void)setupManagersProfileVCForCurrentUser
{
    [self.userManager loadUserData:self.currentUser];
    [self.userManager loadUserImages:self.currentUser];
}

-(void)setupButtonsAndViews
{
    [UIImageView setupFullSizedImage:self.userImage];
    [UIButton circleButtonEdges:self.image1Indicator];
    [UIButton circleButtonEdges:self.image2Indicator];
    [UIButton circleButtonEdges:self.image3Indicator];
    [UIButton circleButtonEdges:self.image4Indicator];
    [UIButton circleButtonEdges:self.image5Indicator];
    [UIButton circleButtonEdges:self.image6Indicator];
}

-(void)loadIndicatorLights:(int)profileImageCount
{
    switch (profileImageCount)
    {
        case 0:
            self.image6Indicator.hidden = YES;
            self.image5Indicator.hidden = YES;
            self.image4Indicator.hidden = YES;
            self.image3Indicator.hidden = YES;
            self.image2Indicator.hidden = YES;
            self.image1Indicator.hidden = YES;
            break;
        case 1:
            [UIButton circleButtonEdges:self.image1Indicator];
            self.image6Indicator.hidden = YES;
            self.image5Indicator.hidden = YES;
            self.image4Indicator.hidden = YES;
            self.image3Indicator.hidden = YES;
            self.image2Indicator.hidden = YES;
            self.image1Indicator.hidden = NO;
            break;
        case 2:
            [UIButton circleButtonEdges:self.image1Indicator];
            [UIButton circleButtonEdges:self.image2Indicator];
            self.image6Indicator.hidden = YES;
            self.image5Indicator.hidden = YES;
            self.image4Indicator.hidden = YES;
            self.image3Indicator.hidden = YES;
            self.image2Indicator.hidden = NO;
            self.image1Indicator.hidden = NO;
            break;
        case 3:
            [UIButton circleButtonEdges:self.image1Indicator];
            [UIButton circleButtonEdges:self.image2Indicator];
            [UIButton circleButtonEdges:self.image3Indicator];
            self.image6Indicator.hidden = YES;
            self.image5Indicator.hidden = YES;
            self.image4Indicator.hidden = YES;
            self.image3Indicator.hidden = NO;
            self.image2Indicator.hidden = NO;
            self.image1Indicator.hidden = NO;
            break;
        case 4:
            [UIButton circleButtonEdges:self.image1Indicator];
            [UIButton circleButtonEdges:self.image2Indicator];
            [UIButton circleButtonEdges:self.image3Indicator];
            [UIButton circleButtonEdges:self.image4Indicator];
            self.image6Indicator.hidden = YES;
            self.image5Indicator.hidden = YES;
            self.image4Indicator.hidden = NO;
            self.image3Indicator.hidden = NO;
            self.image2Indicator.hidden = NO;
            self.image1Indicator.hidden = NO;
            break;
        case 5:
            [UIButton circleButtonEdges:self.image1Indicator];
            [UIButton circleButtonEdges:self.image2Indicator];
            [UIButton circleButtonEdges:self.image3Indicator];
            [UIButton circleButtonEdges:self.image4Indicator];
            [UIButton circleButtonEdges:self.image5Indicator];
            self.image6Indicator.hidden = YES;
            self.image5Indicator.hidden = NO;
            self.image4Indicator.hidden = NO;
            self.image3Indicator.hidden = NO;
            self.image2Indicator.hidden = NO;
            self.image1Indicator.hidden = NO;
            break;
        case 6:
            [UIButton circleButtonEdges:self.image1Indicator];
            [UIButton circleButtonEdges:self.image2Indicator];
            [UIButton circleButtonEdges:self.image3Indicator];
            [UIButton circleButtonEdges:self.image4Indicator];
            [UIButton circleButtonEdges:self.image5Indicator];
            [UIButton circleButtonEdges:self.image6Indicator];
            self.image6Indicator.hidden = NO;
            self.image5Indicator.hidden = NO;
            self.image4Indicator.hidden = NO;
            self.image3Indicator.hidden = NO;
            self.image2Indicator.hidden = NO;
            self.image1Indicator.hidden = NO;
            break;
        default:
            NSLog(@"indicator light error");
            break;
    }
}

-(void)setLightForImage:(long)count
{
    switch (count)
    {
        case 0:
            self.image1Indicator.backgroundColor = [UIColor rubyRed];
            self.image2Indicator.backgroundColor = nil;
            self.image3Indicator.backgroundColor = nil;
            self.image4Indicator.backgroundColor = nil;
            self.image5Indicator.backgroundColor = nil;
            self.image6Indicator.backgroundColor = nil;
            break;
        case 1:
            self.image1Indicator.backgroundColor = nil;
            self.image2Indicator.backgroundColor = [UIColor rubyRed];
            self.image3Indicator.backgroundColor = nil;
            self.image4Indicator.backgroundColor = nil;
            self.image5Indicator.backgroundColor = nil;
            self.image6Indicator.backgroundColor = nil;
            break;
        case 2:
            self.image1Indicator.backgroundColor = nil;
            self.image2Indicator.backgroundColor = nil;
            self.image3Indicator.backgroundColor = [UIColor rubyRed];
            self.image4Indicator.backgroundColor = nil;
            self.image5Indicator.backgroundColor = nil;
            self.image6Indicator.backgroundColor = nil;
            break;
        case 3:
            self.image1Indicator.backgroundColor = nil;
            self.image2Indicator.backgroundColor = nil;
            self.image3Indicator.backgroundColor = nil;
            self.image4Indicator.backgroundColor = [UIColor rubyRed];
            self.image5Indicator.backgroundColor = nil;
            self.image6Indicator.backgroundColor = nil;
            break;
        case 4:
            self.image1Indicator.backgroundColor = nil;
            self.image2Indicator.backgroundColor = nil;
            self.image3Indicator.backgroundColor = nil;
            self.image4Indicator.backgroundColor = nil;
            self.image5Indicator.backgroundColor = [UIColor rubyRed];
            self.image6Indicator.backgroundColor = nil;
            break;
        case 5:
            self.image1Indicator.backgroundColor = nil;
            self.image2Indicator.backgroundColor = nil;
            self.image3Indicator.backgroundColor = nil;
            self.image4Indicator.backgroundColor = nil;
            self.image5Indicator.backgroundColor = nil;
            self.image6Indicator.backgroundColor = [UIColor rubyRed];
            break;
        default:
            NSLog(@"image beyond bounds");
            break;
    }
}

-(void)lastImageBringUpDesciptionView
{
    self.fullDescView.hidden = NO;
    self.fullDescView.layer.cornerRadius = 10;
    NSString *aboutMe = [self.currentUser objectForKey:@"aboutMe"];
    self.fullAboutMe.text = aboutMe;
    self.fullNameAndAge.text = self.nameAndAgeGlobal;
    self.fullMilesAway.text = self.currentCityAndState;
}
@end