//
//  MCOAConfig.m
//  NPushMail
//
//  Created by wuwenyu on 16/5/31.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCOAConfig.h"
#import "MCAccountConfig.h"

@implementation MCOAConfig

- (id)initWithDictionary:(id)dict oaConfigType:(initOaConfigType)type {
    if (self = [super init]) {
        NSDictionary *dic = (NSDictionary *)dict;
        switch (type) {
            case IsOaUserType:
                _isOaUser = [[IsOaUser alloc] initWithDictionary:dic];
                break;
            case CheckIsBindingOaType:
                _checkBindingOa = [[CheckIsBindingOa alloc] initWithDictionary:dic];
                break;
            case OAUserLoginTypeType:
                _oaUserLoginTypeType = [[OAUserLoginType alloc] initWithDictionary:dic];
                break;
            default:
                break;
        }
    }
    return self;
}

@end

@implementation IsOaUser

- (instancetype)initWithDictionary:(id)dict {
    if (self = [super init]) {
        BOOL success = [dict objectForKey:@"success"];
        _message = [dict objectForKey:@"message"];
        if (success) {
            int code = [[dict objectForKey:@"code"] intValue];
            _oaUserFlag = NO;
            if (code == 0) {
                _oaUserFlag = YES;
            }else {
                _oaUserFlag = NO;
            }
        }else {
            DDLogError(@"验证是否是OA用户的接口调用失败:%@", _message);
        }
    }
    return self;
}

@end

@implementation CheckIsBindingOa

- (instancetype)initWithDictionary:(id)dict {
    if (self = [super init]) {
        int result = [[dict objectForKey:@"result"] intValue];
        if (result == 0) {
            //绑定过OA账号了
            _bindingOaFlag = YES;
            NSString *oaUserName = @"";
            NSString *domin = @"";
            if ([dict objectForKey:@"pagedata"]) {
                NSDictionary *pageDic = [dict objectForKey:@"pagedata"];
                if ([pageDic objectForKey:@"rows"]) {
                    NSArray *rowsAry = [pageDic objectForKey:@"rows"];
                    id rowsDic = [rowsAry objectAtIndex:0];
                    if ([rowsDic isKindOfClass:[NSDictionary class]]) {
                        if ([rowsDic objectForKey:@"torgusers"]) {
                            NSDictionary *torgusersDic = [rowsDic objectForKey:@"torgusers"];
                            if ([torgusersDic objectForKey:@"domain"]) {
                                domin = [torgusersDic objectForKey:@"domain"];
                                _oaDomin = domin;
                            }
                            NSString *username = @"";
                            if ([torgusersDic objectForKey:@"username"]) {
                                username = [torgusersDic objectForKey:@"username"];
                            }
                            oaUserName = [NSString stringWithFormat:@"%@@%@", username, domin];
                            _oaUserName = oaUserName;
                        }
                    }
                }
            }
            
        }else {
            _bindingOaFlag = NO;
        }
    }
    return self;
}

@end

@implementation OAUserLoginType

- (instancetype)initWithDictionary:(id)dict {
    if (self = [super init]) {
        BOOL success = [[dict objectForKey:@"success"] boolValue];
        _message = [dict objectForKey:@"message"];
        _success = success;
        _is35mail = [[dict objectForKey:@"is35mail"] boolValue];
        if (success) {
            _accesstoken = [dict objectForKey:@"accesstoken"];
            _createtime = [dict objectForKey:@"createtime"];
            _expireinTime = [[dict objectForKey:@"expirein"] integerValue];
            _oausername = [dict objectForKey:@"oausername"];
            _userid = [dict objectForKey:@"userid"];
            _bindmail = [dict objectForKey:@"bindmail"];
            }
        _errorcode = [[dict objectForKey:@"errorcode"] intValue];
        switch (_errorcode) {
            case 0:
                DDLogInfo(@"登录OA错误码:%d 验证成功",_errorcode);
                break;
            case 1:
                DDLogInfo(@"登录OA错误码:%d 加密的字符串过期",_errorcode);
                break;
            case 2:
                DDLogInfo(@"登录OA错误码:%d 该OA账号不存在",_errorcode);
                break;
            case 12901:
                DDLogInfo(@"登录OA错误码:%d 登录失败，用户名或密码错误",_errorcode);
                break;
            case 12902:
                DDLogInfo(@"登录OA错误码:%d 登录失败，该域不存在",_errorcode);
                break;
            case 12908:
                DDLogInfo(@"登录OA错误码:%d 登录已过期!",_errorcode);
                break;
            case 20001:
                DDLogInfo(@"登录OA错误码:%d 该域已经被关闭!",_errorcode);
                break;
            case 20002:
                DDLogInfo(@"登录OA错误码:%d 该域已经被暂停使用!",_errorcode);
                break;
            case 20003:
                DDLogInfo(@"登录OA错误码:%d 该域暂时被管理员暂停进行系统调整",_errorcode);
                break;
            case 20004:
                DDLogInfo(@"登录OA错误码:%d 该域暂时被管理员暂停进行系统调整",_errorcode);
                break;
            case 20005:
                DDLogInfo(@"登录OA错误码:%d 该域正在进行数据恢复操作，请稍后再重新登录",_errorcode);
                break;
            case 21005:
                DDLogInfo(@"登录OA错误码:%d 该域已过期",_errorcode);
                break;
            case 12010:
                DDLogInfo(@"登录OA错误码:%d 用户数已达最大",_errorcode);
                break;
            case 12015:
                DDLogInfo(@"登录OA错误码:%d 用户登录时,账户未激活",_errorcode);
                break;
            case 12904:
                DDLogInfo(@"登录OA错误码:%d 用户处于登录限制状态",_errorcode);
                break;
            case 12905:
                DDLogInfo(@"登录OA错误码:%d 用户处于限制IP登录状态",_errorcode);
                break;
            case 12909:
                DDLogInfo(@"登录OA错误码:%d 以imap方式登录时,imap参数丢失",_errorcode);
                break;
            case 12910:
                DDLogInfo(@"登录OA错误码:%d 在outerpost时,decode失败",_errorcode);
                break;
            case 12911:
                DDLogInfo(@"登录OA错误码:%d 登录模式非法",_errorcode);
                break;
            case 12912:
                DDLogInfo(@"登录OA错误码:%d 以IMAP方式登录时，服务器报错",_errorcode);
                break;
            case 12913:
                DDLogInfo(@"登录OA错误码:%d 以IMAP方式登录时，timeout",_errorcode);
                break;
            case 12920:
                DDLogInfo(@"登录OA错误码:%d 获取用户的ACCESSTOKEN出错",_errorcode);
                break;
            case -202:
                DDLogInfo(@"登录OA错误码:%d 参数不存在",_errorcode);
                break;
            case -205:
                DDLogInfo(@"登录OA错误码:%d 参数非法",_errorcode);
                break;
            default:
                DDLogInfo(@"登录OA错误码:未知");
                break;
        }
    }
    return self;
}

@end
