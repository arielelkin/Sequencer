//
//  SequencerChannel2.m
//  AmazingSequencer
//
//  Created by Alejandro Santander on 26/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import "SequencerChannel2.h"
#import "AEAudioFileLoaderOperation.h"

#import <mach/mach_time.h>

/*
 NOTES:
 This is as SequencerChannel2 but uses clock ticks instead of frames for timing.
 */
@implementation SequencerChannel2 {
    AudioBufferList *_audioSampleBufferList;
    UInt32 _sampleLengthInFrames;
    mach_timebase_info_data_t _timebaseInfo;
    int _sampleRate;
    double _secondsPerBeat;
}

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url audioController:(AEAudioController*)audioController repeatAtBPM:(UInt64)bpm {
    
    SequencerChannel2 *channel = [[self alloc] init];
    
    //Load audio file:
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
    channel->_secondsPerBeat = 60.0f / bpm;
    NSLog(@"_secondsPerBeat: %f", channel->_secondsPerBeat);
    
    return channel;
}

static OSStatus renderCallback(__unsafe_unretained SequencerChannel2 *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 frames,
                               AudioBufferList *audio) {
    
    int i;
    
//    NSLog(@"renderCallback() --------------------");
    
    // Keeps track of the next frame to read on the sample.
    static UInt64 _sampleFrameIndex;
    if(!_sampleFrameIndex) {
        _sampleFrameIndex = 0;
    }
//    NSLog(@"_sampleFrameIndex: %llu", _sampleFrameIndex);
    
    // Keeps track of the last time the sample was played.
    static UInt64 _lastSampleStartTime;
    if(!_lastSampleStartTime) {
        _lastSampleStartTime = inTimeStamp->mHostTime;
    }
    
    // Calculates time elapsed since the last time the sample was started.
    uint64_t elapsedSinceStartTime = inTimeStamp->mHostTime - _lastSampleStartTime;
//    NSLog(@"elapsedSinceStartTime: %llu", elapsedSinceStartTime);
    double elapsedSinceStartTimeNanoSeconds = elapsedSinceStartTime * (THIS->_timebaseInfo.numer / THIS->_timebaseInfo.denom);
//    NSLog(@"elapsedSinceStartTimeNanoSeconds: %f", elapsedSinceStartTimeNanoSeconds);
    double elapsedSinceStartTimeSeconds = elapsedSinceStartTimeNanoSeconds / 1000000000.0;
//    NSLog(@"elapsedSinceStartTimeSeconds: %f", elapsedSinceStartTimeSeconds);
    
    // Trigger sound according to elapsed time.
    // Can set _sampleIsPlaying to true, but not to false.
    static BOOL _sampleIsPlaying;
    if(!_sampleIsPlaying) {
        _sampleIsPlaying = NO;
    }
    if(elapsedSinceStartTimeSeconds >= THIS->_secondsPerBeat) {
//        NSLog(@"BEAT");
        _sampleIsPlaying = YES;
        _sampleFrameIndex = 0;
        _lastSampleStartTime = inTimeStamp->mHostTime;
    }

    // Sweep and fill buffer frames.
    for( i=0; i<frames; i++ ) {
        for( int j=0; j<audio->mNumberBuffers; j++ ) {
            if(_sampleIsPlaying) {
                // Write sample to buffer.
                // TODO: WARNING: This could cause an error if the sample can't fill the buffer?
                ((float *)audio->mBuffers[j].mData)[i] = ((float *)THIS->_audioSampleBufferList->mBuffers[j].mData)[_sampleFrameIndex];
                // Advance index and reset if necessary.
                _sampleFrameIndex++;
                if(_sampleFrameIndex > THIS->_sampleLengthInFrames) {
                    _sampleFrameIndex = 0;
                    _sampleIsPlaying = NO;
                }
            }
            else {
                // Write silence to buffer.
                // TODO: is this necessary? The data might be zero already.
                ((float *)audio->mBuffers[j].mData)[i] = 0;
            }
        }
    }
    
    return noErr;
}

-(AEAudioControllerRenderCallback)renderCallback {
    return &renderCallback;
}

@end


















