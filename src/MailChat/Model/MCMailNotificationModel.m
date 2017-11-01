//
//  MCMailNotificationModel.m
//  NPushMail
//
//  Created by admin on 5/19/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailNotificationModel.h"

@implementation MCMailNotificationModel


//TODO:apns推送
/*
 自定义参数,类似 data =   { i: 220070, 
 u: 'qiushzh@35.cn',
 s: 'aaaa',
 f: '邱尚振<qiushzh@35.cn>', 
 t: 1423030476950, 
 d: 'inbox',
 m: '邮件内容第一行\\n邮件内容第二行' };
 
 i 邮箱UID (i要做空判断),用于从邮局服务器获取这个邮件
 u 收件人邮箱
 s 邮件标题
 f 发件人信息 名称<邮箱>
 t 时间戳（毫秒）
 d 文件夹
 m 内容摘要
 */

- (id)initModelWith:(NSDictionary*)notifyInfo {
    
    if (self = [super init]) {
        _mailUid = [[notifyInfo valueForKey:@"i"] integerValue];
        _toMail = [notifyInfo valueForKey:@"u"];
        _subject = [notifyInfo valueForKey:@"s"];
        
        NSString *from = [notifyInfo valueForKey:@"f"];
        
        if ([from isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray *)from;
            from = [array firstObject];
        }
        if (from) {
            _from = [MCMailAddress new];
            NSRange range = [from rangeOfString:@"<"];
            if (range.location != NSNotFound) {
                NSString *name = [from substringToIndex:range.location];
                NSRange range1 = [from rangeOfString:@">"];
                NSInteger length = range1.location - range.location;
                NSRange emailRange = NSMakeRange(range.location + 1, length - 1);
                if (emailRange.location != NSNotFound && emailRange.location<1000) {
                    NSString *email = [from substringWithRange:emailRange];
                    _from.name = name;
                    _from.email = email;
                }
                
            } else {
                _from.name = from;
                _from.email = from;
            }
        }
        _time = [[notifyInfo valueForKey:@"t"] doubleValue]/1000;
        _folder = [notifyInfo valueForKey:@"d"];
        if ([_folder isEqualToString:@"inbox"]) {
            _folder = @"INBOX";
        }
        _briefContent = [notifyInfo valueForKey:@"m"];
        NSArray *names = [notifyInfo valueForKey:@"n"];
        if (names&&![names isKindOfClass:[NSNull class]]) {
            _folderName = [names lastObject];
            _level = names.count - 1;
        }
    }
    return self;
}

@end
