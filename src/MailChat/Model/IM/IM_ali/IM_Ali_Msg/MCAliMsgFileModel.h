//
//  MCAliMsgFileModel.h
//  NPushMail
//
//  Created by swhl on 16/12/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAliMsgBaseModel.h"


typedef enum : NSUInteger {
    IMAliFileloadStateNone = 0,
    IMAliFileloadStateloading = 1,
    IMAliFileloadStateloaded = 2,
} IMAliFileloadState;


@interface MCAliMsgFileModel : MCAliMsgBaseModel

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *fileHash;
@property (nonatomic, assign) CGFloat   size;
@property (nonatomic, strong) NSString  *url;
@property (nonatomic, assign) IMAliFileloadState  fileState;

@end
