//
//  MCVersionManager.m
//  NPushMail
//
//  Created by zhang on 16/6/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCVersionManager.h"
#import "MCServerAPI+Version.h"
#import "MCAppSetting.h"

@implementation MCVersionModel

@end

@implementation MCVersionManager
- (void)getVersionInfoWithVersion:(NSString *)version Success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    NSDictionary *params = @{@"c":@"appstore",@"v":version?:@"0"};
    [[MCServerAPI shared] getAppNewVersionWithParams:params success:^(id response) {
        //
        NSDictionary *dic = (NSDictionary*)response;
        if ([[dic valueForKey:@"result"] integerValue] == 1) {
            
            MCVersionModel *model = [self updateInfoWithVersionInfo:[dic valueForKey:@"data"]];
            if (success) {
                success(model);
            }
        }else failure(nil);
    } failuer:failure];
    return;
    /// 旧的更新接口
    [[MCServerAPI shared] getAppVersionSuccess:^(id response) {
        NSDictionary *dic = (NSDictionary*)response;
        if ([[dic valueForKey:@"result"] integerValue] == 1) {
            
            MCVersionModel *model = [self updateInfoWithVersionInfo:[dic valueForKey:@"data"]];
            if (success) {
                success(model);
            }
            
        } else {
            failure(nil);
        }
        
    } failuer:failure];
}

- (MCVersionModel*)updateInfoWithVersionInfo:(NSDictionary*)versionInfo {
    
    MCVersionModel *versionModel = [MCVersionModel new];
    NSString  *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSInteger oldVersion = [[currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
    NSString  *newVersionStr =[[versionInfo valueForKey:@"version"] stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSInteger newVersion = [newVersionStr integerValue];
    versionModel.version = [versionInfo valueForKey:@"version"];
    BOOL updateFlag = NO;
    if (AppSettings.lastUpdateVersion) {
        if (![AppSettings.lastUpdateVersion isEqualToString:versionModel.version]) {
            updateFlag = oldVersion < newVersion?YES:NO;
        }
         AppSettings.lastUpdateVersion = versionModel.version;  //要保存有小数点的版本号
    }else {
        AppSettings.lastUpdateVersion = versionModel.version;  //要保存有小数点的版本号
        updateFlag = oldVersion < newVersion?YES:NO;
    }
    versionModel.update = updateFlag;
    //强制更新
    versionModel.forcedUpdate = [[versionInfo valueForKey:@"forced"] boolValue];
    versionModel.updateInfo = [versionInfo valueForKey:@"update"];
    versionModel.title = [versionInfo valueForKey:@"version"];
    return versionModel;
}

@end
