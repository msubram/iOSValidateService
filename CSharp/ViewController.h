//
//  ViewController.h
//  CSharp
//
//  Created by Lalitha Vedachalam on 9/19/15.
//  Copyright (c) 2015 melioSystems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>{
    NSArray *countries;
    CGFloat animatedDistance;
}

@property (strong, nonatomic) IBOutlet UIImageView *appLogo;

@property (strong, nonatomic) IBOutlet UITextField *peopleMobileNumber;

@property (strong, nonatomic) IBOutlet UITextField *peopleCountry;

@property (nonatomic, retain) IBOutlet NSString *countryCode;

- (IBAction)openCountryPickerView:(id)sender;

- (IBAction)registerUserAfterValidating:(id)sender;

@end

