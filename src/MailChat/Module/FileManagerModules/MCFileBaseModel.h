//
//  MCFileBaseModel.h
//  NPushMail
//
//  Created by wuwenyu on 15/12/29.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 文件来源
 */
typedef enum : NSUInteger {
    FromMesssage = 0,
    FromMail,
    FromContact
} FileSourceType;

@interface MCFileBaseModel : NSObject

/**
 *  主键，自增长id
 */
@property (nonatomic, assign) NSInteger uid;

/**
 *  文件的ID，如邮件附件的ID。
 */
@property(nonatomic, strong) NSString   *fileId;
/**
 *  保存时的文件名（可以重名）
 */
@property(nonatomic, strong) NSString *sourceName;
/**
 *  界面显示的名称
 */
@property(nonatomic, strong) NSString  *displayName;
/**
 *  文件大小（字节）
 */
@property(nonatomic, assign) NSUInteger   size;
/**
 *  文件类型
 */
@property(nonatomic, assign) NSInteger type;
/**
 *  文件存放位置
 */
@property(nonatomic, strong) NSString   *location;
/**
 *  文件格式
 */
@property(nonatomic, strong) NSString  *format;
/**
 *  文件接收日期
 */
@property(nonatomic, assign) NSUInteger  receiveDate;
/**
 *  文件下载时间
 */
@property(nonatomic, assign) NSUInteger  downLoadDate;
@property(nonatomic, assign) NSInteger   parentId;
/**
 *  文件来源
 */
@property(nonatomic, assign) FileSourceType source;
/**
 *  文件发自哪个用户
 */
@property(nonatomic, strong) NSString  *fromUser;
/**
 *  文件备注
 */
@property(nonatomic, strong) NSString   *remark;
/**
 *  是否收藏文件
 */
@property(nonatomic, assign) BOOL isCollect;
/**
 *  是否是文件夹
 */
@property(nonatomic, assign) BOOL isFolder;
/**
 *  界面用选中状态
 */
@property(nonatomic, assign) BOOL isSelected;


/**
 *  文件的全路径
 */
@property (nonatomic,readonly) NSString *fullPath;

@end
