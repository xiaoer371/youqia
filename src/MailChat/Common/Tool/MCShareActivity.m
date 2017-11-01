//
//  MCShareActivity.m
//  NPushMail
//
//  Created by swhl on 16/12/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCShareActivity.h"

@implementation MCShareActivity

- (instancetype)initWithImage:(UIImage *)shareImage
                        atURL:(NSURL *)URL
                      atTitle:(NSString *)title
          atShareContentArray:(NSArray *)shareContentArray {
    if (self = [super init]) {
        _shareImage = shareImage;
        _URL = URL;
        _title = title;
        _shareContentArray = shareContentArray;
    }
    return self;
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    return nil;
}

- (NSString *)activityTitle {
    return _title;
}

- (UIImage *)activityImage {
    return _shareImage;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (UIViewController *)activityViewController {
    return nil;
}

- (void)performActivity {
    if (nil == _title) {
        return;
    }
    
    DDLogVerbose(@"%@", _shareContentArray);
    DDLogVerbose(@"%@", _title);
    
    [self activityDidFinish:YES];//默认调用传递NO
}

- (void)activityDidFinish:(BOOL)completed {
    if (completed) {
        DDLogVerbose(@"%s", __func__);
    }
}

@end
