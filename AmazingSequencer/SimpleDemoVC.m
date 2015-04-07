//
//  SimpleDemoVC.m
//  AmazingSequencer
//
//  Created by Ariel Elkin on 07/04/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import "SimpleDemoVC.h"

#import "AESequencerChannel.h"
#import "AESequencerChannelSequence.h"
#import "AESequencerBeat.h"

@implementation SimpleDemoVC {
    AEAudioController *audioController;
    AESequencerChannel *woodBlockSoundChannel;
    AESequencerChannel *crickSoundChannel;
}

- (void)setupUI {

    UILabel *label = [UILabel new];
    label.text = @"The Amazing Audio Engine Sequencer - Simple Demo";
    label.font = [UIFont systemFontOfSize:30];
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:label];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:30];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.backgroundColor = [UIColor blueColor];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton addTarget:self action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    NSDictionary *views = @{@"label": label, @"backButton":backButton};

    NSArray *labelConstraints = [NSLayoutConstraint
                                 constraintsWithVisualFormat:@"H:|-[label]-|"
                                 options:0
                                 metrics:nil
                                 views:views];
    [self.view addConstraints:labelConstraints];


    labelConstraints = [NSLayoutConstraint
                        constraintsWithVisualFormat:@"V:|-200-[label]"
                        options:0
                        metrics:nil
                        views:views];
    [self.view addConstraints:labelConstraints];



    NSArray *backButtonConstraints = [NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|-[backButton(200)]"
                                      options:0
                                      metrics:nil
                                      views:views];
    [self.view addConstraints:backButtonConstraints];

    backButtonConstraints = [NSLayoutConstraint
                             constraintsWithVisualFormat:@"V:|-20-[backButton(100)]"
                             options:0
                             metrics:nil
                             views:views];
    [self.view addConstraints:backButtonConstraints];
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];

    // Init the AEAudioController:
    audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]];

    // Start it:
    NSError *audioControllerStartError = nil;
    [audioController start:&audioControllerStartError];
    if (audioControllerStartError) {
        NSLog(@"Audio controller start error: %@", audioControllerStartError.localizedDescription);
    }


    //Find the NSURL of your audio file:
    NSURL *woodblockSoundURL = [[NSBundle mainBundle] URLForResource:@"woodblock" withExtension:@"caf"];

    //Specify at which times it should play:
    AESequencerChannelSequence *woodblockSoundSequence = [AESequencerChannelSequence new];
    [woodblockSoundSequence addBeat:[AESequencerBeat beatWithOnset:0]];
    [woodblockSoundSequence addBeat:[AESequencerBeat beatWithOnset:0.25]];
    [woodblockSoundSequence addBeat:[AESequencerBeat beatWithOnset:0.50]];
    [woodblockSoundSequence addBeat:[AESequencerBeat beatWithOnset:0.75]];


    //Create a channel that will play the sequence:
    woodBlockSoundChannel = [AESequencerChannel sequencerChannelWithAudioFileAt:woodblockSoundURL
                                                       audioController:audioController
                                                          withSequence:woodblockSoundSequence
                                           numberOfFullBeatsPerMeasure:4
                                                                 atBPM:120];


    //Add it to the audio controller:
    [audioController addChannels:@[woodBlockSoundChannel]];


    //Tell it to start playing:
    woodBlockSoundChannel.sequenceIsPlaying = true;



    //How about something more complex?

    NSURL *crickSoundURL = [[NSBundle mainBundle] URLForResource:@"crick" withExtension:@"caf"];
    AESequencerChannelSequence *crickSoundSequence= [AESequencerChannelSequence new];
    [crickSoundSequence addBeat:[AESequencerBeat beatWithOnset:1.0 / 4 + 2.0 / 16   velocity:0.25 ]];
    [crickSoundSequence addBeat:[AESequencerBeat beatWithOnset:2.0 / 4 + 1.0 / 16   velocity:0.5 ]];
    [crickSoundSequence addBeat:[AESequencerBeat beatWithOnset:2.0 / 4 + 2.0 / 16   velocity:0.125 ]];
    [crickSoundSequence addBeat:[AESequencerBeat beatWithOnset:2.0 / 4 + 3.0 / 16   velocity:0.5 ]];
    [crickSoundSequence addBeat:[AESequencerBeat beatWithOnset:3.0 / 4 + 1.0 / 8    velocity:0.5 ]];

    crickSoundChannel = [AESequencerChannel sequencerChannelWithAudioFileAt:crickSoundURL
                                                           audioController:audioController
                                                              withSequence:crickSoundSequence
                                               numberOfFullBeatsPerMeasure:4
                                                                     atBPM:120];
    [audioController addChannels:@[crickSoundChannel]];


    crickSoundChannel.sequenceIsPlaying = true;
}

- (void)viewWillDisappear:(BOOL)animated {
    crickSoundChannel.sequenceIsPlaying = false;
    [audioController stop];
}

@end
