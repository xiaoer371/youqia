//
//  MCFeaturesGuideHelper.m
//  NPushMail
//
//  Created by wuwenyu on 16/8/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCFeaturesGuideHelper.h"
#import "NSString+Extension.h"
#import "UIView+MJExtension.h"
#import "MCAppSetting.h"
#import "BearCutOutView.h"

@interface MCFeaturesGuideHelper()
@property(nonatomic, strong) BearCutOutView *backgroundView;
@property(nonatomic, strong) UIImageView *handImageView;

@property(nonatomic, strong) UIImageView *leftArrowImageView;
@property(nonatomic, strong) UIImageView *topArrowImageView;
@property(nonatomic, strong) UIImageView *mailFolderAndAcountGuideImageView;
@property(nonatomic, strong) UIImageView *mailCellGuideImageView;
@property(nonatomic, strong) UIImageView *mailCellImageView;
@property(nonatomic, strong) UIImageView *importantMailNoteImageView;
@property(nonatomic, assign) CGRect mailListCellRect;
@property(nonatomic, assign) CGRect importantRect;

@property(nonatomic, strong) UIImageView *guideMsgView;
@property(nonatomic, strong) NSString *guideMsg;
@property(nonatomic, strong) UILabel *guideMsgLabel;
@property(nonatomic, assign) int tapCounts;
@property(nonatomic, assign) MCFeaturesGuideType guideType;
@end

static const CGFloat mailCellWidth = 231;
static const CGFloat mailGuideImageWidth = 162;
static const CGFloat mailGuideImageHeight = 167;
static const CGFloat importantMailNoteImageWidth = 315;
static const CGFloat importantMailNoteImageHeight = 207;


@implementation MCFeaturesGuideHelper

- (id)initWithFrame:(CGRect)frame mailListCellRect:(CGRect)cellRect importantMailRect:(CGRect)importantRect guideType:(MCFeaturesGuideType)type {
    if (self = [super initWithFrame:frame]) {
        _guideType = type;
        _mailListCellRect = cellRect;
        _importantRect = importantRect;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissWindow)]];
    if (!_mailFolderAndAcountGuideImageView) {
        _mailFolderAndAcountGuideImageView = [[UIImageView alloc] init];
        _mailFolderAndAcountGuideImageView.image = [UIImage imageNamed:@"guideMailFolderAndAccountChange.png"];
        _mailFolderAndAcountGuideImageView.frame = CGRectMake(20, 130, 234, 117);
    }
    
    if (!_leftArrowImageView) {
        _leftArrowImageView = [[UIImageView alloc] init];
        _leftArrowImageView.image = [UIImage imageNamed:@"guideLeftArrow.png"];
        _leftArrowImageView.frame = CGRectMake(CGRectGetMinX(_mailFolderAndAcountGuideImageView.frame) + 20, NAVIGATIONBARHIGHT - 10, 58, 60);
    }
    if (!_topArrowImageView) {
        _topArrowImageView = [[UIImageView alloc] init];
        _topArrowImageView.image = [UIImage imageNamed:@"guideTopArrow.png"];
        _topArrowImageView.frame = CGRectMake(ScreenWidth/2, CGRectGetMinY(_leftArrowImageView.frame) + 5, 18, 63);
    }
   
    if (!_mailCellImageView) {
        _mailCellImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - mailCellWidth, _mailListCellRect.origin.y, mailCellWidth, _mailListCellRect.size.height)];
        _mailCellImageView.image = [UIImage imageNamed:@"guideMailCellEdit.png"];
        _mailCellImageView.hidden = YES;
    }
    
    if (!_mailCellGuideImageView) {
        if (_mailListCellRect.size.height > 0) {
            _mailCellGuideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - mailGuideImageWidth - 80, CGRectGetMaxY(_mailCellImageView.frame), mailGuideImageWidth, mailGuideImageHeight)];
            _mailCellGuideImageView.image = [UIImage imageNamed:@"guideForMailListCellNote.png"];
            _mailCellGuideImageView.hidden = YES;
        }
    }
    
    if (!_importantMailNoteImageView) {
        if (_importantRect.size.height > 0) {
            _importantMailNoteImageView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - importantMailNoteImageWidth)/2, CGRectGetMaxY(_importantRect), importantMailNoteImageWidth, importantMailNoteImageHeight)];
            _importantMailNoteImageView.image = [UIImage imageNamed:@"guideImportantMail.png"];
            _importantMailNoteImageView.hidden = YES;
        }
    }
    
    if (_guideType == MCFeaturesGuideMailList) {
        
    }
    if (_guideType == MCFeaturesGuideMailDetailEditAgain) {
       
    }
    
    if (!_backgroundView) {
        _backgroundView = [[BearCutOutView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth)];
        CGSize accountSize = [AppStatus.currentUser.email mcStringSizeWithFont:11.0 maxWidth:(ScreenWidth - 150) maxHight:17.0];
        
        UIBezierPath *bezierPath1 = [UIBezierPath bezierPath];
        [bezierPath1 addArcWithCenter:CGPointMake(24, 40) radius:18 startAngle:0.0 endAngle:180.0 clockwise:YES];
        [bezierPath1 setLineWidth:5.0];
        [[UIColor redColor] setStroke];
        [bezierPath1 stroke];
        
        UIBezierPath *bezierPath2 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((ScreenWidth - accountSize.width)/2 - 15, 20, accountSize.width + 30, NAVIGATIONBARHIGHT - 20) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(3, 3)];
        [bezierPath2 stroke];
        [_backgroundView setUnCutColor:[UIColor blackColor] cutOutPath1:bezierPath1 cutOutPath1:bezierPath2];
        _backgroundView.alpha = 0.8;
        _backgroundView.userInteractionEnabled = YES;
        [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissWindow)]];
    }
    [self addSubview:_backgroundView];
    [self addSubview:_leftArrowImageView];
    [self addSubview:_topArrowImageView];
    [self addSubview:_mailFolderAndAcountGuideImageView];
    [self addSubview:_mailCellImageView];
    if (_mailCellGuideImageView) {
        [self addSubview:_mailCellGuideImageView];
    }
    if (_importantMailNoteImageView) {
        [self addSubview:_importantMailNoteImageView];
    }

}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}

- (void)dismissWindow {
    if (_guideType == MCFeaturesGuideMailList) {
        _tapCounts ++;
        if (_tapCounts == 1) {
            if (_mailCellGuideImageView) {
                [self mailCellGuideShow];
            }else if (_importantMailNoteImageView) {
                [self importantMailGuideShow];
            }else {
                [self guideEndShow];
            }
        }
        if (_tapCounts == 2) {
            if (_importantMailNoteImageView) {
                [self importantMailGuideShow];
            }else {
                [self guideEndShow];
            }
        }
        if (_tapCounts == 3) {
            [self guideEndShow];
        }
    }
    
    if (_guideType == MCFeaturesGuideMailDetailEditAgain) {
        [self guideEndShow];
    }
}

- (void)mailCellGuideShow {
    [_backgroundView setUnCutColor:[UIColor blackColor] cutOutFrame:CGRectMake(-20, 0, 1, 1)];
    _leftArrowImageView.hidden = YES;
    _topArrowImageView.hidden = YES;
    _mailFolderAndAcountGuideImageView.hidden = YES;
    _mailCellImageView.hidden = NO;
    _mailCellGuideImageView.hidden = NO;
}

- (void)importantMailGuideShow {
    if (_importantRect.size.height > 0) {
        [_backgroundView setUnCutColor:[UIColor blackColor] cutOutFrame:_importantRect];
    }
    _mailCellImageView.hidden = YES;
    _mailCellGuideImageView.hidden = YES;
    _importantMailNoteImageView.hidden = NO;
}

- (void)guideEndShow {
    [AppSettings setIsFirstShowGuideForMailListContrller:NO];
    [self removeFromSuperview];
}
@end
