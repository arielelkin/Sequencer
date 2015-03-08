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


/*!
 * Adds a beat to the sequence.
 *
 * Beats are automatically sorted by their onsets, in
 * ascending order.
 *
 */
- (void)addBeat:(SequencerBeat *)beat;

/*!
 * Removes a beat from the sequence.
 *
 * Returns nil if sequence does not contain a beat
 * with specified onset.
 *
 */
- (void)removeBeatAtOnset:(float)onset;

/*!
 * Removes a beat from the sequence.
 *
 * Returns nil if index is out of bounds of 
 * sequence array.
 *
 */
- (void)removeBeatAtIndex:(NSUInteger)index;

/*!
 * Sets the onset of a beat located at a specified onset
 * in the sequence.
 *
 */
- (void)setOnsetOfBeatAtOnset:(float)oldOnset to:(float)newOnset;

/*!
 * Sets the onset of a beat located at a specified index
 * in the sequence.
 *
 */
- (void)setVelocityOfBeatAtOnset:(float)onset to:(float)newVelocity;



- (SequencerBeat *)beatAtIndex:(NSUInteger)index;
- (SequencerBeat *)beatAtOnset:(float)onset;

/*!
 * Returns the onset of the beat at a specified position 
 * of the sequence 
 * e.g. float onsetOfThirdBeat = mySequence[2];
 *
 */
- (NSDecimalNumber *)objectAtIndexedSubscript:(NSUInteger)index;

/*!
 * Returns the number of beats present in the sequence.
 *
 */
@property (nonatomic, readonly) NSUInteger count;

/*!
 * Returns a 2-dimensional C array representation of 
 * the sequence. Each row is a beat, the first column
 * is the beat's onset, the second column is the beat's
 * velocity. 
 *
 * e.g. float onsetOfThirdBeat = sequenceCRepresentation[2][0]
 *
 * e.g. float velocityOfFirstBeat = sequenceCRepresentation[0][1]
 *
 */
@property (readonly) float** sequenceCRepresentation;

@end
