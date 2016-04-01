//
//  PreferencesViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 12/19/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import "PreferencesViewController.h"
#import "ProfileViewController.h"
#import "PreferencesViewController.h"
#import "AlbumCustomCell.h"
#import "AlbumDetailCollectionVC.h"
#import "UIColor+Pandemos.h"
#import "Facebook.h"

@interface PreferencesViewController ()
<UITableViewDataSource,
UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *pictureArray;

@property (strong, nonatomic) NSString *nextURL;
@property (strong, nonatomic) NSString *albumId;
@property (strong, nonatomic) NSString *albumName;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *activityBackView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;


@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pictureArray = [NSMutableArray new];
    self.tableView.delegate = self;
    
    self.navigationItem.title = @"Change Pics";
    self.navigationController.navigationBar.backgroundColor = [UIColor yellowGreen];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.activityBackView.alpha = .75;
    self.activityBackView.layer.cornerRadius = 10;

    [self.pictureArray removeAllObjects];
//    FacebookData *face = [FacebookData new];
//    [face loadFacebookAlbumList:self.pictureArray andTableView:self.tableView];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.pictureArray.count;
}

-(AlbumCustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
//    FacebookData *face = [self.pictureArray objectAtIndex:indexPath.row];
//    cell.albumNames.text = face.albumId;
//    cell.albumCountLabel.text = face.imageCount;
//    cell.albumImage.layer.cornerRadius = 9;
//    cell.albumImage.image = [UIImage imageWithData:face.photoData];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Facebook *selectedPath = [self.pictureArray objectAtIndex:indexPath.row];
    self.albumId = selectedPath.albumId;
    self.albumName = selectedPath.albumName;
    NSLog(@"album path selected to push on %@", self.albumId);
    [self performSegueWithIdentifier:@"AlbumDetail" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AlbumDetail"])
    {
        NSLog(@"segueing: this: %@", self.albumId);

        AlbumDetailCollectionVC *advc = segue.destinationViewController;
        advc.albumID = self.albumId;
        advc.albumName = self.albumName;
    }
}

//[self.spinner stopAnimating];
//self.activityBackView.hidden = YES;
//self.loadingLabel.hidden = YES;
//self.spinner.hidden = YES;




@end






