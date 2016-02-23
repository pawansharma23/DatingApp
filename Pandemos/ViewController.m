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
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MessagingViewController.h"
#import <MessageUI/MessageUI.h>
#import "PotentialMatch.h"
#import "UIColor+Pandemos.h"

@interface ViewController ()<FBSDKGraphRequestConnectionDelegate,
UIGestureRecognizerDelegate,
UINavigationControllerDelegate,
CLLocationManagerDelegate,
MFMailComposeViewControllerDelegate>
//View elemets
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIImageView *matchedImage;
@property (weak, nonatomic) IBOutlet UIImageView *userImageMatched;

@property (weak, nonatomic) IBOutlet UIButton *image1Indicator;
@property (weak, nonatomic) IBOutlet UIButton *image2Indicator;
@property (weak, nonatomic) IBOutlet UIButton *image3Indicator;
@property (weak, nonatomic) IBOutlet UIButton *image4Indicator;
@property (weak, nonatomic) IBOutlet UIButton *image5Indicator;
@property (weak, nonatomic) IBOutlet UIButton *image6Indicator;
@property (weak, nonatomic) IBOutlet UIButton *greenButton;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *keepPlayingButton;

@property (weak, nonatomic) IBOutlet UIView *userInfoView;
@property (weak, nonatomic) IBOutlet UIView *fullDescView;
@property (weak, nonatomic) IBOutlet UIView *matchView;
@property (weak, nonatomic) IBOutlet UIView *activityView;

@property (weak, nonatomic) IBOutlet UILabel *nameAndAge;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *educationLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullDescNameAndAge;
@property (weak, nonatomic) IBOutlet UILabel *fullAboutMe;
@property (weak, nonatomic) IBOutlet UILabel *fullMilesAway;
@property (weak, nonatomic) IBOutlet UILabel *matchedLabel;

@property (strong, nonatomic) PFUser *currentUser;

@property (strong, nonatomic) NSMutableArray *imageArray;
@property long imageArrayCount;
@property (strong, nonatomic) NSString *nameAndAgeGlobal;
@property (strong, nonatomic) NSDate *birthday;

//location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLGeocoder *geoCoded;
@property (strong, nonatomic) PFGeoPoint *pfGeoCoded;
@property (strong, nonatomic) NSString *currentCityAndState;

//Matching Engine Identifiers
@property (strong, nonatomic) NSString *userImageForMatching;
@property int milesFromUserLocation;
@property long count;

//passed Objects array to the stack of users
@property (strong, nonatomic) NSArray *objectsArray;
@property long matchedUsersCount;


@end

@implementation ViewController
#pragma mark-- View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];
    UserData *userA = [UserData new];
    [userA loadUserDataFromParse:self.currentUser];

    self.navigationItem.title = APP_TITLE;
    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
    [self.navigationItem.rightBarButtonItem setTitle:@"Messages"];

    self.fullDescView.hidden = YES;
    self.matchView.hidden = YES;

    self.count = 0;
    self.matchedUsersCount = 0;
    self.imageArray = [NSMutableArray new];

    //location object.......... works on iPhone, not in sim...........
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    //request permission and update locaiton
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    CLLocation *currentlocal = [self.locationManager location];
    self.currentLocation = currentlocal;
    NSLog(@"location: lat: %f & long: %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    //save lat and long in a PFGeoCode Object and save to User in Parse
    //self.pfGeoCoded = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
    //[self.currentUser setObject:self.pfGeoCoded forKey:@"GeoCode"];
    //NSLog(@"saved PFGeoPoint as: %@", self.pfGeoCoded);

    //other view elements setup
    [self setUpButtons:self.image1Indicator];
    [self setUpButtons:self.image2Indicator];
    [self setUpButtons:self.image3Indicator];
    [self setUpButtons:self.image4Indicator];
    [self setUpButtons:self.image5Indicator];
    [self setUpButtons:self.image6Indicator];

    [userA setUpButtons:self.keepPlayingButton];
    [userA setUpButtons:self.messageButton];

    [self currentImageLightUpIndicatorLight:self.count];

    self.greenButton.transform = CGAffineTransformMakeRotation(M_PI / 180 * 10);
    self.redButton.transform = CGAffineTransformMakeRotation(M_PI / 180 * -10);
    self.greenButton.layer.cornerRadius = 20;
    self.redButton.layer.cornerRadius = 20;
    //main image round edges
    self.userImage.layer.cornerRadius = 8;
    self.userImage.clipsToBounds = YES;

    [self.view insertSubview:self.userInfoView aboveSubview:self.userImage];
    self.userInfoView.layer.cornerRadius = 10;

    //matched View Setup
    [self matchViewSetUp:self.userImageMatched andMatchImage:self.matchedImage];

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
    //right
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(onSwipeRight:)];
    [swipeRight setDelegate:self];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.userImage addGestureRecognizer:swipeRight];
    //left
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(onSwipeLeft:)];
    [swipeLeft setDelegate:self];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.userImage addGestureRecognizer:swipeLeft];
}




#pragma mark -- View Did Appear
-(void)viewDidAppear:(BOOL)animated
{

    //NSLog(@"current user view did appear %@", self.currentUser);
    if (!self.currentUser)
    {
        NSLog(@"no user currently logged in");
        //[self performSegueWithIdentifier:@"NoUser" sender:nil];
    } else
    {
        UserData *userA = [UserData new];
        [userA loadUserDataFromParse:self.currentUser];
        NSLog(@"current user name: %@", userA.fullName);
        NSLog(@"age: %@", [userA ageFromBirthday:userA.birthday]);

        //relation
        //PFRelation *rela = [self.currentUser objectForKey:@"matchNotConfirmed"];

        //save age and location objects
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                NSLog(@"error saving current User data: %@", error.description);
            } else{
                NSLog(@"succeeded saving user updated age and geoCode: %s", succeeded ? "true" : "false");
            }
        }];





        //Matching Engine
        PFQuery *query = [PFUser query];
        //turn the relation into a PFQuery and then use whereKeyDoesNotExist XXXXXX
//        PFRelation *relationSHipper = [self.currentUser objectForKey:@"matchNotConfirmed"];
//        PFQuery *relaQuery = [relationSHipper query];
//        [relaQuery whereKeyDoesNotExist:@"matchNotConfirmed"];

// this is what is being saved when user swipes right or left
//        PFUser *currentMatchUser =  [self.objectsArray objectAtIndex:self.matchedUsersCount];
//        PFRelation *matchWithoutConfirm = [self.currentUser relationForKey:@"matchNotConfirmed"];
//        [matchWithoutConfirm addObject:currentMatchUser];
//query for
//        PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
//        [query whereKey:@"recipientId" equalTo:self.currentUser];
//        [query whereKey:@"recipientId" equalTo:self.recipient];
    //    [query whereKey:@"matchNotConfirmed" containsString:@"User"];

        //this is if there is a relationship, I want !relationship???
        PFRelation *relation = [self.currentUser relationForKey:@"matchNotConfirmed"];
        query = [relation query];
        //gets Error code Unsupported query operator on relation field

        //Both sexes
        if ([userA.sexPref containsString:@"male female"]) {
        //Preference for Both Sexes
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){
            NSLog(@"pfquery-- user objects: %zd", [objects count]);
            self.objectsArray = objects;

//            [self checkAndGetImages:objects user:0];
//            [self checkAndGetUserData:objects user:0];
        } else{
            NSLog(@"error: %@", error);
        }
  }];


        //Preference for Males
        } else if ([userA.sexPref isEqualToString:@"male"]){
            //set up query constraints
            [query whereKey:@"gender" hasPrefix:@"m"];
            //[query whereKey:@"ageMin" greaterThanOrEqualTo:userA.minAge];
            //[query whereKey:@"ageMax" lessThanOrEqualTo:userA.maxAge];
            //NSLog(@"Male Pref Between: %@ and %@", self.minAge, self.maxAge);
            //[query whereKey:@"GeoCode" nearGeoPoint:self.pfGeoCoded withinMiles:self.milesFromUserLocation];

            //run query
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (!error) {
                    long objectCount = [objects count];
                    NSLog(@"male pref query: %zd results", objectCount);
                    self.objectsArray = objects;

                    if (objectCount == 1) {

//                        [self checkAndGetImages:objects user:0];
//                        [self checkAndGetUserData:objects user:0];
                    } else if (objectCount == 2){
//
//                        [self checkAndGetImages:objects user:0];
//                        [self checkAndGetUserData:objects user:0];

                        //for looging purposes only
                        PFUser *user1 =  [objects objectAtIndex:0];
                        PFUser *user2 =  [objects objectAtIndex:1];
                        NSLog(@"matches: %@\n%@\n", [user1  objectForKey:@"fullName"], [user2 objectForKey:@"fullName"]);

                    } else if (objectCount == 3)
                    {
//                        [self checkAndGetImages:objects user:0];
//                        [self checkAndGetUserData:objects user:0];

                        //for looging purposes only
                        PFUser *user1 =  [objects objectAtIndex:0];
                        PFUser *user2 =  [objects objectAtIndex:1];
                        PFUser *user3 =  [objects objectAtIndex:2];
                        NSLog(@"matches: %@\n%@\n%@", [user1  objectForKey:@"fullName"], [user2 objectForKey:@"fullName"], [user3 objectForKey:@"fullName"]);
                    }
                }
                else
                {
                    NSLog(@"error: %@", error);
                }
            }];



            //Preference for Females
            } else{
                [query whereKey:@"gender" hasPrefix:@"f"];
                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
                {
                    if (!error)
                    {

                        long objectCount = [objects count];
                        NSLog(@"female pref query: %lu results", objectCount);

                        //NSLog(@"objects: %@", objects);
                        self.objectsArray = objects;
                        switch (objectCount)
                        {
                            case 0:
                                NSLog(@"nothing here");
                                break;
                            case 1:
                            {
                                //[self checkAndGetImages:objects user:0];
                                //[self checkAndGetUserData:objects user:0];
                                //login purpose only
                                PFUser *user1 =  [objects objectAtIndex:0];
                                NSLog(@"1 match: %@", [user1 objectForKey:@"fullName"]);
                                //get image count for indicator lights
                                [self loadIndicatorLights:objects andUser:0];
                            }
                                break;
                            case 2:
                            {
                                PotentialMatch *potMatch = [PotentialMatch new];
                                [potMatch loadPotentialMatchImages:objects forUser:0];
                                [potMatch loadPotentialMatchData:objects forUser:0];

                                NSString *imageStr = [potMatch.images objectAtIndex:0];
                                NSLog(@"image: %@", imageStr);
                                //view for first match
                                self.userImage.image = [UIImage imageWithData:[self imageData:imageStr]];
                                self.nameAndAge.text = [NSString stringWithFormat:@"%@, %lu", potMatch.firstName, (long)[potMatch ageFromBirthday:potMatch.birthday]];
                                NSLog(@"pot match bday: %@", potMatch.birthday);
                                self.educationLabel.text = potMatch.education;
                                self.jobLabel.text = potMatch.work;


                                //[self checkAndGetImages:objects user:0];
                                //[self checkAndGetUserData:objects user:0];
                                //loggin
                                //PFUser *user1 =  [objects objectAtIndex:0];
                                //PFUser *user2 =  [objects objectAtIndex:1];
                                //get image count for indicator lights
                                [self loadIndicatorLights:objects andUser:0];
                                [self loadIndicatorLights:objects andUser:1];
                                //NSLog(@"2 matches: %@ & %@ for %@", [user1  objectForKey:@"fullName"], [user2 objectForKey:@"fullName"], userA.fullName);

                            }
                                break;
                            default:
                                NSLog(@"more than 2 matches");
                                break;
                        }
                    }
                }];
            }
        }
    }

#pragma mark -- CLLocation delegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations   {
    CLLocation *currentLocation = [locations firstObject];
    NSLog(@"did update locations delegate method: %@", currentLocation);

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
            NSLog(@"user location: %@", self.currentCityAndState);
        }
    }];

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"location manager failed: %@", error);
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
                //indicator lights reflect which image we are on
                [self currentImageLightUpIndicatorLight:self.count];

            } else if (self.count == self.imageArray.count - 1 ){

                self.userImage.image = [UIImage imageWithData:[self imageData:[self.imageArray objectAtIndex:self.count]]];
                NSLog(@"last image");
                [self currentImageLightUpIndicatorLight:self.count];
                //bring up/swap full Description view for small Info view
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
                self.userImage.image = [UIImage imageWithData:[self imageData:[self.imageArray objectAtIndex:self.count]]];
                NSLog(@"first image, count: %zd", self.count);
                //indicator lights
                [self currentImageLightUpIndicatorLight:self.count];
                self.fullDescView.hidden = YES;

            } else if(self.count > 0){

                self.userImage.image = [UIImage imageWithData:[self imageData:[self.imageArray objectAtIndex:self.count]]];
                [self currentImageLightUpIndicatorLight:self.count];
                NSLog(@"count: %zd", self.count);
                self.fullDescView.hidden = YES;

            }
        } completion:^(BOOL finished) {
            NSLog(@"animated");
        }];
    }
}


//Swipe Right or Left
- (IBAction)onSwipeRight:(UISwipeGestureRecognizer *)sender {
    //send approval email
    PFUser *currentMatchUser =  [self.objectsArray objectAtIndex:self.matchedUsersCount];
    NSString *firstNameOFMatch = [currentMatchUser objectForKey:@"firstName"];

    NSString *confidantEmail = [self.currentUser objectForKey:@"confidantEmail"];
    NSLog(@"confidant email: %@", confidantEmail);
    NSString *firstNameOfUser = [self.currentUser objectForKey:@"firstName"];
    NSString *userNeedsHelp = [NSString stringWithFormat:@"%@ needs your approval", firstNameOfUser];
    //relation info for email
    PFUser *approvedMatchUser =  [self.objectsArray objectAtIndex:self.matchedUsersCount];
    PFRelation *approvedRela = [self.currentUser relationForKey:@"matchNotConfirmed"];
    [approvedRela addObject:approvedMatchUser];

    NSString *siteHtml = [NSString stringWithFormat:@"https://api.parse.com/1/classes/%@", approvedRela];
    NSString *cssButton = [NSString stringWithFormat:@"button"];
    NSString *htmlString = [NSString stringWithFormat:@"<a href=%@ class=%@>Aprrove %@ for %@</a>", siteHtml, cssButton, firstNameOFMatch, firstNameOfUser];

    [PFCloud callFunctionInBackground:@"email" withParameters:@{@"email": confidantEmail, @"text": @"What do you think of this user for your friend", @"username": userNeedsHelp, @"htmlCode": htmlString} block:^(NSString *result, NSError *error) {
        if (error) {
            NSLog(@"error cloud js code: %@", error);
        } else {
            NSLog(@"result :%@", result);
        }
    }];



    NSLog(@"swipe right");
    self.count = 1;
    [self.imageArray removeAllObjects];



    [UIView transitionWithView:self.userImage duration:0.1 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{

        //Set relational data to accepted throw a notification to user skip to next user
        if (self.matchedUsersCount == self.objectsArray.count - 1) {

            NSLog(@"last match in queue");
            //bring up the new user Data
            [self matchedView:self.objectsArray user:self.matchedUsersCount + 1];


            //make a new image that takes over the
            // [self checkAndGetImages:self.objectsArray user:self.matchedUsersCount];
            // [self checkAndGetUserData:self.objectsArray user:self.matchedUsersCount];

            //chgange the view for matches up
            self.userImage.image = [UIImage imageNamed:@"cupid-icon"];
            self.userInfoView.hidden = YES;
            self.redButton.hidden = YES;
            self.greenButton.hidden = YES;

            //save the relation to Parse
            PFUser *currentMatchUser =  [self.objectsArray objectAtIndex:self.matchedUsersCount];
            PFRelation *matchWithoutConfirm = [self.currentUser relationForKey:@"matchNotConfirmed"];
            [matchWithoutConfirm addObject:currentMatchUser];

            //for logging purposes
            NSString *fullName = [self.currentUser objectForKey:@"fullName"];
            NSString *fullNameOfCurrentMatch = [currentMatchUser objectForKey:@"fullName"];
            NSLog(@"It's Match Between: %@ and %@",fullName, fullNameOfCurrentMatch);

            [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"error: %@", error);
                }
            }];
            //send the email for confirmation
            //[PFCloud callfun]

        } else {
            UserData *user = [UserData new];
            //view elements, shows next user
            self.matchedUsersCount++;
//            [self checkAndGetImages:self.objectsArray user:self.matchedUsersCount];
//            [self checkAndGetUserData:self.objectsArray user:self.matchedUsersCount];

            //bring up Matched View
            [self matchedView:self.objectsArray user:self.matchedUsersCount];

            //assign a relationship between current user and swiped right user
            PFUser *currentMatchUser =  [self.objectsArray objectAtIndex:self.matchedUsersCount -1];
            PFRelation *matchWithoutConfirm = [self.currentUser relationForKey:@"matchNotConfirmed"];
            [matchWithoutConfirm addObject:currentMatchUser];

            //for logging purposes
            //NSString *fullName = [self.currentUser objectForKey:@"fullName"];
            NSString *fullNameOfCurrentMatch = [currentMatchUser objectForKey:@"fullName"];
            NSLog(@"It's Match Between: %@ and %@", user.fullName, fullNameOfCurrentMatch);

            [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (error) {
                    NSLog(@"error saving relation: %@", error);
                } else{
                    NSLog(@"succeeded in matching: %@ & %@ and saving match: %s", user.fullName, fullNameOfCurrentMatch, succeeded ? "true" : "false");
                }
            }];
        }
    } completion:^(BOOL finished) {
        NSLog(@"animatd");
 }];
}

- (IBAction)onSwipeLeft:(UISwipeGestureRecognizer *)sender {

    NSLog(@"swipe Left, no match");
    self.matchedUsersCount++;
//    [self checkAndGetImages:self.objectsArray user:self.matchedUsersCount];
//    [self checkAndGetUserData:self.objectsArray user:self.matchedUsersCount];

    //save rejected relationship on Parse
    PFUser *currentMatchUser =  [self.objectsArray objectAtIndex:self.matchedUsersCount -1];
    PFRelation *noMatch = [self.currentUser relationForKey:@"NoMatch"];
    [noMatch addObject:currentMatchUser];
    //for logging
    NSString *fullName = [self.currentUser objectForKey:@"fullName"];
    NSString *fullNameOfCurrentMatch = [currentMatchUser objectForKey:@"fullName"];
    NSLog(@"No Match between: %@ and %@",fullName, fullNameOfCurrentMatch);

    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
    }];




}
- (IBAction)onKeepPlaying:(UIButton *)sender {
    self.matchView.hidden = YES;
}

- (IBAction)onMessage:(UIButton *)sender {
    [self performSegueWithIdentifier:@"Messages" sender:self];
}

- (IBAction)onYesButton:(UIButton *)sender {

}




- (IBAction)onXButton:(UIButton *)sender {
}



#pragma mark -- Segue Methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"Messages"]) {
        NSLog(@"Messages Segue");

    } else if ([segue.identifier isEqualToString:@"Settings"])  {

        ProfileViewController *pvc = segue.destinationViewController;
        pvc.userFromViewController = self.currentUser;
        pvc.cityAndState = self.currentCityAndState;
    }
}

#pragma mark -- helpers


-(void)matchedView:(NSArray *)objectsArray user:(NSInteger)userNumber
{
    self.matchView.hidden = NO;

    PFUser *userForImageAndName = [objectsArray objectAtIndex:userNumber - 1];
    NSString *image = [userForImageAndName objectForKey:@"image1"];
    NSString *firstName = [userForImageAndName objectForKey:@"firstName"];

    self.matchedImage.image = [UIImage imageWithData:[self imageData:image]];
    self.matchedLabel.text = firstName;
    self.userImageMatched.image = [UIImage imageWithData:[self imageData:self.userImageForMatching]];

}

-(void)matchViewSetUp:(UIImageView *)userImage andMatchImage:(UIImageView *)matchedImage
{
    self.matchView.backgroundColor = [UIColor blackColor];
    self.matchView.alpha = 0.80;

    userImage.layer.cornerRadius = userImage.image.size.width / 2.0f;
    matchedImage.layer.cornerRadius = matchedImage.image.size.width / 2.0f;
    userImage.clipsToBounds = YES;
    matchedImage.clipsToBounds = YES;
    [self.matchView addSubview:userImage];
    [self.matchView addSubview:matchedImage];

}


-(NSDate *)stringToNSDate:(NSString *)dateAsAString
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MM/dd/yyyy"];

    return [formatter dateFromString:dateAsAString];
}


-(NSData *)imageData:(NSString *)imageString
{
    NSURL *url = [NSURL URLWithString:imageString];
    NSData *data = [NSData dataWithContentsOfURL:url];

    return data;
}

-(void)loadIndicatorLights:(NSArray *)userImageArray andUser:(NSInteger)user{

    PFUser *userForImages =  [userImageArray objectAtIndex:user];

    NSString *image1 = [userForImages objectForKey:@"image1"];
    NSString *image2 = [userForImages objectForKey:@"image2"];
    NSString *image3 = [userForImages objectForKey:@"image3"];
    NSString *image4 = [userForImages objectForKey:@"image4"];
    NSString *image5 = [userForImages objectForKey:@"image5"];
    NSString *image6 = [userForImages objectForKey:@"image6"];

    if (image6) {
        NSLog(@"six images in here hiding no indicator lights");
    } else if (image5)  {
        self.image6Indicator.hidden = YES;
    } else if (image4){
        self.image6Indicator.hidden = YES;
        self.image5Indicator.hidden = YES;
    } else if (image3){
        self.image6Indicator.hidden = YES;
        self.image5Indicator.hidden = YES;
        self.image4Indicator.hidden = YES;
    } else if (image2){
        self.image6Indicator.hidden = YES;
        self.image5Indicator.hidden = YES;
        self.image4Indicator.hidden = YES;
        self.image3Indicator.hidden = YES;
    } else if (image1){
        self.image6Indicator.hidden = YES;
        self.image5Indicator.hidden = YES;
        self.image4Indicator.hidden = YES;
        self.image3Indicator.hidden = YES;
        self.image2Indicator.hidden = YES;
    } else{
        NSLog(@"there are no images to load");
    }

    self.activityView.hidden = YES;
}

-(void)currentImageLightUpIndicatorLight:(long)matchedCount
{
    switch (matchedCount)
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
    UserData *userB = [UserData new];
    self.fullDescView.hidden = NO;
    self.fullDescView.layer.cornerRadius = 10;
    self.fullAboutMe.text = userB.aboutMe;
    NSString *nameAndAge = [NSString stringWithFormat:@"%@, %@", userB.firstName, [userB ageFromBirthday:userB.birthday]];
    self.fullDescNameAndAge.text = nameAndAge;
    self.fullMilesAway.text = userB.milesAway;
}

-(void)setUpButtons:(UIButton *)button
{
    button.layer.cornerRadius = 15.0 / 2.0f;
    button.clipsToBounds = YES;
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[UIColor uclaBlue].CGColor];
}


-(void) sendEmailForApproval{

    NSString *emailTitle = @"Feedback";
    NSString *messageBody = @"<h1>Matched User's Name</h1>";
    NSArray *reciepents = [NSArray arrayWithObject:@"michealsevy@gmail.com"];
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

    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end








