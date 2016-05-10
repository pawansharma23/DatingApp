//
//  ProfileViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 12/19/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import "ProfileViewController.h"
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "CVSettingCell.h"
#import <LXReorderableCollectionViewFlowLayout.h>
#import "UIColor+Pandemos.h"
#import "UIButton+Additions.h"
#import "User.h"
#import "FacebookManager.h"
#import "UserManager.h"
#import "UIImage+Additions.h"

@interface ProfileViewController ()
<MFMailComposeViewControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UITextViewDelegate,
UIScrollViewDelegate,
UICollectionViewDelegateFlowLayout,
LXReorderableCollectionViewDelegateFlowLayout,
LXReorderableCollectionViewDataSource,
UIPopoverPresentationControllerDelegate,
UserManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *appLogo;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UITextView *textViewAboutMe;

@property (weak, nonatomic) IBOutlet UILabel *minimumAgeLabel;
@property (weak, nonatomic) IBOutlet UISlider *minimumAgeSlider;
@property (weak, nonatomic) IBOutlet UISlider *maximumAgeSlider;
@property (weak, nonatomic) IBOutlet UILabel *maximumAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *menButton;
@property (weak, nonatomic) IBOutlet UIButton *womenButton;
@property (weak, nonatomic) IBOutlet UIButton *bothButton;
@property (weak, nonatomic) IBOutlet UILabel *milesAwayLabel;
@property (weak, nonatomic) IBOutlet UISlider *milesAwaySlider;

@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *educationLabel;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UISwitch *publicProfileSwitch;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (strong, nonatomic) NSString *aboutMe;
@property (strong, nonatomic) NSString *sexPref;
@property (strong, nonatomic) NSString *minAge;
@property (strong, nonatomic) NSString *maxAge;
@property (strong, nonatomic) NSString *miles;
@property (strong, nonatomic) NSString *publicProfile;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSMutableArray *profileImages;
@property (strong, nonatomic) FacebookManager *manager;
@property (strong, nonatomic) UserManager *userManager;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [User currentUser];

    if (self.currentUser)
    {
        self.navigationItem.title = @"Settings";
        self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
        self.profileImages = [NSMutableArray new];


        UIImage *closeNavBarButton = [UIImage imageWithImage:[UIImage imageNamed:@"Back-100"] scaledToSize:CGSizeMake(30.0, 30.0)];
        [self.navigationItem.leftBarButtonItem setImage:closeNavBarButton];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor darkGrayColor];
        //retrieve and pass segue properties
        self.locationLabel.text = self.cityAndState;

        //self.automaticallyAdjustsScrollViewInsets = NO;

        //delegation, initialization
        self.scrollView.delegate = self;
        self.collectionView.delegate = self;
        self.textViewAboutMe.delegate = self;

        //collection view
        self.collectionView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor grayColor]);
        self.collectionView.layer.borderWidth = 1.0;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        LXReorderableCollectionViewFlowLayout *flowlayouts = [LXReorderableCollectionViewFlowLayout new];
        [flowlayouts setItemSize:CGSizeMake(100, 100)];

        [flowlayouts setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowlayouts.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);//buffer in: top, left, bottom, right format
        [self.collectionView setCollectionViewLayout:flowlayouts];
        self.collectionView.backgroundColor = [UIColor whiteColor];

        [UIButton setUpButton:self.menButton];
        [UIButton setUpButton:self.womenButton];
        [UIButton setUpButton:self.bothButton];
        [UIButton setUpButton:self.logoutButton];
        [UIButton setUpButton:self.deleteButton];
        [UIButton setUpButton:self.shareButton];
        [UIButton setUpButton:self.feedbackButton];

        self.textViewAboutMe.layer.cornerRadius = 10;
        [self.textViewAboutMe.layer setBorderWidth:1.0];
        [self.textViewAboutMe.layer setBorderColor:[UIColor grayColor].CGColor];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];

    [self setupManagersProfileVC];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark -- TEXTVIEW DELEGATE
-(void)textViewDidChange:(UITextView *)textView
{
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [textView.text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;

    if (textView.text.length > 280)
    {
        if (location != NSNotFound)
        {
            [textView resignFirstResponder];
            NSLog(@"editing: %@", textView.text);
        }

    }
    else if (location != NSNotFound)
    {
        [textView resignFirstResponder];

        NSLog(@"text from shouldChangeInRange: %@", textView.text);

        NSString *aboutMeDescr = textView.text;
        NSLog(@"save textView: %@", aboutMeDescr);

        [self.currentUser setObject:aboutMeDescr forKey:@"aboutMe"];

        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error)
            {
                NSLog(@"cannot save: %@", error.description);
            }
            else
            {
                NSLog(@"saved successful: %s", succeeded ? "true" : "false");
            }
        }];
    }
}

#pragma mark -- COLLECTIONVIEW DELEGATE
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.profileImages.count;
}

-(CVSettingCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingCell";
    CVSettingCell *cell = (CVSettingCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *photoString = [self.profileImages objectAtIndex:indexPath.item];
    cell.userImage.image = [UIImage imageWithData:[self imageData:photoString]];

    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5; // This is the minimum inter item spacing, can be more
}

-(void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    NSString *photoString = [self.profileImages objectAtIndex:fromIndexPath.item];
    [self.profileImages removeObjectAtIndex:fromIndexPath.item];
    [self.profileImages insertObject:photoString atIndex:toIndexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"dragging cell begun");

}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"dragging has stopped");

}

#pragma mark -- BUTTONS/SLIDERS
//3) Min/Max Ages
- (IBAction)onMinAgeSliderChange:(UISlider *)sender
{
    NSLog(@"slider sender: %f", sender.value);
    NSString *minAgeStr = [NSString stringWithFormat:@"%.f", self.minimumAgeSlider.value];
    NSString *minAge = [NSString stringWithFormat:@"Minimum Age: %@", minAgeStr];
    self.minimumAgeLabel.text = minAge;

    [self.currentUser setObject:minAgeStr forKey:@"minAge"];

    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error in saving min Age: %@", error);
        } else{
            NSLog(@"saved: %s with string: %@", succeeded ? "true" : "false", minAgeStr);
        }
    }];
}

- (IBAction)onMaxAgeSliderChange:(UISlider *)sender
{
    NSString *maxAgeStr = [NSString stringWithFormat:@"%.f", self.maximumAgeSlider.value];
    NSString *maxAge = [NSString stringWithFormat:@"Maximum Age: %@", maxAgeStr];
    self.maximumAgeLabel.text = maxAge;

    [self.currentUser setObject:maxAgeStr forKey:@"maxAge"];

    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error in saving Max Age: %@", error);
        } else{
            NSLog(@"saved: %s", succeeded ? "true" : "false");
        }
    }];
}

// 4) Sex Preference
- (IBAction)onMensButton:(UIButton *)sender
{
    [self changeButtonState:self.menButton sexString:@"male" otherButton1:self.womenButton otherButton2:self.bothButton];
}

- (IBAction)onWomensButton:(UIButton *)sender
{
    [self changeButtonState:self.womenButton sexString:@"female" otherButton1:self.menButton otherButton2:self.bothButton];
}

- (IBAction)onBothButton:(UIButton *)sender
{
    [self changeButtonState:self.bothButton sexString:@"male female" otherButton1:self.menButton otherButton2:self.womenButton];
}

//5) Miles away
- (IBAction)milesAwaySlider:(UISlider *)sender
{
    NSString *milesAwayStr = [NSString stringWithFormat:@"%.f", self.milesAwaySlider.value];


    NSLog(@"miles away string to save: %@", milesAwayStr);


    NSString *milesAway = [NSString stringWithFormat:@"Show results within %@ miles of here", milesAwayStr];
    self.milesAwayLabel.text = milesAway;
    [self.currentUser setObject:milesAwayStr forKey:@"milesAway"];

    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"error in saving miles away: %@", error);
        }
        else
        {
            NSLog(@"saved: %s", succeeded ? "true" : "false");
        }
    }];
}


//6)Puublic Profile
- (IBAction)publicProfileSwitch:(UISwitch *)sender
{
    if ([sender isOn])
    {
        [self.currentUser setObject:@"public" forKey:@"publicProfile"];
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error)
            {
                NSLog(@"error in saving public profile: %@", error);
            }
            else
            {
                NSLog(@"saved: %s", succeeded ? "true" : "false");
            }
        }];
    }
    else
    {
        [self.currentUser setObject:@"private" forKey:@"publicProfile"];
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                NSLog(@"error in saving pub profile: %@", error);
            } else{
                NSLog(@"saved: %s", succeeded ? "true" : "false");
            }
        }];
    }
}

- (IBAction)feedback:(UIButton *)sender
{
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

- (IBAction)logOutButton:(UIButton *)sender
{

    if (sender.isSelected)
    {
        self.logoutButton.backgroundColor = [UIColor blackColor];
    }
    
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (!error)
        {
            NSLog(@"logged Out");
        }
        else
        {
            NSLog(@"cannot log out: %@", error);
        }
    }];


    //nothing works to unlink the facebok account
   // [PFFacebookUtils unlinkUserInBackground:self.currentUser];

//    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"error unlinking: %@", error);
//        } else{
//            NSLog(@"logged out, no user: %@", self.currentUser);
//        }
//    }];

    NSLog(@"current user: after %@", self.currentUser);

    [self performSegueWithIdentifier:@"LoggedOut" sender:self];
}

- (IBAction)onBackButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)userViewButton:(UIButton *)sender
{

}

#pragma mark - USER MANAGER DELEGATE
-(void)didReceiveUserData:(NSArray *)data
{
    NSDictionary *userData = [data firstObject];
    self.sexPref = userData[@"sexPref"];
    [self sexPreferenceButton];
    self.aboutMe = userData[@"aboutMe"];
    self.textViewAboutMe.text = self.aboutMe;

    NSString *miles = userData[@"milesAway"];
    [self setMilesAway:miles];

    NSString *min = userData[@"minAge"];
    NSString *max = userData[@"maxAge"];

    [self setMinAndMaxAgeSliders:min andMax:max];
    self.jobLabel.text = userData[@"work"];
    self.educationLabel.text = userData[@"lastSchool"];
    [self setPublicProfile:userData[@"publicProfile"]];
}

-(void)failedToFetchUserData:(NSError *)error
{
    NSLog(@"failed to fetch Data: %@", error);
}

-(void)didReceiveUserImages:(NSArray *)images
{
    self.profileImages = [NSMutableArray arrayWithArray:images];
    [self.collectionView reloadData];
}

-(void)failedToFetchImages:(NSError *)error
{
    NSLog(@"failed to fetch profile images: %@", error);
}
#pragma mark -- NAV


#pragma mark -- HELPERS
-(void)setupManagersProfileVC
{
    self.userManager = [UserManager new];
    self.userManager.delegate = self;

    [self.userManager loadUserData:self.currentUser];
    [self.userManager loadUserImages:self.currentUser];
}

-(void)setPublicProfile:(NSString *)publicProfile
{
    if ([publicProfile containsString:@"public"])
    {
        NSLog(@"public: %@", publicProfile);
        [self.publicProfileSwitch setOn:YES animated:YES];
    }
    else
    {
        NSLog(@"non public: %@", publicProfile);
        [self.publicProfileSwitch setOn:NO animated:YES];
    }
}

-(void)setMilesAway:(NSString *)milesAway
{
    CGFloat away = (CGFloat)[milesAway floatValue];
    self.milesAwaySlider.value = away;
    NSLog(@"miles away: %f", away);
    NSString *milesAwayStr = [NSString stringWithFormat:@"Minimum Age: %.f", away];
    self.milesAwayLabel.text = milesAwayStr;
}

-(void)setMinAndMaxAgeSliders:(NSString *)min andMax:(NSString *)max
{
    CGFloat minAge = (CGFloat)[min floatValue];
    self.minimumAgeSlider.value = minAge;
    NSString *minAgeStr = [NSString stringWithFormat:@"Minimum Age: %.f", minAge];
    self.minimumAgeLabel.text = minAgeStr;

    CGFloat maxAge = (CGFloat)[max floatValue];
    self.maximumAgeSlider.value = maxAge;
    NSString *maxAgeStr = [NSString stringWithFormat:@"Minimum Age: %.f", maxAge];
    self.maximumAgeLabel.text = maxAgeStr;
}

-(void)sexPreferenceButton
{
    if ([self.sexPref isEqualToString:@"female"])
    {
        self.womenButton.backgroundColor = [UIColor blackColor];
    }

    else if ([self.sexPref isEqualToString:@"male"])
    {
        self.menButton.backgroundColor = [UIColor blackColor];
    }
    else if ([self.sexPref isEqualToString:@"male female"])
    {
        self.bothButton.backgroundColor = [UIColor blackColor];
    }
    else
    {
        NSLog(@"sex Pref data not working");
    }
}

-(NSData *)imageData:(NSString *)imageString
{
    NSURL *url = [NSURL URLWithString:imageString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}

-(void)changeButtonState:(UIButton *)button sexString:(NSString *)sex otherButton1:(UIButton *)b1 otherButton2:(UIButton *)b2
{
    button.backgroundColor = [UIColor blackColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.currentUser setObject:sex forKey:@"sexPref"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"saved for %@, %d", sex, succeeded ? true : false);
    }];

    if ([button isSelected])
    {
        [button setSelected:NO];
        button.backgroundColor = [UIColor blackColor];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    }
    else
    {
        //change other two buttons
        [button setSelected:YES];
        [b1 setSelected:NO];
        [b2 setSelected:NO];
        [b1 setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
        [b2 setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
        b1.backgroundColor = [UIColor whiteColor];
        b2.backgroundColor = [UIColor whiteColor];
    }
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
@end







