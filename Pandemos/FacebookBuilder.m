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

+(NSArray *)parseUserData:(NSDictionary *)results withError:(NSError *)error
{
    NSError *localError = nil;

    if (localError != nil)
    {
        error = localError;
        return nil;
    }
    NSLog(@"from builder: %@", results);

    NSMutableArray *parsedData = [NSMutableArray new];
    NSDictionary *dataArray = results[@"data"];

//    if (dataArray)
//    {
//        Facebook *face = [Facebook new];
//        face.locale = dataArray[@"locale"];
//    }

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
        //NSLog(@"dta: %@", data);

        //        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:data];
        //        NSArray *uniqueArray = [orderedSet array];

        for (NSDictionary *imageData in data)
        {
            Facebook *face = [Facebook new];

            face.albumId = imageData[@"id"];
            NSNumber *nSCount = imageData[@"count"];
            face.albumImageCount = [NSString stringWithFormat:@"%@", nSCount];
            face.albumName = imageData[@"name"];
            NSDictionary *picture = imageData[@"picture"];
            NSDictionary *data = picture[@"data"];
            face.albumImageURL = data[@"url"];

            //NSLog(@"id: %@ name: %@, url: %@ %@", face.albumId, face.albumImageCount, face.albumName, face.albumImageURL);
            [parsedData addObject:face];
        }
    }

    return parsedData;
}

+(NSArray *)parseAlbum:(NSDictionary *)results withError:(NSError *)error
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
        for (NSDictionary *dict in data)
        {
            Facebook *face = [Facebook new];
            face.albumImageURL = dict[@"source"];
            face.albumtimestamp = dict[@"updated_time"];
            face.albumImageID = dict[@"id"];

            [parsedData addObject:face];
        }
    }

    return parsedData;
}

+(NSArray *)parseAlbumPaging:(NSDictionary *)results withError:(NSError *)error
{
    NSError *localError = nil;

    if (localError != nil)
    {
        error = localError;
        return nil;
    }
    NSMutableArray *parsedPagingData = [NSMutableArray new];
    NSDictionary *paging = results[@"paging"];

    if (paging)
    {
        Facebook *face = [Facebook new];
        if (paging[@"next"])
        {
            face.nextPage = paging[@"next"];
        }

        if (paging[@"previous"])
        {
            face.previousPage = paging[@"previous"];
        }
        [parsedPagingData addObject:face];
    }
    
    return parsedPagingData;
}

@end