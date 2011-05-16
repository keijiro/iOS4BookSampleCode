//
//  Created by 高橋啓治郎 on 11/1/1.
//  Copyright 2011 iOS 4 プログラミングブック. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SimpleExportViewController.h"

@implementation SimpleExportViewController

@synthesize progressView;
@synthesize resultLabel;
@synthesize exportSession;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // アセット(video1.mov, video2.mov)の取得。
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *asset1Url = [bundle URLForResource:@"video1" withExtension:@"mov"];
    NSURL *asset2Url = [bundle URLForResource:@"video2" withExtension:@"mov"];
    AVURLAsset *asset1 = [AVURLAsset URLAssetWithURL:asset1Url options:nil];
    AVURLAsset *asset2 = [AVURLAsset URLAssetWithURL:asset2Url options:nil];
    
    // コンポジションの初期化。
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    // アセット１の0"-4"部分をコンポジションの先頭に挿入。
    CMTimeRange range1 = CMTimeRangeMake(kCMTimeZero, CMTimeMake(4, 1));
    [composition insertTimeRange:range1 ofAsset:asset1 atTime:kCMTimeZero error:nil];
    
    // アセット２の4"-6"部分をコンポジションの2"に挿入。
    CMTimeRange range2 = CMTimeRangeMake(CMTimeMake(4, 1), CMTimeMake(2, 1));
    [composition insertTimeRange:range2 ofAsset:asset2 atTime:CMTimeMake(2, 1) error:nil];
    
    // エクスポートセッションの作成。
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    self.exportSession = session;
    
    // 出力先（テンポラリファイル）の設定。
    NSString *filePath = NSTemporaryDirectory();
    filePath = [filePath stringByAppendingPathComponent:@"out.mov"];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    session.outputURL = [NSURL fileURLWithPath:filePath];
    
    // 出力タイプの設定。
    session.outputFileType = AVFileTypeQuickTimeMovie;
    
    // 非同期エクスポートの開始。
	[session exportAsynchronouslyWithCompletionHandler:^{
        if (session.status == AVAssetExportSessionStatusCompleted) {
            // フォトアルバムへの書き込み。
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeVideoAtPathToSavedPhotosAlbum:session.outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                if (error) {
                    self.resultLabel.text = [NSString stringWithFormat:@"アセット書き込み失敗\n%@", error];
                } else {
                    self.resultLabel.text = [NSString stringWithFormat:@"完了\n%@", assetURL];
                }
            }];
            [library autorelease];
        } else if (session.status == AVAssetExportSessionStatusCancelled) {
            self.resultLabel.text = @"エクスポート中断";
        } else {
            self.resultLabel.text = [NSString stringWithFormat:@"エクスポート失敗\n%@", session.error];
        }
    }];
    
    // プログレスバーを非同期に更新。
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        while (session.status == AVAssetExportSessionStatusExporting) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.progressView.progress = session.progress;
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
