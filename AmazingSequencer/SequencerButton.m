//
//  SequencerButton.m
//  AmazingSequencer
//
//  Created by Ariel Elkin on 16/03/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import "SequencerButton.h"

@implementation SequencerButton {
    NSMutableSet *activeDivisions;
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

        activeDivisions = [NSMutableSet set];

        self.isActive = NO;

        self.divisions = 4;
    }
    return self;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    NSLog(@"p is %.2f, %.2f", p.x, p.y);

    self.divisions = p.y/self.bounds.size.width * 10;
    NSLog(@"divisions: %lud", self.divisions);
    [self setNeedsDisplay];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    self.isActive = !self.isActive;

    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    long division = (long)p.x / ((long)self.bounds.size.width/self.divisions);
    NSLog(@"division: %lu", division);

    if ([activeDivisions containsObject:@(division)]){
        [activeDivisions removeObject:@(division)];
    }
    else {
        [activeDivisions addObject:@(division)];
    }

    [self.delegate tappedButton:self];

    [self setNeedsDisplay];
}

- (void)makeDivisions {
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);

    for (int i = 0; i < self.divisions; i++) {
        // Draw them with a 2.0 stroke width so they are a bit more visible.
        CGContextSetLineWidth(context, 2.0f);

        CGContextMoveToPoint(context, i * self.bounds.size.width/self.divisions, 0.0f); //start at this point

        CGContextAddLineToPoint(context, i * self.bounds.size.width/self.divisions, self.bounds.size.height); //draw to this point

        if ([activeDivisions containsObject:@(i)]) {
            CGRect rect = CGRectMake(i *self.bounds.size.width/self.divisions, 0, self.bounds.size.width/self.divisions, self.bounds.size.height);
            CGContextFillRect(context, rect);
            CGContextStrokeRect(context, rect);
        }

        // and now draw the Path!
        CGContextStrokePath(context);

    }
}

@end
