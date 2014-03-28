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

@implementation AppDelegate {
    AEAudioController *audioController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    [self startSequencer];

    return YES;
}

- (void)startSequencer {
    audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]];

    NSError *audioControllerStartError = nil;
    [audioController start:&audioControllerStartError];
    if (audioControllerStartError) {
        NSLog(@"Audio controller start error: %@", audioControllerStartError.localizedDescription);
    }
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playSample) userInfo:nil repeats:YES];
}

- (void)playSample {
    AEAudioFilePlayer *guitarPlayer = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:@"guitar" withExtension:@"caf"] audioController:audioController error:NULL];
    [guitarPlayer setRemoveUponFinish:YES];
    [audioController addChannels:@[guitarPlayer]];
}

@end
