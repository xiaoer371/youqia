//
//  MCFeatureReleaseConfig.h
//  NPushMail
//
//  Created by wuwenyu on 16/10/25.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCFeatureReleaseConfig : NSObject

- (instancetype)initWithDictionary:(id)dict;
@property(nonatomic, assign) BOOL importantMailEnableFlag;
@property (nonatomic, assign) BOOL needRollBack;
@end
