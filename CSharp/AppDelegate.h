//
//  AppDelegate.h
//  CSharp
//
//  Created by Lalitha Vedachalam on 9/19/15.
//  Copyright (c) 2015 melioSystems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NetworkStatus remoteHostStatus;
}

@property (nonatomic) Reachability *reachability;

@property (strong, nonatomic) UIWindow *window;

-(BOOL) checkInternetConnection;

@property (nonatomic, retain) NSString *mobileNumber;

@property (nonatomic, retain) NSString *countryCode;

@end
