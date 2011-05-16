//
// Created by 高橋啓治郎 on 11/1/1.
// Copyright 2011 iOS 4 プログラミングブック. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerView;

@interface XfadingViewController : UIViewController;

@property (nonatomic, retain) IBOutlet PlayerView *playerView;

- (IBAction)rewind:(id)sender;

@end

