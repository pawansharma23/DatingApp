//
//  PreviewUserProfileVC.m
//  Pandemos
//
//  Created by Michael Sevy on 2/1/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "PreviewUserProfileVC.h"
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
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MessagingViewController.h"
#import <MessageUI/MessageUI.h>

@interface PreviewUserProfileVC ()<UIGestureRecognizerDelegate>

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
@property (strong, nonatomic) NSString *currentCityAndState;

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSString *leadImage;
@property (strong, nonatomic) NSData *leadImageData;
@property (strong, nonatomic) NSMutableArray *imageArray;
@property long imageArrayCount;
@property (strong, nonatomic) NSString *nameAndAgeGlobal;
@property (strong, nonatomic) NSDate *birthday;
//location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) PFGeoPoint *pfGeoCoded;

@property long count;
@end

@implementation PreviewUserProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];

    self.navigationItem.title = @"Your Profile";
    self.navigationController.navigationBar.barTintColor = [UserData yellowGreen];

    self.imageArray = [NSMutableArray new];
    //load user Images
    [self checkAndGetYourImages];
    //load proper # of indicator lights
    [self loadProperIndicatorLights:(int)self.imageArrayCount];
    self.fullDescView.hidden = YES;

    //get user info
    self.userInfoView.layer.cornerRadius = 10;
    NSString *firstName = [self.currentUser objectForKey:@"firstName"];
    NSString *age = [self.currentUser objectForKey:@"userAge"];
    self.nameAndAgeGlobal = [NSString stringWithFormat:@"%@, %@", firstName, age];
    self.nameAndAge.text = self.nameAndAgeGlobal;

    self.educationLabel.text = [self.currentUser objectForKey:@"work"];
    self.jobLabel.text = [self.currentUser objectForKey:@"scool"];
    //Your images
    self.count = 0;
    //indicator buttons
    [self currentImage:self.count];
    [self setUpButtons:self.image1Indicator];
    [self setUpButtons:self.image2Indicator];
    [self setUpButtons:self.image3Indicator];
    [self setUpButtons:self.image4Indicator];
    [self setUpButtons:self.image5Indicator];
    [self setUpButtons:self.image6Indicator];

    //to get your location
    //PFGeoPoint *geo = [self.currentUser objectForKey:@"GeoCode"];
//  using age object instead
//    NSString *birthdayStr = [self.currentUser objectForKey:@"birthday"];

    //swipe gestures-- up
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

#pragma mark -- CLLocation delegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations   {

    //current location .............. Works in iPhone, not in Sim
    CLLocation *currentLocation = [locations firstObject];
    NSLog(@"array of cuurent locations: %@", locations);
    //double latitude = self.locationManager.location.coordinate.latitude;
    //double longitude = self.locationManager.location.coordinate.longitude;

    [self.locationManager stopUpdatingLocation];

    //get city and location from a CLPlacemark object
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            CLPlacemark *placemark = [placemarks firstObject];
            NSString *city = placemark.locality;
            NSDictionary *stateDict = placemark.addressDictionary;
            NSString *state = stateDict[@"State"];
            self.currentCityAndState = [NSString stringWithFormat:@"%@, %@", city, state];
        }
    }];
}

#pragma mark -- Swipe Gestures
//SwipeUp
- (IBAction)swipeGestureUp:(UISwipeGestureRecognizer *)sender {

    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *) sender direction];
    if (direction == UISwipeGestureRecognizerDirectionUp) {
        NSLog(@"swipe up");
        //add animation
        [UIView transitionWithView:self.userImage duration:0.2 options:UIViewAnimationOptionTransitionCurlUp animations:^{

            self.count++;

            if (self.count < self.imageArray.count - 1) {
                //display image
                self.userImage.image = [UIImage imageWithData:[self imageData:[self.imageArray objectAtIndex:self.count]]];
                //indicator light to reflect image we are on
                [self currentImage:self.count];
                self.fullDescView.hidden = YES;
                NSLog(@"count: %zd", self.count);

            } else if (self.count == self.imageArray.count - 1) {

                //self.fullDescView.hidden = YES;
                self.userImage.image = [UIImage imageWithData:[self imageData:[self.imageArray objectAtIndex:self.count]]];
                NSLog(@"last image, count: %zd", self.count);
                [self currentImage:self.count];
                [self lastImageBringUpDesciptionView];
            }
        } completion:^(BOOL finished) {
        }];
    }
}

//SwipeDown
- (IBAction)swipeGestureDown:(UISwipeGestureRecognizer *)sender {

    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *) sender direction];
    if (direction == UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"swipe down");

        [UIView transitionWithView:self.userImage duration:0.2 options:UIViewAnimationOptionTransitionCurlDown animations:^{

            self.count--;

            if (self.count == 0) {

                NSLog(@"first image, count: %zd", self.count);
                self.userImage.image = [UIImage imageWithData:[self imageData:[self.imageArray objectAtIndex:self.count]]];
                //indicator lights
                [self currentImage:self.count];
                //re-hide full view on the way back up
                self.fullDescView.hidden = YES;

            } else if(self.count > 0){

                self.userImage.image = [UIImage imageWithData:[self imageData:[self.imageArray objectAtIndex:self.count]]];
                //indicator lights
                [self currentImage:self.count];
                NSLog(@"count: %zd", self.count);
                self.fullDescView.hidden = YES;
                
            }
        } completion:^(BOOL finished) {
            NSLog(@"animated");
        }];
    }
}

#pragma mark -- helper methods
-(void)checkAndGetYourImages {

    NSString *image1 = [self.currentUser objectForKey:@"image1"];
    NSString *image2 = [self.currentUser objectForKey:@"image2"];
    NSString *image3 = [self.currentUser objectForKey:@"image3"];
    NSString *image4 = [self.currentUser objectForKey:@"image4"];
    NSString *image5 = [self.currentUser objectForKey:@"image5"];
    NSString *image6 = [self.currentUser objectForKey:@"image6"];

    if (image1) {
        [self.imageArray addObject:image1];
        self.userImage.image = [UIImage imageWithData:[self imageData:image1]];
    }if (image2) {
        [self.imageArray addObject:image2];
    } if (image3) {
        [self.imageArray addObject:image3];
    } if (image4) {
        [self.imageArray addObject:image4];
    } if (image5) {
        [self.imageArray addObject:image5];
    } if (image6) {
        [self.imageArray addObject:image6];
    }
    self.imageArrayCount = [self.imageArray count];
    NSLog(@"%zd images in array", self.imageArrayCount);
}

-(void)loadProperIndicatorLights:(int) count{
    switch (count) {
        case 0:
            NSLog(@"error: No images loading");
            break;
        case 1:
            self.image2Indicator.hidden = YES;
            self.image3Indicator.hidden = YES;
            self.image4Indicator.hidden = YES;
            self.image5Indicator.hidden = YES;
            self.image6Indicator.hidden = YES;
            break;
        case 2:
            self.image3Indicator.hidden = YES;
            self.image4Indicator.hidden = YES;
            self.image5Indicator.hidden = YES;
            self.image6Indicator.hidden = YES;
            break;
        case 3:
            self.image4Indicator.hidden = YES;
            self.image5Indicator.hidden = YES;
            self.image6Indicator.hidden = YES;
            break;
        case 4:
            self.image5Indicator.hidden = YES;
            self.image6Indicator.hidden = YES;
            break;
        case 5:
            self.image6Indicator.hidden = YES;
            break;
        default:
            break;
    }
}

- (NSInteger)ageFromBirthday:(NSDate *)birthdate {

    NSDate *today = [NSDate date];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:birthdate toDate:today options:0];
    return ageComponents.year;
}

-(NSDate *)stringToNSDate:(NSString *)dateAsAString{

    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MM/dd/yyyy"];

    return [formatter dateFromString:dateAsAString];
}


-(NSData *)imageData:(NSString *)imageString{
    NSURL *url = [NSURL URLWithString:imageString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}

-(void)currentImage:(long)count{
    switch (count) {
        case 0:
            self.image1Indicator.backgroundColor = [UserData rubyRed];
            self.image2Indicator.backgroundColor = nil;
            self.image3Indicator.backgroundColor = nil;
            self.image4Indicator.backgroundColor = nil;
            self.image5Indicator.backgroundColor = nil;
            self.image6Indicator.backgroundColor = nil;
            break;
        case 1:
            self.image1Indicator.backgroundColor = nil;
            self.image2Indicator.backgroundColor = [UserData rubyRed];
            self.image3Indicator.backgroundColor = nil;
            self.image4Indicator.backgroundColor = nil;
            self.image5Indicator.backgroundColor = nil;
            self.image6Indicator.backgroundColor = nil;
            break;
        case 2:
            self.image1Indicator.backgroundColor = nil;
            self.image2Indicator.backgroundColor = nil;
            self.image3Indicator.backgroundColor = [UserData rubyRed];
            self.image4Indicator.backgroundColor = nil;
            self.image5Indicator.backgroundColor = nil;
            self.image6Indicator.backgroundColor = nil;
            break;
        case 3:
            self.image1Indicator.backgroundColor = nil;
            self.image2Indicator.backgroundColor = nil;
            self.image3Indicator.backgroundColor = nil;
            self.image4Indicator.backgroundColor = [UserData rubyRed];
            self.image5Indicator.backgroundColor = nil;
            self.image6Indicator.backgroundColor = nil;
            break;
        case 4:
            self.image1Indicator.backgroundColor = nil;
            self.image2Indicator.backgroundColor = nil;
            self.image3Indicator.backgroundColor = nil;
            self.image4Indicator.backgroundColor = nil;
            self.image5Indicator.backgroundColor = [UserData rubyRed];
            self.image6Indicator.backgroundColor = nil;
            break;
        case 5:
            self.image1Indicator.backgroundColor = nil;
            self.image2Indicator.backgroundColor = nil;
            self.image3Indicator.backgroundColor = nil;
            self.image4Indicator.backgroundColor = nil;
            self.image5Indicator.backgroundColor = nil;
            self.image6Indicator.backgroundColor = [UserData rubyRed];
            break;
        default:
            NSLog(@"image beyond bounds");
            break;
    }
}

-(void)lastImageBringUpDesciptionView{

    self.fullDescView.hidden = NO;
    self.fullDescView.layer.cornerRadius = 10;
    NSString *aboutMe = [self.currentUser objectForKey:@"aboutMe"];
    self.fullAboutMe.text = aboutMe;
    self.fullNameAndAge.text = self.nameAndAgeGlobal;
    self.fullMilesAway.text = self.currentCityAndState;

}
//round corners, change button colors
-(void)setUpButtons:(UIButton *)button{
    button.layer.cornerRadius = 15.0 / 2.0f;
    button.clipsToBounds = YES;
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[UserData uclaBlue].CGColor];
    
}



@end

//add animation
//[UIView transitionWithView:self.userImage duration:0.2 options:UIViewAnimationOptionTransitionCurlUp animations:^{
//    if (self.count == self.imageArray.count - 1) {
//
//        self.userImage.image = [UIImage imageWithData:[self imageData:[self.imageArray objectAtIndex:self.count]]];
//        NSLog(@"last image");
//        [self currentImage:self.count];
//        //NSLog(@"count: %zd", self.count);
//        [self lastImageBringUpDesciptionView];
//
//    } else {
//
//        self.count++;
//        self.userImage.image = [UIImage imageWithData:[self imageData:[self.imageArray objectAtIndex:self.count]]];
//        [self currentImage:self.count];
//        //NSLog(@"count: %zd", self.count);
//
//        self.fullDescView.hidden = YES;
//    }
//} completion:^(BOOL finished) {
//}];




