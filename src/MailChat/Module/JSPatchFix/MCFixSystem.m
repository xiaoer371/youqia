//
//  MCFixSystem.m
//  NPushMail
//
//  Created by wuwenyu on 16/10/9.
//  Copyright © 2016年 sprite. All rights reserved.
//
//上传的参数:OS版本号，手机型号，IP地址，用户（或者邮箱列表），app版本号，本地文件时间戳（初始应该为0）。
//返回的参数:js文件时间戳，js文件地址，是否回退标识，是否需要更新js文件。
/*
 https://a.mailchat.cn/app/ihotfix?debug=1&app-ver=5.2.0&os=10.0&model=iPhone5&hotfix-ver=0&mails=[%22qiushzh@35.cn%22,%20%22qiusz@163.com%22]
 debug: 传入非0参数为开启，返回调试日志
 app-ver: 用户APP版本
 os:用户IOS版本
 model:xxx
 hotfix-ver:用户当前补丁版本，默认为0
 mails: 用户当前绑定的邮箱，为 ["aaa","bbb"] string格式，由json序列化
 
 
 */
#import "MCFixSystem.h"
#import "MCServerAPI+File.h"
#import "MCJsFileConfig.h"
#import "MCFileManager.h"
#import "MCFileCore.h"
#import "MCAppSetting.h"
#import "MCAccountManager.h"
#import "MCTool.h"
#import "NSString+JSON.h"
#import "MD5Additions.h"

@implementation MCFixSystem

+ (MCFixSystem *)shared {
    static id instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [MCFixSystem new];
    });
    return instance;
}

- (void)checkUpdateJsFileSuccess:(JsUpdateCompliteBlock)compliteBlock failure:(JsUpdateFailBlock)failBlcok {
    NSString* versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
    NSMutableArray *emails = [NSMutableArray arrayWithCapacity:accounts.count];
    for (MCAccount *act in accounts) {
        [emails addObject:act.email];
    }
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:emails.count];
    for (MCContactModel *email in emails) {
        [dataArray addObject:[NSString stringWithFormat:@"%@", email]];
    }
    NSString *emailsJsonString = [NSString jsonStringWithObject:dataArray];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"debug"] = @(Debug_Flag);
    params[@"os"] = [UIDevice currentDevice].systemVersion;
    params[@"app-ver"] = versionStr;
    params[@"model"] = [[UIDevice currentDevice] model];
    params[@"deviceIP"] = [[MCTool shared] deviceIPAdress];
    params[@"userId"] = AppSettings.user.userId;
    params[@"mails"] = emailsJsonString;
    params[@"hotfix-ver"] = @(AppSettings.jsVersion);
    
    [ServerAPI checkUpdateJsFileParameters:params success:^(id response) {
        MCJsFileConfig *jsConfig = (MCJsFileConfig *)response;
        if (!jsConfig.needRollBack) {
            if (jsConfig.needUpdate) {
                //去下载最新的js文件替换本地
                if (jsConfig.jsUrl) {
                    [ServerAPI downLoadFileWithUrl:[NSURL URLWithString:jsConfig.jsUrl] success:^(id filePath) {
                        //下载成功替换本地的js文件，替换最新的文件版本号
                        NSURL *fileUrl = (NSURL *)filePath;
                        NSData *data = [NSData dataWithContentsOfURL:fileUrl];
                        //验证文件的md5值
                        NSString *md5 = [data md5];
                        if ([md5 isEqualToString:jsConfig.md5]) {
                            //验证通过保存或覆盖js文件
                            MCFileManager *fileManager =[[MCFileCore sharedInstance] getFileModule];
                            //js文件都放置到相应的版本文件夹下
                            NSString *jsFileFolder = [self jsFileFolder];
                            NSString *shortPath = [fileManager saveOrReplaceFileWithData:data shortPath:jsFileFolder fileName:@"MCMainJs.js"];
                            
                            AppSettings.jsPath = shortPath;
                            AppSettings.jsVersion = jsConfig.jsVersion;
                            NSError *error = nil;
                            BOOL flag = [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&error];
                            if (flag) {
                            }else{
                                DDLogError(@"文件删除失败 = %@",error);
                            }
                            if (compliteBlock) {
                                compliteBlock(YES, [self jsFilePath]);
                            }
                        }else {
                            //md5验证不通过
                            DDLogError(@"补丁文件md5校验不一致");
                        }
                        
                    } failure:^(NSError *error) {
                        if (failBlcok) {
                            failBlcok();
                        }
                    }];
                }else {
                    //不需要更新js文件，查找本地js文件路径直接执行
                    if (compliteBlock) {
                        if (AppSettings.jsPath) {
                            compliteBlock(YES, [self jsFilePath]);
                        }
                    }
                }
            }else {
                //不需要更新js文件，查找本地js文件路径直接执行
                if (compliteBlock) {
                    if (AppSettings.jsPath) {
                        compliteBlock(YES, [self jsFilePath]);
                    }
                }
            }
            
        }else {
            //需要回退
            if (compliteBlock) {
                compliteBlock(NO, AppSettings.jsPath);
            }
        }
    } failure:^(NSError *error) {
        if (failBlcok) {
            failBlcok();
        }
    }];
}

- (NSString *)jsFilePath {
    NSString *jsFileFolder = [self jsFileFolder];
    NSString *jsShortPath = [jsFileFolder stringByAppendingPathComponent:@"MCMainJs.js"];
    NSString *filePath = [[[MCFileCore sharedInstance] getFileModule] getFileFullPathWithShortPath:jsShortPath];
    return filePath;
}

- (NSString *)jsFileFolder {
    NSString * versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *jsFileFolder = [allFileDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", @"js", versionStr]];
    return jsFileFolder;
}

@end
