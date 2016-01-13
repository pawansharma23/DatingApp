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


@interface InitialWalkThroughViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
LXReorderableCollectionViewDelegateFlowLayout,
LXReorderableCollectionViewDataSource,
CLLocationManagerDelegate,
UITextViewDelegate,
UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UITextView *textViewAboutMe;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *minAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxAgeLabel;
@property (weak, nonatomic) IBOutlet UISlider *minAgeSlider;
@property (weak, nonatomic) IBOutlet UISlider *maxAgeSlider;
@property (weak, nonatomic) IBOutlet UIButton *mensInterestButton;
@property (weak, nonatomic) IBOutlet UIButton *womensInterestButton;
@property (weak, nonatomic) IBOutlet UIButton *bothSexesButton;

@property (weak, nonatomic) IBOutlet UILabel *locationlabel;
@property (weak, nonatomic) IBOutlet UILabel *milesAwayLabel;
@property (weak, nonatomic) IBOutlet UISlider *milesSlider;

@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet UISwitch *pushNotifications;

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




@end

@implementation InitialWalkThroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];

    self.navigationItem.title = @"Setup";
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:193.0/255.0 blue:255.0/255.0 alpha:1.0];

    //self.automaticallyAdjustsScrollViewInsets = NO;

    //set and initialize delegates
    self.scrollView.delegate = self;
    self.textViewAboutMe.delegate = self;
    self.pictureArray = [NSMutableArray new];
    self.selectedPictures = [NSMutableArray new];


    //grab the facebook data
    [self _loadData];
    [self _loadUserImages];

    //textview layout
    self.textViewAboutMe.layer.cornerRadius = 10;
    [self.textViewAboutMe.layer setBorderWidth:1.0];
    [self.textViewAboutMe.layer setBorderColor:[UIColor grayColor].CGColor];
    //collectionView layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];

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
    [self setUpButtons:self.mensInterestButton];
    [self setUpButtons:self.womensInterestButton];
    [self setUpButtons:self.bothSexesButton];

    self.previousButton.hidden = YES;

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

    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error.description);
        } else{
            NSLog(@"saved: %s", succeeded ? "true" : "false");
        }
    }];

}


-(void)viewDidAppear:(BOOL)animated{

    if ([self.userGender isEqualToString:@"male"]) {
        self.womensInterestButton.backgroundColor = [UIColor blueColor];
        //save to Parse
        [self.currentUser setObject:@"female" forKey:@"sexPref"];
        [self.currentUser saveInBackground];

    } else if ([self.userGender isEqualToString:@"female"]){
        self.mensInterestButton.backgroundColor = [UIColor blueColor];
        //save to Parse
        [self.currentUser setObject:@"male" forKey:@"sexPref"];
        [self.currentUser saveInBackground];
    } else {
        NSLog(@"no data for sex pref");
    }

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

    [self.currentUser setObject:@"" forKey:@"image1"];
    [self.currentUser setObject:@"" forKey:@"image1"];
    [self.currentUser setObject:@"" forKey:@"image1"];
    [self.currentUser setObject:@"" forKey:@"image1"];
    [self.currentUser setObject:@"" forKey:@"image1"];
    [self.currentUser setObject:@"" forKey:@"image1"];


    [self.currentUser saveInBackground];
}


//resign keyboard when touch off textView
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"touchesBegan:withEvent:");
//    [self.view endEditing:YES];
//    [super touchesBegan:touches withEvent:event];
//}


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

    [self changeButtonState:self.mensInterestButton sexString:@"male" otherButton1:self.womensInterestButton otherButton2:self.bothSexesButton];
}

//Womens
- (IBAction)womenInterestButton:(UIButton *)sender {

    [self changeButtonState:self.womensInterestButton sexString:@"female" otherButton1:self.mensInterestButton otherButton2:self.bothSexesButton];
}

//Both
- (IBAction)bothSexesInterestButton:(UIButton *)sender {

    [self changeButtonState:self.bothSexesButton sexString:@"male female" otherButton1:self.mensInterestButton otherButton2:self.womensInterestButton];

}




#pragma mark -- collectionView delegate Methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pictureArray.count;
}

-(CVCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"cvCell";
    CVCell *cell = (CVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UserData *userData = [self.pictureArray objectAtIndex:indexPath.row];
    cell.bookImage.image = [UIImage imageWithData:userData.photosData];

    return cell;
}
//save selected images to array and save to Parse
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    //highlight selected cell... not working
    UICollectionViewCell *cell = [collectionView  cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor];

    NSString *selectedImage = [self.pictureArray objectAtIndex:indexPath.row];
    [self.selectedPictures addObject:selectedImage];

    for (UserData *photoId in self.selectedPictures) {
        //image url string
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
                [self performSegueWithIdentifier:@"chooseImage" sender:self];

            } else {
                NSLog(@"error: %@", error);
                }
        }];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"chooseImage"]) {
        //NSLog(@"correct segue");
        ChooseImageInitialViewController *cvc = segue.destinationViewController;
        cvc.imageStr = self.selectedImage;
        cvc.currentUser = self.currentUser;
    }


}




-(IBAction)onNextPage:(UIButton *)sender {

    self.previousButton.hidden = NO;
    [self onNextPrevPage:self.nextPageURLString];
}

- (IBAction)onPreviousPage:(UIButton *)sender {

    [self onNextPrevPage:self.previousPageURLString];
}



#pragma mark -- push notifications
- (IBAction)pushNotificationsOnOff:(UISwitch *)sender {

    if ([sender isOn]) {
        NSLog(@"push notifs are on");
    } else {
        NSLog(@"push notifs are off");
    }
}


#pragma mark -- helpers
-(void)setUpButtons:(UIButton *)button{
    button.layer.cornerRadius = 15;
    button.clipsToBounds = YES;
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[UIColor greenColor].CGColor];

}

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
            //NSLog(@"objects: %@", objects);
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

- (void)_loadData {

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
            locUser.birthdayString = birthdayStr;

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

-(void)_loadUserImages{

    //self.currentUser = [PFUser currentUser];
    //NSLog(@"current user from Load User Images: %@", self.currentUser);

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


-(void)changeButtonState:(UIButton *)button sexString:(NSString *)sex otherButton1:(UIButton *)b1 otherButton2:(UIButton *)b2    {

    button.backgroundColor = [UIColor blueColor];
    [self.currentUser setObject:sex forKey:@"sexPref"];
    [self.currentUser saveInBackground];

    if ([button isSelected]) {
        [button setSelected:NO];
        button.backgroundColor = [UIColor whiteColor];
    } else{
        //change other two buttons to delected
        [button setSelected:YES];
        [b1 setSelected:NO];
        [b2 setSelected:NO];
        b1.backgroundColor = [UIColor whiteColor];
        b2.backgroundColor = [UIColor whiteColor];
    }
}


//old next page data
//NSURL *URL = [NSURL URLWithString:self.nextPageURLString];
//NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//
//manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//NSURLSessionDataTask *dTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, NSData *data , NSError * _Nullable error) {
//
//    if (!response) {
//        NSLog(@"error: %@", error);
//    } else{
//        [self.pictureArray removeAllObjects];
//
//        NSDictionary *objects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        NSArray *dataFromJSON = objects[@"data"];
//        NSDictionary *paging = objects[@"paging"];
//        NSLog(@"objects: %@", objects);
//
//        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataFromJSON];
//        NSArray *uniqueArray = [orderedSet array];
//
//        for (NSDictionary *imageData in uniqueArray) {
//            NSString *picURLString = imageData[@"picture"];
//
//            //image conversion to NSData and stored in UserData object
//            NSURL *mainPicURL = [NSURL URLWithString:picURLString];
//            NSData *mainPicData = [NSData dataWithContentsOfURL:mainPicURL];
//            // NSString *updatedTime = imageData[@"updated_time"];
//            UserData *userD = [UserData new];
//            userD.photosData = mainPicData;
//
//            [self.pictureArray addObject:userD];
//
//            [self.collectionView reloadData];
//            [self.collectionView setContentOffset:CGPointZero animated:YES];
//
//
//        }
//
//        self.nextPageURLString = paging[@"next"];
//        self.previousPageURLString = paging[@"previous"];
//    }
//
//}];
//
//[dTask resume];




@end





