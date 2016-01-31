//
//  MessageDetailViewCon.m
//  Pandemos
//
//  Created by Michael Sevy on 1/13/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MessageDetailViewCon.h"
#import "MessageDetailCell.h"
#import "MessagingViewController.h"
#import <Parse/PFConstants.h>
#import <Parse/PFUser.h>
#import <Parse/Parse.h>
#import "UserData.h"
//#import "PFCollectionViewCell.h"
//#import "PFQueryCollectionViewController.h"


#define TABBAR_HEIGHT 49.0f
#define TEXTFIELD_HEIGHT 70.0f
#define MAX_ENTRIES_LOADED 50

@interface MessageDetailViewCon ()<UITextFieldDelegate,
//UICollectionViewDataSource,
//UICollectionViewDelegate
UITableViewDataSource,
UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
//@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property BOOL reloading;
@property (strong, nonatomic) NSMutableArray *chatData;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSString *user;

@end

@implementation MessageDetailViewCon
//@synthesize textField;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];
    //NSLog(@"reciepient PFUser: %@", self.recipient);
    NSString *userName = [self.currentUser objectForKey:@"firstName"];
    NSString *repName = [self.recipient objectForKey:@"firstName"];

    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"recipientId" equalTo:self.currentUser];
    [query whereKey:@"recipientId" equalTo:self.recipient];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error in VDL: %@", error);
        }

        if (objects.count == 0) {
            NSLog(@"convo between %@ & %@ has no chats yet", userName, repName);
        } else  {
        PFUser *chat1 = [objects objectAtIndex:0];
        NSString *text = [chat1 objectForKey:@"text"];

            NSLog(@"convo between: %@ & %@ ID: %@\n chats:%@", userName, repName, self.recipient.objectId, text);
        }
     }];


    self.navigationItem.title = @"Chat";
    self.navigationController.navigationBar.backgroundColor = [UserData rubyRed];
    
    _textField.delegate =self;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;

    self.tableView.delegate = self;
    self.user = [NSString new];

    NSLog(@"recipient: %@ & user: %@", [self.recipient objectId], [self.currentUser objectId]);

//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(startRefresh:)
//             forControlEvents:UIControlEventValueChanged];
//    [self.collectionView addSubview:refreshControl];






}
-(void)viewWillAppear:(BOOL)animated{

    self.chatData = [NSMutableArray new];
    [self loadLocalChat];
}

- (void)viewDidUnload   {
    [super viewDidUnload];
    [self freeKeyboardNotifications];
}

#pragma mark -- TextField Entry of Message
- (IBAction)textFieldDoneEditing:(UITextField *)sender {
    NSLog(@"text entry: %@", _textField.text);



    [sender resignFirstResponder];
    [self.textField resignFirstResponder];
    
}

-(IBAction) backgroundTap:(id) sender   {
    [self.textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textFielder    {
    NSLog(@"text entry: %@", _textField.text);
    [textFielder resignFirstResponder];

    if (self.textField.text.length > 0) {
        // updating the table immediately
        NSArray *keys = [NSArray arrayWithObjects:@"text", @"userName", @"date", nil];
        NSArray *objects = [NSArray arrayWithObjects:_textField.text, self.currentUser, [NSDate date], nil];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [self.chatData addObject:dictionary];

        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [insertIndexPaths addObject:newPath];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        [self.tableView reloadData];

        // save message in Parse
        PFObject *newMessage = [PFObject objectWithClassName:@"Chat"];
        [newMessage setObject:self.recipient forKey:@"recipientId"];
        [newMessage setObject:self.currentUser forKey:@"senderId"];
//        [newMessage setObject:[self.recipient objectId] forKey:@"recipientId"];
//        [newMessage setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
//        [newMessage setObject:[[PFUser currentUser] username] forKey:@"senderName"];
        [newMessage setObject:self.textField.text forKey:@"text"];
        //[newMessage setObject:self.user forKey:@"userName"];
        [newMessage setObject:[NSDate date] forKey:@"date"];
        [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                NSLog(@"error saving message: %@", error);
            } else {
                NSLog(@"saved message: %s", succeeded ? "true" : "false");
            }
        }];
        //reset textField
        self.textField.text = @"";
    }

    // reload the data
    [self loadLocalChat];
    return NO;
}








#pragma mark -- tableView delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatData.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier: @"Cell"];
    NSUInteger row = [_chatData count]-[indexPath row]-1;

    if (row < _chatData.count){
        NSString *chatText = [[_chatData objectAtIndex:row] objectForKey:@"text"];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize size = [chatText sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]}];

        cell.textLabel.frame = CGRectMake(75, 14, size.width +20, size.height + 20);
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        cell.textLabel.text = chatText;
        [cell.textLabel sizeToFit];

        NSDate *theDate = [[_chatData objectAtIndex:row] objectForKey:@"date"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm a"];
        NSString *timeString = [formatter stringFromDate:theDate];
        cell.detailTextLabel.text = timeString;

    }
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
//    NSString *cellText = [[_chatData objectAtIndex:_chatData.count-indexPath.row-1] objectForKey:@"text"];
//    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:14.0];
//    CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);
//    CGFloat labelSize = [cellText boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]} context:nil];
//
//    return labelSize;
//
//}


#pragma mark -- helpers
-(void)reloadTableViewDataSource{

    self.reloading = YES;
    [self loadLocalChat];
    [self.tableView reloadData];
}

-(void)doneLoadingCollectionViewData{
    self.reloading = NO;
    //[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:chatTable];
}


//keyboard methods
-(void) registerForKeyboardNotifications    {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


-(void) freeKeyboardNotifications   {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


-(void) keyboardWasShown:(NSNotification*)aNotification {
    NSLog(@"Keyboard was shown");
    NSDictionary* info = [aNotification userInfo];

    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y- keyboardFrame.size.height+TABBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];

    [UIView commitAnimations];

}


-(void) keyboardWillHide:(NSNotification*)aNotification     {

    NSLog(@"Keyboard will hide");
    NSDictionary* info = [aNotification userInfo];

    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardFrame.size.height-TABBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];

    [UIView commitAnimations];
}

-(void)loadLocalChat{

    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    //query to user and recipient specific
    [query whereKey:@"recipientId" equalTo:self.currentUser];

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([_chatData count] == 0) {
        NSLog(@"no chat data");
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [query orderByAscending:@"createdAt"];
        NSLog(@"Trying to retrieve from cache");


        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %zd chats from cache.", objects.count);
                [_chatData removeAllObjects];
                [_chatData addObjectsFromArray:objects];
                [self.tableView reloadData];
            } else {
                // Log details of the failure
                NSLog(@"Error Above: %@ %@", error, [error userInfo]);
            }
        }];
    }

    PFQuery *query2 = [PFQuery queryWithClassName:@"Chat"];
    [query2 whereKey:@"recipientId" equalTo:self.currentUser];
    [query2 orderByDescending:@"createdAt"];

    __block int totalNumberOfEntries = 0;
    [query2 countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            // The count request succeeded. Log the count
            NSLog(@"There are currently %d entries", number);
            totalNumberOfEntries = number;
            if (totalNumberOfEntries > [_chatData count]) {
                NSLog(@"Retrieving data");
                long theLimit;
                if (totalNumberOfEntries-[_chatData count]> 25) {
                    theLimit = 25;
                }
                else {
                    theLimit = (long)totalNumberOfEntries-[_chatData count];
                }
                query2.limit = (long)[NSNumber numberWithLong:theLimit];
                [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        // The find succeeded.
                        NSLog(@"Successfully retrieved %zd chats.", objects.count);
                        [_chatData addObjectsFromArray:objects];
                        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                        for (int ind = 0; ind < objects.count; ind++) {
                            NSIndexPath *newPath = [NSIndexPath indexPathForRow:ind inSection:0];
                            [insertIndexPaths addObject:newPath];
                        }
                        [self.tableView beginUpdates];
                        [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                        [self.tableView endUpdates];
                        [self.tableView reloadData];
                        [self.tableView scrollsToTop];
                    } else {
                        // Log details of the failure
                        NSLog(@"Error below: %@ %@", error, [error userInfo]);
                    }
                }];
            }

        } else {
            // The request failed, we'll keep the chatData count?
            number = (int)[_chatData count];
        }
    }];

}




@end

//old code
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

