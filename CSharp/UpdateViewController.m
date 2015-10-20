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

-(void)dismissAnyOverLappingView{
    //Dismiss the keyboard when tap outside
    [self.workTelephoneNumber resignFirstResponder];
    [self.HomeTelephoneNumber resignFirstResponder];
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

- (IBAction)updateTelephoneNumber:(id)sender {
    // Check for the empty values from the two fields and store the values in the user defaults
    if((![self.workTelephoneNumber.text  isEqual: @""]) && ![self.HomeTelephoneNumber.text isEqual:@""]){
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
