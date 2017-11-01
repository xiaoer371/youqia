//
//  MCMailSentErrorView.m
//  NPushMail
//
//  Created by zhang on 2016/11/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMailSentErrorView.h"

@interface MCMailSentErrorView ()

@property (nonatomic,strong)UIView *mcSuperView;
@property (nonatomic,assign)BOOL needShowClearItem;

@end

static const CGFloat kMCMailSentErrorViewHeight = 44;


@implementation MCMailSentErrorView

- (id)initWithSuperView:(UIView*)superView needClearItem:(BOOL)need {
    if (self = [super init]) {
        _mcSuperView = superView;
        _needShowClearItem = need;
        [self setupViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame needClearItem:(BOOL)needClearItem {
    if (self = [super initWithFrame:frame]) {
        _needShowClearItem = needClearItem;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
   
    UIImageView *errorImageView = [[UIImageView alloc]init];
    errorImageView.frame = CGRectMake(13, (kMCMailSentErrorViewHeight - 22)/2, 22, 22);
    errorImageView.image = [UIImage imageNamed:@"net_err.png"];
    
    UILabel *errorLabel = [[UILabel alloc]init];
    errorLabel.frame = CGRectMake(CGRectGetMaxX(errorImageView.frame)+ 10, (kMCMailSentErrorViewHeight -20)/2, CGRectGetWidth(self.frame) - (CGRectGetWidth(errorImageView.frame)+10) - kMCMailSentErrorViewHeight, 20);
    errorLabel.backgroundColor = [UIColor clearColor];
    errorLabel.font = [UIFont systemFontOfSize:15.0f];
    errorLabel.text = PMLocalizedStringWithKey(@"PM_Mail_sentErrorNote");
    
    [self addSubview:errorImageView];
    [self addSubview:errorLabel];
    
    if (_needShowClearItem) {
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearButton addTarget:self action:@selector(clearErrorView:) forControlEvents:UIControlEventTouchUpInside];
        clearButton.frame = CGRectMake(CGRectGetWidth(self.frame) - kMCMailSentErrorViewHeight, 0, kMCMailSentErrorViewHeight, kMCMailSentErrorViewHeight);
        [clearButton setImage:[UIImage imageNamed:@"mc_closeErrorView.png"] forState:UIControlStateNormal];
        [self addSubview:clearButton];
        [_mcSuperView bringSubviewToFront:self];
    } 
    self.backgroundColor = [UIColor colorWithHexString:@"f9d7d7"];
    
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectedPendingBox:)];
    [self addGestureRecognizer:tap];
    
}

- (void)show {
    
}

- (void)dismiss {
    [self removeFromSuperview];
}

//close
- (void)clearErrorView:(UIButton*)sender {
    if (self.dismissCallback) {
        self.dismissCallback();
    }
//    [self dismiss];
}
//select
- (void)selectedPendingBox:(UIGestureRecognizer*)gesture {
    
    if (self.dismissCallback) {
        self.dismissCallback();
    }
    if (self.didSelectedPendingBox) {
        self.didSelectedPendingBox();
    }
}
@end
