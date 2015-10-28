//
//  UpdateViewController.m
//  CSharp
//
//  Created by Lalitha Vedachalam on 9/19/15.
//  Copyright (c) 2015 melioSystems. All rights reserved.
//

#import "UpdateViewController.h"
#import "AppDelegate.h"
#import "ValidateViewController.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@interface UpdateViewController ()

@end

@implementation UpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Assigning the user defaults values
    self.mobileNumber                    =   [[NSUserDefaults standardUserDefaults] stringForKey:@"peopleMobileNumber"];
    self.countryCode                     =   [[NSUserDefaults standardUserDefaults] stringForKey:@"peopleCountryCode"];

    
    //For Dismissing
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissAnyOverLappingView)];
    
    [self.view addGestureRecognizer:tap];
    
    //change Back Button name
    UIBarButtonItem *backButtonName     =   [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Update", @"Back Button name")
                                                                            style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonName];
    
    self.navigationItem.hidesBackButton   =   YES;
    
    // Do any additional setup after loading the view.
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
    //Dismiss the keyboard when tap outside
    [self.workTelephoneNumber resignFirstResponder];
    [self.HomeTelephoneNumber resignFirstResponder];
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
    //Keyboard becomes visible
    self.view.frame = CGRectMake(0,-200,self.view.frame.size.width,self.view.frame.size.height);
    //resize
}

/*!
 * @brief TextField delegate called when textfield editing ends
 * @param textField An object representing textfield requesting the data

-(void)textFieldDidEndEditing:(UITextField *)textField {
    //keyboard will hide
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    //Return to original size
}
 */

/*!
 * @brief Validate the two text fields for the empty values and update into the user defaults
 * @param sender An object representing the button actions requesting for the data 
 */
- (IBAction)updateTelephoneNumber:(id)sender {
    // Check for the empty values from the two fields and store the values in the user defaults
    if((![self.workTelephoneNumber.text  isEqual: @""]) && ![self.HomeTelephoneNumber.text isEqual:@""]){
        //To Check Internet Connectivity
        if([self checkInternetConnection]){
            UIStoryboard *storyboard;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            [defaults setValue:self.workTelephoneNumber.text forKey:@"workTelephoneNumber"];
            [defaults setValue:self.HomeTelephoneNumber.text forKey:@"homeTelephoneNumber"];
            
            [defaults synchronize];
            
            if(IS_IPAD)
                storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
            else
                storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            
            ValidateViewController *destViewController = (ValidateViewController *) [storyboard instantiateViewControllerWithIdentifier:@"ValidateViewController"];
            [self.navigationController pushViewController:destViewController animated:YES];
        }
        else{
            [self dismissAnyOverLappingView];
            UIAlertView *alertView  =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message: NSLocalizedString(@"Please Check your Wifi Connection",@"Alert Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
            [alertView show];
        }
    }
    else{
        [self dismissAnyOverLappingView];
         UIAlertView *alertView     =   [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", @"Alert title")
                                                            message:NSLocalizedString(@"Please don't leave the fields blank",@"Alert Message")
                                                            delegate:nil
                                                            cancelButtonTitle:NSLocalizedString(@"OK", @"Action")
                                                            otherButtonTitles:nil];
        [alertView show];
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
