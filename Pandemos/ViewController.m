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
#import <Parse/Parse.h>
#import "UserData.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>


@interface ViewController ()<FBSDKGraphRequestConnectionDelegate,
UIGestureRecognizerDelegate,
UINavigationControllerDelegate,
CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *greenButton;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UILabel *nameAndAge;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *educationLabel;


@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSString *leadImage;
@property (strong, nonatomic) NSData *leadImageData;
@property (strong, nonatomic) NSMutableArray *imageArray;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLGeocoder *geoCoded;



//Matching Engine Identifiers
@property (strong, nonatomic) NSString *userSexPref;
@property (strong, nonatomic) NSString *minAge;
@property (strong, nonatomic) NSString *maxAge;
@property (strong, nonatomic) NSString *milesFromUserLocation;
@property (strong, nonatomic) PFGeoPoint *pfGeoCoded;







@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.imageArray = [NSMutableArray new];
    self.navigationItem.title = @"Lhfmf";
//    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:91.0/255.0 blue:255.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:71.0/255.0 blue:255.0/255.0 alpha:1.0];
 // picture instead of Title   self.navigationItem.titleView = [UIImage imageNamed:imagename];
















    //for display just as a placeholder until matching engine works
//    NSString *firstNameOfUserUsing = [self.currentUser objectForKey:@"firstName"];
//    NSString *job = [self.currentUser objectForKey:@"work"];
//    NSString *school = [self.currentUser objectForKey:@"scool"];
//    NSString *bday = [self.currentUser objectForKey:@"birthday"];
//    self.nameAndAge.text = [NSString stringWithFormat:@"%@, %@",firstNameOfUserUsing, [self ageString:bday]];
//    self.jobLabel.text = job;
//    self.educationLabel.text = school;
//






    //other view elements setup
    self.greenButton.transform = CGAffineTransformMakeRotation(M_PI / 180 * 10);
    self.redButton.transform = CGAffineTransformMakeRotation(M_PI / 180 * -10);
    self.userImage.layer.cornerRadius = 5;

    //swipe gestures
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
    NSLog(@"did update locations ");
//    CLLocation *currentLocation = [locations firstObject];
//
//    NSLog(@"array of cuurent locations: %@", locations);
//    double latitude = self.locationManager.location.coordinate.latitude;
//    double longitude = self.locationManager.location.coordinate.longitude;
//
//    NSLog(@"lat: %f", latitude);
//    NSLog(@"long: %f", longitude);
    [self.locationManager stopUpdatingLocation];
//    NSString *latitudeStr = [NSString stringWithFormat:@"%f", latitude];
//    NSString *longStr = [NSString stringWithFormat:@"%f", longitude];
//
//    //save location in latitude and longitude
//    [self.currentUser setObject:latitudeStr forKey:@"latitude"];
//    [self.currentUser setObject:longStr forKey:@"longitude"];
//    [self.currentUser saveInBackground];
//
//    CLGeocoder *geoCoder = [CLGeocoder new];
//    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"error: %@", error);
//        } else {
//            CLPlacemark *placemark = [placemarks firstObject];
//            NSLog(@"placemark city: %@", placemark.locality);
//        }
//    }];



}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"location manager failed: %@", error);
}

-(void)viewDidAppear:(BOOL)animated{

    if (!self.currentUser) {
        
        //[self performSegueWithIdentifier:@"NoUser" sender:nil];
    } else {
        self.currentUser = [PFUser currentUser];
        NSLog(@"current user: %@", self.currentUser);

        //for matching: SexPref min and max age user is intersted in and Location of user/miles around user
        NSString *sexPref = [self.currentUser objectForKey:@"sexPref"];


        self.userSexPref = sexPref;
        self.minAge = [self.currentUser objectForKey:@"minAge"];
        self.maxAge = [self.currentUser objectForKey:@"maxAge"];
        self.milesFromUserLocation = [self.currentUser objectForKey:@"milesAway"];



        //update users age everytime they signin and re-save that age in Parse for matching purpposes
        NSString *userBirthday = [self.currentUser objectForKey:@"birthday"];
        NSString *age = [self ageString:userBirthday];
        [self.currentUser setObject:age forKey:@"userAge"];

        NSLog(@"user Sex Pref: %@\nuser min age Pref: %@\nmax Age: %@\ndistance away:%@\nAge: %@", self.userSexPref, self.minAge, self.maxAge, self.milesFromUserLocation, age);






    //location object
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;

    //request permission and update locaiton
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;

    double latitude = self.locationManager.location.coordinate.latitude;
    double longitude = self.locationManager.location.coordinate.longitude;
    NSLog(@"view did load lat: %f & long: %f", latitude, longitude);

    //save lat and long in a PFGeoCode Object and save to User in Parse
    self.pfGeoCoded = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
    [self.currentUser setObject:self.pfGeoCoded forKey:@"GeoCode"];
    [self.currentUser saveInBackground];
    //PFGeoPoint *geocodeParse = [self.currentUser objectForKey:@"GeoCode"];
    NSLog(@"PFGeoCode: %@", self.pfGeoCoded);






    //image download and conversion
    NSString * imagesStr1 = [self.currentUser objectForKey:@"image1"];
    //    NSString * imagesStr2 = [self.currentUser objectForKey:@"image2"];
    //    NSString * imagesStr3 = [self.currentUser objectForKey:@"image3"];
    //    NSString * imagesStr4 = [self.currentUser objectForKey:@"image4"];
    //    NSString * imagesStr5 = [self.currentUser objectForKey:@"image5"];
    //    NSString * imagesStr6 = [self.currentUser objectForKey:@"image6"];

    //image display
    NSURL *imageURL = [NSURL URLWithString:imagesStr1];
    NSData *dataOb = [NSData dataWithContentsOfURL:imageURL];
    self.userImage.image = [UIImage imageWithData:dataOb];
    //    [self.imageArray addObject:imagesStr1];
    //
    //    if (imagesStr2) {
    //        [self.imageArray addObject:imagesStr2];
    //    }if (imagesStr3) {
    //        [self.imageArray addObject:imagesStr3];
    //    } if (imagesStr4) {
    //        [self.imageArray addObject:imagesStr4];
    //    } if (imagesStr5) {
    //        [self.imageArray addObject:imagesStr5];
    //    } if (imagesStr6) {
    //        [self.imageArray addObject:imagesStr6];
    //    }
    //    NSLog(@"local image array: %@", self.imageArray);
    





















    PFQuery *query = [PFUser query];
    //check to only add users that meet criterion of above current user
    if ([self.userSexPref containsString:@"male female"]) {

        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){
            NSLog(@"pfquery-- user objects: %zd", [objects count]);
        }
  }];

        } else if ([self.userSexPref isEqualToString:@"male"]){

            [query whereKey:@"gender" hasPrefix:@"m"];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"m query return: %zd", [objects count]);
                }
            }];

            } else{
                [query whereKey:@"gender" hasPrefix:@"f"];
                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    if (!error) {
                        NSLog(@"f query return: %zd", [objects count]);
                    }
                }];
            }




    }
}

- (IBAction)swipeGestureUp:(UISwipeGestureRecognizer *)sender {

    if (sender.direction == UISwipeGestureRecognizerDirectionUp){
        NSLog(@"up swipe");
        //int listOfImages = (self.imageArray < 0) ? ([self.imageArray count] -1):listOfImages % [self.imageArray count];
        //self.userImage.image = [UIImage imageWithData:[self.imageArray objectAtIndex:listOfImages]];

    } else{
        NSLog(@"no swipe?");
    }
//    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *) sender direction];
//    switch (direction) {
//        case UISwipeGestureRecognizerDirectionUp:
//            NSLog(@"next image");
////            listOfImages++;
//            break;
//        case UISwipeGestureRecognizerDirectionDown:
//  //          listOfImages--;
//            NSLog(@"last image or top");
//            break;
//        default:
//            break;
//    }
//    listOfImages = (listOfImages < 0) ? ([images count] -1):listOfImages % [images count];
//    imageView.image = [UIImage imageNamed:[images objectAtIndex:listOfImages]];

    //action on swipe up
   // NSLog(@"swiped Up");


}


- (IBAction)swipeGestureDown:(UISwipeGestureRecognizer *)sender {

    if (sender.direction == UISwipeGestureRecognizerDirectionDown){
        NSLog(@"down swipe");
    } else{
        NSLog(@"no swipe?");
    }
}

- (IBAction)onYesButton:(UIButton *)sender {
}




- (IBAction)onXButton:(UIButton *)sender {
}

#pragma mark -- helpers
-(NSString *)ageString:(NSString *)bDayString   {

    NSString *bday = bDayString;
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MM/DD/YYY"];

    NSDate *birthdayDate = [formatter dateFromString:bday];
    NSDate *nowDate = [NSDate date];
    [formatter stringFromDate:nowDate];
    NSString *nowString = [NSString stringWithFormat:@"%@", nowDate];
    NSLog(@"current date string: %@", nowString);
    NSDateComponents *ageCom = [[NSCalendar currentCalendar]components:NSCalendarUnitYear fromDate:birthdayDate toDate:nowDate options:0];
    NSInteger ageInt = [ageCom year];
    NSString *ageString = [NSString stringWithFormat:@"%zd", ageInt];
    return ageString;
}


//old code

//name and age, location off birthday object
//[query whereKey:bday greaterThan:<#(nonnull id)#>]
//    [query whereKey:@"location" nearGeoPoint:PFGEOPoint object withinMiles:milesAwayObject];
//    PFQuery *queryClass = [PFQuery queryWithClassName:@"User"];



//            NSString *age1 = [[objects objectAtIndex:0]objectForKey:@"birthday"];
//            NSString *age2 = [[objects objectAtIndex:1]objectForKey:@"birthday"];
//            NSLog(@"age:%@", [self ageString:age]);
//            NSLog(@"age:%@", [self ageString:age2]);

//
//            NSString *latitude = [[objects firstObject]objectForKey:@"latitude"];
//            NSString *longitude = [[objects firstObject]objectForKey:@"longitude"];
//            double lat = [latitude doubleValue];
//            double longDouble = [longitude doubleValue];
//            for (PFUser *userKeys in objects) {
//                NSLog(@"user: %@", userKeys.objectId);
//                NSLog(@"sexPref: %@", userKeys.sexPref);
//            }
@end








