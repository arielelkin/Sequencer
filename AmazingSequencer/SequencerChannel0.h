//
//  MyChannel.h
//  AmazingSequencer
//
//  Created by Ariel Elkin on 25/06/2014.
//  Copyright (c) 2014 Ariel Elkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEAudioController.h"

@interface SequencerChannel0 : NSObject <AEAudioPlayable>

/*!
 * Sequencer channel
 *
 *  This class allows you to play audio files within a sequencer.
 *  For now, the file repeats at a certain BPM.
 *
 *  TODO:
 *  Enable setting time intervals other than BPM.
 *
 *  To use, create an instance, then add it to the audio controller.
 */

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url
                                audioController:(AEAudioController*)audioController
                                    repeatAtBPM:(UInt64)bpm;

//TODO:
//Stops playback of the file
- (void) stopPlayback;

//TODO:
// Set a new BPM for the file to play back at:
- (void) repeatAtBPM:(UInt64)newBPM;


@end
