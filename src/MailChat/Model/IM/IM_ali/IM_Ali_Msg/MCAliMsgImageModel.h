//
//  MCAliMsgImageModel.h
//  NPushMail
//
//  Created by swhl on 16/12/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAliMsgBaseModel.h"

typedef enum : NSUInteger {
    MCAliMsgImageTypeUnknown = 0,
    MCAliMsgImageTypeJPG         = 1,
    MCAliMsgImageTypePNG         = 2,
    MCAliMsgImageTypeGIF         = 3,
    MCAliMsgImageTypeBMP         = 4

} MCAliMsgImageType;

@interface MCAliMsgImageModel : MCAliMsgBaseModel


@property (nonatomic, assign) MCAliMsgImageType  imageType;

@property (nonatomic, assign) CGFloat size;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
/**
 // 图片hash值
 */
@property (nonatomic, strong) NSString *imageHash;

/**
 图片下载地址
 */
@property (nonatomic, strong) NSString *url;




@end
