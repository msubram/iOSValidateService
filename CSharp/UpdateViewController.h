//
//  UpdateViewController.h
//  CSharp
//
//  Created by Lalitha Vedachalam on 9/19/15.
//  Copyright (c) 2015 melioSystems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateViewController : UIViewController{
    CGFloat animatedDistance;
}

@property (nonatomic, retain) IBOutlet NSString *mobileNumber;

@property (nonatomic, retain) IBOutlet NSString *countryCode;

@property (strong, nonatomic) IBOutlet UITextField *workTelephoneNumber;

@property (strong, nonatomic) IBOutlet UITextField *HomeTelephoneNumber;

- (IBAction)updateTelephoneNumber:(id)sender;

@end
