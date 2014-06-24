//
//  SamplePlayer.m
//  AmazingSequencer
//
//  Created by Ariel Elkin on 28/03/2014.
//  Copyright (c) 2014 Ariel Elkin. All rights reserved.
//

#import "SamplePlayer.h"
#import "AEAudioController.h"
#import "AEAudioFileLoaderOperation.h"

@implementation SamplePlayer

@synthesize timingReceiverCallback;
@synthesize url = _url, loop=_loop, volume=_volume, pan=_pan, channelIsPlaying=_channelIsPlaying, channelIsMuted=_channelIsMuted, removeUponFinish=_removeUponFinish, completionBlock = _completionBlock, startLoopBlock = _startLoopBlock;

//This method must return a pointer to the receiver callback function that accepts received audio.
- (AEAudioControllerTimingCallback)timingReceiverCallback {
    return timingReceiver;
}


static void timingReceiver(id                        receiver,
                           AEAudioController        *audioController,
                           const AudioTimeStamp     *time,
                           UInt32 const              frames,
                           AEAudioTimingContext      context) {

    uint64_t endTime = time->mHostTime;
}

//static OSStatus renderCallback(AEAudioFilePlayer *THIS, AEAudioController *audioController, const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
//    int32_t playhead = THIS->_playhead;
//    int32_t originalPlayhead = playhead;
//
//    if ( !THIS->_channelIsPlaying ) return noErr;
//
//    if ( !THIS->_loop && playhead == THIS->_lengthInFrames ) {
//        // Notify main thread that playback has finished
//        AEAudioControllerSendAsynchronousMessageToMainThread(audioController, notifyPlaybackStopped, &THIS, sizeof(AEAudioFilePlayer*));
//        THIS->_channelIsPlaying = NO;
//        return noErr;
//    }
//
//    // Get pointers to each buffer that we can advance
//    char *audioPtrs[audio->mNumberBuffers];
//    for ( int i=0; i<audio->mNumberBuffers; i++ ) {
//        audioPtrs[i] = audio->mBuffers[i].mData;
//    }
//
//    int bytesPerFrame = THIS->_audioDescription.mBytesPerFrame;
//    int remainingFrames = frames;
//
//    // Copy audio in contiguous chunks, wrapping around if we're looping
//    while ( remainingFrames > 0 ) {
//        // The number of frames left before the end of the audio
//        int framesToCopy = MIN(remainingFrames, THIS->_lengthInFrames - playhead);
//
//        // Fill each buffer with the audio
//        for ( int i=0; i<audio->mNumberBuffers; i++ ) {
//            memcpy(audioPtrs[i], ((char*)THIS->_audio->mBuffers[i].mData) + playhead * bytesPerFrame, framesToCopy * bytesPerFrame);
//
//            // Advance the output buffers
//            audioPtrs[i] += framesToCopy * bytesPerFrame;
//        }
//
//        // Advance playhead
//        remainingFrames -= framesToCopy;
//        playhead += framesToCopy;
//
//        if ( playhead >= THIS->_lengthInFrames ) {
//            // Reached the end of the audio - either loop, or stop
//            if ( THIS->_loop ) {
//                playhead = 0;
//                if ( THIS->_startLoopBlock ) {
//                    // Notify main thread that the loop playback has restarted
//                    AEAudioControllerSendAsynchronousMessageToMainThread(audioController, notifyLoopRestart, &THIS, sizeof(AEAudioFilePlayer*));
//                }
//            } else {
//                // Notify main thread that playback has finished
//                AEAudioControllerSendAsynchronousMessageToMainThread(audioController, notifyPlaybackStopped, &THIS, sizeof(AEAudioFilePlayer*));
//                THIS->_channelIsPlaying = NO;
//                break;
//            }
//        }
//    }
//
//    OSAtomicCompareAndSwap32(originalPlayhead, playhead, &THIS->_playhead);
//
//    return noErr;
//}

//-(AEAudioControllerRenderCallback)renderCallback {
//    return &renderCallback;
//}


@end
