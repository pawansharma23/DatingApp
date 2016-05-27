//
//  ChooseImageInitialViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/11/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//
#import "SelectedImageViewController.h"
#import <LXReorderableCollectionViewFlowLayout.h>
#import "PreviewCell.h"
#import "User.h"
#import "UIColor+Pandemos.h"
#import "UIButton+Additions.h"
#import "UIImage+Additions.h"
#import "UIImageView+Additions.h"
#import "FacebookManager.h"
#import "Facebook.h"
#import "UserManager.h"
#import "UICollectionView+Pandemos.h"

@interface SelectedImageViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
LXReorderableCollectionViewDataSource,
LXReorderableCollectionViewDelegateFlowLayout,
FacebookManagerDelegate,
UserManagerDelegate,
PreviewCellDelegate,
UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *saveImage;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIButton *addAnother;

@property (strong, nonatomic) NSMutableArray *pictures;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) UserManager *userManager;
@property (strong, nonatomic) NSDictionary *sizeAttributes;
@end

@implementation SelectedImageViewController

static NSString * const kReuseIdentifier = @"PreviewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentUser = [User currentUser];

    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Photo";
    self.navigationController.navigationBar.backgroundColor = [UIColor yellowGreen];

    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                 NSFontAttributeName :[UIFont fontWithName:@"GeezaPro" size:20.0]};
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];

    self.userImage.image = [UIImage imageWithData:self.profileImageAsData];
    self.userImage.layer.cornerRadius = 7.0;
    self.userImage.layer.masksToBounds = YES;

    self.pictures = [NSMutableArray new];

    [UICollectionView setupBorder:self.collectionView];
    [self setupCollectionViewFlowLayout];

    [self.saveImage sizeToFit];
    [self.saveImage setContentEdgeInsets:UIEdgeInsetsMake(2.0, 5.0, 2.0, 5.0)];
    self.sizeAttributes = @{NSForegroundColorAttributeName:[UIColor mikeGray],
                            NSFontAttributeName :[UIFont fontWithName:@"GeezaPro" size:14.0]};
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];

    if (self.currentUser)
    {
        self.userManager = [UserManager new];
        self.userManager.delegate = self;

        [self.userManager loadUserImages:self.currentUser];

        [UIButton setUpButton:self.saveImage];
        [UIButton setUpButton:self.addAnother];
        self.addAnother.hidden = YES;
        [UIButton setUpButton:self.profileButton];
    }
    else
    {
        NSLog(@"no user for face request");
    }
}

#pragma mark -- COLLECTIONVIEW DELEGATE
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pictures.count;
}

-(PreviewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PreviewCell *cell = (PreviewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifier forIndexPath:indexPath];
    NSData *imageData = [self.pictures objectAtIndex:indexPath.item];
    cell.cvImage.image = [UIImage imageWithData:imageData];

    if (imageData)
    {
        cell.xImage.image = [UIImage imageWithImage:[UIImage imageNamed:@"Close"] scaledToSize:CGSizeMake(25.0, 25.0)];
    }

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    [self.collectionView performBatchUpdates:^{

        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0] ;
        [self.pictures removeObjectAtIndex:indexPath.row];
        [self.collectionView deleteItemsAtIndexPaths:@[cellIndexPath]];

        [self.currentUser setObject:self.pictures forKey:@"profileImages"];
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

            if (succeeded)
            {
                NSLog(@"NEW PROFILE IMAGES SAVED TO PARSE");
                [self saveButtonCheck];

            }
        }];


    } completion:nil];

    [self.collectionView reloadData];
}

-(void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    User *images = [self.pictures objectAtIndex:fromIndexPath.item];
    [self.pictures removeObjectAtIndex:fromIndexPath.item];
    [self.pictures insertObject:images atIndex:toIndexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"dragging cell begun");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"dragging has stopped");
}

#pragma mark -- NAV
- (IBAction)onBackButton:(UIBarButtonItem *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)onAddAnother:(UIButton *)sender
{
    [UIButton changeButtonStateForSingleButton:self.addAnother];
    [self performSegueWithIdentifier:@"FacebookAlbums" sender:self];
}

- (IBAction)onContinueButton:(UIButton *)sender
{
    [UIButton changeButtonStateForSingleButton:self.profileButton];
    [self performSegueWithIdentifier:@"Profile" sender:self];
}

- (IBAction)onSaveImage:(UIButton *)sender
{
    [UIButton changeButtonStateForSingleButton:self.saveImage];

    switch (self.pictures.count)
    {
        case 0:
            [self saveForImage1];
            [self.collectionView reloadData];
            break;
        case 1:
            [self saveForImage2];
            [self.collectionView reloadData];
            break;
        case 2:
            [self saveForImage3];
            [self.collectionView reloadData];
            break;
        case 3:
            [self saveForImage4];
            [self.collectionView reloadData];
            break;
        case 4:
            [self saveForImage5];
            [self.collectionView reloadData];
            break;
        case 5:
            [self saveForImage6];
            [self.collectionView reloadData];
            break;
        default:
            NSLog(@"all images Filled");
            [self.saveImage setTitle:@"All Full :)" forState:UIControlStateNormal];
            break;
    }

    [self saveButtonCheck];
}

#pragma mark -- USER MANAGER DELEGATE
-(void)didReceiveUserImages:(NSArray *)images
{
    if (images)
    {
        NSMutableArray *mutArr = [NSMutableArray arrayWithArray:images];
        self.pictures = mutArr;
    }

    [self.collectionView reloadData];
}

-(void)previewCellDidReturnButtonAction:(BOOL)action
{
    if (action == YES)
    {
        [self.collectionView reloadData];
    }
}

-(void)didReceiveParsedPhotoSource:(NSString *)photoURL
{
    self.profileImage = photoURL;
}

#pragma mark -- HELPERS
-(void)saveButtonCheck
{
    if (self.pictures.count < 6)
    {
        self.saveImage.hidden = YES;
        self.addAnother.hidden = NO;
    }
    else
    {
        NSString *okString = @"Delete an Image, then save!";
        [self.saveImage setTitle:okString forState:UIControlStateNormal];
        self.saveImage.backgroundColor = [UIColor whiteColor];
        [self.saveImage sizeToFit];
        [self.saveImage setContentEdgeInsets:UIEdgeInsetsMake(2.0, 5.0, 2.0, 5.0)];
    }
}

-(void)setupCollectionViewFlowLayout
{
    LXReorderableCollectionViewFlowLayout *flowlayouts = [LXReorderableCollectionViewFlowLayout new];
    [flowlayouts setItemSize:CGSizeMake(100, 100)];
    [flowlayouts setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowlayouts.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowlayouts.headerReferenceSize = CGSizeZero;
    flowlayouts.footerReferenceSize = CGSizeZero;
    [self.collectionView setCollectionViewLayout:flowlayouts];
}

-(void)delayAndCheckImageCount
{
    int64_t delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        [self saveButtonCheck];
    });
}

-(void)saveForImage1
{
    [self.pictures addObject:self.profileImageAsData];
    [self.currentUser setObject:self.pictures forKey:@"profileImages"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.saveImage setTitle:@"Image 1 Set" forState:UIControlStateNormal];

        [self delayAndCheckImageCount];
    }];
}

-(void)saveForImage2
{
    [self.pictures addObject:self.profileImageAsData];
    [self.currentUser setObject:self.pictures forKey:@"profileImages"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.saveImage setTitle:@"Image 2 Set" forState:UIControlStateNormal];

        [self delayAndCheckImageCount];
    }];
}

-(void)saveForImage3
{
    [self.pictures addObject:self.profileImageAsData];
    [self.currentUser setObject:self.pictures forKey:@"profileImages"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.saveImage setTitle:@"Image 3 Set" forState:UIControlStateNormal];

        [self delayAndCheckImageCount];
    }];
}

-(void)saveForImage4
{
    [self.pictures addObject:self.profileImageAsData];
    [self.currentUser setObject:self.pictures forKey:@"profileImages"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.saveImage setTitle:@"Image 4 Set" forState:UIControlStateNormal];

        [self delayAndCheckImageCount];
    }];
}

-(void)saveForImage5
{
    NSLog(@"5 Empty");
    [self.pictures addObject:self.profileImageAsData];
    [self.currentUser setObject:self.pictures forKey:@"profileImages"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.saveImage setTitle:@"Image 5 Set" forState:UIControlStateNormal];

        [self delayAndCheckImageCount];
    }];
}

-(void)saveForImage6
{
    [self.pictures addObject:self.profileImageAsData];
    [self.currentUser setObject:self.pictures forKey:@"profileImages"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.saveImage setTitle:@"Image 6 Set" forState:UIControlStateNormal];

        [self delayAndCheckImageCount];
    }];
}
@end