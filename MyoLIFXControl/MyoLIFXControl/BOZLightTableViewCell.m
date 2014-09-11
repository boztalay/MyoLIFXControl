//
//  BOZLightTableViewCell.m
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 9/10/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import "BOZLightTableViewCell.h"

@implementation BOZLightTableViewCell

+ (NSString*)reuseIdentifier
{
    return @"LightCell";
}

- (void)setWithLight:(LFXLight*)light
{
    self.textLabel.text = light.label;
    self.detailTextLabel.text = light.deviceID;
}

@end
