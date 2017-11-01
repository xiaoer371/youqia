//
//  MCLaunchViewController.m
//  NPushMail
//
//  Created by swhl on 16/12/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCLaunchViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "MCTool.h"
#import "MCLaunchModel.h"
#import "MCFileCore.h"
#import "MCFileManager.h"

@interface MCLaunchViewController ()

@property (nonatomic, strong) NSURL          *url;
@property (nonatomic, strong) NSArray        *urls;
@property (nonatomic, strong) UIImageView    *imageView;
@property (nonatomic, strong) UIScrollView   *scrollView;
@property (nonatomic, assign) LaunchViewType   type;
@property (nonatomic, strong) AVPlayerLayer  *playerLayer;
@property (nonatomic, strong) MCLaunchModel  *launchModel;
@property (nonatomic, strong) NSTimer  *timer;
@property (nonatomic, assign) CGFloat  time;
@property (nonatomic, strong) UIButton *jumpBtn;


@end

@implementation MCLaunchViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerLayer.player.currentItem cancelPendingSeeks];
    [self.playerLayer.player.currentItem.asset cancelLoading];
}

- (instancetype)initWithLaunchModel:(MCLaunchModel *)model
{
    self = [super init];
    if (self) {
        self.launchModel = model;
        self.time = 5.0f;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpSubViews];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
}

- (void)setUpSubViews
{
    switch (self.type) {
        case LaunchViewTypeDefault:
        {
            [self.view addSubview:self.imageView];
            [self.view addSubview:self.scrollView];
            [self.view addSubview:self.jumpBtn];

        }
            break;
        case LaunchViewTypeGif:
        {
            [self.view addSubview:self.imageView];

        }
            break;
        case LaunchViewTypeVideo:
        {
            [self.view addSubview:self.imageView];
        }
            break;
        default:
            break;
    }
}
// 监听通知
- (void)setUpNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpAction:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

-(UIButton *)jumpBtn
{
    if (!_jumpBtn) {
        UIButton *jumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        jumpBtn.frame = CGRectMake(ScreenWidth-80, 20, 70, 30);
        jumpBtn.layer.cornerRadius = 8.0f;
        jumpBtn.backgroundColor = AppStatus.theme.tintColor;
        NSString *title = [NSString stringWithFormat:@"%@%.fs",PMLocalizedStringWithKey(@"PM_Mine_Ignore"),self.time];
        [jumpBtn setTitle:title forState:UIControlStateNormal];
        [jumpBtn addTarget:self action:@selector(jumpAction:) forControlEvents:UIControlEventTouchUpInside];
        _jumpBtn = jumpBtn;
    }
    return _jumpBtn;
}

- (void)jumpAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(jumpLaunchView:)]) {
        [self.delegate jumpLaunchView:self];
    }
}

- (void)timeAction:(id)sender
{
    self.time --;
    NSString *title = [NSString stringWithFormat:@"%@%.fs",PMLocalizedStringWithKey(@"PM_Mine_Ignore"),self.time];
    [_jumpBtn setTitle:title forState:UIControlStateNormal];
    
    if (self.time ==0) {
        [self.timer invalidate];
        self.timer = nil;
        [self jumpAction:nil];
    }
    
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth)];
        _imageView.image =[[MCTool shared] getBackgroundImage];
//        [_imageView sd_setImageWithURL:self.url placeholderImage:options:SDWebImageAllowInvalidSSLCertificates];
    }
    return _imageView;
}

-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth -80)];
//        _scrollView.backgroundColor = [UIColor redColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        if (self.launchModel.resources) {
            _scrollView.contentSize = CGSizeMake(self.launchModel.resources.count *ScreenWidth, ScreenHeigth -80);
            for (int i =0 ; i<self.launchModel.resources.count ; i++) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*ScreenWidth, 0, ScreenWidth, ScreenHeigth -80)];
                imageView.image = [UIImage imageWithContentsOfFile:[self getLaunchPath:i]];
                [_scrollView addSubview:imageView];
            }
        }
    }
    return _scrollView;
}

- (NSString *)getLaunchPath:(int)num
{
    MCFileManager *fileManager =[[MCFileCore sharedInstance] getFileModule];
    NSString *path = [[fileManager getCachesFilePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d",self.launchModel.title,num]];
//    DDLogVerbose(@"path == %@",path);
    return path;
}

-(AVPlayerLayer *)playerLayer
{
    if (!_playerLayer) {
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:self.url];
        AVPlayer * player = [AVPlayer playerWithPlayerItem:item];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        _playerLayer.frame = self.view.bounds;
        // [self.view.layer addSublayer:_playerLayer];
        [player play];
    }
    return _playerLayer;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
