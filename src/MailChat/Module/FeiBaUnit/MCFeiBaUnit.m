//
//  MCFeiBaUnit.m
//  NPushMail
//
//  Created by swhl on 16/12/28.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCFeiBaUnit.h"
#import "RSADataSigner.h"
#import <CoreLocation/CoreLocation.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>

static NSString* const MCFeiBaPartnerId = @"7b238b1d0a314d30b4f4cbfd06f2d55c";

@interface MCFeiBaUnit ()<BMKLocationServiceDelegate>

@property (nonatomic,strong) BMKLocationService *locationManager;

@property (nonatomic, strong) NSString  *feiBaPrivateKey;

@end


@implementation MCFeiBaUnit

+ (instancetype)shared
{
    static dispatch_once_t token;
    static id instance;
    dispatch_once(&token, ^{
        instance = [MCFeiBaUnit new];
    });
    
    return instance;
}

- (void )feibaBodyParsWithsuccessBlock:(successBlock )successBlock
{
    if (!self.locationManager) {
        self.locationManager = [[BMKLocationService alloc] init];
        self.locationManager.delegate = self;
    }
    [self.locationManager startUserLocationService];
    
    self.successBlock  = successBlock;
    
    
    //定位服务是否可用
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        [self didFailToLocateUserWithError:nil];
    }
}


#pragma mark - BMKLocationServiceDelegate

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{    
    if (self.successBlock) {
        long ts = [[NSDate new] timeIntervalSince1970]*1000;
        NSString *corpId = [AppStatus.currentUser.email mailDomain];
        NSString *userId = AppStatus.currentUser.email;
        NSString *pars = [NSString stringWithFormat:@"partnerId=%@&corpId=%@&userId=%@&lng=%.2f&lat=%.2f&ts=%ld",MCFeiBaPartnerId,corpId,userId,userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude,ts];
        RSADataSigner *rsaUnit =[[RSADataSigner alloc]initWithPrivateKey:self.feiBaPrivateKey];
        NSString *rsaStr = [rsaUnit signString:pars];
        NSString *body = [NSString stringWithFormat: @"%@&sign=%@", pars,rsaStr];
        self.successBlock(body);
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
    long ts = [[NSDate new] timeIntervalSince1970]*1000;
    NSString *pars = [NSString stringWithFormat:@"partnerId=%@&corpId=123&userId=456&lng=99.99&lat=88.88&ts=%ld",MCFeiBaPartnerId,ts];
    RSADataSigner *rsaUnit =[[RSADataSigner alloc] initWithPrivateKey:self.feiBaPrivateKey];
    NSString *rsaStr = [rsaUnit signString:pars];
    NSString *body = [NSString stringWithFormat: @"%@&sign=%@", pars,rsaStr];
    self.successBlock(body);
}

-(NSString *)feiBaPrivateKey
{
    if (!_feiBaPrivateKey) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"rsa_private_key" ofType:@"pem"];
        _feiBaPrivateKey = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    }
    return _feiBaPrivateKey;
}

@end
