//
//  ContentViewController.m
//  SudoSquare
//
//  Created by Romy Ilano on 11/28/13.
//  Copyright (c) 2013 Romy Ilano. All rights reserved.
//

#import "ContentViewController.h"
#import <ContextCore/QLContent.h>

@interface ContentViewController ()

@end

@implementation ContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationBar.topItem.title = self.content.title;
    
    self.descLabel.text = self.content.contentDescription;
    self.urlLabel.text = self.content.contentUrl;
    self.expiresLabel.text = self.content.expires.description;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)donePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
