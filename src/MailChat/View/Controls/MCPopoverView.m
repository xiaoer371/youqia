//
//  MCPopoverView.m
//  NPushMail
//
//  Created by zhang on 16/5/6.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCPopoverView.h"
#import "NSString+Extension.h"

@interface MCPopoverView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) MCArrow *mcArrow;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic,copy)MCPopoverBlock selectedBlock;
@end
// 箭头高度
const static CGFloat kMCPopoverArrowViewHight = 8.0;
// 箭头宽度
const static CGFloat kMCPopoverArrowViewWidth = 15.0;
const static CGFloat kMCPopoverViewTitleFontSize = 16.0;
const static CGFloat kMCPopoverViewCellHight = 50.0;

@implementation MCPopoverView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
    
    self.backgroundColor = [UIColor clearColor];
    _mcArrow = [MCArrow new];
    [self addSubview:_mcArrow];
    [self insertSubview:self.tableView belowSubview:_mcArrow];
        
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // 设置tableView默认的分割线起终点位置
    self.tableView.layer.cornerRadius  = 5.f;
    self.tableView.layer.borderColor   = [UIColor colorWithHexString:@"E1E2E3"].CGColor;
    self.tableView.layer.borderWidth   = 1.0;
}

#pragma mark -- getter

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.delegate        = self;
        _tableView.dataSource      = self;
        _tableView.separatorColor  =  [UIColor colorWithHexString:@"E1E2E3"];
        _tableView.scrollEnabled   = NO;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = UIView.new;
    };
    return _tableView;
}

#pragma mark -- delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"kMCPopoverViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.font   = [UIFont systemFontOfSize:kMCPopoverViewTitleFontSize];
    cell.textLabel.text   = [self.menuTitles objectAtIndex:indexPath.row];
    cell.textLabel.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = AppStatus.theme.tintColor;
    cell.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedBlock) {
        _selectedBlock(indexPath.row);
    }
    
    if (_dissmissCallBack) {
        _dissmissCallBack();
    }
    [_backgroundView removeFromSuperview];
    _backgroundView = nil;
    [self removeFromSuperview];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kMCPopoverViewCellHight;
}

#pragma mark -- private
// 点击透明层隐藏
- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^{
        _backgroundView.alpha = 0;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [_backgroundView removeFromSuperview];
        _backgroundView = nil;
        [self removeFromSuperview];
    }];
    if (_dissmissCallBack) {
        _dissmissCallBack();
    }
}

#pragma mark -- public

/*!
 *  @author lifution
 *
 *  @brief 显示弹窗
 *
 *  @param point    箭头指向的坐标
 *  @param selected 选择完成回调
 */

- (void)showFromPoint:(CGPoint)point popoverViewStyle:(MCPopoverViewStyle)popoverViewStyle  selected:(MCPopoverBlock)selected {
    if (selected) self.selectedBlock = selected;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    // 背景遮挡
    _backgroundView = UIView.new;
    _backgroundView.frame = keyWindow.bounds;
    _backgroundView.backgroundColor = [UIColor grayColor];
    _backgroundView.alpha = 0;
    _backgroundView.userInteractionEnabled = YES;
    [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
    [keyWindow addSubview:_backgroundView];
    
    // 刷新数据更新contentSize
    [self.tableView reloadData];
    
    // 取得标题中的最大宽度
    CGFloat maxWidth = 0;
    for (id obj in self.menuTitles) {
        if ([obj isKindOfClass:[NSString class]]) {
            CGSize titleSize = [obj sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kMCPopoverViewTitleFontSize]}];
            if (titleSize.width > maxWidth) {
                maxWidth = titleSize.width;
            }
        }
    }
    CGFloat curWidth  = ((maxWidth + 60) > ScreenWidth -30)?ScreenWidth - 30:(maxWidth + 60);
    CGFloat curHeight = self.tableView.contentSize.height + kMCPopoverArrowViewHight;
    CGFloat curX      = point.x - curWidth/2;
    CGFloat curY      = point.y + 10;
    if (popoverViewStyle == MCPopoverViewStyleDown) {
        curY -= curHeight;
        _mcArrow.hidden = YES;
    }
    // 如果箭头指向点距离屏幕右边减去5px不足curWidth的一半的话就重新设置curX
    if ((ScreenWidth - point.x -5) < curWidth/2) {
        curX = curX-(curWidth/2-(ScreenWidth - point.x -5));
    }
    // 如果箭头指向点距离屏幕左边加上5px不足curWidth的一半的话就重新设置curX
    if (point.x + 5 < curWidth/2) {
        curX = curX + (curWidth/2 - point.x) + 5;
    }
    
    self.frame = CGRectMake(curX, curY, curWidth, curHeight);
    _mcArrow.frame = CGRectMake(point.x- curX - kMCPopoverArrowViewWidth/2, 0, kMCPopoverArrowViewWidth, kMCPopoverArrowViewHight + 1);
    // 箭头高度 +1 遮挡住tableView的边框
    self.tableView.frame = CGRectMake(0, kMCPopoverArrowViewHight, curWidth, self.tableView.contentSize.height);
    [keyWindow addSubview:self];
    
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.alpha = 0.2;
        self.alpha = 1;
    }];
}

@end

// 箭头
@implementation MCArrow

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    CGSize curSize = rect.size;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithHexString:@"E1E2E3"].CGColor);
    CGContextSetFillColorWithColor(context, UIColor.whiteColor.CGColor);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, curSize.height);
    CGContextAddLineToPoint(context, curSize.width/2, 0);
    CGContextAddLineToPoint(context, curSize.width, curSize.height);
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
