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
    float **_sequenceCRepresentation;
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

- (void)removeBeatAtIndex:(NSUInteger)index{
    if (index < sequence.count) {
        [sequence removeObject:[sequence objectAtIndex:index]];
        [self updateSequenceCRepresentation];
    }
    else {
        NSLog(@"%s index %d out of bounds, there are %d beats.", __PRETTY_FUNCTION__, index, sequence.count);
    }
}

- (SequencerBeat *)beatAtIndex:(NSUInteger)index {

    if (index < sequence.count) {
        return sequence[index];
    }
    else {
        NSLog(@"%s index %d out of bounds, there are %d beats, returning nil.", __PRETTY_FUNCTION__, index, sequence.count);
        return nil;
    }
}

- (SequencerBeat *)beatAtOnset:(float)onset {
    
    for (SequencerBeat *beat in sequence) {
        if (beat.onset == onset) {
            return beat;
        }
    }
    return nil;
}

- (NSUInteger)indexOfBeatAtOnset:(float)onset {
    for (NSUInteger i = 0; i < sequence.count; i++) {
        SequencerBeat *beat = sequence[i];
        if (beat.onset == onset) {
            return i;
        }
    }
    return -1;
}

- (void)setOnsetOfBeatAtOnset:(float)oldOnset to:(float)newOnset {
    SequencerBeat *beat = [self beatAtOnset:oldOnset];
    beat.onset = newOnset;
}

- (void)setVelocityOfBeatAtOnset:(float)onset to:(float)newVelocity {
    SequencerBeat *beat = [self beatAtOnset:onset];
    beat.velocity = newVelocity;
}

- (NSUInteger)count {
    return sequence.count;
}

#pragma mark -
#pragma mark C Representation

- (void)updateSequenceCRepresentation {
    NSUInteger numberOfBeats = sequence.count;
    NSUInteger numberOfParametersInBeat = 2;

    _sequenceCRepresentation = (float**)malloc(numberOfBeats * sizeof(float*));

    for(int i=0; i < numberOfBeats; i++) {
        _sequenceCRepresentation[i] = (float*)malloc(numberOfParametersInBeat * sizeof(float));
    }

    for (int i = 0; i < numberOfBeats; i++){
        SequencerBeat *beat = sequence[i];
        _sequenceCRepresentation[i][0] = beat.onset;
        _sequenceCRepresentation[i][1] = beat.velocity;
    }
}

- (float **)sequenceCRepresentation {
    return _sequenceCRepresentation;
}


#pragma mark -
#pragma mark Subscripting

- (NSNumber *)objectAtIndexedSubscript:(NSUInteger)index {

    return @([[self beatAtIndex:index] onset]);
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
