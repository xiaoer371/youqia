//
//  MCAvailablePhotoViewController.m
//  NPushMail
//
//  Created by swhl on 16/6/28.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAvailablePhotoViewController.h"
#import "MCIMChatNoticeCell.h"
#import "UIView+MCExpand.h"

static const CGFloat imagVHeight = 132;
static const CGFloat imagVWidth = 132;
static const CGFloat originY = 110;
static const CGFloat btnHeight = 44;
static const CGFloat btnWidth = 260;
static const CGFloat originSubTitleX = 20;

@interface MCAvailablePhotoViewController ()

@end

@implementation MCAvailablePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.leftNavigationBarButtonItem.image = nil;
    self.rightNavigationBarButtonItem.title  =PMLocalizedStringWithKey(@"PM_Common_Cancel");
    UIImageView* imageV = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - imagVWidth)/2, originY, imagVWidth, imagVHeight)];
    imageV.image = [UIImage imageNamed:@"photoLock.png"];
    [self.view addSubview:imageV];
    
    UILabel* titileLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageV.frame) + 20, ScreenWidth, 21)];
    titileLabel.backgroundColor = [UIColor clearColor];
    titileLabel.text = PMLocalizedStringWithKey(@"PM_Login_PhotoreStricted");
    titileLabel.textAlignment = NSTextAlignmentCenter;
    titileLabel.font = [UIFont systemFontOfSize:17.0f];
    titileLabel.textColor = [UIColor blackColor];
    [self.view addSubview:titileLabel];
    
    if (EGOVersion_iOS8) {
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((ScreenWidth - btnWidth)/2, CGRectGetMaxY(titileLabel.frame) + 30, btnWidth, btnHeight);
        UIImage *image = [UIImage imageNamed:@"startYouQiaBtnBg.png"];
        [btn setBackgroundImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(8, 20, 8, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [btn setTitle:PMLocalizedStringWithKey(@"PM_Login_PhotoSet") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }else {
        UILabel* subTitileLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titileLabel.frame) + 20, ScreenWidth, 21)];
        subTitileLabel.backgroundColor = [UIColor clearColor];
        subTitileLabel.text = PMLocalizedStringWithKey(@"PM_Login_HowToSet");
        subTitileLabel.textAlignment = NSTextAlignmentCenter;
        subTitileLabel.numberOfLines = 0;
        subTitileLabel.font = [UIFont systemFontOfSize:17.0f];
        subTitileLabel.textColor = [UIColor blackColor];
        CGSize subTitleSize = [subTitileLabel estimateUISizeByWidth:ScreenWidth - originSubTitleX*2];
        [subTitileLabel moveToX:originSubTitleX];
        subTitileLabel.mc_width = ScreenWidth - originSubTitleX*2;
        subTitileLabel.mc_height = subTitleSize.height;
        [self.view addSubview:subTitileLabel];
    }

}

-(void) openSettings {
    if (EGOVersion_iOS8) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

-(void)rightNavigationBarButtonItemAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
