//
//  MJRefreshGifHeader+style.m
//  NPushMail
//
//  Created by zhang on 16/4/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MJRefreshGifHeader+style.h"

@implementation MJRefreshGifHeader(style)

- (void)mcRefreshGifStyle {
    NSArray* images = AppStatus.theme.mailStyle.mcRefreshImages;
//    [self setImages:images duration: 1.0 forState:MJRefreshStateIdle];
    [self setImages:images duration: 1.0 forState:MJRefreshStatePulling];
//    [self setImages:images duration: 1.0 forState:MJRefreshStateRefreshing];
    self.mj_h = 50.0;
    self.lastUpdatedTimeLabel.hidden = YES;
    self.stateLabel.hidden = YES;
}
@end
