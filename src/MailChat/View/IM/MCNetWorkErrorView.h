//
//  MCNetWorkErrorView.h
//  NPushMail
//
//  Created by swhl on 16/1/20.
//  Copyright © 2016年 sprite. All rights reserved.
//

//====== 提示 网络连接错误 的view =======

typedef enum : NSUInteger {
    IMNoticeTypeNetError = 0,
    IMNoticeTypeWindowOnLine,
} IMNoticeType;

//点击整个View 回调
typedef void(^actionViewBlock)(IMNoticeType);

#import <UIKit/UIKit.h>

@interface MCNetWorkErrorView : UIView{
    
}

@property (nonatomic,copy) actionViewBlock actionBlock;

/**
 *  初始化View 带点击view回调
 *  @param frame           frame
 *  @param clickViewAction 回调
 *  @return view
 */
-(instancetype)initWithFrame:(CGRect)frame
                   actionViewBlock:(actionViewBlock)actionBlock;

-(instancetype)initWithFrame:(CGRect)frame
             actionViewBlock:(actionViewBlock)actionBlock
                  noticeType:(IMNoticeType)type;



@end
