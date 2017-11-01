//
//  MCMailEditingView.m
//  NPushMail
//
//  Created by zhang on 15/12/23.
//  Copyright © 2015年 sprite. All rights reserved.
//



#import "MCMailEditingView.h"
#import "UIColor+Hex.h"
#import "MCPopoverView.h"
@interface MCMailEditingView ()

@property (nonatomic,assign)CGFloat angle;

@property (nonatomic,strong)UIImageView   *classifyNoteImageView;

@end

const static CGFloat kMCMailEditingViewHight                      = 49.0;
const static CGFloat kMCMailEditingViewSpace                      = 4.0;
const static CGFloat kMCMailEditingViewSpaceLineHight             = 0.5;
const static NSInteger kMCMailEditingViewItemButtonCount          = 2;
const static NSInteger kMCMailEditingViewItemClassifyButtonTag    = 20;
const static CGFloat KMCMailEditingViewClassifyNoteImageViewHight = 5.0;
const static CGFloat KMCMailEditingViewClassifyNoteImageViewWidth = 9.0;
const static CGFloat kMCMailEditingViewItemButtomTitleFontSize    = 15.0;
const static CGFloat KMCMailEditingViewPopoverViewY               = 64 + 22.0;


@implementation MCMailEditingView

- (id)init{
    
    if (self = [super init]) {
        
        self.frame = CGRectMake(0, 0, ScreenWidth, kMCMailEditingViewHight);
        self.backgroundColor = [UIColor whiteColor];
        
        [self setUp];
    }
    
    return self;
}

- (void)setUp{
    
    UIView*vLine = [[UIView alloc]initWithFrame:CGRectMake((ScreenWidth - kMCMailEditingViewSpaceLineHight)/2, kMCMailEditingViewSpace, kMCMailEditingViewSpaceLineHight, kMCMailEditingViewHight - 2*kMCMailEditingViewSpace)];
    
    vLine.backgroundColor = AppStatus.theme.toolBarSeparatorColor;
    [self addSubview:vLine];
    
    UIView *hLine = [[UIView alloc]initWithFrame:CGRectMake(0, kMCMailEditingViewHight - kMCMailEditingViewSpaceLineHight, ScreenWidth, kMCMailEditingViewSpaceLineHight)];
    hLine.backgroundColor = AppStatus.theme.toolBarSeparatorColor;
    [self addSubview:hLine];
    
    for (int i = 0; i < kMCMailEditingViewItemButtonCount; i ++) {
        UIButton*button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*(ScreenWidth/2), 0, ScreenWidth/2, kMCMailEditingViewHight);
        
        if (i == 1) {
            
            button.tag = kMCMailEditingViewItemClassifyButtonTag;
        }
        
        [button setTitle:i == 0?PMLocalizedStringWithKey(@"PM_Contact_Edit"):PMLocalizedStringWithKey(@"PM_Mail_All") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(toEditingState:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:kMCMailEditingViewItemButtomTitleFontSize];
        if (i == 1) {
            self.classifyNoteImageView = [[UIImageView alloc]initWithFrame:CGRectMake(button.frame.size.width *4/5-KMCMailEditingViewClassifyNoteImageViewWidth/2, (button.frame.size.height-KMCMailEditingViewClassifyNoteImageViewHight)/2, KMCMailEditingViewClassifyNoteImageViewWidth, KMCMailEditingViewClassifyNoteImageViewHight)];
            self.classifyNoteImageView.image = [UIImage imageNamed:@"mc_mailListNote.png"];
            self.classifyNoteImageView.transform = CGAffineTransformMakeRotation(M_PI);
            self.angle = 0;
            [button addSubview:self.classifyNoteImageView];
        }
        [self addSubview:button];
    }
    
}

- (void)toEditingState:(UIButton*)sender{
    
    if (sender.tag == kMCMailEditingViewItemClassifyButtonTag) {
        NSArray*titles;
        MCMailBox *mailBox = [_delegate mailEditingView:self canEditing:YES];
        if (mailBox.type == MCMailFolderTypePending |mailBox.type == MCMailFolderTypeDrafts) {
            return;
        } else if (mailBox.type == MCMailFolderTypeStarred){
            titles = @[PMLocalizedStringWithKey(@"PM_Mail_All_title"),PMLocalizedStringWithKey(@"PM_Mail_UnRead")];
        }else {
            titles = @[PMLocalizedStringWithKey(@"PM_Mail_All_title"),PMLocalizedStringWithKey(@"PM_Mail_UnRead"),PMLocalizedStringWithKey(@"PM_Mail_Collection_title")];
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.classifyNoteImageView.transform = CGAffineTransformMakeRotation(self.angle);
        } completion:^(BOOL finished) {
            if (self.angle != 0) {
                self.angle = 0;
            } else {
                self.angle = M_PI;
            }
        }];
           
        __weak MCMailEditingView *weak = self;
        CGPoint point = CGPointMake(sender.frame.origin.x + self.classifyNoteImageView.frame.origin.x + self.classifyNoteImageView.frame.size.width/2, KMCMailEditingViewPopoverViewY);
        MCPopoverView *mcPopverView = [MCPopoverView new];
        mcPopverView.menuTitles = titles;
        mcPopverView.dissmissCallBack = ^{
            
            [UIView animateWithDuration:0.3 animations:^{
                weak.classifyNoteImageView.transform = CGAffineTransformMakeRotation(weak.angle);
            } completion:^(BOOL finished) {
                if (weak.angle != 0) {
                    weak.angle = 0;
                } else {
                    weak.angle = M_PI;
                }
            }];
        };
        
        [mcPopverView showFromPoint:point popoverViewStyle:MCPopoverViewStyleUp  selected:^(NSInteger index) {
            if ([weak.delegate respondsToSelector:@selector(mailEditingView:classify:)]) {
                //友盟统计事件
                switch (index) {
                    case 0:
                        [MCUmengManager addEventWithKey:mc_mail_all_all];
                        break;
                    case 1:
                        [MCUmengManager addEventWithKey:mc_mail_all_read];
                        break;
                    case 2:
                        [MCUmengManager addEventWithKey:mc_mail_all_star];
                        break;
                        
                    default:
                        break;
                }
                [weak.delegate mailEditingView:weak classify:(MCMailFlags)index];
            }
            [sender setTitle:[titles[index] stringByReplacingOccurrencesOfString:@" " withString:@""] forState:UIControlStateNormal];
        }];
        
    } else {
       
       if ([_delegate respondsToSelector:@selector(mailEditingView:intoEditing:)]) {
           [_delegate mailEditingView:self intoEditing:YES];
       }

    }
}

//TOOD:reset
- (void)reset {
    UIButton*button = (UIButton*)[self viewWithTag:kMCMailEditingViewItemClassifyButtonTag];
    [button setTitle:PMLocalizedStringWithKey(@"PM_Mail_All") forState:UIControlStateNormal];
}
@end
