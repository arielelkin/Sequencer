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
#import "MyChannel.h"

#import <mach/mach_time.h>

@import AVFoundation;

@implementation ViewController {

    AEAudioController *audioController;
    AEBlockChannel *blockChannel;
    AEBlockChannel *audioFileChannel;
    MyChannel *myChannel;
    bool shouldPlay;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self setupAudioController];

    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"guitar" withExtension:@"caf"];
    myChannel = [MyChannel repeatingAudioFileAt:fileURL audioController:audioController repeatAtBPM:60];
    [audioController addChannels:@[myChannel]];

}

- (void)setupAudioController {
    //init audio controller:
    audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]];

    NSError *audioControllerStartError = nil;
    [audioController start:&audioControllerStartError];
    if (audioControllerStartError) {
        NSLog(@"Audio controller start error: %@", audioControllerStartError.localizedDescription);
    }
}

- (void)playAudioFile {

    //Load audio file:
    AEAudioFileLoaderOperation *operation = [[AEAudioFileLoaderOperation alloc] initWithFileURL:[[NSBundle mainBundle] URLForResource:@"guitar" withExtension:@"caf"]
                                                                         targetAudioDescription:audioController.audioDescription];
    [operation start];
    if ( operation.error ) {
        NSLog(@"load error: %@", operation.error);
        return;
    }

    AudioBufferList *audioSampleBufferList = operation.bufferList;

    //Play the audio file using an AEBlockChannel:
    audioFileChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {

        static UInt32 playHead;

        if (!shouldPlay) {
            playHead = 0;
            return;
        }

        for (int i=0; i<frames; i++) {

            for ( int j=0; j<audio->mNumberBuffers; j++ ) {

                bool shouldLoop = true;

                if (playHead < operation.lengthInFrames) {
                    ((float *)audio->mBuffers[j].mData)[i] = ((float *)audioSampleBufferList->mBuffers[j].mData)[playHead + i];
                }
                else if (shouldLoop) {
                    playHead = 0;
                }
                else {
                    ((float *)audio->mBuffers[j].mData)[i] = 0;
                }
            }
        }

        playHead += frames;

    }];

    [audioController addChannels:@[audioFileChannel]];
}

- (IBAction)play {
//    shouldPlay = true;
}

- (IBAction)stop {
//    shouldPlay = false;
}


@end
