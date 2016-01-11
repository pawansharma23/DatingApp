//
//  MessagingViewController.h
//  Pandemos
//
//  Created by Michael Sevy on 1/7/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <UIKit/UIKit.h>
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

@interface MessagingViewController : UIViewController

@property (strong, nonatomic) PFUser *pfUser;
@property (strong, nonatomic) PFRelation *relation;

@end
