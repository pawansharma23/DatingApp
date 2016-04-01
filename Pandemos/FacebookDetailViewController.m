//
//  FacebookDetailViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "FacebookDetailViewController.h"
#import "FacebookCVCell.h"
#import "AlbumDetailCollectionVC.h"
#import "UIColor+Pandemos.h"
#import "Facebook.h"
#import "ChooseImageInitialViewController.h"

@interface FacebookDetailViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate>

@property (strong, nonatomic) NSMutableArray *pictureArray;
@property (strong, nonatomic) NSString *nextURL;
@property (strong, nonatomic) NSString *previousURL;
@property (strong, nonatomic) NSString *photoURL;
@property (strong, nonatomic) NSData *photoData;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation FacebookDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.loadingView.alpha = .75;
    self.loadingView.layer.cornerRadius = 8;
    
    self.navigationItem.title = self.albumName;
    self.navigationController.navigationBar.backgroundColor = [UIColor yellowGreen];
    
    self.collectionView.delegate = self;
    self.pictureArray = [NSMutableArray new];

    self.collectionView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor grayColor]);
    self.collectionView.layer.borderWidth = 1.0;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];

//    FacebookData *face = [FacebookData new];
//    [face loadFacebookAlbum:self.albumId withPhotoArray:self.pictureArray andCollectionView:self.collectionView];

}


#pragma mark -- collectionView delegate Methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pictureArray.count;
}

-(FacebookCVCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    FacebookData *face = [self.pictureArray objectAtIndex:indexPath.item];
//    static NSString *cellIdentifier = @"Cell";
//    FacebookCVCell *cell = (FacebookCVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
//    cell.image.image = [UIImage imageWithData:face.photoData];
    FacebookCVCell * cell = [self.pictureArray objectAtIndex:indexPath.row];

    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Facebook *selectedPath = [self.pictureArray objectAtIndex:indexPath.row];
//    self.photoURL = selectedPath.photoID;
//    self.photoData = selectedPath.photoData;
    NSLog(@"photo URL: %@", selectedPath.photoCount);

    [self performSegueWithIdentifier:@"ChooseImageVC" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ChooseImageVC"])
    {
        ChooseImageInitialViewController *civc = segue.destinationViewController;
        civc.photoID = self.photoURL;
        civc.photoData = self.photoData;
    }
}
@end






