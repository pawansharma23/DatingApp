//
//  ProfileViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 12/19/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import "ProfileViewController.h"
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
#import "RangeSlider.h"
#import <MessageUI/MessageUI.h>
#import "CVSettingCell.h"
#import "PreferencesViewController.h"


@interface ProfileViewController ()<MFMailComposeViewControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UITextViewDelegate,
UIScrollViewDelegate>

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSMutableArray *pictures;
@property (weak, nonatomic) IBOutlet UIImageView *appLogo;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *minimumAgeLabel;
@property (weak, nonatomic) IBOutlet UISlider *minimumAgeSlider;
@property (weak, nonatomic) IBOutlet UILabel *maximumAgeLabel;
@property (weak, nonatomic) IBOutlet UISlider *maximumAgeSlider;
@property (weak, nonatomic) IBOutlet UILabel *milesAwayLabel;
@property (weak, nonatomic) IBOutlet UISlider *milesAwaySlider;
@property (weak, nonatomic) IBOutlet UIButton *menButton;
@property (weak, nonatomic) IBOutlet UIButton *womenButton;
@property (weak, nonatomic) IBOutlet UIButton *bothButton;

@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *educationLabel;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UISwitch *publicProfileSwitch;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextView *textViewAboutMe;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.currentUser = [PFUser currentUser];
//    NSString *fullName = [self.currentUser objectForKey:@"fullName"];
//    NSLog(@"current user(ProileVC) VDL: %@", fullName);

    self.scrollView.delegate = self;

    //self.currentUser = self.userFromViewController;
    self.pictures = [NSMutableArray new];
    self.collectionView.delegate = self;
    self.textViewAboutMe.delegate = self;

    NSLog(@"profile VC user: %@", self.currentUser);

    self.navigationItem.title = @"Settings";
    //profile change info added to left side of nav bar
    UIBarButtonItem *leftSideBB = [[UIBarButtonItem alloc]initWithTitle:@"Update Profile" style:UIBarButtonItemStylePlain target:self action:@selector(segueToProfileView)];
    leftSideBB.tintColor = [UIColor colorWithRed:251.0/255.0 green:73.0/255.0 blue:72.0/255.0 alpha:1.0];
    self.navigationItem.rightBarButtonItem = leftSideBB;

    //save the about me
    NSString *aboutMe = self.textViewAboutMe.text;
    NSLog(@"about me: %@", aboutMe);
    [self.currentUser setObject:aboutMe forKey:@"aboutMe"];

    //Buttons Setup
    [self setUpButton:self.menButton];
    [self setUpButton:self.womenButton];
    [self setUpButton:self.bothButton];
    [self setUpButton:self.logoutButton];
    [self setUpButton:self.deleteButton];
    [self setUpButton:self.shareButton];
    [self setUpButton:self.feedbackButton];

    self.textViewAboutMe.layer.cornerRadius = 10;
    [self.textViewAboutMe.layer setBorderWidth:1.0];
    [self.textViewAboutMe.layer setBorderColor:[UIColor grayColor].CGColor];

    //call Parse for User Data
    PFQuery *query = [PFUser query];

    //this is quering the user info from the PFUser cached in sim, which is not the usr that is logged in??
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){

            NSString *name = [[objects firstObject]objectForKey:@"fullName"];
            NSLog(@"name from query: %@", name);
            //miles Away slider
            CGFloat strFloat = (CGFloat)[[[objects firstObject] objectForKey:@"milesAway"] floatValue];
            self.milesAwaySlider.value = strFloat;
            NSString *milesAwayStr = [NSString stringWithFormat:@"Show results within %.f miles of here", strFloat];
            self.milesAwayLabel.text = milesAwayStr;

            //age min and max sliders
            CGFloat strFloatForMinAge = (CGFloat)[[[objects firstObject] objectForKey:@"minAge"] floatValue];
            self.minimumAgeSlider.value = strFloatForMinAge;
            NSString *minAge = [NSString stringWithFormat:@"Minimum Age: %.f", strFloatForMinAge];
            self.minimumAgeLabel.text = minAge;
            //Max
            CGFloat strFloatForMaxAge = (CGFloat)[[[objects firstObject] objectForKey:@"maxAge"] floatValue];
            self.maximumAgeSlider.value = strFloatForMaxAge;
            NSString *maxAge = [NSString stringWithFormat:@"Minimum Age: %.f", strFloatForMaxAge];
            self.maximumAgeLabel.text = maxAge;

            //public profile status
            NSString *pubProf = [[objects firstObject] objectForKey:@"publicProfile"];
            //NSLog(@"switch set to %@", pubProf);
            if ([pubProf containsString:@"public"]) {
                [self.publicProfileSwitch setOn:YES animated:YES];
            } else{
                [self.publicProfileSwitch setOn:NO animated:YES];
            }

            //sex pref presets
            NSString *sexPref = [[objects firstObject] objectForKey:@"sexPref"];
            if ([sexPref containsString:@"M"]) {
                self.menButton.backgroundColor = [UIColor blueColor];
            } else if ([sexPref containsString:@"F"]){
                self.womenButton.backgroundColor = [UIColor blueColor];
            } else if ([sexPref containsString:@"Both"])  {
                self.bothButton.backgroundColor = [UIColor blueColor];
            }else{
            NSLog(@"sex pref: %@", sexPref);
            }

            //
          //  NSArray *likes = [[objects firstObject] objectForKey:@"likes"];
        //NSLog(@"likes array: %@", likes);
            NSString *job = [[objects firstObject] objectForKey:@"work"];
            NSString *school = [[objects firstObject] objectForKey:@"scool"];
            self.jobLabel.text = job;
            self.educationLabel.text = school;

            //userImages
            NSString *image1 = [[objects firstObject] objectForKey:@"image1"];
            NSString *image2 = [[objects firstObject] objectForKey:@"image2"];
            NSString *image3 = [[objects firstObject] objectForKey:@"image3"];
            NSString *image4 = [[objects firstObject] objectForKey:@"image4"];
            NSString *image5 = [[objects firstObject] objectForKey:@"image5"];
            NSString *image6 = [[objects firstObject] objectForKey:@"image6"];
            if (image1) {
                [self.pictures addObject:image1];
            } if (image2) {
                [self.pictures addObject:image2];
            } if (image3) {
                [self.pictures addObject:image3];
            } if (image4) {
                [self.pictures addObject:image4];
            } if (image5) {
                [self.pictures addObject:image5];
            } if (image6) {
                [self.pictures addObject:image6];
            }

            [self.collectionView reloadData];
        }
    }];


}


//1)CollectionView for User Images
#pragma mark -- collectionView delegate Methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pictures.count;
}

-(CVSettingCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"SettingCell";
    CVSettingCell *cell = (CVSettingCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    //UserData *userData = [self.pictures objectAtIndex:indexPath.row];
    NSString *photoString = [self.pictures objectAtIndex:indexPath.row];
    cell.userImage.image = [UIImage imageWithData:[self imageData:photoString]];

    return cell;
}
//save selected images to array and save to Parse
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    //highlight selected cell... not working
    UICollectionViewCell *cell = [collectionView  cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor];
    
}

#pragma mark -- View Elements
//3) Min/Max Ages
- (IBAction)onMinAgeSliderChange:(UISlider *)sender {
    //number to label convert
    NSString *minAgeStr = [NSString stringWithFormat:@"%.f", self.minimumAgeSlider.value];
    NSString *minAge = [NSString stringWithFormat:@"Minimum Age: %@", minAgeStr];
    self.minimumAgeLabel.text = minAge;
    //save to Parse
    [self.currentUser setObject:minAgeStr forKey:@"minAge"];
    [self.currentUser saveInBackground];
    NSLog(@"change min age to: %@", minAge);
}
- (IBAction)onMaxAgeSliderChange:(UISlider *)sender {
    //number to label convert
    NSString *maxAgeStr = [NSString stringWithFormat:@"%.f", self.maximumAgeSlider.value];
    NSString *maxAge = [NSString stringWithFormat:@"Maximum Age: %@", maxAgeStr];
    self.maximumAgeLabel.text = maxAge;
    //save to Parse
    [self.currentUser setObject:maxAgeStr forKey:@"maxAge"];
    [self.currentUser saveInBackground];
    NSLog(@"change min age to: %@", maxAge);
}


// 4) Sex Preference buttons and saving to parse on selection, also deselecting the other two
- (IBAction)onMensButton:(UIButton *)sender {
    [self changeButtonState:self.menButton sexString:@"male" otherButton1:self.womenButton otherButton2:self.bothButton];
}
- (IBAction)onWomensButton:(UIButton *)sender {
    [self changeButtonState:self.womenButton sexString:@"female" otherButton1:self.menButton otherButton2:self.womenButton];
}
- (IBAction)onBothButton:(UIButton *)sender {

    [self changeButtonState:self.bothButton sexString:@"male female" otherButton1:self.menButton otherButton2:self.womenButton];
}


//5) Miles away
- (IBAction)milesAwaySlider:(UISlider *)sender {

    NSString *milesAwayStr = [NSString stringWithFormat:@"%.f", self.milesAwaySlider.value];
    NSString *milesAway = [NSString stringWithFormat:@"Show results within %@ miles of here", milesAwayStr];
    self.milesAwayLabel.text = milesAway;
    [self.currentUser setObject:milesAwayStr forKey:@"milesAway"];
    [self.currentUser saveInBackground];
}


//6)Puublic Profile On/Off
- (IBAction)publicProfileSwitch:(UISwitch *)sender {
    if ([sender isOn]) {
        [self.currentUser setObject:@"public" forKey:@"publicProfile"];
        [self.currentUser saveInBackground];
    } else {
        [self.currentUser setObject:@"private" forKey:@"publicProfile"];
        [self.currentUser saveInBackground];
    }
}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(CVSettingCell *)cell {
//
////
////    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
//    NSString *imageSelected = [self.pictures objectAtIndex:indexPath.row];
////
//    PreferencesViewController *prefVC = segue.destinationViewController;
//    prefVC.image = imageSelected;
//
//}


//highlighting selected collectioView Cell... not working
//-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
//
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor blueColor];
//}





//textView delegates
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.textViewAboutMe.text isEqualToString:@"placeholder text here..."]) {
        self.textViewAboutMe.text = @"";
        self.textViewAboutMe.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.textViewAboutMe.text isEqualToString:@""]) {
        self.textViewAboutMe.text = @"placeholder text here...";
        self.textViewAboutMe.textColor = [UIColor lightGrayColor]; //optional
        NSLog(@"about me: %@", self.textViewAboutMe.text);
    }
    [textView resignFirstResponder];
}





//send an email with the UIMessage framework for feedback
- (IBAction)feedback:(UIButton *)sender {
    //subject line and body of email to send
    NSString *emailTitle = @"Feedback";
    NSString *messageBody = @"message body";
    NSArray *reciepents = [NSArray arrayWithObject:@"michealsevy@gmail.com"];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc]init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
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



-(void)segueToProfileView{
    [self performSegueWithIdentifier:@"ProfileSegue" sender:nil];
}


- (IBAction)logOutButton:(UIButton *)sender {

    if (sender.isSelected) {
        self.logoutButton.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:193.0/255.0 blue:255.0/255.0 alpha:1.0];

    }
    [PFUser logOut];


    //nothing works to unlink the facebok account
    //[PFFacebookUtils unlinkUserInBackground:self.currentUser];

//    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"error unlinking: %@", error);
//        } else{
//            NSLog(@"logged out, no user: %@", self.currentUser);
//        }
//    }];
//
//    NSLog(@"current user: after %@", self.currentUser);

    //[self performSegueWithIdentifier:@"LoggedOut" sender:self];
}


- (IBAction)userViewButton:(UIButton *)sender {
}


#pragma mark -- helpers
-(void)setUpButton:(UIButton *)button{
    button.layer.cornerRadius = 15;
    button.clipsToBounds = YES;
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[UserData rubyRed].CGColor];
}

-(void)borderLabel:(UILabel *)label{
    label.layer.cornerRadius = 10;
    label.clipsToBounds = YES;
    [label.layer setBorderWidth:1.0];
    [label.layer setBorderColor:[UIColor grayColor].CGColor];
}

-(NSData *)imageData:(NSString *)imageString{
    NSURL *url = [NSURL URLWithString:imageString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
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



@end







