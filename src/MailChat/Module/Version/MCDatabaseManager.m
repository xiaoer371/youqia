//
//  MCDatabaseManager.m
//  NPushMail
//
//  Created by admin on 7/6/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCDatabaseManager.h"
#import "MCDbVersion1.h"
#import "MCAppSetting.h"
#import "MCDbVersion2.h"
#import "MCDbVersion3.h"
#import "MCDbVersion4.h"
#import "MCDbVersion5.h"
#import "MCDbVersion6.h"
#import "MCDbVersion7.h"
#import "MCDbVersion8.h"
@interface MCDatabaseManager ()

@property (nonatomic,strong) NSArray *versions;

@end

@implementation MCDatabaseManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Should be ordered
        _versions = @[[MCDbVersion1 new],
                      [MCDbVersion2 new],
                      [MCDbVersion3 new],
                      [MCDbVersion4 new],
                      [MCDbVersion5 new],
                      [MCDbVersion6 new],
                      [MCDbVersion7 new],
                      [MCDbVersion8 new]
                      ];
    }
    return self;
}

- (BOOL)shouldUpgrade
{
    id<MCDbVersionProtocol> lastVer = [self.versions lastObject];
    // 新安装的版本，判断是否要就数据库升级
    if (AppSettings.dbVersion == 0) {
        if ([self hasOldDb]) {
            return YES;
        }
        else {
            AppSettings.dbVersion = [lastVer version];
            return NO;
        }
    }
    else {
        return [lastVer version] > AppSettings.dbVersion;
    }
}

- (BOOL)upradeDatabase
{
    NSUInteger dbVersion = AppSettings.dbVersion;
    __block NSInteger currentVerIndex = -1;
    [self.versions enumerateObjectsUsingBlock:^(id<MCDbVersionProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj version] == dbVersion) {
            currentVerIndex = idx;
            *stop = YES;
        }
    }];
    
    for (NSInteger i = currentVerIndex + 1; i < self.versions.count; i++) {
        id<MCDbVersionProtocol> ver = self.versions[i];
        BOOL success = [ver upgradeDatabase];
        if (success) {
            AppSettings.dbVersion = [ver version];
        }
        else {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Private

- (BOOL)hasOldDb
{
    NSString *databasePath = [AppStatus.documentDir stringByAppendingPathComponent:@"database.sqlite"];
    return [[NSFileManager defaultManager] fileExistsAtPath:databasePath];
}

@end
