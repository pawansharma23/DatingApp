//
//  FacebookData.h
//  Pandemos
//
//  Created by Michael Sevy on 2/18/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Facebook : NSObject
//Ind. FB Categories
@property (strong, nonatomic) NSString *locale;
@property (strong, nonatomic) NSString *timezone;
@property (strong, nonatomic) NSString *verified;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSArray *likes;
//image properties-- THUMBS
@property (strong, nonatomic) NSString *thumbURL;
@property (strong, nonatomic) NSString *thumbPhotoID;
@property (strong, nonatomic) NSString *thumbTimeUpdated;
//ALBUMS
@property (strong, nonatomic) NSString *albumName;
@property (strong, nonatomic) NSString *albumId;
@property (strong, nonatomic) NSString *albumImageCount;
@property (strong, nonatomic) NSString *albumImageURL;
@property (strong, nonatomic) NSString *albumtimestamp;
@property (strong, nonatomic) NSString *albumImageID;
//PAGINATION
@property (strong, nonatomic) NSString *nextPage;
@property (strong, nonatomic) NSString *previousPage;
@property (strong, nonatomic) NSString *photoCount;


-(NSData *)stringURLToData:(NSString *)urlString;
@end
