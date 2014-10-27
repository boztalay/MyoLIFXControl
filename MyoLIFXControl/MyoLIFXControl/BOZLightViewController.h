//
//  BOZLightViewController.h
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 9/10/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LIFXKit/LIFXKit.h>
#import "BOZLightView.h"
#import "BOZMyoView.h"

@interface BOZLightViewController : UIViewController <LFXLightObserver, BOZMyoViewDelegate>

@property (weak, nonatomic) IBOutlet BOZLightView* lightView;
@property (weak, nonatomic) IBOutlet BOZMyoView* myoView;

@property (strong, nonatomic) LFXLight* light;

@property (nonatomic) BOOL isControllingBrightness;
@property (strong, nonatomic) NSTimer* brightnessTimer;
@property (strong, nonatomic) NSTimer* brightnessLockGraceTimer;
@property (nonatomic) CGFloat brightnessStep;

@property (nonatomic) BOOL isControllingColor;
@property (nonatomic) BOOL gotFirstReadings;
@property (nonatomic) GLKVector3 firstOrientationReading;
@property (strong, nonatomic) LFXHSBKColor* firstColor;

@end
