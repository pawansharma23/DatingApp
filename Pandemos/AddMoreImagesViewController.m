//
//  AddMoreImagesViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "AddMoreImagesViewController.h"
#import <FBSDKGraphRequestConnection.h>
#import "UserData.h"
#import "AddImageCell.h"


@interface AddMoreImagesViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (strong, nonatomic) NSMutableArray *pictureArray;
@property (strong, nonatomic) NSString *nextURL;

@end

@implementation AddMoreImagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionView.delegate = self;
    self.pictureArray = [NSMutableArray new];

    self.navigationItem.title = @"Add More";
    self.navigationController.navigationBar.backgroundColor = [UserData yellowGreen];

    self.automaticallyAdjustsScrollViewInsets = NO;


    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];

    UserData *userD = [UserData new];
    [userD loadFacebookThumbnails:self.nextButton arrayForPictures:self.pictureArray andCollectionView:self.collectionView];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pictureArray.count;
}

-(AddImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"AddImageCell";
    AddImageCell *cell = (AddImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UserData *userData = [self.pictureArray objectAtIndex:indexPath.row];
    cell.image.image = [UIImage imageWithData:userData.photosData];

    return cell;
}



- (IBAction)onNextButton:(UIButton *)sender {
}


- (IBAction)onPreviousButton:(UIButton *)sender {
}



@end










