//
//  SequencerChannelSequence.m
//  AmazingSequencer
//
//  Created by Ariel Elkin on 03/03/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import "SequencerChannelSequence.h"


@implementation SequencerChannelSequence {
    NSMutableArray *sequence;
    BEAT* _sequenceCRepresentation;
}

- (void)addBeat:(SequencerBeat *)beat {

    if (!beat) return;

    if (!sequence) {
        sequence = [NSMutableArray array];
    }

    [sequence addObject:beat];

    [sequence sortUsingComparator:^NSComparisonResult(SequencerBeat *beat1, SequencerBeat *beat2) {
        return beat1.onset > beat2.onset;
    }];


    [self updateSequenceCRepresentation];
}

- (void)removeBeatAtOnset:(float)onset {
    for (int i = 0; i < sequence.count; i++) {
        SequencerBeat *beat = sequence[i];
        if (beat.onset == onset) {
            [sequence removeObject:beat];
        }
    }

    [self updateSequenceCRepresentation];
}

- (void)setOnsetOfBeatAtOnset:(float)oldOnset to:(float)newOnset {
    SequencerBeat *beat = [self beatAtOnset:oldOnset];
    beat.onset = newOnset;
}

- (void)setVelocityOfBeatAtOnset:(float)onset to:(float)newVelocity {
    SequencerBeat *beat = [self beatAtOnset:onset];
    beat.velocity = newVelocity;
}

- (SequencerBeat *)beatAtOnset:(float)onset {

    for (SequencerBeat *beat in sequence) {
        if (beat.onset == onset) {
            return beat;
        }
    }
    return nil;
}

- (NSArray *)allBeats {
    return [NSArray arrayWithArray:sequence];
}

- (NSUInteger)count {
    return sequence.count;
}

#pragma mark -
#pragma mark C Representation

- (void)updateSequenceCRepresentation {
    NSUInteger numberOfBeats = sequence.count;

    _sequenceCRepresentation = (BEAT *)malloc(sizeof(BEAT) * numberOfBeats);

    for(int i=0; i < numberOfBeats; i++) {

        SequencerBeat *beat = sequence[i];

        BEAT cBeat;
        cBeat.onset = beat.onset;
        cBeat.velocity = beat.velocity;

        _sequenceCRepresentation[i] = cBeat;

    }
}

- (BEAT *)sequenceCRepresentation {
    return _sequenceCRepresentation;
}


#pragma mark -
#pragma mark Description

- (NSString *)description {
    NSMutableString *description = @"Sequence Description:\n".mutableCopy;

    for (SequencerBeat *beat in sequence) {
        [description appendFormat:@"%@\n", beat.description];
    }
    return description;
}

@end
