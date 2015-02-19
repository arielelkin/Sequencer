//
//  ViewController.m
//  AmazingSequencer
//
//  Created by Ariel Elkin on 01/04/2014.
//  Copyright (c) 2014 Ariel Elkin. All rights reserved.
//

#import "ViewController.h"

#import "AEAudioController.h"
#import "SequencerChannel.h"


@import AVFoundation;

@implementation ViewController {

    AEAudioController *audioController;

    SequencerChannel *woodblockChannel;
    SequencerChannel *crickChannel;

}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self setupAudioController];

    [self setupSequencer];
}

- (void)setupSequencer {
    NSURL *woodblockURL = [[NSBundle mainBundle] URLForResource:@"woodblock" withExtension:@"caf"];
    woodblockChannel = [SequencerChannel sequencerChannelWithAudioFileAt:woodblockURL audioController:audioController repeatAtBPM:60];
    [audioController addChannels:@[woodblockChannel]];

//    NSURL *crickURL = [[NSBundle mainBundle] URLForResource:@"hihat" withExtension:@"caf"];
//    crickChannel = [SequencerChannel sequencerChannelWithAudioFileAt:crickURL audioController:audioController repeatAtBPM:120];
//    [audioController addChannels:@[crickChannel]];
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

@end
