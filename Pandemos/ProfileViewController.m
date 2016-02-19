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
#import <LXReorderableCollectionViewFlowLayout.h>

@interface ProfileViewController ()<MFMailComposeViewControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UITextViewDelegate,
UIScrollViewDelegate,
UICollectionViewDelegateFlowLayout,
LXReorderableCollectionViewDelegateFlowLayout,
LXReorderableCollectionViewDataSource,
UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSMutableArray *pictures;
@property (weak, nonatomic) IBOutlet UIImageView *appLogo;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *minimumAgeLabel;
@property (weak, nonatomic) IBOutlet UISlider *minimumAgeSlider;
@property (weak, nonatomic) IBOutlet UILabel *maximumAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
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
@property (strong, nonatomic) IBOutlet UITextView *textViewAboutMe;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

@property (strong, nonatomic) NSString *textViewString;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];
    //NSLog(@"profile VC user: %@", self.currentUser);
    self.navigationItem.title = @"Settings";
    self.navigationController.navigationBar.barTintColor = [UserData yellowGreen];
    //retrieve and pass segue properties
    self.locationLabel.text = self.cityAndState;
    //loading view
    self.loadingView.alpha = .75;
    self.loadingView.layer.cornerRadius = 8;
    [self.spinner startAnimating];

    //UIBarButtonItem *previewYourProfile = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(segueAction)];
    //self.navigationController.navigationItem.rightBarButtonItem = previewYourProfile;
    //self.navigationController.navigationItem.rightBarButtonItem.title = @"this is it";

    //UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithTitle:@"Preview" style:UIBarButtonItemStylePlain target:self action:@selector(segueAction)];
    //self.navigationItem.rightBarButtonItem = newButton;
    UIBarButtonItem *newest = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(segueAction)];
    self.navigationItem.rightBarButtonItem = newest;

    self.automaticallyAdjustsScrollViewInsets = NO;

    //delegation, initialization
    self.scrollView.delegate = self;
    self.collectionView.delegate = self;
    self.pictures = [NSMutableArray new];
    self.textViewAboutMe.delegate = self;

    //collection view
    self.collectionView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor grayColor]);
    self.collectionView.layer.borderWidth = 1.0;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    LXReorderableCollectionViewFlowLayout *flowlayouts = [LXReorderableCollectionViewFlowLayout new];
    [flowlayouts setItemSize:CGSizeMake(100, 100)];
//    flowlayouts.minimumInteritemSpacing = 2;


    [flowlayouts setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowlayouts.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);//buffer in: top, left, bottom, right format
    [self.collectionView setCollectionViewLayout:flowlayouts];
    self.collectionView.backgroundColor = [UIColor whiteColor];

    //Buttons Setup
    UserData *userD = [UserData new];
    [userD setUpButtons:self.menButton];
    [userD setUpButtons:self.womenButton];
    [userD setUpButtons:self.bothButton];
    [userD setUpButtons:self.logoutButton];
    [userD setUpButtons:self.deleteButton];
    [userD setUpButtons:self.shareButton];
    [userD setUpButtons:self.feedbackButton];

    self.textViewAboutMe.layer.cornerRadius = 10;
    [self.textViewAboutMe.layer setBorderWidth:1.0];
    [self.textViewAboutMe.layer setBorderColor:[UIColor grayColor].CGColor];

    //textView


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
            NSLog(@"switch set to: %@", pubProf);
            if ([pubProf containsString:@"public"]) {
                [self.publicProfileSwitch setOn:YES animated:YES];
            } else{
                [self.publicProfileSwitch setOn:NO animated:YES];
            }

            //sex pref presets
            NSString *sexPref = [[objects firstObject] objectForKey:@"sexPref"];

            if ([sexPref isEqualToString:@"male"]) {
                self.menButton.backgroundColor = [UIColor blackColor];
                [self.menButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else if ([sexPref isEqualToString:@"female"]){
                self.womenButton.backgroundColor = [UIColor blackColor];
                [self.womenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else if ([sexPref isEqualToString:@"male female"])  {
                self.bothButton.backgroundColor = [UIColor blackColor];
                [self.bothButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }else{
            NSLog(@"sex pref: %@", sexPref);
            }


            //textView output
            NSString *textView = [[objects firstObject]objectForKey:@"aboutMe"];
            self.textViewAboutMe.text = textView;


            //
          //  NSArray *likes = [[objects firstObject] objectForKey:@"likes"];
        //NSLog(@"likes array: %@", likes);
            NSString *job = [[objects firstObject] objectForKey:@"work"];
            NSString *school = [[objects firstObject] objectForKey:@"scool"];
            self.jobLabel.text = job;
            self.educationLabel.text = school;

            [self loadImagesFromParse:objects];

        }
    }];


}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];


}


#pragma mark -- textView Editing
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

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



#pragma mark -- collectionView delegate Methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pictures.count;
}

-(CVSettingCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"SettingCell";
    CVSettingCell *cell = (CVSettingCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *photoString = [self.pictures objectAtIndex:indexPath.item];
    cell.userImage.image = [UIImage imageWithData:[self imageData:photoString]];

    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section    {
    return 5; // This is the minimum inter item spacing, can be more
}

-(void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    NSString *photoString = [self.pictures objectAtIndex:fromIndexPath.item];
    [self.pictures removeObjectAtIndex:fromIndexPath.item];
    [self.pictures insertObject:photoString atIndex:toIndexPath.item];

    [self deconstructArray:self.pictures];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"dragging cell begun");

}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"dragging has stopped");

}
#pragma mark -- Segue
- (IBAction)onSwapPhotsButton:(UIButton *)sender {
    [self performSegueWithIdentifier:@"SwapImages" sender:self];
}

#pragma mark --other view elements

//3) Min/Max Ages
- (IBAction)onMinAgeSliderChange:(UISlider *)sender {
    //number to label convert
    NSString *minAgeStr = [NSString stringWithFormat:@"%.f", self.minimumAgeSlider.value];
    NSString *minAge = [NSString stringWithFormat:@"Minimum Age: %@", minAgeStr];
    self.minimumAgeLabel.text = minAge;
    //save to Parse
    [self.currentUser setObject:minAgeStr forKey:@"minAge"];

    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error in saving min Age: %@", error);
        } else{
            NSLog(@"saved: %s", succeeded ? "true" : "false");
        }
    }];

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
    [self changeButtonState:self.womenButton sexString:@"female" otherButton1:self.menButton otherButton2:self.bothButton];
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



- (IBAction)logOutButton:(UIButton *)sender {

    if (sender.isSelected) {
        self.logoutButton.backgroundColor = [UIColor blackColor];

    }
    [PFUser logOut];


    //nothing works to unlink the facebok account
   // [PFFacebookUtils unlinkUserInBackground:self.currentUser];

    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error unlinking: %@", error);
        } else{
            NSLog(@"logged out, no user: %@", self.currentUser);
        }
    }];

    NSLog(@"current user: after %@", self.currentUser);

    [self performSegueWithIdentifier:@"LoggedOut" sender:self];
}


- (IBAction)userViewButton:(UIButton *)sender {
}


#pragma mark -- helpers


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

-(void)loadImagesFromParse:(NSArray *)objectArray{

    //userImages
    NSString *image1 = [[objectArray firstObject] objectForKey:@"image1"];
    NSString *image2 = [[objectArray firstObject] objectForKey:@"image2"];
    NSString *image3 = [[objectArray firstObject] objectForKey:@"image3"];
    NSString *image4 = [[objectArray firstObject] objectForKey:@"image4"];
    NSString *image5 = [[objectArray firstObject] objectForKey:@"image5"];
    NSString *image6 = [[objectArray firstObject] objectForKey:@"image6"];
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

    [self.spinner stopAnimating];
    self.loadingView.hidden = YES;
    self.loadingLabel.hidden = YES;
    self.spinner.hidden = YES;
}

-(void)changeButtonState:(UIButton *)button sexString:(NSString *)sex otherButton1:(UIButton *)b1 otherButton2:(UIButton *)b2    {

    button.backgroundColor = [UIColor blackColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.currentUser setObject:sex forKey:@"sexPref"];
    [self.currentUser saveInBackground];

    if ([button isSelected]) {
        [button setSelected:NO];
        button.backgroundColor = [UIColor blackColor];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    } else{
        //change other two buttons to delected
        [button setSelected:YES];
        [b1 setSelected:NO];
        [b2 setSelected:NO];
        [b1 setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
        [b2 setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
        b1.backgroundColor = [UIColor whiteColor];
        b2.backgroundColor = [UIColor whiteColor];
    }
}

-(void)deconstructArray:(NSMutableArray *)array {

    NSString *firstImage = [array firstObject];
    NSString *secondImage = [array objectAtIndex:1];
    NSString *thirdImage = [array objectAtIndex:2];
    NSString *forthImage = [array objectAtIndex:3];
    NSString *fifthImage = [array objectAtIndex:4];
    NSString *sixthImage = [array objectAtIndex:5];

    if (firstImage) {
        [self.currentUser setObject:firstImage forKey:@"image1"];
        [self.currentUser saveInBackground];
    } if (secondImage) {
        [self.currentUser setObject:secondImage forKey:@"image2"];
        [self.currentUser saveInBackground];
    } if (thirdImage) {
        [self.currentUser setObject:thirdImage forKey:@"image3"];
        [self.currentUser saveInBackground];
    } if (forthImage) {
        [self.currentUser setObject:forthImage forKey:@"image4"];
        [self.currentUser saveInBackground];
    } if (fifthImage) {
        [self.currentUser setObject:fifthImage forKey:@"image5"];
        [self.currentUser saveInBackground];
    } if (sixthImage) {
        [self.currentUser setObject:sixthImage forKey:@"image6"];
        [self.currentUser saveInBackground];
    }
}

-(void)segueAction{
    [self performSegueWithIdentifier:@"PreviewSegue" sender:self];
}
@end







