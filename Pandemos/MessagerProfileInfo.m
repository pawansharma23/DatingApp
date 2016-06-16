//
//  MessagerProfileInfo.m
//  Pandemos
//
//  Created by Michael Sevy on 6/5/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MessagerProfileInfo.h"
#import "UIImage+Additions.h"
#import "MessagerProfileVC.h"
#import "MessagerTopCell.h"
#import "UIColor+Pandemos.h"
#import "UserManager.h"
#import "User.h"
#import <UIKit/UIDynamicBehavior.h>

@interface MessagerProfileInfo ()
@property (strong, nonatomic) UserManager *usermanager;
@property (strong, nonatomic) NSString *imageStr;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) User *selectedUser;
@end

@implementation MessagerProfileInfo

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];

    UIImage *closeNavBarButton = [UIImage imageWithImage:[UIImage imageNamed:@"Back"] scaledToSize:CGSizeMake(30.0, 30.0)];
    [self.navigationController.navigationItem.leftBarButtonItem setImage:closeNavBarButton];

    self.usermanager = [UserManager new];

    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
}

-(void)viewDidAppear:(BOOL)animated
{

    [self.usermanager queryForUserData:self.messagingUser.objectId withUser:^(User *user, NSError *error) {

        if (user)
        {
            NSArray *arr = user[@"profileImages"];
            self.imageStr = arr.firstObject;
            self.name = user[@"givenName"];
            self.selectedUser = user;
        }
        else
        {
            NSLog(@"no user");
        }

        [self.tableView reloadData];
    }];

}

#pragma mark - TABLEVIEW DELGATES

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 16;
            break;
        case 1:
            return 32;
            break;
        case 2:
            return 0;
            break;
        case 3:
            return 0;
        default:
            break;
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            return 150;
            break;
        case 1:
            return 30;
            break;
        case 2:
            return 30;
            break;
        case 3:
            return 30;
            break;
        default:
            return 0;
            break;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
        default:
            return 0;
            break;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessagerTopCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    switch (indexPath.section)
    {
        case 0:
            cell.textLabel.frame = CGRectMake(0, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width, cell.textLabel.frame.size.height);
            cell.imageView.frame = CGRectMake(75, 75, 100, 100);
            cell.imageView.layer.cornerRadius = 50;
            cell.imageView.layer.masksToBounds = YES;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.imageView.image = [UIImage imageWithImage:[UIImage imageWithString:self.imageStr] scaledToSize:CGSizeMake(100, 100)];
            cell.textLabel.text = self.name;
            return cell;
            break;
        case 1:
            cell.imageView.image = [UIImage imageWithImage:[UIImage imageNamed:@"profile"] scaledToSize:CGSizeMake(23, 23)];
            cell.textLabel.text = @"View profile";
            return cell;
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"Unmatch with %@", self.name];
            return cell;
            break;
        case 3:
            cell.textLabel.text = [NSString stringWithFormat:@"Block and Report %@", self.name];
            return cell;
        default:
            return cell;
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            break;
        case 1:
            [self performSegueWithIdentifier:@"toMessagerProfile" sender:self];
            break;
        case 2:
            [self addUnmatchConfirmAlert:self.selectedUser];
            break;
        case 3:
            [self addBlockConfirmAlert:self.selectedUser];

            //send report email to Ally webmaster
        default:
            break;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toMessagerProfile"])
    {
        MessagerProfileVC *mpvc = segue.destinationViewController;
        mpvc.messagingUser = self.messagingUser;
    }
}

-(void)addBlockConfirmAlert:(User *)chatter
{
    NSString *userName = [NSString stringWithFormat:@"Confirm block: %@", chatter.givenName];
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:userName
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];


    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Block"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //add another pfrelation to the relationship: blocked, check this during downloading Messaging list
                             [self.usermanager changePFRelationToDeniedWithPFCloudFunction:chatter];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:^{

                                 }];
                             }];


    [alert addAction:cancel];
    [alert addAction:ok];

//    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
//
//    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc]initWithItem:alert snapToPoint:self.view.center];
//    snapBehavior.damping = 0.65f;
//    [animator addBehavior:snapBehavior];
//
//    UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[alert]];
//    gravityBehaviour.gravityDirection = CGVectorMake(0, 10);
//    [animator addBehavior:gravityBehaviour];
//
//    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[alert]];
//    [itemBehaviour addAngularVelocity:-M_PI_2 forItem:alert];
//    [animator addBehavior:itemBehaviour];


    [self presentViewController:alert animated:YES completion:nil];

}


-(void)addUnmatchConfirmAlert:(User *)chatter
{
    NSString *userName = [NSString stringWithFormat:@"Confirm unmatching %@", chatter.givenName];
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:userName
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Unmatch"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //add another pfrelation to the relationship: blocked, check this during downloading Messaging list
                             [self.usermanager changePFRelationToDeniedWithPFCloudFunction:chatter];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:^{

                                 }];
                             }];

    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
