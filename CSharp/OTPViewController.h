//
//  OTPViewController.h
//  CSharp
//
//  Created by Lalitha Vedachalam on 9/19/15.
//  Copyright (c) 2015 melioSystems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTPViewController : UIViewController

@property (nonatomic, retain) IBOutlet NSString *mobileNumber;

@property (nonatomic, retain) IBOutlet NSString *countryCode;

@property (strong, nonatomic) IBOutlet UITextField *OTPFirstDigit;

@property (strong, nonatomic) IBOutlet UITextField *OTPSecondDigit;

@property (strong, nonatomic) IBOutlet UITextField *OTPThirdDigit;

@property (strong, nonatomic) IBOutlet UITextField *OTPFourthDigit;

@property (strong, nonatomic) IBOutlet UITextField *OTPFifthDigit;

- (IBAction)validateOTP:(id)sender;

@end
