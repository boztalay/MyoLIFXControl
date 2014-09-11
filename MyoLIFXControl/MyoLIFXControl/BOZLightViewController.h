//
//  BOZLightViewController.h
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 9/10/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LIFXKit/LIFXKit.h>

@interface BOZLightViewController : UIViewController <LFXLightObserver>

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;

@property (strong, nonatomic) LFXLight* light;

- (IBAction)sliderValueChanged:(id)sender;
- (IBAction)sliderValueFinishedChanging:(id)sender;

@end
