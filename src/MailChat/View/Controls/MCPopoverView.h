//
//  MCPopoverView.h
//  NPushMail
//
//  Created by zhang on 16/5/6.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^MCPopoverBlock)(NSInteger index);

typedef NS_ENUM(NSInteger,MCPopoverViewStyle) {
    MCPopoverViewStyleUp = 0,
    MCPopoverViewStyleDown
};


@interface MCPopoverView : UIView
// 菜单列表集合
@property (nonatomic, copy) NSArray *menuTitles;

@property (nonatomic, copy)dispatch_block_t dissmissCallBack;

/*!
 *  @author lifution
 *
 *  @brief 显示弹窗
 *
 *  @param point    箭头指向的坐标
 *  @param selected 选择完成回调
 */

- (void)showFromPoint:(CGPoint)point popoverViewStyle:(MCPopoverViewStyle)popoverViewStyle  selected:(MCPopoverBlock)selected;

@end

@interface MCArrow : UIView

@end
