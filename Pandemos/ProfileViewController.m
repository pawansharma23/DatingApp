//
//  ProfileViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 12/19/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import "ProfileViewController.h"
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


@interface ProfileViewController ()
@property (strong, nonatomic) PFUser *currentUser;



@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];
    self.navigationController.navigationItem.title = @"Profile Info";

    
}


-(void)viewDidAppear:(BOOL)animated {

    if(!_currentUser) {
        NSLog(@"No pf user: %@", _currentUser);
        [self performSegueWithIdentifier:@"NoUserLogOut" sender:self];
    } else{
        NSLog(@"user is logged in: %@", _currentUser);
    }
}


- (IBAction)logOutButton:(UIButton *)sender {

    [PFUser logOut];
    [self performSegueWithIdentifier:@"LoggedOut" sender:self];

}

- (IBAction)userViewButton:(UIButton *)sender {


}

#pragma mark -- helpers

- (void)_loadData {

    //    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:permissionsArray];
    //    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, about, birthday, gender, bio, education, is_verified, locale, first_name, work, location, likes"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        ///{user-id}
        if (!error) {
            NSDictionary *userData = (NSDictionary *)result;
            // NSLog(@"dictionary of results: %@", userData);

            NSString *facebookID = userData[@"id"];
            //BOOL isVerified = userData[@"is_verified"];
            NSString *fullName = userData[@"name"];
            NSString *firstName = userData[@"first_name"];
            NSString *birthdayStr = userData[@"birthday"];
            NSString *gender = userData[@"gender"];
            // NSString *locale = userData[@"locale"];
            // NSString *lastName = userData[@"gender"];
            NSString *location = userData[@"location"][@"name"];
            NSLog(@"location from below: %@", location);
            //work array
            NSArray *workArray = userData[@"work"];
            NSDictionary *employerDict = [workArray lastObject];
            NSString *placeOfWork = employerDict[@"employer"][@"name"];
            NSLog(@"place of work: %@", placeOfWork);
            //education array
            NSArray *educationArray = userData[@"education"];
            NSDictionary *schoolDict = [educationArray lastObject];
            NSString *school = schoolDict[@"school"][@"name"];
            NSLog(@"last school acheived: %@", school);
            //likes array
            NSDictionary *likes = userData[@"likes"];
            NSArray *likeArray = likes[@"data"];
            for (NSDictionary *like in likeArray) {
                NSLog(@"like: %@", like[@"name"]);
            }
            UserData *locUser = [UserData new];
            locUser.fullName = fullName;
            locUser.firstName = firstName;
            locUser.birthdayString = birthdayStr;

            //PFUser *myUser = [PFUser user];
            [self.currentUser setObject:fullName forKey:@"fullName"];
            [self.currentUser setObject:firstName forKey:@"firstName"];
            [self.currentUser setObject:facebookID forKey:@"faceID"];
            [self.currentUser setObject:birthdayStr forKey:@"birthday"];
            [self.currentUser setObject:gender forKey:@"gender"];
            [self.currentUser setObject:location forKey:@"facebookLocation"];
            [self.currentUser setObject:placeOfWork forKey:@"work"];
            [self.currentUser setObject:school forKey:@"scool"];



            [_currentUser saveInBackground];

           // NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];

            //self.userImage.image = [UIImage imageWithData:[self convertURLToData:pictureURL]];
            
            
        }
    }];
    
    
    
    
}

-(NSData *)convertURLToData:(NSURL *)url{
    
    NSURL *imageURL = url;
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
    return imageData;
}


@end
