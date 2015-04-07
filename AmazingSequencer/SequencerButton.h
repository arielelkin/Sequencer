//
//  SequencerButton.h
//  The Amazing Audio Engine
//
//  Created by Ariel Elkin on 16/03/2015.
//

#import <UIKit/UIKit.h>

@protocol SequencerButtonDelegate <NSObject>
- (void)tappedButton:(id)button;
@end

@interface SequencerButton : UIView

+(instancetype)buttonWithRow:(NSUInteger)row column:(NSUInteger)column;

@property id<SequencerButtonDelegate> delegate;

@property NSUInteger row;
@property NSUInteger column;
@property BOOL isActive;

@end
