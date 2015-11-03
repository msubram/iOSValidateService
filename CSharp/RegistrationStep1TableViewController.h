//
//  TableViewController.h
//  Validations
//
//  Created by Lalitha Vedachalam on 10/29/15.
//  Copyright © 2015 melioSystems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistrationStep1TableViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>{
    NSArray *countries;
    CGFloat animatedDistance;
}

@property (strong, nonatomic) IBOutlet UITextField *peopleMobileNumber;

@property (strong, nonatomic) IBOutlet UITextField *peopleCountry;

@property (nonatomic, retain) IBOutlet NSString *countryCode;

- (IBAction)registerUserAfterValidating:(id)sender;

@end
