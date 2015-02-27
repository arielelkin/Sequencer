//
//  Beat.h
//  AmazingSequencer
//
//  Created by Ariel Elkin on 24/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SequencerBeat : NSObject

+ (instancetype)beatWithOnset:(float)onset
                     velocity:(float)velocity;

+ (instancetype)beatWithOnset:(float)onset;

@property (nonatomic) float onset;
@property (nonatomic) float velocity;

@end