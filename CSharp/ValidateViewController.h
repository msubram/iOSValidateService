//
//  ValidateViewController.h
//  CSharp
//
//  Created by Lalitha Vedachalam on 9/19/15.
//  Copyright (c) 2015 melioSystems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ValidateViewController : UIViewController{
    NSTimer *connectionTimer;
}

@property (nonatomic, retain) IBOutlet NSString *mobileNumber;

@property (nonatomic, retain) IBOutlet NSString *countryCode;

@property (nonatomic, retain) IBOutlet NSString *workTelephoneNumber;

@property (nonatomic, retain) IBOutlet NSString *HomeTelephoneNumber;

@property (nonatomic, retain) IBOutlet NSDictionary *receivedNotification;

@property (strong, nonatomic) IBOutlet UIAlertView *alertView;

@property (weak, nonatomic) IBOutlet UIButton *notification;

- (IBAction)validationProcess:(id)sender;

- (IBAction)viewNotification:(id)sender;

@end
