//
//  MCFeaturesReleaseManager.h
//  NPushMail
//
//  Created by wuwenyu on 16/10/25.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

//检查功能类型
typedef NS_ENUM(NSInteger, FeatureReleaseType) {
    FeatureImportantMail = 0, //重要邮件
};

typedef void(^FeaturesReleasecompliteBlock)(BOOL enableFlag);
typedef void(^FeaturesReleaseFailBlock)(void);

@interface MCFeaturesReleaseManager : NSObject

- (void)checkFeatureReleaseSuccess:(FeaturesReleasecompliteBlock)success
                           failure:(FeaturesReleaseFailBlock)failure
                        featureType:(FeatureReleaseType)featureType;


@end
