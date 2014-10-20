//
//  BOZVectorProcessor.h
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 10/19/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface BOZVectorProcessor : NSObject

@property (nonatomic) GLKVector3 smoothedVector;

- (void)addReading:(GLKVector3)readingVector atTime:(NSDate*)time;

@end
