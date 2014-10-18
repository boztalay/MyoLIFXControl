//
//  BOZLightView.m
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 10/18/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import "BOZLightView.h"

#define kNibName @"BOZLightView"

@implementation BOZLightView

#pragma mark - Init

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self addSubview:[[[NSBundle mainBundle] loadNibNamed:kNibName owner:self options:nil] firstObject]];
        
        self.colorView.layer.cornerRadius = 6.0f;
        self.colorView.layer.borderWidth = 1.0f;
        self.colorView.layer.borderColor = [UIColor clearColor].CGColor;
        
        [self updateColorViewBorder];
        
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setLight:(LFXLight*)light
{
    [self.light removeLightObserver:self];
    _light = light;
    [self.light addLightObserver:self];
    
    self.userInteractionEnabled = YES;
    [self updateAll];
}

#pragma mark - The Light

- (void)light:(LFXLight*)light didChangeColor:(LFXHSBKColor*)color
{
    [self updateColorViewFromLight];
    [self updateSlidersFromLight];
}

- (void)light:(LFXLight*)light didChangeLabel:(NSString*)label
{
    [self updateTitle];
}

- (void)light:(LFXLight*)light didChangePowerState:(LFXPowerState)powerState
{
    [self updatePowerSwitchFromLight];
}

#pragma mark - Sliders

- (IBAction)sliderValueChanged:(id)sender
{
    [self updateColorViewFromSliders];
}

- (IBAction)sliderValueFinishedChanging:(id)sender
{
    [self setLightColorFromSliders];
}

- (void)setLightColorFromSliders
{
    UIColor* colorFromSliders = [self getColorFromSliders];
    CGFloat hue, saturation, brightness, alpha;
    [colorFromSliders getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    [self.light setColor:[LFXHSBKColor colorWithHue:(hue * 360.0f) saturation:saturation brightness:brightness]];
}

- (UIColor*)getColorFromSliders
{
    return [UIColor colorWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value alpha:1.0f];
}

- (void)enableSliders
{
    self.redSlider.userInteractionEnabled = YES;
    self.greenSlider.userInteractionEnabled = YES;
    self.blueSlider.userInteractionEnabled = YES;
}

- (void)disableSliders
{
    self.redSlider.userInteractionEnabled = NO;
    self.greenSlider.userInteractionEnabled = NO;
    self.blueSlider.userInteractionEnabled = NO;
}

#pragma mark - Power Switch

- (IBAction)powerSwitchValueChanged:(id)sender
{
    if(self.powerSwitch.isOn) {
        [self.light setPowerState:LFXPowerStateOn];
    } else {
        [self.light setPowerState:LFXPowerStateOff];
    }
}

#pragma mark - Label

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.labelLabel resignFirstResponder];
    [self.light setLabel:textField.text];
    
    return YES;
}

#pragma mark - Updating Views

- (void)updateAll
{
    if(self.light == nil) {
        return;
    }
    
    [self updateTitle];
    [self updateColorViewFromLight];
    [self updateSlidersFromLight];
    [self updatePowerSwitchFromLight];
}

#pragma mark Title

- (void)updateTitle
{
    self.labelLabel.text = self.light.label;
}

#pragma mark Color View

- (void)updateColorViewFromLight
{
    UIColor* lightColor = [self.light.color UIColor];
    self.colorView.backgroundColor = lightColor;
    [self updateColorViewBorder];
}

- (void)updateColorViewFromSliders
{
    self.colorView.backgroundColor = [self getColorFromSliders];
    [self updateColorViewBorder];
}

- (void)updateColorViewBorder
{
    CGFloat hue, saturation, brightness, alpha;
    [self.colorView.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    CGFloat colorViewBorderAlpha = (1.0f - saturation) * brightness;
    
    self.colorView.layer.borderColor = [UIColor colorWithWhite:0.85f alpha:colorViewBorderAlpha].CGColor;
}

#pragma mark Sliders

- (void)updateSlidersFromLight
{
    UIColor* lightColor = [self.light.color UIColor];
    const CGFloat* colorComponents = CGColorGetComponents(lightColor.CGColor);

    [UIView animateWithDuration:0.3 animations:^(void) {
        [self.redSlider setValue:colorComponents[0] animated:YES];
        [self.greenSlider setValue:colorComponents[1] animated:YES];
        [self.blueSlider setValue:colorComponents[2] animated:YES];
    }];
}

#pragma mark Power Switch

- (void)updatePowerSwitchFromLight
{
    if(self.light.powerState == LFXPowerStateOn) {
        [self.powerSwitch setOn:YES animated:YES];
        [self enableSliders];
    } else {
        [self.powerSwitch setOn:NO animated:YES];
        [self disableSliders];
    }
}

@end
