//
//  NotificationManager.m
//  Pandemos
//
//  Created by Michael Sevy on 6/6/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "NotificationManager.h"
#import "AppDelegate.h"

@implementation NotificationManager

-(void)registerForNotifications
{
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);

    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];

    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)scheduleInstantNotificationFromMatch:(NSString*)matchName
{
    [self scheduleNotificationWithDate:[NSDate date]
                               message:[NSString stringWithFormat:@"You have a new message from %@", matchName]];
}

-(void)scheduleNotificationNowWithUnreadCount:(long)count
{
    if (count > 1)
    {
        [self scheduleNotificationWithDate:[NSDate date]
                                   message:[NSString stringWithFormat:@"You have %ld new messages", count]];
    }
}

-(void)scheduleNotificationForLater:(long)count withMatched:(NSString *)matchName
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *laterDate = [calendar dateByAddingUnit:NSCalendarUnitMinute value:30.0 toDate:[NSDate date] options:NSCalendarMatchStrictly];

    [self scheduleNotificationWithDate:laterDate
                               message:[NSString stringWithFormat:@"You have a new message from %@", matchName]];
}

-(void)scheduleNotificationWithDate:(NSDate*)date message:(NSString*)message
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = date;
    notification.timeZone = [NSTimeZone localTimeZone];
    //notification.repeatInterval = calendarUnit;
    notification.alertBody = message;
    notification.hasAction = NO;
    //notification.category = category;
    //notification.userInfo for putting in the 700 reminder
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
