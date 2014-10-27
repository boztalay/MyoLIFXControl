//
//  BOZLightViewController.m
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 9/10/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import "BOZLightViewController.h"
#import <MyoKit/MyoKit.h>

#define kBrightnessStep 0.05f
#define kBrightnessStepInterval 0.1f
#define kBrightnessLockGracePeriod 1.0f

#define kPitchSaturationRange 70.0f
#define kPitchSaturationHalfRange (kPitchSaturationRange / 2.0f)
#define kSaturationMax 1.0f

#define kYawHueRange 80.0f
#define kHueMax 360.0f
#define kHueIncrementPerUnitYaw (kHueMax / kYawHueRange)

@implementation BOZLightViewController

#pragma mark - Init

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isControllingBrightness = NO;
    self.isControllingColor = NO;
    self.gotFirstReadings = NO;
    
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
    if(self.light == nil) {
        return;
    }
    
    [self.brightnessLockGraceTimer invalidate];
    
    if(self.light.powerState == LFXPowerStateOn) {
        [self.light setPowerState:LFXPowerStateOff];
    } else {
        [self.light setPowerState:LFXPowerStateOn];
    }
}

#pragma mark - Brightness control

- (void)myoUnlockedPoseWaveIn
{
    [self startSteppingBrightnessBy:-kBrightnessStep];
}

- (void)myoUnlockedPoseWaveOut
{
    [self startSteppingBrightnessBy:kBrightnessStep];
}

- (void)startSteppingBrightnessBy:(CGFloat)brightnessStep
{
    if(self.light == nil) {
        return;
    }
    
    self.brightnessStep = brightnessStep;
    
    self.isControllingBrightness = YES;
    [self.myoView holdUnlock];
    
    [self.brightnessLockGraceTimer invalidate];
    self.brightnessTimer = [NSTimer scheduledTimerWithTimeInterval:kBrightnessStepInterval target:self selector:@selector(stepBrightness:) userInfo:nil repeats:YES];
}

- (void)stepBrightness:(NSTimer*)timer
{
    LFXHSBKColor* currentColor = self.light.color;
    
    CGFloat nextBrightness = currentColor.brightness + self.brightnessStep;
    if(nextBrightness < 0.0f) {
        nextBrightness = 0.0f;
    } else if(nextBrightness > 1.0f) {
        nextBrightness = 1.0f;
    }
    
    currentColor.brightness = nextBrightness;
    self.light.color  = currentColor;
}

#pragma mark - Color control

- (void)myoUnlockedPoseFist
{
    if(self.light == nil) {
        return;
    }
    
    [self.brightnessLockGraceTimer invalidate];
    
    self.isControllingColor = YES;
    self.gotFirstReadings = NO;
    [self.myoView holdUnlock];
}

// NOTE: The color controls don't take into account
// how the armband is oriented (toward elbow or wrist)
- (void)myoOrientationReading:(NSValue*)orientationValue
{
    if(self.light == nil || !self.isControllingColor) {
        return;
    }
    
    GLKVector3 orientation;
    [orientationValue getValue:&orientation];
    
    if(!self.gotFirstReadings) {
        self.firstOrientationReading = orientation;
        self.firstColor = self.light.color;
        self.gotFirstReadings = YES;
        return;
    }
    
    float pitchOffInitial = self.firstOrientationReading.y - orientation.y;
    if(pitchOffInitial > 180.0f) {
        pitchOffInitial -= 360.0f;
    } else if(pitchOffInitial < -180.0f) {
        pitchOffInitial += 360.0f;
    }
    
    float yawOffInitial = self.firstOrientationReading.z - orientation.z;
    if(yawOffInitial > 180.0f) {
        yawOffInitial -= 360.0f;
    } else if(yawOffInitial < -180.0f) {
        yawOffInitial += 360.0f;
    }
    
    // Saturation with pitch
    
    if(pitchOffInitial > kPitchSaturationHalfRange) {
        pitchOffInitial = kPitchSaturationHalfRange;
    } else if(pitchOffInitial < -kPitchSaturationHalfRange) {
        pitchOffInitial = -kPitchSaturationHalfRange;
    }
    
    CGFloat pitchRangeProportion = (pitchOffInitial + kPitchSaturationHalfRange) / kPitchSaturationRange;
    pitchRangeProportion = 1.0f - pitchRangeProportion;
    CGFloat nextSaturation = pitchRangeProportion * kSaturationMax;
    if(nextSaturation > kSaturationMax) {
        nextSaturation = kSaturationMax;
    } else if(nextSaturation < 0.0f) {
        nextSaturation = 0.0f;
    }
    
    // Hue with yaw
    
    CGFloat hueOffset = yawOffInitial * kHueIncrementPerUnitYaw;
    CGFloat nextHue = fmodf(self.firstColor.hue + hueOffset, kHueMax);
    
    NSLog(@"%0.2f | %0.2f |||| %0.2f | %0.2f", pitchOffInitial, yawOffInitial, nextSaturation, nextHue);
    
    [self.light setColor:[LFXHSBKColor colorWithHue:nextHue saturation:nextSaturation brightness:self.light.color.brightness]];
}

- (void)myoAtRest
{
    if(self.isControllingBrightness) {
        [self.brightnessTimer invalidate];
        self.brightnessLockGraceTimer = [NSTimer scheduledTimerWithTimeInterval:kBrightnessLockGracePeriod target:self selector:@selector(brightnessLockGracePeriodComplete:) userInfo:nil repeats:NO];
    }
    
    if(self.isControllingColor) {
        self.isControllingColor = NO;
        self.gotFirstReadings = NO;
        [self.myoView forceLock];
    }
}

- (void)brightnessLockGracePeriodComplete:(NSTimer*)timer
{
    self.isControllingBrightness = NO;
    [self.myoView forceLock];
}

@end
