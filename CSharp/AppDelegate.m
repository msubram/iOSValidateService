//
//  AppDelegate.m
//  CSharp
//
//  Created by Lalitha Vedachalam on 9/19/15.
//  Copyright (c) 2015 melioSystems. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self enablePushNotification];
    return YES;
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

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*!
 * @brief Request the user to allow or disallow the push notification
 */
- (void) enablePushNotification {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

/*!
 * @brief Push Notification Delegate Methods
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    //#if !TARGET_IPHONE_SIMULATOR
    // Prepare the Device Token for Registration (remove spaces and < >)
    NSString *deviceToken = [[[[devToken description]
                               stringByReplacingOccurrencesOfString:@"<"withString:@""]                             stringByReplacingOccurrencesOfString:@">" withString:@""]                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"Device Token %@",deviceToken);
    [self updateToken:deviceToken];
    //#endif
    
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //#if !TARGET_IPHONE_SIMULATOR
    NSLog(@"Error in Registration, Error : %@",error);
    //#endif
}
/* End */

/*!
 * @brief Update the device token in the user defaults for the future use
 * @param deviceToken Holds the device token value
 */
- (void) updateToken:(NSString *)deviceToken {
    [[NSUserDefaults standardUserDefaults] setValue:deviceToken forKey:@"deviceToken"]; 
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*!
 * @brief Check for the internet connectivity in the mobile
 */
- (BOOL) checkInternetConnection {
    self.reachability = [Reachability reachabilityForInternetConnection];
    remoteHostStatus = [self.reachability currentReachabilityStatus];
    if(remoteHostStatus == ReachableViaWiFi)
        return YES;
    else
        return NO;
}

@end
