//
//  AppDelegate.m
//  Pandemos
//
//  Created by Michael Sevy on 12/13/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4.h>
#import <Parse.h>
#import <FBSDKAppEvents.h>
#import "User.h"
#import "MatchRequest.h"

@interface AppDelegate ()

@property (nonatomic) LYRClient *layerClient;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //conenct to FB
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    //connect to parse
    [Parse setApplicationId:@"dCNWcarB6Tv1iW8vCT1c7UATrEwZ3AFq7OzwAs7A" clientKey:@"Fm7fN3AP4Efbcq6265D8Bh4ReICvjbHkgmRiQucl"];
    [User registerSubclass];
    [MatchRequest registerSubclass];

    //initialize the FB Parse plugin
    [PFFacebookUtils initialize];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];

    //layer-- need the cloud code set up to run this for production environment
//    NSURL *appID = [NSURL URLWithString:@"layer:///apps/staging/8b0e6db8-0cab-11e6-b294-424d000047e5"];
//    self.layerClient = [LYRClient clientWithAppID:appID];
//    [self.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
//        if (!success) {
//            NSLog(@"Failed to connect to Layer: %@", error);
//        } else {
//            // For the purposes of this Quick Start project, let's authenticate as a user named 'Device'.  Alternatively, you can authenticate as a user named 'Simulator' if you're running on a Simulator.
//            NSString *userIDString = @"Device";
//            // Once connected, authenticate user.
//            // Check Authenticate step for authenticateLayerWithUserID source
//            [self authenticateLayerWithUserID:userIDString completion:^(BOOL success, NSError *error) {
//                if (!success) {
//                    NSLog(@"Failed Authenticating Layer Client with error:%@", error);
//                }
//            }];
//        }
//    }];
    return YES;
}



- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    //facebook install method
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

//app events
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
