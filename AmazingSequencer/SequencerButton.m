//
//  SequencerButton.m
//  The Amazing Audio Engine
//
//  Created by Ariel Elkin on 16/03/2015.
//

#import "SequencerButton.h"

@implementation SequencerButton

+ (instancetype)buttonWithRow:(NSUInteger)row column:(NSUInteger)column {
    SequencerButton *sequencerButton = [[self alloc] init];
    sequencerButton.row = row;
    sequencerButton.column = column;
    return sequencerButton;
}

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 3;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    self.isActive = !self.isActive;

    if (self.isActive) {
        self.backgroundColor = [UIColor orangeColor];
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
    }

    [self.delegate tappedButton:self];
}

@end
