//
//  AppDelegate.m
//  AmazingSequencer
//
//  Created by Ariel Elkin on 26/03/2014.
//  Copyright (c) 2014 Ariel Elkin. All rights reserved.
//

#import "AppDelegate.h"
#import "AEAudioController.h"
#import "AEAudioFilePlayer.h"
#import "SamplePlayer.h"
#import "AEBlockScheduler.h"

#import "AEBlockChannel.h"
#import "AEAudioUnitChannel.h"
#import "ViewController.h"

@implementation AppDelegate {
    AEAudioController *audioController;
    AEBlockScheduler *scheduler;
    AEAudioFilePlayer *audioFilePlayer;
    AEBlockChannel *blockChannel;
    AEBlockChannel *anotherChannel;
    AEAudioUnitChannel *sampler;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    ViewController *vc = [ViewController new];
    [self.window setRootViewController:vc];

    return YES;
}

- (void)startSequencer {
    audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]];

    NSError *audioControllerStartError = nil;
    [audioController start:&audioControllerStartError];
    if (audioControllerStartError) {
        NSLog(@"Audio controller start error: %@", audioControllerStartError.localizedDescription);
    }

    NSError *audioFilePlayerErorr;
    audioFilePlayer = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:@"guitar" withExtension:@"caf"] audioController:audioController error:&audioFilePlayerErorr];
    [audioController addChannels:@[audioFilePlayer]];
    [audioFilePlayer setRemoveUponFinish:NO];

    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(play) userInfo:nil repeats:YES];


    return;


    NSError *errorSamplerSetup = NULL;
    sampler = [[AEAudioUnitChannel alloc] initWithComponentDescription:AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_MusicDevice, kAudioUnitSubType_Sampler) audioController:audioController error:&errorSamplerSetup];

    if (errorSamplerSetup) {
        NSLog(@"Error setting up sampler: %@", errorSamplerSetup.localizedDescription);
    }

    [audioController addChannels:@[sampler]];





    return;






//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playSample) userInfo:nil repeats:YES];

//    return;

    scheduler = [[AEBlockScheduler alloc] initWithAudioController:audioController];
//    [audioController addTimingReceiver:scheduler];

    __block int blockFramesOne  = 0;
    __block int blockFramesTwo = 0;

//    [scheduler scheduleBlock:^(const AudioTimeStamp *time, UInt32 offset) {
//        // We are now on the Core Audio thread at *time*, which is *offset* frames
//        // before the time we scheduled, *timestamp*.
//
//        AEAudioFilePlayer *guitarPlayer = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:@"guitar" withExtension:@"caf"] audioController:audioController error:NULL];
//        [guitarPlayer setRemoveUponFinish:YES];
//        [audioController addChannels:@[guitarPlayer]];
//
//    }
//                      atTime:80000
//               timingContext:AEAudioTimingContextOutput
//                  identifier:@"play_guitar_sample"];

    blockChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {

        blockFramesOne++;

        printf("i have %d\n", blockFramesOne);

        if ( (int)(time->mSampleTime) % (frames*10) < 50) {
//            AEAudioFilePlayer *guitarPlayer = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:@"guitar" withExtension:@"caf"] audioController:audioController error:NULL];
//            [guitarPlayer setRemoveUponFinish:YES];
//            [audioController addChannels:@[guitarPlayer]];


        }
    }];
    [audioController addChannels:@[blockChannel]];

    anotherChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        blockFramesTwo++;
        printf("and I have %d\n", blockFramesTwo);

    }];
    [audioController addChannels:@[anotherChannel]];
}

- (IBAction)play {
    [audioFilePlayer setCurrentTime:0];
    [audioFilePlayer setChannelIsPlaying:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(stop) userInfo:nil repeats:NO];
}

- (IBAction)stop {
    [audioFilePlayer setChannelIsPlaying:NO];
}

- (void)playSample {

//    [audioFilePlayer setCurrentTime:0];
    [self play];

    return;


    SamplePlayer *guitarPlayer = [SamplePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:@"guitar" withExtension:@"caf"] audioController:audioController error:NULL];
    [guitarPlayer setRemoveUponFinish:YES];
    
    [audioController addTimingReceiver:guitarPlayer];

    [audioController addChannels:@[guitarPlayer]];
}

@end
