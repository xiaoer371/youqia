//
//  MCInviteViewController.m
//  NPushMail
//
//  Created by zhang on 16/4/13.
//  Copyright © 2016年 sprite. All rights reserved.
//


#import "MCInviteViewController.h"
#import "MCTool.h"

@interface MCInviteViewController ()
@property (weak, nonatomic) IBOutlet UIButton *inviteBtn;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation MCInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubViews];
}

- (void)initSubViews {
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Invite_Friends");
    self.contentLabel.text = PMLocalizedStringWithKey(@"PM_Invite_qrcode");
    [self.inviteBtn setTitle:PMLocalizedStringWithKey(@"PM_Message_SendInvitations") forState:UIControlStateNormal];
    self.inviteBtn.backgroundColor = AppStatus.theme.tintColor;
    self.inviteBtn.layer.cornerRadius = 5.0f;
}

- (IBAction)inviteAction:(id)sender {
    
    [[MCTool shared] shareYouqia];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
