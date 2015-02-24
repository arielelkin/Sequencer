//
//  TimedChannel.h
//  AmazingSequencer
//
//  Created by Ariel Elkin on 23/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEAudioController.h"
#import "Beat.h"

@interface TimedChannel : NSObject <AEAudioTimingReceiver>

+ (instancetype)timedChannelWithAudioFile:(NSURL *)url
                           beatsPerMinute:(double)bpm
                                 sequence:(NSMutableArray *)beats;

@property (nonatomic) UInt64 beatsPerMinute;
@property (nonatomic) NSMutableArray *beats;

@end

//Beats data type can represent beats per bar
//and resolution, rather than including
//them in constructor.

//Alternative:
//Developer must specify
//beatsPerBar:(UInt64)beatsPerBar
//resolution:(Resolution)resolution

typedef NS_ENUM(NSInteger, Resolution) {
    ResolutionQuarterNote,
    ResolutionEigthNote,
    ResolutionSixteenthNote,
    ResolutionThirtySecondNote
};

//Beat array could also be represented as:
//typedef float Beats[][2];
//so that
//Beats = {beat onset, velocity}
//but C arrays are immutable, and makes API harder to use

