//
//  MCVersionManager.h
//  NPushMail
//
//  Created by zhang on 16/6/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCVersionModel :NSObject
@property (nonatomic,assign)NSString *version;
@property (nonatomic,assign)BOOL update;
@property (nonatomic,assign)BOOL forcedUpdate;
@property (nonatomic,strong)NSString *updateInfo;
@property (nonatomic,strong)NSString *title;
@end

@interface MCVersionManager : NSObject
- (void)getVersionInfoWithVersion:(NSString *)version Success:(SuccessBlock)success failure:(FailureBlock)failure;

@end
