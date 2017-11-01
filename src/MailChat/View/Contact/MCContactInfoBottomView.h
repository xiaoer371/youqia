//
//  MCContactInfoBottomView.h
//  NPushMail
//
//  Created by wuwenyu on 16/2/3.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^writeMailAction)(void);
typedef void (^sendMsgAction)(void);

@interface MCContactInfoBottomView : UIView

@property (nonatomic, copy) writeMailAction writeMailBlock;
@property (nonatomic, copy) sendMsgAction sendMsgBlock;

@end
