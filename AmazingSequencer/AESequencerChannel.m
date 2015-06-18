//
//  AESequencerChannel.m
//  The Amazing Audio Engine
//
//  Created by Alejandro Santander on 26/02/2015.
//

#import "AESequencerChannel.h"
#import "AEAudioFileLoaderOperation.h"

#import <mach/mach_time.h>

@interface AESequencerChannel()
@property float playheadPosition;
@end

@implementation AESequencerChannel {
    AEAudioController *_audioController;
    AudioBufferList *_audioSampleBufferList;
    UInt32 _sampleLengthInFrames;
    mach_timebase_info_data_t _timebaseInfo;
    UInt64 _nanoSecondsPerSequence;
    UInt64 _nanoSecondsPerFrame;
    UInt64 _sampleFrameIndex; // Keeps track of the next frame to read on the sample.
    int _currentBeatIndex; // Keeps track of the current beat playing.
    UInt64 _sequenceStartTimeNanoSeconds;
    UInt64 _currentTimeNanoSeconds;
    UInt64 _elapsedTimeSinceSequenceStartNanoSeconds;
    bool _sampleIsPlaying; // Keeps track if a sample is playing or not.
    BEAT *_sequenceCRepresentation;
    unsigned long _numBeats;
    AESequencerChannelSequence *_sequence;
    bool _sequenceIsPlaying;
    double _bpm;
    NSUInteger _beatsPerMeasure;
    float _playheadPosition;
    unsigned int _numSampleBuffers;
    bool _pendingTimingReset;
    NSURL *_url;
}

@synthesize pan = _pan, volume = _volume, muted = _muted, soloed = _soloed;

#pragma mark -
#pragma mark Init

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url
                                audioController:(AEAudioController*)audioController
                                   withSequence:(AESequencerChannelSequence*)sequence
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

    AESequencerChannel *channel = [[self alloc] init];
    channel->_url = url;
    channel->_audioController = audioController;
    channel->_pan = 0.0f;
    channel->_volume = 1.0f;
    channel->_soloed = 0;
    channel->_muted = false;
    channel->_pendingTimingReset = false;

    // Load audio file:
    AEAudioFileLoaderOperation *operation = [[AEAudioFileLoaderOperation alloc] initWithFileURL:url targetAudioDescription:audioController.audioDescription];
    [operation start];
    if ( operation.error ) {
        NSLog(@"%s Cannot load audio file: error: %@", __PRETTY_FUNCTION__, operation.error);
        return nil;
    }
    channel->_audioSampleBufferList = operation.bufferList;
    channel->_sampleLengthInFrames = operation.lengthInFrames;
    channel->_numSampleBuffers = (unsigned int)operation.bufferList->mNumberBuffers;
    //NSLog(@"Number of buffers in sample: %d", (unsigned int)operation.bufferList->mNumberBuffers);

    //Load sequence:
    channel.sequence = sequence;
    channel->_numBeats = sequence.count;
    channel->_sequenceCRepresentation = sequence.sequenceCRepresentation;

    // Init consistent variables:
    channel->_sampleFrameIndex = 0;
    channel->_currentBeatIndex = -1;
    channel->_sequenceStartTimeNanoSeconds = 0;
    channel->_currentTimeNanoSeconds = 0;
    channel->_elapsedTimeSinceSequenceStartNanoSeconds = 0;
    channel->_sampleIsPlaying = false;

    // Timing calculations:
    // Populates _timebaseInfo with data necessary to convert
    // machine clock ticks to nano seconds later on:
    mach_timebase_info(&channel->_timebaseInfo);
    channel->_beatsPerMeasure = beatsPerMeasure;
    channel->_bpm = bpm;
    [channel updateBpm];

    //Sequence playback control variables:
    channel->_sequenceIsPlaying = false;

    return channel;
}

#pragma mark -
#pragma mark Sequence access

- (void)setSequence:(AESequencerChannelSequence *)sequence {
//    NSLog(@"setSequence() - sequence: %@", _sequence);
    _sequence = sequence;
    [self updateCSequence];
}

- (AESequencerChannelSequence *)sequence {
    [self updateCSequence];
    return _sequence;
}

-(void)updateCSequence {

//    NSLog(@"updateCSequence()");
    
    // If the sequence's lenght change, update the beat index.
    if(_sequence.count > _numBeats) {
        _currentBeatIndex++;
    }
    else if(_sequence.count < _numBeats) {
        if(_currentBeatIndex > 0) {
            _currentBeatIndex--;
        }
    }

    _sequenceCRepresentation = [_sequence sequenceCRepresentation];
    _numBeats = _sequence.count;
}

#pragma mark -
#pragma mark Playback control

- (void)setSequenceIsPlaying:(bool)sequenceIsPlaying {
    
    // Reset all timing values.
    // If stopped, let the sounds ring.
    if(!sequenceIsPlaying) {
        _pendingTimingReset = true;
        _playheadPosition = 0;
    }
    // If starting to play, reset now.
    else {
        _playheadPosition = 0;
        _currentBeatIndex = -1;
        _sequenceStartTimeNanoSeconds = 0;
        _sampleFrameIndex = 0;
        _sampleIsPlaying = false;
        _pendingTimingReset = false;
    }
    _sequenceIsPlaying = sequenceIsPlaying;
}
- (bool)sequenceIsPlaying {
    return _sequenceIsPlaying;
}

#pragma mark -
#pragma mark BPM control

- (void)setBpm:(double)bpm {
    
    float changeFactor = _bpm / bpm;
    
    _bpm = bpm;
    [self updateBpm];
    
    // Correct time.
    _sequenceStartTimeNanoSeconds -= _elapsedTimeSinceSequenceStartNanoSeconds * changeFactor - _elapsedTimeSinceSequenceStartNanoSeconds;
}

- (double)bpm {
    return _bpm;
}

- (void)updateBpm {
    double nanoSecondsPerBeat = 1000000000.0f * 60.0f / _bpm;
    _nanoSecondsPerSequence = _beatsPerMeasure * nanoSecondsPerBeat;
    _nanoSecondsPerFrame = 1000000000.0f / _audioController.audioDescription.mSampleRate;
}

#pragma mark -
#pragma mark Playhead

- (float)playheadPosition {
    return _playheadPosition;
}

#pragma mark -
#pragma mark Render callback

static OSStatus renderCallback(__unsafe_unretained AESequencerChannel *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 frames,
                               AudioBufferList *audio) {

//    NSLog(@"renderCallback()");
//    NSLog(@"  numBeats: %lu", THIS->_numBeats);
    
    // Skip if channel is not playing or stopped.
    // Note that it will continue playing until the current sample finished playing.
    if (!THIS->_sequenceIsPlaying && !THIS->_sampleIsPlaying) return noErr;
    if (THIS->_numBeats == 0) return noErr;
    
    // Keep track of when a sequence iteration starts and ends.
    UInt64 k = THIS->_timebaseInfo.numer / THIS->_timebaseInfo.denom;
    THIS->_currentTimeNanoSeconds = inTimeStamp->mHostTime * k;
    if(THIS->_sequenceStartTimeNanoSeconds == 0) {
        THIS->_sequenceStartTimeNanoSeconds = THIS->_currentTimeNanoSeconds;
        THIS->_currentBeatIndex = -1;
    }
    
    // Quickly evaluate if there will be no audio in this renderCallback() and hence writting to buffers can be skipped entirely
    // todo
    
    // Update playhead tacking.
    THIS->_elapsedTimeSinceSequenceStartNanoSeconds = THIS->_currentTimeNanoSeconds - THIS->_sequenceStartTimeNanoSeconds;
    THIS->_playheadPosition = (float)THIS->_elapsedTimeSinceSequenceStartNanoSeconds / (float)THIS->_nanoSecondsPerSequence;
    
    // Sweep the audio buffer frames and fill with sample frames when appropriate.
    UInt64 frameTimeNanoSeconds = 0;
    int buff = 0;
    for(int i = 0; i < frames; i++) {
        
        // Evaluate time passed in this sequence iteration.
        // If a sequence iteration has ended, values are shifted so that a new iteration begins.
        THIS->_elapsedTimeSinceSequenceStartNanoSeconds = THIS->_currentTimeNanoSeconds + frameTimeNanoSeconds - THIS->_sequenceStartTimeNanoSeconds;
        if(THIS->_elapsedTimeSinceSequenceStartNanoSeconds > THIS->_nanoSecondsPerSequence) { // reset?
            THIS->_elapsedTimeSinceSequenceStartNanoSeconds = THIS->_elapsedTimeSinceSequenceStartNanoSeconds % THIS->_nanoSecondsPerSequence;
            THIS->_sequenceStartTimeNanoSeconds = THIS->_currentTimeNanoSeconds - THIS->_elapsedTimeSinceSequenceStartNanoSeconds;
            THIS->_currentBeatIndex = -1;
//            NSLog(@"------ LOOP restart ------");
        }
        
        // Check if the coming beat is suposed to have started by now.
        if(THIS->_sequenceIsPlaying) {
            int nextBeatIndex = THIS->_currentBeatIndex + 1 < THIS->_numBeats ? THIS->_currentBeatIndex + 1 : -1;
            if(nextBeatIndex >= 0) {
                BEAT beat = THIS->_sequenceCRepresentation[nextBeatIndex];
                double beatTimeNanoSeconds = THIS->_nanoSecondsPerSequence * beat.onset;
                double delta = THIS->_elapsedTimeSinceSequenceStartNanoSeconds - beatTimeNanoSeconds;
                if(delta >= 0) {
                    THIS->_sampleFrameIndex = 0;
                    THIS->_sampleIsPlaying = true;
                    THIS->_currentBeatIndex = nextBeatIndex;
//                    NSLog(@"sample start: %d of %lu", THIS->_currentBeatIndex, THIS->_numBeats - 1);
//                    NSLog(@"delta: %f", delta);
                }
            }
        }
        
        // Make some noise?
        if(THIS->_sampleIsPlaying) {
            
            // Writes the same samples on left and right channels.
            bool write = true;
            if(THIS->_soloed == -1) write = false; // don't write if some other channel is soloed
            if(THIS->_muted && THIS->_soloed != 1) write = false; // don't write if this channel is muted and is not soloed
            if(THIS->_currentBeatIndex >= 0) {
                BEAT beat = THIS->_sequenceCRepresentation[THIS->_currentBeatIndex];
                if(write) {
                    for(int j = 0; j < audio->mNumberBuffers; j++) {
                        
                        // Makes sure that the audio will not request buffers that the sample doesn't have.
                        // i.e. if the sample is mono and audio is stereo, writes the same thing on both channels.
                        buff = j < THIS->_numSampleBuffers ? j : buff;
                        ((float *)audio->mBuffers[j].mData)[i] = beat.velocity * ((float *)THIS->_audioSampleBufferList->mBuffers[j].mData)[THIS->_sampleFrameIndex];
                    }
                }
            }
            
            // Advance sample frame.
            THIS->_sampleFrameIndex++;
            if(THIS->_sampleFrameIndex > THIS->_sampleLengthInFrames) {
                THIS->_sampleIsPlaying = false;
                if(THIS->_pendingTimingReset) {
                    // Reset.
                    THIS->_currentBeatIndex = -1;
                    THIS->_sequenceStartTimeNanoSeconds = 0;
                    THIS->_sampleFrameIndex = 0;
                    THIS->_pendingTimingReset = false;
                    THIS->_playheadPosition = 0;
                }
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
