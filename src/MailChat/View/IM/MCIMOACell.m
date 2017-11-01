//
//  MCIMOACell.m
//  NPushMail
//
//  Created by swhl on 16/3/22.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMOACell.h"
#import "MCIMAppModel.h"
#import "NSDate+Category.h"


static const CGFloat padding = 5;          //label与背景的间距
static const CGFloat paddingY = 3;         //时间label与背景的间距
//static const CGFloat fontSize = 14.0f;     //字体大小
static const CGFloat timeLabelHeight = 18; //时间label高度

@interface MCIMOACell ()<MCIMOAContentViewDelegate>

@property (nonatomic,strong)UIImageView *timeLabelBgImgView;

@end

@implementation MCIMOACell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self =[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self _initSubView];
    }
    return self;
}
-(void)_initSubView
{
    //    =========时间==========
    self.contentView.clipsToBounds = YES;
    //时间背景
    [self.contentView addSubview:self.timeLabelBgImgView];
    //时间label
    [self.contentView addSubview:self.timeLabel];
    //头像
    [self.contentView addSubview:self.userImageView];
    //用户名
    [self.contentView addSubview:self.userNameLabel];
    //内容
    _cellView = [[MCIMOAContentView alloc] init];
    _cellView.delegate = self;
    [self.contentView addSubview:_cellView];
    
    //已读 未读标志图片
    [self.contentView addSubview:self.readFlagImgView];
}

#pragma mark - subViews
-(UIImageView *)timeLabelBgImgView
{
    if (!_timeLabelBgImgView) {
        _timeLabelBgImgView = [[UIImageView alloc] init];
    }
    return _timeLabelBgImgView;
}
-(UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel  = [[UILabel alloc] init];
        _timeLabel.numberOfLines = 1;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:14.0f];
        _timeLabel.textColor = [UIColor whiteColor];
    }
    return _timeLabel;
}
-(UIImageView *)userImageView
{
    if (!_userImageView) {
        _userImageView =[[UIImageView alloc] init];
        _userImageView.userInteractionEnabled =YES;
        UITapGestureRecognizer* singleRecognizer;
        singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleClick:)];
        //点击的次数
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        //给self.添加一个手势监测；
        [_userImageView addGestureRecognizer:singleRecognizer];
    }
    return _userImageView;
}
-(UILabel *)userNameLabel
{
    if (!_userNameLabel) {
        _userNameLabel =[[UILabel alloc] init];
        _userNameLabel.font =[UIFont systemFontOfSize:14.0f];
        _userNameLabel.numberOfLines = 1;
        _userNameLabel.textColor = [UIColor grayColor];
    }
    return _userNameLabel;
}
-(UIImageView *)readFlagImgView
{
    if (!_readFlagImgView) {
        _readFlagImgView =[[UIImageView alloc] init];
        _readFlagImgView.image =[UIImage imageNamed:@"read_flag.png"];
    }
    return _readFlagImgView;
}



#pragma mark - update subUI

-(void)setOaModel:(MCIMOAMessageModel *)oaModel
{
    _oaModel = oaModel;
    if (self.showTimeLabel) {
        _timeLabel.frame =CGRectMake(0, 2, ScreenWidth, 10);
        NSDate *date =oaModel.time;
        _timeLabel.text = [date minuteDescription];
        
        CGFloat timeLabelWidth = 100;  // [_timeLabel estimateUISizeByHeight:timeLabelHeight].width;
        _timeLabel.frame = CGRectMake((ScreenWidth - timeLabelWidth - padding*2)/2, paddingY*2, timeLabelWidth, timeLabelHeight);
        _timeLabelBgImgView.frame = CGRectMake(CGRectGetMinX(_timeLabel.frame) - padding, CGRectGetMinY(_timeLabel.frame) - paddingY, _timeLabel.frame.size.width + padding*2, _timeLabel.frame.size.height + paddingY*2);
        _timeLabelBgImgView.image =[[UIImage imageNamed:@"systemOrTimeBgImg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 20, 8, 20) resizingMode:UIImageResizingModeStretch];
        
        float originY =CGRectGetMaxY(_timeLabel.frame)+9;
        _userImageView.frame =CGRectMake(8, originY, 33, 33);

        
        _userNameLabel.frame =CGRectMake(60, originY, 200/*ScreenWidth-110*/, 16);
        
       
        float originY2 =CGRectGetMaxY(_userNameLabel.frame)+7;
        float originX=CGRectGetMinX(_userNameLabel.frame);
        CGPoint point =CGPointMake(originX, originY2);
        
        [_cellView setFrameWithOAmodel:oaModel originPoint:point];
        float originX2 =CGRectGetMinX(_cellView.frame);
        _readFlagImgView.frame =CGRectMake(originX2+_cellView.frame.size.width+13, originY+_cellView.frame.size.height/2+16, 10, 10);
        if (oaModel.isRead) {
            _readFlagImgView.hidden =YES;
        }else _readFlagImgView.hidden = NO;
    }
    else
    {
        _timeLabel.frame =CGRectZero;
        _timeLabelBgImgView.frame=CGRectZero;
        float originY =CGRectGetMaxY(_timeLabel.frame)+9;
        _userImageView.frame =CGRectMake(8, originY, 33, 33);
//        NSArray *array1 =[oaModel.from componentsSeparatedByString:@"<"];
//        NSString *name =array1[0];
//        NSArray *array2 =[array1[1] componentsSeparatedByString:@">"];
//        NSString *userEmail =array2[0];
        
//        NSString *urlStr =[ContactTB getHeadImageUrlWithEmail:userEmail withAccount:[MailLoginManager currentUser]];
//        NSString* imageAddress = [NSString stringWithFormat:@"%@%@_s", avatorBaseUrl, urlStr];
//        [_userImageView sd_setImageWithURL:[NSURL URLWithString:imageAddress] placeholderImage:[self headViewWithDisplay:name] options:SDWebImageAllowInvalidSSLCertificates];
        
        _userNameLabel.frame =CGRectMake(60, originY,200 /*ScreenWidth-110*/, 16);
        _userNameLabel.text = @"111";
        float originY2 = CGRectGetMaxY(_userNameLabel.frame)+5;
        float originX = CGRectGetMinX(_userNameLabel.frame);
        CGPoint point = CGPointMake(originX, originY2);
        [_cellView setFrameWithOAmodel:oaModel originPoint:point];
        
        float originX2 =CGRectGetMinX(_cellView.frame);
        _readFlagImgView.frame =CGRectMake(originX2+_cellView.frame.size.width+13, originY+_cellView.frame.size.height/2+16, 10, 10);
        if (oaModel.isRead) {
            _readFlagImgView.hidden =YES;
        }else _readFlagImgView.hidden = NO;
    }
}
-(void)singleClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(userHeadClick:)]) {
        [self.delegate userHeadClick:self.oaModel];
    }
}

-(void)didSelectContentView
{
    _readFlagImgView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(contentClick:)]) {
        [self.delegate contentClick:self.oaModel];
    }
}

@end
