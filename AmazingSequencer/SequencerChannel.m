//
//  SequencerChannel3.m
//  AmazingSequencer
//
//  Created by Alejandro Santander on 26/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import "SequencerChannel.h"
#import "AEAudioFileLoaderOperation.h"

#import <mach/mach_time.h>

/*
 NOTES:
 This experiment accepts an array of beats as a pattern instead of a bpm.
 It uses tick logic as developed in SequenceChannel2.
 
 */
@implementation SequencerChannel {
    AudioBufferList *_audioSampleBufferList;
    UInt32 _sampleLengthInFrames;
    NSMutableArray* _beats;
    int _sampleRate;
    mach_timebase_info_data_t _timebaseInfo;
    // TODO: cant have objc calls in renderCallback()
    SequencerBeat *_activeBeat;
    double _secondsPerMeasure;
    UInt64 _sampleFrameIndex; // Keeps track of the next frame to read on the sample.
    UInt64 _lastPlayedBeatIndex; // Keeps track of the last time a measure/pattern started.
    UInt64 _lastMeasureStartTime; // Keeps track of the next pattern beat to play.
    UInt64 _sampleIsPlaying; // Keeps track if a sample is playing or not.
    double **beatCArray;
    NSUInteger numBeats;
}

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url
                                audioController:(AEAudioController*)audioController
                                    withPattern:(NSMutableArray*)beats // of Beat
                                          atBPM:(double)bpm {
    
    return [self sequencerChannelWithAudioFileAt:url
                                 audioController:audioController withPattern:beats
                                    withDuration:4
                                           atBPM:bpm];
}

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url
                                audioController:(AEAudioController*)audioController
                                    withPattern:(NSMutableArray*)beats // of Beat
                                   withDuration:(NSUInteger)beatsPerMeasure
                                          atBPM:(double)bpm {
    
    SequencerChannel *channel = [[self alloc] init];
    
    channel->_beats = beats;

    channel->numBeats = beats.count;
    NSUInteger numParametersInBeat = 2;


    //Dynamically allocate 2-dimensional C array to represent NSMutableArray beats:
    //beatCArray[beats.count][numParametersInBeat]
    double **beatsCRepresentation = (double**)malloc(channel->numBeats*sizeof(double*));

    for(int i=0; i < channel->numBeats; i++) {
        beatsCRepresentation[i] = (double*)malloc(numParametersInBeat*sizeof(double));
    }

    for (int i = 0; i < channel->numBeats; i++){
        SequencerBeat *beat = beats[i];

        if (![beat isKindOfClass:[SequencerBeat class]]) {
            NSLog(@"Cannot initialize a sequencer channel with beats array that contains objects not of type beat");
            return nil;
        }
        beatsCRepresentation[i][0] = beat.onset;
        beatsCRepresentation[i][1] = beat.velocity;
    }

    channel->beatCArray = beatsCRepresentation;
    
    // Load audio file.
    AEAudioFileLoaderOperation *operation = [[AEAudioFileLoaderOperation alloc] initWithFileURL:url targetAudioDescription:audioController.audioDescription];
    [operation start];
    if ( operation.error ) {
        NSLog(@"load error: %@", operation.error);
        return nil;
    }
    channel->_audioSampleBufferList = operation.bufferList;
    channel->_sampleLengthInFrames = operation.lengthInFrames;
    
    // Init consistent vars.
    channel->_sampleFrameIndex = 0;
    channel->_lastPlayedBeatIndex = 0;
    channel->_lastMeasureStartTime = 0;
    channel->_sampleIsPlaying = NO;
    
    // Translate NSMutableArray of Beats to c arrays.
    // (used in renderCallback, which cant have Obj-c code)
    // TODO: cant have objc calls in renderCallback()
    
    // Timing calculations.
    channel->_sampleRate = audioController.audioDescription.mSampleRate;
    mach_timebase_info(&channel->_timebaseInfo);
    double secondsPerBeat = 60.0f / bpm;
    channel->_secondsPerMeasure = beatsPerMeasure * secondsPerBeat; // hardcoded - assumes there are 4 beats in 1 measure
    
    return channel;
}

static OSStatus renderCallback(__unsafe_unretained SequencerChannel *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 frames,
                               AudioBufferList *audio) {
    
    // Calculates the time elapsed since the last time a measure/pattern started.
    if(THIS->_lastMeasureStartTime == 0) THIS->_lastMeasureStartTime = inTimeStamp->mHostTime;
    uint64_t elapsedSinceStartTime = inTimeStamp->mHostTime - THIS->_lastMeasureStartTime;
    // TODO: does _timebaseInfo.numer count as an objc call?
    // TODO: do we have a way to throughly test if we are doing NONOes here? i.e. a warning that says "hey you're using objc here!"?
    double elapsedSinceStartTimeNanoSeconds = elapsedSinceStartTime * (THIS->_timebaseInfo.numer / THIS->_timebaseInfo.denom);
    double elapsedSinceStartTimeSeconds = elapsedSinceStartTimeNanoSeconds / 1000000000;
    if(elapsedSinceStartTimeSeconds > THIS->_secondsPerMeasure) { // reset?
        THIS->_lastMeasureStartTime = inTimeStamp->mHostTime;
        THIS->_lastPlayedBeatIndex = 0;
        return noErr;
    }
    
    // Determine if a new sample should be triggered.
    // This set _sampleIsPlaying to true, but not to false.
    if(THIS->_lastPlayedBeatIndex < THIS->numBeats) {
        THIS->_activeBeat = THIS->_beats[(int)THIS->_lastPlayedBeatIndex];
        double beatTime = THIS->_secondsPerMeasure * THIS->_activeBeat.onset;
        double delta = elapsedSinceStartTimeSeconds - beatTime;
        if(delta > 0) { // A beat cannot be missed by combining this with _lastPlayedBeatIndex
            THIS->_sampleIsPlaying = YES;
            THIS->_sampleFrameIndex = 0;
            THIS->_lastPlayedBeatIndex++;
        }
    }
    
    // Can skip writing? (buffer already has zeroes)
    if(THIS->_sampleIsPlaying == NO) return noErr;
    
    // Sweep the audio buffer frames and fill with sample frames if appropriate.
    for(int i = 0; i < frames; i++) {
        
        // Writes the same samples on left and right channels.
        for(int j = 0; j < audio->mNumberBuffers; j++) {
            // TODO: cant have objc calls in renderCallback()
            ((float *)audio->mBuffers[j].mData)[i] = THIS->_activeBeat.velocity * ((float *)THIS->_audioSampleBufferList->mBuffers[j].mData)[THIS->_sampleFrameIndex];
        }
        
        // Advance sample frame.
        THIS->_sampleFrameIndex++;
        if(THIS->_sampleFrameIndex > THIS->_sampleLengthInFrames) {
            THIS->_sampleIsPlaying = NO;
            break;
        }
    }
    
    return noErr;
}

-(AEAudioControllerRenderCallback)renderCallback {
    return &renderCallback;
}

@end















