//
//  BOZMyoView.m
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 10/18/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import "BOZMyoView.h"
#import "BOZVectorProcessor.h"
#import <MyoKit/MyoKit.h>

#define kNibName @"BOZMyoView"

@interface BOZMyoView()

@property (strong, nonatomic) BOZVectorProcessor* accelerationProcessor;

@end

@implementation BOZMyoView

#pragma mark - Init

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        UIView* loadedView = [[[NSBundle mainBundle] loadNibNamed:kNibName owner:self options:nil] firstObject];
        loadedView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:loadedView];
        
        // Yay autolayout
        [self addConstraint:[NSLayoutConstraint constraintWithItem:loadedView attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:loadedView attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self attribute:NSLayoutAttributeTop
                                                        multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:loadedView attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self attribute:NSLayoutAttributeRight
                                                        multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:loadedView attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0 constant:0.0]];
        
        self.accelerationProcessor = [[BOZVectorProcessor alloc] init];
        
        [self initMyo];
    }
    return self;
}

- (void)initMyo
{
    [[TLMHub sharedHub] attachToAny];
    
    // Hub notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectDevice:)
                                                 name:TLMHubDidConnectDeviceNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnectDevice:)
                                                 name:TLMHubDidDisconnectDeviceNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAttachDevice:)
                                                 name:TLMHubDidAttachDeviceNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDetachDevice:)
                                                 name:TLMHubDidDetachDeviceNotification
                                               object:nil];
    
    // Arms and poses
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveArmRecognizedEvent:)
                                                 name:TLMMyoDidReceiveArmRecognizedEventNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveArmLostEvent:)
                                                 name:TLMMyoDidReceiveArmLostEventNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];
    
    // Motion
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAccelerometerEvent:)
                                                 name:TLMMyoDidReceiveAccelerometerEventNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveGyroscopeEvent:)
                                                 name:TLMMyoDidReceiveGyroscopeEventNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveOrientationEvent:)
                                                 name:TLMMyoDidReceiveOrientationEventNotification
                                               object:nil];
}

#pragma mark - Myo connection notifications

- (void)didConnectDevice:(NSNotification*)notification {
    NSLog(@"Device connected!");
}

- (void)didDisconnectDevice:(NSNotification*)notification {
    NSLog(@"Device disconnected!");
}

- (void)didAttachDevice:(NSNotification*)notification {
    NSLog(@"Device attached!");
    TLMMyo* myo = [[TLMHub sharedHub].myoDevices firstObject];
    
    self.myoNameLabel.text = myo.name;
}

- (void)didDetachDevice:(NSNotification*)notification {
    NSLog(@"Device detached!");
    
    self.myoNameLabel.text = @"Uninitialized";
}

#pragma mark - Arm recognition notifications

- (void)didReceiveArmRecognizedEvent:(NSNotification*)notification {
    NSLog(@"Arm recognized: %@", notification.userInfo);
    TLMArmRecognizedEvent* armRecognizedEvent = notification.userInfo[kTLMKeyArmRecognizedEvent];
    
    switch(armRecognizedEvent.arm) {
        case TLMArmRight:
            self.armLabel.text = @"Right";
            break;
        case TLMArmLeft:
            self.armLabel.text = @"Left";
            break;
    }
}

- (void)didReceiveArmLostEvent:(NSNotification*)notification {
    NSLog(@"Arm lost: %@", notification.userInfo);
    
    self.armLabel.text = @"Uninitialized";
    self.currentPoseLabel.text = @"Uninitialized";
}

#pragma mark - Pose change notification

- (void)didReceivePoseChange:(NSNotification*)notification {
    NSLog(@"Pose change: %@", notification.userInfo);
    
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

#pragma mark - Motion data notifications

- (void)didReceiveAccelerometerEvent:(NSNotification*)notification {
    TLMAccelerometerEvent* accelerometerEvent = notification.userInfo[kTLMKeyAccelerometerEvent];
    GLKVector3 accelerationVector = accelerometerEvent.vector;
    
    [self.accelerationProcessor addReading:accelerationVector atTime:accelerometerEvent.timestamp];
    
    self.accelerationView.vector = self.accelerationProcessor.smoothedVector;
}

- (void)didReceiveGyroscopeEvent:(NSNotification*)notification {
    TLMGyroscopeEvent* gyroscopeEvent = notification.userInfo[kTLMKeyGyroscopeEvent];
    GLKVector3 gyroVector = gyroscopeEvent.vector;
    self.gyroView.vector = gyroVector;
}

- (void)didReceiveOrientationEvent:(NSNotification*)notification {
    TLMOrientationEvent* orientationEvent = notification.userInfo[kTLMKeyOrientationEvent];
    
    GLKQuaternion orientationQuaternion = orientationEvent.quaternion;
    TLMEulerAngles* orientationEulerAngles = [TLMEulerAngles anglesWithQuaternion:orientationQuaternion];
    
    GLKVector3 orientationVector = GLKVector3Make(orientationEulerAngles.roll.degrees, orientationEulerAngles.pitch.degrees, orientationEulerAngles.yaw.degrees);
    
    self.orientationView.vector = orientationVector;
}

@end
