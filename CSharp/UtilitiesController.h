//
//  UtilitiesController.h
//  CSharp
//
//  Created by Lalitha Vedachalam on 9/19/15.
//  Copyright (c) 2015 melioSystems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilitiesController : NSObject

+ (UtilitiesController *) sharedInstance;

- (void) sendRequestForOTP:(NSString *)mobileDetails;

- (void) sendRequestToValidateOTP:(NSString *)mobileDetailsWithOTP;

-(void) sendRequestForValidation:(NSString *)message;

-(void) GCMRegistrationProcess:(NSString *)deviceToken;

@end
