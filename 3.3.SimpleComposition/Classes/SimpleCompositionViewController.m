//
//  Created by 高橋啓治郎 on 11/1/1.
//  Copyright 2011 iOS 4 プログラミングブック. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SimpleCompositionViewController.h"
#import "PlayerView.h"

@implementation SimpleCompositionViewController

@synthesize playerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // アセット(video1.mov, video2.mov)の取得。
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *asset1Url = [bundle URLForResource:@"video1" withExtension:@"mov"];
    NSURL *asset2Url = [bundle URLForResource:@"video2" withExtension:@"mov"];
    AVURLAsset *asset1 = [AVURLAsset URLAssetWithURL:asset1Url options:nil];
    AVURLAsset *asset2 = [AVURLAsset URLAssetWithURL:asset2Url options:nil];
    
    // コンポジションの作成。
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    // アセット１の0"-4"部分をコンポジションの先頭に挿入。
    CMTimeRange range1 = CMTimeRangeMake(kCMTimeZero, CMTimeMake(4, 1));
    [composition insertTimeRange:range1 ofAsset:asset1 atTime:kCMTimeZero error:nil];
    
    // アセット２の4"-6"部分をコンポジションの2"に挿入。
    CMTimeRange range2 = CMTimeRangeMake(CMTimeMake(4, 1), CMTimeMake(2, 1));
    [composition insertTimeRange:range2 ofAsset:asset2 atTime:CMTimeMake(2, 1) error:nil];
    
    // コンポジションをアセットとしてプレイヤーアイテムを作成。
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:composition];
    
    // プレイヤービューで再生を開始。
    self.playerView.player = [AVPlayer playerWithPlayerItem:playerItem];
    [self.playerView.player play];
}

// 巻き戻しボタンの押下。
- (IBAction)rewind:(id)sender {
    [self.playerView.player seekToTime:kCMTimeZero];
    [self.playerView.player play];
}

- (void)dealloc {
    [super dealloc];
}

@end
