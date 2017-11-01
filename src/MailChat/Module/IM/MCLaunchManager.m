//
//  MCLaunchManager.m
//  NPushMail
//
//  Created by swhl on 17/2/15.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCLaunchManager.h"
#import "MCServerAPI+Launch.h"
#import "MCAppSetting.h"
#import "MCFileCore.h"
#import "MCFileManager.h"
#import "MCServerAPI+File.h"

@implementation MCLaunchManager

+ (void)checkLaunch
{
    [ServerAPI checkLaunchVersion:AppSettings.launchModel.version?:@"0" success:^(id response) {
//    [ServerAPI checkLaunchVersion:@"0" success:^(id response) {
        //TODO : 保存启动资源  配置信息等等
        NSDictionary *responseObject = (NSDictionary *)response;
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (AppSettings.launchModel) {
                MCFileManager *fileManager =[[MCFileCore sharedInstance] getFileModule];
                [fileManager deleteFileWithPath:[fileManager getCachesFilePath]];
                MCLaunchModel *model = AppSettings.launchModel;
                model.isDownLoad = NO;
                [AppSettings setLaunchModel:model];
            }
            MCLaunchModel *model = [[MCLaunchModel alloc] initWithDictionary:[responseObject objectForKey:@"data"]];
            [self downLoadLaunchFile:model];
        }
        else{
            if (AppSettings.launchModel.isDownLoad ==NO) {
                [self downLoadLaunchFile:AppSettings.launchModel];
            }
        }
    } failure:^(NSError *error) {
        //
    }];
}

+ (void)downLoadLaunchFile:(MCLaunchModel *)model
{
    __block int i = 0;
    for (NSArray *arr in model.resources) {
        if ([arr isKindOfClass:[NSArray class]]) {
            if (arr.count>0) {
                // TODO: 替换可用的URL 目前为测试URL
                //  NSString *str = arr[0];
                NSString *str = @"https:/a.mailchat.cn/file/e98b122fd74b229588264b19a4e6666b0f08bac7/3ef02a97-872c-40e1-b22a-e23c27b9aaa1.png";
                NSURL *url = [[NSURL alloc] initWithString:str];
                [ServerAPI downLoadFileWithUrl:url success:^(id response) {
                    //
                    NSURL *fileUrl = (NSURL *)response;
                    NSData *data = [NSData dataWithContentsOfURL:fileUrl];
                    
                    MCFileManager *fileManager =[[MCFileCore sharedInstance] getFileModule];
                    NSString *name =[NSString stringWithFormat:@"%@%d",model.title,i++];
                    [fileManager saveFileWithData:data folder:fileLaunch fileName:name];
                    
                    DDLogVerbose(@"name ==== %@",name);
                    model.isDownLoad = YES;
                    [AppSettings setLaunchModel:model];
                } failure:^(NSError *error) {
                    model.isDownLoad = NO;
                    [AppSettings setLaunchModel:model];
                }];
            }
        }
    }
}


@end
