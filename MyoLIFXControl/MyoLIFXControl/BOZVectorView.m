//
//  BOZVectorView.m
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 10/19/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import "BOZVectorView.h"

#define kNibName @"BOZVectorView"

@implementation BOZVectorView

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
    }
    return self;
}

- (void)setVector:(GLKVector3)vector
{
    _vector = vector;
    
    self.xLabel.text = [NSString stringWithFormat:@"%0.4f", _vector.x];
    self.yLabel.text = [NSString stringWithFormat:@"%0.4f", _vector.y];
    self.zLabel.text = [NSString stringWithFormat:@"%0.4f", _vector.z];
}

@end
