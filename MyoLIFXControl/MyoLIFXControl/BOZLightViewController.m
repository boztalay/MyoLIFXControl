//
//  BOZLightViewController.m
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 9/10/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import "BOZLightViewController.h"

@implementation BOZLightViewController

#pragma mark - Init

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.colorView.layer.cornerRadius = 6.0f;
    self.colorView.layer.borderWidth = 1.0f;
    self.colorView.layer.borderColor = [UIColor clearColor].CGColor;
    
    [self updateColorViewBorder];
}

- (void)setLight:(LFXLight *)light
{
    [self.light removeLightObserver:self];
    _light = light;
    [self.light addLightObserver:self];
    
    [self updateAll];
}

#pragma mark - The Light

- (void)light:(LFXLight *)light didChangeColor:(LFXHSBKColor *)color
{
    [self updateColorViewFromLight];
    [self updateSlidersFromLight];
}

- (void)light:(LFXLight *)light didChangeLabel:(NSString *)label
{
    [self updateTitle];
}

- (void)updateLightColorFromSliders
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

#pragma mark - Sliders

- (IBAction)sliderValueChanged:(id)sender
{
    [self updateColorViewFromSliders];
}

- (IBAction)sliderValueFinishedChanging:(id)sender
{
    [self updateLightColorFromSliders];
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
}

- (void)updateTitle
{
    if(self.light.label.length > 0) {
        self.title = self.light.label;
    } else {
        self.title = self.light.deviceID;
    }
}

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
    
    CGFloat colorViewBorderAlpha = 1.0f - saturation;
    if(saturation < 0.001f && brightness < 0.001f) {
        colorViewBorderAlpha = 0.0f;
    }
    
    self.colorView.layer.borderColor = [UIColor colorWithWhite:0.85f alpha:colorViewBorderAlpha].CGColor;
}

- (void)updateSlidersFromLight
{
    UIColor* lightColor = [self.light.color UIColor];
    const CGFloat* colorComponents = CGColorGetComponents(lightColor.CGColor);

    self.redSlider.value = colorComponents[0];
    self.greenSlider.value = colorComponents[1];
    self.blueSlider.value = colorComponents[2];
}

@end
