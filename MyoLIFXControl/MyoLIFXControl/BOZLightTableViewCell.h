//
//  BOZLightTableViewCell.h
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 9/10/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LIFXKit/LIFXKit.h>

@interface BOZLightTableViewCell : UITableViewCell

+ (NSString*)reuseIdentifier;

- (void)setWithLight:(LFXLight*)light;

@end
