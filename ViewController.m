//
//  ViewController.m
//  The Amazing Audio Engine
//
//  Created by Ariel Elkin on 01/04/2014.
//  Copyright (c) 2014 Ariel Elkin. All rights reserved.
//

#import "ViewController.h"

#import "AEAudioController.h"
#import "AESequencerChannel.h"
#import "AESequencerBeat.h"
#import "AESequencerChannelSequence.h"

#import "SequencerButton.h"


@import AVFoundation;

@interface ViewController()<SequencerButtonDelegate>

@end

@implementation ViewController {
    
    AEAudioController *audioController;

    AESequencerChannel *kickChannel;
    AESequencerChannel *woodblockChannel;
    AESequencerChannel *crickChannel;
    AESequencerChannel *hihatChannel;

    AEChannelGroupRef _mainChannelGroup;

    IBOutlet UIButton *playPauseButton;
    
    bool sequencerIsPlaying;

    NSInteger numberOfRows;
    NSInteger numberOfColumns;
    CGFloat buttonWidth;
    CGFloat buttonHeight;

}


#pragma mark -
#pragma mark Setup

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self setupSequencerUI];
    [self setupAudioController];
    [self setupSequencer];

    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressView) userInfo:nil repeats:YES];
}


- (void)setupSequencerUI {

    [_mainVolumeSlider addTarget:self action:@selector(mainVolumeSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_bpmSlider addTarget:self action:@selector(bpmSliderChanged:) forControlEvents:UIControlEventValueChanged];


    UIView *sequencerView = [UIView new];
    sequencerView.backgroundColor = [UIColor purpleColor];
    sequencerView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:sequencerView];

    NSArray *constraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sequencerView]-240-|" options:0 metrics:nil views:@{@"sequencerView": sequencerView}];
    [self.view addConstraints:constraintsH];

    NSArray *constraintsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sequencerView]|" options:0 metrics:nil views:@{@"sequencerView": sequencerView}];
    [self.view addConstraints:constraintsV];


    numberOfRows = 4;
    numberOfColumns = 16;
    buttonWidth = 35;
    buttonHeight = 70;

    for( int i = 0; i < numberOfRows; i++) {

        for ( int j = 0 ; j < numberOfColumns; j++ ) {

            SequencerButton *sequencerButton = [SequencerButton buttonWithRow:i column:j];
            sequencerButton.delegate = self;
            CGFloat width = buttonWidth;
            CGFloat height = buttonHeight;
            CGFloat originX = 20 + (j * width) * 1.2;
            CGFloat originY = 20 + (i * height) * 1.2;
            sequencerButton.frame = CGRectMake(originX, originY, width, height);

            [sequencerView addSubview:sequencerButton];
        }
    }
    [self.view bringSubviewToFront:self.playheadPositionOfKickSequence];
}


- (void) updateProgressView {
    self.playheadPositionOfKickSequence.progress = kickChannel.playheadPosition;
}


#pragma mark -
#pragma mark Playback Control

- (IBAction)togglePlayPause {

    sequencerIsPlaying = !sequencerIsPlaying;

    // Sweep all channels and apply.
    NSArray *channels = [self sequencerChannelsInGroup:_mainChannelGroup];
    for(int i = 0; i < channels.count; i++) {
        AESequencerChannel *channel = [channels objectAtIndex:i];
        channel.sequenceIsPlaying = sequencerIsPlaying;
    }

    // Toggle button.
    if(!sequencerIsPlaying) {
        [playPauseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        playPauseButton.backgroundColor = [UIColor orangeColor];
    }
    else {
        playPauseButton.backgroundColor = [UIColor blackColor];
        [playPauseButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    }
}

- (void)tappedButton:(SequencerButton *)button {

    AESequencerChannel *selectedChannel;

    if (button.row == 0) selectedChannel = kickChannel;
    else if (button.row == 1) selectedChannel = woodblockChannel;
    else if (button.row == 2) selectedChannel = crickChannel;
    else if (button.row == 3) selectedChannel = hihatChannel;

    double onset = (double)button.column / (double)numberOfColumns;

    AESequencerBeat *beat = [AESequencerBeat beatWithOnset:onset];

    if (button.isActive) {
        [selectedChannel.sequence addBeat:beat];
    }
    else {
        [selectedChannel.sequence removeBeatAtOnset:onset];
    }
    NSLog(@"%@", selectedChannel.sequence);
}

- (void)mainVolumeSliderChanged:(UISlider*)sender {
    [audioController setVolume:sender.value forChannelGroup:_mainChannelGroup];
}

- (void)bpmSliderChanged:(UISlider*)sender {
    //    NSLog(@"bpmSliderChanged: %f", sender.value);

    // Update label.
    _bpmLabel.text = [NSString stringWithFormat:@"%f", sender.value];

    // Sweep all channels and apply.
    NSArray *channels = [self sequencerChannelsInGroup:_mainChannelGroup];
    for(int i = 0; i < channels.count; i++) {
        AESequencerChannel *channel = [channels objectAtIndex:i];
        channel.bpm = sender.value;
    }
}


#pragma mark -
#pragma mark Sequencer Setup

- (void)setupSequencer {
    _mainChannelGroup = [audioController createChannelGroup];
    sequencerIsPlaying = false;


    // Pattern vars.
    double bpm = _bpmSlider.value;
    NSUInteger numBeats = 4;

    // KICK channel
    NSURL *kickURL = [[NSBundle mainBundle] URLForResource:@"kick" withExtension:@"caf"];
    AESequencerChannelSequence *kickSequence = [AESequencerChannelSequence new];
    kickChannel = [AESequencerChannel sequencerChannelWithAudioFileAt:kickURL
                                                    audioController:audioController
                                                       withSequence:kickSequence
                                        numberOfFullBeatsPerMeasure:numBeats
                                                              atBPM:bpm];
    [audioController addChannels:@[kickChannel] toChannelGroup:_mainChannelGroup];


    // WOODBLOCK channel
    NSURL *woodblockURL = [[NSBundle mainBundle] URLForResource:@"woodblock" withExtension:@"caf"];
    AESequencerChannelSequence *woodblockSequence = [AESequencerChannelSequence new];
    woodblockChannel = [AESequencerChannel sequencerChannelWithAudioFileAt:woodblockURL
                                                         audioController:audioController
                                                            withSequence:woodblockSequence
                                             numberOfFullBeatsPerMeasure:numBeats
                                                                   atBPM:bpm];
    [audioController addChannels:@[woodblockChannel] toChannelGroup:_mainChannelGroup];


    // CRICK channel
    NSURL *crickURL = [[NSBundle mainBundle] URLForResource:@"crick" withExtension:@"caf"];
    AESequencerChannelSequence *crickSequence = [AESequencerChannelSequence new];
    crickChannel = [AESequencerChannel sequencerChannelWithAudioFileAt:crickURL
                                                     audioController:audioController
                                                        withSequence:crickSequence
                                         numberOfFullBeatsPerMeasure:numBeats
                                                               atBPM:bpm];
    [audioController addChannels:@[crickChannel] toChannelGroup:_mainChannelGroup];


    // HI-HAT channel
    NSURL *hihatURL = [[NSBundle mainBundle] URLForResource:@"hihat" withExtension:@"caf"];
    AESequencerChannelSequence *hihatSequence = [AESequencerChannelSequence new];
    hihatChannel = [AESequencerChannel sequencerChannelWithAudioFileAt:hihatURL
                                                     audioController:audioController
                                                        withSequence:hihatSequence
                                         numberOfFullBeatsPerMeasure:numBeats
                                                               atBPM:bpm];
    [audioController addChannels:@[hihatChannel] toChannelGroup:_mainChannelGroup];

}

- (void)setupSequencerWithPremadeBeat {

    // Will hold the top layer of channels.
    _mainChannelGroup = [audioController createChannelGroup];
    sequencerIsPlaying = false;

    // Pattern vars.
    double bpm = _bpmSlider.value;
    NSUInteger numBeats = 4;

    // KICK channel
    NSURL *kickURL = [[NSBundle mainBundle] URLForResource:@"kick" withExtension:@"caf"];
    AESequencerChannelSequence *kickSequence = [AESequencerChannelSequence new];
    [kickSequence addBeat:[AESequencerBeat beatWithOnset:0.0 / 4 velocity:0.75 ]];
    [kickSequence addBeat:[AESequencerBeat beatWithOnset:1.0 / 4 velocity:0.25 ]];
    [kickSequence addBeat:[AESequencerBeat beatWithOnset:2.0 / 4 velocity:0.75 ]];
    [kickSequence addBeat:[AESequencerBeat beatWithOnset:3.0 / 4 velocity:0.25 ]];
    kickChannel = [AESequencerChannel sequencerChannelWithAudioFileAt:kickURL
                                                    audioController:audioController
                                                       withSequence:kickSequence
                                        numberOfFullBeatsPerMeasure:numBeats
                                                              atBPM:bpm];
    [audioController addChannels:@[kickChannel] toChannelGroup:_mainChannelGroup];

    // WOODBLOCK channel
    NSURL *woodblockURL = [[NSBundle mainBundle] URLForResource:@"woodblock" withExtension:@"caf"];
    AESequencerChannelSequence *woodblockSequence = [AESequencerChannelSequence new];
    [woodblockSequence addBeat:[AESequencerBeat beatWithOnset:1.0 / 4 + 2.0 / 16 velocity:0.25 ]];
    [woodblockSequence addBeat:[AESequencerBeat beatWithOnset:2.0 / 4 + 1.0 / 16 velocity:0.5 ]];
    [woodblockSequence addBeat:[AESequencerBeat beatWithOnset:2.0 / 4 + 2.0 / 16 velocity:0.125 ]];
    [woodblockSequence addBeat:[AESequencerBeat beatWithOnset:2.0 / 4 + 3.0 / 16 velocity:0.5 ]];
    [woodblockSequence addBeat:[AESequencerBeat beatWithOnset:3.0 / 4 + 1.0 / 8 velocity:0.5 ]];
    woodblockChannel = [AESequencerChannel sequencerChannelWithAudioFileAt:woodblockURL
                                                         audioController:audioController
                                                            withSequence:woodblockSequence
                                             numberOfFullBeatsPerMeasure:numBeats
                                                                   atBPM:bpm];
    [audioController addChannels:@[woodblockChannel] toChannelGroup:_mainChannelGroup];

    // CRICK channel
    NSURL *crickURL = [[NSBundle mainBundle] URLForResource:@"crick" withExtension:@"caf"];
    AESequencerChannelSequence *crickSequence = [AESequencerChannelSequence new];
    [crickSequence addBeat:[AESequencerBeat beatWithOnset:0.0 / 4 + 1.0 / 8 velocity:0.0625 ]];
    [crickSequence addBeat:[AESequencerBeat beatWithOnset:3.0 / 4 + 3.0 / 16 velocity:0.125 ]];
    crickChannel = [AESequencerChannel sequencerChannelWithAudioFileAt:crickURL
                                                     audioController:audioController
                                                        withSequence:crickSequence
                                         numberOfFullBeatsPerMeasure:numBeats
                                                               atBPM:bpm];
    [audioController addChannels:@[crickChannel] toChannelGroup:_mainChannelGroup];


    // HI-HAT channel
    NSURL *hihatURL = [[NSBundle mainBundle] URLForResource:@"hihat" withExtension:@"caf"];
    AESequencerChannelSequence *hihatSequence = [AESequencerChannelSequence new];
    [hihatSequence addBeat:[AESequencerBeat beatWithOnset:0.0 / 4 + 1.0 / 8 velocity:0.5 ]];
    [hihatSequence addBeat:[AESequencerBeat beatWithOnset:1.0 / 4 + 1.0 / 16 velocity:0.25 ]];
    [hihatSequence addBeat:[AESequencerBeat beatWithOnset:1.0 / 4 + 3.0 / 16 velocity:0.25 ]];
    [hihatSequence addBeat:[AESequencerBeat beatWithOnset:2.0 / 4 + 1.0 / 8  velocity:0.5 ]];
    [hihatSequence addBeat:[AESequencerBeat beatWithOnset:3.0 / 4 + 1.0 / 16 velocity:0.25 ]];
    [hihatSequence addBeat:[AESequencerBeat beatWithOnset:3.0 / 4 + 2.0 / 16 velocity:0.5 ]];
    [hihatSequence addBeat:[AESequencerBeat beatWithOnset:3.0 / 4 + 3.0 / 16 velocity:0.25 ]];
    hihatChannel = [AESequencerChannel sequencerChannelWithAudioFileAt:hihatURL
                                                     audioController:audioController
                                                        withSequence:hihatSequence
                                         numberOfFullBeatsPerMeasure:numBeats
                                                               atBPM:bpm];
    [audioController addChannels:@[hihatChannel] toChannelGroup:_mainChannelGroup];
}

- (void)setupAudioController {

    // Init audio controller:
    audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]];

    // Start it.
    NSError *audioControllerStartError = nil;
    [audioController start:&audioControllerStartError];
    if (audioControllerStartError) {
        NSLog(@"Audio controller start error: %@", audioControllerStartError.localizedDescription);
    }
}


#pragma mark -
#pragma mark Utils

- (NSArray*)sequencerChannelsInGroup:(AEChannelGroupRef)group {
    
    NSMutableArray *seqChannels = [NSMutableArray array];
    
    NSArray *channels = [audioController channelsInChannelGroup:group];
    for(int i = 0; i < channels.count; i++) {
        id channel = [channels objectAtIndex:i];
        if([channel isKindOfClass:[AESequencerChannel class]]) {
            [seqChannels addObject:channel];
        }
    }
    
    return seqChannels;
}

@end



























