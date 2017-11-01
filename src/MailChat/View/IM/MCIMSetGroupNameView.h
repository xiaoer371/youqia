//
//  MCIMSetGroupNameView.h
//  NPushMail
//
//  Created by swhl on 16/4/20.
//  Copyright © 2016年 sprite. All rights reserved.
//

typedef void(^sureBlock)(NSString * groupName);
typedef void(^cancelBlock)(void);

#import <UIKit/UIKit.h>

@interface MCIMSetGroupNameView : UIView

@property (nonatomic,copy)sureBlock sureBlock;
@property (nonatomic,copy)cancelBlock cancelBlock;
@property (nonatomic,strong) UITextField *groupName;


-(instancetype)initWithFrame:(CGRect)frame
                    withSure:(sureBlock)sureBlock
                  withCancel:(cancelBlock)cancelBlock;


@end
