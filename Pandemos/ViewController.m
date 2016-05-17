//
//  ViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 12/13/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import "User.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MessagingViewController.h"
#import <MessageUI/MessageUI.h>
#import "PotentialMatch.h"
#import "UIColor+Pandemos.h"
#import "UIButton+Additions.h"
#import "UIImageView+Additions.h"
#import "UIImage+Additions.h"
#import "User.h"
#import "UserManager.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "ChooseMatchView.h"
#import "MessageManager.h"

//static const CGFloat ChooseUserButtonHorizontalPadding = 80.f;
//static const CGFloat ChooseUserButtonVerticalPadding = 20.f;

@interface ViewController ()<
UIGestureRecognizerDelegate,
UINavigationControllerDelegate,
CLLocationManagerDelegate,
MFMailComposeViewControllerDelegate,
UserManagerDelegate,
MDCSwipeToChooseDelegate>

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

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) User *currentMatch;
@property (strong, nonatomic) UserManager *userManager;
@property (strong, nonatomic) MessageManager *messageManager;
@property (strong, nonatomic) NSArray<User*> *potentialMatchData;
@property (strong, nonatomic) NSArray<User*> *rawUserMatchData;

@property int userCount;
@property long imageArrayCount;
@property (strong, nonatomic) NSString *currentCityAndState;
//@property (strong, nonatomic) ChooseMatchView *frontCardView;
//@property (strong, nonatomic) ChooseMatchView *backCardView;
//@property (strong, nonatomic) NSString *nameAndAgeGlobal;

//Matching
@property (strong, nonatomic) NSString *sexPref;
@property (strong, nonatomic) NSString *milesAway;
@property (strong, nonatomic) NSString *minAge;
@property (strong, nonatomic) NSString *maxAge;
@property (strong, nonatomic) NSString *userImageForMatching;
@property long count;
@property long matchedUsersCount;
//Location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLGeocoder *geoCoded;
@property (strong, nonatomic) PFGeoPoint *pfGeoCoded;
@end

@implementation ViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // This view controller maintains a list of ChoosePersonView
        // instances to display.
        //_people = [self.potentialMatchData mutableCopy];
    }
    return self;
}

#pragma mark-- VIEW DID LOAD
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = APP_TITLE;
    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
    [self.navigationItem.rightBarButtonItem setTitle:@"Messages"];

    //setup swipe buttons
    [UIButton setUpButton:self.keepPlayingButton];
    [UIButton setUpButton:self.messageButton];
    [UIButton acceptButton:self.greenButton];
    [UIButton denyButton:self.redButton];
}

-(void)viewDidAppear:(BOOL)animated
{
    MessageManager *messageManager = [MessageManager new];
    [messageManager launchApp];
    
    self.image1Indicator.hidden = YES;
    self.image2Indicator.hidden = YES;
    self.image3Indicator.hidden = YES;
    self.image4Indicator.hidden = YES;
    self.image5Indicator.hidden = YES;
    self.image6Indicator.hidden = YES;
    self.fullDescView.hidden = YES;
    self.matchView.hidden = YES;

    self.currentUser = [User currentUser];
    if (self.currentUser)
    {
        NSLog(@"user: %@(%@) logged in", self.currentUser.givenName, self.currentUser.objectId);

        [self setupManagersProfileVC];

        self.count = 0;
        self.userCount = 0;
        self.matchedUsersCount = 0;
        //user match data for methods
        self.rawUserMatchData = [NSArray new];
        //User match data for views
        self.potentialMatchData = [NSArray new];

        //location
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        CLLocation *currentlocal = [self.locationManager location];
        self.currentLocation = currentlocal;
        //NSLog(@"location: lat: %f & long: %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
        //save lat and long in a PFGeoCode Object and save to User in Parse
        //self.pfGeoCoded = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
        //[self.currentUser setObject:self.pfGeoCoded forKey:@"GeoCode"];

        [self.view insertSubview:self.userInfoView aboveSubview:self.userImage];
        self.fullDescView.layer.cornerRadius = 10;

        [UIImageView setupFullSizedImage:self.userImage];

        [self.userImage setUserInteractionEnabled:YES];

        [self setupGestureUp];
        [self setupGestureDown];
        [self setupGestureLeft];
        [self setupGestureRight];

        //    // Display the first ChoosePersonView in front. Users can swipe to indicate
        //    // whether they like or dislike the person displayed.
        //    self.frontCardView = [self popPersonViewWithFrame:[self frontCardViewFrame]];
        //    [self.view addSubview:self.frontCardView];
        //
        //    // Display the second ChoosePersonView in back. This view controller uses
        //    // the MDCSwipeToChooseDelegate protocol methods to update the front and
        //    // back views after each user swipe.
        //    self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
        //    [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        //
        //    // Add buttons to programmatically swipe the view left or right.
        //    // See the `nopeFrontCardView` and `likeFrontCardView` methods.
        //    [self constructNopeButton];
        //    [self constructLikedButton];
    }
    else
    {
        NSLog(@"no user currently logged in");
//        Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'Receiver (<PFLoginViewController: 0x7f8772067800>) has no segue with identifier 'FacebookLogin''
        //[self performSegueWithIdentifier:@"FacebookLogin" sender:self];
    }
}


#pragma mark -- CLLOCATION
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
    {
    CLLocation *currentLocation = [locations firstObject];
  //  NSLog(@"did update locations delegate method: %@", currentLocation);

    [self.locationManager stopUpdatingLocation];
    //get city and location from a CLPlacemark object
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
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
            self.currentCityAndState = [NSString stringWithFormat:@"%@, %@", city, state];
        //    NSLog(@"user location: %@", self.currentCityAndState);
        }
    }];

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location manager failed: %@", error);
}

#pragma mark -- SWIPE GESTURES
- (IBAction)swipeGestureUp:(UISwipeGestureRecognizer *)sender
{
    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *) sender direction];
    if (direction == UISwipeGestureRecognizerDirectionUp)
    {
        [UIView transitionWithView:self.userImage duration:0.2 options:UIViewAnimationOptionTransitionCurlUp animations:^{

            [self profileImageSwipeUp];

        } completion:^(BOOL finished) {
        }];
    }
}

- (IBAction)swipeGestureDown:(UISwipeGestureRecognizer *)sender
{
    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *) sender direction];

    if (direction == UISwipeGestureRecognizerDirectionDown)
    {
        [UIView transitionWithView:self.userImage duration:0.2 options:UIViewAnimationOptionTransitionCurlDown animations:^{

            [self profileImagesSwipeDown];

        } completion:^(BOOL finished) {

        }];
    }
}

- (IBAction)onSwipeRight:(UISwipeGestureRecognizer *)sender
{
    [self.userManager createMatchRequest:[self.potentialMatchData objectAtIndex:self.userCount] withCompletion:^(MatchRequest *matchRequest, NSError *error) {
    }];

    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *) sender direction];

    if (direction == UISwipeGestureRecognizerDirectionRight)
    {
        [UIView transitionWithView:self.userImage duration:0.2 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{

            [self nextPotentialMatchUp];

        } completion:^(BOOL finished) {
        }];
    }
}

- (IBAction)onSwipeLeft:(UISwipeGestureRecognizer *)sender
{
    [self.userManager createDenyMatchRequest:[self.potentialMatchData objectAtIndex:self.userCount] withCompletion:^(MatchRequest *matchRequest, NSError *error) {
    }];

    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *) sender direction];

    if (direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [UIView transitionWithView:self.userImage duration:0.2 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{

            [self nextPotentialMatchUp];

        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark -- BUTTONS
- (IBAction)onYesButton:(UIButton *)sender
{
   // NSLog(@"user accepting: %@", [self.potentialMatchData objectAtIndex:self.userCount]);
    NSString *givenName = [self.rawUserMatchData objectAtIndex:self.userCount].givenName;
    NSLog(@"user accpting: %@", givenName);
    
    [self.userManager createMatchRequest:[self.rawUserMatchData objectAtIndex:self.userCount] withCompletion:^(MatchRequest *matchRequest, NSError *error) {
    }];

    [UIView transitionWithView:self.userImage duration:0.2 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{

        [self nextPotentialMatchUp];

        } completion:^(BOOL finished) {
    }];
}

- (IBAction)onXButton:(UIButton *)sender
{
    [self.userManager createDenyMatchRequest:[self.potentialMatchData objectAtIndex:self.userCount] withCompletion:^(MatchRequest *matchRequest, NSError *error) {
    }];

    [UIView transitionWithView:self.userImage duration:0.2 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{

        [self nextPotentialMatchUp];

        } completion:^(BOOL finished) {
    }];
}

- (IBAction)onKeepPlaying:(UIButton *)sender
{
    self.matchView.hidden = YES;
}

- (IBAction)onMessage:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"Messages" sender:self];
}

#pragma mark - USER MANAGER DELEGATE
-(void)didReceiveUserData:(NSArray *)data
{
    NSDictionary *userData = [data firstObject];
    self.sexPref = userData[@"sexPref"];
    self.milesAway = userData[@"milesAway"];
    self.minAge = userData[@"minAge"];
    self.maxAge = userData[@"maxAge"];
    [self.userManager loadUsersUnseenPotentialMatches:self.sexPref minAge:self.minAge maxAge:self.maxAge];
}

-(void)failedToFetchUserData:(NSError *)error
{
    NSLog(@"failed to fetch Data: %@", error);
}

-(void)didReceivePotentialMatchData:(NSArray *)data
{
    NSMutableArray *array = [NSMutableArray new];
    self.rawUserMatchData = data;

    for (NSDictionary *dict in data)
    {
        User *user = [User new];
        user.objectId = dict[@"objectId"];
        user.work = dict[@"work"];
        user.birthday = dict[@"birthday"];
        user.givenName = dict[@"givenName"];
        user.age = dict[@"userAge"];
        user.profileImages = dict[@"profileImages"];

        [array addObject:user];
    }
    //1st match
    self.potentialMatchData = array;
    self.currentMatch = [array objectAtIndex:0];
    //set 1st match data objects
    self.nameAndAge.text = [NSString stringWithFormat:@"%@,%@", self.currentMatch.givenName, self.currentMatch.age];
    self.jobLabel.text = self.currentMatch.work;
    self.educationLabel.text = self.currentMatch.lastSchool;
    //images
    int profilePhotos = (int)self.currentMatch.profileImages.count;
    [self loadIndicatorLights:profilePhotos];
    self.image1Indicator.backgroundColor = [UIColor rubyRed];
    self.userImage.image = [UIImage imageWithData:[self imageData:[self.currentMatch.profileImages firstObject]]];

    //matches
    //NSLog(@"%d maches:\n1:%@ \n2st: %@\n3st:%@", (int)self.potentialMatchData.count, self.potentialMatchData.firstObject, [self.potentialMatchData objectAtIndex:1].givenName, [self.potentialMatchData objectAtIndex:2].givenName);
}

-(void)failedToFetchPotentialMatchData:(NSError *)error
{
    NSLog(@"failed to fetch match data: %@", error);
}

-(void)didReceivePotentialMatchImages:(NSArray *)images
{
    //vacated for now with data and images both being sent to didReceivePotentialMatchData
}

-(void)failedToFetchPotentialMatchImages:(NSError *)error
{
    NSLog(@"failed to fetch match images: %@", error);
}

-(void)didCreateMatchRequest:(MatchRequest *)matchRequest
{
    [self.userManager updateMatchRequest:matchRequest withResponse:@"pending" withSuccess:^(User *user, NSError *error){
        if (!error)
        {
            //adds PFRelation to the MatchRequest
            NSLog(@"update worked");
        }
    }];
}

-(void)failedToCreateMatchRequest:(NSError *)error
{
    NSLog(@"failed to create match request: %@", error);
}
-(void)didUpdateMatchRequest:(User *)user
{

    NSLog(@"to user: %@", user.givenName);
//    [self.messageManager createConversationWithUsers:@[user.objectId] withCompletion:^(LYRConversation *conversation, NSError *error) {
//        NSLog(@"convo object: %@", conversation);
//    }];


    //this starts the convo even though we need another layer of authentication to go through so this method should live in a launch app or pending match screen, or even in the MessageController
    //[self.messageManager createConversationWithUsers:@[user.objectId] withCompletion:^(LYRConversation *conversation, NSError *error) {

//    }];

}

-(void)failedToUpdateMatchRequest:(NSError *)error
{
    NSLog(@"failed to update match: %@", error);
}

-(void)didCreateDenyMatchRequest:(MatchRequest *)matchRequest
{
    NSLog(@"match user request was denied for %@", [self.potentialMatchData objectAtIndex:self.count].givenName);
}

-(void)failedToCreateDenyMatchRequest:(NSError *)error
{
    NSLog(@"failed to create deny request: %@", error);
}

#pragma mark -- HELPERS
-(void)nextPotentialMatchUp
{
    if (self.count < self.rawUserMatchData.count)
    {

    self.userCount++;
    User *matchedUser = [self.potentialMatchData objectAtIndex:self.userCount];
    self.currentMatch.profileImages = matchedUser[@"profileImages"];
    [self loadIndicatorLights:(int)self.currentMatch.profileImages.count];
    //self.image1Indicator.backgroundColor = [UIColor rubyRed];
        //which indicator light will light up
        [self currentImageLightUpIndicatorLight:0];

    self.userImage.image = [UIImage imageWithData:[self imageData:self.currentMatch.profileImages.firstObject]];
    self.nameAndAge.text = [NSString stringWithFormat:@"%@, %@", matchedUser.givenName, matchedUser.age];
    self.jobLabel.text = matchedUser.work;
    self.educationLabel.text = matchedUser.lastSchool;

    self.count = 0;
    }
    else if(self.count == self.rawUserMatchData.count)
    {
        NSLog(@"last match");
    }
    else
    {
        NSLog(@"other count");
    }
}

-(void)profileImagesSwipeDown
{
    self.count--;
    if (self.count == 0)
    {
        self.userImage.image = [UIImage imageWithData:[self imageData:[self.currentMatch.profileImages objectAtIndex:self.count]]];
        [self currentImageLightUpIndicatorLight:self.count];
        self.fullDescView.hidden = YES;
    }
    else if(self.count > 0)
    {
        self.userImage.image = [UIImage imageWithData:[self imageData:[self.currentMatch.profileImages objectAtIndex:self.count]]];
        [self currentImageLightUpIndicatorLight:self.count];
        NSLog(@"count: %zd", self.count);
        self.fullDescView.hidden = YES;
    }
}

-(void)profileImageSwipeUp
{
    self.count++;
    if (self.count < self.currentMatch.profileImages.count - 1)
    {
        self.userImage.image = [UIImage imageWithData:[self imageData:[self.currentMatch.profileImages objectAtIndex:self.count]]];
        [self currentImageLightUpIndicatorLight:self.count];
    }
    else if (self.count == self.currentMatch.profileImages.count - 1)
    {
        NSLog(@"last image");
        self.userImage.image = [UIImage imageWithData:[self imageData:[self.currentMatch.profileImages objectAtIndex:self.count]]];
        [self currentImageLightUpIndicatorLight:self.count];
        [self lastImageBringUpDesciptionView];
    }
}

-(void)setupManagersProfileVC
{
    self.userManager = [UserManager new];
    self.userManager.delegate = self;
    [self.userManager loadUserData:self.currentUser];
}

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

-(NSData *)imageData:(NSString *)imageString
{
    NSURL *url = [NSURL URLWithString:imageString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
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
    User *user = [User new];
    self.fullDescView.hidden = NO;
    self.fullDescView.layer.cornerRadius = 10;
    self.fullAboutMe.text = user.aboutMe;
    NSString *nameAndAge = [NSString stringWithFormat:@"%@, %@", user.givenName, user.age];
    //[userB ageFromBirthday:userB.birthday]];
    self.fullDescNameAndAge.text = nameAndAge;
    self.fullMilesAway.text = user.milesAway;
}

-(void) sendEmailForApproval
{
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

    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)setupGestureUp
{
    UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(swipeGestureUp:)];
    [swipeGestureUp setDelegate:self];
    swipeGestureUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.userImage addGestureRecognizer:swipeGestureUp];
}

-(void)setupGestureDown
{
    UISwipeGestureRecognizer *swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(swipeGestureDown:)];
    [swipeGestureDown setDelegate:self];
    swipeGestureDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.userImage addGestureRecognizer:swipeGestureDown];
}

-(void)setupGestureRight
{
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(onSwipeRight:)];
    [swipeRight setDelegate:self];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.userImage addGestureRecognizer:swipeRight];
}

-(void)setupGestureLeft
{
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(onSwipeLeft:)];
    [swipeLeft setDelegate:self];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.userImage addGestureRecognizer:swipeLeft];
}

#pragma mark -- SEGUE
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Messages"])
    {
        NSLog(@"Messages Segue");

    }
    else if ([segue.identifier isEqualToString:@"Settings"])
    {
        ProfileViewController *pvc = segue.destinationViewController;
        pvc.userFromViewController = self.currentUser;
        pvc.cityAndState = self.currentCityAndState;
    }
}

@end

//#pragma mark -- MDC DELEGATE
//
//// This is called when a user didn't fully swipe left or right.
//- (void)viewDidCancelSwipe:(UIView *)view
//{
//    NSLog(@"You couldn't decide on %@.", self.currentMatch.username);
//}
//
//// This is called then a user swipes the view fully left or right.
//- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction
//{
//    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
//    // and "LIKED" on swipes to the right.
//    if (direction == MDCSwipeDirectionLeft)
//    {
//        NSLog(@"You noped %@.", self.currentMatch.username);
//    } else
//    {
//        NSLog(@"You liked %@.", self.currentMatch.username);
//    }
//
//    // MDCSwipeToChooseView removes the view from the view hierarchy
//    // after it is swiped (this behavior can be customized via the
//    // MDCSwipeOptions class). Since the front card view is gone, we
//    // move the back card to the front, and create a new back card.
//    self.frontCardView = self.backCardView;
//    if ((self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]])) {
//        // Fade the back card into view.
//        self.backCardView.alpha = 0.f;
//        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
//        [UIView animateWithDuration:0.5
//                              delay:0.0
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             self.backCardView.alpha = 1.f;
//                         } completion:nil];
//    }
//}
//#pragma mark -- MDC
//- (void)setFrontCardView:(ChooseMatchView *)frontCardView
//{
//    // Keep track of the person currently being chosen.
//    // Quick and dirty, just for the purposes of this sample app.
//    _frontCardView = frontCardView;
//    self.currentMatch = frontCardView.user;
//}
//
//- (ChooseMatchView *)popPersonViewWithFrame:(CGRect)frame
//{
//    if ([self.people count] == 0)
//    {
//        return nil;
//    }
//
//    // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
//    // Each take an "options" argument. Here, we specify the view controller as
//    // a delegate, and provide a custom callback that moves the back card view
//    // based on how far the user has panned the front card view.
//    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
//    options.delegate = self;
//    options.threshold = 160.f;
//    options.onPan = ^(MDCPanState *state){
//        CGRect frame = [self backCardViewFrame];
//        self.backCardView.frame = CGRectMake(frame.origin.x,
//                                             frame.origin.y - (state.thresholdRatio * 10.f),
//                                             CGRectGetWidth(frame),
//                                             CGRectGetHeight(frame));
//    };
//
//    // Create a personView with the top person in the people array, then pop
//    // that person off the stack.
//    ChooseMatchView *userView = [[ChooseMatchView alloc] initWithFrame:frame
//                                                                    user:self.people[0]
//                                                                   options:options];
//    [self.people removeObjectAtIndex:0];
//    return userView;
//}
//
//#pragma mark View Contruction
//
//- (CGRect)frontCardViewFrame
//{
//    CGFloat horizontalPadding = 20.f;
//    CGFloat topPadding = 60.f;
//    CGFloat bottomPadding = 200.f;
//    return CGRectMake(horizontalPadding,
//                      topPadding,
//                      CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
//                      CGRectGetHeight(self.view.frame) - bottomPadding);
//}
//
//- (CGRect)backCardViewFrame
//{
//    CGRect frontFrame = [self frontCardViewFrame];
//    return CGRectMake(frontFrame.origin.x,
//                      frontFrame.origin.y + 10.f,
//                      CGRectGetWidth(frontFrame),
//                      CGRectGetHeight(frontFrame));
//}
//
//// Create and add the "nope" button.
//- (void)constructNopeButton
//{
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    UIImage *image = [UIImage imageNamed:@"nope"];
//    button.frame = CGRectMake(ChooseUserButtonHorizontalPadding,
//                              CGRectGetMaxY(self.frontCardView.frame) + ChooseUserButtonVerticalPadding,
//                              image.size.width,
//                              image.size.height);
//    [button setImage:image forState:UIControlStateNormal];
//    [button setTintColor:[UIColor colorWithRed:247.f/255.f
//                                         green:91.f/255.f
//                                          blue:37.f/255.f
//                                         alpha:1.f]];
//    [button addTarget:self
//               action:@selector(nopeFrontCardView)
//     forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
//}
//
//// Create and add the "like" button.
//- (void)constructLikedButton
//{
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    UIImage *image = [UIImage imageNamed:@"liked"];
//    button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChooseUserButtonHorizontalPadding,
//                              CGRectGetMaxY(self.frontCardView.frame) + ChooseUserButtonVerticalPadding,
//                              image.size.width,
//                              image.size.height);
//    [button setImage:image forState:UIControlStateNormal];
//    [button setTintColor:[UIColor colorWithRed:29.f/255.f
//                                         green:245.f/255.f
//                                          blue:106.f/255.f
//                                         alpha:1.f]];
//    [button addTarget:self
//               action:@selector(likeFrontCardView)
//     forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
//}
//
//// Programmatically "nopes" the front card view.
//- (void)nopeFrontCardView
//{
//    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
//}
//
//// Programmatically "likes" the front card view.
//- (void)likeFrontCardView
//{
//    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
//}





//    PFUser *currentMatchUser =  [self.objectsArray objectAtIndex:self.matchedUsersCount];
//    NSString *firstNameOFMatch = [currentMatchUser objectForKey:@"firstName"];
//
//    NSString *confidantEmail = [self.currentUser objectForKey:@"confidantEmail"];
//    NSLog(@"confidant email: %@", confidantEmail);
//    NSString *firstNameOfUser = [self.currentUser objectForKey:@"firstName"];
//    NSString *userNeedsHelp = [NSString stringWithFormat:@"%@ needs your approval", firstNameOfUser];
//    //relation info for email
//    PFUser *approvedMatchUser =  [self.objectsArray objectAtIndex:self.matchedUsersCount];
//    PFRelation *approvedRela = [self.currentUser relationForKey:@"matchNotConfirmed"];
//    [approvedRela addObject:approvedMatchUser];
//
//    NSString *siteHtml = [NSString stringWithFormat:@"https://api.parse.com/1/classes/%@", approvedRela];
//    NSString *cssButton = [NSString stringWithFormat:@"button"];
//    NSString *htmlString = [NSString stringWithFormat:@"<a href=%@ class=%@>Aprrove %@ for %@</a>", siteHtml, cssButton, firstNameOFMatch, firstNameOfUser];
//
//    [PFCloud callFunctionInBackground:@"email" withParameters:@{@"email": confidantEmail, @"text": @"What do you think of this user for your friend", @"username": userNeedsHelp, @"htmlCode": htmlString} block:^(NSString *result, NSError *error) {
//        if (error) {
//            NSLog(@"error cloud js code: %@", error);
//        } else {
//            NSLog(@"result :%@", result);
//        }
//    }];
//
//
//
//    NSLog(@"swipe right");
//    self.count = 1;
//    [self.imageArray removeAllObjects];
//
//
//
//    [UIView transitionWithView:self.userImage duration:0.1 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
//
//        //Set relational data to accepted throw a notification to user skip to next user
//        if (self.matchedUsersCount == self.objectsArray.count - 1)
//        {
//
//            NSLog(@"last match in queue");
//            //bring up the new user Data
//            [self matchedView:self.objectsArray user:self.matchedUsersCount + 1];
//
//
//            //make a new image that takes over the
//            // [self checkAndGetImages:self.objectsArray user:self.matchedUsersCount];
//            // [self checkAndGetUserData:self.objectsArray user:self.matchedUsersCount];
//
//            //chgange the view for matches up
//            self.userImage.image = [UIImage imageNamed:@"cupid-icon"];
//            self.userInfoView.hidden = YES;
//            self.redButton.hidden = YES;
//            self.greenButton.hidden = YES;
//
//            //save the relation to Parse
//            PFUser *currentMatchUser =  [self.objectsArray objectAtIndex:self.matchedUsersCount];
//            PFRelation *matchWithoutConfirm = [self.currentUser relationForKey:@"matchNotConfirmed"];
//            [matchWithoutConfirm addObject:currentMatchUser];
//
//            //for logging purposes
//            NSString *fullName = [self.currentUser objectForKey:@"fullName"];
//            NSString *fullNameOfCurrentMatch = [currentMatchUser objectForKey:@"fullName"];
//            NSLog(@"It's Match Between: %@ and %@",fullName, fullNameOfCurrentMatch);
//
//            [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                if (error) {
//                    NSLog(@"error: %@", error);
//                }
//            }];
//            //send the email for confirmation
//            //[PFCloud callfun]
//
//        } else {
//            User *user = [User new];
//            //view elements, shows next user
//            self.matchedUsersCount++;
////            [self checkAndGetImages:self.objectsArray user:self.matchedUsersCount];
////            [self checkAndGetUserData:self.objectsArray user:self.matchedUsersCount];
//
//            //bring up Matched View
//            [self matchedView:self.objectsArray user:self.matchedUsersCount];
//
//            //assign a relationship between current user and swiped right user
//            PFUser *currentMatchUser =  [self.objectsArray objectAtIndex:self.matchedUsersCount -1];
//            PFRelation *matchWithoutConfirm = [self.currentUser relationForKey:@"matchNotConfirmed"];
//            [matchWithoutConfirm addObject:currentMatchUser];
//
//            //for logging purposes
//            //NSString *fullName = [self.currentUser objectForKey:@"fullName"];
//            NSString *fullNameOfCurrentMatch = [currentMatchUser objectForKey:@"fullName"];
//            NSLog(@"It's Match Between: %@ and %@", user.givenName, fullNameOfCurrentMatch);
//
//            [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//
//                if (error) {
//                    NSLog(@"error saving relation: %@", error);
//                } else{
//                    NSLog(@"succeeded in matching: %@ & %@ and saving match: %s", user.givenName, fullNameOfCurrentMatch, succeeded ? "true" : "false");
//                }
//            }];
//        }
//    } completion:^(BOOL finished) {
//        NSLog(@"animatd");
// }];