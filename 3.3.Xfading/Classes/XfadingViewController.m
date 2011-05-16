//
// Created by 高橋啓治郎 on 11/1/1.
// Copyright 2011 iOS 4 プログラミングブック. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "XfadingViewController.h"
#import "PlayerView.h"

@implementation XfadingViewController

@synthesize playerView;

// ビデオトラックをフェードイン＆アウトするレイヤーインストラクションの作成。
- (AVVideoCompositionLayerInstruction *)makeFadeVideoTrack:(AVAssetTrack *)track startTime:(CMTime)startTime endTime:(CMTime)endTime fadeDuration:(CMTime)fadeDuration {
    // 指定されたビデオトラックに対応するレイヤーインストラクションの作成。
    AVMutableVideoCompositionLayerInstruction *layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:track];

    // フェードインの設定。
    CMTimeRange timeRangeIn = CMTimeRangeMake(startTime, fadeDuration);
    [layerInst setOpacityRampFromStartOpacity:0 toEndOpacity:1 timeRange:timeRangeIn];
    
    // フェードアウトの設定。
    CMTimeRange timeRangeOut = CMTimeRangeMake(CMTimeSubtract(endTime, fadeDuration), fadeDuration);
    [layerInst setOpacityRampFromStartOpacity:1 toEndOpacity:0 timeRange:timeRangeOut];  

    return layerInst;
}

// オーディオトラックをフェードイン＆アウトするオーディオ入力パラメータの作成。
- (AVAudioMixInputParameters *)makeFadesAudioTrack:(AVAssetTrack *)track startTime:(CMTime)startTime endTime:(CMTime)endTime fadeDuration:(CMTime)fadeDuration {
    // 指定されたオーディオトラックに対応するオーディオ入力パラメータの作成。
    AVMutableAudioMixInputParameters *params = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    
    // フェードインの設定。
    CMTimeRange timeRangeIn = CMTimeRangeMake(startTime, fadeDuration);
    [params setVolumeRampFromStartVolume:0 toEndVolume:1 timeRange:timeRangeIn];
    
    // フェードアウトの設定。
    CMTimeRange timeRangeOut = CMTimeRangeMake(CMTimeSubtract(endTime, fadeDuration), fadeDuration);
    [params setVolumeRampFromStartVolume:1 toEndVolume:0 timeRange:timeRangeOut];
    
    return params;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // アセット(video1.mov, video2.mov)の取得。
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *asset1Url = [bundle URLForResource:@"video1" withExtension:@"mov"];
    NSURL *asset2Url = [bundle URLForResource:@"video2" withExtension:@"mov"];
    AVURLAsset *asset1 = [AVURLAsset URLAssetWithURL:asset1Url options:nil];
    AVURLAsset *asset2 = [AVURLAsset URLAssetWithURL:asset2Url options:nil];
    
    // 各アセットからビデオ／オーディオトラックを取得。
    AVAssetTrack *asset1VideoTrack = [[asset1 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVAssetTrack *asset1AudioTrack = [[asset1 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    AVAssetTrack *asset2VideoTrack = [[asset2 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVAssetTrack *asset2AudioTrack = [[asset2 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    // フェード時間。
    CMTime fadeDuration = CMTimeMakeWithSeconds(1.5f, 1);
    // クロスフェーディング開始時間の算出。
    CMTime timeStartXfading = CMTimeSubtract(asset1.duration, fadeDuration);
    // コンポジション全体の終了時間の算出。
    CMTime timeEndComposition = CMTimeAdd(timeStartXfading, asset2.duration);
    
    // コンポジションの作成。
    AVMutableComposition *composition = [AVMutableComposition composition];
    // コンポジション内にビデオトラック1およびオーディオトラック1を作成。
    AVMutableCompositionTrack *videoTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    // コンポジション内にビデオトラック2およびオーディオトラック2を作成。
    AVMutableCompositionTrack *videoTrack2 = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack2 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // アセット1をトラック1の先頭に挿入。
    [videoTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset1.duration) ofTrack:asset1VideoTrack atTime:kCMTimeZero error:nil];
    [audioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset1.duration) ofTrack:asset1AudioTrack atTime:kCMTimeZero error:nil];
    // アセット2をトラック2のクロスフェーディング開始位置に挿入。
    [videoTrack2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset2.duration) ofTrack:asset2VideoTrack atTime:timeStartXfading error:nil];
    [audioTrack2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset2.duration) ofTrack:asset2AudioTrack atTime:timeStartXfading error:nil];
    
    // ビデオトラック1のフェード設定。
    AVVideoCompositionLayerInstruction *videoTrack1LayerInst = [self makeFadeVideoTrack:videoTrack1 startTime:kCMTimeZero endTime:asset1.duration fadeDuration:fadeDuration];
    // オーディオトラック1のフェード設定。
    AVAudioMixInputParameters *audioTrack1Params = [self makeFadesAudioTrack:audioTrack1 startTime:kCMTimeZero endTime:asset1.duration fadeDuration:fadeDuration];

    // ビデオトラック2のフェード設定。
    AVVideoCompositionLayerInstruction *videoTrack2LayerInst = [self makeFadeVideoTrack:videoTrack2 startTime:timeStartXfading endTime:timeEndComposition fadeDuration:fadeDuration];
    // オーディオトラック2のフェード設定。
    AVAudioMixInputParameters *audioTrack2Params = [self makeFadesAudioTrack:audioTrack2 startTime:timeStartXfading endTime:timeEndComposition fadeDuration:fadeDuration];
    
    // ビデオコンポジションインストラクションの作成。
    AVMutableVideoCompositionInstruction *videoCompoInst = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoCompoInst.layerInstructions = [NSArray arrayWithObjects:videoTrack1LayerInst, videoTrack2LayerInst, nil];
    videoCompoInst.timeRange = CMTimeRangeMake(kCMTimeZero, timeEndComposition);
    
    // ビデオコンポジションの作成。
    AVMutableVideoComposition *videoCompo = [AVMutableVideoComposition videoComposition];
    videoCompo.frameDuration = CMTimeMake(1, 30);
    videoCompo.renderSize = [asset1 naturalSize];
    videoCompo.instructions = [NSArray arrayWithObject:videoCompoInst];
    
    // オーディオミックスの作成。
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = [NSArray arrayWithObjects:audioTrack1Params, audioTrack2Params, nil];
    
    // コンポジションをアセットとしてプレイヤーアイテムを作成。
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:composition];
    playerItem.videoComposition = videoCompo;
    playerItem.audioMix = audioMix;
    
    // プレイヤービュー上で再生を開始。
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
