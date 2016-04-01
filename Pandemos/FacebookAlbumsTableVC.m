//
//  FacebookAlbumsTableVC.m
//  Pandemos
//
//  Created by Michael Sevy on 1/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "FacebookAlbumsTableVC.h"
#import "FacebookTableViewCell.h"
#import "AlbumDetailCollectionVC.h"
#import "FacebookDetailViewController.h"
#import "UIColor+Pandemos.h"
#import "Facebook.h"
#import "FacebookManager.h"

@interface FacebookAlbumsTableVC ()

@property (strong, nonatomic) NSMutableArray *pictureArray;
@property (strong, nonatomic) NSString *albumName;
@property (strong, nonatomic) NSString *albumId;

@end

@implementation FacebookAlbumsTableVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Facebook Albums";
    self.navigationController.navigationBar.backgroundColor = [UIColor yellowGreen];
    
    self.tableView.delegate = self;
    self.pictureArray = [NSMutableArray new];

//    FacebookData *face = [FacebookData new];
//    [face loadFacebookAlbumList:self.pictureArray andTableView:self.tableView];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.pictureArray.count;
}

-(FacebookTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FacebookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    FacebookData *face = [self.pictureArray objectAtIndex:indexPath.row];
//    cell.albumTitleLabel.text = face.albumId;
//    cell.albumCountLabel.text = face.imageCount;
//    cell.albumImage.layer.cornerRadius = 7;
//    cell.albumImage.image = [UIImage imageWithData:face.photoData];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Facebook *selectedPath = [self.pictureArray objectAtIndex:indexPath.row];
    self.albumId = selectedPath.albumId;
    self.albumName = selectedPath.albumName;
    NSLog(@"album path selected to push on %@", self.albumId);
    [self performSegueWithIdentifier:@"FacebookDetail" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqualToString:@"FacebookDetail"])
    {
        NSLog(@"segueing: this: %@", self.albumId);
        FacebookDetailViewController *fdvc = segue.destinationViewController;
        fdvc.albumId = self.albumId;
        fdvc.albumName = self.albumName;
    }
}
@end
