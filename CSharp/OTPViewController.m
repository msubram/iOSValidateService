//
//  OTPViewController.m
//  CSharp
//
//  Created by Lalitha Vedachalam on 9/19/15.
//  Copyright (c) 2015 melioSystems. All rights reserved.
//

#import "OTPViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "UtilitiesController.h"
#import "UpdateViewController.h"

@interface OTPViewController ()

@end

@implementation OTPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mobileNumber                    =   [[NSUserDefaults standardUserDefaults] stringForKey:@"peopleMobileNumber"];
    self.countryCode                     =   [[NSUserDefaults standardUserDefaults] stringForKey:@"peopleCountryCode"];
    
    
    //For Dismissing
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissAnyOverLappingView)];
    
    [self.view addGestureRecognizer:tap];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    //Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(OTPValidationNotification:)
                                            name:@"OTPValidationNotification"
                                            object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(GCMRegistrationNotification:)
                                            name:@"GCMRegistrationNotification"
                                            object:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    //Remove Notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                            name:@"OTPValidationNotification"
                                            object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                            name:@"GCMRegistrationNotification"
                                            object:nil];
    
}

-(void)dismissAnyOverLappingView{
    [self.OTPFirstDigit resignFirstResponder];
    [self.OTPSecondDigit resignFirstResponder];
    [self.OTPThirdDigit resignFirstResponder];
    [self.OTPFourthDigit resignFirstResponder];
    [self.OTPFifthDigit resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(range.length!=0){
        return YES;
    }
    
    NSInteger nextTag = textField.tag + 1;
    NSLog(@"%ld",(long)nextTag);
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if([textField.text length]>=1){
        return NO;
    }
    if (nextResponder) {
        // Found next responder, so set it.
        [textField setText:newString];
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField setText:newString];
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

//Make View up when keyboard shows
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    //Keyboard becomes visible
    self.view.frame = CGRectMake(0,-200,self.view.frame.size.width,self.view.frame.size.height);
    //resize
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    //keyboard will hide
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    //Return to original size
}
/* End */

- (IBAction)validateOTP:(id)sender {
    
    NSString *enteredOTPValue   =   [NSString stringWithFormat:@"%@%@%@%@%@",self.OTPFirstDigit.text,self.OTPSecondDigit.text,self.OTPThirdDigit.text,self.OTPFourthDigit.text,self.OTPFifthDigit.text];
    
    NSString *valuesForServer = [NSString stringWithFormat:@"{\"MobileInfo\":{\"CountryCode\":%@,\"MobileNumber\":%@},\"RegCode\":%@}",self.countryCode,self.mobileNumber,enteredOTPValue];
    
    [[UtilitiesController sharedInstance] sendRequestToValidateOTP:valuesForServer];
}

-(void)OTPValidationNotification: (NSNotification *) notification{
    if ([[notification name] isEqualToString:@"OTPValidationNotification"]) {
        NSDictionary *userInfo = notification.userInfo;
        if([userInfo[@"state"] isEqualToString:@"success"]) {
            if([userInfo[@"data"] isEqualToString:@"-1"]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message:NSLocalizedString(@"Please enter a valid OTP token",@"Alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles:nil];
                [alert show];
                self.OTPFirstDigit.text     =   @"";
                self.OTPSecondDigit.text    =   @"";
                self.OTPThirdDigit.text     =   @"";
                self.OTPFourthDigit.text    =   @"";
                self.OTPFifthDigit.text     =   @"";
                [self.OTPFirstDigit becomeFirstResponder];
            }
            else{
                NSString *deviceToken       =   [[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"];
                [[UtilitiesController sharedInstance] GCMRegistrationProcess:deviceToken];
            }
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message:NSLocalizedString(@"Please check your Internet Connection", @"Alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles:nil];
            [alert show];
        }
    }
    
}

-(void)GCMRegistrationNotification: (NSNotification *) notification{
    if ([[notification name] isEqualToString:@"GCMRegistrationNotification"]) {
        NSDictionary *userInfo = notification.userInfo;
        if([userInfo[@"state"] isEqualToString:@"success"]) {
            /*if([userInfo[@"data"] isEqualToString:@"-1"]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message:NSLocalizedString(@"App Registration with GCM failed",@"Alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Please try again", @"Action") otherButtonTitles:nil];
                [alert show];
                self.OTPFirstDigit.text     =   @"";
                self.OTPSecondDigit.text    =   @"";
                self.OTPThirdDigit.text     =   @"";
                self.OTPFourthDigit.text    =   @"";
                self.OTPFifthDigit.text     =   @"";
                [self.OTPFirstDigit becomeFirstResponder];
            }
           else{*/
                UIStoryboard *storyboard;
                if(IS_IPAD)
                    storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
                else
                    storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                UpdateViewController *destViewController = (UpdateViewController *) [storyboard instantiateViewControllerWithIdentifier:@"UpdateViewController"];
                [self.navigationController pushViewController:destViewController animated:YES];
                
           // }
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message:NSLocalizedString(@"Please check your Internet Connection", @"Alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
