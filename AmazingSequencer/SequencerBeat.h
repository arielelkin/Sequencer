//
//  Beat.h
//  AmazingSequencer
//
//  Created by Ariel Elkin on 24/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SequencerBeat : NSObject

+ (instancetype)beatWithOnset:(double)onset
                     velocity:(double)velocity;

+ (instancetype)beatWithOnset:(double)onset;

@property (nonatomic) double onset;
@property (nonatomic) double velocity;

@end