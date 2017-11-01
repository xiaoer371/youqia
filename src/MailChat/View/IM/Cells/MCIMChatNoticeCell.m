//
//  MCIMChatNoticeCell.m
//  NPushMail
//
//  Created by swhl on 16/4/22.
//  Copyright © 2016年 sprite. All rights reserved.
//
#define STRETCH_IMAGE(image, edgeInsets) [image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch]

#import "MCIMChatNoticeCell.h"
#import "NSDate+Category.h"

@implementation MCIMChatNoticeCell{
    UIImageView* _contentBgImgView;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self =[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorWithHexString:@"eeeff2"];
        [self _initSubView];
    }
    return self;
}

-(void)_initSubView
{
    //    ==========内容==========
    _contentBgImgView = [[UIImageView alloc] init];
    [self.contentView addSubview:_contentBgImgView];
    _contentLabel  = [[UILabel alloc] init];
    _contentLabel.numberOfLines = 0;
    _contentLabel.textColor = [UIColor whiteColor];
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    _contentLabel.font = [UIFont systemFontOfSize:fontSize];
    [self.contentView addSubview:_contentLabel];
    
}

- (void)setModel:(MCIMMessageModel *)model
{
    _model =model;
    UIFont *font =[UIFont systemFontOfSize:fontSize];
    CGSize contentSize = [model.content boundingRectWithSize:CGSizeMake(ScreenWidth-60, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:font} context:nil].size;
    
    float width = contentSize.width+5;
    _contentLabel.frame = CGRectMake((ScreenWidth - width)/2, padding*2, width, contentSize.height+3);
    _contentBgImgView.frame =  _contentLabel.frame ;
    _contentBgImgView.image = STRETCH_IMAGE([UIImage imageNamed:@"systemOrTimeBgImg.png"], UIEdgeInsetsMake(8, 20, 8, 20));
    
    _contentLabel.text =[NSString stringWithFormat:@"%@",model.content];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+(CGFloat) cellHeightWithMessageModel:(MCIMMessageModel *)model showTime:(BOOL)showTime{

    UIFont *font =[UIFont systemFontOfSize:fontSize];
    CGSize contentSize = [model.content boundingRectWithSize:CGSizeMake(ScreenWidth-60, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:font} context:nil].size;
    if (showTime) {
        return timeLabelHeight + contentSize.height + padding*5;
    }
    return contentSize.height + padding*3 ;
}

@end

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define MB_TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;
#else
#define MB_TEXTSIZE(text, font) [text length] > 0 ? [text sizeWithFont:font] : CGSizeZero;
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define MB_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) \
attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;
#else
#define MB_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
sizeWithFont:font constrainedToSize:maxSize lineBreakMode:mode] : CGSizeZero;
#endif

@implementation UILabel (Common)

- (void)resize:(UILabelResizeType)type{
    CGSize size;
    if (type == UILabelResizeType_constantHeight)
    {
        // 高不变
        size = [self estimateUISizeByHeight:self.bounds.size.height];
        if (!CGSizeEqualToSize(CGSizeZero, size))
        {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, self.bounds.size.height);
        }
    }
    else if (type == UILabelResizeType_constantWidth)
    {
        // 宽不变
        size = [self estimateUISizeByWidth:self.bounds.size.width];
        if (!CGSizeEqualToSize(CGSizeZero, size))
        {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, size.height);
        }
        
    }
}

- (CGSize)estimateUISizeByBound:(CGSize)bound
{
    if ( nil == self.text || 0 == self.text.length )
    {
        return CGSizeZero;
    }
    
    return MB_MULTILINE_TEXTSIZE(self.text, self.font, bound, self.lineBreakMode);
}

- (CGSize)estimateUISizeByWidth:(CGFloat)width
{
    if ( nil == self.text || 0 == self.text.length )
    {
        return CGSizeMake( width, 0.0f );
    }
    
    
    if ( self.numberOfLines )
    {
        return MB_MULTILINE_TEXTSIZE(self.text, self.font, CGSizeMake(width, self.font.lineHeight * self.numberOfLines + 1), self.lineBreakMode);
    }
    else
    {
        return MB_MULTILINE_TEXTSIZE(self.text, self.font, CGSizeMake(width, 999999.0f), self.lineBreakMode);
    }
}

- (CGSize)estimateUISizeByHeight:(CGFloat)height
{
    if ( nil == self.text || 0 == self.text.length )
    {
        return CGSizeMake( 0.0f, height );
    }
    
    return MB_MULTILINE_TEXTSIZE(self.text, self.font, CGSizeMake(999999.0f, height), self.lineBreakMode);
}


@end
