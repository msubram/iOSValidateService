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

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

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

/*!
 * @brief To check the internet connectivity
 */
-(BOOL)checkInternetConnection{
    if([(AppDelegate *)[[UIApplication sharedApplication] delegate] checkInternetConnection] == 0){
        return false;
    }
    else{
        return true;
    }
}

/*!
 * @brief Dismiss the overlapping view when tap outside of the keyboard or overlapping views
 */
-(void)dismissAnyOverLappingView{
    [self.OTPFirstDigit resignFirstResponder];
    [self.OTPSecondDigit resignFirstResponder];
    [self.OTPThirdDigit resignFirstResponder];
    [self.OTPFourthDigit resignFirstResponder];
    [self.OTPFifthDigit resignFirstResponder];
}

/*!
 * @brief TextField delegate calls automatically when User types inside the TextField
 * @param textField An object representing the textfield requesting the data
 * @param range Holds the length of the text in the textfield
 * @param string Holds the current text of the textField
 */
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


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    CGRect textFieldRect =[self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y - 2 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}



/*!
 * @brief TextField delegate called when textfield editing starts
 * @param textField An object representing textfield requesting the data
 
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    //After Keyboard gets visible
    self.view.frame = CGRectMake(0,-200,self.view.frame.size.width,self.view.frame.size.height);
    //resize
}

/*!
 * @brief TextField delegate called when textfield editing ends
 * @param textField An object representing textfield requesting the data
 
-(void)textFieldDidEndEditing:(UITextField *)textField {
    //After keyboard will hide
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    //Return to original size
}
*/

/*!
 * @brief Send the specific values for the server and check whether the given
 * @param sender An object representing the button actions requesting for the data
 */
- (IBAction)validateOTP:(id)sender {
    
    NSString *enteredOTPValue   =   [NSString stringWithFormat:@"%@%@%@%@%@",self.OTPFirstDigit.text,self.OTPSecondDigit.text,self.OTPThirdDigit.text,self.OTPFourthDigit.text,self.OTPFifthDigit.text];
    
    NSString *valuesForServer = [NSString stringWithFormat:@"{\"MobileInfo\":{\"CountryCode\":%@,\"MobileNumber\":%@},\"RegCode\":%@}",self.countryCode,self.mobileNumber,enteredOTPValue];
    
    //To Check Internet Connectivity
    if([self checkInternetConnection]){
        [[UtilitiesController sharedInstance] sendRequestToValidateOTP:valuesForServer];
    }
    else{
        UIAlertView *alertView  =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message: NSLocalizedString(@"Please Check your Wifi Connection",@"Alert Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
        [alertView show];
    }
}

/*!
 * @brief Return notification from the server after validating the OTP
 * @param notification Holds the data and the type of the notification
 */
-(void)OTPValidationNotification: (NSNotification *) notification{
    if ([[notification name] isEqualToString:@"OTPValidationNotification"]) {
        NSDictionary *userInfo = notification.userInfo;
        if([userInfo[@"state"] isEqualToString:@"success"]) {
            if([userInfo[@"data"] isEqualToString:@"-1"]){
                [self dismissAnyOverLappingView];
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
            [self dismissAnyOverLappingView];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message:NSLocalizedString(@"Please check your Internet Connection", @"Alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles:nil];
            [alert show];
        }
    }
    
}

/*!
 * @brief Return notification from the server after GCM Registrations
 * @param notification Holds the data and the type of the notification
 */
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
            [self dismissAnyOverLappingView];
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
