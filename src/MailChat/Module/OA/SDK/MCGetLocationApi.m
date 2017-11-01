//
//  MCGetLocationApi.m
//  NPushMail
//
//  Created by admin on 3/24/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCGetLocationApi.h"
#import <CoreLocation/CoreLocation.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>

@interface MCGetLocationApi () <BMKLocationServiceDelegate>

@property (nonatomic,strong) BMKLocationService *locationManager;

@property (nonatomic,copy) JSSuccessBlock successBlock;
@property (nonatomic,copy) JSFailureBlock failureBlock;

@end

@implementation MCGetLocationApi

- (NSString *)name
{
    return @"getlocation";
}

- (void)processWithParameters:(id)params success:(JSSuccessBlock)success failure:(JSFailureBlock)failure
{
    if (![CLLocationManager locationServicesEnabled]) {
        if (failure) {
            failure(@"Location service disabled");
        }
        return;
    }
    
    self.successBlock = success;
    self.failureBlock = failure;
    
    if (!self.locationManager) {
        self.locationManager = [[BMKLocationService alloc] init];
        self.locationManager.delegate = self;
    }
    
    [self.locationManager startUserLocationService];
}

#pragma mark - BMKLocationServiceDelegate

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSDictionary *result = @{@"latitude" : @(userLocation.location.coordinate.latitude),
                             @"longitude" : @(userLocation.location.coordinate.longitude)};
    
    if (self.successBlock) {
        self.successBlock(@[result]);
        self.successBlock = nil; // 设置为空，避免重复调用，因为一起请求会有多个回调。
    }
    
    [self.locationManager stopUserLocationService];
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSString *errMsg = [error description];
    if (self.failureBlock) {
        self.failureBlock(errMsg);
    }
}

@end
