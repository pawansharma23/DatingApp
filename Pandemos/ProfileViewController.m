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
#import "UICollectionView+Pandemos.h"
#import "SelectedImageViewController.h"
#import "HeaderForProfileVC.h"
#import "SVProgressHUD.h"

@interface ProfileViewController ()
<MFMailComposeViewControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UITextViewDelegate,
UIScrollViewDelegate,
UICollectionViewDelegateFlowLayout,
LXReorderableCollectionViewDelegateFlowLayout,
LXReorderableCollectionViewDataSource,
UIPopoverPresentationControllerDelegate,
UserManagerDelegate>
{
    UIImagePickerController *ipc;
}
//View Properties
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *viewInsideScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UITextView *textViewAboutMe;

@property (weak, nonatomic) IBOutlet UILabel *minimumAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *maximumAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *milesAwayLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *educationLabel;

@property (weak, nonatomic) IBOutlet UIButton *SwapAddPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *menButton;
@property (weak, nonatomic) IBOutlet UIButton *womenButton;
@property (weak, nonatomic) IBOutlet UIButton *bothButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookAlbumsButton;

@property (weak, nonatomic) IBOutlet UISwitch *publicProfileSwitch;
@property (weak, nonatomic) IBOutlet UISlider *milesSlider;
@property (weak, nonatomic) IBOutlet UISlider *minimumAgeSlider;
@property (weak, nonatomic) IBOutlet UISlider *maximumAgeSlider;
//strong global properties
@property (strong, nonatomic) NSString *aboutMe;
@property (strong, nonatomic) NSString *sexPref;
@property (strong, nonatomic) NSString *minAge;
@property (strong, nonatomic) NSString *maxAge;
@property (strong, nonatomic) NSString *miles;
@property (strong, nonatomic) NSString *publicProfile;
@property (strong, nonatomic) NSString *selectedImage;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSMutableArray *profileImages;
@property (strong, nonatomic) FacebookManager *manager;
@property (strong, nonatomic) UserManager *userManager;
@property (strong, nonatomic) NSData *selectedImageData;
@property (strong, nonatomic) NSData *selectedPhoneImageData;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [User currentUser];

    if (self.currentUser)
    {
        //self.locationLabel.text = self.cityAndState;
        //placeholder
        self.locationLabel.text = @"Location";

        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor unitedNationBlue],
                                     NSFontAttributeName :[UIFont fontWithName:@"GeezaPro" size:20.0]};
        [self.navigationController.navigationBar setTitleTextAttributes:attributes];
        self.navigationItem.title = @"Settings";
        self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];

        UIImage *closeNavBarButton = [UIImage imageWithImage:[UIImage imageNamed:@"Back"] scaledToSize:CGSizeMake(25.0, 25.0)];
        [self.navigationItem.leftBarButtonItem setImage:closeNavBarButton];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor mikeGray];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor mikeGray];

        self.profileImages = [NSMutableArray new];
        self.textViewAboutMe.delegate = self;

        [UICollectionView setupBorder:self.collectionView];
        self.collectionView.delegate = self;

        [self setFlowLayout];
        [self setupButtonsAndTextView];

    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];

    [SVProgressHUD show];

    //CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 900);
    //[self.view setFrame:frame];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.delegate = self;
    self.scrollView.scrollEnabled = YES;
    [self.scrollView addSubview:self.viewInsideScrollView];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 900)];
    self.scrollView.scrollsToTop = YES;





    [self setupManagersProfileVC];

    [UIButton setUpButton:self.SwapAddPhotoButton];
    [UIButton setUpButton:self.facebookAlbumsButton];
    //on reload scroll to top
    [self.milesSlider setUserInteractionEnabled:YES];
    [self.minimumAgeSlider setUserInteractionEnabled:YES];
    [self.maximumAgeSlider setUserInteractionEnabled:YES];

    if (self.selectedPhoneImageData)
    {
        [self performSegueWithIdentifier:@"Selected" sender:self];
    }
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return NO;
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return NO;
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
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(300, 20);
}

-(HeaderForProfileVC *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    HeaderForProfileVC *header = nil;
    static NSString *imagesDesc = @"*Hold and drag photos to change their order";
    static NSString *identifier = @"ImageDescription";

    if (kind == UICollectionElementKindSectionHeader)
    {
        HeaderForProfileVC *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identifier forIndexPath:indexPath];
        headerView.headerTitle.text = imagesDesc;
        headerView.backgroundColor = [UIColor lightGrayColor];
        header = headerView;
    }

    return header;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.profileImages.count;
}

-(CVSettingCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingCell";
    CVSettingCell *cell = (CVSettingCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSData *photoData = [self.profileImages objectAtIndex:indexPath.item];
    cell.userImage.image = [UIImage imageWithData:photoData];

    return cell;
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 2; // This is the minimum inter item spacing, can be more
//}

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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedImageData = [self.profileImages objectAtIndex:indexPath.item];
    [self performSegueWithIdentifier:@"Selected" sender:self];
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
- (IBAction)onMilesSliderChanged:(UISlider *)sender
{
    NSLog(@"miles value: %d", (int)sender);
    NSString *milesAwayStr = [NSString stringWithFormat:@"%.f", self.milesSlider.value];
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
            NSLog(@"SAVED:%@ %s", milesAwayStr, succeeded ? "true" : "false");
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
    [self performSegueWithIdentifier:@"BackToMain" sender:self];
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
    if (self.aboutMe)
    {
        self.textViewAboutMe.text = self.aboutMe;
    }
    else
    {
        self.textViewAboutMe.text = @"Tell us about you, 280 characters max";
    }

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
    [SVProgressHUD dismiss];
}

-(void)failedToFetchImages:(NSError *)error
{
    NSLog(@"failed to fetch profile images: %@", error);
}

#pragma mark -- SEGUE
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Selected"])
    {
        [SVProgressHUD dismiss];
        if (self.selectedPhoneImageData)
        {
            SelectedImageViewController *sivc = [(UINavigationController*)segue.destinationViewController topViewController];
            sivc.profileImageAsData = self.selectedPhoneImageData;
        }
        else
        {
            SelectedImageViewController *sivc = [(UINavigationController*)segue.destinationViewController topViewController];
            sivc.profileImageAsData = self.selectedImageData;
        }
    }
}

#pragma mark -- NAV
- (IBAction)onFacebookAlbums:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"Swap" sender:self];
    [UIButton changeButtonStateForSingleButton:self.facebookAlbumsButton];
}

- (IBAction)onPreviewTapped:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"Preview" sender:self];
}

- (IBAction)onSwapTapped:(UIButton *)sender
{
    [UIButton changeButtonStateForSingleButton:self.SwapAddPhotoButton];
    ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = (id)self;

    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                       ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
                                       [self presentViewController:ipc animated:YES completion:nil];
                                   }];

    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)  {
                                        ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                        [self presentViewController:ipc animated:YES completion:nil];
                                    }];

    UIAlertAction *savedPhotosAction = [UIAlertAction actionWithTitle:@"Saved" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                            ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                                            [self presentViewController:ipc animated:YES completion:nil];
                                        }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alertController addAction:cameraAction];
    [alertController addAction:libraryAction];
    [alertController addAction:savedPhotosAction];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *orginalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *scaledImage = [UIImage imageWithImage:orginalImage scaledToScale:2.0];

    if (scaledImage)
    {
        self.selectedPhoneImageData = [[NSData alloc] init];
        self.selectedPhoneImageData = UIImagePNGRepresentation(scaledImage);
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- HELPERS
-(void)setupButtonsAndTextView
{
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

-(void)setFlowLayout
{
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 2;
    layout.headerReferenceSize = CGSizeMake(300, 20);

    LXReorderableCollectionViewFlowLayout *flowlayouts = [LXReorderableCollectionViewFlowLayout new];
    [flowlayouts setItemSize:CGSizeMake(100, 100)];
    [flowlayouts setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowlayouts.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowlayouts.headerReferenceSize = CGSizeMake(300, 20);
    flowlayouts.footerReferenceSize = CGSizeZero;

    [self.collectionView setCollectionViewLayout:flowlayouts];
    self.collectionView.contentInset = UIEdgeInsetsZero;
}

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
    self.milesSlider.value = away;
    NSString *milesAwayStr = [NSString stringWithFormat:@"Within: %.f miles of you", away];
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