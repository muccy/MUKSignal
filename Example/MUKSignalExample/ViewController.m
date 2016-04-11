//
//  ViewController.m
//  MUKSignalExample
//
//  Created by Marco on 08/04/16.
//  Copyright © 2016 MeLive. All rights reserved.
//

#import "ViewController.h"
#import <MUKSignal/MUKSignal.h>

@interface ViewController ()
@property (nonatomic) IBOutlet UIStepper *stepper;
@property (nonatomic) IBOutlet UILabel *valueLabel;
@property (nonatomic) MUKSignalObservation<MUKControlActionSignal<UIStepper *> *> *stepperObservation;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.stepperObservation) {
        MUKControlActionSignal *const signal = [[MUKControlActionSignal alloc] initWithControl:self.stepper forEvents:UIControlEventValueChanged];
        
        __weak __typeof__(self) weakSelf = self;
        self.stepperObservation = [MUKSignalObservation observationWithSignal:signal token:[signal subscribe:^(UIEvent * _Nullable event)
        {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            [strongSelf updateValueLabel];
        }]];
        
        [self updateValueLabel];
    }
    else {
        [self.stepperObservation resume];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.stepperObservation suspend];
}

- (void)updateValueLabel {
    self.valueLabel.text = [NSString stringWithFormat:@"%.0f", self.stepper.value];
}

@end
