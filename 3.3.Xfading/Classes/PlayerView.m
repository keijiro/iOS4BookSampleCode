//
// Created by 高橋啓治郎 on 11/1/1.
// Copyright 2011 iOS 4 プログラミングブック. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"

@implementation PlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end
