//
//  MessagingViewController.h
//  Pandemos
//
//  Created by Michael Sevy on 1/7/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import <Parse/Parse.h>

@interface MessagingList : UIViewController

@property (strong, nonatomic) User *pfUser;
@property (strong, nonatomic) PFRelation *relation;

@end
