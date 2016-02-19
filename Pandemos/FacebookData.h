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

@property (strong, nonatomic) NSString *locale;
@property (strong, nonatomic) NSString *timezone;
@property (strong, nonatomic) NSString *verified;
//Ind. FB Categories
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSArray *likes;

//facebook user pictures
@property (strong, nonatomic) NSString *photoID;
@property (strong, nonatomic) NSURL *photoURL;
@property (strong, nonatomic) NSData *photosData;
@property (strong, nonatomic) NSString *albumId;
@property (strong, nonatomic) NSString *realAlbumId;
@property (strong, nonatomic) NSString *imageCount;
@property (strong, nonatomic) NSString *nextPageURL;

-(void)retriveFacebookThumbnails:(UIButton *)nextButton arrayForPictures:(NSMutableArray *)picArray andCollectionView:(UICollectionView *)collection;


@end
