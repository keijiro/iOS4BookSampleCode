//
// Created by 高橋啓治郎 on 11/1/1.
// Copyright 2011 iOS 4 プログラミングブック. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerView;

@interface TextCrawlViewController : UIViewController;

@property (nonatomic, retain) IBOutlet PlayerView *playerView;
@property (nonatomic, retain) IBOutlet UISlider *speedSlider;

- (IBAction)rewind:(id)sender;
- (IBAction)changeSpeed:(UISlider *)sender;

@end

