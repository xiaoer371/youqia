//
//  MCFeaturesReleaseManager.m
//  NPushMail
//
//  Created by wuwenyu on 16/10/25.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCFeaturesReleaseManager.h"
#import "MCAccountManager.h"
#import "MCAppSetting.h"
#import "MCContactModel.h"
#import "NSString+JSON.h"
#import "MCTool.h"
#import "MCServerAPI+Version.h"
#import "MCFeatureReleaseConfig.h"

@implementation MCFeaturesReleaseManager

- (void)checkFeatureReleaseSuccess:(FeaturesReleasecompliteBlock)success failure:(FeaturesReleaseFailBlock)failure featureType:(FeatureReleaseType)featureType {
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
    [ServerAPI checkFeatureReleaseWithParams:params success:^(id response) {
        if (response) {
            MCFeatureReleaseConfig *config = (MCFeatureReleaseConfig *)response;
            switch (featureType) {
                case FeatureImportantMail:{
                    if (success) {
                        success(config.importantMailEnableFlag);
                    }
                    break;
                }
                default:
                    break;
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure();
        }
    }];

}

@end
