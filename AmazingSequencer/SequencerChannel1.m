//
//  SequencerChannel1.m
//  AmazingSequencer
//
//  Created by Alejandro Santander on 26/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import "SequencerChannel1.h"
#import "AEAudioFileLoaderOperation.h"

static double __framesPerBeat = 0.0;
static uint64_t kSampleRate;

/*
 NOTES:
 
 This is an initial experiment by Li, in which a sound can be reproduced at any BPM, without clipping.
 Frames are used instead of clock ticks. Appears accurate tho.
 
 Measuring time using frames is easy but could produce timing errors if there is any sort of lag. If so,
 time could pass without the audio card requiring audio frames, and hence timing data could accumulate error
 and innacuracies.
 */
@implementation SequencerChannel1 {
    AudioBufferList *audioSampleBufferList;
    UInt32 lengthInFrames;
}

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url audioController:(AEAudioController*)audioController repeatAtBPM:(UInt64)bpm {
    
    SequencerChannel1 *channel = [[self alloc] init];
    
    //Load audio file:
    AEAudioFileLoaderOperation *operation = [[AEAudioFileLoaderOperation alloc] initWithFileURL:url targetAudioDescription:audioController.audioDescription];
    [operation start];
    if ( operation.error ) {
        NSLog(@"load error: %@", operation.error);
        return nil;
    }
    channel->audioSampleBufferList = operation.bufferList;
    channel->lengthInFrames = operation.lengthInFrames;
    NSLog(@"sample length in frames: %d", (unsigned int)operation.lengthInFrames);
    
    kSampleRate = (uint64_t)audioController.audioDescription.mSampleRate;
    
    // Timing calculations.
    double beatsPerSecond = (double)bpm / 60.0f;
    __framesPerBeat = (UInt32)(kSampleRate / beatsPerSecond);
    NSLog(@"_framesPerBeat: %f", __framesPerBeat);
    
    return channel;
}

static OSStatus renderCallback(__unsafe_unretained SequencerChannel1 *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 frames,
                               AudioBufferList *audio) {
    
    int i;
    
    NSLog(@"renderCallback() --------------------");
    
    // Stores the frames elapsed since last beat.
    static UInt64 _beatFrameIndex;
    if(!_beatFrameIndex) {
        _beatFrameIndex = 0;
    }
    else if(_beatFrameIndex > __framesPerBeat) {
        _beatFrameIndex = 0;
    }
    NSLog(@"_beatFrameIndex: %llu", _beatFrameIndex);
    
    // Keeps track of the next frame to read on the sample.
    static UInt64 _sampleFrameIndex;
    if(!_sampleFrameIndex) {
        _sampleFrameIndex = 0;
    }
    NSLog(@"_sampleFrameIndex: %llu", _sampleFrameIndex);
    
    // Determines when a new sample should be played.
    // Can set _sampleIsPlaying to true, but not to false.
    static BOOL _sampleIsPlaying;
    if(!_sampleIsPlaying) {
        _sampleIsPlaying = NO;
    }
    if(_beatFrameIndex == 0) {
        _sampleIsPlaying = YES;
    }
    
    // Sweep and fill buffer frames.
    for( i=0; i<frames; i++ ) {
        for( int j=0; j<audio->mNumberBuffers; j++ ) {
            if(_sampleIsPlaying) {
                // Write sample to buffer.
                // TODO: WARNING: This could cause an error if the sample can't fill the buffer?
                ((float *)audio->mBuffers[j].mData)[i] = ((float *)THIS->audioSampleBufferList->mBuffers[j].mData)[_sampleFrameIndex];
                // Advance index and reset if necessary.
                _sampleFrameIndex++;
                if(_sampleFrameIndex > THIS->lengthInFrames) {
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
        _beatFrameIndex++;
    }
    
    return noErr;
}

-(AEAudioControllerRenderCallback)renderCallback {
    return &renderCallback;
}

@end
