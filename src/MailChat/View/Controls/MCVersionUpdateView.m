//
//  MCVersionUpdateView.m
//  NPushMail
//
//  Created by zhang on 16/6/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCVersionUpdateView.h"
#import "MCVersionManager.h"
#import "MCAppSetting.h"
#import "MCAppDelegate.h"
#import "MCTabBarController.h"
#import "MCIMChatViewController.h"
#import "UITabBar+badge.h"

#import "UIAlertView+Blocks.h"

#import "MCContactManager.h"
#import "MCIMConversationManager.h"
@interface MCVersionUpdateView ()

@property (nonatomic,strong)MCVersionModel *versionModel;
@end

@implementation MCVersionUpdateView

#define SPACE             20

const static CGFloat  mainTitleFoutSize = 21.0f;
const static CGFloat  subTitleFontSize  = 14.0f;
const static CGFloat  titleViewHight    = 65.0f;
const static CGFloat  titlelViewSpace   = 14.0f;
const static CGFloat  contentViewWidth  = 254.0f;


- (id)initWithVersionInfo:(MCVersionModel*)versionModel {
    
    if (self = [super init]) {
        _versionModel = versionModel;
        [self setUp];
    }
    return self;
}

- (void)setUp{
    
    UIView*titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, contentViewWidth, titleViewHight)];
    titleView.backgroundColor = [UIColor clearColor];
    UILabel*mainTitleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, titlelViewSpace, contentViewWidth, [self hightWihtContent:_versionModel.title fontSize:mainTitleFoutSize])];
    mainTitleLable.font = [UIFont boldSystemFontOfSize:mainTitleFoutSize];
    mainTitleLable.text = _versionModel.title;
    mainTitleLable.textAlignment = NSTextAlignmentCenter;
    mainTitleLable.textColor = AppStatus.theme.tintColor;
    [titleView addSubview:mainTitleLable];
    
    NSString*subTitle = [NSString stringWithFormat:PMLocalizedStringWithKey(@"PM_UpdateVersion_note")];
    
    UILabel*subTitleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, titlelViewSpace+ mainTitleLable.frame.size.height + 9, contentViewWidth, [self hightWihtContent:subTitle fontSize:subTitleFontSize])];
    subTitleLable.text = subTitle;
    subTitleLable.textAlignment = NSTextAlignmentCenter;
    subTitleLable.textColor = AppStatus.theme.tintColor;
    subTitleLable.font = [UIFont systemFontOfSize:subTitleFontSize];
    [titleView addSubview:subTitleLable];
    
    UIView*line = [[UIView alloc]initWithFrame:CGRectMake(0,subTitleLable.frame.size.height+subTitleLable.frame.origin.y+titlelViewSpace, contentViewWidth, 1)];
    line.backgroundColor = [UIColor colorWithHexString:@"e8e8e8"];
    [self addSubview:line];
    [self addSubview:titleView];
    
    
    NSString*updateNote = [NSString stringWithFormat:PMLocalizedStringWithKey(@"PM_UpdateVersion_title"),_versionModel.title];
    
    UILabel*updateNoteLable = [[UILabel alloc]initWithFrame:CGRectMake(0, line.frame.size.height+line.frame.origin.y+titlelViewSpace, contentViewWidth, [self hightWihtContent:updateNote fontSize:subTitleFontSize])];
    updateNoteLable.backgroundColor = [UIColor clearColor];
    updateNoteLable.text = updateNote;
    updateNoteLable.font = [UIFont systemFontOfSize:subTitleFontSize];
    updateNoteLable.textAlignment = NSTextAlignmentCenter;
    updateNoteLable.textColor = [UIColor colorWithHexString:@"333333"];
    [self addSubview:updateNoteLable];
    
    
    CGFloat contentHight;
    NSArray*contentArray = [_versionModel.updateInfo componentsSeparatedByString:@"\n"];
    //计算内容高度
    for (NSString*subContent in contentArray) {
        
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:subTitleFontSize]};
        CGSize size = [subContent boundingRectWithSize:CGSizeMake(contentViewWidth - 40, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin  attributes:attribute context:nil].size;
        contentHight += size.height;
    }
    
    UILabel*contentLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, contentViewWidth-40, contentHight)];
    contentLable.font = [UIFont systemFontOfSize:subTitleFontSize];
    contentLable.text = _versionModel.updateInfo;
    contentLable.numberOfLines = 0;
    contentLable.textColor = [UIColor colorWithHexString:@"333333"];
    
    CGFloat restHight = ScreenHeigth - contentHight - titlelViewSpace - 50 -(updateNoteLable.frame.size.height+updateNoteLable.frame.origin.y+titlelViewSpace) - 100;
    CGFloat maxHight = contentHight;
    
    if (restHight < 0) {
        maxHight = ScreenHeigth - titlelViewSpace - 50 -(updateNoteLable.frame.size.height+updateNoteLable.frame.origin.y+titlelViewSpace) - 100;
    }
    
    UIScrollView*contentBackgroundView = [[UIScrollView alloc]initWithFrame:CGRectMake(20, updateNoteLable.frame.size.height+updateNoteLable.frame.origin.y + titlelViewSpace, contentViewWidth - 40, maxHight)];
    contentBackgroundView.contentSize  = CGSizeMake(0, contentHight);
    [contentBackgroundView addSubview:contentLable];
    [self addSubview:contentBackgroundView];
    
    self.frame = CGRectMake(0, 0, contentViewWidth, maxHight+updateNoteLable.frame.size.height+updateNoteLable.frame.origin.y + titlelViewSpace*2);
    self.backgroundColor = [UIColor clearColor];
}

+ (void)show:(BOOL)isShow{
    
    MCVersionManager *manager = [MCVersionManager new];
    
    NSString *version = isShow?AppSettings.lastUpdateVersion:@"0";
    if (!isShow){[SVProgressHUD  showWithStatus:PMLocalizedStringWithKey(@"PM_Mine_CheckVersion") maskType:SVProgressHUDMaskTypeClear];};
    [manager getVersionInfoWithVersion:version Success:^(id response) {
        
        if (!isShow){[SVProgressHUD dismiss];};
        MCVersionModel *model = (MCVersionModel*)response;
        if (!model.update && isShow) {
            if (![self feedback]) {
                [self praiseFor35User];
            }
            return ;
        }
        CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc]init];
        if (model.forcedUpdate) {
            alertView.buttonTitles = @[PMLocalizedStringWithKey(@"PM_UpdateVersion_Yes")];
        }else{
            alertView.buttonTitles =@[PMLocalizedStringWithKey(@"PM_UpdateVersion_NO"),PMLocalizedStringWithKey(@"PM_UpdateVersion_Yes")];
        }
        MCVersionUpdateView *updateView = [[MCVersionUpdateView alloc]initWithVersionInfo:model];
        alertView.containerView = updateView;
        alertView.useMotionEffects = YES;
        alertView.onButtonTouchUpInside = ^(CustomIOSAlertView *alertView, int buttonIndex){
            
            [alertView close];
            if (buttonIndex == 1 ||model.forcedUpdate) {
                [self praise];
            }
        };
        [alertView show];
        
    } failure:^(NSError *error) {
        if (!isShow){
            [SVProgressHUD dismiss];
        } else {
            if (![self feedback]) {
                [self praiseFor35User];
            }
        };
    }];
}

+ (void)showUpdateBadgeWithWorkPlace:(BOOL)flag
{
   MCAppSetting* appSet = [MCAppSetting shared];
    if (!appSet.lastSetVersion) {
        appSet.lastSetVersion = @"0";
    }
    if (([self strIntegerValue:appSet.lastSetVersion] < [self strIntegerValue:appSet.lastUpdateVersion]) && ([self strIntegerValue:appSet.lastUpdateVersion] > [[self appCurrentVersion] integerValue])) {
        MCAppDelegate *appDelegate = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
        if (flag) {
            [appDelegate.tabBarController.tabBar showBadgeOnItemIndex:4 itemNumber:5];
        }else{
            [appDelegate.tabBarController.tabBar showBadgeOnItemIndex:3 itemNumber:4];
        }
    }
}

+(NSInteger)strIntegerValue:(NSString *)version
{
    NSString *str = [version stringByReplacingOccurrencesOfString:@"." withString:@""];
    return [str integerValue];
}

+ (NSString *)appCurrentVersion
{
    NSString  *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return [currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
}

- (CGFloat)hightWihtContent:(NSString*)content fontSize:(CGFloat)fontSize{
    
    CGSize size =[content sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];
    
    return size.height;
}

//feedback
+ (BOOL)feedback {
    BOOL feedbackShow = AppSettings.isShowFeedbackVipMailInfoNote;
    if (feedbackShow) {
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Feedback_NotRemine") action:^{
            [MCUmengManager praiseEvent:mc_praise_unNote];
        }];
        RIButtonItem *likeItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Feedback_Like") action:^{
            RIButtonItem *praiseItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Feedback_Praise") action:^{
                //评价
                [self praise];
                [MCUmengManager praiseEvent:mc_praise_star];
            }];
            UIAlertView *likeAlertView = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Feedback_PraiseNote") message:nil cancelButtonItem:nil otherButtonItems:cancelItem,praiseItem, nil];
            [likeAlertView show];
            [MCUmengManager praiseEvent:mc_praise_like];
        }];
        RIButtonItem *unLikeItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Feedback_UnLike") action:^{
            RIButtonItem *feedbackItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Feedback_Go") action:^{
                //跟邮洽小助手吐槽
                MCContactModel *helperContact = [[MCContactManager sharedInstance] helperContact];
                MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForContact:helperContact];
                MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    MCAppDelegate *appDelegate = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
                    [appDelegate.tabBarController.selectedViewController pushViewController:vc animated:YES];
                });
                [MCUmengManager praiseEvent:mc_praise_feedback];
            }];
            UIAlertView *unLikeAlertview = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Feedback_FeedbackNote") message:nil cancelButtonItem:nil otherButtonItems:cancelItem,feedbackItem, nil];
            [unLikeAlertview show];
            [MCUmengManager praiseEvent:mc_praise_unLike];
        }];
        UIAlertView *feedbackAlerView = [[UIAlertView alloc]initWithTitle:nil message:PMLocalizedStringWithKey(@"PM_Feedback_VipMailsNote") cancelButtonItem:nil otherButtonItems:unLikeItem,likeItem, nil];
        [feedbackAlerView show];
    }
    return feedbackShow;
}

+ (void)praiseFor35User {
    
    if (!AppStatus.currentUser.email || [AppStatus.currentUser.email rangeOfString:@"@35.cn"].location == NSNotFound) {
        return;
    }
    BOOL show = NO ;
    if ((!AppSettings.lastSetVersion)||([self strIntegerValue:AppSettings.lastSetVersion] < [[self appCurrentVersion] integerValue])) {
        show = YES;
    }
    if (show) {
        double delayTime = 20;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayTime *NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Feedback_NotRemine") action:^{
                [MCUmengManager praiseEvent:mc_praise_35UnNote];
            }];
            RIButtonItem *praiseItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Feedback_Praise") action:^{
                //评价
                [self praise];
                [MCUmengManager praiseEvent:mc_praise_35UserStar];
            }];
            
            UIAlertView *likeAlertView = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Comment_praise") message:PMLocalizedStringWithKey(@"PM_Comment_content") cancelButtonItem:nil otherButtonItems:cancelItem,praiseItem, nil];
            [likeAlertView show];
            AppSettings.lastSetVersion = [self appCurrentVersion];
        });
    }
}


+ (void)praise {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/wei-mei-35pushmail/id592687646?mt=8"]];
}

@end
