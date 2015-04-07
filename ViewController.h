//
//  ViewController.h
//  The Amazing Audio Engine
//
//  Created by Ariel Elkin on 01/04/2014.
//  Copyright (c) 2014 Ariel Elkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISlider *mainVolumeSlider;
@property (strong, nonatomic) IBOutlet UISlider *bpmSlider;
@property (strong, nonatomic) IBOutlet UILabel *bpmLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *playheadPositionOfKickSequence;

@end
