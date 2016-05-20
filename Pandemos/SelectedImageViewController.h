//
//  ChooseImageInitialViewController.h
//  Pandemos
//
//  Created by Michael Sevy on 1/11/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectedImageViewController : UIViewController

@property (strong, nonatomic) NSString *profileImage;
@property (strong, nonatomic) NSData *profileImageAsData;
@property BOOL fromCamera;
@end
