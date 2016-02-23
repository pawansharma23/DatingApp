//
//  FacebookData.h
//  Pandemos
//
//  Created by Michael Sevy on 2/18/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FacebookData : NSObject
//Ind. FB Categories
@property (strong, nonatomic) NSString *locale;
@property (strong, nonatomic) NSString *timezone;
@property (strong, nonatomic) NSString *verified;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSArray *likes;
//Facebook Album
@property (strong, nonatomic) NSString *albumId;
@property (strong, nonatomic) NSString *albumId2;
@property (strong, nonatomic) NSString *imageCount;
@property (strong, nonatomic) NSString *nextPage;
@property (strong, nonatomic) NSString *previousPage;
@property (strong, nonatomic) NSString *photoID;
@property (strong, nonatomic) NSString *photoCount;
//image properties
@property (strong, nonatomic) NSString *photoStr;
@property (strong, nonatomic) NSString *photoTaken;
@property (strong, nonatomic) NSURL *photoURL;
@property (strong, nonatomic) NSData *photoData;

-(void)loadFacebookThumbnails:(UIButton *)nextButton arrayForPictures:(NSMutableArray *)picArray andCollectionView:(UICollectionView *)collection;
-(void)loadFacebookAlbum:(NSString *)albumID withPhotoArray:(NSMutableArray *)mutArray andCollectionView:(UICollectionView *)collectionView;
-(void)loadFacebookAlbumList:(NSMutableArray *)mutArray andTableView:(UITableView *)tableView;
-(void)loadNextPrevPage:(NSString *)pageURLString withPhotoArray:(NSMutableArray *)mutArray andCollectionView:(UICollectionView *)collectionView;
@end
