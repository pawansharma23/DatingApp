//
//  InitialWalkThroughViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 12/20/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import "InitialWalkThroughViewController.h"
#import <Foundation/Foundation.h>
#import <Bolts/BFTask.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <ParseFacebookUtilsV4.h>
#import <Parse/PFConstants.h>
#import <Parse/PFUser.h>
#import <Parse/Parse.h>
#import <FBSDKGraphRequest.h>
#import <FBSDKGraphRequestConnection.h>
#import "UserData.h"
#import "CVCell.h"
#import "AFNetworking.h"
#import "RangeSlider.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <LXReorderableCollectionViewFlowLayout.h>
#import "ChooseImageInitialViewController.h"
#import "SuggestionsViewController.h"

@interface InitialWalkThroughViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
LXReorderableCollectionViewDelegateFlowLayout,
LXReorderableCollectionViewDataSource,
CLLocationManagerDelegate,
UITextViewDelegate,
UIScrollViewDelegate>
//Misc View Outlets
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *textViewAboutMe;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//sliders
@property (weak, nonatomic) IBOutlet UISlider *minAgeSlider;
@property (weak, nonatomic) IBOutlet UISlider *maxAgeSlider;
@property (weak, nonatomic) IBOutlet UISlider *milesSlider;
//labels
@property (weak, nonatomic) IBOutlet UILabel *minAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationlabel;
@property (weak, nonatomic) IBOutlet UILabel *milesAwayLabel;
//buttons
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

@property (strong, nonatomic) NSMutableArray *pictureArray;
@property (strong, nonatomic) NSArray *picArray;
@property (strong, nonatomic) NSMutableArray *selectedPictures;
@property (strong, nonatomic) NSMutableArray *secondSelectedPictures;
//user images
@property (strong, nonatomic) NSString *nextPageURLString;
@property (strong, nonatomic) NSString *previousPageURLString;
@property (strong, nonatomic) NSString *userGender;
//likes
@property (strong, nonatomic) NSMutableArray *likeArray;
@property (strong, nonatomic) NSMutableArray *secondLikeArray;
@property (strong, nonatomic) NSArray *dataArray;

//image properties
@property (strong, nonatomic) NSString *imageSource1;
@property (strong, nonatomic) NSString *imageSource2;
@property (strong, nonatomic) NSString *imageSource3;
@property (strong, nonatomic) NSString *imageSource4;
@property (strong, nonatomic) NSString *imageSource5;
@property (strong, nonatomic) NSString *imageSource6;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) PFGeoPoint *pfGeoCoded;

@property (strong, nonatomic) NSString *selectedImage;
@property (strong, nonatomic) PFUser *currentUser;
@end

@implementation InitialWalkThroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];
    UserData *userD = [UserData new];

    [self.spinner startAnimating];
    self.loadingView.alpha = .75;
    self.loadingView.layer.cornerRadius = 8;
    self.navigationItem.title = @"Setup";
    self.navigationController.navigationBar.backgroundColor = [UserData yellowGreen];

    self.automaticallyAdjustsScrollViewInsets = NO;

    //set and initialize delegates
    self.scrollView.delegate = self;
    self.textViewAboutMe.delegate = self;
    self.collectionView.delegate = self;
    self.pictureArray = [NSMutableArray new];
    self.selectedPictures = [NSMutableArray new];
    self.previousButton.hidden = YES;


    //grab the facebook data
    [self loadFacebookData];
    [self loadFacebookThumbnails];

    //textview layout
    self.textViewAboutMe.layer.cornerRadius = 10;
    [self.textViewAboutMe.layer setBorderWidth:1.0];
    [self.textViewAboutMe.layer setBorderColor:[UIColor grayColor].CGColor];
    //collectionView layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];


    //location object
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;

    //request permission and update locaiton
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;

    double latitude = self.locationManager.location.coordinate.latitude;
    double longitude = self.locationManager.location.coordinate.longitude;
   // NSLog(@"view did load lat: %f & long: %f", latitude, longitude);

    //save lat and long in a PFGeoCode Object and save to User in Parse
    self.pfGeoCoded = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
    [self.currentUser setObject:self.pfGeoCoded forKey:@"GeoCode"];
    NSLog(@"saved PFGeoCode: %@", self.pfGeoCoded);

    //setup Buttons
    [userD setUpButtons:self.mensInterestButton];
    [userD setUpButtons:self.womensInterestButton];
    [userD setUpButtons:self.bothSexesButton];
    [userD setUpButtons:self.suggestionsButton];
    [userD setUpButtons:self.emptyImageButton];
    [userD setUpButtons:self.continueButton];

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

    //public Profile default to public
    [self.currentUser setObject:@"public" forKey:@"publicProfile"];
    //save default data
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error.description);
        } else{
            NSLog(@"saved: %s", succeeded ? "true" : "false");
        }
    }];

}


-(void)viewDidAppear:(BOOL)animated{
    //sexPref Buttons
    if ([self.userGender isEqualToString:@"male"]) {
        self.womensInterestButton.backgroundColor = [UIColor blackColor];
        //save to Parse
        [self.currentUser setObject:@"female" forKey:@"sexPref"];
        [self.currentUser saveInBackground];

    } else if ([self.userGender isEqualToString:@"female"]){
        self.mensInterestButton.backgroundColor = [UIColor blackColor];
        //save to Parse
        [self.currentUser setObject:@"male" forKey:@"sexPref"];
        [self.currentUser saveInBackground];
    } else {
        NSLog(@"no data for sex pref");
    }

    //aboutMe TextView Populated
    NSString *aboutMeDescription = [self.currentUser objectForKey:@"aboutMe"];
    if (aboutMeDescription) {
    NSLog(@"about me: %@", aboutMeDescription);
        self.textViewAboutMe.text = aboutMeDescription;
    }

    [self.spinner stopAnimating];
    self.loadingLabel.hidden = YES;
    self.loadingView.hidden = YES;
    self.spinner.hidden = YES;
}

#pragma mark -- CLLocation delegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations   {
   // NSLog(@"didUpdateLocations Delegate Method");
        //current location
        CLLocation *currentLocation = [locations firstObject];
        NSLog(@"array of cuurent locations: %@", locations);
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


- (IBAction)onEmptyImagesFromParse:(UIButton *)sender {

    [self.currentUser removeObjectForKey:@"image1"];
    [self.currentUser removeObjectForKey:@"image2"];
    [self.currentUser removeObjectForKey:@"image3"];
    [self.currentUser removeObjectForKey:@"image4"];
    [self.currentUser removeObjectForKey:@"image5"];
    [self.currentUser removeObjectForKey:@"image6"];

    [self.currentUser saveInBackground];
}


//resign keyboard when touch off textView
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"touchesBegan:withEvent:");
//    [self.view endEditing:YES];
//    [super touchesBegan:touches withEvent:event];
//}

#pragma mark -- textView Editing
- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"textViewDidBeginEditing");
    //clears text set as instructions
    [textView setText:@""];
    textView.backgroundColor = [UIColor greenColor];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"textViewDidEndEditing:");
    textView.backgroundColor = [UIColor whiteColor];
    NSString *aboutMeDescr = textView.text;
    NSLog(@"save textView: %@", aboutMeDescr);

    [self.currentUser setObject:aboutMeDescr forKey:@"aboutMe"];

    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"cannot save: %@", error.description);
        } else {
            NSLog(@"saved successful: %s", succeeded ? "true" : "false");
        }
    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;

    if (textView.text.length + text.length > 280){
        if (location != NSNotFound){
            [textView resignFirstResponder];
            NSLog(@"editing: %@", text);
        }
        return NO;
    }
    else if (location != NSNotFound){
        [textView resignFirstResponder];
        NSLog(@"not editing");
        NSLog(@"text from shouldChangeInRange: %@", text);


        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    NSLog(@"textViewDidChange:");

    NSLog(@"text: %@", textView.text);
}

- (IBAction)onSuggestionsTapped:(UIButton *)sender {

    [self performSegueWithIdentifier:@"Suggestions" sender:self];
}


#pragma mark -- age min and max sliders
- (IBAction)minSliderChange:(UISlider *)sender {
    //number to label convert
    NSString *minAgeStr = [NSString stringWithFormat:@"%.f", self.minAgeSlider.value];
    NSString *minAge = [NSString stringWithFormat:@"Minimum Age: %@", minAgeStr];
    self.minAgeLabel.text = minAge;

    //save to Parse
    [self.currentUser setObject:minAgeStr forKey:@"minAge"];
    [self.currentUser saveInBackground];
}
//Max
- (IBAction)maxSliderChange:(UISlider *)sender {
    //number to label convert
    NSString *maxAgeStr = [NSString stringWithFormat:@"%.f", self.maxAgeSlider.value];
    NSString *maxAge = [NSString stringWithFormat:@"Maximum Age: %@", maxAgeStr];
    self.maxAgeLabel.text = maxAge;

    //save to Parse
    [self.currentUser setObject:maxAgeStr forKey:@"maxAge"];
    [self.currentUser saveInBackground];
}


#pragma mark -- Distance Away Slider
- (IBAction)sliderValueChanged:(UISlider *)sender {

        NSString *milesAwayStr = [NSString stringWithFormat:@"%.f", self.milesSlider.value];
        NSString *milesAway = [NSString stringWithFormat:@"Show results within %@ miles of here", milesAwayStr];
        self.milesAwayLabel.text = milesAway;

        [self.currentUser setObject:milesAwayStr forKey:@"milesAway"];
        [self.currentUser saveInBackground];

}

#pragma mark -- Sex preference buttons
//Sender is the only thing that has been omitted in the helper method, grouping it with the global object
- (IBAction)menInterestButton:(UIButton *)sender {
    UserData *userD = [UserData new];
    [userD changeButtonState:self.mensInterestButton];
    [userD changeOtherButton:self.womensInterestButton];
    [userD changeOtherButton:self.bothSexesButton];
    [self.currentUser setObject:@"male" forKey:@"sexPref"];
    [self.currentUser saveInBackground];
}
//Womens
- (IBAction)womenInterestButton:(UIButton *)sender {
    UserData *userD = [UserData new];
    [userD changeButtonState:self.womensInterestButton];
    [userD changeOtherButton:self.mensInterestButton];
    [userD changeOtherButton:self.bothSexesButton];
    [self.currentUser setObject:@"female" forKey:@"sexPref"];
    [self.currentUser saveInBackground];
}
//Both
- (IBAction)bothSexesInterestButton:(UIButton *)sender {
    UserData *userD = [UserData new];
    [userD changeButtonState:self.bothSexesButton];
    [userD changeOtherButton:self.womensInterestButton];
    [userD changeOtherButton:self.mensInterestButton];
    [self.currentUser setObject:@"male female" forKey:@"sexPref"];
    [self.currentUser saveInBackground];
}




#pragma mark -- collectionView delegate Methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pictureArray.count;
}

-(CVCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"cvCell";
    CVCell *cell = (CVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UserData *userData = [self.pictureArray objectAtIndex:indexPath.item];
    cell.bookImage.image = [UIImage imageWithData:userData.photosData];

    return cell;
}
//save selected images to array and save to Parse
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    //highlight selected cell... not working
    CVCell *cell = (CVCell *)[collectionView  cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor];

    NSString *selectedImage = [self.pictureArray objectAtIndex:indexPath.item];
    [self.selectedPictures addObject:selectedImage];
    NSLog(@"seleceted image: %@", self.selectedImage);

    //get original image from 100 x 100 thumbnail...........This Loop does nothing to get the source image, were passing on the same image as the AddImageToProfile View Controller
    for (UserData *photoId in self.selectedPictures) {

        NSString *photos = photoId.photoID;
        // getting the full image url(from FB) from the ID and saving it in Parse
        NSString *graphPath = [NSString stringWithFormat:@"//%@", photos];
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:graphPath parameters:@{@"fields": @"images"}HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                              id result,
                                              NSError *error) {
            if (!error) {
               // NSLog(@"results: %@", result);
                //save image URL Strings to Parse
                NSArray *images = result[@"images"];
                NSDictionary *imageDict = [images firstObject];
                NSString *imageSource = imageDict[@"source"];
                NSLog(@"image selected: %@", imageSource);

                self.selectedImage = imageSource;
                //segue
                [self performSegueWithIdentifier:@"ChooseImage" sender:self];

            } else {
                self.notValidImageLabel.hidden = NO;
                self.nextButton.hidden = YES;
                self.previousButton.hidden = YES;
                self.facebookAlbumBUtton.hidden = NO;
                }
        }];
    }
}

#pragma mark -- Segue delegate
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"ChooseImage"]) {
        ChooseImageInitialViewController *cvc = segue.destinationViewController;
        cvc.imageStr = self.selectedImage;
    } else if ([segue.identifier isEqualToString:@"Suggestions"]){
        SuggestionsViewController *svc = segue.destinationViewController;
        svc.userGender = self.userGender;
    }
}


#pragma mark -- next page

-(IBAction)onNextPage:(UIButton *)sender {

    self.previousButton.hidden = NO;
    [self onNextPrevPage:self.nextPageURLString];

}

- (IBAction)onPreviousPage:(UIButton *)sender {

    [self onNextPrevPage:self.previousPageURLString];
}

- (IBAction)onFacebookAlbums:(UIButton *)sender {
    [self performSegueWithIdentifier:@"FacebookAlbumsTable" sender:self];
}


#pragma mark -- push notifications
- (IBAction)pushNotificationsOnOff:(UISwitch *)sender {

    if ([sender isOn]) {
        NSLog(@"push notifs are on");
    } else {
        NSLog(@"push notifs are off");
    }
}


#pragma mark -- load data
-(void)loadFacebookThumbnails{

    //now get images from user's facebook account and display them for user to sift through
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/photos/uploaded" parameters:@{@"fields": @"picture, updated_time"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
            //NSLog(@"image data %@", result);
            NSArray *dataArr = result[@"data"];
            //next/previous page results
            NSDictionary *paging = result[@"paging"];
            if (paging[@"next"] == nil) {
                self.nextButton.hidden = YES;
            }
            if (dataArr) {
                self.nextPageURLString = paging[@"next"];

                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataArr];
                NSArray *uniqueArray = [orderedSet array];

                for (NSDictionary *imageData in uniqueArray) {

                    //image id and 100X100 thumbnail of image from "picture" field above the nsdata object is for the 100x100 image
                    NSString *pictureIds = imageData[@"id"];
                    NSString *pictureURL = imageData[@"picture"];
                    // NSString *updatedtime = imageData[@"updated_time"];
                    //image conversion
                    NSURL *mainPicURL = [NSURL URLWithString:pictureURL];
                    NSData *mainPicData = [NSData dataWithContentsOfURL:mainPicURL];

                    UserData *userD = [UserData new];
                    userD.photoID = pictureIds;
                    userD.photosData = mainPicData;
                    userD.photoURL = mainPicURL;

                    [self.pictureArray addObject:userD];
                    [self.collectionView reloadData];
                }
            } else{
                NSLog(@"no images");
            }

        } else{
            NSLog(@"error getting faceboko images: %@", error);
        }
    }];


}

- (void)loadFacebookData {

    self.currentUser = [PFUser currentUser];
    //NSLog(@"current user from Data load: %@", self.currentUser);

    //make FB Graph API request for applicable free data
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, about, birthday, gender, bio, education, is_verified, locale, first_name, work, location, likes"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            //dictionary of data returned from FB
            NSDictionary *userData = (NSDictionary *)result;

            //Parse through the data and save needed bits to Parse backend & to local for Gender
            NSString *facebookID = userData[@"id"];
            NSString *fullName = userData[@"name"];
            NSString *firstName = userData[@"first_name"];
            NSString *birthdayStr = userData[@"birthday"];
            NSString *gender = userData[@"gender"];
            self.userGender = gender;

            NSString *location = userData[@"location"][@"name"];
            //work array
            NSArray *workArray = userData[@"work"];
            NSDictionary *employerDict = [workArray lastObject];
            NSString *placeOfWork = employerDict[@"employer"][@"name"];
            //education array
            NSArray *educationArray = userData[@"education"];
            NSDictionary *schoolDict = [educationArray lastObject];
            NSString *school = schoolDict[@"school"][@"name"];

            UserData *locUser = [UserData new];

            //likes array saved in parse as an array
            NSDictionary *likes = userData[@"likes"];

            if (likes) {
            NSArray *likeArray = likes[@"data"];

            self.secondLikeArray = [[NSMutableArray alloc] initWithCapacity:[likeArray count]];

            for (NSDictionary *like in likeArray) {

                NSArray *likes = [like objectForKey:@"name"];
                [self.secondLikeArray addObject:likes];

                [self.currentUser setObject:self.secondLikeArray forKey:@"likes"];
                [_currentUser saveInBackground];
            }

                } else{
                    NSLog(@"no likes: %@", self.secondLikeArray);
                }

            locUser.fullName = fullName;
            locUser.firstName = firstName;
            locUser.birthday = birthdayStr;

            //save users data from FB to Parse
            if (fullName){
                [self.currentUser setObject:fullName forKey:@"fullName"];
            }
            if (firstName) {
                [self.currentUser setObject:firstName forKey:@"firstName"];
            }
            if (facebookID) {
                [self.currentUser setObject:facebookID forKey:@"faceID"];
            }
            if (birthdayStr) {
                [self.currentUser setObject:birthdayStr forKey:@"birthday"];
            }
            if (gender) {
                [self.currentUser setObject:gender forKey:@"gender"];
            }
            if (location) {
                [self.currentUser setObject:location forKey:@"facebookLocation"];
            }
            if (placeOfWork) {
                [self.currentUser setObject:placeOfWork forKey:@"work"];
            }
            if (school) {
                [self.currentUser setObject:school forKey:@"scool"];
            }

            [_currentUser saveInBackground];
            //NSLog(@"saved facebook user data: 1)%@\n2)%@\n3)%@\n4)%@\n5)%@\n6)%@\n7)%@\n8)%@\n", fullName, firstName, facebookID, birthdayStr, gender, location, placeOfWork, school);
        } else {
            NSLog(@"facebook data error: %@", error);
        }
    }];
}


#pragma mark -- Next/Previous Page
-(void)onNextPrevPage:(NSString *)pageURLString {
    NSURL *URL = [NSURL URLWithString:pageURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionDataTask *dTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, NSData *data , NSError * _Nullable error) {

        if (!response) {
            NSLog(@"error: %@", error);
        } else{
            //remove the current images from the collectionview array
            [self.pictureArray removeAllObjects];
            NSDictionary *objects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSArray *dataFromJSON = objects[@"data"];

            //get next and previous urls
            NSDictionary *paging = objects[@"paging"];
            //store em globally
            self.nextPageURLString = paging[@"next"];
            self.previousPageURLString = paging[@"previous"];

            //arrange image array
            NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataFromJSON];
            NSArray *uniqueArray = [orderedSet array];
            //run loop to get images data
            for (NSDictionary *imageData in uniqueArray) {
                NSString *picURLString = imageData[@"picture"];
                //image conversion to NSData and stored in UserData object
                NSURL *mainPicURL = [NSURL URLWithString:picURLString];
                NSData *mainPicData = [NSData dataWithContentsOfURL:mainPicURL];
                // NSString *updatedTime = imageData[@"updated_time"];
                UserData *userD = [UserData new];
                userD.photosData = mainPicData;

                [self.pictureArray addObject:userD];
                [self.collectionView reloadData];
                //pops cursor to the top of the collectionView
                [self.collectionView setContentOffset:CGPointZero animated:YES];
            }
        }
    }];
    
    [dTask resume];
}

@end





