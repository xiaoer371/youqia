//
//  MCFileEditingView.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/16.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MCFileEditType) {
    MCFileEditSendMsg = 0,
    MCFileEditForMailAttachment,
    MCFileEditDelete
};


@protocol MCFileEditSelectedDelegate <NSObject>

- (void)fileEditDidSelectOption:(MCFileEditType)type;

@end

@interface MCFileEditingView : UIView

@property (nonatomic,weak)id<MCFileEditSelectedDelegate>delegate;
@property (nonatomic,strong) NSMutableArray *titles;
- (void)show:(BOOL)show;
- (void)setBtnEnable:(BOOL)enableFlag;

@end
