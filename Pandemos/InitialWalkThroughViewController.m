//
//  InitialWalkThroughViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 12/20/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import "InitialWalkThroughViewController.h"
#import <Foundation/Foundation.h>

#import <Parse/PFConstants.h>
#import <Parse/PFUser.h>
#import <Parse/Parse.h>
#import "ChooseImageInitialViewController.h"
#import "SuggestionsViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <LXReorderableCollectionViewFlowLayout.h>
#import "CVCell.h"
#import "UIColor+Pandemos.h"
#import "UIButton+Additions.h"
#import "UITextView+Additions.h"
#import "Facebook.h"
#import "FacebookManager.h"
#import "FacebookNetwork.h"
#import "User.h"
#import "SVProgressHUD.h"

@interface InitialWalkThroughViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
LXReorderableCollectionViewDelegateFlowLayout,
LXReorderableCollectionViewDataSource,
CLLocationManagerDelegate,
UITextViewDelegate,
UIScrollViewDelegate,
FacebookManagerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *textViewAboutMe;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISlider *minAgeSlider;
@property (weak, nonatomic) IBOutlet UISlider *maxAgeSlider;
@property (weak, nonatomic) IBOutlet UISlider *milesSlider;
@property (weak, nonatomic) IBOutlet UILabel *minAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationlabel;
@property (weak, nonatomic) IBOutlet UILabel *milesAwayLabel;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookAlbumBUtton;
@property (weak, nonatomic) IBOutlet UIButton *mensInterestButton;
@property (weak, nonatomic) IBOutlet UIButton *womensInterestButton;
@property (weak, nonatomic) IBOutlet UIButton *bothSexesButton;
@property (weak, nonatomic) IBOutlet UIButton *suggestionsButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *emptyImageButton;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotifications;
@property (weak, nonatomic) IBOutlet UILabel *notValidImageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) FacebookManager *manager;

@property (strong, nonatomic) NSArray *thumbnails;
@property (strong, nonatomic) NSMutableArray *selectedPictures;
@property (strong, nonatomic) NSArray *nextPages;
@property (strong, nonatomic) NSArray *previousPages;

@property (strong, nonatomic) NSString *selectedImage;
@property (strong, nonatomic) PFGeoPoint *pfGeoCoded;
@property (strong, nonatomic) NSString *userGender;
//likes
//@property (strong, nonatomic) NSMutableArray *likeArray;
//@property (strong, nonatomic) NSMutableArray *secondLikeArray;


@end

@implementation InitialWalkThroughViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [User currentUser];

    if (self.currentUser)
    {
        NSLog(@"User: %@", self.currentUser.fullName);

        [self.spinner startAnimating];
        self.loadingView.alpha = .75;
        self.loadingView.layer.cornerRadius = 8;
        self.navigationItem.title = @"Setup";
        self.navigationController.navigationBar.backgroundColor = [UIColor yellowGreen];
        self.automaticallyAdjustsScrollViewInsets = NO;

        //set and initialize delegates
        self.scrollView.delegate = self;
        self.textViewAboutMe.delegate = self;
        self.collectionView.delegate = self;
        self.selectedPictures = [NSMutableArray new];
        self.thumbnails = [NSArray new];
        self.nextPages = [NSArray new];

        self.previousButton.hidden = YES;



        //COLLECTIONVIEW
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setItemSize:CGSizeMake(100, 100)];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [self.collectionView setCollectionViewLayout:flowLayout];
        self.collectionView.backgroundColor = [UIColor whiteColor];

        //LOCATION
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        double latitude = self.locationManager.location.coordinate.latitude;
        double longitude = self.locationManager.location.coordinate.longitude;

        //save lat and long in a PFGeoCode Object and save to User in Parse
        self.pfGeoCoded = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
        [self.currentUser setObject:self.pfGeoCoded forKey:@"GeoCode"];
        //NSLog(@"saved PFGeoCode: %@", self.pfGeoCoded);

        //SETUP
        [UIButton setUpButtons:self.mensInterestButton];
        [UIButton setUpButtons:self.womensInterestButton];
        [UIButton setUpButtons:self.bothSexesButton];
        [UIButton setUpButtons:self.suggestionsButton];
        [UIButton setUpButtons:self.emptyImageButton];
        [UIButton setUpButtons:self.continueButton];
        [UITextView setup:self.textViewAboutMe];

        self.notValidImageLabel.hidden = YES;

        //set age slider values MIN
        NSString *minAge = [NSString stringWithFormat:@"Minimum Age: %.f", self.minAgeSlider.value];
        self.minAgeLabel.text = minAge;
        NSString *minAgeStr = [NSString stringWithFormat:@"%.f", self.minAgeSlider.value];
        [self.currentUser setObject:minAgeStr forKey:@"minAge"];
        //Max
        NSString *maxAge = [NSString stringWithFormat:@"Maximum Age: %.f", self.maxAgeSlider.value];
        self.maxAgeLabel.text = maxAge;
        NSString *maxAgeStr = [NSString stringWithFormat:@"%.f", self.maxAgeSlider.value];
        [self.currentUser setObject:maxAgeStr forKey:@"maxAge"];

        //distance away slider initial
        NSString *milesAwayStr = [NSString stringWithFormat:@"%.f", self.milesSlider.value];
        NSString *milesAway = [NSString stringWithFormat:@"Show results within %@ miles of here", milesAwayStr];
        self.milesAwayLabel.text = milesAway;
        [self.currentUser setObject:milesAwayStr forKey:@"milesAway"];

        [self.currentUser setObject:@"public" forKey:@"publicProfile"];
        //save default data
//        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//
//            if (error)
//            {
//                NSLog(@"error: %@", error.description);
//            }
//        }];
    }

    else
    {
        NSLog(@"no User logged in");
    }

}

-(void)viewDidAppear:(BOOL)animated
{

    if (self.currentUser)
        {
            self.manager = [FacebookManager new];
            self.manager.facebookNetworker = [FacebookNetwork new];
            self.manager.facebookNetworker.delegate = self.manager;

            self.manager.delegate = self;
            [self.manager loadParsedFacebookThumbnails];
        }
        else
        {
            NSLog(@"no user for face request");
        }
    

    //sexPref Buttons
//    if ([self.userGender isEqualToString:@"male"])
//    {
//        self.womensInterestButton.backgroundColor = [UIColor blackColor];
//        [self.currentUser setObject:@"female" forKey:@"sexPref"];
//        [self.currentUser saveInBackground];
//    }
//    else if ([self.userGender isEqualToString:@"female"])
//    {
//        self.mensInterestButton.backgroundColor = [UIColor blackColor];
//        [self.currentUser setObject:@"male" forKey:@"sexPref"];
//        [self.currentUser saveInBackground];
//    }
//    else
//    {
//        NSLog(@"no data for sex pref");
//    }

    //aboutMe TextView Populated
    NSString *aboutMeDescription = [self.currentUser objectForKey:@"aboutMe"];
    if (aboutMeDescription)
    {
        self.textViewAboutMe.text = aboutMeDescription;
    }

    [self.spinner stopAnimating];
    self.loadingLabel.hidden = YES;
    self.loadingView.hidden = YES;
    self.spinner.hidden = YES;
}

#pragma mark -- CLLOCATION
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //current location
    CLLocation *currentLocation = [locations firstObject];
    //NSLog(@"array of cuurent locations: %@", locations);
    double latitude = self.locationManager.location.coordinate.latitude;
    double longitude = self.locationManager.location.coordinate.longitude;

    [self.locationManager stopUpdatingLocation];

    NSString *latitudeStr = [NSString stringWithFormat:@"%f", latitude];
    NSString *longStr = [NSString stringWithFormat:@"%f", longitude];

    //save location in latitude and longitude
    [self.currentUser setObject:latitudeStr forKey:@"latitude"];
    [self.currentUser setObject:longStr forKey:@"longitude"];
    [self.currentUser saveInBackground];

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
            self.locationlabel.text = [NSString stringWithFormat:@"%@, %@", city, state];
        }
    }];
}


- (IBAction)onEmptyImagesFromParse:(UIButton *)sender
{
    [self.currentUser removeObjectForKey:@"image1"];
    [self.currentUser removeObjectForKey:@"image2"];
    [self.currentUser removeObjectForKey:@"image3"];
    [self.currentUser removeObjectForKey:@"image4"];
    [self.currentUser removeObjectForKey:@"image5"];
    [self.currentUser removeObjectForKey:@"image6"];
    [self.currentUser saveInBackground];
}


#pragma mark -- TEXTVIEW DELEGATE
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewDidBeginEditing");
    //clears text set as instructions
    [textView setText:@""];
    textView.backgroundColor = [UIColor greenColor];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"textViewDidEndEditing: %@", textView);

   // NSString *aboutMeDescr = textView.text;
//    [self.currentUser setObject:aboutMeDescr forKey:@"aboutMe"];
//    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
//     {
//
//         if (error)
//         {
//             NSLog(@"cannot save: %@", error.description);
//         }
//         else
//         {
//             NSLog(@"saved successful: %s", succeeded ? "true" : "false");
//         }
//     }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;

    if (textView.text.length + text.length > 280)
    {
        if (location != NSNotFound)
        {
            [textView resignFirstResponder];
            NSLog(@"editing: %@", text);
        }
        return NO;
    }
    else if (location != NSNotFound)
    {
        [textView resignFirstResponder];
        NSLog(@"text from shouldChangeInRange: %@", text);

        return NO;
    }
    return YES;
}
//
//- (void)textViewDidChange:(UITextView *)textView
//{
//    NSLog(@"textViewDidChange:");
//
//    NSLog(@"text: %@", textView.text);
//}

- (IBAction)onSuggestionsTapped:(UIButton *)sender
{

    [self performSegueWithIdentifier:@"Suggestions" sender:self];
}

#pragma mark -- COLLECTION VIEW DELEGATE
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.thumbnails.count;
}

-(CVCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cvCell";
    CVCell *cell = (CVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    Facebook *face = [self.thumbnails objectAtIndex:indexPath.item];
    cell.bookImage.image = [UIImage imageWithData:[face stringURLToData:face.thumbURL]];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedImage = [self.thumbnails objectAtIndex:indexPath.item];
    [self.selectedPictures addObject:selectedImage];
    NSLog(@"seleceted image: %@", self.selectedImage);

}

#pragma mark -- AGE SLIDERS
- (IBAction)minSliderChange:(UISlider *)sender
{
    NSString *minAgeStr = [NSString stringWithFormat:@"%.f", self.minAgeSlider.value];
    NSString *minAge = [NSString stringWithFormat:@"Minimum Age: %@", minAgeStr];
    self.minAgeLabel.text = minAge;
    [self.currentUser setObject:minAgeStr forKey:@"minAge"];
    [self.currentUser saveInBackground];
}

- (IBAction)maxSliderChange:(UISlider *)sender
{
    NSString *maxAgeStr = [NSString stringWithFormat:@"%.f", self.maxAgeSlider.value];
    NSString *maxAge = [NSString stringWithFormat:@"Maximum Age: %@", maxAgeStr];
    self.maxAgeLabel.text = maxAge;

    [self.currentUser setObject:maxAgeStr forKey:@"maxAge"];
    [self.currentUser saveInBackground];
}


#pragma mark -- Distance Away Slider
- (IBAction)sliderValueChanged:(UISlider *)sender
{
    NSString *milesAwayStr = [NSString stringWithFormat:@"%.f", self.milesSlider.value];
    NSString *milesAway = [NSString stringWithFormat:@"Show results within %@ miles of here", milesAwayStr];
    self.milesAwayLabel.text = milesAway;

    [self.currentUser setObject:milesAwayStr forKey:@"milesAway"];
    [self.currentUser saveInBackground];
}

#pragma mark -- SEX PREFERENCE
//Sender is the only thing that has been omitted in the helper method, grouping it with the global object
- (IBAction)menInterestButton:(UIButton *)sender
{
    [UIButton changeButtonState:self.mensInterestButton];
    [UIButton changeOtherButton:self.womensInterestButton];
    [UIButton changeOtherButton:self.bothSexesButton];

    [self.currentUser setObject:@"male" forKey:@"sexPref"];
    [self.currentUser saveInBackground];
}
//Womens
- (IBAction)womenInterestButton:(UIButton *)sender
{
    [UIButton changeButtonState:self.womensInterestButton];
    [UIButton changeOtherButton:self.mensInterestButton];
    [UIButton changeOtherButton:self.bothSexesButton];

    [self.currentUser setObject:@"female" forKey:@"sexPref"];
    [self.currentUser saveInBackground];
}
//Both
- (IBAction)bothSexesInterestButton:(UIButton *)sender
{
    [UIButton changeButtonState:self.bothSexesButton];
    [UIButton changeOtherButton:self.womensInterestButton];
    [UIButton changeOtherButton:self.mensInterestButton];

    [self.currentUser setObject:@"male female" forKey:@"sexPref"];
    [self.currentUser saveInBackground];
}

#pragma mark -- SEGUE
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqualToString:@"ChooseImage"])
    {
        ChooseImageInitialViewController *cvc = segue.destinationViewController;
        cvc.imageStr = self.selectedImage;
    }
    else if ([segue.identifier isEqualToString:@"Suggestions"])
    {
        //SuggestionsViewController *svc = segue.destinationViewController;
        //svc.userGender = self.userGender;
    }
}


#pragma mark -- NEXT/PREVIOUS PAGE BUTTONS
-(IBAction)onNextPage:(UIButton *)sender
{
    self.previousButton.hidden = NO;
    // FacebookData *face = [FacebookData new];
    // [face loadNextPrevPage:face.nextPage withPhotoArray:self.pictureArray andCollectionView:self.collectionView];
}

- (IBAction)onPreviousPage:(UIButton *)sender
{
    //FacebookData *face = [FacebookData new];
    //[face loadNextPrevPage:face.previousPage withPhotoArray:self.pictureArray andCollectionView:self.collectionView];
}

- (IBAction)onFacebookAlbums:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"FacebookAlbumsTable" sender:self];
}


#pragma mark -- PUSH NOTIFICATIONS
- (IBAction)pushNotificationsOnOff:(UISwitch *)sender
{
    if ([sender isOn])
    {
        NSLog(@"push notifs are on");
    }
    else
    {
        NSLog(@"push notifs are off");
    }
}

#pragma mark -- FACEBOOK MANAGER DELEGATE
-(void)didReceiveParsedThumbnails:(NSArray *)thumbnails
{
    self.thumbnails = thumbnails;
    [self.collectionView reloadData];
}

-(void)failedToReceiveParsedThumbs:(NSError *)error
{
    NSLog(@"failed to call facebook delegate: %@", error);
}

-(void)didReceiveParsedThumbPaging:(NSArray *)thumbPaging
{
    NSLog(@"paging array from VC: %@", thumbPaging);
    self.nextPages = thumbPaging;

    //PAGE DATA
    if (self.nextPages)
    {
        self.nextButton.hidden = NO;
        //algo in here from UserManager to pull up page two from facebook photos
    }
}

-(void)failedToReceiveParsedThumbPaging:(NSError *)error
{
    NSLog(@"failed to call facebook del for Paging: %@", error);
}
@end





