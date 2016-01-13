//
//  ChooseImageInitialViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/11/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "ChooseImageInitialViewController.h"
#import <LXReorderableCollectionViewFlowLayout.h>
#import "CVImageCell.h"

@interface ChooseImageInitialViewController ()<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
LXReorderableCollectionViewDataSource,
LXReorderableCollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *saveImage;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *pictures;

@property (strong, nonatomic) NSString *image1;
@property (strong, nonatomic) NSString *image2;
@property (strong, nonatomic) NSString *image3;
@property (strong, nonatomic) NSString *image4;
@property (strong, nonatomic) NSString *image5;
@property (strong, nonatomic) NSString *image6;




@end

@implementation ChooseImageInitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Choose Your Pics";
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:193.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    self.userImage.image = [UIImage imageWithData:[self imageData:self.imageStr]];
    self.pictures = [NSMutableArray new];
    self.collectionView.delegate = self;
    self.collectionView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor grayColor]);
    self.collectionView.layer.borderWidth = 1.0;

    LXReorderableCollectionViewFlowLayout *flowlayouts = [LXReorderableCollectionViewFlowLayout new];
    [flowlayouts setItemSize:CGSizeMake(100, 100)];
    [flowlayouts setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowlayouts.sectionInset = UIEdgeInsetsMake(5, 0, 5, 0);
    [self.collectionView setCollectionViewLayout:flowlayouts];

    self.collectionView.backgroundColor = [UIColor whiteColor];

    //get "no data" from backend
    PFQuery *query = [PFUser query];

    //this is quering the user info from the PFUser cached in sim, which is not the usr that is logged in??
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){

            //userImages
            self.image1 = [[objects firstObject] objectForKey:@"image1"];
            self.image2 = [[objects firstObject] objectForKey:@"image2"];
            self.image3 = [[objects firstObject] objectForKey:@"image3"];
            self.image4 = [[objects firstObject] objectForKey:@"image4"];
            self.image5 = [[objects firstObject] objectForKey:@"image5"];
            self.image6 = [[objects firstObject] objectForKey:@"image6"];

            if (self.image1) {
                [self.pictures addObject:self.image1];
            } if (self.image2) {
                [self.pictures addObject:self.image2];
            } if (self.image3) {
                [self.pictures addObject:self.image3];
            } if (self.image4) {
                [self.pictures addObject:self.image4];
            } if (self.image5) {
                [self.pictures addObject:self.image5];
            } if (self.image6) {
                [self.pictures addObject:self.image6];
            }
            //NSLog(@"picture array: %@", self.pictures);

            [self.collectionView reloadData];
        }
    }];

}


#pragma mark -- collectionView delegate Methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pictures.count;
}

-(CVImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"CVCell";
    CVImageCell *cell = (CVImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    NSString *photoString = [self.pictures objectAtIndex:indexPath.item];
    cell.cvImage.image = [UIImage imageWithData:[self imageData:photoString]];

    return cell;
}
//save selected images to array and save to Parse
//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
//    //highlight selected cell... not working
//    UICollectionViewCell *cell = [collectionView  cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor blueColor];
//
//}


-(void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    NSString *photoString = [self.pictures objectAtIndex:fromIndexPath.item];

    [self.pictures removeObjectAtIndex:fromIndexPath.item];
    [self.pictures insertObject:photoString atIndex:toIndexPath.item];

    [self deconstructArray:self.pictures];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath    {

    NSLog(@"dragging cell begun");

}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath  {

    NSLog(@"dragging has stopped");
    
}





- (IBAction)onSaveImage:(UIButton *)sender {

    if (!self.image1) {
        NSLog(@"nothing in 1");
        [self.currentUser setObject:self.imageStr forKey:@"image1"];

        [self.currentUser saveInBackground];
        [self.saveImage setTitle:@"Save as Image 1" forState:UIControlStateNormal];

        [self.collectionView reloadData];

    } else if (self.image1 && !self.image2) {

        NSLog(@"1 occupied, 2 empty");
        [self.currentUser setObject:self.imageStr forKey:@"image2"];
        [self.currentUser saveInBackground];
        [self.collectionView reloadData];

    } else if (self.image1 && self.image2 && !self.image3){
        NSLog(@"1 & 2 occ, 3 empty");
        [self.currentUser setObject:self.imageStr forKey:@"image3"];
        [self.currentUser saveInBackground];

        [self.collectionView reloadData];

    } else if (self.image1 && self.image2 && self.image3 && !self.image4){
        NSLog(@"1, 2, 3 occ, 4 empty");
        [self.currentUser setObject:self.imageStr forKey:@"image4"];

        [self.currentUser saveInBackground];
        [self.collectionView reloadData];

    } else if (self.image1 && self.image2 && self.image3 && self.image4 && !self.image5){

        NSLog(@"1, 2, 3, 4 occ 5 empty");

        [self.currentUser setObject:self.imageStr forKey:@"image5"];
        [self.currentUser saveInBackground];
        [self.collectionView reloadData];

    } else if (self.image1 && self.image2 && self.image3 && self.image4 && self.image5 && !self.image6){

        NSLog(@"1, 2, 3, 4, 5 occ 6 empty");
        [self.currentUser setObject:self.imageStr forKey:@"image6"];

        [self.currentUser saveInBackground];
        [self.collectionView reloadData];
        
    }else{
            NSLog(@"all images Filled");
        [self.saveImage setTitle:@"All Full :(" forState:UIControlStateNormal];

        }
}


#pragma mark -- helpers
-(NSData *)imageData:(NSString *)imageString{
    NSURL *url = [NSURL URLWithString:imageString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
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


@end
