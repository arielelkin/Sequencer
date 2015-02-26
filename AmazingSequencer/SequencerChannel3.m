//
//  SequencerChannel3.m
//  AmazingSequencer
//
//  Created by Alejandro Santander on 26/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import "SequencerChannel3.h"
#import "AEAudioFileLoaderOperation.h"

#import <mach/mach_time.h>

/*
 NOTES:
 This experiment accepts an array of beats as a pattern instead of a bpm.
 It uses tick logic as developed in SequenceChannel2.
 
 */
@implementation SequencerChannel3 {
    AudioBufferList *_audioSampleBufferList;
    UInt32 _sampleLengthInFrames;
    NSMutableArray* _beats;
    int _sampleRate;
    mach_timebase_info_data_t _timebaseInfo;
    double _secondsPerMeasure;
    UInt64 _sampleFrameIndex;
    UInt64 _lastMeasureStartTime;
    int _lastPlayedBeatIndex;
    BOOL _sampleIsPlaying;
}

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url
                                audioController:(AEAudioController*)audioController
                                    withPattern:(NSMutableArray*)beats // of Beat
                                          atBPM:(UInt64)bpm {
    
    SequencerChannel3 *channel = [[self alloc] init];
    
    channel->_beats = beats;
    
    // Load audio file.
    AEAudioFileLoaderOperation *operation = [[AEAudioFileLoaderOperation alloc] initWithFileURL:url targetAudioDescription:audioController.audioDescription];
    [operation start];
    if ( operation.error ) {
        NSLog(@"load error: %@", operation.error);
        return nil;
    }
    channel->_audioSampleBufferList = operation.bufferList;
    channel->_sampleLengthInFrames = operation.lengthInFrames;
    NSLog(@"sample length in frames: %d", (unsigned int)operation.lengthInFrames);
    
    // Timing calculations.
    channel->_sampleRate = audioController.audioDescription.mSampleRate;
    mach_timebase_info(&channel->_timebaseInfo);
    double secondsPerBeat = 60.0f / bpm;
    channel->_secondsPerMeasure = 4 * secondsPerBeat; // hardcoded - assumes there are 4 beats in 1 measure
    
    return channel;
}

static OSStatus renderCallback(__unsafe_unretained SequencerChannel3 *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 frames,
                               AudioBufferList *audio) {
    
    int i;
    Beat *beat;
    
    if(!THIS->_lastPlayedBeatIndex) {
        THIS->_lastPlayedBeatIndex = 0;
    }
    
//    NSLog(@"renderCallback() --------------------");
    
    // Keeps track of the next frame to read on the sample.
    if(!THIS->_sampleFrameIndex) {
        THIS->_sampleFrameIndex = 0;
    }
    
    // Keeps track of the last time the measure started.
    if(!THIS->_lastMeasureStartTime) {
        THIS->_lastMeasureStartTime = inTimeStamp->mHostTime;
    }
    
    // Calculates time elapsed since the last time the measure started.
    uint64_t elapsedSinceStartTime = inTimeStamp->mHostTime - THIS->_lastMeasureStartTime;
    //    NSLog(@"elapsedSinceStartTime: %llu", elapsedSinceStartTime);
    double elapsedSinceStartTimeNanoSeconds = elapsedSinceStartTime * (THIS->_timebaseInfo.numer / THIS->_timebaseInfo.denom);
    //    NSLog(@"elapsedSinceStartTimeNanoSeconds: %f", elapsedSinceStartTimeNanoSeconds);
    double elapsedSinceStartTimeSeconds = elapsedSinceStartTimeNanoSeconds / 1000000000;
//    NSLog(@"elapsedSinceStartTimeSeconds: %f", elapsedSinceStartTimeSeconds);
    if(elapsedSinceStartTimeSeconds > THIS->_secondsPerMeasure) {
        THIS->_lastMeasureStartTime = inTimeStamp->mHostTime;
        THIS->_lastPlayedBeatIndex = 0;
    }
    
    // Determine if a new sample should be triggered.
    // Can set _sampleIsPlaying to true, but not to false.
    if(!THIS->_sampleIsPlaying) {
        THIS->_sampleIsPlaying = NO;
    }
    int numBeats = THIS->_beats.count;
    for(i = THIS->_lastPlayedBeatIndex; i < numBeats; i++) {
        beat = THIS->_beats[i];
        double beatTime = THIS->_secondsPerMeasure * beat.onset;
//        NSLog(@"beat %d: %f", i, beatTime);
        double delta = elapsedSinceStartTimeSeconds - beatTime;
//        NSLog(@"delta: %f", delta);
        if(delta > 0) {
            NSLog(@"BEAT %d", THIS->_lastPlayedBeatIndex);
            THIS->_sampleIsPlaying = YES;
            THIS->_sampleFrameIndex = 0;
            THIS->_lastPlayedBeatIndex++;
            i = 999; // break
        }
        else {
            i = 999; // break
        }
    }
    
    // Sweep and fill buffer frames.
    for( i=0; i<frames; i++ ) {
        for( int j=0; j<audio->mNumberBuffers; j++ ) {
            if(THIS->_sampleIsPlaying) {
                // Write sample to buffer.
                // TODO: WARNING: This could cause an error if the sample can't fill the buffer?
//                float vel = beat.velocity; // NOT USED - for some strange reason, I cannot just multiply this by the value, produces
                // weird audio results
                ((float *)audio->mBuffers[j].mData)[i] = ((float *)THIS->_audioSampleBufferList->mBuffers[j].mData)[THIS->_sampleFrameIndex];
                // Advance index and reset if necessary.
                THIS->_sampleFrameIndex++;
                if(THIS->_sampleFrameIndex > THIS->_sampleLengthInFrames) {
                    THIS->_sampleIsPlaying = NO;
//                    NSLog(@"_sampleFrameIndex %llu", _sampleFrameIndex);
                    THIS->_sampleFrameIndex = 0;
                }
            }
//            else {
//                // Write silence to buffer.
//                // TODO: is this necessary? The data might be zero already.
//                ((float *)audio->mBuffers[j].mData)[i] = 0;
//            }
        }
    }
    
    return noErr;
}

-(AEAudioControllerRenderCallback)renderCallback {
    return &renderCallback;
}

@end















