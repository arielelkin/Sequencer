//
//  Beat.m
//  AmazingSequencer
//
//  Created by Ariel Elkin on 24/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import "SequencerBeat.h"

@implementation SequencerBeat

+ (instancetype)beatWithOnset:(double)onset
                     velocity:(double)velocity {
    SequencerBeat *beat = [[self alloc] init];
    beat.onset = onset;
    beat.velocity = velocity;
    return beat;
}

+ (instancetype)beatWithOnset:(double)onset {
    return [self beatWithOnset:onset velocity:1.0];
}

@end
