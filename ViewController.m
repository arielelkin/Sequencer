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
    
//    [self setupSequencer];
//    [self setupDumbMetronome];
//    [self setupWithInvalidBeats];
    [self setupMetronome];
}

- (void)setupMetronome {

    //I want to do the back-end for a metronome app:
    double bpm = 100.0;

    NSURL *hihatURL = [[NSBundle mainBundle] URLForResource:@"hihat" withExtension:@"caf"];
    NSMutableArray *metronomeSequence = [NSMutableArray array];

    //I'm being stupid and doing this:
    [metronomeSequence addObject:[SequencerBeat beatWithOnset:0.0/4]];
    [metronomeSequence addObject:[SequencerBeat beatWithOnset:1.0/4]];
    [metronomeSequence addObject:[SequencerBeat beatWithOnset:2.0/4]];
    [metronomeSequence addObject:[SequencerBeat beatWithOnset:3.0/4]];
    SequencerChannel *metronomeChannel = [SequencerChannel sequencerChannelWithAudioFileAt:hihatURL
                                                                           audioController:audioController
                                                                               withPattern:metronomeSequence
                                                                                     atBPM:bpm];
    [audioController addChannels:@[metronomeChannel]];

}

- (void)setupDumbMetronome {

    //I want to do the back-end for a metronome app:
    double bpm = 100.0;
    NSUInteger numBeats = 2;

    NSURL *hihatURL = [[NSBundle mainBundle] URLForResource:@"hihat" withExtension:@"caf"];
    NSMutableArray *metronomeSequence = [NSMutableArray array];

    //I'm being stupid and doing this:
    [metronomeSequence addObject:[SequencerBeat beatWithOnset:0/4]];
    [metronomeSequence addObject:[SequencerBeat beatWithOnset:1/4]];
    [metronomeSequence addObject:[SequencerBeat beatWithOnset:2/4]];
    [metronomeSequence addObject:[SequencerBeat beatWithOnset:3/4]];

    SequencerChannel *metronomeChannel = [SequencerChannel sequencerChannelWithAudioFileAt:hihatURL
                                                                       audioController:audioController
                                                                           withPattern:metronomeSequence
                                                                          withDuration:numBeats
                                                                                 atBPM:bpm];
    [audioController addChannels:@[metronomeChannel]];

}

- (void)setupWithInvalidBeats {
    NSURL *hihatURL = nil;

    NSMutableArray *metronomeSequence = [NSMutableArray array];

    //I'm an idiot, so please fail gracefully:
    [metronomeSequence addObject:[NSArray new]];
    [metronomeSequence addObject:[NSNumber new]];
    [metronomeSequence addObject:[NSScanner new]];

    NSUInteger duration = 0;
    NSUInteger bpm = 0;

    SequencerChannel *metronomeChannel = [SequencerChannel sequencerChannelWithAudioFileAt:hihatURL
                                                                           audioController:audioController
                                                                               withPattern:metronomeSequence
                                                                              withDuration:duration
                                                                                     atBPM:bpm];
    [audioController addChannels:@[metronomeChannel]];


}

- (void)setupSequencer {
    
    // Pattern vars.
    double bpm = 120.0;
    NSUInteger numBeats = 4;

    // KICK channel
    NSURL *kickURL = [[NSBundle mainBundle] URLForResource:@"kick" withExtension:@"caf"];
    NSMutableArray *kickSequence = [NSMutableArray array];
    [kickSequence addObject:[SequencerBeat beatWithOnset:0.0 / 4 velocity:0.75 ]];
    [kickSequence addObject:[SequencerBeat beatWithOnset:1.0 / 4 velocity:0.25 ]];
    [kickSequence addObject:[SequencerBeat beatWithOnset:2.0 / 4 velocity:0.75 ]];
    [kickSequence addObject:[SequencerBeat beatWithOnset:3.0 / 4 velocity:0.25 ]];
    SequencerChannel *kickChannel = [SequencerChannel sequencerChannelWithAudioFileAt:kickURL
                                                                      audioController:audioController
                                                                          withPattern:kickSequence
                                                                         withDuration:numBeats
                                                                                atBPM:bpm];
    [audioController addChannels:@[kickChannel]];
    
    // WOODBLOCK channel
    NSURL *woodblockURL = [[NSBundle mainBundle] URLForResource:@"woodblock" withExtension:@"caf"];
    NSMutableArray *woodblockSequence = [NSMutableArray array];
    [woodblockSequence addObject:[SequencerBeat beatWithOnset:1.0 / 4 + 2.0 / 16 velocity:0.25 ]];
    [woodblockSequence addObject:[SequencerBeat beatWithOnset:2.0 / 4 + 1.0 / 16 velocity:0.5 ]];
    [woodblockSequence addObject:[SequencerBeat beatWithOnset:2.0 / 4 + 2.0 / 16 velocity:0.125 ]];
    [woodblockSequence addObject:[SequencerBeat beatWithOnset:2.0 / 4 + 3.0 / 16 velocity:0.5 ]];
    [woodblockSequence addObject:[SequencerBeat beatWithOnset:3.0 / 4 + 1.0 / 8 velocity:0.5 ]];
    SequencerChannel *woodblockChannel = [SequencerChannel sequencerChannelWithAudioFileAt:woodblockURL
                                                                           audioController:audioController
                                                                               withPattern:woodblockSequence
                                                                              withDuration:numBeats
                                                                                     atBPM:bpm];
    [audioController addChannels:@[woodblockChannel]];
    
    // CRICK channel
    NSURL *crickURL = [[NSBundle mainBundle] URLForResource:@"crick" withExtension:@"caf"];
    NSMutableArray *crickSequence = [NSMutableArray array];
    [crickSequence addObject:[SequencerBeat beatWithOnset:0.0 / 4 + 1.0 / 8 velocity:0.0625 ]];
    [crickSequence addObject:[SequencerBeat beatWithOnset:3.0 / 4 + 3.0 / 16 velocity:0.125 ]];
    SequencerChannel *crickChannel = [SequencerChannel sequencerChannelWithAudioFileAt:crickURL
                                                                       audioController:audioController
                                                                           withPattern:crickSequence
                                                                          withDuration:numBeats
                                                                                 atBPM:bpm];
    [audioController addChannels:@[crickChannel]];

    
    // HI-HAT channel
    NSURL *hihatURL = [[NSBundle mainBundle] URLForResource:@"hihat" withExtension:@"caf"];
    NSMutableArray *hihatSequence = [NSMutableArray array];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:0.0 / 4 + 1.0 / 8 velocity:0.5 ]];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:1.0 / 4 + 1.0 / 16 velocity:0.25 ]];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:1.0 / 4 + 3.0 / 16 velocity:0.25 ]];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:2.0 / 4 + 1.0 / 8  velocity:0.5 ]];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:3.0 / 4 + 1.0 / 16 velocity:0.25 ]];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:3.0 / 4 + 2.0 / 16 velocity:0.5 ]];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:3.0 / 4 + 3.0 / 16 velocity:0.25 ]];
    SequencerChannel *hihatChannel = [SequencerChannel sequencerChannelWithAudioFileAt:hihatURL
                                                                       audioController:audioController
                                                                           withPattern:hihatSequence
                                                                          withDuration:numBeats
                                                                                 atBPM:bpm];
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
