//
//  PotentialMatch.h
//  Pandemos
//
//  Created by Michael Sevy on 2/23/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PotentialMatch : NSObject

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *work;
@property (nonatomic, strong) NSString *education;
@property (nonatomic, strong) NSString *birthday;

-(NSMutableArray *)loadPotentialMatchImages:(NSArray *)pFObjects forUser:(NSUInteger)user;
-(void)loadPotentialMatchData:(NSArray *)pFObjects forUser:(NSUInteger)user;
-(NSString *)ageFromBirthday:(NSString *)birthday;
@end
