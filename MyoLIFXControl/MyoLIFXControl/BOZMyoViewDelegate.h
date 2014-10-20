//
//  BOZMyoViewDelegate.h
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 10/20/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@protocol BOZMyoViewDelegate <NSObject>

@optional

- (void)myoAtRest;
- (void)myoUnlocked;
- (void)myoUnlockedPoseFist;
- (void)myoUnlockedPoseFingersSpread;
- (void)myoUnlockedPoseWaveIn;
- (void)myoUnlockedPoseWaveOut;
- (void)myoLocked;

- (void)myoAccelerationReading:(NSValue*)accelerationValue;
- (void)myoGyroReading:(NSValue*)gyroValue;
- (void)myoOrientationReading:(NSValue*)orientationValue;

@end