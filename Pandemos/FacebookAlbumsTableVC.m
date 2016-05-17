//  FacebookAlbumsTableVC.m
//  Pandemos
//
//  Created by Michael Sevy on 1/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "FacebookAlbumsTableVC.h"
#import "FacebookTableViewCell.h"
#import "AlbumDetailViewController.h"
#import "UIColor+Pandemos.h"
#import "Facebook.h"
#import "FacebookManager.h"
#import "User.h"

@interface FacebookAlbumsTableVC ()<FacebookManagerDelegate>

@property (strong, nonatomic) NSArray *albums;
@property (strong, nonatomic) NSString *albumName;
@property (strong, nonatomic) NSString *albumId;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) FacebookManager *manager;
@end

@implementation FacebookAlbumsTableVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Facebook Albums";
    self.navigationController.navigationBar.backgroundColor = [UIColor yellowGreen];

    self.albums = [NSArray new];
    self.currentUser = [User currentUser];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self addBackButtonWithTitle:@"Back"];

    if (self.currentUser)
    {
        self.manager = [FacebookManager new];
        self.manager.facebookNetworker = [FacebookNetwork new];
        self.manager.facebookNetworker.delegate = self.manager;
        self.manager.delegate = self;
        [self.manager loadParsedFBPhotoAlbums];
    }
    else
    {
        NSLog(@"no user for face request");
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Album:";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albums.count;
}

-(FacebookTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FacebookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Facebook *face = [self.albums objectAtIndex:indexPath.row];
    cell.albumTitleLabel.text = face.albumName;
    cell.albumCountLabel.text = face.albumImageCount;
    cell.albumImage.layer.cornerRadius = 7;
    cell.albumImage.image = [UIImage imageWithData:[face stringURLToData:face.albumImageURL]];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Facebook *selectedPath = [self.albums objectAtIndex:indexPath.row];
    self.albumId = selectedPath.albumId;
    self.albumName = selectedPath.albumName;
    NSLog(@"album path selected to push on %@", self.albumId);

    [self performSegueWithIdentifier:@"AlbumDetail" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     if([segue.identifier isEqualToString:@"AlbumDetail"])
    {
        AlbumDetailViewController *advc = segue.destinationViewController;
        NSLog(@"segueing: this: %@", self.albumId);

        advc.albumID = self.albumId;
        advc.albumName = self.albumName;
    }
}

- (void)addBackButtonWithTitle:(NSString *)title
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - FACEBOOK MANAGER DELEGATE
-(void)didReceiveParsedAlbumList:(NSArray *)photoAlbums
{
    self.albums = photoAlbums;
    [self.tableView reloadData];
}
@end
