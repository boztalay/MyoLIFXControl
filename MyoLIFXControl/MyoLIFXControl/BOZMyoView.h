//
//  BOZMyoView.h
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 10/18/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BOZVectorView.h"
#import "BOZMyoViewDelegate.h"

@interface BOZMyoView : UIView

@property (weak, nonatomic) id<BOZMyoViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *myoNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPoseLabel;
@property (weak, nonatomic) IBOutlet UILabel *lockStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *armLabel;
@property (weak, nonatomic) IBOutlet BOZVectorView *accelerationView;
@property (weak, nonatomic) IBOutlet BOZVectorView *gyroView;
@property (weak, nonatomic) IBOutlet BOZVectorView *orientationView;

- (void)holdUnlock;
- (void)forceLock;

@end
