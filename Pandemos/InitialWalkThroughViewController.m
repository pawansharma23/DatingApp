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

@interface InitialWalkThroughViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//deprecated user image with array
@property (strong, nonatomic) NSMutableArray *pictureArray;
@property (strong, nonatomic) NSArray *picArray;
@property (strong, nonatomic) NSMutableArray *selectedPictures;
@property (strong, nonatomic) NSMutableArray *secondSelectedPictures;
//user images
@property (strong, nonatomic) NSData *imageDataGlob;
@property (strong, nonatomic) NSString  *imageIDGlobal;
@property (strong, nonatomic) NSURL  *imageURL;
@property (strong, nonatomic) NSString *nextPageURLString;
@property (strong, nonatomic) NSString *previousPageURLString;



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

//view properties
@property (weak, nonatomic) IBOutlet UILabel *locationlabel;
@property (weak, nonatomic) IBOutlet UILabel *milesAwayLabel;
@property (weak, nonatomic) IBOutlet UISlider *milesSlider;
@property (weak, nonatomic) IBOutlet UIButton *mensInterestButton;
@property (weak, nonatomic) IBOutlet UIButton *womensInterestButton;
@property (weak, nonatomic) IBOutlet UIButton *bothSexesButton;
@property (weak, nonatomic) IBOutlet UISwitch *publicProfileSwitch;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;


@end

@implementation InitialWalkThroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"hellllllo");




    self.navigationItem.title = @"Initial Setup";



    self.automaticallyAdjustsScrollViewInsets = NO;


    self.pictureArray = [NSMutableArray new];
    self.selectedPictures = [NSMutableArray new];

    self.currentUser = [PFUser currentUser];
    NSLog(@"current user: %@", self.currentUser);


    //grab the facebook data
    [self _loadData];
    [self _loadUserImages];

    //collectionView layout
    //self.collectionView.backgroundColor = [UIColor grayColor];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];

    //from CLLocation object
    //self.currentLocation
    self.locationlabel.text = @"West Des Moines, IA";
    //suggestion segue for user "about me"
    UIButton *suggestions = [[UIButton alloc]init];
    [suggestions setTitle:@"help with description" forState:UIControlStateNormal];
    [self.textField addSubview:suggestions];
   // [self.textField addConstraint:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[suggestions]-|"
     //                                                                     options:NSLayoutAttributeLeading metrics:nil views:NSDictionaryOfVariableBindings(suggestions)]];



    //set miles away slider from Parse
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){
            CGFloat strFloat = (CGFloat)[[[objects firstObject] objectForKey:@"milesAway"] floatValue];

            self.milesSlider.value = strFloat;
            NSString *milesAwayStr = [NSString stringWithFormat:@"Show results within %.f miles of here", strFloat];
            self.milesAwayLabel.text = milesAwayStr;
            //sex pref presets
            NSString *sexPref = [[objects firstObject] objectForKey:@"gender"];
            NSLog(@"user sex is: %@", sexPref);
                    if ([sexPref containsString:@"male"]) {
                        self.womensInterestButton.backgroundColor = [UIColor blueColor];
                    } else if ([sexPref containsString:@"female"]){
                        self.mensInterestButton.backgroundColor = [UIColor blueColor];
                    } else {
                        NSLog(@"no data for sex pref");
                    }
        }
        NSString *name = [[objects firstObject] objectForKey:@"firstName"];

        NSLog(@"user name from parse: %@", name);

    }];

    //M Sex Pref Button setup round edges etc.
    self.mensInterestButton.layer.cornerRadius = 15;
    self.mensInterestButton.clipsToBounds = YES;
    [self.mensInterestButton.layer setBorderWidth:1.0];
    [self.mensInterestButton.layer setBorderColor:[UIColor greenColor].CGColor];
    //F
    self.womensInterestButton.layer.cornerRadius = 15;
    self.womensInterestButton.clipsToBounds = YES;
    [self.womensInterestButton.layer setBorderWidth:1.0];
    [self.womensInterestButton.layer setBorderColor:[UIColor greenColor].CGColor];
    //Both
    self.bothSexesButton.layer.cornerRadius = 15;
    self.bothSexesButton.clipsToBounds = YES;
    [self.bothSexesButton.layer setBorderWidth:1.0];
    [self.bothSexesButton.layer setBorderColor:[UIColor greenColor].CGColor];

    self.previousButton.hidden = YES;

}


-(void)viewDidAppear:(BOOL)animated{

    UIScrollView *scrollView;
    UIView *contentView;
    [scrollView addSubview:contentView];
    scrollView.contentSize = contentView.frame.size;
    [scrollView setScrollEnabled:YES];
}

#pragma mark -- miles away range
- (IBAction)sliderValueChanged:(UISlider *)sender {

        NSString *milesAwayStr = [NSString stringWithFormat:@"%.f", self.milesSlider.value];
        NSString *milesAway = [NSString stringWithFormat:@"Show results within %@ miles of here", milesAwayStr];
        self.milesAwayLabel.text = milesAway;

        [self.currentUser setObject:milesAwayStr forKey:@"milesAway"];
        [self.currentUser saveInBackground];

}

#pragma mark -- sex preference buttons
//Sex Preference buttons and saving to parse on selection, also deselecting the other two
- (IBAction)menInterestButton:(UIButton *)sender {
    self.mensInterestButton.backgroundColor = [UIColor blueColor];
    [self.currentUser setObject:@"M" forKey:@"sexPref"];
    [self.currentUser saveInBackground];
    if ([sender isSelected]) {
        [sender setSelected:NO];
        self.mensInterestButton.backgroundColor = [UIColor whiteColor];
    } else{
        [sender setSelected:YES];
        [self.womensInterestButton setSelected:NO];
        [self.bothSexesButton setSelected:NO];
        self.womensInterestButton.backgroundColor = [UIColor whiteColor];
        self.bothSexesButton.backgroundColor = [UIColor whiteColor];
    }
}
//Womens
- (IBAction)womenInterestButton:(UIButton *)sender {
    self.womensInterestButton.backgroundColor = [UIColor blueColor];
    [self.currentUser setObject:@"F" forKey:@"sexPref"];
    [self.currentUser saveInBackground];
    if ([sender isSelected]) {
        [sender setSelected:NO];
        self.womensInterestButton.backgroundColor = [UIColor whiteColor];
    } else{
        [sender setSelected:YES];
        [self.mensInterestButton setSelected:NO];
        [self.bothSexesButton setSelected:NO];
        self.mensInterestButton.backgroundColor = [UIColor whiteColor];
        self.bothSexesButton.backgroundColor = [UIColor whiteColor];
    }
}
//Both
- (IBAction)bothSexesInterestButton:(UIButton *)sender {
    self.bothSexesButton.backgroundColor = [UIColor blueColor];
    [self.currentUser setObject:@"MF" forKey:@"sexPref"];
    [self.currentUser saveInBackground];
    if ([sender isSelected]) {
        [sender setSelected:NO];
        self.bothSexesButton.backgroundColor = [UIColor whiteColor];
    } else{
        [sender setSelected:YES];
        [self.mensInterestButton setSelected:NO];
        [self.womensInterestButton setSelected:NO];
        self.mensInterestButton.backgroundColor = [UIColor whiteColor];
        self.womensInterestButton.backgroundColor = [UIColor whiteColor];
    }
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
//didSelectItemAtIndexPath
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    //highlight selected cell... not working
    UICollectionViewCell* cell = [collectionView  cellForItemAtIndexPath:indexPath];
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

                if (!self.imageSource1) {
                    self.imageSource1 = imageSource;
                    [self.currentUser setObject:imageSource forKey:@"image1"];
                    [self.currentUser saveInBackground];
                    NSLog(@"first saved in image1 %@", imageSource);


                } else if (self.imageSource1 && !self.imageSource2){
                    NSLog(@"2nd Saved %@", imageSource);
                    self.imageSource2 = imageSource;
                    [self.currentUser setObject:imageSource forKey:@"image2"];
                    [self.currentUser saveInBackground];
                    //3
                } else if(self.imageSource1 && self.imageSource2 && !self.imageSource3){
                    NSLog(@"3rd Saved %@", imageSource);
                    self.imageSource3 = imageSource;
                    [self.currentUser setObject:imageSource forKey:@"image3"];
                    [self.currentUser saveInBackground];
                    //4
                } else if (self.imageSource1 && self.imageSource2 && self.imageSource3 && !self.imageSource4){
                    NSLog(@"4th Saved %@", imageSource);
                    self.imageSource4 = imageSource;
                    [self.currentUser setObject:imageSource forKey:@"image4"];
                    [self.currentUser saveInBackground];
                    //5
                } else if (self.imageSource1 && self.imageSource2 && self.imageSource3 && self.imageSource4 && !self.imageSource5){
                    NSLog(@"5th Saved %@", imageSource);
                    self.imageSource5 = imageSource;
                    [self.currentUser setObject:imageSource forKey:@"image5"];
                    [self.currentUser saveInBackground];
                } else if (self.imageSource1 && self.imageSource2 && self.imageSource3 && self.imageSource4 && self.imageSource5 && !self.imageSource6){
                    NSLog(@"6th Saved %@", imageSource);
                    self.imageSource6 = imageSource;
                    [self.currentUser setObject:imageSource forKey:@"image6"];
                    [self.currentUser saveInBackground];
                } else{
                    NSLog(@"all images are filled");
                }

            } else {
                NSLog(@"error: %@", error);
                }
        }];
    }
}
//highlighting selected collectioView Cell... not working
-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor];
}


- (IBAction)onNextPage:(UIButton *)sender {

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
#pragma mark -- previous/next page
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
            NSLog(@"objects: %@", objects);
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

#pragma mark -- facebook profile data load
- (void)_loadData {

    //make FB Graph API request for applicable free data
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, about, birthday, gender, bio, education, is_verified, locale, first_name, work, location, likes"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            //dictionary of data returned from FB
            NSDictionary *userData = (NSDictionary *)result;
             NSLog(@"dictionary of results: %@", userData);
            
            //Parse through the data and save needed bits to Parse backend
            NSString *facebookID = userData[@"id"];
            //BOOL isVerified = userData[@"is_verified"];
            NSString *fullName = userData[@"name"];
            NSString *firstName = userData[@"first_name"];
            NSString *birthdayStr = userData[@"birthday"];
            NSString *gender = userData[@"gender"];
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
            NSArray *likeArray = likes[@"data"];

            self.secondLikeArray = [[NSMutableArray alloc] initWithCapacity:[likeArray count]];

            for (NSDictionary *like in likeArray) {

                NSArray *likes = [like objectForKey:@"name"];
                [self.secondLikeArray addObject:likes];

                NSLog(@"like array: %@", self.secondLikeArray);
                [self.currentUser setObject:self.secondLikeArray forKey:@"likes"];
                [_currentUser saveInBackground];
            }

            locUser.fullName = fullName;
            locUser.firstName = firstName;
            locUser.birthdayString = birthdayStr;

            //save users data from FB to Parse
            [self.currentUser setObject:fullName forKey:@"fullName"];
            [self.currentUser setObject:firstName forKey:@"firstName"];
            [self.currentUser setObject:facebookID forKey:@"faceID"];
            [self.currentUser setObject:birthdayStr forKey:@"birthday"];
            [self.currentUser setObject:gender forKey:@"gender"];
            [self.currentUser setObject:location forKey:@"facebookLocation"];
            [self.currentUser setObject:placeOfWork forKey:@"work"];
            [self.currentUser setObject:school forKey:@"scool"];

            [_currentUser saveInBackground];

        } else {
            NSLog(@"getting facebook data: %@", error);
        }
    }];

}

#pragma mark -- facebook Image data load
-(void)_loadUserImages{
    //now get images from user's facebook account and display them for user to sift through
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/photos/uploaded" parameters:@{@"fields": @"picture, updated_time"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
        NSLog(@"image data %@", result);
            NSArray *dataArr = result[@"data"];
            //next/previous page results
            NSDictionary *paging = result[@"paging"];
            self.nextPageURLString = paging[@"next"];
            if (paging[@"next"] == nil) {
                self.nextButton.hidden = YES;
            }

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
                NSLog(@"pic ids: %@", pictureIds);
//                NSArray *picArray = [NSArray arrayWithObject:mainPicData];
//                NSSortDescriptor *sorter = [[NSSortDescriptor alloc]initWithKey:updatedtime ascending:YES];
//                NSArray *sortDesc = [NSArray arrayWithObject:sorter];
//
//                self.picArray = [picArray sortedArrayUsingDescriptors:sortDesc];

                [self.pictureArray addObject:userD];

               // NSLog(@"facebook id from source: %@", pictureIds);

                [self.collectionView reloadData];

            }
        } else{
            NSLog(@"error getting faceboko images: %@", error);
        }
    }];
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





