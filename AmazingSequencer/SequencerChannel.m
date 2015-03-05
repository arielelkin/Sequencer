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


@implementation SequencerChannel {
    AudioBufferList *_audioSampleBufferList;
    UInt32 _sampleLengthInFrames;
    mach_timebase_info_data_t _timebaseInfo;
    UInt64 _nanoSecondsPerPattern;
    UInt64 _nanoSecondsPerFrame;
    UInt64 _sampleFrameIndex; // Keeps track of the next frame to read on the sample.
    int _currentBeatIndex; // Keeps track of the current beat playing.
    UInt64 _patternStartTimeNanoSeconds;
    UInt64 _sampleIsPlaying; // Keeps track if a sample is playing or not.
    double **_sequenceCRepresentation;
    int _numBeats;
    SequencerChannelSequence *_sequence;
    bool _sequenceIsPlaying;
}

#pragma mark -
#pragma mark Init

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url
                                audioController:(AEAudioController*)audioController
                                   withSequence:(SequencerChannelSequence*)sequence
                                   numberOfFullBeatsPerMeasure:(NSUInteger)beatsPerMeasure
                                          atBPM:(double)bpm {

    //Sanity checks
    if (!url) {
        NSLog(@"%s Cannot initialize Sequencer Channel if NSURL of audio file is nil.", __PRETTY_FUNCTION__);
        return nil;
    }
    if (beatsPerMeasure <= 0) {
        NSLog(@"%s Cannot initialize Sequencer Channel with zero or less full beats per measure", __PRETTY_FUNCTION__);
        return nil;
    }
    if (bpm <= 0) {
        NSLog(@"%s Cannot initialize Sequencer Channel with BPM <= 0", __PRETTY_FUNCTION__);
        return nil;
    }

    SequencerChannel *channel = [[self alloc] init];


    // Load audio file:
    AEAudioFileLoaderOperation *operation = [[AEAudioFileLoaderOperation alloc] initWithFileURL:url targetAudioDescription:audioController.audioDescription];
    [operation start];
    if ( operation.error ) {
        NSLog(@"load error: %@", operation.error);
        return nil;
    }
    channel->_audioSampleBufferList = operation.bufferList;
    channel->_sampleLengthInFrames = operation.lengthInFrames;


    //Load sequence:
    channel.sequence = sequence;
    channel->_numBeats = sequence.count;
    channel->_sequenceCRepresentation = sequence.sequenceCRepresentation;
    

    // Init consistent variables:
    channel->_sampleFrameIndex = 0;
    channel->_currentBeatIndex = -1;
    channel->_patternStartTimeNanoSeconds = 0;
    channel->_sampleIsPlaying = false;


    // Timing calculations:

    // Populates _timebaseInfo with data necessary to convert
    //machine clock ticks to nano seconds later on:
    mach_timebase_info(&channel->_timebaseInfo);
    double nanoSecondsPerBeat = 1000000000.0f * 60.0f / bpm;
    channel->_nanoSecondsPerPattern = beatsPerMeasure * nanoSecondsPerBeat;
    channel->_nanoSecondsPerFrame = 1000000000.0f / audioController.audioDescription.mSampleRate;


    //Sequence playback control variables:
    channel->_sequenceIsPlaying = true;

    return channel;
}


#pragma mark -
#pragma mark Sequence access

- (void)setSequence:(SequencerChannelSequence *)sequence {
    [self updateCSequence];
    _sequence = sequence;
}

- (SequencerChannelSequence *)sequence {
    [self updateCSequence];
    return _sequence;
}

-(void)updateCSequence {
    _sequenceCRepresentation = [_sequence sequenceCRepresentation];
    _numBeats = _sequence.count;
}


#pragma mark -
#pragma mark Playback control

- (void)setSequenceIsPlaying:(BOOL)sequenceIsPlaying {
    _sequenceIsPlaying = sequenceIsPlaying;
}
- (BOOL)sequenceIsPlaying {
    return _sequenceIsPlaying;
}


#pragma mark -
#pragma mark Render callback

static OSStatus renderCallback(__unsafe_unretained SequencerChannel *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 frames,
                               AudioBufferList *audio) {

    if (!THIS->_sequenceIsPlaying) return noErr;

    // Skip if channel is not playing or stopped.
    // TODO - feature
    
    // Keep track of when a pattern iteration starts and ends.
    UInt64 k = THIS->_timebaseInfo.numer / THIS->_timebaseInfo.denom;
    UInt64 currentTimeNanoSeconds = inTimeStamp->mHostTime * k;
    if(THIS->_patternStartTimeNanoSeconds == 0) {
        THIS->_patternStartTimeNanoSeconds = currentTimeNanoSeconds;
    }
    
    // Evaluate time passed in this pattern iteration.
    // If a pattern iteration has ended, values are shifted so that a new iteration begins.
    UInt64 elapsedTimeSinceCycleStartNanoSeconds = currentTimeNanoSeconds - THIS->_patternStartTimeNanoSeconds;
    if(elapsedTimeSinceCycleStartNanoSeconds > THIS->_nanoSecondsPerPattern) { // reset?
        elapsedTimeSinceCycleStartNanoSeconds = elapsedTimeSinceCycleStartNanoSeconds % THIS->_nanoSecondsPerPattern;
        THIS->_patternStartTimeNanoSeconds = currentTimeNanoSeconds - elapsedTimeSinceCycleStartNanoSeconds;
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
            double beatTimeNanoSeconds = THIS->_nanoSecondsPerPattern * THIS->_sequenceCRepresentation[nextBeatIndex][0];
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
                    ((float *)audio->mBuffers[j].mData)[i] = THIS->_sequenceCRepresentation[THIS->_currentBeatIndex][1] * ((float *)THIS->_audioSampleBufferList->mBuffers[j].mData)[THIS->_sampleFrameIndex];
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















