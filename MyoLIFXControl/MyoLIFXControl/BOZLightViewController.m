//
//  BOZLightViewController.m
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 9/10/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import "BOZLightViewController.h"
#import <MyoKit/MyoKit.h>

@implementation BOZLightViewController

#pragma mark - Init

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lightView.layer.borderColor = [[UIColor redColor] CGColor];
    self.lightView.layer.borderWidth = 2.0f;
    
    self.myoView.layer.borderColor = [[UIColor blueColor] CGColor];
    self.myoView.layer.borderWidth = 2.0f;
}

- (void)setLight:(LFXLight*)light
{
    _light = light;
    self.lightView.light = _light;
}

@end
