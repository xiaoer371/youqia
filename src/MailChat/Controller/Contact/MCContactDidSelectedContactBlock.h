//
//  MCContactDidSelectedContactBlock.h
//  NPushMail
//
//  Created by wuwenyu on 16/4/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#ifndef MCContactDidSelectedContactBlock_h
#define MCContactDidSelectedContactBlock_h

/**
 *  点击联系人回调方法
 *
 *  @param model 点击的联系人Model
 *  @param index 点击哪一行
 *  @param ctrl  目标跳转页面
 */
typedef void (^ContactDidSelectedBlock)(id model, NSIndexPath *index, id ctrl);

#endif /* MCContactDidSelectedContactBlock_h */
