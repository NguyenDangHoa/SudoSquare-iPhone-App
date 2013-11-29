//
//  ViewController.m
//  SudoSquare
//
//  Created by Romy Ilano on 11/28/13.
//  Copyright (c) 2013 Romy Ilano. All rights reserved.
//

#import "ViewController.h"
#import "ContentViewController.h"


#import <ContextLocation/QLPlace.h>
#import <ContextLocation/QLPlaceEvent.h>
#import <ContextLocation/QLContentDescriptor.h>

#import <ContextProfiling/PRProfile.h>

@interface ViewController ()

-(void)displayLastKnownPlaceEvent;
-(void)savePlaceEvent:(QLPlaceEvent *)placeEvent;
-(void)displaceLastKnownContentDescriptor;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"SudoSquare";
    
    self.contextCoreConnector = [[QLContextCoreConnector alloc] init];
    self.contextCoreConnector.permissionsDelegate = self;
    
    self.contextPlaceConnector = [[QLContextPlaceConnector alloc] init];
    self.contextPlaceConnector.delegate = self;
    
    self.contextInterestsConnector = [[PRContextInterestsConnector alloc] init];
    self.contextInterestsConnector.delegate = self;
    
    NSLog(@"Initializing connector");
    
    self.contentConnector = [[QLContentConnector alloc] init];
    self.contentConnector.delegate = self;

    //
  
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [self.contextCoreConnector checkStatusAndOnEnabled:^(QLContextConnectorPermissions *contextConnectorPermissions) {
        
        if (contextConnectorPermissions.subscriptionPermission)
        {
            if (_contextPlaceConnector.isPlacesEnabled)
            {
                [self displayLastKnownPlaceEvent];
            }
        }
        
    } disabled:^(NSError *error) {
        NSLog(@"%@", error);
        if (error.code == QLContextCoreNonCompatibleOSVersion)
        {
            NSLog(@"%@", @"GIMBAL SDK requires iOS 5.0 or higher");
        }
        else
        {
            _enableSDKButton.enabled = YES;
            self.placeNameLabel.text = nil;
            self.sudoMessageLabel.text = nil;
        }
    }];

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self setEnableSDKButton:nil];
    [self setPlaceNameLabel:nil];
    [self setSudoMessageLabel:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - Action Methods

-(IBAction)enableSDK:(id)sender
{
    [_contextCoreConnector enableFromViewController:self.navigationController
                                            success:^{
                                                _enableSDKButton.enabled = NO;
                                            } failure:^(NSError *error) {
                                                NSLog(@"%@", error);
                                            }];
    
}

-(IBAction)showPermissions:(id)sender
{
    [_contextCoreConnector showPermissionsFromViewController:self
                                                     success:NULL
                                                     failure:^(NSError *error) {
                                                         NSLog(@"%@", error);
                                                     }];
    
}

-(void)displayLastKnownPlaceEvent
{
    self.placeNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"PlaceEventKey"];
    
}

-(void)savePlaceEvent:(QLPlaceEvent *)placeEvent
{
    NSString *placeTitle = nil;
    
    switch (placeEvent.eventType)
    {
        case QLPlaceEventTypeAt:
            placeTitle = [NSString stringWithFormat:@"At %@", placeEvent.place.name];
            break;
        case QLPlaceEventTypeLeft:
            placeTitle = [NSString stringWithFormat:@"Left %@", placeEvent.place.name];
            break;
    }
    [[NSUserDefaults standardUserDefaults] setObject:placeTitle
                                              forKey:@"PlaceEventKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)displaceLastKnownContentDescriptor
{
    [self.contextPlaceConnector requestContentHistoryAndOnSuccess:^(NSArray *contentHistories) {
        if ([contentHistories count] > 0)
        {
            QLContentDescriptor *lastKnownContentDescriptor = [contentHistories objectAtIndex:0];
            self.sudoMessageLabel.text = lastKnownContentDescriptor.title;
        }
    } failure:^(NSError *error) {
        NSLog(@"Failed to fetch content: %@", [error localizedDescription]);
    }];
}

-(void)postOneContentDescriptorLocalNotification:(QLContentDescriptor *)contentDescriptor
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertAction = NSLocalizedString(@"Foo", nil);
    localNotification.alertBody = [NSString stringWithFormat:@"%@", contentDescriptor.title];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark - QLContextCorePermissionsDelegate Methods
-(void)subscriptionPermissionDidChange:(BOOL)subscriptionPermission
{
     if (subscriptionPermission)
     {
         if (_contextPlaceConnector.isPlacesEnabled)
         {
             [self displayLastKnownPlaceEvent];
         }
         else
         {
             self.placeNameLabel.text = @"";
             
         }
         _enableSDKButton.enabled = NO;
     }
    else
    {
        self.placeNameLabel.text = @"";
        self.sudoMessageLabel.text = @"";
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
       [self.contextCoreConnector checkStatusAndOnEnabled:NULL
                                                 disabled:^(NSError *error) {
                                                     _enableSDKButton.enabled = YES;
       }];
    }
}

#pragma mark - QLContextPlaceConnectorDelegate Methods
-(void)didGetPlaceEvent:(QLPlaceEvent *)placeEvent
{
    NSLog(@"Got place event");
    [self savePlaceEvent:placeEvent];
    [self displayLastKnownPlaceEvent];
}

-(void)didGetContentDescriptors:(NSArray *)contentDescriptors
{
    self.sudoMessageLabel.text = [[contentDescriptors lastObject] title];
    
    [self displaceLastKnownContentDescriptor];
    
    for (QLContentDescriptor *contentDescriptor in contentDescriptors)
    {
        [self postOneContentDescriptorLocalNotification:contentDescriptor];
    }
}

-(void)placesPermissionDidChange:(BOOL)placesPermission
{
    if (placesPermission)
    {
        [self displayLastKnownPlaceEvent];
        [self displaceLastKnownContentDescriptor];
    }
    else
    {
        self.placeNameLabel.text = NSLocalizedString(@"LOCATION_PERMISSION_TURNED_OFF", @"permission turned off for user");
        self.sudoMessageLabel.text = @"";
    }
}

-(void)didReceiveNotification:(QLContentNotification *)notification appState:(QLNotificationAppState)appState
{
    NSLog(@"SudoSquare: didReceiveNotification: %@ - %d", notification.message, appState);
    
    [self.contentConnector contentWithId:notification.contentId
                                 success:^(QLContent *content) {
                                     NSLog(@"requestContentForID: success: %@", content.title);
                                     
                                     ContentViewController *contentViewController = [[ContentViewController alloc] init];
                                     contentViewController.content = content;
                                     
                                     // to-do make this a storyboard segue
                                     [self.navigationController presentViewController:contentViewController animated:YES completion:nil];
                                     
                                 } failure:^(NSError *error) {
                                     NSLog(@"requestContentForID: error: %@", error);
                                 }];
}

@end

