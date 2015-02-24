//
//  Beat.m
//  AmazingSequencer
//
//  Created by Ariel Elkin on 24/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import "Beat.h"

@implementation Beat

+ (instancetype)beatWithOnset:(float)onset
                     velocity:(float)velocity {
    Beat *beat = [[self alloc] init];
    beat.onset = onset;
    beat.velocity = velocity;
    return beat;
}

+ (instancetype)beatWithOnset:(float)onset {
    return [self beatWithOnset:onset velocity:1.0];
}

@end
