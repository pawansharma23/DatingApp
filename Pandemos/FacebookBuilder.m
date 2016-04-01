//
//  FacebookBuilder.m
//  Pandemos
//
//  Created by Michael Sevy on 3/22/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "FacebookBuilder.h"
#import "Facebook.h"

@implementation FacebookBuilder

+(NSArray *)parseThumbnailData:(NSDictionary *)results withError:(NSError *)error
{
    NSError *localError = nil;

    if (localError != nil)
    {
        error = localError;
        return nil;
    }
    NSMutableArray *parsedData = [NSMutableArray new];
    NSArray *dataArray = results[@"data"];

    if (dataArray)
    {
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataArray];
        NSArray *uniqueArray = [orderedSet array];

        for (NSDictionary *dict in uniqueArray)
        {
            Facebook *face = [Facebook new];
            face.thumbPhotoID = dict[@"id"];
            face.thumbURL = dict[@"picture"];
            face.thumbTimeUpdated = dict[@"updated_time"];

            [parsedData addObject:face];
        }
    }
    
    return parsedData;
}

+(NSArray *)parseThumbnailPaging:(NSDictionary *)results withError:(NSError *)error
{
    NSError *localError = nil;

    if (localError != nil)
    {
        error = localError;
        return nil;
    }
    NSMutableArray *parsedPaging = [NSMutableArray new];
    NSDictionary *paging = results[@"paging"];

    //NSLog(@"pagings: %@", paging);
    
    if (paging)
    {
        Facebook *face = [Facebook new];

        if (paging[@"next"])
        {
            NSString *next = paging[@"next"];
            face.nextPage = next;
        }
        if (paging[@"previous"])
        {
            NSString *previous = paging[@"previous"];
            face.previousPage = previous;
        }

            [parsedPaging addObject:face];

    }
    return parsedPaging;
}

+(NSArray *)parsePhotoAlbums:(NSDictionary *)results withError:(NSError *)error
{
    NSError *localError = nil;

    if (localError != nil)
    {
        error = localError;
        return nil;
    }
    NSMutableArray *parsedData = [NSMutableArray new];
    NSArray *data = results[@"data"];

    if (data)
    {
        NSLog(@"data from builder: %@", data);
        Facebook *face = [Facebook new];
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:data];
        NSArray *uniqueArray = [orderedSet array];

        for (NSDictionary *imageData in uniqueArray)
        {
            face.albumId = imageData[@"id"];
            face.albumImageCount = imageData[@"count"];
            face.albumName = imageData[@"name"];

            [parsedData addObject:face];
        }
    }

    return parsedData;
}
@end