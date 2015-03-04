//
//  SequencerChannelSequence.h
//  AmazingSequencer
//
//  Created by Ariel Elkin on 03/03/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SequencerBeat.h"

@interface SequencerChannelSequence : NSObject

//SequencerBeats will always be placed in order
//of their onsets
- (void)addBeat:(SequencerBeat *)beat;

- (void)removeBeatAtOnset:(double)onset;


- (void)setOnsetOfBeatAtOnset:(double)oldOnset to:(double)newOnset;
- (void)setVelocityOfBeatAtOnset:(double)onset to:(double)newVelocity;



- (void)removeBeatAtIndex:(NSUInteger)index;
- (SequencerBeat *)beatAtIndex:(NSUInteger)index;
//Shortcut to access beats by index
//e.g. SequencerBeat *thirdBeat = mySequence[2];
- (SequencerBeat *)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(SequencerBeat *)beat atIndexedSubscript:(NSUInteger)index;

@property (nonatomic, readonly) NSUInteger count;

- (double **)CRepresentation;

@end
