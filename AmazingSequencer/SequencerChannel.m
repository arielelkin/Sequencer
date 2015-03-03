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
    mach_timebase_info_data_t _timebaseInfo;
    UInt64 _nanoSecondsPerCycle;
    UInt64 _nanoSecondsPerFrame;
    UInt64 _sampleFrameIndex; // Keeps track of the next frame to read on the sample.
    int _currentBeatIndex; // Keeps track of the current beat playing.
    UInt64 _cycleStartTimeNanoSeconds;
    UInt64 _cycleEndTimeNanoSeconds;
    UInt64 _sampleIsPlaying; // Keeps track if a sample is playing or not.
    double **_beatCArray;
    int _numBeats;
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

    // Dynamically allocate 2-dimensional C array to represent NSMutableArray beats:
    // beatCArray[beats.count][numParametersInBeat]
    // (can't use Obj-c within renderCallback)
    channel->_beats = beats;
    channel->_numBeats = beats.count;
    NSUInteger numParametersInBeat = 2;
    double **beatsCRepresentation = (double**)malloc(channel->_numBeats*sizeof(double*));
    for(int i=0; i < channel->_numBeats; i++) {
        beatsCRepresentation[i] = (double*)malloc(numParametersInBeat*sizeof(double));
    }
    for (int i = 0; i < channel->_numBeats; i++){
        SequencerBeat *beat = beats[i];
        if (![beat isKindOfClass:[SequencerBeat class]]) {
            NSLog(@"Cannot initialize a sequencer channel with beats array that contains objects not of type beat");
            return nil;
        }
        beatsCRepresentation[i][0] = beat.onset;
        beatsCRepresentation[i][1] = beat.velocity;
    }
    channel->_beatCArray = beatsCRepresentation;
    
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
    channel->_currentBeatIndex = -1;
    channel->_cycleStartTimeNanoSeconds = 0;
    channel->_cycleEndTimeNanoSeconds = 0;
    channel->_sampleIsPlaying = false;
    
    // Timing calculations.
    mach_timebase_info(&channel->_timebaseInfo); // Populates _timebaseInfo with data necessary to convert machine clock ticks to nano seconds later on.
    double nanoSecondsPerBeat = 1000000000.0f * 60.0f / bpm;
    channel->_nanoSecondsPerCycle = beatsPerMeasure * nanoSecondsPerBeat;
    channel->_nanoSecondsPerFrame = 1000000000.0f / audioController.audioDescription.mSampleRate;
    
    return channel;
}

static OSStatus renderCallback(__unsafe_unretained SequencerChannel *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 frames,
                               AudioBufferList *audio) {
    

    // Skip if channel is not playing or stopped.
    // TODO - feature
    
    // Keep track of when a cycle starts and ends.
    UInt64 k = THIS->_timebaseInfo.numer / THIS->_timebaseInfo.denom;
    UInt64 currentTimeNanoSeconds = inTimeStamp->mHostTime * k;
    if(THIS->_cycleStartTimeNanoSeconds == 0) {
        THIS->_cycleStartTimeNanoSeconds = currentTimeNanoSeconds;
        THIS->_cycleEndTimeNanoSeconds = THIS->_cycleStartTimeNanoSeconds + THIS->_nanoSecondsPerFrame * frames;
    }
    
    // Evaluate time passed in this cycle.
    // If a cycle has ended, values are shifted so that a new cycle begins.
    UInt64 elapsedTimeSinceCycleStartNanoSeconds = currentTimeNanoSeconds - THIS->_cycleStartTimeNanoSeconds;
    if(elapsedTimeSinceCycleStartNanoSeconds > THIS->_nanoSecondsPerCycle) { // reset?
        elapsedTimeSinceCycleStartNanoSeconds = elapsedTimeSinceCycleStartNanoSeconds % THIS->_nanoSecondsPerCycle;
        THIS->_cycleStartTimeNanoSeconds = currentTimeNanoSeconds - elapsedTimeSinceCycleStartNanoSeconds;
        THIS->_cycleEndTimeNanoSeconds = THIS->_cycleStartTimeNanoSeconds + THIS->_nanoSecondsPerFrame * frames;
        THIS->_currentBeatIndex = -1;
    }
    
    // Quickly evaluate if there will be no audio in this renderCallback() and hence writting to buffers can be skipped entirely.
    // TODO - optimization
    
    // Sweep the audio buffer frames and fill with sample frames when appropriate.
    UInt64 frameTimeNanoSeconds = 0;
    for(int i = 0; i < frames; i++) {
        
        // Check if the coming beat is suposed to have started by now.
        int nextBeatIndex = THIS->_currentBeatIndex + 1 < THIS->_numBeats ? THIS->_currentBeatIndex + 1 : -1;
        if(nextBeatIndex >= 0) {
            double beatTimeNanoSeconds = THIS->_nanoSecondsPerCycle * THIS->_beatCArray[nextBeatIndex][0];
            double delta = elapsedTimeSinceCycleStartNanoSeconds + frameTimeNanoSeconds - beatTimeNanoSeconds;
            if(delta >= 0) {
                THIS->_sampleFrameIndex = 0;
                THIS->_sampleIsPlaying = true;
                THIS->_currentBeatIndex = nextBeatIndex;
            }
        }
        
        // Make some noise?
        if(THIS->_sampleIsPlaying) {
            
            // Writes the same samples on left and right channels.
            if(THIS->_currentBeatIndex >= 0) {
                for(int j = 0; j < audio->mNumberBuffers; j++) {
                    ((float *)audio->mBuffers[j].mData)[i] = THIS->_beatCArray[THIS->_currentBeatIndex][1] * ((float *)THIS->_audioSampleBufferList->mBuffers[j].mData)[THIS->_sampleFrameIndex];
                }
            }
            
            // Advance sample frame.
            THIS->_sampleFrameIndex++;
            if(THIS->_sampleFrameIndex > THIS->_sampleLengthInFrames) {
                THIS->_sampleIsPlaying = false;
            }
        }
        
        // Advance time.
        frameTimeNanoSeconds += THIS->_nanoSecondsPerFrame;
    }
    
    return noErr;
}

-(AEAudioControllerRenderCallback)renderCallback {
    return &renderCallback;
}

@end















