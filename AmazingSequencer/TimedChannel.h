//
//  TimedChannel.h
//  AmazingSequencer
//
//  Created by Ariel Elkin on 23/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEAudioController.h"

@interface TimedChannel : NSObject <AEAudioTimingReceiver>

+ (instancetype)repeatAtTime:(float)time;

@end
