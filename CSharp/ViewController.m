//
//  ViewController.m
//  CSharp
//
//  Created by Lalitha Vedachalam on 9/19/15.
//  Copyright (c) 2015 melioSystems. All rights reserved.
///Users/lalithavedachalam/Documents/Vishal/CSharp/CSharp/ViewController.m

#import "ViewController.h"
#import "AppDelegate.h"
#import "UtilitiesController.h"
#import "OTPViewController.h"
#import "ValidateViewController.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    //Checking for the user details, if present user will be redirectd to the Validate View Controller
    NSUserDefaults *data                 =   [NSUserDefaults standardUserDefaults];
    NSString *mobileNumber               =   [data valueForKey:@"peopleMobileNumber"];
    NSString *workTelephoneNumber        =   [data valueForKey:@"workTelephoneNumber"];
    NSString *homeTelephoneNumber        =   [data valueForKey:@"homeTelephoneNumber"];
    if(mobileNumber && workTelephoneNumber && homeTelephoneNumber){
        UIStoryboard *storyboard;
        if(IS_IPAD)
            storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
        else
            storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        ValidateViewController *destViewController = (ValidateViewController *) [storyboard instantiateViewControllerWithIdentifier:@"ValidateViewController"];
        [self.navigationController pushViewController:destViewController animated:YES];
    }
    
    [super viewDidLoad];
    
    //Setting Value for Country and Picker View
    countries                   =   [[NSArray alloc] initWithObjects: NSLocalizedString(@"India", nil) , NSLocalizedString(@"United Kingdom", nil),NSLocalizedString(@"United States", nil),nil];
    self.peopleCountry.text     =   NSLocalizedString(@"India",nil);
    self.countryCode            =   @"91";
    
    //For Dismissing
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissAnyOverLappingView)];
    
    [self.view addGestureRecognizer:tap];
    
    //change Back Button name
    UIBarButtonItem *backButtonName     =   [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Retry" , @"Back button name")
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonName];
    
    self.navigationItem.hidesBackButton   =   YES;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    //Adding Notification for moving to Registration : step 2
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestForOTPNotification:)
                                                 name:@"requestForOTPNotification"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //Notification removed when view gets disappear
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"requestForOTPNotification"
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
    [self.peopleCountry resignFirstResponder];
    [self.peopleMobileNumber resignFirstResponder];
}

/*!
 * @brief Changes the keyboard view into the picker view when tapped the UITextField
 */
- (IBAction)openCountryPickerView:(id)sender {
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    self.peopleCountry.inputView = pickerView;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    // Add One column
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //set number of rows
    return 3;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //set item per row
    return [countries objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    //Setting the value based on the row selected
    if(row==0){
        self.peopleCountry.text  =   NSLocalizedString(@"India", nil);
        self.countryCode =   @"91";
    }
    else if(row==1){
        self.peopleCountry.text  =   NSLocalizedString(@"United Kingdom", nil);
        self.countryCode =   @"44";
    }
    else{ 
        self.peopleCountry.text  =   NSLocalizedString(@"United States", nil);
        self.countryCode =   @"1";
    }
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
    //After Keyboard becomes visible
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
 * @brief Validate the user for the empty field and send the request to the server for the OTP
 * @param sender An object representing the button requesting for the data
 */
- (IBAction)registerUserAfterValidating:(id)sender {
    // Validating the user for empty entries in the mobile number text field
    if(![self.peopleMobileNumber.text  isEqual: @""]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setValue:self.peopleMobileNumber.text forKey:@"peopleMobileNumber"];
        [userDefaults setValue:self.countryCode forKey:@"peopleCountryCode"];
        
        [userDefaults synchronize];
        
        NSDictionary *valuesForServer = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",self.countryCode],@"CountryCode",
                                         [NSString stringWithFormat:@"%@",self.peopleMobileNumber.text], @"MobileNumber", nil];
        NSError * err;
        NSData * peopleData   = [NSJSONSerialization  dataWithJSONObject:valuesForServer options:0 error:&err];
        NSString * peopleDataInString = [[NSString alloc] initWithData:peopleData encoding:NSUTF8StringEncoding];
        //To Check Internet Connectivity
        if([self checkInternetConnection]){
            [[UtilitiesController sharedInstance] sendRequestForOTP:peopleDataInString];
        }
        else{
            [self dismissAnyOverLappingView];
            UIAlertView *alertView  =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message: NSLocalizedString(@"Please Check your Wifi Connection",@"Alert Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
            [alertView show];
        }
    }
    else{
        [self dismissAnyOverLappingView];
        UIAlertView *alertView  =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message: NSLocalizedString(@"Please don't leave the fields blank",@"Alert Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
        [alertView show];
    }
}

/*!
 * @brief After requesting the server for OTP switch the view from ViewController to OTPViewController
 * @param notification Carries the particular notification which have been requested
 */
-(void)requestForOTPNotification: (NSNotification *) notification{
    //Notification after validating the user details
    if ([[notification name] isEqualToString:@"requestForOTPNotification"]) {
        NSDictionary *userInfo = notification.userInfo;
        if([userInfo[@"state"] isEqualToString:@"success"]) {
            UIStoryboard *storyboard;
            if(IS_IPAD)
                storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
            else
                storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            OTPViewController *destViewController = (OTPViewController *) [storyboard instantiateViewControllerWithIdentifier:@"OTPViewController"];
            [self.navigationController pushViewController:destViewController animated:YES];
        }
        else {
            [self dismissAnyOverLappingView];
            UIAlertView *alertView  =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message: NSLocalizedString(@"Please Check your Wifi Connection",@"Alert Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
            [alertView show];
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
