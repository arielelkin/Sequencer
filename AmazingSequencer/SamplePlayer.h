//
//  SamplePlayer.h
//  AmazingSequencer
//
//  Created by Ariel Elkin on 28/03/2014.
//  Copyright (c) 2014 Ariel Elkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEAudioFilePlayer.h"

@interface SamplePlayer : AEAudioFilePlayer <AEAudioTimingReceiver>

-(AEAudioControllerTimingCallback)timingReceiverCallback;

@end
