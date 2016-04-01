//
//  PotentialMatch.m
//  Pandemos
//
//  Created by Michael Sevy on 2/23/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "PotentialMatch.h"
#import <Parse/PFUser.h>
#import "User.h"

@implementation PotentialMatch

-(NSMutableArray *)loadPotentialMatchImages:(NSArray *)pFObjects forUser:(NSUInteger)user
{
    User *userForImage = [pFObjects objectAtIndex:user];
    NSString *image1 = [userForImage objectForKey:@"image1"];
    NSString *image2 = [userForImage objectForKey:@"image2"];
    NSString *image3 = [userForImage objectForKey:@"image3"];
    NSString *image4 = [userForImage objectForKey:@"image4"];
    NSString *image5 = [userForImage objectForKey:@"image5"];
    NSString *image6 = [userForImage objectForKey:@"image6"];
    self.images = [NSMutableArray new];

    if (image1)
    {
        [self.images addObject:image1];
    }
    if (image2)
    {
        [self.images addObject:image2];
    }
    if (image3)
    {
        [self.images addObject:image3];
    }
    if (image4)
    {
        [self.images addObject:image4];
    }
    if (image5)
    {
        [self.images addObject:image5];
    }
    if (image6)
    {
        [self.images addObject:image6];
    }

    return self.images;
}

-(void)loadPotentialMatchData:(NSArray *)pFObjects forUser:(NSUInteger)user
{
    User *userForData = [pFObjects objectAtIndex:user];
    self.firstName = [userForData objectForKey:@"firstName"];
    self.work = [userForData objectForKey:@"work"];
    self.education = [userForData objectForKey:@"scool"];
    self.birthday = [userForData objectForKey:@"birthday"];
}

-(NSString *)ageFromBirthday:(NSString *)birthday
{
    //Caculate age from birthday
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *todaysDate = [NSDate date];
    NSDate *birthdateDate = [formatter dateFromString:birthday];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:birthdateDate toDate:todaysDate options:0];
    NSUInteger age = ageComponents.year;
    NSLog(@"years of life: %zd", age);
    NSString *ageStr = [NSString stringWithFormat:@"%lu", (unsigned long)age];

    return ageStr;
}
@end
