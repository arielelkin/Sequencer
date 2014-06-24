//
//  ViewController.m
//  AmazingSequencer
//
//  Created by Ariel Elkin on 01/04/2014.
//  Copyright (c) 2014 Ariel Elkin. All rights reserved.
//

#import "ViewController.h"

#import "AEAudioController.h"
#import "AEBlockChannel.h"
#import "AEAudioFilePlayer.h"

#import <mach/mach_time.h>

@import AVFoundation;

@implementation ViewController {

    AEAudioController *audioController;
    AEBlockChannel *blockChannel;
    AEAudioFilePlayer *audioFilePlayer;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startSequencer];
}

- (void)startSequencer {

    //init audio controller:
    audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]];

    NSError *audioControllerStartError = nil;
    [audioController start:&audioControllerStartError];
    if (audioControllerStartError) {
        NSLog(@"Audio controller start error: %@", audioControllerStartError.localizedDescription);
    }

    //Setup time variables for TECHNIQUE 1:
    const uint64_t kSampleRate = (uint64_t)audioController.audioDescription.mSampleRate;
    static double __secondsPerHostTick = 0.0;
    static double __hostTicksPerSecond = 0.0;
    static double __hostTicksPerFrame = 0.0;

    static UInt64 _playbackStartTime;

    mach_timebase_info_data_t tinfo;
    mach_timebase_info(&tinfo);

    __secondsPerHostTick = ((double)tinfo.numer / tinfo.denom) * 1.0e-9;
    __hostTicksPerSecond = 1.0 / __secondsPerHostTick;
    __hostTicksPerFrame = __hostTicksPerSecond / kSampleRate;

    blockChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *inTimeStamp, UInt32 frames, AudioBufferList *audio) {


        //TECHNIQUE 1
        //USE MACH TIMEBASE:

        if ( !_playbackStartTime ) {
            _playbackStartTime = inTimeStamp->mHostTime;
        }
        uint64_t bufferStartPlaybackPosition = inTimeStamp->mHostTime - _playbackStartTime;
        uint64_t bufferEndPlaybackPosition = bufferStartPlaybackPosition + (frames * __hostTicksPerFrame);

        if ( bufferEndPlaybackPosition % (uint64_t)__hostTicksPerSecond < bufferStartPlaybackPosition % (uint64_t)__hostTicksPerSecond ) {
            // We have crossed a second boundary in this buffer

            int framesToBoundary = (__hostTicksPerSecond - (bufferStartPlaybackPosition % (uint64_t)__hostTicksPerSecond)) / __hostTicksPerFrame;

            for ( int i=0; i<framesToBoundary; i++ ) {
                ((float*)audio->mBuffers[0].mData)[i] =
                ((float*)audio->mBuffers[1].mData)[i] = 0.2; //just some noise
            }
        }

        //comment out this return statement to try TECHNIQUE 2:
        return;



        //TECHNIQUE 2
        //COUNT SAMPLES:

        for ( int i=0; i<frames; i++ ) {

            static uint64_t numSamples;
            numSamples++;

            if (numSamples % kSampleRate == 0) {
                //1 second
            }

            if (numSamples % (kSampleRate/2) == 0) {
                // 1/2 seconds
                ((float*)audio->mBuffers[0].mData)[i] =
                ((float*)audio->mBuffers[1].mData)[i] = 0.1;
            }

            if (numSamples % (kSampleRate) == 0) {
                // 1/3 seconds
                ((float*)audio->mBuffers[0].mData)[i] =
                ((float*)audio->mBuffers[1].mData)[i] = 0.3;
            }

        }

    }];

    [audioController addChannels:@[blockChannel]];



    //Work in progress: Sequencing audio files

    NSError *audioFilePlayerErorr;
    audioFilePlayer = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:@"guitar" withExtension:@"caf"]
                                                audioController:audioController
                                                          error:&audioFilePlayerErorr];
    [audioFilePlayer setChannelIsPlaying:NO];
    [audioController addChannels:@[audioFilePlayer]];

}

- (IBAction)play {
    [audioFilePlayer setChannelIsPlaying:YES];
}

- (IBAction)stop {
    [audioFilePlayer setCurrentTime:0];
    [audioFilePlayer setChannelIsPlaying:NO];
}


@end
