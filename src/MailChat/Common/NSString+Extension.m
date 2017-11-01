//
//  NSString+Extension.m
//  NPushMail
//
//  Created by admin on 1/4/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (NSString *)mailDomain
{
    NSRange atRange = [self rangeOfString:@"@" options:NSBackwardsSearch];
    if (atRange.length == 0) {
        DDLogVerbose(@"Not an email : %@", self);
        return nil;
    }
    
    NSRange domainRange = NSMakeRange(atRange.location + 1, self.length - atRange.location - 1);
    return [self substringWithRange:domainRange];
}

- (NSString *)mailName
{
    NSRange atRange = [self rangeOfString:@"@"];
    if (atRange.length == 0) {
        DDLogVerbose(@"Not an email = %@",self);
        return nil;
    }
    
    return [self substringToIndex:atRange.location];
}

- (NSString *)emailName {
    NSRange atRange = [self rangeOfString:@"@"];
    if (atRange.length == 0) {
        DDLogVerbose(@"Not an email = %@",self);
        return nil;
    }
    
    return [self substringToIndex:atRange.location + 1];
}

//判断邮箱格式

- (BOOL)isEmail
{
    NSString *emailCheck = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailCheck];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)isQQEmail
{
    if ([self containsString:@"qq.com"] || [self containsString:@"foxmail.com"] ) {
        return YES;
    }else return NO;
}

- (BOOL)isNetEastMail {
    if ([self containsString:@"163.com"] || [self containsString:@"126.com"] || [self containsString:@"yeah.net"]) {
        return YES;
    }else return NO;
}

- (BOOL)isGmailEmail
{
    if ([self containsString:@"gmail.com"]) {
        return YES;
    }else return NO;
}

- (BOOL)is35Mail
{
    if ([self containsString:@"35.cn"] ||[self containsString:@"china-channel.com"]) {
        return YES;
    }else return NO;
}

-(BOOL)isPhone
{
    NSString *phoneCheck = @"((\\d{3}-|\\d{4}-)?(\\d{11}|\\d{8}|\\d{7})?)";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",phoneCheck];
    return [phoneTest evaluateWithObject:self];
}


- (BOOL)hasExtension:(NSString *)fileExtension
{
    return [self hasSuffix:fileExtension];
}

- (BOOL)validateMobile {
    NSString *MOBILE = @"^[0-9]*$";
    NSPredicate *regexTestMobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",MOBILE];
    if ([regexTestMobile evaluateWithObject:self]) {
        return YES;
    }else {
        return NO;
    }
}
/**
 *  去空格 、换行
 */
- (NSString*)trim {
    
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString*)trimNewLine {
    return [self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}


- (NSString *)lowercaseStringWithSpaceRemoved
{
    return [self.lowercaseString trim];
}

- (BOOL)isPureInt
{
    BOOL isInt = NO;
    NSCharacterSet *alphaNumberSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:self];
    isInt = [alphaNumberSet isSupersetOfSet:stringSet];
    
    return isInt;
}

- (NSString*)toHtmlSpaceAndLine {
    NSString*str = [self stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp"];
    return [str stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
}

//计算字符串size
//不限制宽高
- (CGSize)mcStringSizeWithFont:(CGFloat)fontSize {
    return [self mcStringSizeWithFont:fontSize maxWidth:MAXFLOAT maxHight:MAXFLOAT];
}
//指定最大宽高
- (CGSize)mcStringSizeWithFont:(CGFloat)fontSize maxWidth:(CGFloat)maxWidth maxHight:(CGFloat)maxHight{
    
    return [self mcStringSizeWithFont:[UIFont systemFontOfSize:fontSize] width:maxWidth hight:maxHight];
    
}

- (CGSize)mcStringSizeWithBoldFont:(CGFloat)fontSize maxWidth:(CGFloat)maxWidth maxHight:(CGFloat)maxHight {
    return [self mcStringSizeWithFont:[UIFont boldSystemFontOfSize:fontSize] width:maxWidth hight:maxHight];
}
- (CGSize)mcStringSizeWithFont:(UIFont*)font width:(CGFloat)w hight:(CGFloat)h {
    
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize size = [self boundingRectWithSize:CGSizeMake(w, h) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return size;
}

- (BOOL)isHelperAccount
{
    if ([self isEqualToString:kMailChatHelper] || [self isEqualToString:kMailChatHelperAndroid]) {
        return YES;
    }else return NO;
}

- (BOOL)mcContainsString:(NSString*)other {
    if (self) {
        NSRange range = [self rangeOfString:other];
        return range.length != 0;
    }
    return NO;
}

-(BOOL)isSimplifiedChinese {
    
    for(int i = 0; i< [self length];i++) {
        int a = [self characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fa5){
            return YES;
          }
       }
    return NO;
}
//由 e38080 到 e9be98 ( 包括全型符号 )
- (BOOL)isTraditionalChinese {
    
    for(int i = 0; i< [self length];i++) {
        int a = [self characterAtIndex:i];
        if((a > 0x8140 && a < 0xa0fe)||
           (a > 0xa140 && a < 0xa3bf)||
           (a > 0xa440 && a < 0xc67e)||
           (a > 0xc6a1 && a < 0xc8fe)||
           (a > 0xa3c0 && a < 0xa3fe)||
           (a > 0xc940 && a < 0xf9d5)||
           (a > 0xf0d6 && a < 0xfefe)){
            return YES;
        }
    }
    return NO;
}

- (MCMailSubjectLanguageType)stringLanguage {
//    if ([self isTraditionalChinese]) {
//        return MCMailSubjectLanguageSimplifiedChinese;
//    } else
        if ([self isSimplifiedChinese]){
        return MCMailSubjectLanguageSimplifiedChinese;
    }
    return MCMailSubjectLanguageEnglish;
}

-(NSString *)sizeWithfloat:(CGFloat)a
{
    NSString *sizeStr;
    if (a>1024*1024) {
        a =(float)a/(1024*1024);
        sizeStr =[NSString stringWithFormat:@"%.2fM",a];
    }else if(a>1024)
    {
        a =(float)a/(1024);
        sizeStr =[NSString stringWithFormat:@"%.2fK",a];
    }else{
        sizeStr =[NSString stringWithFormat:@"%.2fB",a];
    }
    return sizeStr;
}

- (NSString *)encodedString
{
    NSString *unreserved = @"-._~/?";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet
                                      alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    
    NSString *percentString = [self stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    //NSString *encodedString = [percentString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return percentString;
}

- (float)percentString
{
    NSInteger  a = [self integerValue];
    float b  = a/100.00;
    return b;
}


@end
