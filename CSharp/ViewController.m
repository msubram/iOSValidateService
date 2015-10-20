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
    
    //Hud View
    [self.HUDView setHidden:YES];
    self.HUDView.layer.cornerRadius = 5;
    self.HUDView.layer.masksToBounds = YES;
    
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

-(void)dismissAnyOverLappingView{
    //Dismiss the overlapping view when tap outside of the keyboard
    [self.peopleCountry resignFirstResponder];
    [self.peopleMobileNumber resignFirstResponder];
}

- (IBAction)openCountryPickerView:(id)sender {
    //To add picker view for country instead of keyboard
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
        
        [[UtilitiesController sharedInstance] sendRequestForOTP:peopleDataInString];
 
    }
    else{
        UIAlertView *alertView  =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message: NSLocalizedString(@"Please don't leave the fields blank",@"Alert Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
        [alertView show];
    }
}

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
            [self.peopleMobileNumber resignFirstResponder];
            [UIView transitionWithView:self.HUDView duration:1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
                [self.HUDView setHidden:NO];
            } completion:nil];
            //[self.HUDView setHidden:NO];
            double delayInSeconds = 3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [UIView transitionWithView:self.HUDView duration:1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
                    [self.HUDView setHidden:YES];
                } completion:nil];
            });
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
