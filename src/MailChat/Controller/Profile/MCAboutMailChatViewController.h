//
//  MCAboutMailChatViewController.h
//  NPushMail
//
//  Created by zhang on 16/4/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"

@interface MCAboutMailChatViewController : MCBaseSubViewController
@property (weak, nonatomic) IBOutlet UIImageView *mcLogoImgeView;
@property (weak, nonatomic) IBOutlet UILabel *mcVersonLable;
@property (weak, nonatomic) IBOutlet UIButton *evaluationButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (weak, nonatomic) IBOutlet UIView *mcIconBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *mcEvaluationBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *mcInfoView;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@end
