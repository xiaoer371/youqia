//
//  MCContactModel.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMPeerModelProtocol.h"
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MCModelStateOwner = 0,
    MCModelStateMember = 1,
    MCModelStateNotJion = 2,
} MCModelType;

@interface MCContactModel : NSObject <MCIMPeerModelProtocol>

@property (nonatomic,assign) NSInteger uid;

/**
 *  联系人账号
 */
@property(nonatomic, strong) NSString *account;
/**
 *  昵称
 */
@property(nonatomic, readonly) NSString *displayName;

/**
 *  头像的checksum
 */
@property (nonatomic,copy) NSString *headChecksum;

/**
 *  头像地址
 */
@property(nonatomic, strong, readonly) NSString *headImageUrl;

/**
 *  原始头像地址
 */
@property(nonatomic, strong, readonly) NSString *largeHeadImageUrl;

/**
 *  昵称首字母
 */
@property(nonatomic, strong) NSString *pinyinFirstChar;
/**
 *  昵称拼音
 */
@property(nonatomic, strong) NSString *pinyin;
/**
 *  联系人权重
 */
@property(nonatomic, assign) NSInteger weights;
/**
 *  若无头像，用于展示的current的头像色值
 */
@property(nonatomic, strong) NSString *headDefaultColorStr;

/**
 *  重要联系人（》1 为重要联系人
 */
@property(nonatomic, assign) BOOL importantFlag;
/**
 *  邮洽用户
 */
@property(nonatomic, assign) BOOL youqiaFlag;
/**
 *  删除标记
 */
@property(nonatomic, assign) BOOL deleteFlag;
/**
 *  是否选中
 */
@property(nonatomic, assign) BOOL isSelect;
/**
 *  是否不可编辑
 */
@property(nonatomic, assign) BOOL cantEdit;
/**
 *  备注的文字
 */
@property(nonatomic, strong) NSString *note;
/**
 *  备注的电话号码,多个电话号码用,分隔
 */
@property(nonatomic, strong) NSString *notePhoneNumbers;
/**
 *  电话号码
 */
@property(nonatomic, strong) NSString *phoneNumbers;
/**
 *  企业联系人标注  1是 0不是
 */
@property(nonatomic) BOOL isCompanyUser;
/**
 *  公司
 */
@property(nonatomic, strong) NSString *company;
/**
 *  职位
 */
@property(nonatomic, strong) NSString *position;
/**
 *  备注名
 */
@property(nonatomic, strong) NSString *noteDisplayName;
/**
 *  企业联系人名称
 */
@property(nonatomic, strong) NSString *enterpriseUserName;
/**
 *  邮洽中设置的昵称
 */
@property(nonatomic, strong) NSString *youqiaNickName;
/**
 *  邮件信息中的昵称
 */
@property(nonatomic, strong) NSString *emailNickName;
/**
 *  所属企业部门名称
 */
@property(nonatomic, strong) NSString *enterpriseDepartMent;
/**
 *  是否领导
 */
@property(nonatomic) BOOL isLeader;
/**
 *  联系人分组ID
 */
@property(nonatomic, strong) NSString *groupId;
/**
 *  组织架构中移动电话号码
 */
@property(nonatomic, strong) NSString *enterpriseMobile_phone;
/**
 *  组织架构中工作电话号码
 */
@property(nonatomic, strong) NSString *enterpriseWork_phone;

/**
 *  组织架构中家庭电话号码
 */
@property(nonatomic, strong) NSString *enterpriseHome_phone;

/**
 *  组织架构中生日
 */
@property(nonatomic, strong) NSString *enterpriseBirthday;
/**
 *  组织架构中人员的置顶排序
 */
@property(nonatomic, assign) NSInteger enterpriseTopId;
/**
 *  组织架构中人员的排序
 */
@property(nonatomic, assign) NSInteger enterpriseSortId;
/**
 *  最后更新时间
 */
@property(nonatomic, assign) NSTimeInterval lastUpdateTime;


#pragma mark - AvatarModelProtocol

@property(nonatomic, readonly) NSString *peerName;

@property (nonatomic, readonly) NSString *avatarUrl;

/**
 *  若无头像，用于展示的current的头像色值生成的头像
 */
@property(nonatomic, readonly) UIImage *avatarPlaceHolder;


#pragma mark - privata
@property(nonatomic) MCModelType groupMemberType;



#pragma mark - method
/**
 *  获取首字母
 *
 *  @param str 源字符串
 *
 *  @return 首字母
 */
+ (NSString *)getPinYinFirstCharWith:(NSString *)str;

+ (NSString *)getPinyin:(NSString *)str;


/**
 *  根据邮箱的昵称得到model
 *
 *  @param email
 *  @param emailNickName
 *
 *  @return
 */
+ (MCContactModel *)contactWithEmail:(NSString *)email
                       emailNickName:(NSString *)emailNickName;

@end
