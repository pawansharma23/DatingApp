//
//  FacebookNetwork.h
//  Pandemos
//
//  Created by Michael Sevy on 3/22/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@protocol FacebookNetworkDelegate<NSObject>

-(void)receivedFBThumbnail:(NSDictionary *)facebookThumbnails;
-(void)failedToFetchFBThumbs:(NSError *)error;
-(void)receivedFBThumbPaing:(NSDictionary *)facebookThumbPaging;
-(void)failedToFetchFBThumbPaging:(NSError *)error;
-(void)receivedFBPhotoAlbums:(NSDictionary *)facebookAlbums;
-(void)failedToFetchFBPhotoAlbums:(NSError *)error;


//-(void)receivedFBUserInfo:(NSArray *)facebookUserInfo;
//-(void)receivedFBUserImage:(NSArray *)facebookUserImages;

@end
@interface FacebookNetwork : NSObject

typedef void (^resultBlockWithSuccess)(BOOL success, NSError *error);

@property (weak, nonatomic) id<FacebookNetworkDelegate>delegate;

-(void)loadFacebookThumbnails:(resultBlockWithSuccess)results;
-(void)loadFacebookPhotoAlbums:(resultBlockWithSuccess)results;
@end
