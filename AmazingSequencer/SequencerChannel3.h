//
//  SequencerChannel3.m
//  AmazingSequencer
//
//  Created by Alejandro Santander on 26/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEAudioController.h"
#import "Beat.h"

@interface SequencerChannel3 : NSObject <AEAudioPlayable>

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url
                                audioController:(AEAudioController*)audioController
                                    withPattern:(NSMutableArray*)beats // of Beat
                                          atBPM:(UInt64)bpm;

@end
