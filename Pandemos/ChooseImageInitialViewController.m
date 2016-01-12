//
//  ChooseImageInitialViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/11/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "ChooseImageInitialViewController.h"


@interface ChooseImageInitialViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *saveImage;

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
            
            //[self.collectionView reloadData];
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onSaveImage:(UIButton *)sender {

    if (!self.image1) {
        NSLog(@"nothing in 1");
        [self.currentUser setObject:self.image1 forKey:@"image1"];
        [self.currentUser saveInBackground];
        [self.saveImage setTitle:@"Save as Image 1" forState:UIControlStateNormal];

    } else if (self.image1 && !self.image2) {

        NSLog(@"1 occupied, 2 empty");
        [self.currentUser setObject:self.image2 forKey:@"image2"];
        [self.currentUser saveInBackground];

    } else if (self.image1 && self.image2 && !self.image3){
        NSLog(@"1 & 2 occ, 3 empty");
        [self.currentUser setObject:self.image3 forKey:@"image3"];
        [self.currentUser saveInBackground];

    } else if (self.image1 && self.image2 && self.image3 && !self.image4){
        NSLog(@"1, 2, 3 occ, 4 empty");
        [self.currentUser setObject:self.image4 forKey:@"image4"];
        [self.currentUser saveInBackground];

    } else if (self.image1 && self.image2 && self.image3 && self.image4 && !self.image5){

        NSLog(@"1, 2, 3, 4 occ 5 empty");
        [self.currentUser setObject:self.image5 forKey:@"image5"];
        [self.currentUser saveInBackground];

    } else if (self.image1 && self.image2 && self.image3 && self.image4 && self.image5 && !self.image6){

        NSLog(@"1, 2, 3, 4, 5 occ 6 empty");
        [self.currentUser setObject:self.image6 forKey:@"image6"];
        [self.currentUser saveInBackground];

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



@end
