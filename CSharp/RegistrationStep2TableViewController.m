//
//  RegistrationStep2TableViewController.m
//  Validations
//
//  Created by Lalitha Vedachalam on 10/30/15.
//  Copyright © 2015 melioSystems. All rights reserved.
//

#import "RegistrationStep2TableViewController.h"
#import "AppDelegate.h"
#import "UtilitiesController.h"
#import "SVProgressHUD.h"
#import "UserInformationTableViewController.h"

@interface RegistrationStep2TableViewController ()

@end

@implementation RegistrationStep2TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mobileNumber                    =   [[NSUserDefaults standardUserDefaults] stringForKey:@"peopleMobileNumber"];
    self.countryCode                     =   [[NSUserDefaults standardUserDefaults] stringForKey:@"peopleCountryCode"];
    
    
    //For Dismissing
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissAnyOverLappingView)];
    
    [self.view addGestureRecognizer:tap];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
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

/*!
 * @brief Send the specific values for the server and check whether the given
 * @param sender An object representing the button actions requesting for the data
 */
- (IBAction)validateOTP:(id)sender {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading", @"Loading text") maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *enteredOTPValue   =   [NSString stringWithFormat:@"%@%@%@%@%@",self.OTPFirstDigit.text,self.OTPSecondDigit.text,self.OTPThirdDigit.text,self.OTPFourthDigit.text,self.OTPFifthDigit.text];
    
    NSString *valuesForServer = [NSString stringWithFormat:@"{\"MobileInfo\":{\"CountryCode\":\"%@\",\"MobileNumber\":\"%@\"},\"RegCode\":%@}",self.countryCode,self.mobileNumber, enteredOTPValue];
    
    //To Check Internet Connectivity
    if([self checkInternetConnection]){
        [[UtilitiesController sharedInstance] sendRequestToValidateOTP:valuesForServer];
    }
    else{
        [SVProgressHUD dismiss];
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
                [SVProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message:NSLocalizedString(@"Please enter a valid OTP token",@"Alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles:nil];
                [alert show];
                self.OTPFirstDigit.text     =   @"";
                self.OTPSecondDigit.text    =   @"";
                self.OTPThirdDigit.text     =   @"";
                self.OTPFourthDigit.text    =   @"";
                self.OTPFifthDigit.text     =   @"";
            }
            else{
                NSString *registrationToken       =   [[NSUserDefaults standardUserDefaults]objectForKey:@"registrationToken"];
                [[UtilitiesController sharedInstance] GCMRegistrationProcess:registrationToken];
            }
        }
        else {
            [self dismissAnyOverLappingView];
            [SVProgressHUD dismiss];
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
    [SVProgressHUD dismiss];
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
            UserInformationTableViewController *destViewController = (UserInformationTableViewController *) [storyboard instantiateViewControllerWithIdentifier:@"UserInformationTableViewController"];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

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
