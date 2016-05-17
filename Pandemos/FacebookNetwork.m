//
//  FacebookNetwork.m
//  Pandemos
//
//  Created by Michael Sevy on 3/22/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "FacebookNetwork.h"
#import "User.h"
#import <FBSDKGraphRequestConnection.h>
#import <FBSDKGraphRequest.h>

@implementation FacebookNetwork

-(void)loadFacebookThumbnails:(resultBlockWithSuccess)results
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"me/photos" parameters:@{@"fields":@"picture, updated_time, id, album"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        if (!error)
        {
            results(YES, nil);
            [self.delegate receivedFBThumbnail:result];
            [self.delegate receivedFBThumbPaging:result];
        }
        else
        {
            results(NO, nil);
            [self.delegate failedToFetchFBThumbs:error];
            [self.delegate failedToFetchFBThumbPaging:error];
        }
    }];
}

-(void)loadFacebookUserData:(resultBlockWithSuccess)results
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:@{@"fields":@"id, about, birthday, gender, bio, education, first_name, work, location, likes"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {

        User *user = [User currentUser];
        if (!error)
        {
            results(YES, nil);
            [self.delegate receivedFBUserInfo:result andUser:user];
        }
        else
        {
            results(NO, nil);
            [self.delegate failedToFetchUserInfo:error];
        }
    }];
}

-(void)loadFacebookPhotoAlbums:(resultBlockWithSuccess)results
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"me/albums" parameters:@{@"fields": @"picture, count, updated_time, name"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {

        if (!error)
        {
            results(YES, nil);
            [self.delegate receivedFBPhotoAlbums:result];
        }

        else
        {
            results(NO, nil);
            [self.delegate failedToFetchFBPhotoAlbums:error];
        }
    }];
}

-(void)loadFacebookPhotoAlbum:(NSString *)albumID withSuccess:(resultBlockWithSuccess)results
{
    NSString *albumIdPath = [NSString stringWithFormat:@"/%@/photos", albumID];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:albumIdPath parameters:@{@"fields": @"source, updated_time"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {

        if (!error)
        {
            results(YES, nil);
            [self.delegate receivedFBPhotoAlbum:result];
            [self.delegate receivedFBAlbumPaging:result];
        }
        else
        {
            results(NO, nil);
            [self.delegate failedToFetchFBAlbum:error];
            [self.delegate failedToFetchFBAlbum:error];
        }
    }];
}

-(void)loadFacebookSourcePhoto:(NSString *)photoId withSuccess:(resultBlockWithSuccess)results
{
    NSString *photoIdStr = [NSString stringWithFormat:@"/%@", photoId];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:photoIdStr parameters:@{@"fields": @"source, updated_time"} HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {

        if (!error)
        {
            results(YES, nil);
            [self.delegate receivedPhotoSource:result];
        }
        else
        {
            results(NO, nil);
            [self.delegate failedToFetchFBAlbum:error];
        }
    }];
}
@end
