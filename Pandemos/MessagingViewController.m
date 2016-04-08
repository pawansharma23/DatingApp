//
//  MessagingViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/7/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MessagingViewController.h"
#import "MessagingCell.h"
#import "MessageDetailViewCon.h"
#import <Parse/PFUser.h>
#import "UIColor+Pandemos.h"
#import "User.h"

@interface MessagingViewController ()
<UITableViewDataSource,
UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) User *recipientUser;
@property (strong, nonatomic) NSArray *matchesNotYetConfirmed;


@end

@implementation MessagingViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    self.currentUser = [User currentUser];

    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
    self.navigationItem.title = @"Messages";

    self.matchesNotYetConfirmed = [NSArray new];
    self.tableView.delegate = self;

    self.automaticallyAdjustsScrollViewInsets = NO;


}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    self.relation = [self.currentUser objectForKey:@"matchNotConfirmed"];
    PFQuery *query = [self.relation query];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error);
        } else{
           // NSLog(@"objects: %@", objects);

            self.matchesNotYetConfirmed = objects;
            [self.tableView reloadData];
        }
    }];
}

//recieve message
//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//
//    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
//    [query whereKey:@"recipientsId" equalTo:[[PFUser currentUser] objectId]];
//    [query orderByDescending:@"createdAt"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
//        if(error){
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        } else {
//            self.messages = objects;
//            [self.tableView reloadData];
//            NSLog(@"retrived %lu messages", self.messages.count);
//        }
//    }];
//
//}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.matchesNotYetConfirmed.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessagingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    cell.userImage.contentMode = UIViewContentModeScaleAspectFill;

    PFUser *userSelected = [self.matchesNotYetConfirmed objectAtIndex:indexPath.row];
    NSString *userimage1 = [userSelected objectForKey:@"image1"];
    NSString *name = [userSelected objectForKey:@"firstName"];

    cell.userImage.layer.cornerRadius = 22.0 / 2.0f;
    cell.userImage.clipsToBounds = YES;

    cell.lastMessage.text = name;
    cell.lastMessageTime.text = userSelected.objectId;
    cell.userImage.image = [UIImage imageWithData:[self imageData:userimage1]];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.recipientUser = [self.matchesNotYetConfirmed objectAtIndex:indexPath.row];

    [self performSegueWithIdentifier:@"MessageDetail" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MessageDetailViewCon *mdvc = segue.destinationViewController;
    mdvc.recipient = self.recipientUser;
}


#pragma mark -- HELPERS
-(NSData *)imageData:(NSString *)imageString
{
    NSURL *url = [NSURL URLWithString:imageString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}
@end






