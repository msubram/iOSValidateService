//
//  ValidateViewController.m
//  CSharp
//
//  Created by Lalitha Vedachalam on 9/19/15.
//  Copyright (c) 2015 melioSystems. All rights reserved.
//

#import "ValidateViewController.h"
#import "AppDelegate.h"
#import "UtilitiesController.h"
#import "UpdateViewController.h"
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface ValidateViewController ()

@end

@implementation ValidateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Getting default view
    self.mobileNumber                    =   [[NSUserDefaults standardUserDefaults] stringForKey:@"peopleMobileNumber"];
    self.countryCode                     =   [[NSUserDefaults standardUserDefaults] stringForKey:@"peopleCountryCode"];
    self.workTelephoneNumber             =   [[NSUserDefaults standardUserDefaults] stringForKey:@"workTelephoneNumber"];
    self.HomeTelephoneNumber             =   [[NSUserDefaults standardUserDefaults] stringForKey:@"HomeTelephoneNumber"];
    
    
    
    //change Back Button name
    UIBarButtonItem *leftNavigationButton     =   [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"< %@",NSLocalizedString(@"Update", @"Back Button name")] 
                                                                            style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(showUpdateView:)];
    [self.navigationItem setLeftBarButtonItem:leftNavigationButton];
    
    self.navigationItem.hidesBackButton   =   YES;

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    //Notification to validate app
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(validationProcessNotification:)
                                            name:@"validationProcessNotification"
                                            object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //Remove validate app Notification
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                            name:@"validationProcessNotification"
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
 * @brief Shows the UpdateView When the Left bar button id cliked
 * @param sender An object representing the button actions requesting for the data
 */
-(void)showUpdateView:(UIBarButtonItem *)sender{
    UIStoryboard *storyboard;
    if(IS_IPAD)
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    else
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
    UpdateViewController *destViewController = (UpdateViewController *) [storyboard instantiateViewControllerWithIdentifier:@"UpdateViewController"];
    [self.navigationController pushViewController:destViewController animated:YES];
    
}

/*!
 * @brief After Clicking the validate button the message will be broadcasted using the UDP protocol and listen for the return packets
 * @param sender An object representing the button actions requesting for the data
 */
- (IBAction)validationProcess:(id)sender {
    //To Check Internet Connectivity
    if([self checkInternetConnection]){
        //Loader saying please wait... validating
        self.alertView  =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please wait... Validating",@"Alert title") message: NSLocalizedString(@"",@"Alert Message") delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loading.frame=CGRectMake(150, 150, 16, 16);
        [self.alertView addSubview:loading];
        [self.alertView show];
        
        //Starting UDP broadcast
        int socketSD = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
        if (socketSD <= 0) {
            NSLog(@"Error: Could not open socket.");
            return;
        }
        
        // set socket options enable broadcast
        int broadcastEnable = 1;
        int ret = setsockopt(socketSD, SOL_SOCKET, SO_BROADCAST, &broadcastEnable, sizeof(broadcastEnable));
        if (ret) {
            NSLog(@"Error: Could not open set socket to broadcast mode");
            close(socketSD);
            return;
        }
        
        // Configure the port and ip we want to send to
        struct sockaddr_in broadcastAddr;
        memset(&broadcastAddr, 0, sizeof(broadcastAddr));
        broadcastAddr.sin_family = AF_INET;
        inet_pton(AF_INET, "255.255.255.255", &broadcastAddr.sin_addr);
        broadcastAddr.sin_port = htons(32233);
        /* Broadcast message converting the dictionary to the string */
        NSDictionary *valuesForServer = [[NSDictionary alloc] initWithObjectsAndKeys:self.countryCode, @"CountryCode", self.mobileNumber, @"MobileNumber", [NSString stringWithFormat:@"%@", [self getIPAddress]], @"IP", @"IPhone", @"Name", @"", @"EndPoint", @"38798", @"UDPListenPort", nil];
        
        NSError * err;
        NSData * jsonData   = [NSJSONSerialization  dataWithJSONObject:valuesForServer options:0 error:&err];
        NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        /* End */
        
        const char *c   =   [myString UTF8String];
        
        //Getting the return value
        ret = sendto(socketSD, c, strlen(c), 0, (struct sockaddr*)&broadcastAddr, sizeof(broadcastAddr));
        
        //Based on ret value
        if (ret < 0) {
            NSLog(@"Error: Could not open send broadcast.");
            close(socketSD);
            return;
        }
        
        //close the socket and listen for the ret packets
        close(socketSD);
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self listenForPackets];
            [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
        });
        
        [connectionTimer invalidate];
        connectionTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(checkConnection) userInfo:nil repeats:NO];
    }
    else{
        UIAlertView *alertView  =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message: NSLocalizedString(@"Please Check your Wifi Connection",@"Alert Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
        [alertView show];
    }
}

/*!
 * @brief After the message have been broadcasted the client will be listening for the return packets from the server
 */
- (void)listenForPackets{
    int listeningSocket = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (listeningSocket <= 0) {
        NSLog(@"Error: listenForPackets - socket() failed.");
        return;
    }
    
    // set timeout to 2 seconds.
    struct timeval timeV;
    timeV.tv_sec = 2;
    timeV.tv_usec = 0;
    
    if (setsockopt(listeningSocket, SOL_SOCKET, SO_RCVTIMEO, &timeV, sizeof(timeV)) == -1) {
        NSLog(@"Error: listenForPackets - setsockopt failed");
        close(listeningSocket);
        return;
    }
    
    // bind the port
    struct sockaddr_in sockaddr;
    memset(&sockaddr, 0, sizeof(sockaddr));
    
    sockaddr.sin_len = sizeof(sockaddr);
    sockaddr.sin_family = AF_INET;
    sockaddr.sin_port = htons(38798);
    sockaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    int status = bind(listeningSocket, (struct sockaddr *)&sockaddr, sizeof(sockaddr));
    if (status == -1) {
        close(listeningSocket);
        NSLog(@"Error: listenForPackets - bind() failed.");
        return;
    }
    
    // receive
    struct sockaddr_in receiveSockaddr;
    socklen_t receiveSockaddrLen = sizeof(receiveSockaddr);
    
    size_t bufSize = 9216;
    void *buf = malloc(bufSize);
    ssize_t result = recvfrom(listeningSocket, buf, bufSize, 0, (struct sockaddr *)&receiveSockaddr, &receiveSockaddrLen);
    
    NSData *data = nil;
    
    if (result > 0) {
        if ((size_t)result != bufSize) {
            buf = realloc(buf, result);
        }
        data = [NSData dataWithBytesNoCopy:buf length:result freeWhenDone:YES];
        
        char addrBuf[INET_ADDRSTRLEN];
        if (inet_ntop(AF_INET, &receiveSockaddr.sin_addr, addrBuf, (size_t)sizeof(addrBuf)) == NULL) {
            addrBuf[0] = '\0';
        }
        
        NSString *address = [NSString stringWithCString:addrBuf encoding:NSASCIIStringEncoding];
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@ and %@", address, msg);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didReceiveMessage:msg fromAddress:address];
        });
        
    } else {
        free(buf);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message:NSLocalizedString(@"Something went wrong.Please try again.",@"Alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles:nil];
            [alert show];
        });
    }
    
    close(listeningSocket);
}

/*!
 * @brief To get the device IP Address
 */
- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

/*!
 * @brief Function is called once the packet is received and the request is made based on the received message
 * @param message Holds the message from the server
 * @param address Holds the IP-Address of the user's device
 */
- (void)didReceiveMessage:(NSString *)message fromAddress:(NSString *)address{
    //To Check Internet Connectivity
    if([self checkInternetConnection]){
        [[UtilitiesController sharedInstance] sendRequestForValidation:message];
    }
    else{
        UIAlertView *alertView  =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message: NSLocalizedString(@"Please Check your Wifi Connection",@"Alert Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
        [alertView show];
    }
}

/*!
 * @brief Check for the Internet Connectivity for every t seconds
 */
-(void)checkConnection{
    if(![self checkInternetConnection]){
        UIAlertView *alertView  =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message: NSLocalizedString(@"Please Check your Wifi Connection",@"Alert Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
        [alertView show];
    }
}

/*!
 * @brief Request is made to the server to validate users based on the received message
 * @param notification Holds the return message from the server and name of the notification
 */
-(void)validationProcessNotification :(NSNotification *) notification{
    //Check whether the notification receive is same
    if ([[notification name] isEqualToString:@"validationProcessNotification"]) {
        [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
        NSDictionary *userInfo = notification.userInfo;
        //Check for the status
        if([userInfo[@"state"] isEqualToString:@"success"]) {
            if([userInfo[@"data"] isEqualToString:@"-1"]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert Title") message:NSLocalizedString(@"Something went wrong.Please try again.",@"Alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles:nil];
                [alert show];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert Title")  message:NSLocalizedString(@"Successfully Validated",@"Alert Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles:nil];
                [alert show];
            }
        }
        else {
            //Show message if there is any problem in connection
            UIAlertView *alertView  =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"Alert title") message: NSLocalizedString(@"Please Check your Wifi Connection",@"Alert Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Action") otherButtonTitles: nil];
            [alertView show];
        }
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
