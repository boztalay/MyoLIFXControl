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
#define kUnlockTimeout 1.5

@interface BOZMyoView()

@property (strong, nonatomic) BOZVectorProcessor* accelerationProcessor;
@property (strong, nonatomic) BOZVectorProcessor* gyroProcessor;
@property (strong, nonatomic) BOZVectorProcessor* orientationProcessor;

@property (strong, nonatomic) NSTimer* lockTimer;
@property (nonatomic) BOOL isLocked;

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
        self.gyroProcessor = [[BOZVectorProcessor alloc] init];
        self.orientationProcessor = [[BOZVectorProcessor alloc] init];
        
        [self initMyo];
    }
    return self;
}

- (void)initMyo
{
    // Init the locking logic
    
    self.isLocked = YES;
    
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
    
    // Find a Myo
    
    [[TLMHub sharedHub] attachToAny];
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
    
    self.isLocked = YES;
    [self updateLockedStatusLabel];
}

- (void)didReceiveArmLostEvent:(NSNotification*)notification {
    NSLog(@"Arm lost: %@", notification.userInfo);
    
    self.armLabel.text = @"Uninitialized";
    self.currentPoseLabel.text = @"Uninitialized";
    self.lockStatusLabel.text = @"Uninitialized";
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
    
    if(pose.type == TLMPoseTypeUnknown) {
        return;
    } else if(pose.type == TLMPoseTypeRest && [self.delegate respondsToSelector:@selector(myoAtRest)]) {
        [self.delegate myoAtRest];
        return;
    }
    
    if(pose.type == TLMPoseTypeThumbToPinky) {
        [self unlock];
    } else {
        if(!self.isLocked) {
            [self unlock];
        }
    }
    
    if(self.isLocked) {
        return;
    }
    
    switch(pose.type) {
        case TLMPoseTypeFist:
            if([self.delegate respondsToSelector:@selector(myoUnlockedPoseFist)]) {
                [self.delegate myoUnlockedPoseFist];
            }
            break;
        case TLMPoseTypeWaveIn:
            if([self.delegate respondsToSelector:@selector(myoUnlockedPoseWaveIn)]) {
                [self.delegate myoUnlockedPoseWaveIn];
            }
            break;
        case TLMPoseTypeWaveOut:
            if([self.delegate respondsToSelector:@selector(myoUnlockedPoseWaveOut)]) {
                [self.delegate myoUnlockedPoseWaveOut];
            }
            break;
        case TLMPoseTypeFingersSpread:
            if([self.delegate respondsToSelector:@selector(myoUnlockedPoseFingersSpread)]) {
                [self.delegate myoUnlockedPoseFingersSpread];
            }
            break;
        default: break;
    }
}

#pragma mark - Lock management

- (void)unlock
{
    self.isLocked = NO;
    
    [self.lockTimer invalidate];
    self.lockTimer = [NSTimer scheduledTimerWithTimeInterval:kUnlockTimeout target:self selector:@selector(lock:) userInfo:nil repeats:NO];
    
    [self updateLockedStatusLabel];
    
    if([self.delegate respondsToSelector:@selector(myoUnlocked)]) {
        [self.delegate myoUnlocked];
    }
}

- (void)lock:(NSTimer*)timer
{
    self.isLocked = YES;
    [self updateLockedStatusLabel];
    
    if(timer != nil && [self.delegate respondsToSelector:@selector(myoUnlocked)]) {
        [self.delegate myoLocked];
    }
}

- (void)holdUnlock
{
    [self.lockTimer invalidate];
}

- (void)forceLock
{
    [self.lockTimer invalidate];
    [self lock:nil];
}

- (void)updateLockedStatusLabel
{
    if(self.isLocked) {
        self.lockStatusLabel.text = @"Locked";
    } else {
        self.lockStatusLabel.text = @"Unlocked";
    }
}

#pragma mark - Motion data notifications

- (void)didReceiveAccelerometerEvent:(NSNotification*)notification {
    TLMAccelerometerEvent* accelerometerEvent = notification.userInfo[kTLMKeyAccelerometerEvent];
    
    [self.accelerationProcessor addReading:accelerometerEvent.vector atTime:accelerometerEvent.timestamp];
    self.accelerationView.vector = self.accelerationProcessor.smoothedVector;
    
    if([self.delegate respondsToSelector:@selector(myoAccelerationReading:)]) {
        [self.delegate myoAccelerationReading:[self.accelerationProcessor smoothedVectorValue]];
    }
}

- (void)didReceiveGyroscopeEvent:(NSNotification*)notification {
    TLMGyroscopeEvent* gyroscopeEvent = notification.userInfo[kTLMKeyGyroscopeEvent];
    
    [self.gyroProcessor addReading:gyroscopeEvent.vector atTime:gyroscopeEvent.timestamp];
    self.gyroView.vector = self.gyroProcessor.smoothedVector;
    
    if([self.delegate respondsToSelector:@selector(myoGyroReading:)]) {
        [self.delegate myoGyroReading:[self.gyroProcessor smoothedVectorValue]];
    }
}

- (void)didReceiveOrientationEvent:(NSNotification*)notification {
    TLMOrientationEvent* orientationEvent = notification.userInfo[kTLMKeyOrientationEvent];
    
    GLKQuaternion orientationQuaternion = orientationEvent.quaternion;
    TLMEulerAngles* orientationEulerAngles = [TLMEulerAngles anglesWithQuaternion:orientationQuaternion];
    
    GLKVector3 orientationVector = GLKVector3Make(orientationEulerAngles.roll.degrees, orientationEulerAngles.pitch.degrees, orientationEulerAngles.yaw.degrees);
    
    [self.orientationProcessor addReading:orientationVector atTime:orientationEvent.timestamp];
    self.orientationView.vector = self.orientationProcessor.smoothedVector;
    
    if([self.delegate respondsToSelector:@selector(myoOrientationReading:)]) {
        [self.delegate myoOrientationReading:[self.orientationProcessor smoothedVectorValue]];
    }
}

@end
