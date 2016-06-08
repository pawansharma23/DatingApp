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
#import "MessagingList.h"
#import <MessageUI/MessageUI.h>
//#import "PotentialMatch.h"
#import "UIColor+Pandemos.h"
#import "UIButton+Additions.h"
#import "UIImageView+Additions.h"
#import "UIImage+Additions.h"
#import "User.h"
#import "UserManager.h"
#import "MessageManager.h"
#import "DraggableViewBackground.h"

@interface ViewController ()<
UINavigationControllerDelegate,
CLLocationManagerDelegate,
MFMailComposeViewControllerDelegate,
UserManagerDelegate>

@property (strong, nonatomic) UserManager *userManager;
@property (strong, nonatomic) MessageManager *messageManager;
@property (strong, nonatomic) NSArray<User*> *potentialMatchData;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) User *currentMatch;

@property int userCount;
@property long count;
@property long imageArrayCount;
@property (strong, nonatomic) NSString *currentCityAndState;
@property (strong, nonatomic) NSString *gender;
//Loc
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLGeocoder *geoCoded;
@property (strong, nonatomic) PFGeoPoint *pfGeoCoded;
@end

@implementation ViewController


#pragma mark-- VIEW DID LOAD
- (void)viewDidLoad
{
    [super viewDidLoad];

    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
    [self.view addSubview:draggableBackground];
    //self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = APP_TITLE;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor unitedNationBlue]}];
    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
    [self.navigationItem.rightBarButtonItem setTitle:@"Messages"];

    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageWithImage:[UIImage imageNamed:@"Ally"] scaledToSize:CGSizeMake(30, 30)]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];


    self.currentUser = [User currentUser];

    if (self.currentUser)
    {
        NSLog(@"user: %@(%@) logged in", self.currentUser.givenName, self.currentUser.objectId);

        self.count = 0;
        self.userCount = 0;
        self.potentialMatchData = [NSArray new];

    }
    else
    {
        [self performSegueWithIdentifier:@"NoUser" sender:self];
    }
}


//#pragma mark -- CLLOCATION
//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
//{
//    CLLocation *currentLocation = [locations firstObject];
//    //  NSLog(@"did update locations delegate method: %@", currentLocation);
//
//    [self.locationManager stopUpdatingLocation];
//    //get city and location from a CLPlacemark object
//    CLGeocoder *geoCoder = [CLGeocoder new];
//    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        if (error)
//        {
//            NSLog(@"error: %@", error);
//        }
//        else
//        {
//            CLPlacemark *placemark = [placemarks firstObject];
//            NSString *city = placemark.locality;
//            NSDictionary *stateDict = placemark.addressDictionary;
//            NSString *state = stateDict[@"State"];
//            self.currentCityAndState = [NSString stringWithFormat:@"%@, %@", city, state];
//        }
//    }];
//
//}
//
//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//    NSLog(@"location manager failed: %@", error);
//}

//#pragma mark -- BUTTONS
////ACCEPTED
//- (IBAction)onYesButton:(UIButton *)sender
//{
//    User *matchedObject = [self.potentialMatchData objectAtIndex:self.userCount];
//    NSLog(@"user accepting: %@", matchedObject.givenName);
//
//    [self setYesStatusForMatchRequestObject:matchedObject];
//
//    [UIView transitionWithView:self.userImage duration:0.2 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
//
//        [self nextPotentialMatchUp];
//
//        } completion:^(BOOL finished) {
//    }];
//}
////DENIED
//- (IBAction)onXButton:(UIButton *)sender
//{
//    User *matchedObject = [self.potentialMatchData objectAtIndex:self.userCount];
//    NSLog(@"user denied: %@", matchedObject.givenName);
//
//    [self.userManager createMatchRequestWithStringId:matchedObject.objectId withStatus:@"denied" withCompletion:^(MatchRequest *matchRequest, NSError *error) {
//    }];
//
//    [UIView transitionWithView:self.userImage duration:0.2 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
//
//        [self nextPotentialMatchUp];
//
//    } completion:^(BOOL finished) {
//    }];
//}

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

//-(void)didCreateMatchRequest:(MatchRequest *)matchRequest
//{
//    NSLog(@"match Request class successfully created: %@", matchRequest);
//
//    //now passes on to get toUser User Object from UserManager private method
//    [self.userManager updateMatchRequestWithRetrivalUserObject:matchRequest withResponse:@"lastStep" withSuccess:^(NSDictionary *userDict, NSError *error) {
//
//        if (!error)
//        {
//            NSLog(@"update worked added PFRelation");
//            //calls didFetchUserObjectForFinalMatch
//        }
//    }];
//}
//
//-(void)didFetchUserObjectForFinalMatch:(User *)user
//{
//    //*************Final Security to added the PF RELATION*******************//
//    for (NSDictionary *dict in self.userManager.alreadySeenUsers)
//    {
//        User *userObjId = dict[@"fromUser"];
//        NSString *status = dict[@"status"];
//        //need to change to user being a girl and status = "confidantApproved"
//
//        if ([userObjId.objectId isEqualToString:[User currentUser].objectId] && [status isEqualToString:@"boyYes"])
//        {
//            NSLog(@"print matches: %@", dict[@"strId"]);
//            //*******************allow users to talk****************complete approval******************:
//            [self matchedView:[self.potentialMatchData objectAtIndex:self.userCount]];
//        }
//        else
//        {   //need to be female, male for testing
//            if ([self.gender isEqualToString:@"male"])
//            {
//                //send email for approval
//                [self sendEmailForApproval];
//                NSLog(@"still need anther level of approval to start chatting");
//
//            }
//        }
//    }
//
//    //[self.userManager secureMatchWithPFCloudFunction:user];
//}

//-(void)failedToCreateMatchRequest:(NSError *)error
//{
//    NSLog(@"failed to create match request: %@", error);
//}
//
//-(void)failedToUpdateMatchRequest:(NSError *)error
//{
//    NSLog(@"failed to update match: %@", error);
//}
//
//-(void)didCreateDenyMatchRequest:(MatchRequest *)matchRequest
//{
//    NSLog(@"match user request was denied for %@", [self.potentialMatchData objectAtIndex:self.count].givenName);
//}
//
//-(void)failedToCreateDenyMatchRequest:(NSError *)error
//{
//    NSLog(@"failed to create deny request: %@", error);
//}

#pragma mark -- HELPERS
-(void)setYesStatusForMatchRequestObject:(User*)potentialMatch
{
    if ([self.gender isEqualToString:@"male"])
    {
        [self matchStatus:@"boyYes" potentialMatch:potentialMatch];
    }
    else if ([self.gender isEqualToString:@"female"])
    {
        [self matchStatus:@"girlYes" potentialMatch:potentialMatch];
    }
}

-(void)matchStatus:(NSString*)status potentialMatch:(User*)potMatch
{
    [self.userManager createMatchRequestWithStringId:potMatch.objectId withStatus:status withCompletion:^(MatchRequest *matchRequest, NSError *error) {
    }];
}

//-(void)loadLocation
//{
//    //location
//    self.locationManager = [CLLocationManager new];
//    self.locationManager.delegate = self;
//    [self.locationManager requestWhenInUseAuthorization];
//    [self.locationManager startUpdatingLocation];
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
//    CLLocation *currentlocal = [self.locationManager location];
//    self.currentLocation = currentlocal;
    //NSLog(@"location: lat: %f & long: %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    //save lat and long in a PFGeoCode Object and save to User in Parse
    //self.pfGeoCoded = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
    //[self.currentUser setObject:self.pfGeoCoded forKey:@"GeoCode"];
//}
//
//-(void)nextPotentialMatchUp
//{
//    if (self.userCount < self.potentialMatchData.count - 1)
//    {
//        self.userCount++;
//        User *matchedUser = [self.potentialMatchData objectAtIndex:self.userCount];
//        self.currentMatch.profileImages = matchedUser[@"profileImages"];
//
//        [UIButton loadIndicatorLightsForProfileImages:self.image1Indicator image2:self.image2Indicator image3:self.image3Indicator image4:self.image4Indicator image5:self.image5Indicator image6:self.image6Indicator imageCount:(int)self.currentMatch.profileImages.count];
//
//        //to curent mach array to 0??
//
//        self.fullDescView.hidden = YES;
//        self.userImage.image = [UIImage imageWithString:self.currentMatch.profileImages.firstObject];
//        self.nameAndAge.text = [NSString stringWithFormat:@"%@, %@", matchedUser.givenName, [matchedUser ageFromBirthday:matchedUser.birthday]];
//        self.jobLabel.text = matchedUser.work;
//        self.educationLabel.text = matchedUser.lastSchool;
//        //set image array to zero
//        self.count = 0;
//    }
//    else if(self.count == self.potentialMatchData.count - 1)
//    {
//        NSLog(@"no user match in your area");
//        self.noMatchesImage.image = [UIImage imageWithImage:[UIImage imageNamed:@"Close"] scaledToSize:CGSizeMake(240.0, 128.0)];
//        [self.view insertSubview:self.activityView aboveSubview:self.userImage];
//    }
//    else
//    {
//        NSLog(@"other count");
//    }
//}



//-(void)matchedViewSetUp:(UIImageView *)userImage andMatchImage:(UIImageView *)matchedImage
//{
//    self.matchView.backgroundColor = [UIColor blackColor];
//    self.matchView.alpha = 0.80;
//
//    userImage.layer.cornerRadius = userImage.image.size.width / 2.0f;
//    matchedImage.layer.cornerRadius = matchedImage.image.size.width / 2.0f;
//    userImage.clipsToBounds = YES;
//    matchedImage.clipsToBounds = YES;
//    [self.matchView addSubview:userImage];
//    [self.matchView addSubview:matchedImage];
//}

//-(void)sendEmailForApproval
//{
//    NSString *emailTitle = @"Feedback";
//    NSString *messageBody = @"<h1>Matched User's Name</h1>";
//    NSArray *reciepents = [NSArray arrayWithObject:@"michealsevy@gmail.com"];
//    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc]init];
//    mc.mailComposeDelegate = self;
//    [mc setSubject:emailTitle];
//    [mc setMessageBody:messageBody isHTML:YES];
//    [mc setToRecipients:reciepents];
//
//    [self presentViewController:mc animated:YES completion:nil];
//}
//
//- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
//{
//    switch (result)
//    {
//        case MFMailComposeResultCancelled:
//            NSLog(@"Mail cancelled");
//            break;
//        case MFMailComposeResultSaved:
//            NSLog(@"Mail saved");
//            break;
//        case MFMailComposeResultSent:
//            NSLog(@"Mail sent");
//            break;
//        case MFMailComposeResultFailed:
//            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
//            break;
//        default:
//            break;
//    }
//
//    [self dismissViewControllerAnimated:YES completion:NULL];
//}
@end