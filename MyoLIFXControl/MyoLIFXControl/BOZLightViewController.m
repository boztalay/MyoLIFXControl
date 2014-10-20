//
//  BOZLightViewController.m
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 9/10/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import "BOZLightViewController.h"
#import <MyoKit/MyoKit.h>

#define kRollBrightnessControlThreshold 20.0f
#define kBrightnessStep 0.01f;

@implementation BOZLightViewController

#pragma mark - Init

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isControllingColor = NO;
    self.gotFirstOrientationReading = NO;
    
    self.myoView.delegate = self;
}

- (void)setLight:(LFXLight*)light
{
    _light = light;
    self.lightView.light = _light;
    
    self.title = _light.deviceID;
}

#pragma mark - Toggling the light

- (void)myoUnlockedPoseFingersSpread
{
    if(self.light != nil) {
        if(self.light.powerState == LFXPowerStateOn) {
            [self.light setPowerState:LFXPowerStateOff];
        } else {
            [self.light setPowerState:LFXPowerStateOn];
        }
    }
}

#pragma mark - Controlling the light's color

- (void)myoUnlockedPoseFist
{
    if(self.light == nil) {
        return;
    }
    
    self.isControllingColor = YES;
    self.gotFirstOrientationReading = NO;
    [self.myoView holdUnlock];
}

// NOTE: The brightness control won't be symmetrical between arms,
// and doesn't take the X axis orientation into account
- (void)myoOrientationReading:(NSValue*)orientationValue
{
    if(self.light == nil || !self.isControllingColor) {
        return;
    }
    
    GLKVector3 orientation;
    [orientationValue getValue:&orientation];
    
    if(!self.gotFirstOrientationReading) {
        self.firstOrientationReading = orientation;
        self.gotFirstOrientationReading = YES;
        return;
    }
    
    float rollOffInitial = self.firstOrientationReading.x - orientation.x;
    if(rollOffInitial > 180.0f) {
        rollOffInitial -= 360.0f;
    } else if(rollOffInitial < -180.0f) {
        rollOffInitial += 360.0f;
    }
    
    if(fabsf(rollOffInitial) > kRollBrightnessControlThreshold) {
        float brightnessStep = kBrightnessStep;
        if(rollOffInitial > 0.0f) {
            brightnessStep *= -1.0f;
        }
        
        LFXHSBKColor* currentColor = self.light.color;
        CGFloat nextBrightness = currentColor.brightness + brightnessStep;
        
        if(nextBrightness > 1.0f) {
            nextBrightness = 1.0f;
        } else if(nextBrightness < 0.0f) {
            nextBrightness = 0.0f;
        }
        
        [self.light setColor:[LFXHSBKColor colorWithHue:currentColor.hue saturation:currentColor.saturation brightness:nextBrightness]];
    }
}

- (void)myoAtRest
{
    if(self.light == nil) {
        return;
    }
    
    if(self.isControllingColor) {
        self.isControllingColor = NO;
        self.gotFirstOrientationReading = NO;
        [self.myoView forceLock];
    }
}

@end
