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
}

- (void)removeBeatAtOnset:(double)onset {
    
}

- (void)removeBeatAtIndex:(NSUInteger)index{
    if (index < sequence.count) {
        [sequence removeObject:[sequence objectAtIndex:index]];
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

- (SequencerBeat *)beatAtOnset:(double)oldOnset {
    for (SequencerBeat *beat in sequence) {
        if (beat.onset == oldOnset) {
            return beat;
        }
    }
    return nil;
}

- (void)setOnsetOfBeatAtOnset:(double)oldOnset to:(double)newOnset {
    SequencerBeat *beat = [self beatAtOnset:oldOnset];
    beat.onset = newOnset;
}

- (void)setVelocityOfBeatAtOnset:(double)onset to:(double)newVelocity {
    SequencerBeat *beat = [self beatAtOnset:onset];
    beat.velocity = newVelocity;
}

- (NSUInteger)count {
    return sequence.count;
}

#pragma mark -
#pragma mark C Representation

- (double **)CRepresentation {

    NSUInteger numberOfBeats = sequence.count;
    NSUInteger numberOfParametersInBeat = 2;

    double **sequenceCRepresentation = (double**)malloc(numberOfBeats * sizeof(double*));

    for(int i=0; i < numberOfBeats; i++) {
        sequenceCRepresentation[i] = (double*)malloc(numberOfParametersInBeat * sizeof(double));
    }

    for (int i = 0; i < numberOfBeats; i++){
        SequencerBeat *beat = sequence[i];
        sequenceCRepresentation[i][0] = beat.onset;
        sequenceCRepresentation[i][1] = beat.velocity;
    }

    return sequenceCRepresentation;
}


#pragma mark -
#pragma mark Subscripting

- (SequencerBeat *)objectAtIndexedSubscript:(NSUInteger)index {
    return [self beatAtIndex:index];
}

- (void)setObject:(SequencerBeat *)beat atIndexedSubscript:(NSUInteger)index {

    SequencerBeat *theBeat = [self beatAtIndex:index];
    if (theBeat) {
        theBeat = beat;
    }
    else {
        [sequence addObject:beat];
    }
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
