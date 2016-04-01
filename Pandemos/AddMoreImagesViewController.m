//
//  AddMoreImagesViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "AddMoreImagesViewController.h"
#import "AddImageCell.h"
#import "UIColor+Pandemos.h"
#import "Facebook.h"

@interface AddMoreImagesViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *otherFacebookButton;

@property (strong, nonatomic) NSString *nextURL;
@property (strong, nonatomic) NSString *previousURL;

@property (strong, nonatomic) NSMutableArray *pictureArray;

@end

@implementation AddMoreImagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionView.delegate = self;
    self.pictureArray = [NSMutableArray new];

    self.navigationItem.title = @"Add more";
    self.navigationController.navigationBar.backgroundColor = [UIColor yellowGreen];
    self.automaticallyAdjustsScrollViewInsets = NO;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];

//    FacebookData *faceD = [FacebookData new];
//    [faceD loadFacebookThumbnails:self.nextButton arrayForPictures:self.pictureArray andCollectionView:self.collectionView];
//    self.nextURL = faceD.nextPage;
//    self.previousURL = faceD.previousPage;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.pictureArray.count;
}

-(AddImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    AddImageCell *cell = (AddImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"AddImageCell" forIndexPath:indexPath];
    Facebook *userData = [self.pictureArray objectAtIndex:indexPath.row];
    cell.image.image = [UIImage imageWithData:userData.photoData];

    return cell;
}

- (IBAction)onOtherFacebookAlbums:(UIButton *)sender
{

    [self performSegueWithIdentifier:@"FacebookAlbums" sender:self];
}


- (IBAction)onNextButton:(UIButton *)sender
{
//    FacebookData *face = [FacebookData new];
//    [face loadNextPrevPage:self.nextURL withPhotoArray:self.pictureArray andCollectionView:self.collectionView];
//    [self onNextPrevPage:self.nextURL];
}


- (IBAction)onPreviousButton:(UIButton *)sender
{
//    FacebookData *face = [FacebookData new];
//    [face loadNextPrevPage:self.previousURL withPhotoArray:self.pictureArray andCollectionView:self.collectionView];
    //[self onNextPrevPage:self.previousURL];
}
@end










