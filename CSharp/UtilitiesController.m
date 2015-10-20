//
//  UtilitiesController.m
//  CSharp
//
//  Created by Lalitha Vedachalam on 9/19/15.
//  Copyright (c) 2015 melioSystems. All rights reserved.
//

#import "UtilitiesController.h"
#import "OTPViewController.h"

@implementation UtilitiesController

+ (UtilitiesController *)sharedInstance {
    static UtilitiesController *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [self new];
    });
    return sharedStore;
}

-(void) sendRequestForOTP:(NSString *)mobileDetails{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *url   =   [NSString stringWithFormat:@"%@/RegistrationRequest/", IS_BASE_URL];
    
    [request setURL:[NSURL URLWithString:url]];
    
    request.timeoutInterval = 20;
    
    [request setHTTPMethod:@"POST"];
    
    NSData* data = [mobileDetails dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[data length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:data];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *httpresponse, NSData *data, NSError *error) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)httpresponse;
               
        
        if (response.statusCode == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *responseData    =   data;
                NSString* responseDataInString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                
                NSDictionary *userInfo = @{@"state":@"success",@"data":responseDataInString};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"requestForOTPNotification" object:self userInfo:userInfo];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSDictionary *userInfo = @{@"state":@"failure"};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"requestForOTPNotification" object:self userInfo:userInfo];
            });
        }
    }];

}

- (void) sendRequestToValidateOTP:(NSString *)mobileDetailsWithOTP{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *url   =   [NSString stringWithFormat:@"%@/Registrations/", IS_BASE_URL];
    
    [request setURL:[NSURL URLWithString:url]];
    
    request.timeoutInterval = 20;
    
    [request setHTTPMethod:@"POST"];
    
    NSData* data = [mobileDetailsWithOTP dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[data length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:data];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *httpresponse, NSData *data, NSError *error) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)httpresponse;
        
        
        if (response.statusCode == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *responseData    =   data;
                NSString* responseDataInString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                
                NSDictionary *userInfo = @{@"state":@"success",@"data":responseDataInString};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"OTPValidationNotification" object:self userInfo:userInfo];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSDictionary *userInfo = @{@"state":@"failure"};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"OTPValidationNotification" object:self userInfo:userInfo];
            });
        }
    }];
}

-(void)sendRequestForValidation : (NSString *) message{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:message]];
    
    request.timeoutInterval = 20;
    
    [request setHTTPMethod:@"POST"];
    
    NSUserDefaults *userDefaults    =   [NSUserDefaults standardUserDefaults];
    
    NSString *userMobileNumber      =   [userDefaults valueForKey:@"peopleMobileNumber"];
    NSString *userCountryCode       =   [userDefaults valueForKey:@"peopleCountryCode"];
    NSString *workTelephoneNumber   =   [userDefaults valueForKey:@"workTelephoneNumber"];
    NSString *homeTelephoneNumber   =   [userDefaults valueForKey:@"homeTelephoneNumber"];
    
    NSDictionary *valuesForServer = [[NSDictionary alloc] initWithObjectsAndKeys:@"", @"Email", homeTelephoneNumber, @"HomeNumber", workTelephoneNumber , @"WorkNumber", userMobileNumber, @"MobileNumber", userCountryCode, @"MobileCountryCode", nil];
    
    NSError * err;
    NSData * jsonData   = [NSJSONSerialization  dataWithJSONObject:valuesForServer options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    
    NSData* data = [myString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[data length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:data];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *httpresponse, NSData *data, NSError *error) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)httpresponse;
        
        if (response.statusCode == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *responseData    =   data;
                NSString* responseDataInString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                
                NSDictionary *userInfo = @{@"state":@"success",@"data":responseDataInString};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"validationProcessNotification" object:self userInfo:userInfo];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSDictionary *userInfo = @{@"state":@"failure"};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"validationProcessNotification" object:self userInfo:userInfo];
            });
        }
    }];
}

-(void) GCMRegistrationProcess:deviceToken{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *url   =   [NSString stringWithFormat:@"%@/GCMRegistrationRequest/", IS_BASE_URL];
    
    [request setURL:[NSURL URLWithString:url]];
    
    request.timeoutInterval = 20;
    
    [request setHTTPMethod:@"POST"];
    
    NSUserDefaults *userDefaults    =   [NSUserDefaults standardUserDefaults];
    
    NSString *userMobileNumber      =   [userDefaults valueForKey:@"peopleMobileNumber"];
    NSString *userCountryCode       =   [userDefaults valueForKey:@"peopleCountryCode"];
    
    NSDictionary *valuesForServer   = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%@",userCountryCode], @"MobileCountryCode",[NSString stringWithFormat:@"%@",userMobileNumber],@"MobileNumber",@"", @"InstanceId", deviceToken, @"Token", nil];
    
    NSError * err;
    NSData * jsonData   = [NSJSONSerialization  dataWithJSONObject:valuesForServer options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    
    NSData* data = [myString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[data length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:data];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *httpresponse, NSData *data, NSError *error) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)httpresponse;
        
        if (response.statusCode == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *responseData    =   data;
                NSString* responseDataInString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                
                NSDictionary *userInfo = @{@"state":@"success",@"data":responseDataInString};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GCMRegistrationNotification" object:self userInfo:userInfo];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSDictionary *userInfo = @{@"state":@"failure"};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GCMRegistrationNotification" object:self userInfo:userInfo];
            });
        }
    }];

}


@end
