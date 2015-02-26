//
//  SequencerChannel2.m
//  AmazingSequencer
//
//  Created by Alejandro Santander on 26/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import "SequencerChannel2.h"
#import "AEAudioFileLoaderOperation.h"

/*
 NOTES:
 This is as SequencerChannel2 but uses clock ticks instead of frames for timing.
 */
@implementation SequencerChannel2 {
    AudioBufferList *audioSampleBufferList;
    UInt32 lengthInFrames;
}

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url audioController:(AEAudioController*)audioController repeatAtBPM:(UInt64)bpm {
    
    SequencerChannel2 *channel = [[self alloc] init];
    
    //Load audio file:
    AEAudioFileLoaderOperation *operation = [[AEAudioFileLoaderOperation alloc] initWithFileURL:url targetAudioDescription:audioController.audioDescription];
    [operation start];
    if ( operation.error ) {
        NSLog(@"load error: %@", operation.error);
        return nil;
    }
    channel->audioSampleBufferList = operation.bufferList;
    channel->lengthInFrames = operation.lengthInFrames;
    NSLog(@"sample length in frames: %d", (unsigned int)operation.lengthInFrames);
    
    
    
    return channel;
}

static OSStatus renderCallback(__unsafe_unretained SequencerChannel2 *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 frames,
                               AudioBufferList *audio) {
    
    NSLog(@"renderCallback() --------------------");
    
    
    
    return noErr;
}

-(AEAudioControllerRenderCallback)renderCallback {
    return &renderCallback;
}

@end


















