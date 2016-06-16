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
#import "AppConstants.h"

@interface MatchViewController()
@property (strong, nonatomic) UIButton *button;
@end
//static float CARD_HEIGHT;
//static float CARD_WIDTH;

@implementation MatchViewController

-(void)viewDidLoad
{
    if ([User currentUser].givenName)
    {
        NSLog(@"logged in user: %@", [User currentUser].givenName);

        self.navigationItem.title = APP_TITLE;
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor mikeGray]}];
        self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];

        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor mikeGray]];
        //self.navigationItem.rightBarButtonItem.title = @"Chats";
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"chatEmpty"];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor mikeGray];

        self.navigationItem.leftBarButtonItem.image = [UIImage imageWithImage:[UIImage imageNamed:@"emptySettings"] scaledToSize:CGSizeMake(30, 30)];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor mikeGray];

        DragBackground *drag = [[DragBackground alloc]initWithFrame:self.view.frame];
        [self.view addSubview:drag];

        self.automaticallyAdjustsScrollViewInsets = NO;

        self.button = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 20, 20)];
        [self.button setTitle:@"To Init Setup" forState:UIControlStateNormal];
        self.button.backgroundColor = [UIColor blackColor];
        self.button.layer.cornerRadius = 10;
        self.button.layer.masksToBounds = YES;
        [self.view addSubview:self.button];
        [self.button addTarget:self action:@selector(segueToNoUser:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [self performSegueWithIdentifier:@"NoUser" sender:self];
    }
}

-(void)segueToNoUser:(UIButton*)sender
{
    [self performSegueWithIdentifier:@"NoUser" sender:self.button];
}

- (IBAction)onSettingsTapped:(UIBarButtonItem *)sender
{
    self.navigationItem.leftBarButtonItem.image = [UIImage imageWithImage:[UIImage imageNamed:@"filledSettings"] scaledToSize:CGSizeMake(30, 30)];
    [self performSegueWithIdentifier:@"Settings" sender:self];
}
- (IBAction)onMessagesTapped:(UIBarButtonItem *)sender
{
    self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"chatFilled2"];
    [self performSegueWithIdentifier:@"Messaging" sender:self];
}
@end
