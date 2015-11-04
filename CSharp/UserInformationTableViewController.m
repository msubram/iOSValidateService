//
//  UserInformationTableViewController.m
//  Validations
//
//  Created by Lalitha Vedachalam on 10/30/15.
//  Copyright © 2015 melioSystems. All rights reserved.
//

#import "UserInformationTableViewController.h"
#import "AppDelegate.h"
#import "ValidateViewController.h"
#import "SVProgressHUD.h"

@interface UserInformationTableViewController ()

@end

@implementation UserInformationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Assigning the user defaults values
    self.mobileNumber                    =   [[NSUserDefaults standardUserDefaults] stringForKey:@"peopleMobileNumber"];
    self.countryCode                     =   [[NSUserDefaults standardUserDefaults] stringForKey:@"peopleCountryCode"];
    NSUserDefaults *data                 =   [NSUserDefaults standardUserDefaults];
    NSString *workTelephoneNumber        =   [data valueForKey:@"workTelephoneNumber"];
    NSString *homeTelephoneNumber        =   [data valueForKey:@"homeTelephoneNumber"];
    if(workTelephoneNumber && homeTelephoneNumber){
        self.workTelephoneNumber.text    =      workTelephoneNumber;
        self.HomeTelephoneNumber.text    =      homeTelephoneNumber;
    }
    
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
    
    //Display the next button for the Work telephone number textfield
    UIToolbar* numberToolbarForWorkTelephone = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbarForWorkTelephone.barStyle = UIBarStyleDefault;
    numberToolbarForWorkTelephone.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(nextWithNumberPad)]];
    [numberToolbarForWorkTelephone sizeToFit];
    self.workTelephoneNumber.inputAccessoryView = numberToolbarForWorkTelephone;
    
    //Display the Done button for the Home telephone number textfield
    UIToolbar* numberToolbarForHomeTelephone = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbarForHomeTelephone.barStyle = UIBarStyleDefault;
    numberToolbarForHomeTelephone.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Prev" style:UIBarButtonItemStyleBordered target:self action:@selector(previousWithNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];

    [numberToolbarForHomeTelephone sizeToFit];
    self.HomeTelephoneNumber.inputAccessoryView = numberToolbarForHomeTelephone;
    
    // Do any additional setup after loading the view.

}

/*!
 * @brief Add Next button for the Numpad
 */
-(void)nextWithNumberPad{
    [self.HomeTelephoneNumber becomeFirstResponder];
}

/*!
 * @brief Add Previous button for the Numpad
 */
-(void)previousWithNumberPad{
    [self.workTelephoneNumber becomeFirstResponder];
}

/*!
 * @brief Add Done button for the Numpad
 */
-(void)doneWithNumberPad{
    [self.HomeTelephoneNumber resignFirstResponder];
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

/*!
 * @brief Temporary Function to send registration token
 */

- (IBAction)sendRegistrationTokenViaMail:(id)sender {
    // Email Subject
    NSString *emailTitle = @"Registration token";
    // Email Content
    NSUserDefaults *data                 =   [NSUserDefaults standardUserDefaults];
    NSString *messageBody                =   [data valueForKey:@"registrationToken"];
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"vishal@meliosystems.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alertView;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            alertView  =   [[UIAlertView alloc] initWithTitle:@"Mail cancelled" message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
            [alertView show];
            break;
        case MFMailComposeResultSaved:
            alertView  =   [[UIAlertView alloc] initWithTitle:@"Mail saved" message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
            [alertView show];
            break;
        case MFMailComposeResultSent:
            alertView  =   [[UIAlertView alloc] initWithTitle:@"Mail sent" message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
            [alertView show];
            break;
        case MFMailComposeResultFailed:
            alertView  =   [[UIAlertView alloc] initWithTitle:@"Mail sent failure" message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
            [alertView show];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
/* End */


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
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
