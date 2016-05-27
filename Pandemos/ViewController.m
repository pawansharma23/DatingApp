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
#import "Match.h"
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
@property (weak, nonatomic) IBOutlet UIImageView *noMatchesImage;

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

@property (weak, nonatomic) IBOutlet UITextView *fullDescriptionTextView;

@property (strong, nonatomic) UserManager *userManager;
@property (strong, nonatomic) MessageManager *messageManager;

@property (strong, nonatomic) NSArray<User*> *potentialMatchData;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) User *currentMatch;

@property int userCount;
@property long count;
@property long imageArrayCount;
@property (strong, nonatomic) NSString *currentCityAndState;
//@property (strong, nonatomic) ChooseMatchView *frontCardView;
//@property (strong, nonatomic) ChooseMatchView *backCardView;
//@property (strong, nonatomic) NSString *nameAndAgeGlobal;

//Matching
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *sexPref;
@property (strong, nonatomic) NSString *milesAway;
@property (strong, nonatomic) NSString *minAge;
@property (strong, nonatomic) NSString *maxAge;
@property (strong, nonatomic) NSString *userImageForMatching;
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
    [self hideButtonsAndViews];

    self.currentUser = [User currentUser];

    if (self.currentUser)
    {
        NSLog(@"user: %@(%@) logged in", self.currentUser.givenName, self.currentUser.objectId);

        [self setupManagersProfileVC];

        self.count = 0;
        self.userCount = 0;

        self.potentialMatchData = [NSArray new];

        [self.view insertSubview:self.userInfoView aboveSubview:self.userImage];
        self.fullDescView.layer.cornerRadius = 10;

        [UIImageView setupFullSizedImage:self.userImage];

        [self.userImage setUserInteractionEnabled:YES];

        [self setupGestureUp];
        [self setupGestureDown];
        [self setupGestureLeft];
        [self setupGestureRight];

        [UIButton setIndicatorLight:self.image1Indicator l2:self.image2Indicator l3:self.image3Indicator l4:self.image4Indicator l5:self.image5Indicator l6:self.image6Indicator forCount:self.count];


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
        [self performSegueWithIdentifier:@"NoUser" sender:self];
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
    User *matchedObject = [self.potentialMatchData objectAtIndex:self.userCount];
    NSLog(@"user accepting: %@", matchedObject.givenName);

    if ([self.gender isEqualToString:@"male"])
    {
        [self.userManager createMatchRequest:matchedObject withStatus:@"boyYes" withCompletion:^(MatchRequest *matchRequest, NSError *error) {
        }];
    }
    else if ([self.gender isEqualToString:@"female"])
    {
        [self.userManager createMatchRequest:matchedObject withStatus:@"girlYes" withCompletion:^(MatchRequest *matchRequest, NSError *error) {
        }];
    }

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
    User *matchedObject = [self.potentialMatchData objectAtIndex:self.userCount];
    NSLog(@"user denied: %@", matchedObject.givenName);

    [self.userManager createMatchRequest:matchedObject withStatus:@"Deny" withCompletion:^(MatchRequest *matchRequest, NSError *error) {
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
//ACCEPTED
- (IBAction)onYesButton:(UIButton *)sender
{
    User *matchedObject = [self.potentialMatchData objectAtIndex:self.userCount];
    NSLog(@"user accepting: %@", matchedObject.givenName);

//    [self.userManager queryForUserData:matchedObject.objectId withUser:^(User *users, NSError *error) {
//
//        NSLog(@"usre: %@", users);
//    }];

    if ([self.gender isEqualToString:@"male"])
    {
        //matchObject.objectId is a hack using a string objectId we nneeeeeeeeed to use the User object but keep getting PFCOnsistneyAssertion errors!!!!!???!??!?!?!
        [self.userManager createMatchRequestWithStringId:matchedObject.objectId withStatus:@"boyYes" withCompletion:^(MatchRequest *matchRequest, NSError *error) {

        }];
    }
    else if ([self.gender isEqualToString:@"female"])
    {
        [self.userManager createMatchRequest:matchedObject withStatus:@"girlYes" withCompletion:^(MatchRequest *matchRequest, NSError *error) {
        }];
    }

    [UIView transitionWithView:self.userImage duration:0.2 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{

        [self nextPotentialMatchUp];

        } completion:^(BOOL finished) {
    }];
}
//DENIED
- (IBAction)onXButton:(UIButton *)sender
{
    User *matchedObject = [self.potentialMatchData objectAtIndex:self.userCount];
    NSLog(@"user denied: %@", matchedObject.givenName);

    [self.userManager createMatchRequest:matchedObject withStatus:@"Deny" withCompletion:^(MatchRequest *matchRequest, NSError *error) {
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

#pragma mark -- NAV
- (IBAction)onMessaging:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"Messaging" sender:self];
}

- (IBAction)onSettings:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"Settings" sender:self];
}

- (IBAction)initialSetup:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"NoUser" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Messaging"])
    {
        NSLog(@"Messages Segue");

    }
    else if ([segue.identifier isEqualToString:@"Settings"])
    {
        //ProfileViewController *pvc = segue.destinationViewController;
        //pvc.cityAndState = self.currentCityAndState;
    }
    else if ([segue.identifier isEqualToString:@"NoUser"])
    {
        NSLog(@"no user, log in screen");
    }
}

#pragma mark - USER MANAGER DELEGATE
-(void)didReceiveUserData:(NSArray *)data
{
    NSDictionary *userData = [data firstObject];
    self.sexPref = userData[@"sexPref"];
    self.milesAway = userData[@"milesAway"];
    self.minAge = userData[@"minAge"];
    self.maxAge = userData[@"maxAge"];
    self.gender = userData[@"gender"];
    //this method take user preferences and returns allMatchedUsers
    [self.userManager loadUsersUnseenPotentialMatches:self.sexPref minAge:self.minAge maxAge:self.maxAge];
}

-(void)failedToFetchUserData:(NSError *)error
{
    NSLog(@"failed to fetch Data: %@", error);
}

-(void)didReceivePotentialMatchData:(NSArray *)data
{
    [self.userManager loadMatchedUsers:^(NSArray *users, NSError *error) {

    }];
}

-(void)didLoadMatchedUsers:(NSArray<User *> *)users
{
    //loop through all matched users and compare to all current matches
    NSMutableArray *intersectionArray = [NSMutableArray arrayWithArray:self.userManager.allMatchedUsers];

    for (User *user in self.userManager.allMatchedUsers)
    {
        NSLog(@"match: %@", user.givenName);

        for (NSDictionary *matchRequest in users)//self.userManager.alreadySeenUser
        {
            User *userObjectFrom = matchRequest[@"fromUser"];

            NSString *seenIdFrom = userObjectFrom.objectId;
            NSString *strIdTo = matchRequest[@"strId"];
            //NSString *seenIdTo = userObjectTo.objectId;

            if ([user.objectId isEqualToString:seenIdFrom] || [user.objectId isEqualToString:strIdTo])
            {
                //                    [intersectionArray addObject:user.objectId];
                NSLog(@"filtered matches to remove: %@", user.givenName);
                [intersectionArray removeObject:user];

            }
        }
    }

    if (intersectionArray.count > 0)
    {
        self.potentialMatchData = intersectionArray;
        [self loadInitialMatch:intersectionArray];
        NSLog(@"filtered matches: %d", (int)self.potentialMatchData.count);
    }
    else
    {
        NSLog(@"no user match in your area");
        self.noMatchesImage.image = [UIImage imageWithImage:[UIImage imageNamed:@"Close"] scaledToSize:CGSizeMake(240.0, 128.0)];
        [self.view insertSubview:self.activityView aboveSubview:self.userImage];
    }
}

-(void)failedToFetchPotentialMatchData:(NSError *)error
{
    NSLog(@"NO POTENTIAL MATCHES FOR USER TO SEE: %@", error);
}

-(void)didCreateMatchRequest:(MatchRequest *)matchRequest
{
    NSLog(@"match Request class successfully created: %@", matchRequest);

    //now passes on to get toUser User Object from UserManager private method

    [self.userManager updateMatchRequest:matchRequest withResponse:@"lastStep" withSuccess:^(User *user, NSError *error){
        if (!error)
        {
            NSLog(@"update worked added PFRelation");
            //calls didFetchUserObjectForFinalMatch
        }
    }];
}

-(void)didFetchUserObjectForFinalMatch:(User *)user
{
    //*************Final Security to added the PF RELATION*******************//
    [self.userManager secureMatchWithPFCloudFunction:user];
}
-(void)failedToCreateMatchRequest:(NSError *)error
{
    NSLog(@"failed to create match request: %@", error);
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
-(void)loadInitialMatch:(NSArray*)matchArray
{
    NSDictionary *matchDict = matchArray.firstObject;

    self.currentMatch = matchArray.firstObject;
    self.nameAndAge.text = [NSString stringWithFormat:@"%@, %@", matchDict[@"givenName"], matchDict[@"userAge"]];
    self.jobLabel.text = matchDict[@"work"];
    self.educationLabel.text = matchDict[@"lastSchool"];
    [UIButton loadIndicatorLightsForProfileImages:self.image1Indicator image2:self.image2Indicator image3:self.image3Indicator image4:self.image4Indicator image5:self.image5Indicator image6:self.image6Indicator imageCount:(int)self.currentMatch.profileImages.count];
    self.image1Indicator.backgroundColor = [UIColor rubyRed];
    self.userImage.image = [UIImage imageWithString:[matchDict[@"profileImages"] firstObject]];
}

-(void)hideButtonsAndViews
{
    self.image1Indicator.hidden = YES;
    self.image2Indicator.hidden = YES;
    self.image3Indicator.hidden = YES;
    self.image4Indicator.hidden = YES;
    self.image5Indicator.hidden = YES;
    self.image6Indicator.hidden = YES;
    self.fullDescView.hidden = YES;
    self.matchView.hidden = YES;
}

-(void)loadLocation
{
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
}

-(void)nextPotentialMatchUp
{
    if (self.userCount < self.potentialMatchData.count)
    {
        self.userCount++;
        User *matchedUser = [self.potentialMatchData objectAtIndex:self.userCount];
        self.currentMatch.profileImages = matchedUser[@"profileImages"];

        [UIButton loadIndicatorLightsForProfileImages:self.image1Indicator image2:self.image2Indicator image3:self.image3Indicator image4:self.image4Indicator image5:self.image5Indicator image6:self.image6Indicator imageCount:(int)self.currentMatch.profileImages.count];

        //to curent mach array to 0??

        self.fullDescView.hidden = YES;
        self.userImage.image = [UIImage imageWithString:self.currentMatch.profileImages.firstObject];
        self.nameAndAge.text = [NSString stringWithFormat:@"%@, %@", matchedUser.givenName, [matchedUser ageFromBirthday:matchedUser.birthday]];
        self.jobLabel.text = matchedUser.work;
        self.educationLabel.text = matchedUser.lastSchool;
        //set image array to zero
        self.count = 0;
    }
    else if(self.count == self.userManager.allMatchedUsers.count)
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
        self.userImage.image = [UIImage imageWithString:[self.currentMatch.profileImages objectAtIndex:self.count]];

        [UIButton setIndicatorLight:self.image1Indicator l2:self.image2Indicator l3:self.image3Indicator l4:self.image4Indicator l5:self.image5Indicator l6:self.image6Indicator forCount:self.count];
    }
    else if(self.count > 0)
    {
        self.userImage.image = [UIImage imageWithString:[self.currentMatch.profileImages objectAtIndex:self.count]];
        self.fullDescView.hidden = YES;
        [UIButton setIndicatorLight:self.image1Indicator l2:self.image2Indicator l3:self.image3Indicator l4:self.image4Indicator l5:self.image5Indicator l6:self.image6Indicator forCount:self.count];
        self.userInfoView.hidden = NO;
    }
}

-(void)profileImageSwipeUp
{
    self.count++;
    if (self.count < self.currentMatch.profileImages.count - 1)
    {
        self.userImage.image = [UIImage imageWithString:[self.currentMatch.profileImages objectAtIndex:self.count]];
        [UIButton setIndicatorLight:self.image1Indicator l2:self.image2Indicator l3:self.image3Indicator l4:self.image4Indicator l5:self.image5Indicator l6:self.image6Indicator forCount:self.count];
        self.fullDescView.hidden = YES;
        self.userInfoView.hidden = NO;
    }
    else if (self.count == self.currentMatch.profileImages.count - 1)
    {
        NSLog(@"last image");

        self.userImage.image = [UIImage imageWithString:[self.currentMatch.profileImages objectAtIndex:self.count]];
        [self lastImageLoadFullDescView];
        [UIButton setIndicatorLight:self.image1Indicator l2:self.image2Indicator l3:self.image3Indicator l4:self.image4Indicator l5:self.image5Indicator l6:self.image6Indicator forCount:self.count];
        //get the fullDesc to appear after the last image
        //self.fullDescView.hidden = NO;
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
    self.matchedImage.image = [UIImage imageWithString:image];
    self.matchedLabel.text = firstName;
    self.userImageMatched.image = [UIImage imageWithString:self.userImageForMatching];
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

-(void)lastImageLoadFullDescView
{
    User *user = [User new];
    self.userInfoView.hidden = YES;
    self.fullDescView.hidden = NO;
    self.fullDescView.layer.cornerRadius = 10;
    self.fullAboutMe.text = user.aboutMe;
    self.fullDescNameAndAge.text = [NSString stringWithFormat:@"%@, %@", user.givenName, user.age];;
    self.fullMilesAway.text = user.milesAway;
    self.fullDescriptionTextView.text = user.aboutMe;
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


@end