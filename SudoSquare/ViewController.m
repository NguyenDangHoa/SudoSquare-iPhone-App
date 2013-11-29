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

@interface ViewController ()

-(void)displayLastKnownPlaceEvent;
-(void)savePlaceEvent:(QLPlaceEvent *)placeEvent;
-(void)displaceLastKnownContentDescriptor;

@end

@implementation ViewController
-(id)init
{
    self = [super init];
    
    if (self)
    {
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
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
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
            self.contentInfoLabel.text = nil;
        }
    }];

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self setEnableSDKButton:nil];
    [self setPlaceNameLabel:nil];
    [self setContentInfoLabel:nil];
    
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
    
    switch (placeEvent.placeType) {
        case <#constant#>:
            <#statements#>
            break;
            
        default:
            break;
    }
    
}

@end

