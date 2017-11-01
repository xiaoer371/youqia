//
//  MCAdEventView.h
//  NPushMail
//
//  Created by swhl on 17/1/12.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+MCExpand.h"

typedef enum : NSUInteger {
    MCAdEventTypeDefault = 0,
    MCAdEventTypeFeiBa,
    MCAdEventTypeOther,
} MCAdEventType;

@protocol MCAdEventViewDelegate <NSObject>

- (void)didSelectADEventType:(MCAdEventType)type;

@end

@interface MCAdEventView : UIView

@property (nonatomic,weak) id<MCAdEventViewDelegate> delegate;

+ (MCAdEventView *)showWithAdEventType:(MCAdEventType)type;

@end


