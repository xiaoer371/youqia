//
//  MCMailStyle.m
//  NPushMail
//
//  Created by zhang on 16/3/14.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMailStyle.h"

@implementation MCMailStyle

- (NSArray*)mcRefreshImages {
    
    if (!_mcRefreshImages) {
        NSMutableArray *array = [NSMutableArray new];
        for (int i = 1; i < 62; i ++) {
            NSString *imageName = [NSString stringWithFormat:@"mc_refreshImage%d.png",i];
            UIImage *image =[UIImage imageNamed:imageName];
            [array addObject:image];
        }
        _mcRefreshImages = array;
    }
    return _mcRefreshImages;
}

@end
