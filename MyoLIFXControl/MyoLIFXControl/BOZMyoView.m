//
//  BOZMyoView.m
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 10/18/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import "BOZMyoView.h"
#import <MyoKit/MyoKit.h>

#define kNibName @"BOZMyoView"

@implementation BOZMyoView

#pragma mark - Init

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self addSubview:[[[NSBundle mainBundle] loadNibNamed:kNibName owner:self options:nil] firstObject]];
        
        [[TLMHub sharedHub] attachToAny];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceivePoseChange:)
                                                     name:TLMMyoDidReceivePoseChangedNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Pose changes

- (void)didReceivePoseChange:(NSNotification*)notification {
    TLMPose* pose = notification.userInfo[kTLMKeyPose];
    
    switch(pose.type) {
        case TLMPoseTypeRest:
            self.currentPoseLabel.text = @"Rest";
            break;
        case TLMPoseTypeFist:
            self.currentPoseLabel.text = @"Fist";
            break;
        case TLMPoseTypeWaveIn:
            self.currentPoseLabel.text = @"Wave In";
            break;
        case TLMPoseTypeWaveOut:
            self.currentPoseLabel.text = @"Wave Out";
            break;
        case TLMPoseTypeFingersSpread:
            self.currentPoseLabel.text = @"Fingers Spread";
            break;
        case TLMPoseTypeThumbToPinky:
            self.currentPoseLabel.text = @"Thumb to Pinky";
            break;
        case TLMPoseTypeUnknown:
            self.currentPoseLabel.text = @"Unknown";
            break;
    }
}

@end
