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
#import "SequencerBeat.h"

@import AVFoundation;

@implementation ViewController {
    AEAudioController *audioController;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupAudioController];
    [self setupSequencer];
}

- (void)setupSequencer {
    
    /*
     This is probably the worst rhythm ever conceived by the human intelect.
     Sorry =P
     */
    
    // Pattern vars.
    int bpm = 120;
    int numBeats = 4;
    
    // KICK channel
    NSMutableArray *kickSequence = [NSMutableArray array];
    [kickSequence addObject:[SequencerBeat beatWithOnset:0.25 * 0 velocity:0.5  ]];
    [kickSequence addObject:[SequencerBeat beatWithOnset:0.25 * 1 velocity:0.25 ]];
    [kickSequence addObject:[SequencerBeat beatWithOnset:0.25 * 2 velocity:0.5  ]];
    [kickSequence addObject:[SequencerBeat beatWithOnset:0.25 * 3 velocity:0.25 ]];
    SequencerChannel *kickChannel = [SequencerChannel sequencerChannelWithAudioFileAt:[[NSBundle mainBundle] URLForResource:@"kick" withExtension:@"caf"]
                                                                      audioController:audioController
                                                                          withPattern:kickSequence
                                                                         withDuration:numBeats
                                                                                atBPM:bpm];
    
    // WOODBLOCK channel
    NSMutableArray *woodblockSequence = [NSMutableArray array];
    [woodblockSequence addObject:[SequencerBeat beatWithOnset:0.125 + 0.25 * 0          velocity:1    ]];
    [woodblockSequence addObject:[SequencerBeat beatWithOnset:0.25 * 2                  velocity:0.5  ]];
    [woodblockSequence addObject:[SequencerBeat beatWithOnset:0.0625 + 0.25 * 2         velocity:0.25 ]];
    [woodblockSequence addObject:[SequencerBeat beatWithOnset:0.125 + 0.25 * 3 + 0.0625 velocity:0.5  ]];
    SequencerChannel *woodblockChannel = [SequencerChannel sequencerChannelWithAudioFileAt:[[NSBundle mainBundle] URLForResource:@"woodblock" withExtension:@"caf"]
                                                                           audioController:audioController
                                                                               withPattern:woodblockSequence
                                                                              withDuration:numBeats
                                                                                     atBPM:bpm];
    
    
    // HI-HAT channel
    NSMutableArray *hihatSequence = [NSMutableArray array];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:0.125 + 0.25 * 0          velocity:1    ]];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:0.125 + 0.25 * 1          velocity:0.5  ]];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:0.125 + 0.25 * 2          velocity:1    ]];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:0.125 + 0.25 * 3          velocity:0.75 ]];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:0.125 + 0.25 * 3 + 0.0625 velocity:0.5  ]];
    SequencerChannel *hihatChannel = [SequencerChannel sequencerChannelWithAudioFileAt:[[NSBundle mainBundle] URLForResource:@"hihat" withExtension:@"caf"]
                                                                       audioController:audioController
                                                                           withPattern:hihatSequence
                                                                          withDuration:numBeats
                                                                                 atBPM:bpm];
    
    // Add channels to engine.
    [audioController addChannels:@[kickChannel]];
    [audioController addChannels:@[woodblockChannel]];
    [audioController addChannels:@[hihatChannel]];
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
