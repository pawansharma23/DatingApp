//
//  ViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 12/13/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import <Bolts/BFTask.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <ParseFacebookUtilsV4.h>
#import <Parse/PFConstants.h>
#import <Parse/PFUser.h>
#import <FBSDKGraphRequest.h>
#import <FBSDKGraphRequestConnection.h>
#import "UserData.h"
#import <Parse/Parse.h>


@interface ViewController ()<FBSDKGraphRequestConnectionDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *greenButton;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UILabel *nameAndAge;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *educationLabel;


@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSString *leadImage;
@property (strong, nonatomic) NSData *leadImageData;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    self.currentUser = [PFUser currentUser];

    self.greenButton.transform = CGAffineTransformMakeRotation(M_PI / 180 * 10);
    self.redButton.transform = CGAffineTransformMakeRotation(M_PI / 180 * -10);





//    UIView *descriptionView = [[UIView alloc]initWithFrame:CGRectMake(0,0, 100, 75)];
//    descriptionView.backgroundColor = [UIColor colorWithRed:74.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:1.0];
//    [self.view addConstraint:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(descriptionView)]];
//
//
//    UILabel *usernameLabel, *jobLabel, *schoolLabel, *interestLabel;
//    usernameLabel = [[UILabel alloc]init];
//    jobLabel = [[UILabel alloc]init];
//    schoolLabel = [[UILabel alloc]init];
//    interestLabel = [[UILabel alloc]init];
//
//    [descriptionView addSubview:usernameLabel];
//    [descriptionView addSubview:jobLabel];



    //self.userImage.backgroundColor = [UIColor blackColor];




    //[self.view addSubview:descriptionView];
}


-(void)viewDidAppear:(BOOL)animated{

    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){
            //job and education label
            NSString *firstname = [[objects firstObject] objectForKey:@"firstName"];
            NSString *age = [[objects firstObject]objectForKey:@"birthday"];
            NSDateFormatter *formatter = [NSDateFormatter new];
            [formatter setDateFormat:@"MM/DD/YYY"];
            NSDate *birthday = [formatter dateFromString:age];
            NSDate *nowDate = [NSDate date];
            //double secSinceBirth = [birthday timeIntervalSinceNow];
            //int realAge = secSinceBirth / (86400);
            //int realAgerem = realAge / (365);
            //double realAgemin = realAgerem / 60;

            NSDateComponents *ageCom = [[NSCalendar currentCalendar]components:NSCalendarUnitYear fromDate:birthday toDate:nowDate options:0];
            NSInteger ageInt = [ageCom year];
            NSString *ageString = [NSString stringWithFormat:@"%@, %zd", firstname, ageInt];
            NSString *job = [[objects firstObject] objectForKey:@"work"];
            NSString *school = [[objects firstObject] objectForKey:@"scool"];
            self.nameAndAge.text = ageString;
            self.jobLabel.text = job;
            self.educationLabel.text = school;

            NSArray * imagesStr = [[objects firstObject]objectForKey:@"selectedUserImages"];
            self.leadImageData = [[objects firstObject]objectForKey:@"selectedUserImages"];
            //NSData *seondImageData = [[objects objectAtIndex:1]objectForKey:@"selectedUserImages"];
            //UserData *images = [[objects firstObject] objectForKey:@"selectedUserImages"];
            NSLog(@"image ID tag from top: %@", imagesStr[0]);
            NSURL *urlObject = [[objects firstObject]objectForKey:@"selectedUserImages"];

            NSInteger count = [imagesStr count];
            NSLog(@"image available: %ld", (long)count);
            self.leadImage = imagesStr[0];
            NSLog(@"full array print: %@", urlObject);

            NSLog(@"image some class1: %@", self.leadImage);
            //            NSLog(@"image some class2: %@", self.leadImageData);

            self.userImage.image = [UIImage imageWithData:imagesStr[0]];
            //            NSString *className = NSStringFromClass([self.leadImageData class]);

            
            //            NSLog(@"image some class3: %@", className);
            
            
            
            
            
            
            
            
        }
    }];

}


- (IBAction)onYesButton:(UIButton *)sender {

    [self makeImageCall];



}




- (IBAction)onXButton:(UIButton *)sender {



}


-(void)makeImageCall{
    //params: @{@"fields": @"id, link"}   http://graph.facebook.com/10153744912065061/picture
    NSString *graphPath = [NSString stringWithFormat:@"//%@", self.leadImage];
    NSString *path = @"/10153744912065061";
    NSLog(@"print this out: %@", self.leadImage);
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:graphPath
                                  parameters:@{@"fields": @"id, images"}
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
            //NSLog(@"results: %@", result);
            NSArray *images = result[@"images"];
            NSDictionary *imageDict = [images firstObject];
            NSString *imageSource = imageDict[@"source"];
            NSLog(@"source: %@", imageSource);
            NSURL *url = [NSURL URLWithString:imageSource];
            NSData *data = [NSData dataWithContentsOfURL:url];
            self.userImage.image = [UIImage imageWithData:data];
//            for (NSString *imageSrc in imageDict) {
//                NSLog(@"orignial pic: %@", [imageSrc containsString:o.jpg]);
//            }
        } else {
            NSLog(@"error: %@", error);
        }
    }];
}

@end








