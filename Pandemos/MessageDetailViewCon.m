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
#import "PFCollectionViewCell.h"
#import "PFQueryCollectionViewController.h"


#define TABBAR_HEIGHT 49.0f
#define TEXTFIELD_HEIGHT 70.0f
#define MAX_ENTRIES_LOADED 50

@interface MessageDetailViewCon ()<UITextFieldDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property BOOL reloading;
@property (strong, nonatomic) NSMutableArray *chatData;
@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation MessageDetailViewCon
@synthesize textField;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];
    NSLog(@"reciepient PFUser: %@", self.recipient);
    NSString *userName = [self.currentUser objectForKey:@"firstName"];
    NSString *repName = [self.recipient objectForKey:@"firstName"];
    NSLog(@"convo between: %@ & %@ ID: %@", userName, repName, self.recipient.objectId);

    self.navigationItem.title = @"Chat";
    self.navigationController.navigationBar.backgroundColor = [UserData rubyRed];
    
    textField.delegate =self;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;

    self.collectionView.delegate = self;
    self.chatData = [NSMutableArray new];

    
    self.chatData = [NSMutableArray arrayWithObjects:@"well hello there", @"Beautiful day outside, huh", @"well what do you know?", nil];

//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(startRefresh:)
//             forControlEvents:UIControlEventValueChanged];
//    [self.collectionView addSubview:refreshControl];


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

}

- (void)viewDidUnload   {
    [super viewDidUnload];
    [self freeKeyboardNotifications];
}

#pragma mark -- TextField Entry of Message
- (IBAction)textFieldDoneEditing:(UITextField *)sender {
    NSLog(@"text entry: %@", textField.text);

//    PFQuery *message = [PFQuery queryWithClassName:@"Message"];
 //   [message getObjectInBackgroundWithId:@"recipientIds" block:^(PFObject
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

    [sender resignFirstResponder];
    [textField resignFirstResponder];
    
}

-(IBAction) backgroundTap:(id) sender   {
    [self.textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textFielder    {
    NSLog(@"text entry: %@", textField.text);
    [textFielder resignFirstResponder];

    if (textField.text.length>0) {
        NSLog(@"text field should return");

        return YES;
    }

    return NO;
}








#pragma mark -- collectionView delegate Methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.chatData.count;
}

-(MessageDetailCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"MessageCell";
    MessageDetailCell *cell = (MessageDetailCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    NSUInteger row = [self.chatData count]-[indexPath row]-1;

    if (row < self.chatData.count){
        NSString *chatText = [[self.chatData objectAtIndex:row] objectForKey:@"text"];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;

        //CGSize size = textRect.size;
        // CGSize size = [chatText sizeWithFont:font constrainedToSize:CGSizeMake(225.0f, 1000.0f) lineBreakMode:NSLineBreakByCharWrapping];
        //cell.textLabel.frame = CGRectMake(75, 14, size.width +20, size.height + 20);


        cell.textLabel.text = chatText;

        NSDate *theDate = [[self.chatData objectAtIndex:row] objectForKey:@"date"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm a"];
        NSString *timeString = [formatter stringFromDate:theDate];

        cell.timeLabel.text = timeString;

    }
    return cell;
}


#pragma mark -- helpers
-(void)reloadCollectionViewDataSource{

    self.reloading = YES;
    [self loadLocalChat];
    [self.collectionView reloadData];
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

    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];


    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.chatData count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [query orderByAscending:@"createdAt"];
        NSLog(@"Trying to retrieve from cache");
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %zd chats from cache.", objects.count);
                [self.chatData removeAllObjects];
                [self.chatData addObjectsFromArray:objects];
                [self.collectionView reloadData];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    __block int totalNumberOfEntries = 0;
    [query orderByAscending:@"createdAt"];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            // The count request succeeded. Log the count
            NSLog(@"There are currently %d entries", number);
            totalNumberOfEntries = number;
            if (totalNumberOfEntries > [self.chatData count]) {
                NSLog(@"Retrieving data");
                int theLimit;
                if (totalNumberOfEntries-[self.chatData count]> 50) {
                    theLimit = 50;
                }
                else {
                    theLimit = totalNumberOfEntries - (int)[self.chatData count];
                }
    query.limit = (int)[NSNumber numberWithInt:theLimit];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %zd chats.", objects.count);
            [self.chatData addObjectsFromArray:objects];
            NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
            for (int ind = 0; ind < objects.count; ind++) {
                NSIndexPath *newPath = [NSIndexPath indexPathForRow:ind inSection:0];
                [insertIndexPaths addObject:newPath];
            }

            [self.collectionView performBatchUpdates:^{

                long resultsSize = [self.chatData count];
                [self.chatData addObjectsFromArray:objects];
                NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];

                for (long i = resultsSize; i < resultsSize + objects.count; i++)
                    [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];

                [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
                
            } completion:nil];




            [self.collectionView insertItemsAtIndexPaths:insertIndexPaths];
            [self.collectionView reloadData];
            [self.collectionView scrollsToTop];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

} else {
    // The request failed, we'll keep the chatData count?
    number = (int)[self.chatData count];
}
}];
}


@end




