//
//  MCAliSysHelperModel.h
//  NPushMail
//
//  Created by swhl on 16/12/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAliSysBaseModel.h"

@interface MCAliSysHelperModel : MCAliSysBaseModel

/**
  * From user id，请教小助手时候还没登录，此id一般为设备id
 */
@property (nonatomic, strong) NSString  *fromId;

/**
 平台信息 (ios, android, windows, osx )
 */
@property (nonatomic, strong) NSString  *platform;


/**
 版本号
 */
@property (nonatomic, strong) NSString  *version;

@end
