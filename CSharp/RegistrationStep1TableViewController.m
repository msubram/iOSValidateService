//
//  TableViewController.m
//  Validations
//
//  Created by Lalitha Vedachalam on 10/29/15.
//  Copyright © 2015 melioSystems. All rights reserved.
//

#import "RegistrationStep1TableViewController.h"
#import "AppDelegate.h"
#import "RegistrationStep2TableViewController.h"
#import "ValidateViewController.h"
#import "UtilitiesController.h"
#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@interface RegistrationStep1TableViewController ()

@end

@implementation RegistrationStep1TableViewController

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
    
    //For Dismissing
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissAnyOverLappingView)];
    
    [self.tableView addGestureRecognizer:tap];
    
    //change Back Button name
    UIBarButtonItem *backButtonName     =   [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Retry" , @"Back button name")
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonName];
    self.navigationItem.hidesBackButton   =   YES;
    
    /*Change the keyboard view of country textfield to picker view
    * and Setting Value for Country and Picker View
    */
    countries                   =   [[NSArray alloc] initWithObjects: NSLocalizedString(@"India", nil) , NSLocalizedString(@"United Kingdom", nil),NSLocalizedString(@"United States", nil),nil];
    self.peopleCountry.text     =   NSLocalizedString(@"United Kingdom",nil);
    self.countryCode            =   @"44";
    
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    self.peopleCountry.inputView = pickerView;
    [pickerView reloadAllComponents];
    [pickerView selectRow:1 inComponent:0 animated:YES];
    
    
    //Providing the Done Keyboard in the Mobile number textfield
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    self.peopleMobileNumber.inputAccessoryView = numberToolbar;
    
    // Do any additional setup after loading the view, typically from a nib.

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*!
 * @brief Add Done button for the Numpad
 */
-(void)doneWithNumberPad{
    [self.peopleMobileNumber resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
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

/*!
 * @brief Validate the user for the empty field and send the request to the server for the OTP
 * @param sender An object representing the button requesting for the data
 */
- (IBAction)registerUserAfterValidating:(id)sender {
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading", @"Loading text") maskType:SVProgressHUDMaskTypeGradient];
    
    /*For Removing preceding zero
    NSString *mobileNumber      = self.peopleMobileNumber.text;
    
    // Skip leading zeros
    NSScanner *scanner          = [NSScanner scannerWithString:mobileNumber];
    NSCharacterSet *zeros       = [NSCharacterSet characterSetWithCharactersInString:@"0"];
    [scanner scanCharactersFromSet:zeros intoString:NULL];
    
    // Get the rest of the string and log it
    NSString *result = [mobileNumber substringFromIndex:[scanner scanLocation]];
    self.peopleMobileNumber.text    =   result;
     */
    
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
            [SVProgressHUD dismiss];
            UIAlertView *alertView  =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message: NSLocalizedString(@"Please Check your Wifi Connection",@"Alert Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
            [alertView show];
        }
    }
    else{
        [self dismissAnyOverLappingView];
        [SVProgressHUD dismiss];
        UIAlertView *alertView  =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message: NSLocalizedString(@"Please don't leave the fields blank",@"Alert Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
        [alertView show];
    }
}

/*!
 * @brief After requesting the server for OTP switch the view from ViewController to OTPViewController
 * @param notification Carries the particular notification which have been requested
 */
-(void)requestForOTPNotification: (NSNotification *) notification{
    [SVProgressHUD dismiss];
    //Notification after validating the user details
    if ([[notification name] isEqualToString:@"requestForOTPNotification"]) {
        NSDictionary *userInfo = notification.userInfo;
        if([userInfo[@"state"] isEqualToString:@"success"]) {
            UIStoryboard *storyboard;
            if(IS_IPAD)
                storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
            else
                storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            RegistrationStep2TableViewController *destViewController = (RegistrationStep2TableViewController *) [storyboard instantiateViewControllerWithIdentifier:@"RegistrationStep2TableViewController"];
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

/*#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}*/



/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
