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

@interface SequencerChannel : NSObject <AEAudioPlayable>

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url
                                audioController:(AEAudioController*)audioController
                                    withPattern:(NSMutableArray*)beats // of Beat
                                   withDuration:(NSUInteger)numBeats
                                          atBPM:(double)bpm;

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url
                                audioController:(AEAudioController*)audioController
                                    withPattern:(NSMutableArray*)beats // of Beat
                                          atBPM:(double)bpm;

@property (strong, nonatomic) NSMutableArray *sequence;

@end
