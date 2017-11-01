//
//  MCSetAvatorViewController.m
//  NPushMail
//
//  Created by swhl on 16/1/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCSetAvatorViewController.h"
#import "MCInputCodeViewController.h"
#import "MCContactManager.h"
#import "UIImageView+MCCorner.h"
#import "UIImage+Utility.h"
#import "MCAccountManager.h"
#import "MCWorkSpaceManager.h"
#import "MCAppDelegate.h"
#import "MCAppStatus.h"
#import "MCAccountConfig.h"
#import "MCWebViewController.h"
#import "MCAppSetting.h"
#import "MCBaseNavigationViewController.h"

NSString *const MCKeyboardWillChangeFrameNotification3    = @"UIKeyboardWillChangeFrameNotification";

static const CGFloat MCMailavatorHeight = 80.0f;
static const CGFloat MCMailavatorWidth = 80.0f;
static const CGFloat MCMailavatorOriginY = 97.0f;
static const CGFloat  MCMailnameLabelOriginX = 20;


@interface MCSetAvatorViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>{
    
    UIImage    *_avatorImage;
}

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIButton *avatorBtn;
@property (nonatomic,strong) UIImageView *avatorImgView;
@property (nonatomic,strong) UILabel *avatorNoticeLab;
@property (nonatomic,strong) UITextField *nameTextField;
@property (nonatomic,strong) UILabel *avatorTitleLabel;
@property (nonatomic,strong) UIImagePickerController *caremaPicker;
@property (nonatomic,strong) UIButton *startBtn;

@property (nonatomic,strong) MCAccount  *account;

@end

@implementation MCSetAvatorViewController


-(void) dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:_nameTextField];
    
}

- (instancetype)initWithAccount:(MCAccount *)account
{
    self = [super init];
    if (self) {
        _account = account;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self _initSubViews];
    
}
-(void)_initSubViews
{
    _caremaPicker = [[UIImagePickerController alloc] init];
    
    [self.view addSubview:self.bgView];
    [self.bgView addSubview:self.avatorImgView];
    [self.avatorImgView addSubview:self.avatorNoticeLab];
    [self.bgView addSubview:self.avatorBtn];
    [self.bgView addSubview:self.avatorTitleLabel];
    [self.bgView addSubview:self.nameTextField];
    
    UIImageView* lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_nameTextField.frame.origin.x, CGRectGetMaxY(_nameTextField.frame) - 5, CGRectGetWidth(_nameTextField.frame), 1)];
    lineImgView.image = [UIImage imageNamed:@"spaceLine.png"];
    [self.bgView addSubview:lineImgView];
    
    [self.bgView addSubview:self.startBtn];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerKeyBoardNotification];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeKeyBoardNotification];
    
    //开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

}

-(void)setAvatorAction:(UIButton *)sender
{
    [_nameTextField resignFirstResponder];
    
    UIActionSheet * action=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel") destructiveButtonTitle:nil otherButtonTitles:PMLocalizedStringWithKey(@"PM_Login_TakePhoto"), PMLocalizedStringWithKey(@"PM_Login_FromPhoto") ,nil];
    [action showInView:self.view];
}

-(void)startYouQia:(UIButton*)sender
{
     [_nameTextField resignFirstResponder];
    //跳转主界面   上传头像
    [self loadMainViewController];
    
    
    MCAccountManager *accountManager  = [MCAccountManager  shared];
    if (_nameTextField.text.length>0 && ![_nameTextField.text isEqualToString:[self.account.email mailName]]) {
        [accountManager updateAccount:self.account withNickName:_nameTextField.text company:nil dept:nil title:nil success:^{
        } failure:^(NSError *error) {
            //
        }];
    }
    
    if (_avatorImage) {
        [accountManager changeAccount:self.account avatar:_avatorImage success:^{
            //
        } failure:^(NSError *error) {
            //
        }];
    }

}
- (void)loadMainViewController {
    MCAppDelegate*mcAppDelegate = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
    if (!mcAppDelegate.tabBarController) {
        mcAppDelegate.tabBarController.needCheckWorkSpaceWhenAccountChange = YES;
        [mcAppDelegate displayTabBarViewController];
    } else {
        mcAppDelegate.tabBarController.selectedIndex = 0;
        mcAppDelegate.tabBarController.needCheckWorkSpaceWhenAccountChange = YES;
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [MCWorkSpaceManager workSpaceUserCheck];
    }
   
    //检查流量活动
    [[MCAccountManager shared] checkEvent:AppStatus.currentUser success:^(id response) {
        //
        NSString *strUrl = [NSString stringWithFormat:@"https://a.mailchat.cn/app/event_start?d=%@&p=%@&e=%@",AppSettings.user.userId,AppSettings.user.password,AppStatus.currentUser.email];
        MCWebViewController *webController = [[MCWebViewController alloc] initWithUrl:[NSURL URLWithString:strUrl] title:@"获取流量包" style:MCWebViewStyleEvent];
        MCBaseNavigationViewController *webNav = [[MCBaseNavigationViewController alloc] initWithRootViewController:webController];
        UINavigationController *nav = mcAppDelegate.tabBarController.viewControllers[mcAppDelegate.tabBarController.selectedIndex];
        webController.delegate = nav.viewControllers[0];
        [nav presentViewController:webNav animated:YES completion:nil];

    } failure:^(NSError *error) {
        //
    }];
}
#pragma mark -
//注册键盘事件通知
- (void)registerKeyBoardNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

//注销键盘通知
- (void)removeKeyBoardNotification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];

}


#pragma mark - subViews

-(UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:self.view.bounds];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

-(UIImageView *)avatorImgView{
    if (!_avatorImgView) {
        _avatorImgView =[[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - MCMailavatorWidth)/2, MCMailavatorOriginY, MCMailavatorWidth, MCMailavatorHeight)];
        [_avatorImgView cornerRadius];
       _avatorImgView.image = self.account.avatarPlaceHolder;
    }
    return _avatorImgView;
}

-(UILabel *)avatorNoticeLab
{
    if (!_avatorNoticeLab) {
        _avatorNoticeLab =[[UILabel alloc] initWithFrame:CGRectMake(0, /*MCMailavatorOriginY +*/ 50,MCMailavatorWidth, 24)];
        _avatorNoticeLab.backgroundColor =[UIColor clearColor];
        _avatorNoticeLab.textColor =[UIColor whiteColor];
        _avatorNoticeLab.text = PMLocalizedStringWithKey(@"PM_Login_ClickFix");
        _avatorNoticeLab.textAlignment = NSTextAlignmentCenter;
        _avatorNoticeLab.font = [UIFont systemFontOfSize:12.0f];
    }
    return _avatorNoticeLab;
}

-(UIButton *)avatorBtn
{
    if (!_avatorBtn) {
        _avatorBtn  =[UIButton buttonWithType:UIButtonTypeCustom];
        _avatorBtn.frame =_avatorImgView.frame;
        _avatorBtn.backgroundColor =[UIColor clearColor];
        [_avatorBtn addTarget:self action:@selector(setAvatorAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _avatorBtn;
}

-(UILabel *)avatorTitleLabel
{
    if (!_avatorTitleLabel) {
        
        CGFloat  marginY = 50.0f;
//        marginY = ScreenHeigth<481? 10.0f:50.0f;
        _avatorTitleLabel =[[UILabel alloc] initWithFrame:CGRectMake(MCMailnameLabelOriginX, CGRectGetMaxY(_avatorBtn.frame) + marginY, 50, 21)];
        _avatorTitleLabel.font = [UIFont systemFontOfSize:17.0f];
        _avatorTitleLabel.text = PMLocalizedStringWithKey(@"PM_Login_NickName");
    }
    return _avatorTitleLabel;
}

-(UITextField *)nameTextField
{
    if (!_nameTextField) {
        _nameTextField =[[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_avatorTitleLabel.frame), CGRectGetMinY(_avatorTitleLabel.frame) - 10, ScreenWidth - MCMailnameLabelOriginX*2 - _avatorTitleLabel.frame.size.width, 40)];
        _nameTextField.delegate = self;
        _nameTextField.borderStyle = UITextBorderStyleNone;
        _nameTextField.text = self.account.displayName;
        if (_nameTextField.text.length <1) {
            _nameTextField.text = [self.account.email mailName];
        }
    }
    return _nameTextField;
}


-(UIButton *)startBtn
{
    if (!_startBtn) {
        _startBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        _startBtn.frame = CGRectMake(MCMailnameLabelOriginX, CGRectGetMaxY(_nameTextField.frame) + 30, ScreenWidth - MCMailnameLabelOriginX*2, 44);
        _startBtn.layer.cornerRadius = 6;
        _startBtn.layer.masksToBounds = YES;
        _startBtn.backgroundColor = AppStatus.theme.tintColor; //[UIColor colorWithHexString:@"2ea8e6"];
        [_startBtn setTitle:PMLocalizedStringWithKey(@"PM_Login_YQstart") forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(startYouQia:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}


#pragma mark - 键盘处理
- (void)onKeyboardWillShow:(NSNotification *)note {
    [self slideUpView:[note userInfo]];
}

- (void)onKeyboardWillHide:(NSNotification *)note {
    [self slideDownView];
}

- (void)slideUpView:(NSDictionary *)userInfo {
    [self updateSubViewsFrame:-80.0f];
}

- (void)slideDownView {
    [self updateSubViewsFrame:0.0f];
}

- (void)updateSubViewsFrame:(CGFloat)y
{
    if (ScreenHeigth<481) {
        self.bgView.frame =CGRectMake(0, y, ScreenWidth, ScreenHeigth);
    }
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==2) {
        
    }else if(buttonIndex==0||buttonIndex==1){
        
        _caremaPicker.delegate = self;
        _caremaPicker.allowsEditing=YES;
        if (buttonIndex == 1) {
            _caremaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }else {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                return;
            }
            _caremaPicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        }
        if ([_caremaPicker.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
            [_caremaPicker.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_title.png"]forBarMetrics:UIBarMetricsDefault];
        }
        [self presentViewController:_caremaPicker animated:YES completion:^{
            
        }];
    }
}

#pragma mark - ImgPicker_delegate
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker.videoQuality = UIImagePickerControllerQualityTypeLow;
    _avatorImage = image;
    UIImage* img = [UIImage scaleToSize:image size:CGSizeMake(MCMailavatorHeight, MCMailavatorHeight)];
    self.avatorImgView.image =img;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
