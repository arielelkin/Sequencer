//
//  MyChannel.m
//  AmazingSequencer
//
//  Created by Ariel Elkin on 25/06/2014.
//  Copyright (c) 2014 Ariel Elkin. All rights reserved.
//

#import "MyChannel.h"
#import "AEAudioFileLoaderOperation.h"

@implementation MyChannel {
    AudioBufferList *audioSampleBufferList;
    UInt32 lengthInFrames;

    bool shouldPlay;
}

+ (instancetype)repeatingAudioFileAt:(NSURL *)url audioController:(AEAudioController*)audioController repeatAtBPM:(UInt64)bpm {

    MyChannel *channel = [[self alloc] init];

    AEAudioFileLoaderOperation *operation = [[AEAudioFileLoaderOperation alloc] initWithFileURL:url targetAudioDescription:audioController.audioDescription];
    [operation start];
    if ( operation.error ) {
        NSLog(@"load error: %@", operation.error);
        return nil;
    }

    channel->audioSampleBufferList = operation.bufferList;
    channel->lengthInFrames = operation.lengthInFrames;

    return channel;
}

static OSStatus renderCallback(__unsafe_unretained MyChannel *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp *time,
                               UInt32 frames,
                               AudioBufferList *audio) {
    static UInt32 playHead;

    if (!THIS->shouldPlay) {
        playHead = 0;
        return noErr;
    }

    for (int i=0; i<frames; i++) {

        for ( int j=0; j<audio->mNumberBuffers; j++ ) {

            bool shouldLoop = true;

            if (playHead < THIS->lengthInFrames) {
                ((float *)audio->mBuffers[j].mData)[i] = ((float *)THIS->audioSampleBufferList->mBuffers[j].mData)[playHead + i];
            }
            else if (shouldLoop) {
                playHead = 0;
            }
            else {
                ((float *)audio->mBuffers[j].mData)[i] = 0;
            }
        }
    }

    playHead += frames;

    return noErr;
}

- (void)play {
    shouldPlay = true;
}
- (void)stop {
    shouldPlay = false;
}


-(AEAudioControllerRenderCallback)renderCallback {
    return &renderCallback;
}

@end
