//
//  AppDelegate.h
//  CSharp
//
//  Created by Lalitha Vedachalam on 9/19/15.
//  Copyright (c) 2015 melioSystems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/CloudMessaging.h>
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate> {
    NetworkStatus remoteHostStatus;
}

@property (nonatomic) Reachability *reachability;

@property (strong, nonatomic) UIWindow *window;

-(BOOL) checkInternetConnection;

@property (nonatomic, retain) NSString *mobileNumber;

@property (nonatomic, retain) NSString *countryCode;

@property(nonatomic, readonly, strong) NSString *registrationKey;

@property(nonatomic, readonly, strong) NSString *messageKey;

@property(nonatomic, readonly, strong) NSDictionary *registrationOptions;

@property(nonatomic, readonly, strong) NSString *gcmSenderID;

@end
