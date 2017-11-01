//
//  MCPCNoticeViewController.m
//  NPushMail
//
//  Created by swhl on 17/2/9.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCPCNoticeViewController.h"
#import "NSString+Extension.h"

@interface MCPCNoticeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *pcLabel;
@property (weak, nonatomic) IBOutlet UIButton *noticeBtn;
@property (weak, nonatomic) IBOutlet UIButton *fileHelpBtn;

@end

@implementation MCPCNoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpSubViews];
    
}

- (void)setUpSubViews
{
    self.viewTitle = PMLocalizedStringWithKey(@"PM_PCWindows_navTitle");
    self.pcLabel.text = PMLocalizedStringWithKey(@"PM_PCWindows_title");
    
    NSString *title = PMLocalizedStringWithKey(@"PM_PCWindows_noticeTitle");
    CGSize size = [title mcStringSizeWithFont:15.0 maxWidth:160 maxHight:50];
    [self.noticeBtn setTitle:title forState:UIControlStateNormal];
     self.noticeBtn.titleEdgeInsets = UIEdgeInsetsMake(80, -(size.width/2-10), 0, 0);
    
    
    title = PMLocalizedStringWithKey(@"PM_PCWindows_fileTitle");
    size = [title mcStringSizeWithFont:15.0 maxWidth:160 maxHight:50];
    [self.fileHelpBtn setTitle:title forState:UIControlStateNormal];
    self.fileHelpBtn.titleEdgeInsets = UIEdgeInsetsMake(80,  -(size.width/2-10), 0, 0);

}

- (IBAction)noticeAction:(UIButton *)sender {
    
}

- (IBAction)fileHelpAction:(UIButton *)sender {
    
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
