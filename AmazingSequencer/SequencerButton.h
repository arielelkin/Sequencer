//
//  SequencerButton.h
//  AmazingSequencer
//
//  Created by Ariel Elkin on 16/03/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SequencerButtonDelegate <NSObject>
-(void)tappedButton:(id)button;
@end

@interface SequencerButton : UIView

+(instancetype)buttonWithRow:(NSUInteger)row column:(NSUInteger)column;

@property id<SequencerButtonDelegate> delegate;

@property NSUInteger row;
@property NSUInteger column;
@property BOOL isActive;
@property NSUInteger divisions;

@end
