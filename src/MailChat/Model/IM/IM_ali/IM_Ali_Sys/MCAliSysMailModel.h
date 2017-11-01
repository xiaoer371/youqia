//
//  MCAliSysMailModel.h
//  NPushMail
//
//  Created by swhl on 16/12/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAliSysBaseModel.h"

@interface MCAliSysMailModel : MCAliSysBaseModel

/**
  Error messages
 */
@property (nonatomic, strong) NSString  *errorInfo;

/**
    status ( 1 : Yes, 0 :NO )
 */
@property (nonatomic, assign) BOOL  state;

@end
