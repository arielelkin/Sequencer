//
//  SequencerChannel3.m
//  AmazingSequencer
//
//  Created by Alejandro Santander on 26/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEAudioController.h"
#import "SequencerBeat.h"
#import "SequencerChannelSequence.h"

@interface SequencerChannel : NSObject <AEAudioPlayable>

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url
                                audioController:(AEAudioController*)audioController
                                   withSequence:(SequencerChannelSequence*)sequence
                    numberOfFullBeatsPerMeasure:(NSUInteger)beatsPerMeasure
                                          atBPM:(double)bpm;

@property (nonatomic) SequencerChannelSequence *sequence;
@property (nonatomic, readwrite) float volume;
@property (nonatomic, readwrite) float pan;                 
@property bool sequenceIsPlaying;
@property double bpm;
@property (nonatomic, readonly) float playheadPosition;
@property bool muted;
@property int soloed; // 1 = soloed, -1 = not soloed, 0 = ignore

@end
