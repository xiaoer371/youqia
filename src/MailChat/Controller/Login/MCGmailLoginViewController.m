//
//  MCGmailLoginViewController.m
//  NPushMail
//
//  Created by swhl on 16/10/8.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCGmailLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "OIDWebViewController.h"
#import "MCAppDelegate.h"
#import "MCGmailProvider.h"
#import "MCGmailAuth.h"
#import "MCAccountManager.h"
#import "MCAccountConfig.h"

@interface MCGmailLoginViewController ()

/// Gmail 登录提示View
@property (nonatomic, strong) ShapeLoadingView *waitView;
@property (nonatomic, strong) UIView  *wView;

@end

@implementation MCGmailLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self gotoGmailAuth];
}

#pragma mark - Gmail

- (void)gotoGmailAuth
{
    
    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
    // https://accounts.google.com/.well-known/openid-configuration
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"gmail" ofType:@"json"];
    NSData *discoveryData = [NSData dataWithContentsOfFile:jsonPath];
    OIDServiceDiscovery *discovery = [[OIDServiceDiscovery alloc] initWithJSONData:discoveryData error:nil];
    OIDServiceConfiguration *configuration =
    [[OIDServiceConfiguration alloc] initWithDiscoveryDocument:discovery];
    
    // builds authentication request
    OIDAuthorizationRequest *request =
    [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                  clientId:kClientID
                                                    scopes:@[OIDScopeOpenID,
                                                             OIDScopeProfile,
                                                             OIDScopeEmail,
                                                             @"https://mail.google.com/"]
                                               redirectURL:redirectURI
                                              responseType:OIDResponseTypeCode
                                      additionalParameters:@{@"audience" : kServerClientID}];
    // performs authentication request
    DDLogVerbose(@"Initiating authorization request with scope: %@", request.scope);
    AppStatus.currentAuthorizationFlow =
    [OIDAuthState authStateByPresentingAuthorizationRequest:request presentingViewController:self
                                                   callback:^(OIDAuthState *_Nullable authState,
                                                              NSError *_Nullable error) {
                                                       if (authState) {
                                                           DDLogVerbose(@"Got authorization tokens. Access token: %@", authState.lastTokenResponse.accessToken);
                                                           [MCGmailAuth requestAccountWithAuthState:authState success:^(MCAccount *account) {
                                                               DDLogVerbose(@"get user success");
                                                               [self.delegate authViewController:self didAuthWithAccount:account];
                                                           } failure:^(NSError *error) {
                                                               DDLogError(@"Get gmail user info error: %@",error);
                                                               [self.delegate authViewController:self didFailedWithError:error];
                                                           }];
                                                           
                                                       } else {
                                                           DDLogVerbose(@"Authorization error: %@", [error localizedDescription]);
                                                           // 用户拒绝，网络请求失败
                                                           [self.delegate authViewController:self didFailedWithError:error];
                                                       }
                                                   }];
    
    [self createMockNavBar];
}

- (void)authState:(OIDAuthState *)state didEncounterAuthorizationError:(nonnull NSError *)error {
    DDLogVerbose(@"Received authorization error: %@", error);
}

-(void)createMockNavBar
{
    OIDWebViewController *vc= (OIDWebViewController*)self.presentedViewController;
    vc.offsetY = NAVIGATIONBARHIGHT;
    
    UIView *aView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, NAVIGATIONBARHIGHT)];
    aView.backgroundColor = AppStatus.theme.tintColor;
    [self.presentedViewController.view addSubview:aView];
    
    UILabel *titleLab =[[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-200)/2, 33, 200, 18)];
    titleLab.text = @"Gmail";
    titleLab.font = [UIFont boldSystemFontOfSize:kMCBaseViewNavBarTitleFont];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.backgroundColor = [UIColor clearColor];
    titleLab.textColor = AppStatus.theme.navgationBarTitleTextColor;
    [aView addSubview:titleLab];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.backgroundColor = AppStatus.theme.tintColor;
    cancleBtn.frame = CGRectMake(10, 33, 22, 22);
    [cancleBtn setImage:AppStatus.theme.commonBackImage forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(dismisspresentedViewController:) forControlEvents:UIControlEventTouchUpInside];
    [aView addSubview:cancleBtn];
    
    [self performSelector:@selector(creatWaitView:) withObject:nil afterDelay:.5f];
    
}

- (void)creatWaitView:(id)sender
{
    if (!_waitView) {
        _wView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _wView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_wView];
        UIView *loadingView =[[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-100/2, self.view.frame.size.height/2-120/2, 100, 120)];
        loadingView.alpha = 1;
        loadingView.backgroundColor = [UIColor clearColor];
        [_wView addSubview:loadingView];
        _waitView =  [[ShapeLoadingView alloc] initWithFrame:CGRectMake(0,0, 100, 120) title:@"加载中..."];
        _waitView.backgroundColor =[UIColor clearColor];
        [loadingView addSubview:_waitView];
        
        [_waitView startAnimating];
    }
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Login_Gmail");
    self.leftNavigationBarButtonItem.image = nil;
    self.leftNavigationBarButtonItem.enabled = NO;
}

- (void)dismisspresentedViewController:(UIButton *)sender
{   [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

@end

@interface ShapeLoadingView ()

@property (nonatomic, assign) int stepNumber;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) NSString *titleString;


@end

@implementation ShapeLoadingView


#define ANIMATION_DURATION_SECS 0.5f

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.titleString=title;
        [self step];
    }
    return self;
}


-(void) step
{
    _stepNumber = 0;

    _shapView=[[UIImageView alloc] init];
    _shapView.frame=CGRectMake(self.frame.size.width/2-31/2, 0, 31, 31);
    _shapView.image=[UIImage imageNamed:@"loading_circle"];
    _shapView.contentMode=UIViewContentModeScaleAspectFit;
    [self addSubview:_shapView];
    
    //阴影
    _shadowView=[[UIImageView alloc] init];
    _shadowView.frame=CGRectMake(self.frame.size.width/2-37/2, self.frame.size.height-2.5-30, 37, 2.5);
    _shadowView.image=[UIImage imageNamed:@"loading_shadow"];
    [self addSubview:_shadowView];
    
    
    UILabel *_label=[[UILabel alloc] init];
    _label.frame=CGRectMake(0, self.frame.size.height-20, self.frame.size.width, 20);
    _label.textColor=[UIColor grayColor];
    _label.textAlignment=NSTextAlignmentCenter;
    _label.text=_titleString;
    _label.font=[UIFont systemFontOfSize:13.0f];
    
    [self addSubview:_label];
    
    _fromValue=_shapView.frame.size.height/2;
    _toValue=self.frame.size.height-30-_shapView.frame.size.height/2-_shadowView.frame.size.height;
    _scalefromValue=0.3f;
    _scaletoValue=1.0f;
    
    self.alpha=0;
    
}

-(void) startAnimating
{
    if (!_isAnimating)
    {
        _isAnimating = YES;
        self.alpha=1;
        _timer = [NSTimer scheduledTimerWithTimeInterval:ANIMATION_DURATION_SECS target:self selector:@selector(animateNextStep) userInfo:nil repeats:YES];
    }

}

-(void) stopAnimating
{
    _isAnimating = NO;
    [_timer invalidate];
    _stepNumber = 0;
    self.alpha=0;
    [_shapView.layer removeAllAnimations];
    [_shadowView.layer removeAllAnimations];
    _shapView.image=[UIImage imageNamed:@"loading_circle"];
}


-(void)animateNextStep
{
    switch (_stepNumber)
    {
        case 0:
        {
            _shapView.image=[UIImage imageNamed:@"loading_circle"];
            [self loadingAnimation:_fromValue toValue:_toValue timingFunction:kCAMediaTimingFunctionEaseIn];
            [self scaleAnimation:_scalefromValue toValue:_scaletoValue timingFunction:kCAMediaTimingFunctionEaseIn];
        }
            break;
        case 1:
        {
            _shapView.image=[UIImage imageNamed:@"loading_square"];
            [self loadingAnimation:_toValue toValue:_fromValue timingFunction:kCAMediaTimingFunctionEaseOut];
            [self scaleAnimation:_scaletoValue toValue:_scalefromValue timingFunction:kCAMediaTimingFunctionEaseIn];
            
        }
            break;
        case 2:
        {
            _shapView.image=[UIImage imageNamed:@"loading_square"];
            [self loadingAnimation:_fromValue toValue:_toValue timingFunction:kCAMediaTimingFunctionEaseIn];
            [self scaleAnimation:_scalefromValue toValue:_scaletoValue timingFunction:kCAMediaTimingFunctionEaseIn];
        }
            break;
        case 3:
        {
            _shapView.image=[UIImage imageNamed:@"loading_triangle"];
            [self loadingAnimation:_toValue toValue:_fromValue timingFunction:kCAMediaTimingFunctionEaseOut];
            [self scaleAnimation:_scaletoValue toValue:_scalefromValue timingFunction:kCAMediaTimingFunctionEaseIn];

        }
            break;
        case 4:
        {
            _shapView.image=[UIImage imageNamed:@"loading_triangle"];
            [self loadingAnimation:_fromValue toValue:_toValue timingFunction:kCAMediaTimingFunctionEaseIn];
            [self scaleAnimation:_scalefromValue toValue:_scaletoValue timingFunction:kCAMediaTimingFunctionEaseIn];
        }
            
            break;
        case 5:
        {
            _shapView.image=[UIImage imageNamed:@"loading_circle"];
            [self loadingAnimation:_toValue toValue:_fromValue timingFunction:kCAMediaTimingFunctionEaseOut];
            [self scaleAnimation:_scaletoValue toValue:_scalefromValue timingFunction:kCAMediaTimingFunctionEaseIn];
            _stepNumber = -1;
            
        }
            break;
        default:
            break;
    }
    _stepNumber++;
}


-(void) loadingAnimation:(float)fromValue toValue:(float)toValue timingFunction:(NSString * const)tf
{
    //位置
    CABasicAnimation *panimation = [CABasicAnimation animation];
    panimation.keyPath = @"position.y";
    panimation.fromValue =@(fromValue);
    panimation.toValue = @(toValue);
    panimation.duration = ANIMATION_DURATION_SECS;
    
    panimation.timingFunction = [CAMediaTimingFunction functionWithName:tf];
    
    
    //旋转
    CABasicAnimation *ranimation = [CABasicAnimation animation];
    ranimation.keyPath = @"transform.rotation";
    ranimation.fromValue =@(0);
    ranimation.toValue = @(M_PI_2);
    ranimation.duration = ANIMATION_DURATION_SECS;
    
    ranimation.timingFunction = [CAMediaTimingFunction functionWithName:tf];
    
    
    
    //组合
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    group.animations = @[ panimation,ranimation];
    group.duration = ANIMATION_DURATION_SECS;
    group.beginTime = 0;
    group.fillMode=kCAFillModeForwards;
    group.removedOnCompletion = NO;
    
    
    [_shapView.layer addAnimation:group forKey:@"basic"];

}

-(void) scaleAnimation:(float) fromeValue toValue:(float)toValue timingFunction:(NSString * const)tf
{
    
    //缩放
    CABasicAnimation *sanimation = [CABasicAnimation animation];
    sanimation.keyPath = @"transform.scale";
    sanimation.fromValue =@(fromeValue);
    sanimation.toValue = @(toValue);
    sanimation.duration = ANIMATION_DURATION_SECS;
    
    sanimation.fillMode = kCAFillModeForwards;
    sanimation.timingFunction = [CAMediaTimingFunction functionWithName:tf];
    sanimation.removedOnCompletion = NO;
    
    [_shadowView.layer addAnimation:sanimation forKey:@"shadow"];
}

- (BOOL)isAnimating
{
    return _isAnimating;
}

- (void)dealloc
{

}
@end




