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

- (void)setOnset:(double)onset {
    if (onset >= 0) {
        _onset = onset;
    }
    else {
        NSLog(@"%s onset can't be < 0, setting to 0", __PRETTY_FUNCTION__);
        _onset = 0;
    }
}

- (void)setVelocity:(double)velocity {
    if(velocity >= 0 && velocity <= 1) {
        _velocity = velocity;
    }
    else if (velocity < 0) {
        NSLog(@"%s velocity can't be < 0, setting to 0", __PRETTY_FUNCTION__);
        _velocity = 0;
    }
    else if (velocity > 1) {
        NSLog(@"%s velocity can't be > 1, setting to 1", __PRETTY_FUNCTION__);
        _velocity = 1;
    }
}

+ (instancetype)beatWithOnset:(double)onset {
    return [self beatWithOnset:onset velocity:1.0];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Onset: %.3f ||| Velocity: %.3f", self.onset, self.velocity];
}

@end
