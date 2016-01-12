//
//  MessagingViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/7/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MessagingViewController.h"

@interface MessagingViewController ()<UITableViewDataSource,
UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@property (strong, nonatomic) NSArray *matchesNotYetConfirmed;

@end

@implementation MessagingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255.0/255.0 green:84.0/255.0 blue:95.0/255.0 alpha:1.0];
    //picture on nav bar
    self.navigationItem.title = @"Messages";
    //self.pfUser is current user from VC

    //self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"MessagingImage"]];
    //self.navigationItem.titleView.tintColor = [UIColor colorWithRed:255.0/255.0 green:84.0/255.0 blue:95.0/255.0 alpha:1.0];

    self.matchesNotYetConfirmed = [NSArray new];
    self.tableView.delegate = self;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    self.relation = [self.pfUser objectForKey:@"matchNotConfirmed"];
    PFQuery *query = [self.relation query];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error);
        } else{
            NSLog(@"objects: %@", objects);
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

//send Message
//PFObject *message = [PFObject objectWithClassName:@"Message"];
////making association btw files and messages
//[message setObject:file forKey:@"file"];
//[message setObject:fileType forKey:@"fileType"];
//[message setObject:self.recipients forKey:@"recipientsId"];
//[message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
//[message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
//
//[message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
//    if (error) {
//      NSLog("error: %@", error);
//
//    } else{
//        NSLog(@"message and file were uploaded to parse");
//        [self reset];

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.matchesNotYetConfirmed.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    //need a custom cell to size the image correctly
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.frame = CGRectMake(20, 0, 30, 30);

    NSString *userFirstName = [[self.matchesNotYetConfirmed objectAtIndex:indexPath.row] objectForKey:@"firstName"];
    NSString *userimage1 = [[self.matchesNotYetConfirmed objectAtIndex:indexPath.row] objectForKey:@"image1"];
    NSString *userAge = [[self.matchesNotYetConfirmed objectAtIndex:indexPath.row] objectForKey:@"userAge"];

    //cell.imageView.layer.cornerRadius = 25;
    cell.textLabel.text = userFirstName;
    cell.detailTextLabel.text = userAge;
    cell.imageView.image = [UIImage imageWithData:[self imageData:userimage1]];

    return cell;
}


#pragma mark -- helpers

-(NSData *)imageData:(NSString *)imageString{
    NSURL *url = [NSURL URLWithString:imageString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}

@end






