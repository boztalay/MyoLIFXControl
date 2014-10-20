//
//  BOZVectorProcessor.m
//  MyoLIFXControl
//
//  Created by Ben Oztalay on 10/19/14.
//  Copyright (c) 2014 Ben Oztalay. All rights reserved.
//

#import "BOZVectorProcessor.h"

#define kReadingsHistoryLength 10
#define kJerkHistoryLength 10
#define kNumReadingsToIncludeInJerkCalculation 3
#define kImpulseEventJerkThreshold 7.0
#define kImpulseEventJerkToAverageRatioMax 25.0

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
@property (strong, nonatomic) NSMutableArray* jerkHistory;

@end

@implementation BOZVectorProcessor

- (id)init {
    self = [super init];
    if(self) {
        self.smoothedVector = GLKVector3Make(0.0f, 0.0f, 0.0f);
        self.readingsHistory = [[NSMutableArray alloc] init];
        self.jerkHistory = [[NSMutableArray alloc] init];
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
    // Calculate the smoothed vector
    
    GLKVector3 averageVector = GLKVector3Make(0.0f, 0.0f, 0.0f);
    
    for(ReadingTimePair* pair in self.readingsHistory) {
        averageVector = GLKVector3Add(averageVector, pair.vector);
    }
    
    self.smoothedVector = GLKVector3DivideScalar(averageVector, kReadingsHistoryLength);
    
    // See if there was an impulse event
    
    if(self.readingsHistory.count < kNumReadingsToIncludeInJerkCalculation) {
        return;
    }
    
    ReadingTimePair* mostRecentReading = [self.readingsHistory firstObject];
    ReadingTimePair* readingToAverageFrom = [self.readingsHistory objectAtIndex:kNumReadingsToIncludeInJerkCalculation - 1];
    
    double secondsBetweenReadings = [mostRecentReading.time timeIntervalSinceDate:readingToAverageFrom.time];
    double deltaLengthBetweenReadings = GLKVector3Length(mostRecentReading.vector) - GLKVector3Length(readingToAverageFrom.vector);
    double jerk = fabs(deltaLengthBetweenReadings / secondsBetweenReadings);
    
    if(self.jerkHistory.count >= kJerkHistoryLength) {
        double jerkAverage = 0.0;
        for(NSNumber* historicalJerk in self.jerkHistory) {
            jerkAverage += historicalJerk.doubleValue;
        }
        jerkAverage /= kJerkHistoryLength;
        
        NSLog(@"\t%0.1f\t\t%0.1f", jerk, jerkAverage);
        
        // This is getting a little convoluted
        if(jerk > kImpulseEventJerkMin && jerk < kImpulseEventJerkMax) {
            double jerkToAverage = jerk / jerkAverage;
            if(jerkToAverage > kImpulseEventJerkToAverageRatioMin && jerkToAverage < kImpulseEventJerkToAverageRatioMax) {
                NSLog(@"\t\t\t\t\t\t\t\tImpulse!");
            }
        }
    }
    
    [self.jerkHistory insertObject:[NSNumber numberWithDouble:jerk] atIndex:0];
    if(self.jerkHistory.count > kJerkHistoryLength) {
        [self.jerkHistory removeLastObject];
    }
}

@end
