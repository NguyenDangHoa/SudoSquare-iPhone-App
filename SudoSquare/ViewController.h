//
//  ViewController.h
//  SudoSquare
//
//  Created by Romy Ilano on 11/28/13.
//  Copyright (c) 2013 Romy Ilano. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ContextCore/QLContextCore.h>
#import <ContextLocation/QLContextPlaceConnector.h>
#import <ContextProfiling/PRContextInterestsConnector.h>


#import <ContextProfiling/PRProfile.h>

@interface ViewController : UIViewController <QLContextCorePermissionsDelegate, QLContextPlaceConnectorDelegate, PRContextInterestsDelegate, QLTimeContentDelegate>

@property (nonatomic, strong) QLContextCoreConnector *contextCoreConnector;
@property (nonatomic, strong) QLContextPlaceConnector *contextPlaceConnector;
@property (nonatomic, strong) PRContextInterestsConnector *contextInterestsConnector;
@property (nonatomic, strong) QLContentConnector *contentConnector;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *enableSDKButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *contentInfoLabel;

-(IBAction)enableSDK:(id)sender;
-(IBAction)showPermissions:(id)sender;


@end
