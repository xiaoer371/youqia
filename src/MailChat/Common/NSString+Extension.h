//
//  NSString+Extension.h
//  NPushMail
//
//  Created by admin on 1/4/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,MCMailSubjectLanguageType) {
    MCMailSubjectLanguageEnglish = 0,
    MCMailSubjectLanguageSimplifiedChinese,
    MCMailSubjectLanguageTraditionalChinese
};

@interface NSString (Extension)

/**
 *  获取邮件的域名，如 35.cn, 163.com
 *
 *  @return 邮件的域名
 */
- (NSString *)mailDomain;
/**
 *  根据邮件地址获取名称
 *
 *  @return 邮件地址的前缀
 */
- (NSString *)mailName;
/*
 包含@
 */
- (NSString *)emailName;
/**
 *  是否是小助手账号
 *
 *  @return 是否是小助手账号
 */
- (BOOL)isHelperAccount;
/**
 *  是否是邮箱
 *
 *  @return 是否是邮箱
 */
- (BOOL)isEmail;

/**
 是否是QQ邮箱

 @return 是否是QQ邮箱
 */
- (BOOL)isQQEmail;


/**
 是否是网易邮箱

 @return
 */
- (BOOL)isNetEastMail;

/**
 是否是gmail 邮箱

 @return 是否是gmail 邮箱
 */
- (BOOL)isGmailEmail;

/**
 *  是否是电话号码
 *
 *  @return 是否是电话号码
 */
-(BOOL)isPhone;


/**
 * 是否是35的邮箱

 @return 是否是35的邮箱
 */
- (BOOL)is35Mail;

/**
 *  去掉前后空格，换行
 *
 *  @return 处理后的字符串
 */
- (NSString *)trim;
//去换行符
- (NSString*)trimNewLine;

/**
 *  小写去空格
 *
 *  @return 小写去空格后的字符串
 */
- (NSString *)lowercaseStringWithSpaceRemoved;

- (BOOL)isPureInt;
- (BOOL)hasExtension:(NSString *)fileExtension;
- (BOOL)validateMobile;
/** 
 替换成html空格换行
 */
- (NSString*)toHtmlSpaceAndLine;

/**
 *  计算字符串宽高
 *
 *  @param fontSize 字号
 *
 *  @return CGSize
 */
- (CGSize)mcStringSizeWithFont:(CGFloat)fontSize;
/**
 *  计算指定字符串size
 *
 *  @param fontSize 字号
 *  @param maxWidth 最大宽度
 *  @param maxHight 最大高度
 *
 *  @return CGSize
 */
- (CGSize)mcStringSizeWithFont:(CGFloat)fontSize maxWidth:(CGFloat)maxWidth maxHight:(CGFloat)maxHight;
//粗体字符计算
- (CGSize)mcStringSizeWithBoldFont:(CGFloat)fontSize maxWidth:(CGFloat)maxWidth maxHight:(CGFloat)maxHight ;
/**
 *  判断字符串是否包含某字符串
 *  @param 返回BOOL
 */
- (BOOL)mcContainsString:(NSString*)other;

/**
 *  是否是中文
 *
 */
- (BOOL)isSimplifiedChinese;
- (BOOL)isTraditionalChinese;
- (MCMailSubjectLanguageType)stringLanguage;
/**
 *  计算文件大小
 */
-(NSString *)sizeWithfloat:(CGFloat)a;

- (NSString *)encodedString;

// 百分比字符串转float
- (float)percentString;


@end
