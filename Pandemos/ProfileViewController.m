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

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ProfileViewController ()<MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) PFUser *currentUser;

@property (weak, nonatomic) IBOutlet UILabel *milesAwayLabel;
@property (weak, nonatomic) IBOutlet UISlider *milesAwaySlider;
@property (weak, nonatomic) IBOutlet UISwitch *publicProfileSwitch;
@property (weak, nonatomic) IBOutlet UIButton *menButton;
@property (weak, nonatomic) IBOutlet UIButton *womenButton;
@property (weak, nonatomic) IBOutlet UIButton *bothButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *educationLabel;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];
    self.navigationItem.title = @"Settings";
    //profile change info added to left side of nav bar
    UIBarButtonItem *leftSideBB = [[UIBarButtonItem alloc]initWithTitle:@"Update Profile" style:UIBarButtonItemStylePlain target:self action:@selector(segueToProfileView)];
    leftSideBB.tintColor = [UIColor colorWithRed:251.0/255.0 green:73.0/255.0 blue:72.0/255.0 alpha:1.0];
    self.navigationItem.rightBarButtonItem = leftSideBB;

    
//    RangeSlider *rangleSlider = [[RangeSlider alloc]initWithFrame:CGRectMake(20, 150, 200, 30)];
//    rangleSlider.minimumRangeLength = 1.0;
//    rangleSlider.min = 18.0;
//    rangleSlider.max = 100.0;
//    [rangleSlider addTarget:self action:@selector(updateRangeLabel:) forControlEvents:UIControlEventValueChanged];
//    [self.view addSubview:rangleSlider];

    //M Sex Pref Button setup round edges etc.
    self.menButton.layer.cornerRadius = 15;
    self.menButton.clipsToBounds = YES;
    [self.menButton.layer setBorderWidth:2.0];
    [self.menButton.layer setBorderColor:[UIColor blackColor].CGColor];
    //F
    self.womenButton.layer.cornerRadius = 15;
    self.womenButton.clipsToBounds = YES;
    [self.womenButton.layer setBorderWidth:2.0];
    [self.womenButton.layer setBorderColor:[UIColor blackColor].CGColor];
    //Both
    self.bothButton.layer.cornerRadius = 15;
    self.bothButton.clipsToBounds = YES;
    [self.bothButton.layer setBorderWidth:2.0];
    [self.bothButton.layer setBorderColor:[UIColor blackColor].CGColor];

    //Logout and Delete buttons
    self.logoutButton.layer.cornerRadius = 15;
    self.logoutButton.clipsToBounds = YES;
    [self.logoutButton.layer setBorderWidth:2.0];
    [self.logoutButton.layer setBorderColor:[UIColor blackColor].CGColor];
    self.deleteButton.layer.cornerRadius = 15;
    self.deleteButton.clipsToBounds = YES;
    [self.deleteButton.layer setBorderWidth:2.0];
    [self.deleteButton.layer setBorderColor:[UIColor blackColor].CGColor];
    //Share and Feedback buttons
    self.shareButton.layer.cornerRadius = 15;
    self.shareButton.clipsToBounds = YES;
    [self.shareButton.layer setBorderWidth:2.0];
    [self.shareButton.layer setBorderColor:[UIColor blackColor].CGColor];
    self.feedbackButton.layer.cornerRadius = 15;
    self.feedbackButton.clipsToBounds = YES;
    [self.feedbackButton.layer setBorderWidth:2.0];
    [self.feedbackButton.layer setBorderColor:[UIColor blackColor].CGColor];

    //set miles away slider from Parse
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){
            CGFloat strFloat = (CGFloat)[[[objects firstObject] objectForKey:@"milesAway"] floatValue];
            //NSLog(@"miles away: %f", strFloat);
            self.milesAwaySlider.value = strFloat;
            NSString *milesAwayStr = [NSString stringWithFormat:@"Show results within %.f miles of here", strFloat];
            self.milesAwayLabel.text = milesAwayStr;
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
            NSArray *likes = [[objects firstObject] objectForKey:@"likes"];
        NSLog(@"likes array: %@", likes);
            NSString *job = [[objects firstObject] objectForKey:@"work"];
            NSString *school = [[objects firstObject] objectForKey:@"scool"];
            self.jobLabel.text = job;
            self.educationLabel.text = school;

            //userImages
            NSArray *userImages = [[objects firstObject] objectForKey:@"selectedUserImages"];
            //NSString *imageStr = user.photoID;
            NSLog(@"user images: %@", userImages);

        }
    }];


}

- (IBAction)publicProfileSwitch:(UISwitch *)sender {
    if ([sender isOn]) {
        [self.currentUser setObject:@"public" forKey:@"publicProfile"];
        [self.currentUser saveInBackground];
    } else {
        [self.currentUser setObject:@"private" forKey:@"publicProfile"];
        [self.currentUser saveInBackground];
    }
}


- (IBAction)milesAwaySlider:(UISlider *)sender {

    NSString *milesAwayStr = [NSString stringWithFormat:@"%.f", self.milesAwaySlider.value];
    NSString *milesAway = [NSString stringWithFormat:@"Show results within %@ miles of here", milesAwayStr];
    self.milesAwayLabel.text = milesAway;
    [self.currentUser setObject:milesAwayStr forKey:@"milesAway"];
    [self.currentUser saveInBackground];

}

-(void)viewDidAppear:(BOOL)animated {

    if(!_currentUser) {
        NSLog(@"No pf user: %@", _currentUser);
        [self performSegueWithIdentifier:@"LoggedOut" sender:self];
    } else{
        NSLog(@"user is logged in: %@", _currentUser);
    }
}



//Sex Preference buttons and saving to parse on selection, also deselecting the other two
- (IBAction)onMensButton:(UIButton *)sender {
    self.menButton.backgroundColor = [UIColor blueColor];
    [self.currentUser setObject:@"M" forKey:@"sexPref"];
    [self.currentUser saveInBackground];
    if ([sender isSelected]) {
        [sender setSelected:NO];
        self.menButton.backgroundColor = [UIColor whiteColor];
    } else{
        [sender setSelected:YES];
        [self.womenButton setSelected:NO];
        [self.bothButton setSelected:NO];
        self.womenButton.backgroundColor = [UIColor whiteColor];
        self.bothButton.backgroundColor = [UIColor whiteColor];
    }
}

- (IBAction)onWomensButton:(UIButton *)sender {
    self.womenButton.backgroundColor = [UIColor blueColor];
    [self.currentUser setObject:@"F" forKey:@"sexPref"];
    [self.currentUser saveInBackground];
    if ([sender isSelected]) {
        [sender setSelected:NO];
        self.womenButton.backgroundColor = [UIColor whiteColor];
    } else{
        [sender setSelected:YES];
        [self.menButton setSelected:NO];
        [self.bothButton setSelected:NO];
        self.menButton.backgroundColor = [UIColor whiteColor];
        self.bothButton.backgroundColor = [UIColor whiteColor];
    }
}

- (IBAction)onBothButton:(UIButton *)sender {
    self.bothButton.backgroundColor = [UIColor blueColor];
    [self.currentUser setObject:@"Both" forKey:@"sexPref"];
    [self.currentUser saveInBackground];
    if ([sender isSelected]) {
        [sender setSelected:NO];
        self.bothButton.backgroundColor = [UIColor whiteColor];
    } else{
        [sender setSelected:YES];
        [self.menButton setSelected:NO];
        [self.womenButton setSelected:NO];
        self.menButton.backgroundColor = [UIColor whiteColor];
        self.womenButton.backgroundColor = [UIColor whiteColor];
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

#pragma mark -- helpers

-(void)updateRangeLabel:(RangeSlider *)slider{
    NSLog(@"Slider Range: %f - %f", slider.min, slider.max);
}


-(void)segueToProfileView{
    [self performSegueWithIdentifier:@"ProfileSegue" sender:nil];
}


- (IBAction)logOutButton:(UIButton *)sender {

    [PFUser logOut];
    [self performSegueWithIdentifier:@"LoggedOut" sender:self];

}


- (IBAction)userViewButton:(UIButton *)sender {


}
@end





