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
UserManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *saveImage;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *pictures;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) UserManager *userManager;
@end

@implementation SelectedImageViewController

static NSString * const kReuseIdentifier = @"PreviewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentUser = [User currentUser];

    self.navigationItem.title = @"Photo";
    self.navigationController.navigationBar.backgroundColor = [UIColor yellowGreen];
    UIImage *closeNavBarButton = [UIImage imageWithImage:[UIImage imageNamed:@"Back"] scaledToSize:CGSizeMake(25.0, 25.0)];
    [self.navigationItem.leftBarButtonItem setImage:closeNavBarButton];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor mikeGray];

    self.pictures = [NSMutableArray new];

    if (self.fromCamera == YES)
    {
        self.userImage.image = [UIImage imageWithData:self.imageAsData];
    }
    else
    {
        self.userImage.image = [UIImage imageWithString:self.image];
        [UIImageView setupFullSizedImage:self.userImage];
    }

    [UIButton setUpButton:self.saveImage];

    [UICollectionView setupBorder:self.collectionView];
    [self setupCollectionViewFlowLayout];
}

-(void)viewDidAppear:(BOOL)animated
{

    if (self.currentUser)
    {
        self.userManager = [UserManager new];
        self.userManager.delegate = self;

        [self.userManager loadUserImages:self.currentUser];
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
    NSString *image = [self.pictures objectAtIndex:indexPath.item];
    cell.cvImage.image = [UIImage imageWithString:image];

    return cell;
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

- (IBAction)onSaveImage:(UIButton *)sender
{
    [UIButton changeButtonState:self.saveImage];

    if (self.pictures.count == 0)
    {
        [self saveForImage1];
        [self.collectionView reloadData];
    }

    else if (self.pictures.count == 1)
    {
        [self saveForImage2];
        [self.collectionView reloadData];
    }

    else if (self.pictures.count == 2)
    {
        [self saveForImage3];
        [self.collectionView reloadData];
    }

    else if (self.pictures.count == 3)
    {
        [self saveForImage4];
        [self.collectionView reloadData];
    }

    else if (self.pictures.count == 4)
    {
        [self saveForImage5];
        [self.collectionView reloadData];
    }

    else if (self.pictures.count == 5)
    {
        [self saveForImage6];
        [self.collectionView reloadData];
    }

    else
    {
        NSLog(@"all images Filled");
        [self.saveImage setTitle:@"All Full :)" forState:UIControlStateNormal];
    }
}
- (IBAction)onBackButton:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAddAnother:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark -- HELPERS
-(void)setupCollectionViewFlowLayout
{
    LXReorderableCollectionViewFlowLayout *flowlayouts = [LXReorderableCollectionViewFlowLayout new];
    [flowlayouts setItemSize:CGSizeMake(100, 100)];
    [flowlayouts setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowlayouts.sectionInset = UIEdgeInsetsMake(5, 0, 5, 0);
    [self.collectionView setCollectionViewLayout:flowlayouts];
}

-(void)saveForImage1
{
    NSLog(@"1 Empty");
    [self.pictures addObject:self.image];
    [self.currentUser setObject:self.pictures forKey:@"profileImages"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.saveImage setTitle:@"Image 1 Set" forState:UIControlStateNormal];
    }];
}

-(void)saveForImage2
{
    NSLog(@"2 Empty");
    [self.pictures addObject:self.image];
    [self.currentUser setObject:self.pictures forKey:@"profileImages"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.saveImage setTitle:@"Image 2 Set" forState:UIControlStateNormal];
    }];
}

-(void)saveForImage3
{
    NSLog(@"3 Empty");
    [self.pictures addObject:self.image];
    [self.currentUser setObject:self.pictures forKey:@"profileImages"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.saveImage setTitle:@"Image 3 Set" forState:UIControlStateNormal];
    }];
}

-(void)saveForImage4
{
    NSLog(@"4 Empty");
    [self.pictures addObject:self.image];
    [self.currentUser setObject:self.pictures forKey:@"profileImages"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.saveImage setTitle:@"Image 4 Set" forState:UIControlStateNormal];
    }];
}

-(void)saveForImage5
{
    NSLog(@"5 Empty");
    [self.pictures addObject:self.image];
    [self.currentUser setObject:self.pictures forKey:@"profileImages"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.saveImage setTitle:@"Image 5 Set" forState:UIControlStateNormal];
    }];
}

-(void)saveForImage6
{
    NSLog(@"6 Empty");
    [self.pictures addObject:self.image];
    [self.currentUser setObject:self.pictures forKey:@"profileImages"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.saveImage setTitle:@"Image 6 Set" forState:UIControlStateNormal];
    }];
}
@end