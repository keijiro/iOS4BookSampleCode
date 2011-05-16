//
// Created by 高橋啓治郎 on 11/1/1.
// Copyright 2011 iOS 4 プログラミングブック. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "TextCrawlViewController.h"
#import "PlayerView.h"

@implementation TextCrawlViewController

@synthesize playerView;
@synthesize speedSlider;

// テキストクロールのレイヤーツリーの作成。
- (CALayer *)makeTextCrawlLayerWithSize:(CGSize)size {
    CGFloat height = size.height / 6;       // テキスト高さ
    CGFloat oy = size.height - height / 2;  // スクロール位置
    
    // 親レイヤーの作成。
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    // テキストレイヤーの作成。
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.bounds = CGRectMake(0, 0, size.width, height);
    textLayer.position = CGPointMake(size.width * 1.5, oy);
    textLayer.fontSize = height;
    textLayer.string = @"Core Animation Test";
    [parentLayer addSublayer:textLayer];
    
    // 右から左へスクロールするアニメーション（４秒でスクロールアウト）。
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
    anim.fromValue = [NSValue valueWithCGPoint:textLayer.position];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(size.width / -2, oy)];
    anim.duration = 4;
    anim.beginTime = AVCoreAnimationBeginTimeAtZero;  // ☆
    anim.removedOnCompletion = NO;                    // ☆
    [textLayer addAnimation:anim forKey:nil];
    
    return parentLayer;
}

// 指定されたプレイヤーアイテムと同期する同期レイヤーの作成。
- (AVSynchronizedLayer *)makeSynchronizedLayer:(AVPlayerItem *)playerItem withParentLayer:(CALayer *)playerLayer {
    // 同期レイヤーの作成。
    AVSynchronizedLayer *syncLayer = [AVSynchronizedLayer synchronizedLayerWithPlayerItem:playerItem];
    
    // boundsをアセットの大きさに合わせる。
    CGSize assetSize = playerItem.asset.naturalSize;
    syncLayer.bounds = CGRectMake(0, 0, assetSize.width, assetSize.height);
    
    // ポジションをプレイヤーの中心と合わせる。
    CGSize playerSize = playerLayer.bounds.size;
    syncLayer.position = CGPointMake(playerSize.width / 2, playerSize.height / 2);
    
    // プレイヤーの狭い方の幅に合わせてスケールをかける。
    CGFloat scale = fmin(playerSize.width / assetSize.width, playerSize.height / assetSize.height);
    syncLayer.transform = CATransform3DMakeScale(scale, scale, 1);
    
    // プレイヤーのサブレイヤーとする。
    [playerLayer addSublayer:syncLayer];
    
    return syncLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // アセット(video1.mov)と、それに対応するプレイヤーアイテムの初期化。
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *assetUrl = [bundle URLForResource:@"video1" withExtension:@"mov"];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:assetUrl options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    // playerItemと同期する同期レイヤーをplayerViewのサブレイヤーとして作成する。
    CALayer *syncLayer = [self makeSynchronizedLayer:playerItem withParentLayer:self.playerView.layer];
    
    // テキストクロールを作成して同期レイヤーのサブレイヤーとする。
    [syncLayer addSublayer:[self makeTextCrawlLayerWithSize:asset.naturalSize]];
    
    // プレイヤーアイテムの再生を開始する。
    self.playerView.player = [AVPlayer playerWithPlayerItem:playerItem];
    [self.playerView.player play];
}

// 巻き戻しボタンの押下。
- (IBAction)rewind:(id)sender {
    [self.playerView.player seekToTime:kCMTimeZero];
    [self.playerView.player play];
    self.playerView.player.rate = self.speedSlider.value;
}

// スピードバーの変更。
- (IBAction)changeSpeed:(UISlider*)sender {
    self.playerView.player.rate = sender.value;
}

- (void)dealloc {
    [super dealloc];
}

@end
