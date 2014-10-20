//
//  BOZMyoViewDelegate.h
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 10/20/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BOZMyoViewDelegate

@optional

- (void)myoUnlocked;
- (void)myoUnlockedPoseFist;
- (void)myoUnlockedPoseFingersSpread;
- (void)myoUnlockedPoseWaveIn;
- (void)myoUnlockedPoseWaveOut;
- (void)myoLocked;

@end