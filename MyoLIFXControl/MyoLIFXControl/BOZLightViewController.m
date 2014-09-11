//
//  BOZLightViewController.m
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 9/10/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import "BOZLightViewController.h"

@implementation BOZLightViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setLight:(LFXLight *)light
{
    _light = light;
    [self.light setColor:[LFXHSBKColor colorWithHue:137.0f saturation:1.0f brightness:1.0f]];
    
    [self updateAll];
}

- (void)updateAll
{
    if(self.light == nil) {
        return;
    }
    
    // Title
    
    if(self.light.label.length > 0) {
        self.title = self.light.label;
    } else {
        self.title = self.light.deviceID;
    }
    
    // Color
    
    UIColor* lightColor = [self.light.color UIColor];
    self.colorView.backgroundColor = lightColor;

    const CGFloat* colorComponents = CGColorGetComponents(lightColor.CGColor);
    self.redSlider.value = colorComponents[0];
    self.greenSlider.value = colorComponents[1];
    self.blueSlider.value = colorComponents[2];
}

@end
