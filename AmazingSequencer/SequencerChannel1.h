//
//  SequencerChannel1.m
//  AmazingSequencer
//
//  Created by Alejandro Santander on 26/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEAudioController.h"

@interface SequencerChannel1 : NSObject <AEAudioPlayable>

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url
                                audioController:(AEAudioController*)audioController
                                    repeatAtBPM:(UInt64)bpm;

@end
