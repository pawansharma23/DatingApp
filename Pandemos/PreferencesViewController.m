//
//  PreferencesViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 12/19/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import "PreferencesViewController.h"

@interface PreferencesViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"image from Pref: %@", self.image);
    self.userImage.image = [UIImage imageWithData:[self imageData:self.image]];
}


-(NSData *)imageData:(NSString *)imageString{

    NSURL *url = [NSURL URLWithString:imageString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}

@end
