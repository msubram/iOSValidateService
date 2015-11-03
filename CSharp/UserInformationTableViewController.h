//
//  UserInformationTableViewController.h
//  Validations
//
//  Created by Lalitha Vedachalam on 10/30/15.
//  Copyright © 2015 melioSystems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInformationTableViewController : UITableViewController

@property (nonatomic, retain) IBOutlet NSString *mobileNumber;

@property (nonatomic, retain) IBOutlet NSString *countryCode;

@property (strong, nonatomic) IBOutlet UITextField *workTelephoneNumber;

@property (strong, nonatomic) IBOutlet UITextField *HomeTelephoneNumber;

- (IBAction)updateTelephoneNumber:(id)sender;


@end
