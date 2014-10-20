//
//  BOZVectorProcessor.m
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 10/19/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import "BOZVectorProcessor.h"

#define kReadingsHistoryLength 10

#pragma mark - A quick class to pair readings with timestamps

@interface ReadingTimePair : NSObject

@property (nonatomic) GLKVector3 vector;
@property (strong, nonatomic) NSDate* time;

+ (ReadingTimePair*)pairWithReading:(GLKVector3)reading andTime:(NSDate*)time;

@end

@implementation ReadingTimePair

+ (ReadingTimePair*)pairWithReading:(GLKVector3)reading andTime:(NSDate*)time
{
    ReadingTimePair* pair = [[ReadingTimePair alloc] init];
    pair.vector = reading;
    pair.time = time;
    return pair;
}

@end

#pragma mark - The actual vector processor

@interface BOZVectorProcessor()

@property (strong, nonatomic) NSMutableArray* readingsHistory;

@end

@implementation BOZVectorProcessor

- (id)init {
    self = [super init];
    if(self) {
        self.smoothedVector = GLKVector3Make(0.0f, 0.0f, 0.0f);
        self.readingsHistory = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addReading:(GLKVector3)readingVector atTime:(NSDate*)time
{
    [self.readingsHistory insertObject:[ReadingTimePair pairWithReading:readingVector andTime:time] atIndex:0];
    if(self.readingsHistory.count > kReadingsHistoryLength) {
        [self.readingsHistory removeLastObject];
    }
    
    [self processReadings];
}

- (void)processReadings
{
    GLKVector3 averageVector = GLKVector3Make(0.0f, 0.0f, 0.0f);
    
    for(ReadingTimePair* pair in self.readingsHistory) {
        averageVector = GLKVector3Add(averageVector, pair.vector);
    }
    
    self.smoothedVector = GLKVector3DivideScalar(averageVector, kReadingsHistoryLength);
}

@end
