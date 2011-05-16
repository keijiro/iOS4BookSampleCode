//
// Created by 高橋啓治郎 on 11/1/1.
// Copyright 2011 iOS 4 プログラミングブック. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVAssetExportSession;

@interface TextCrawlExportViewController : UIViewController;

@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UILabel *resultLabel;
@property (nonatomic, retain) AVAssetExportSession *exportSession;

- (IBAction)cancel;

@end

