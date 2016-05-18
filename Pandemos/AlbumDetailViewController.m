//
//  AlbumDetailViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//
#import "AlbumDetailViewController.h"
#import "UIColor+Pandemos.h"
#import "FacebookCVCell.h"
#import "SelectedImageViewController.h"
#import "Facebook.h"
#import "FacebookManager.h"
#import "User.h"
#import "UIImage+Additions.h"

@interface AlbumDetailViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
FacebookManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;

@property (strong, nonatomic) NSString *nextURL;
@property (strong, nonatomic) NSString *previousURL;
@property (strong, nonatomic) NSString *selectedImage;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) FacebookManager *manager;
@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) NSArray *albumPages;

@end

@implementation AlbumDetailViewController

static NSString * const reuseIdentifier = @"FaceCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentUser = [User currentUser];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor yellowGreen];
    self.navigationController.navigationBar.backgroundColor = [UIColor yellowGreen];

    self.navigationItem.title = self.albumName;
    UIImage *closeNavBarButton = [UIImage imageWithImage:[UIImage imageNamed:@"Back"] scaledToSize:CGSizeMake(25.0, 25.0)];
    [self.navigationItem.leftBarButtonItem setImage:closeNavBarButton];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor mikeGray];

    self.photos = [NSArray new];
    self.albumPages = [NSArray new];

    [self setupCollectionView];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (self.currentUser)
    {
        self.manager = [FacebookManager new];
        self.manager.facebookNetworker = [FacebookNetwork new];
        self.manager.facebookNetworker.delegate = self.manager;
        self.manager.delegate = self;

        [self.manager loadParsedFBAlbum:self.albumID];
    }
    else
    {
        NSLog(@"no user for face request");
    }
}

#pragma mark -- COLLECTION VIEW DELEGATE
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (FacebookCVCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FacebookCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    Facebook *face = [self.photos objectAtIndex:indexPath.item];
    cell.image.image = [UIImage imageWithData:[face stringURLToData:face.albumImageURL]];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Facebook *selectedImage = [self.photos objectAtIndex:indexPath.item];
    [self.manager loadPhotoSource:selectedImage.albumImageID];
}

#pragma mark -- DELEGATES
-(void)didReceiveParsedAlbum:(NSArray *)album
{
    self.photos = album;
    [self.collectionView reloadData];
}

-(void)didReceiveParsedAlbumPaging:(NSArray *)albumPaging
{
    self.albumPages = albumPaging;

    Facebook *nextPage = [self.albumPages firstObject];
    NSLog(@"next: %@", nextPage.nextPage);
    self.nextURL = nextPage.nextPage;

}

-(void)didReceiveParsedPhotoSource:(NSString *)photoURL
{
    self.selectedImage = photoURL;
    [self performSegueWithIdentifier:@"ChooseImage" sender:self];
}

#pragma mark -- NAV
- (IBAction)onBackButton:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onOtherFacebookAlbums:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNextButton:(UIButton *)sender
{
  //  Facebook *face = [self.albumPages firstObject];
    //pagination need to use a whole different route to call the url, not through FB network

//    [face loadNextPrevPage:self.nextURL withPhotoArray:self.pictureArray andCollectionView:self.collectionView];
//    [self onNextPrevPage:self.nextURL];
    [self.manager loadNextPage:self.nextURL];
    
    [self.collectionView reloadData];
}


- (IBAction)onPreviousButton:(UIButton *)sender
{
//    FacebookData *face = [FacebookData new];
//    [face loadNextPrevPage:self.previousURL withPhotoArray:self.pictureArray andCollectionView:self.collectionView];
    //[self onNextPrevPage:self.previousURL];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SelectedImageViewController *sivc = segue.destinationViewController;
    sivc.image = self.selectedImage;
}

#pragma mark -- HELPERS
-(void)setupCollectionView
{
    self.collectionView.delegate = self;
    self.collectionView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor grayColor]);
    self.collectionView.layer.borderWidth = 1.0;
    self.collectionView.backgroundColor = [UIColor whiteColor];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];
}
@end