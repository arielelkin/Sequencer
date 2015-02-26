//
//  SequencerChannel3.m
//  AmazingSequencer
//
//  Created by Alejandro Santander on 26/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import "SequencerChannel3.h"
#import "AEAudioFileLoaderOperation.h"

/*
 NOTES:
 This experiment is as SequencerChannel2, but accepts an array of beats as a pattern instead of a bpm.
 
 [[[ INCOMPLETE ]]]
 
 */
@implementation SequencerChannel3 {
    AudioBufferList *_audioSampleBufferList;
    UInt32 _sampleLengthInFrames;
    NSMutableArray* _beats;
    int _framesPerMeasure;
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
//    int patternLengthInBeats = 4; // hardcoded
//    int sampleRate = audioController.audioDescription.mSampleRate;
//    double beatsPerSecond = (double)bpm / 60.0f;
//    int framesPerBeat = (int)(sampleRate / beatsPerSecond);
//    channel->_framesPerMeasure = patternLengthInBeats * framesPerBeat;
//    NSLog(@"_framesPerMeasure: %d", channel->_framesPerMeasure);
    
    return channel;
}

static OSStatus renderCallback(__unsafe_unretained SequencerChannel3 *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 frames,
                               AudioBufferList *audio) {
    
    int i;
    
    NSLog(@"renderCallback() --------------------");
    
    // Stores the frames elapsed since the last measure started.
//    static UInt64 _measureFrameIndex;
//    if(!_measureFrameIndex) {
//        _measureFrameIndex = 0;
//    }
//    if(_measureFrameIndex > THIS->_framesPerMeasure) {
//        _measureFrameIndex = 0;
//    }
//    NSLog(@"_measureFrameIndex: %llu", _measureFrameIndex);
    
    // Keeps track of the next frame to read on the sample.
//    static UInt64 _sampleFrameIndex;
//    if(!_sampleFrameIndex) {
//        _sampleFrameIndex = 0;
//    }
//    NSLog(@"_sampleFrameIndex: %llu", _sampleFrameIndex);
    
    // Determines when a new sample should be played.
    // Can set _sampleIsPlaying to true, but not to false.
//    static BOOL _sampleIsPlaying;
//    if(!_sampleIsPlaying) {
//        _sampleIsPlaying = NO;
//    }
//    for(i = 0; i < THIS->_beats.count; i++) {
//        Beat *beat = THIS->_beats[i];
//        NSLog(@"beat %d: %f", i, beat.onset);
//        int beatFrames = beat.onset * THIS->_framesPerMeasure;
//        NSLog(@"beat frames: %d", beatFrames);
//        if(beatFrames == _measureFrameIndex) {
//            NSLog(@"BEAT");
//            _sampleIsPlaying = YES;
//            break;
//        }
//    }
    
    // Sweep and fill buffer frames.
//    for( i=0; i<frames; i++ ) {
//        for( int j=0; j<audio->mNumberBuffers; j++ ) {
//            if(_sampleIsPlaying) {
//                // Write sample to buffer.
//                ((float *)audio->mBuffers[j].mData)[i] = ((float *)THIS->_audioSampleBufferList->mBuffers[j].mData)[_sampleFrameIndex];
//                // Advance index and reset if necessary.
//                _sampleFrameIndex++;
//                if(_sampleFrameIndex > THIS->_sampleLengthInFrames) {
//                    _sampleFrameIndex = 0;
//                    _sampleIsPlaying = NO;
//                }
//            }
//            else {
//                // Write silence to buffer.
//                // TODO: is this necessary? The data might be zero already.
//                ((float *)audio->mBuffers[j].mData)[i] = 0;
//            }
//        }
//        _measureFrameIndex++;
//    }
    
    return noErr;
}

-(AEAudioControllerRenderCallback)renderCallback {
    return &renderCallback;
}

@end















