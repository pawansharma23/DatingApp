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

@interface InitialWalkThroughViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *pictureArray;
@property (strong, nonatomic) NSArray *picArray;
@property (strong, nonatomic) NSMutableArray *selectedPictures;
@property (strong, nonatomic) NSMutableArray *secondSelectedPictures;


//likes
@property (strong, nonatomic) NSMutableArray *likeArray;
@property (strong, nonatomic) NSMutableArray *secondLikeArray;



@property (strong, nonatomic) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UILabel *locationlabel;
@property (weak, nonatomic) IBOutlet UILabel *milesAwayLabel;
@property (weak, nonatomic) IBOutlet UISlider *milesSlider;
@property (weak, nonatomic) IBOutlet UIButton *mensInterestButton;
@property (weak, nonatomic) IBOutlet UIButton *womensInterestButton;
@property (weak, nonatomic) IBOutlet UIButton *bothSexesButton;
@property (weak, nonatomic) IBOutlet UISwitch *publicProfileSwitch;
@property (weak, nonatomic) IBOutlet UITextField *textField;


@end

@implementation InitialWalkThroughViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;


    self.pictureArray = [NSMutableArray new];
    self.selectedPictures = [NSMutableArray new];

    self.currentUser = [PFUser currentUser];
    self.navigationItem.title = @"Initial Setup";

    //grab the facebook data
    [self _loadData];
    [self _loadUserImages];

    //collectionView layout
    self.collectionView.backgroundColor = [UIColor grayColor];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];

    //from CLLocation object
    //self.currentLocation
    self.locationlabel.text = @"West Des Moines, IA";

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
                    if ([sexPref containsString:@"male"]) {
                        self.womensInterestButton.backgroundColor = [UIColor blueColor];
                    } else if ([sexPref containsString:@"female"]){
                        self.mensInterestButton.backgroundColor = [UIColor blueColor];
                    } else {
                        NSLog(@"no data for sex pref");
                    }


        }
    }];

    //M Sex Pref Button setup round edges etc.
    self.mensInterestButton.layer.cornerRadius = 10;
    self.mensInterestButton.clipsToBounds = YES;
    [self.mensInterestButton.layer setBorderWidth:2.0];
    [self.mensInterestButton.layer setBorderColor:[UIColor greenColor].CGColor];
    //F
    self.womensInterestButton.layer.cornerRadius = 10;
    self.womensInterestButton.clipsToBounds = YES;
    [self.womensInterestButton.layer setBorderWidth:2.0];
    [self.womensInterestButton.layer setBorderColor:[UIColor greenColor].CGColor];
    //Both
    self.bothSexesButton.layer.cornerRadius = 10;
    self.bothSexesButton.clipsToBounds = YES;
    [self.bothSexesButton.layer setBorderWidth:2.0];
    [self.bothSexesButton.layer setBorderColor:[UIColor greenColor].CGColor];

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
    [self.currentUser setObject:@"Both" forKey:@"sexPref"];
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

#pragma mark -- public profile switch
- (IBAction)onPublicProfileSwitch:(UISwitch *)sender {
    if ([sender isOn]) {
    [self.currentUser setObject:@"private" forKey:@"publicProfile"];
    [self.currentUser saveInBackground];
    } else{
        [self.currentUser setObject:@"public" forKey:@"publicProfile"];
        [self.currentUser saveInBackground];
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pictureArray.count;
}

-(CVCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"cvCell";
    CVCell *cell = (CVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    //NSLog(@"from inside cellforrow: %@", [self.pictureArray firstObject]);
    UserData *userData = [self.pictureArray objectAtIndex:indexPath.row];
    cell.bookImage.image = [UIImage imageWithData:userData.photosData];
    cell.selectedBackgroundView.backgroundColor = [UIColor blueColor];

    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    NSString *selectedImage = [self.pictureArray objectAtIndex:indexPath.row];
    [self.selectedPictures addObject:selectedImage];
    NSLog(@"selected pic %@", selectedImage);
    //UserData *user = [UserData new];
    NSLog(@"user image array %@", self.selectedPictures);
    //NSLog(@"user image ID: %@", user.photoID);

    self.secondSelectedPictures = [[NSMutableArray alloc]initWithCapacity:[self.selectedPictures count]];

   // NSLog(@"second selected pics: %@", self.secondSelectedPictures);

    for (UserData *photoId in self.selectedPictures) {

        //ID String
        //NSString *photos = photoId.photoID;
        //NSLog(@"photoids: %@", photos);
//        NSArray *imageArray = [self.secondSelectedPictures addObject:photoId];

        //grab image data and convert to nsData object then save nsdata object in Parse
        //            NSLog(@"results: %@", result);
        //            NSArray *images = result[@"images"];
        //            NSDictionary *imageDict = [images firstObject];
        //            NSString *imageSource = imageDict[@"source"];
        //            NSLog(@"source: %@", imageSource);
        //            NSURL *url = [NSURL URLWithString:imageSource];
        //            NSData *data = [NSData dataWithContentsOfURL:url];
        //            self.userImage.image = [UIImage imageWithData:data];
        //also the saving the nsdata object but is it for the 100x100 or the original which we need
        NSData *photoData = photoId.photosData;
        NSLog(@"photoids: %@", photoData);
       // NSURL *urlObie = photoId.photoURL;

        //[self.secondSelectedPictures addObject:photos];

        [self.secondSelectedPictures addObject:photoData];
        //[self.secondSelectedPictures addObject:urlObie];

    [self.currentUser setObject:self.secondSelectedPictures forKey:@"selectedUserImages"];
    [self.currentUser saveInBackground];
    }


}
//layout buffer delegate methods
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return CGSizeMake(100, 100);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{

    return UIEdgeInsetsMake(5, 5, 5, 5);
}



#pragma mark -- facebook profile data load
- (void)_loadData {

    //make FB Graph API request for applicable free data
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, about, birthday, gender, bio, education, is_verified, locale, first_name, work, location, likes, images"} HTTPMethod:@"GET"];
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

                NSLog(@"new shit %@", self.secondLikeArray);
                [self.currentUser setObject:self.secondLikeArray forKey:@"likes"];
                [_currentUser saveInBackground];
            }


            locUser.fullName = fullName;
            locUser.firstName = firstName;
            locUser.birthdayString = birthdayStr;

            //also getting the full image NSData object and passing it Parse
//            NSString *graphPath = [NSString stringWithFormat:@"//%@", self.leadImage];
//            NSString *path = @"/10153744912065061";
//            NSLog(@"print this out: %@", self.leadImage);
//            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
//                                          initWithGraphPath:graphPath
//                                          parameters:@{@"fields": @"id, images"}
//                                          HTTPMethod:@"GET"];
//            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
//                                                  id result,
//                                                  NSError *error) {
//                if (!error) {
//                    NSLog(@"results: %@", result);
//                    NSArray *images = result[@"images"];
//                    NSDictionary *imageDict = [images firstObject];
//                    NSString *imageSource = imageDict[@"source"];
//                    NSLog(@"source: %@", imageSource);
//                    NSURL *url = [NSURL URLWithString:imageSource];
//                    NSData *data = [NSData dataWithContentsOfURL:url];
//                    self.userImage.image = [UIImage imageWithData:data];
//                    //            for (NSString *imageSrc in imageDict) {
//                    //                NSLog(@"orignial pic: %@", [imageSrc containsString:o.jpg]);
//                    //            }
//                } else {
//                    NSLog(@"error: %@", error);
//                }
//            }];

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

        }
    }];

}

#pragma mark -- facebook Image data load
-(void)_loadUserImages{
    //now get images from user's facebook account and display them for user to sift through
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/photos" parameters:@{@"fields": @"picture, updated_time"} HTTPMethod:@"GET"];
    //{@"type": @"tagged, uploaded"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
        NSLog(@"all the data %@", result);
            NSArray *dataArr = result[@"data"];
            NSDictionary *paging = result[@"paging"];
            NSDictionary *cursors = paging[@"cursors"];
            NSString *after = cursors[@"after"];
            NSLog(@"paging after id: %@", after);


            NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataArr];
            NSArray *uniqueArray = [orderedSet array];

            for (NSDictionary *imageData in uniqueArray) {

                //image id and 100X100 thumbnail of image from "picture" field above the nsdata object is for the 100x100 image
                NSString *pictureIds = imageData[@"id"];
                NSString *pictureURL = imageData[@"picture"];
                NSString *updatedtime = imageData[@"updated_time"];
                //image conversion
                NSURL *mainPicURL = [NSURL URLWithString:pictureURL];
                NSData *mainPicData = [NSData dataWithContentsOfURL:mainPicURL];

                UserData *userD = [UserData new];
                userD.photoID = pictureIds;
                userD.photosData = mainPicData;
                userD.photoURL = mainPicURL;

                NSArray *picArray = [NSArray arrayWithObject:mainPicData];
                NSSortDescriptor *sorter = [[NSSortDescriptor alloc]initWithKey:updatedtime ascending:YES];
                NSArray *sortDesc = [NSArray arrayWithObject:sorter];

                self.picArray = [picArray sortedArrayUsingDescriptors:sortDesc];
                [self.pictureArray addObject:userD];


                NSLog(@"facebook id from source: %@", pictureIds);


                [self.collectionView reloadData];
                //NSLog(@"ids %@, urls: %@", pictureIds, pictureURL);
                //NSLog(@"self.picture array: %@", self.pictureArray);

            }


        }
    }];
}

-(NSData *)convertURLToData:(NSURL *)url{

    NSURL *imageURL = url;
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
    return imageData;
}


@end
