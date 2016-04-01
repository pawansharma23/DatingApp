//
//  FacebookManager.h
//  Pandemos
//
//  Created by Michael Sevy on 3/22/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookNetwork.h"
#import "User.h"
#import "Facebook.h"

@class User;

@protocol FacebookManagerDelegate <NSObject>

-(void)didReceiveParsedThumbnails:(NSArray *)thumbnails;
-(void)failedToReceiveParsedThumbs:(NSError *)error;
-(void)didReceiveParsedThumbPaging:(NSArray *)thumbPaging;
-(void)failedToReceiveParsedThumbPaging:(NSError *)error;
-(void)didReceiveParsedAlbumList:(NSArray *)photoAlbums;
-(void)failedToReceiveParsedPhotoAlbums:(NSError *)error;
@end

@interface FacebookManager : NSObject<FacebookNetworkDelegate>

@property(nonatomic, strong)User *currentUser;
@property(nonatomic, strong)NSMutableArray<User*> *allUsers;
@property(nonatomic, strong)NSMutableArray<User*> *pendingMatches;
@property(nonatomic, strong)NSMutableArray<User*> *matchingUsers;

//@property(nonatomic, strong)NSMutableArray<FriendRequest*> *pendingArray;

@property (strong, nonatomic) FacebookNetwork *facebookNetworker;
@property (weak, nonatomic) id<FacebookManagerDelegate>delegate;

+(FacebookManager*)sharedSettings;

-(void)loadParsedFacebookThumbnails;
-(void)loadParedFBPhotoAlbums;
@end
