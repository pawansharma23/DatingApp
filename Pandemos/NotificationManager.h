//
//  NotificationManager.h
//  Pandemos
//
//  Created by Michael Sevy on 6/6/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationManager : NSObject

-(void)registerForNotifications;
-(void)scheduleNotificationNowWithUnreadCount:(long)count;
-(void)scheduleNotificationForLater:(long)count withMatched:(NSString *)matchName;
-(void)scheduleInstantNotificationFromMatch:(NSString*)matchName;
@end
