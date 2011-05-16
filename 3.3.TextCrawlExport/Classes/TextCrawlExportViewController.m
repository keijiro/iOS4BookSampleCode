//
// Created by 高橋啓治郎 on 11/1/1.
// Copyright 2011 iOS 4 プログラミングブック. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "TextCrawlExportViewController.h"

@implementation TextCrawlExportViewController

@synthesize progressView;
@synthesize exportSession;
@synthesize resultLabel;

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

// コンポジションの最初のトラックを通すだけのインストラクションの作成。
- (NSArray *)makePassThroughInstructions:(AVComposition *)composition {
    // コンポジションの全時間をカバーするコンポジションインストラクションの作成。
    AVMutableVideoCompositionInstruction *inst =
    [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    inst.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration);
    
    // コンポジションの最初のビデオトラックを指定する。
    NSArray *vtracks = [composition tracksWithMediaType:AVMediaTypeVideo];
    AVMutableVideoCompositionLayerInstruction *layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:[vtracks objectAtIndex:0]];
    
    // 各単一要素を配列化して返す。
    inst.layerInstructions = [NSArray arrayWithObject:layerInst];
    return [NSArray arrayWithObject:inst];
}

// Core Animationツールの作成。
- (AVVideoCompositionCoreAnimationTool*)makeCoreAnimationTool:(CALayer *)animationLayer assetSize:(CGSize)size {
    // アセットのサイズに合わせて各レイヤーを作成。
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    // parentLayerにvideoLayerとanimationLayerをぶら下げる。
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:animationLayer];
    
    // このレイヤーツリーを使ってCore Animationツールを作成。
    return [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // アセット(video1.mov)の取得。
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *assetUrl = [bundle URLForResource:@"video1" withExtension:@"mov"];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:assetUrl options:nil];
    
    // コンポジションの初期化（先頭にアセットを挿入）。
    AVMutableComposition *composition = [AVMutableComposition composition];
    [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofAsset:asset atTime:kCMTimeZero error:nil];
    
    // エクスポートセッションの初期化。
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    self.exportSession = session;
    
    // ビデオコンポジションの初期化。
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    CGSize assetSize = asset.naturalSize;
    videoComposition.renderSize = assetSize;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    // コンポジションを単純に通すだけのインストラクション。
    videoComposition.instructions = [self makePassThroughInstructions:composition];
    
    // Core Animationツールを使ってテキストクロールを組み込む。
    CALayer *textCrawlLayer = [self makeTextCrawlLayerWithSize:assetSize];
    textCrawlLayer.geometryFlipped = YES;    // ☆
    videoComposition.animationTool = [self makeCoreAnimationTool:textCrawlLayer assetSize:assetSize];
    
    session.videoComposition = videoComposition;
    
    // 出力先（テンポラリファイル）の設定。
    NSString *filePath = NSTemporaryDirectory();
    filePath = [filePath stringByAppendingPathComponent:@"out.mov"];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    session.outputURL = [NSURL fileURLWithPath:filePath];
    session.outputFileType = AVFileTypeQuickTimeMovie;
    
    // 非同期エクスポートの開始。
	[session exportAsynchronouslyWithCompletionHandler:^{
        if (session.status == AVAssetExportSessionStatusCompleted) {
            // フォトアルバムへの書き込み。
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeVideoAtPathToSavedPhotosAlbum:session.outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                if (error) {
                    resultLabel.text =
                    [NSString stringWithFormat:@"アセット書き込み失敗\n%@", error];
                } else {
                    resultLabel.text =
                    [NSString stringWithFormat:@"完了\n%@", assetURL];
                }
            }];
            [library release];
        } else if (session.status == AVAssetExportSessionStatusCancelled) {
            resultLabel.text = @"エクスポート中断";
        } else {
            resultLabel.text = [NSString stringWithFormat:@"エクスポート失敗\n%@", session.error];
        }
    }];
    
    // プログレスバーを非同期に更新。
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        while (session.status == AVAssetExportSessionStatusExporting) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                progressView.progress = session.progress;
            });
        }
    });
}

// キャンセルボタンの押下。
- (IBAction)cancel {
    [self.exportSession cancelExport];
}

- (void)viewDidUnload {
    self.exportSession = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end
