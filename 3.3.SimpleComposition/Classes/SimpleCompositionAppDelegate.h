//
//  Created by 高橋啓治郎 on 11/1/1.
//  Copyright 2011 iOS 4 プログラミングブック. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SimpleCompositionViewController;

@interface SimpleCompositionAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SimpleCompositionViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SimpleCompositionViewController *viewController;

@end

