//
//  MCAppStatus.m
//  NPushMail
//
//  Created by admin on 12/24/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCAppStatus.h"
#import "MCAppDelegate.h"

@interface MCAppStatus ()

@property (nonatomic, strong) Reachability *reachability;

@end

@implementation MCAppStatus

- (instancetype)init
{
    if (self=[super init]) {
        [self setup];
    }
    
    return self;
}

+ (instancetype)shared
{
    static dispatch_once_t token;
    static id instance;
    dispatch_once(&token, ^{
        instance = [MCAppStatus new];
    });
    
    return instance;
}

- (void)setup
{
    _documentDir = [[self class] applicationDocumentsDirectory];
    _reachability = [Reachability reachabilityForInternetConnection];
    __weak typeof(self) weakSelf = self;
    _reachability.reachableBlock = ^(Reachability *rechability){
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.networkStatus = rechability.currentReachabilityStatus;
            DDLogVerbose(@"Network status = %ld",(long)weakSelf.networkStatus);
        });
    };
    _reachability.unreachableBlock = ^(Reachability *rechability){
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.networkStatus = rechability.currentReachabilityStatus;
            DDLogVerbose(@"Network status = %ld",(long)weakSelf.networkStatus);
        });
    };
    
    [_reachability startNotifier];
    self.networkStatus = _reachability.currentReachabilityStatus;
    DDLogVerbose(@"Network status = %ld",(long)self.networkStatus);
}

- (MCTouchIdWindow *)touchIdWindow {
    MCAppDelegate *mcAppDelegate = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
    return mcAppDelegate.touchWindow;
}

- (MCGestureWindow *)gestureWindow {
    MCAppDelegate *mcAppDelegate = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
    return mcAppDelegate.gestureWindow;
}

+ (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

@end
