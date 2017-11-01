//
//  MCDebugViewController.h
//  NPushMail
//
//  Created by swhl on 16/7/6.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"

enum MCDDEBUGTYPE{
    MCDDEBUGTYPE_35Mail = 0,
    MCDDEBUGTYPE_other = 1
};

@interface MCDebugViewController : MCBaseSubViewController

- (instancetype)initWithDebugType:(enum MCDDEBUGTYPE)type;

@end
