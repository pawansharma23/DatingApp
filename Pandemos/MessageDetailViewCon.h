//
//  MessageDetailViewCon.h
//  Pandemos
//
//  Created by Michael Sevy on 1/13/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFUser.h>
#import <Parse/Parse.h>


@interface MessageDetailViewCon : UIViewController

@property (strong, nonatomic) PFUser *recipient;

@end
