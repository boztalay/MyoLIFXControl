//
//  BOZVectorView.h
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 10/19/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface BOZVectorView : UIView

@property (nonatomic) GLKVector3 vector;

@property (weak, nonatomic) IBOutlet UILabel *xLabel;
@property (weak, nonatomic) IBOutlet UILabel *yLabel;
@property (weak, nonatomic) IBOutlet UILabel *zLabel;

@end
