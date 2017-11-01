//
//  MCContactInfoHeaderView.m
//  NPushMail
//
//  Created by wuwenyu on 16/1/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactInfoHeaderView.h"
#import "MCContactModel.h"
#import "MCContactTable.h"
#import "MCContactManager.h"
#import "UIImageView+WebCache.h"
#import "MCAccount.h"
#import "MCAvatarHelper.h"
#import "UIImageView+MCCorner.h"
#import "MCAvatarImageViewHelper.h"
#import "MCLabel.h"

@interface MCContactInfoHeaderView ()

@property (nonatomic,strong) UIImageView *bgImageView;
@property (nonatomic,strong) UIImageView *avatorImgView;
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UILabel *nickNameLabel;
@property (nonatomic,strong) MCLabel *accountLabel;
@property (nonatomic,strong) UIButton *collectBtn;
@property (nonatomic,strong) MCContactModel *model;
@property (nonatomic,assign) BOOL isCollect;
@property (nonatomic,strong) setImportantBlock importantBlock;

@end

static CGFloat const avatorImageOriginY = 93;
static CGFloat const avatorImageOriginX = 15;
static CGFloat const avatorHeight = 67;
static CGFloat const avatorWidth = 67;
static CGFloat const  collectBtnHeight = 21;
static CGFloat const  collectBtnWidth = 66;
static CGFloat const  accountLabelFontSize = 15;
static CGFloat const  displayNameLabelFontSize = 17.0f;

@implementation MCContactInfoHeaderView

- (id)initWithFrame:(CGRect)frame showBottomLine:(BOOL)showLineFlag importantBlock:(setImportantBlock)importantBlock {
    self = [super initWithFrame:frame];
    if (self) {
        _isCollect = NO;
        self.userInteractionEnabled = YES;
        self.image = [UIImage imageNamed:@"contactInfoBg.png"];
        self.clipsToBounds = YES;
        self.importantBlock = importantBlock;
        //头像
        _avatorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(avatorImageOriginX, avatorImageOriginY, avatorWidth, avatorHeight)];
        _avatorImgView.userInteractionEnabled = YES;
               UITapGestureRecognizer* singleRecognizer;
        singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapAction:)];
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        [_avatorImgView addGestureRecognizer:singleRecognizer];
        [_avatorImgView cornerRadiusWithMask];
        _avatorImgView.layer.borderWidth = 2.0f;
        _avatorImgView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor whiteColor]);
        
        //重要联系人按钮
        _collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _collectBtn.frame = CGRectMake(CGRectGetWidth(frame) - avatorImageOriginX - collectBtnWidth, CGRectGetMinY(_avatorImgView.frame) + 25, collectBtnWidth, collectBtnHeight);
        _collectBtn.layer.cornerRadius = 5;
        [_collectBtn setBackgroundColor:[UIColor clearColor]];
        [[_collectBtn titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
        [_collectBtn addTarget:self action:@selector(setCollect:) forControlEvents:UIControlEventTouchUpInside];
        
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_avatorImgView.frame) + avatorImageOriginX, CGRectGetMinY(_avatorImgView.frame) + 15, CGRectGetWidth(frame) - avatorImageOriginX*3 - collectBtnWidth - avatorWidth, 21)];
        _nickNameLabel.textAlignment = NSTextAlignmentLeft;
        _nickNameLabel.font = [UIFont systemFontOfSize:displayNameLabelFontSize];
        _nickNameLabel.textColor = [UIColor whiteColor];
        _accountLabel = [[MCLabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_nickNameLabel.frame), CGRectGetMaxY(_nickNameLabel.frame) + 5, CGRectGetWidth(frame) - CGRectGetMinX(_nickNameLabel.frame), CGRectGetHeight(_nickNameLabel.frame))];
        _accountLabel.textAlignment = NSTextAlignmentLeft;
        _accountLabel.font = [UIFont systemFontOfSize:15.0f];
        _accountLabel.textColor = [UIColor whiteColor];
        _accountLabel.font = [UIFont systemFontOfSize:accountLabelFontSize];

        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - 0.5, CGRectGetWidth(frame), 0.5)];
        line.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        line.hidden = !showLineFlag;
        
        [self addSubview:_avatorImgView];
        [self addSubview:_nickNameLabel];
        [self addSubview:_accountLabel];
        [self addSubview:_collectBtn];
        
        _avatorImgView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _collectBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        line.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

    }
    return self;
}

- (void)configureView:(id)contactModel {
    _model = (MCContactModel *)contactModel;
    _accountLabel.text = _model.account;
    _nickNameLabel.text = _model.displayName;
    [_avatorImgView setUserInteractionEnabled:YES];
    [_avatorImgView sd_setImageWithURL:[NSURL URLWithString:_model.headImageUrl] placeholderImage:_model.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
    if (_model.importantFlag) {
        _isCollect = YES;
        [_collectBtn setBackgroundImage:[UIImage imageNamed:@"unFavorite1.png"] forState:UIControlStateNormal];
    }else {
        _isCollect = NO;
        [_collectBtn setBackgroundImage:[UIImage imageNamed:@"Favorite1.png"] forState:UIControlStateNormal];
    }
}

- (void)setCollect:(UIButton *)sender {
    if (_isCollect) {
        [_collectBtn setBackgroundImage:[UIImage imageNamed:@"Favorite1.png"] forState:UIControlStateNormal];
    }else{
        [_collectBtn setBackgroundImage:[UIImage imageNamed:@"unFavorite1.png"] forState:UIControlStateNormal];
    }
    [[MCContactManager sharedInstance] updateImportFlagWithEmail:_model.account importFlag:!_isCollect];
    _isCollect = !_isCollect;
    if (self.importantBlock) {
        self.importantBlock(_isCollect);
    }
}

- (void)handleSingleTapAction:(id)sender {
    NSURL *url =[NSURL URLWithString:_model.largeHeadImageUrl];
    [MCAvatarImageViewHelper showImage:_avatorImgView withBigImgUrl:url];
}

@end
