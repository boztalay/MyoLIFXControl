//
//  BOZLightView.h
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 10/18/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LIFXKit/LIFXKit.h>

@interface BOZLightView : UIView <LFXLightObserver, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (weak, nonatomic) IBOutlet UISwitch *powerSwitch;
@property (weak, nonatomic) IBOutlet UITextField *labelLabel;

@property (strong, nonatomic) LFXLight* light;

- (IBAction)sliderValueChanged:(id)sender;
- (IBAction)sliderValueFinishedChanging:(id)sender;

- (IBAction)powerSwitchValueChanged:(id)sender;

@end
