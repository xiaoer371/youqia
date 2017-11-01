//
//  MCFeaturesGuideHelper.h
//  NPushMail
//
//  Created by wuwenyu on 16/8/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  引导类型
 */
typedef NS_ENUM(NSInteger, MCFeaturesGuideType) {
    /**
     *  邮件列表页引导
     */
    MCFeaturesGuideMailList  = 0,
    /**
     *  邮件详情-再次编辑引导
     */
    MCFeaturesGuideMailDetailEditAgain
};

@interface MCFeaturesGuideHelper : UIView

- (id)initWithFrame:(CGRect)frame mailListCellRect:(CGRect)cellRect importantMailRect:(CGRect)importantRect guideType:(MCFeaturesGuideType)type;
- (void)show;
- (void)dismissWindow;

@end
