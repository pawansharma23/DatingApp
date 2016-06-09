//
//  MatchViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 6/8/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MatchViewController.h"
#import "User.h"
#import "UIColor+Pandemos.h"
#import "UIImage+Additions.h"
#import "DragBackground.h"

@implementation MatchViewController

-(void)viewDidLoad
{
    if ([User currentUser])
    {
        self.navigationItem.title = APP_TITLE;
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor unitedNationBlue]}];
        self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
        [self.navigationItem.rightBarButtonItem setTitle:@"Messages"];

        self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageWithImage:[UIImage imageNamed:@"aLogo"] scaledToSize:CGSizeMake(35, 35)]];

//        DraggableViewBackground *draggable = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
//        [self.view addSubview:draggable];

        DragBackground *drag = [[DragBackground alloc]initWithFrame:self.view.frame];
        [self.view addSubview:drag];

        self.automaticallyAdjustsScrollViewInsets = NO;

    }
    else
    {
        [self performSegueWithIdentifier:@"NoUser" sender:self];
    }
}
- (IBAction)onSettingsTapped:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"Settings" sender:self];
}
- (IBAction)onMessagesTapped:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"Messaging" sender:self];
}
@end
