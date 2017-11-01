//
//  MCGestureSetViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/4/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCGestureSetViewController.h"
#import "PCCircleView.h"
#import "PCCircleViewConst.h"
#import "PCLockLabel.h"
#import "PCCircleInfoView.h"
#import "PCCircle.h"
#import "MCAppDelegate.h"
#import "MCAppSetting.h"
#import "UIView+MJExtension.h"
#import "MCGestuerPassWordViewController.h"
#import "MCReloginViewController.h"

@interface MCGestureSetViewController ()<CircleViewDelegate>

/**
 *  重设按钮
 */
@property (nonatomic, strong) UIButton *resetBtn;

/**
 *  提示Label
 */
@property (nonatomic, strong) PCLockLabel *msgLabel;

/**
 *  解锁界面
 */
@property (nonatomic, strong) PCCircleView *lockView;

/**
 *  infoView
 */
@property (nonatomic, strong) PCCircleInfoView *infoView;

@end

static const CGFloat setTypeOriginY = 20;
static const CGFloat modifyTypeOriginY = 50;

@implementation MCGestureSetViewController {
    int errorCounts;
    GestureViewControllerType _ctrlType;
}

- (id)initWithCtrlType:(GestureViewControllerType) type {
    if (self = [super init]) {
        _ctrlType = type;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_ctrlType == GestureViewControllerTypeLogin) {
        [self.navigationController.navigationBar setHidden:YES];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView* backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth)];
    backImageView.backgroundColor = [UIColor colorWithHexString:@"f7f7f9"];
    errorCounts = 0;
    [self.view addSubview:backImageView];
    [self.view sendSubviewToBack:backImageView];
    // 1.界面相同部分生成器
    [self setupSameUI];
    // 2.界面不同部分生成器
    [self setupDifferentUI];
}

#pragma mark - 创建UIBarButtonItem
- (UIBarButtonItem *)itemWithTitle:(NSString *)title target:(id)target action:(SEL)action tag:(NSInteger)tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.frame = (CGRect){CGPointZero, {100, 20}};
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    button.tag = tag;
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [button setHidden:YES];
    self.resetBtn = button;
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

#pragma mark - 界面不同部分生成器
- (void)setupDifferentUI
{
    switch (_ctrlType) {
        case GestureViewControllerTypeSetting:
            [self setupSubViewsSettingVc];
            break;
        case GestureViewControllerTypeLogin:
            [self setupSubViewsLoginVc];
            break;
        case GestureViewControllerTypeModify:
            [self setupSubViewsModifyVc];
            break;
        case GestureViewControllerTypeVerify:
            [self setupSubViewsModifyVc];
            break;
        default:
            break;
    }
}

#pragma mark - 界面相同部分生成器
- (void)setupSameUI
{
    // 解锁界面
    PCCircleView *lockView = [[PCCircleView alloc] init];
    lockView.delegate = self;
    self.lockView = lockView;
    [self.view addSubview:lockView];
    
    PCLockLabel *msgLabel = [[PCLockLabel alloc] init];
    msgLabel.frame = CGRectMake(0, 0, kScreenW, 14);
    msgLabel.center = CGPointMake(kScreenW/2, CGRectGetMinY(lockView.frame) - 30);
    self.msgLabel = msgLabel;
    [self.view addSubview:msgLabel];
}

#pragma mark - 设置手势密码界面
- (void)setupSubViewsSettingVc
{
    //如果是设置页面的话需先清空原密码
    [PCCircleViewConst saveGesture:nil Key:gestureOneSaveKey];
    [self.lockView setType:CircleViewTypeSetting];
    
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Mine_SetGesturePassword");
    [self.msgLabel showNormalMsg:gestureTextBeforeSet];//提示绘制解锁图案
    
    //顶部用来显示上次绘制的图案
    PCCircleInfoView *infoView = [[PCCircleInfoView alloc] init];
    infoView.frame = CGRectMake(0, 0, CircleRadius * 2 * 0.6, CircleRadius * 2 * 0.6);
    infoView.center = CGPointMake(kScreenW/2, CGRectGetMinY(self.msgLabel.frame) - CGRectGetHeight(infoView.frame)/2 - 10);
    self.infoView = infoView;
    [self.view addSubview:infoView];
    
    [self.msgLabel setMj_y:setTypeOriginY];
    [self.infoView setMj_y:CGRectGetMaxY(self.msgLabel.frame) + 5];
    [self.lockView setMj_y:CGRectGetMaxY(self.infoView.frame) + 10];

}

#pragma mark - 修改手势密码界面
-(void)setupSubViewsModifyVc {
    [self.msgLabel setMj_y:modifyTypeOriginY];
    [self.lockView setMj_y:CGRectGetMaxY(self.msgLabel.frame) + 10];
    //先验证旧的手势密码，然后再设置新的密码
    [self.lockView setType:CircleViewTypeVerify];
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Mine_SetAgainGesturePassword");
    //提示验证原手势密码
    [self.msgLabel showNormalMsg:gestureTextOldGesture];
}

#pragma mark - 登陆手势密码界面
- (void)setupSubViewsLoginVc
{
    [self.lockView setType:CircleViewTypeLogin];
    [self.navigationController.navigationBar setHidden:YES];
    [self.msgLabel showNormalMsg:PMLocalizedStringWithKey(@"PM_Mine_PleaseGesturePassword")];//提示绘制解锁图案
    // 头像
    UIImageView  *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, 65, 65);
    imageView.center = CGPointMake(kScreenW/2, kScreenH/6);
    [imageView setImage:[UIImage imageNamed:@"youqiaIcon.png"]];
    [self.view addSubview:imageView];
    
    CGSize btnSize = [PMLocalizedStringWithKey(@"PM_Mine_ForgetGesturePassword") boundingRectWithSize:CGSizeMake(99999, 21) options:(NSStringDrawingUsesLineFragmentOrigin)
                                                                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} context:nil].size;
    
    UIButton* forgetPwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetPwdBtn.frame = CGRectMake((ScreenWidth - btnSize.width)/2, ScreenHeigth - 40, btnSize.width, 21);
    [forgetPwdBtn setTitle:PMLocalizedStringWithKey(@"PM_Mine_ForgetGesturePassword") forState:UIControlStateNormal];
    [forgetPwdBtn setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
    [forgetPwdBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [forgetPwdBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [forgetPwdBtn addTarget:self action:@selector(forgetPwd) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgetPwdBtn];
    
}

-(void) forgetPwd {
    MCReloginViewController *v = [[MCReloginViewController alloc] init];
    __weak MCGestureSetViewController *weakSelf = self;
    v.gestureLoginSuccess = ^{
        if (weakSelf.resultBlock) {
            weakSelf.resultBlock(YES, nil);
        }
    };
    [self.navigationController pushViewController:v animated:YES];
}

#pragma mark - 创建UIButton
- (void)creatButton:(UIButton *)btn frame:(CGRect)frame title:(NSString *)title alignment:(UIControlContentHorizontalAlignment)alignment tag:(NSInteger)tag
{
    btn.frame = frame;
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setContentHorizontalAlignment:alignment];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [btn addTarget:self action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

#pragma mark - button点击事件
- (void)didClickBtn:(UIButton *)sender
{
    NSLog(@"%ld", (long)sender.tag);
    switch (sender.tag) {
        case buttonTagReset:
        {
            NSLog(@"点击了重设按钮");
            // 1.隐藏按钮
            [self.resetBtn setHidden:YES];
            // 2.infoView取消选中
            [self infoViewDeselectedSubviews];
            // 3.msgLabel提示文字复位
            [self.msgLabel showNormalMsg:gestureTextBeforeSet];
            // 4.清除之前存储的密码
            [PCCircleViewConst saveGesture:nil Key:gestureOneSaveKey];
        }
            break;
        case buttonTagManager:
        {
            NSLog(@"点击了管理手势密码按钮");
            
        }
            break;
        case buttonTagForget:
            NSLog(@"点击了登录其他账户按钮");
            
            break;
        default:
            break;
    }
}

#pragma mark - circleView - delegate
#pragma mark - circleView - delegate - setting
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type connectCirclesLessThanNeedWithGesture:(NSString *)gesture
{
    NSString *gestureOne = [PCCircleViewConst getGestureWithKey:gestureOneSaveKey];
    // 看是否存在第一个密码
    if ([gestureOne length]) {
        [self.resetBtn setHidden:NO];
        DDLogVerbose(@"与上次绘制不一致，请重新绘制");
        [self.msgLabel showWarnMsgAndShake:gestureTextDrawAgainError];
    } else {
        DDLogVerbose(@"密码长度不合法%@", gesture);
        [self.msgLabel showWarnMsgAndShake:gestureTextConnectLess];
    }
}

- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteSetFirstGesture:(NSString *)gesture
{
    DDLogVerbose(@"获得第一个手势密码%@", gesture);
    //提示再次绘制解锁图案
    [self.msgLabel showNormalMsg:gestureTextDrawAgain];
    // infoView展示对应选中的圆(顶部展示选中的状态)
    [self infoViewSelectedSubviewsSameAsCircleView:view];
}

- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteSetSecondGesture:(NSString *)gesture result:(BOOL)equal
{
    DDLogVerbose(@"获得第二个手势密码%@",gesture);
    
    if (equal) {
        DDLogVerbose(@"两次手势匹配！可以进行本地化保存了");
        [self.msgLabel showWarnMsg:gestureTextSetSuccess];
        [PCCircleViewConst saveGesture:gesture Key:gestureFinalSaveKey];
        [AppSettings setIsPassGesturePwd:YES];//设置验证通过
        [AppSettings setGesturePasswordFlag:YES];//设置手势密码开关已开启
        [AppSettings setTouchIdFlag:NO];//关闭指纹验证
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[MCGestuerPassWordViewController class]]) {
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
    } else {
        DDLogVerbose(@"两次手势不匹配！");
        [self.msgLabel showWarnMsgAndShake:gestureTextDrawAgainError];
        [self.resetBtn setHidden:NO];
    }
}

#pragma mark - circleView - delegate - login or verify gesture
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteLoginGesture:(NSString *)gesture result:(BOOL)equal
{
    // 此时的type有两种情况 Login or verify
    if (type == CircleViewTypeLogin) {
        if (equal) {
            DDLogVerbose(@"登陆成功！");
            [AppSettings setIsPassGesturePwd:YES];
            if (self.resultBlock) {
                self.resultBlock(YES, nil);
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            DDLogVerbose(@"密码错误！");
            if (errorCounts == 4) {
                [self forgetPwd];
                return;
            }
            errorCounts = errorCounts + 1;
            [self.msgLabel showWarnMsgAndShake:[NSString stringWithFormat:@"密码错误，还可以再输入%d次",gestureTextGestureVerifyErrorCoount - errorCounts]];
        }
    } else if (type == CircleViewTypeVerify) {
        if (equal) {
            DDLogVerbose(@"验证成功，跳转到设置手势界面");
            if (_ctrlType == GestureViewControllerTypeVerify) {
                //验证成功给回调
                if (self.verifyBlock) {
                    self.verifyBlock(YES);
                    [self.navigationController popViewControllerAnimated:YES];
                }
                return;
            }
            MCGestureSetViewController *gestureVc = [[MCGestureSetViewController alloc] initWithCtrlType:GestureViewControllerTypeSetting];
            [self.navigationController pushViewController:gestureVc animated:YES];
        } else {
            DDLogVerbose(@"原手势密码输入错误！");
            if (self.verifyBlock) {
                self.verifyBlock(NO);
            }
            [self.msgLabel showWarnMsgAndShake:gestureTextGestureVerifyError];
        }
    }
}

#pragma mark - infoView展示方法, 让infoView对应按钮选中
- (void)infoViewSelectedSubviewsSameAsCircleView:(PCCircleView *)circleView
{
    for (PCCircle *circle in circleView.subviews) {
        if (circle.state == CircleStateSelected || circle.state == CircleStateLastOneSelected) {
            
            for (PCCircle *infoCircle in self.infoView.subviews) {
                if (infoCircle.tag == circle.tag) {
                    [infoCircle setState:CircleStateSelected];
                }
            }
        }
    }
}

#pragma mark - 让infoView对应按钮取消选中
- (void)infoViewDeselectedSubviews
{
    [self.infoView.subviews enumerateObjectsUsingBlock:^(PCCircle *obj, NSUInteger idx, BOOL *stop) {
        [obj setState:CircleStateNormal];
    }];
}

-(void)leftBarButtonAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
