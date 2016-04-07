//
//  FacebookBuilder.m
//  Pandemos
//
//  Created by Michael Sevy on 3/22/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "FacebookBuilder.h"
#import "Facebook.h"
#import "User.h"
#import "Parse/Parse.h"

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

+(void)parseAndSaveUserData:(NSDictionary *)results andUser:(User *)user withError:(NSError *)error
{
    NSError *localError = nil;

    if (localError != nil)
    {
        error = localError;
    }

    NSDictionary *userDict = results;

    if (userDict)
    {

        NSString *faceID = userDict[@"id"];
        NSString *name = userDict[@"first_name"];
        NSString *gender = userDict[@"male"];
        NSString *birthday = userDict[@"birthday"];
        NSString *location = userDict[@"location"][@"name"];
        //work
        NSArray *workArray = userDict[@"work"];
        NSDictionary *employerDict = [workArray lastObject];
        NSString *placeOfWork = employerDict[@"employer"][@"name"];
        //education
        NSArray *educationArray = userDict[@"education"];
        NSDictionary *schoolDict = [educationArray lastObject];
        NSString *lastSchool = schoolDict[@"school"][@"name"];
        //likes
        NSDictionary *likeDict = userDict[@"likes"];

        if (likeDict)
        {
            NSArray *likes = likeDict[@"data"];

            //save to Parse
            if (name)
            {
                [user setObject:name forKey:@"givenName"];
            }
            if (faceID)
            {
                [user setObject:faceID forKey:@"faceID"];
            }
            if (birthday)
            {
                [user setObject:birthday forKey:@"birthday"];
            }
            if (gender)
            {
                [user setObject:gender forKey:@"gender"];
            }
            if (location)
            {
                [user setObject:location forKey:@"facebookLocation"];
            }
            if (placeOfWork)
            {
                [user setObject:placeOfWork forKey:@"work"];
            }
            if (lastSchool)
            {
                [user setObject:lastSchool forKey:@"lastSchool"];
            }
            if (likes)
            {
                [user setObject:likes forKey:@"likes"];
            }
        }

        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

            if (succeeded)
            {
                NSLog(@"saved FB data to parse: %d", succeeded ? true : false);
            }
            else
            {
                NSLog(@"did not save to parse: %@", error);
            }
        }];
    }

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