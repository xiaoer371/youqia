//
//  MCImapHelpNoteViewController.m
//  NPushMail
//
//  Created by zhang on 16/1/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCImapHelpNoteViewController.h"

@interface MCImapHelpNoteViewController ()

@property (nonatomic,strong)UIImageView *noteImageView;

@end

@implementation MCImapHelpNoteViewController

- (id)initWithSelectEmailIndex:(MCMailType)mcMailType showPassWordNote:(BOOL)passWordNote {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self setUpWithSelectMailType:mcMailType showPassWordNote:passWordNote];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setUpWithSelectMailType:(MCMailType)mcMailType showPassWordNote:(BOOL)passWordNote {
    
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Login_IMAPSetting");
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT)];
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    
    _noteImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    _noteImageView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:_noteImageView];

    //note图片
    NSString*imageName ;
    switch (mcMailType) {
        case MCMailType163:
        {
          imageName = passWordNote?@"163PassWord.png":@"IMAP163.png";
        }
            break;
        case MCMailTypeQQ://qq邮箱
        {
           imageName = passWordNote?@"":@"IMAPQQ.png";
        }
            break;
        case MCMailTypeSina://新浪邮箱
        {
          imageName = @"IMAPsina.png";
        }
        default:
            break;
    }
    
    UIImage*image = [UIImage imageNamed:imageName];
    CGFloat h = (ScreenWidth/image.size.width)*image.size.height;
    self.noteImageView.frame = CGRectMake(0, 0, ScreenWidth, h);
    self.noteImageView.image = image;
    scrollView.contentSize = CGSizeMake(0, self.noteImageView.frame.size.height);
}

- (void)leftNavigationBarButtonItemAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
