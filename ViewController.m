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

    AEChannelGroupRef _mainChannelGroup;

    IBOutlet UIButton *kickButtonOne;
    IBOutlet UIButton *kickButtonTwo;
    IBOutlet UIButton *kickButtonThree;
    IBOutlet UIButton *kickButtonFour;

    IBOutlet UIButton *playPauseButton;
    
    bool _isPlaying;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupAudioController];

    // Pick one.
    [self setupSequencer];
//    [self setupMetronome];
}

- (void)setupMetronome {

    double bpm = 100.0;

    NSURL *hihatURL = [[NSBundle mainBundle] URLForResource:@"hihat" withExtension:@"caf"];
    SequencerChannelSequence *metronomeSequence = [SequencerChannelSequence new];

    //I'm being stupid and doing this:
    [metronomeSequence addBeat:[SequencerBeat beatWithOnset:0.0/4]];
    [metronomeSequence addBeat:[SequencerBeat beatWithOnset:1.0/4]];
    [metronomeSequence addBeat:[SequencerBeat beatWithOnset:2.0/4]];
    [metronomeSequence addBeat:[SequencerBeat beatWithOnset:3.0/4]];

    SequencerChannel *metronomeChannel = [SequencerChannel sequencerChannelWithAudioFileAt:hihatURL
                                                         audioController:audioController
                                                             withSequence:metronomeSequence
                                                            numberOfFullBeatsPerMeasure:4
                                                                   atBPM:bpm];
    [audioController addChannels:@[metronomeChannel] toChannelGroup:_mainChannelGroup];
}

- (void)setupSequencer {
    
    // Pattern vars.
    double bpm = 120.0;
    NSUInteger numBeats = 4;

    // KICK channel
    NSURL *kickURL = [[NSBundle mainBundle] URLForResource:@"kick" withExtension:@"caf"];
    SequencerChannelSequence *kickSequence = [SequencerChannelSequence new];
    [kickSequence addBeat:[SequencerBeat beatWithOnset:0.0 / 4 velocity:0.75 ]];
    [kickSequence addBeat:[SequencerBeat beatWithOnset:1.0 / 4 velocity:0.25 ]];
    [kickSequence addBeat:[SequencerBeat beatWithOnset:2.0 / 4 velocity:0.75 ]];
    [kickSequence addBeat:[SequencerBeat beatWithOnset:3.0 / 4 velocity:0.25 ]];
    SequencerChannel *kickChannel = [SequencerChannel sequencerChannelWithAudioFileAt:kickURL
                                                                      audioController:audioController
                                                                          withSequence:kickSequence
                                                          numberOfFullBeatsPerMeasure:numBeats
                                                                                atBPM:bpm];
    [audioController addChannels:@[kickChannel] toChannelGroup:_mainChannelGroup];
    
    // WOODBLOCK channel
    NSURL *woodblockURL = [[NSBundle mainBundle] URLForResource:@"woodblock" withExtension:@"caf"];
    SequencerChannelSequence *woodblockSequence = [SequencerChannelSequence new];
    [woodblockSequence addBeat:[SequencerBeat beatWithOnset:1.0 / 4 + 2.0 / 16 velocity:0.25 ]];
    [woodblockSequence addBeat:[SequencerBeat beatWithOnset:2.0 / 4 + 1.0 / 16 velocity:0.5 ]];
    [woodblockSequence addBeat:[SequencerBeat beatWithOnset:2.0 / 4 + 2.0 / 16 velocity:0.125 ]];
    [woodblockSequence addBeat:[SequencerBeat beatWithOnset:2.0 / 4 + 3.0 / 16 velocity:0.5 ]];
    [woodblockSequence addBeat:[SequencerBeat beatWithOnset:3.0 / 4 + 1.0 / 8 velocity:0.5 ]];
    SequencerChannel *woodblockChannel = [SequencerChannel sequencerChannelWithAudioFileAt:woodblockURL
                                                                           audioController:audioController
                                                                              withSequence:woodblockSequence
                                                               numberOfFullBeatsPerMeasure:numBeats
                                                                                     atBPM:bpm];
    [audioController addChannels:@[woodblockChannel] toChannelGroup:_mainChannelGroup];

    // CRICK channel
    NSURL *crickURL = [[NSBundle mainBundle] URLForResource:@"crick" withExtension:@"caf"];
    SequencerChannelSequence *crickSequence = [SequencerChannelSequence new];
    [crickSequence addBeat:[SequencerBeat beatWithOnset:0.0 / 4 + 1.0 / 8 velocity:0.0625 ]];
    [crickSequence addBeat:[SequencerBeat beatWithOnset:3.0 / 4 + 3.0 / 16 velocity:0.125 ]];
    SequencerChannel *crickChannel = [SequencerChannel sequencerChannelWithAudioFileAt:crickURL
                                                                       audioController:audioController
                                                                          withSequence:crickSequence
                                                           numberOfFullBeatsPerMeasure:numBeats
                                                                                 atBPM:bpm];
    [audioController addChannels:@[crickChannel] toChannelGroup:_mainChannelGroup];


    // HI-HAT channel
    NSURL *hihatURL = [[NSBundle mainBundle] URLForResource:@"hihat" withExtension:@"caf"];
    SequencerChannelSequence *hihatSequence = [SequencerChannelSequence new];
    [hihatSequence addBeat:[SequencerBeat beatWithOnset:0.0 / 4 + 1.0 / 8 velocity:0.5 ]];
    [hihatSequence addBeat:[SequencerBeat beatWithOnset:1.0 / 4 + 1.0 / 16 velocity:0.25 ]];
    [hihatSequence addBeat:[SequencerBeat beatWithOnset:1.0 / 4 + 3.0 / 16 velocity:0.25 ]];
    [hihatSequence addBeat:[SequencerBeat beatWithOnset:2.0 / 4 + 1.0 / 8  velocity:0.5 ]];
    [hihatSequence addBeat:[SequencerBeat beatWithOnset:3.0 / 4 + 1.0 / 16 velocity:0.25 ]];
    [hihatSequence addBeat:[SequencerBeat beatWithOnset:3.0 / 4 + 2.0 / 16 velocity:0.5 ]];
    [hihatSequence addBeat:[SequencerBeat beatWithOnset:3.0 / 4 + 3.0 / 16 velocity:0.25 ]];
    SequencerChannel *hihatChannel = [SequencerChannel sequencerChannelWithAudioFileAt:hihatURL
                                                                       audioController:audioController
                                                                          withSequence:hihatSequence
                                                           numberOfFullBeatsPerMeasure:numBeats
                                                                                 atBPM:bpm];
    [audioController addChannels:@[hihatChannel] toChannelGroup:_mainChannelGroup];
}

#pragma mark -
#pragma mark Init

- (void)setupAudioController {
    
    // Init audio controller:
    audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]];

    // Start it.
    NSError *audioControllerStartError = nil;
    [audioController start:&audioControllerStartError];
    if (audioControllerStartError) {
        NSLog(@"Audio controller start error: %@", audioControllerStartError.localizedDescription);
    }
    
    // Will hold the top layer of channels.
    _mainChannelGroup = [audioController createChannelGroup];
    
    _isPlaying = false;
    
    // Init UI.
    [_mainVolumeSlider addTarget:self action:@selector(mainVolumeSliderChanged:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark -
#pragma mark UI Events

- (void)mainVolumeSliderChanged:(UISlider*)sender {
    [audioController setVolume:sender.value forChannelGroup:_mainChannelGroup];
}

#pragma mark -
#pragma mark Playback Control

- (IBAction)tappedKickButton:(id)sender {

    double beatOnset;

    // Select onset from pressed button.
    if (sender == kickButtonOne) beatOnset = 0/4.0;
    else if (sender == kickButtonTwo) beatOnset = 1/4.0;
    else if (sender == kickButtonThree) beatOnset = 2/4.0;
    else if (sender == kickButtonFour) beatOnset = 3/4.0;

    // Grab the first channel.
    NSArray *channels = [self sequencerChannelsInGroup:_mainChannelGroup];
    SequencerChannel *channel = [channels objectAtIndex:0];
    NSLog(@"sequence entering: %@", channel.sequence);

    // Identify the beat.
    SequencerBeat *beat = [channel.sequence beatAtOnset:beatOnset];
    
    // Add or remove the beat.
    if(beat) {
        [channel.sequence removeBeatAtOnset:beatOnset];
    }
    else {
        [channel.sequence addBeat:[SequencerBeat beatWithOnset:beatOnset]];
    }

    NSLog(@"sequence leaving: %@", channel.sequence);
}

- (IBAction)togglePlayPause {
    
    _isPlaying = !_isPlaying;
    
    // Sweep all channels and apply.
    NSArray *channels = [self sequencerChannelsInGroup:_mainChannelGroup];
    for(int i = 0; i < channels.count; i++) {
        SequencerChannel *channel = [channels objectAtIndex:i];
        channel.sequenceIsPlaying = _isPlaying;
    }

    // Toggle button.
    if(!_isPlaying) {
        [playPauseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        playPauseButton.backgroundColor = [UIColor orangeColor];
    }
    else {
        playPauseButton.backgroundColor = [UIColor blackColor];
        [playPauseButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark Utils

- (NSArray*)sequencerChannelsInGroup:(AEChannelGroupRef)group {
    
    NSMutableArray *seqChannels = [NSMutableArray array];
    
    NSArray *channels = [audioController channelsInChannelGroup:group];
    for(int i = 0; i < channels.count; i++) {
        id channel = [channels objectAtIndex:i];
        if([channel isKindOfClass:[SequencerChannel class]]) {
            [seqChannels addObject:channel];
        }
    }
    
    return seqChannels;
}

@end



























