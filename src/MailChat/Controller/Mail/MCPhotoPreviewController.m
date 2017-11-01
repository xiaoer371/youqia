//
//  MCPhotoPreviewController.m
//  NPushMail
//
//  Created by zhang on 16/8/17.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCPhotoPreviewController.h"
#import "HZPhotoBrowser.h"
#import "MCMailAttachment.h"
#import "MCTool.h"
@interface MCPhotoPreviewController ()<HZPhotoBrowserDelegate>
{
    BOOL _isShow;
}
@property (nonatomic,strong)NSMutableArray *imageAttachs;
@property (nonatomic,assign)NSInteger currentIndex;
@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIView *boomView;
@property (nonatomic,strong)HZPhotoBrowser *hzPhotoBrowser;
@end

@implementation MCPhotoPreviewController

- (id)initWithImageAttachments:(NSArray *)imageAttachs didSelectIndex:(NSInteger)selectIndex {
    
    if (self = [super initWithNibName:nil bundle:nil]) {
        _isShow = NO;
        _imageAttachs = [imageAttachs mutableCopy];
        _currentIndex = selectIndex;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
}

- (void)initSubViews {
    _originalLable.text = PMLocalizedStringWithKey(@"PM_Mail_OriginalImage");
    _originalLable.textColor = [UIColor grayColor];
    _originalLable.userInteractionEnabled = YES;
    _originalLable.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectOriginalImage:)];
    [_originalLable addGestureRecognizer:tap];
    
    [_deleteButton setTitle:PMLocalizedStringWithKey(@"PM_Mail_DeleteMail") forState:UIControlStateNormal];
    [_deleteButton setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
    _hzPhotoBrowser = [[HZPhotoBrowser alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth)];
    _hzPhotoBrowser.imageCount = _imageAttachs.count;
    _hzPhotoBrowser.delegate = self;
    _hzPhotoBrowser.browserType = BrowserTypeDelete;
    _hzPhotoBrowser.firstShowStatic = YES;
    _hzPhotoBrowser.currentImageIndex = _currentIndex;
    [self.view addSubview:_hzPhotoBrowser];
    [self.view sendSubviewToBack:_hzPhotoBrowser];
}

/**
 *  单击图片操作
 */
- (void)didSelectPhoto:(HZPhotoBrowser *)browser
{
    _isShow = !_isShow;
    [UIView animateWithDuration:0.38 animations:^{
        _navView.hidden = _isShow;
        _boomView.hidden = _isShow;
    }];
}

//HZPhotoBrowser delegate
- (UIImage*)photoBrowser:(HZPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    if (index >= _imageAttachs.count) {
        return nil;
    }
    _currentIndex = index;
    MCMailAttachment *attachment =  _imageAttachs[index];
    UIImage *image = [UIImage imageWithData:attachment.data scale:1];
//    _originalButton.hidden = attachment.originalImage?NO:YES;
//    _originalLable.hidden = attachment.originalImage?NO:YES;
//    [self setOriginalStateWithAttach:attachment];

    return image;
}
- (BOOL)photoBrowser:(HZPhotoBrowser *)browser deleteImageForIndex:(NSInteger)index {
    
    MCMailAttachment *attach = _imageAttachs[index];
    if (_deleteImageCallBack) {
        _deleteImageCallBack(attach);
    }
    [_imageAttachs removeObjectAtIndex:index];
    if (_imageAttachs.count == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    browser.imageCount --;
    return YES;
}
- (IBAction)mcDismiss:(UIButton *)sender {
    
    if (_deleteImageCallBack) {
        _deleteImageCallBack(nil);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)deleteAttachment:(UIButton *)sender {
    [_hzPhotoBrowser deleteItem];
}
- (IBAction)selectOriginalImage:(UIButton *)sender {
    
    MCMailAttachment *attachment = _imageAttachs[_currentIndex];
    if (!attachment.originalImage) {
        return;
    }
    CGFloat scale = attachment.isOriginalImage?0.5:1.0;
    attachment.data = UIImageJPEGRepresentation(attachment.originalImage, scale);
    attachment.size = attachment.data.length;
    attachment.isOriginalImage = !attachment.isOriginalImage;
    [self setOriginalStateWithAttach:attachment];
}

//set
- (void)setOriginalStateWithAttach:(MCMailAttachment *)attachment {
    
    if (attachment.isOriginalImage) {
        NSString *size = [[MCTool shared] getFileSizeWithLength:attachment.size];
        _originalLable.textColor = [UIColor whiteColor];
        _originalLable.text = [NSString stringWithFormat:@"%@ (%@)",PMLocalizedStringWithKey(@"PM_Mail_OriginalImage"),size];
        [_originalButton setImage:[UIImage imageNamed:@"mc_imageDidSelect.png"] forState:UIControlStateNormal];
    } else {
        _originalLable.textColor = [UIColor grayColor];
        _originalLable.text = PMLocalizedStringWithKey(@"PM_Mail_OriginalImage");
        [_originalButton setImage:[UIImage imageNamed:@"mc_imageDesSelect.png"] forState:UIControlStateNormal];
    }
}
@end
