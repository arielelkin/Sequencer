//
//  SequencerButton.m
//  AmazingSequencer
//
//  Created by Ariel Elkin on 16/03/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import "SequencerButton.h"

@implementation SequencerButton {
    NSUInteger divisions;
    UIRotationGestureRecognizer *gestureRecognizer;
}

+(instancetype)buttonWithRow:(NSUInteger)row column:(NSUInteger)column {
    SequencerButton *sequencerButton = [[self alloc] init];
    sequencerButton.row = row;
    sequencerButton.column = column;
    return sequencerButton;
}

- (id)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 3;

        gestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotated:)];
        [self addGestureRecognizer:gestureRecognizer];

        self.isActive = NO;

        divisions = 4;
    }
    return self;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    CGPoint p = [touch locationInView:self];
//    NSLog(@"p is %.2f, %.2f", p.x, p.y);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    self.isActive = !self.isActive;

    if (self.isActive) {
        self.backgroundColor = [UIColor orangeColor];
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
    }

    [self.delegate tappedButton:self];
}

-(void)rotated:(UIRotationGestureRecognizer *)gesture{
    NSLog(@"gesture: %.2f", gesture.rotation);
//    NSLog(@"rotation: %.2f", ((gesture.rotation)/M_PI) * 20);
    CGFloat result = gesture.rotation/M_PI * 20;
    NSLog(@"result: %.2f", result);

    divisions = (NSUInteger)round(result); //* 20.0 ;
//
//    divisions = divisions + rotations;
//    NSLog(@"gesture.rotation/pi: %.2f, %.2f", gesture.rotation, gesture.rotation/M_PI);
//    
    NSLog(@"divisions: %lu", divisions);


//    [self setNeedsDisplay];
}

- (void)makeDivisions {
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);

    for (int i = 0; i < divisions; i++) {
        // Draw them with a 2.0 stroke width so they are a bit more visible.
        CGContextSetLineWidth(context, 2.0f);

        CGContextMoveToPoint(context, i * self.bounds.size.width/divisions, 0.0f); //start at this point

        CGContextAddLineToPoint(context, i * self.bounds.size.width/divisions, self.bounds.size.height); //draw to this point

        // and now draw the Path!
        CGContextStrokePath(context);

    }
}

@end
