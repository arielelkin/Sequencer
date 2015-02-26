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
#import "SequencerChannel1.h"
#import "SequencerChannel2.h"
#import "SequencerChannel3.h"
#import "TimedChannel.h"
#import "Beat.h"

@import AVFoundation;

@implementation ViewController {

    AEAudioController *audioController;

    SequencerChannel *woodblockChannel;
    SequencerChannel *crickChannel;

    TimedChannel *timedChannel;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self setupAudioController];

    [self setupSequencer];

//    [self setupTimedChannel];
}

- (void)setupSequencer {
    
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"woodblock" withExtension:@"caf"];
    NSURL *sampleURL1 = [[NSBundle mainBundle] URLForResource:@"hihat" withExtension:@"caf"];
    NSURL *sampleURL2 = [[NSBundle mainBundle] URLForResource:@"crick" withExtension:@"caf"];
    
    /* PICK ONE, COMMENT THE REST */
    
    // SequencerChannel Test
    // Original test by Ariel.
//    woodblockChannel = [SequencerChannel sequencerChannelWithAudioFileAt:sampleURL audioController:audioController repeatAtBPM:120];
//    [audioController addChannels:@[woodblockChannel]];
    
    // SequencerChannel1 Test
    // Playing a sound at a given BPM, using frames for timing.
//    SequencerChannel1 *channel1 = [SequencerChannel1 sequencerChannelWithAudioFileAt:sampleURL audioController:audioController repeatAtBPM:120];
//    [audioController addChannels:@[channel1]];
    
    // SequencerChannel2 Test
    // Playing a sound at a given BPM, using mach_time() for timing.
//    SequencerChannel2 *channel2 = [SequencerChannel2 sequencerChannelWithAudioFileAt:sampleURL audioController:audioController repeatAtBPM:120];
//    [audioController addChannels:@[channel2]];
    
    // SequencerChannel3 Test
    // Playing a pattern.
    int bpm = 120;
    NSMutableArray *mySequence = [NSMutableArray array];
    [mySequence addObject:[Beat beatWithOnset:0   velocity:1]];
    [mySequence addObject:[Beat beatWithOnset:0.5 velocity:1]];
    SequencerChannel3 *woodblockChannel3a = [SequencerChannel3 sequencerChannelWithAudioFileAt:sampleURL
                                                                               audioController:audioController
                                                                                   withPattern:mySequence
                                                                                         atBPM:bpm];
    [audioController addChannels:@[woodblockChannel3a]];
    NSMutableArray *mySequence1 = [NSMutableArray array];
    [mySequence1 addObject:[Beat beatWithOnset:0 velocity:1]]; // Weird things happen if a channel doesn't have a note at zero.
    [mySequence1 addObject:[Beat beatWithOnset:0.25 velocity:1]];
    [mySequence1 addObject:[Beat beatWithOnset:0.75 velocity:1]];
    [mySequence1 addObject:[Beat beatWithOnset:0.875 velocity:1]];
    SequencerChannel3 *woodblockChannel3b = [SequencerChannel3 sequencerChannelWithAudioFileAt:sampleURL1
                                                                              audioController:audioController
                                                                                  withPattern:mySequence1
                                                                                        atBPM:bpm];
    [audioController addChannels:@[woodblockChannel3b]];
    NSMutableArray *mySequence2 = [NSMutableArray array];
    [mySequence2 addObject:[Beat beatWithOnset:0 velocity:1]]; // Weird things happen if a channel doesn't have a note at zero.
    [mySequence2 addObject:[Beat beatWithOnset:0.875 velocity:1]];
    SequencerChannel3 *woodblockChannel3c = [SequencerChannel3 sequencerChannelWithAudioFileAt:sampleURL2
                                                                               audioController:audioController
                                                                                   withPattern:mySequence2
                                                                                         atBPM:bpm];
    [audioController addChannels:@[woodblockChannel3c]];
}

- (void)setupTimedChannel {

    //Play a sound every 1/4 note:
    NSMutableArray *mySequence = [NSMutableArray array];

    [mySequence addObject:[Beat beatWithOnset:0]];
    
    [mySequence addObject:[Beat beatWithOnset:0.25
                                        velocity:0.8]];

    [mySequence addObject:[Beat beatWithOnset:0.5]];

    [mySequence addObject:[Beat beatWithOnset:0.75
                                        velocity:0.8]];



    //Play sound on first and second 1/8 notes
    //silence for one 1/8 note, then play sound
    //on fourth and fifth 1/8 notes.
    NSMutableArray *beatsSecondBar = [NSMutableArray array];

    [beatsSecondBar addObject:[Beat beatWithOnset:1]];

    [beatsSecondBar addObject:[Beat beatWithOnset:1.125
                                         velocity:0.8]];

    [beatsSecondBar addObject:[Beat beatWithOnset:1.5]];

    [beatsSecondBar addObject:[Beat beatWithOnset:1.625
                                         velocity:0.8]];

    //Play a typical waltz:
    __unused NSMutableArray *waltz = [NSMutableArray array];

    [waltz addObject:[Beat beatWithOnset:0]];
    [waltz addObject:[Beat beatWithOnset:1/3
                                velocity:0.8]];
    [waltz addObject:[Beat beatWithOnset:2/3
                                velocity:0.8]];

    [mySequence addObjectsFromArray:beatsSecondBar];

    timedChannel = [TimedChannel timedChannelWithAudioFile:nil
                                            beatsPerMinute:60
                                                  sequence:mySequence];

    [audioController addTimingReceiver:timedChannel];

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
