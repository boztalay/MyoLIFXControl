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
    
    self.myoView.delegate = self;
}

- (void)setLight:(LFXLight*)light
{
    _light = light;
    self.lightView.light = _light;
    
    self.title = _light.deviceID;
}

- (void)myoUnlockedPoseFingersSpread
{
    if(self.light != nil) {
        [self.lightView toggleLight];
    }
}

- (void)myoUnlockedPoseFist
{
    
}

@end
