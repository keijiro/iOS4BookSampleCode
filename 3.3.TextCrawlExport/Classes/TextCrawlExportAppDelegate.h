//
// Created by 高橋啓治郎 on 11/1/1.
// Copyright 2011 iOS 4 プログラミングブック. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextCrawlExportViewController;

@interface TextCrawlExportAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TextCrawlExportViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TextCrawlExportViewController *viewController;

@end

