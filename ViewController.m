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
#import "SequencerChannelSequence.h"

@import AVFoundation;

@implementation ViewController {
    AEAudioController *audioController;

    SequencerChannel *kickChannel;
    IBOutlet UIButton *kickButtonOne;
    IBOutlet UIButton *kickButtonTwo;
    IBOutlet UIButton *kickButtonThree;
    IBOutlet UIButton *kickButtonFour;
}

- (void)viewDidLoad{
    [super viewDidLoad];

    SequencerChannelSequence *mySequence = [SequencerChannelSequence new];
    [mySequence addBeat:[SequencerBeat beatWithOnset:0.4]];
    [mySequence addBeat:[SequencerBeat beatWithOnset:0.1]];
    [mySequence addBeat:[SequencerBeat beatWithOnset:0.3]];

    mySequence[0].onset = 0.9;

    mySequence[3] = [SequencerBeat beatWithOnset:0.5];


    double **theSeq = [mySequence CRepresentation];


    NSLog(@"%@", mySequence);
    [mySequence removeBeatAtIndex:3];
    [mySequence removeBeatAtIndex:2];

    theSeq = [mySequence CRepresentation];
    

    [mySequence setOnsetOfBeatAtOnset:0.1 to:0.2];
    [mySequence setVelocityOfBeatAtOnset:0.2 to:234];

    theSeq = [mySequence CRepresentation];

    NSLog(@"%@", mySequence);


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupAudioController];
//    [self setupSequencer];

//    [self setupDumbMetronome];
    [self setupWithInvalidBeats];
//    [self setupMetronome];
}

- (void)setupMetronome {

    //I want to do the back-end for a metronome app:
    double bpm = 100.0;

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
    [metronomeSequence addObject:[NSPointerFunctions new]];
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
    
    /*
     This is probably the worst rhythm ever conceived by the human intelect.
     Sorry =P
     */

    // Pattern vars.
    double bpm = 120.0;
    NSUInteger numBeats = 4;

    // KICK channel
    NSURL *kickURL = [[NSBundle mainBundle] URLForResource:@"kick" withExtension:@"caf"];
    NSMutableArray *kickSequence = [NSMutableArray array];

    //Add kick sound every quarter:
    //0/4, 1/4, 2/4, 3/4
    [kickSequence addObject:[SequencerBeat beatWithOnset:0.25 * 0 velocity:0.5  ]];
    [kickSequence addObject:[SequencerBeat beatWithOnset:0.25 * 1 velocity:0.25 ]];
    [kickSequence addObject:[SequencerBeat beatWithOnset:0.25 * 2 velocity:0.5  ]];
    [kickSequence addObject:[SequencerBeat beatWithOnset:0.25 * 3 velocity:0.25 ]];

    kickChannel = [SequencerChannel sequencerChannelWithAudioFileAt:kickURL
                                                                      audioController:audioController
                                                                          withPattern:kickSequence
                                                                         withDuration:numBeats
                                                                                atBPM:bpm];
    
    // WOODBLOCK channel
    NSURL *woodblockURL = [[NSBundle mainBundle] URLForResource:@"woodblock" withExtension:@"caf"];
    NSMutableArray *woodblockSequence = [NSMutableArray array];

    //TODO:
    //Add woodblock sound every ???
    [woodblockSequence addObject:[SequencerBeat beatWithOnset:0.125 + 0.25 * 0          velocity:1    ]];
    [woodblockSequence addObject:[SequencerBeat beatWithOnset:0.25 * 2                  velocity:0.5  ]];
    [woodblockSequence addObject:[SequencerBeat beatWithOnset:0.0625 + 0.25 * 2         velocity:0.25 ]];
    [woodblockSequence addObject:[SequencerBeat beatWithOnset:0.125 + 0.25 * 3 + 0.0625 velocity:0.5  ]];

    SequencerChannel *woodblockChannel = [SequencerChannel sequencerChannelWithAudioFileAt:woodblockURL
                                                                           audioController:audioController
                                                                               withPattern:woodblockSequence
                                                                              withDuration:numBeats
                                                                                     atBPM:bpm];
    
    
    // HI-HAT channel
    NSURL *hihatURL = [[NSBundle mainBundle] URLForResource:@"hihat" withExtension:@"caf"];
    NSMutableArray *hihatSequence = [NSMutableArray array];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:0.125 + 0.25 * 0          velocity:1    ]];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:0.125 + 0.25 * 1          velocity:0.5  ]];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:0.125 + 0.25 * 2          velocity:1    ]];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:0.125 + 0.25 * 3          velocity:0.75 ]];
    [hihatSequence addObject:[SequencerBeat beatWithOnset:0.125 + 0.25 * 3 + 0.0625 velocity:0.5  ]];

    SequencerChannel *hihatChannel = [SequencerChannel sequencerChannelWithAudioFileAt:hihatURL
                                                                       audioController:audioController
                                                                           withPattern:hihatSequence
                                                                          withDuration:numBeats
                                                                                 atBPM:bpm];
    
    // Add channels to engine.
    [audioController addChannels:@[kickChannel]];
//    [audioController addChannels:@[woodblockChannel]];
//    [audioController addChannels:@[hihatChannel]];
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

#pragma mark -
#pragma mark UI Setup

- (IBAction)tappedKickButton:(id)sender {

    NSUInteger beatIndex;
    [SequencerBeat beatWithOnset:-1 velocity:314];

    for (SequencerBeat *beat in kickChannel.sequence) {
        NSLog(@"%@", beat);
    }
    NSLog(@" ");

    if (sender == kickButtonOne) beatIndex = 0;

    else if (sender == kickButtonTwo) beatIndex = 1;

    else if (sender == kickButtonThree) beatIndex = 2;

    else if (sender == kickButtonFour) beatIndex = 3;

    SequencerBeat *beat = kickChannel.sequence[beatIndex];
    if (beat) {
        [kickChannel.sequence removeObject:beat];
    }
    else {
        beat = [SequencerBeat beatWithOnset:0];
        [kickChannel.sequence insertObject:beat atIndex:beatIndex];
    }
}

@end
