//
//  MCIMNoMessageView.m
//  NPushMail
//
//  Created by swhl on 16/7/14.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMNoMessageView.h"
#import "UIView+MCExpand.h"

static const CGFloat mcNomessageTextLabelFont = 16.0f;
static const CGFloat mcNomessageImageSize     = 100.0f;

@interface MCIMNoMessageView ()

@property (nonatomic) enum MCNODateSourceAlertType type;

@end

@implementation MCIMNoMessageView

- (instancetype)initWithCreatType:(enum MCNODateSourceAlertType)type
{
    return [self initWithCreatType:type imageName:nil text:nil];
}

- (instancetype)initWithCreatType:(enum MCNODateSourceAlertType)type
                        imageName:(NSString *)imageName
                             text:(NSString *)text
{
    CGRect rect = CGRectMake(0, 44, ScreenWidth, ScreenHeigth-NAVIGATIONBARHIGHT-50);
    self = [self initWithFrame:rect];
    self.type = type;
    self.imageName = imageName;
    self.text = text;
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = MCNODateSourceAlertNoMessage;
        [self _initSubViews];
    }
    return self;
}

- (void)_initSubViews
{
    CGFloat height = CGRectGetHeight(self.frame);
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth-100)/2, (height -mcNomessageImageSize*2)/2, mcNomessageImageSize, mcNomessageImageSize)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame =_imageView.bounds;
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    float y = CGRectGetMaxY(_imageView.frame);
    _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, y+20, ScreenWidth-40, 30)];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.numberOfLines = 0;
    _textLabel.textColor = AppStatus.theme.fontTintColor;
    _textLabel.font = [UIFont systemFontOfSize:mcNomessageTextLabelFont];
    switch (self.type) {
        case MCNODateSourceAlertNoMessage:
        {
            _imageView.image = [UIImage imageNamed:@"mc_nomessages.png"];
            _textLabel.text = PMLocalizedStringWithKey(@"PM_IMChat_noMessagesNotice");
        }
            break;
        default:
            break;
    }
    
    [self addSubview:_imageView];
    [self addSubview:_textLabel];
    
}

- (void)setText:(NSString *)text
{
    _text = text;
    _textLabel.text = self.text;
    
   CGSize size = [self.text boundingRectWithSize:CGSizeMake(ScreenWidth-40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:[UIFont systemFontOfSize:mcNomessageTextLabelFont]} context:nil].size;
    _textLabel.mc_height = size.height;
    
}

- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    _imageView.image = [UIImage imageNamed:imageName];
}

- (void)action:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectImageView)]) {
        [self.delegate didSelectImageView];
    }
}

@end
