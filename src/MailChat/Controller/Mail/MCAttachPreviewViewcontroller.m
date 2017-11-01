//
//  MCAttachPreviewViewcontroller.m
//  NPushMail
//
//  Created by zhang on 16/1/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAttachPreviewViewcontroller.h"
#import "MCBaseNavigationViewController.h"
#import "MCAttachDownloadView.h"
#import <QuickLook/QuickLook.h>
#import "MCMailManager.h"
#import "MCFileBaseModel.h"
#import "MCFileCore.h"
#import "MCFileManager.h"
#import "MCIMFileModel.h"
#import "MCServerAPI+File.h"
#import "MCIMMessageManager.h"

@interface MCAttachPreviewViewcontroller ()<QLPreviewControllerDataSource,QLPreviewControllerDelegate>
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,strong) MCAttachDownloadView *attachDownloadView;
@property (nonatomic,strong) UIWebView  *webView;
@property (nonatomic,copy) id fileObject;
@property (nonatomic,assign) MCFileSourceFrom sourceFrom;

@property (nonatomic,strong)UIButton *mcDeleteItem;
//文件浏览器
@property (nonatomic,strong) QLPreviewController *qlviewController;
@property (nonatomic,strong) UIDocumentInteractionController *docInteractionController;

@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic,strong) MCMailManager *mailManager;

@end

@implementation MCAttachPreviewViewcontroller


- (id)initWithFile:(id)file manager:(MCMailManager *)mailManager fileSourceFrom:(MCFileSourceFrom)sourceFrom {
    if (self = [super init]) {
        _fileObject = file;
        _sourceFrom = sourceFrom;
        _mailManager = mailManager;
    }
    return self;
}

- (UIWebView*)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0,0,ScreenWidth,ScreenHeigth - NAVIGATIONBARHIGHT)];
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (UIButton*)mcDeleteItem {
    
    if (!_mcDeleteItem) {
        _mcDeleteItem = [UIButton buttonWithType:UIButtonTypeCustom];
        _mcDeleteItem.frame = CGRectMake(ScreenWidth - 60, ScreenHeigth - 60 -NAVIGATIONBARHIGHT, 50, 50);
        [_mcDeleteItem setImage :[UIImage imageNamed:@"mc_mailaddAttach_delete.png"] forState:UIControlStateNormal];
        [_mcDeleteItem addTarget:self action:@selector(mcDeleteAttachment:)forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_mcDeleteItem];
    }
    return _mcDeleteItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    NSString *title ;
    if (_sourceFrom == MCFileSourceFromMail) {
        //邮件附件浏览
        MCMailAttachment *attachment = (MCMailAttachment*)_fileObject;
        if (attachment.isDownload && attachment.localPath) {
            [self showFileWithPath:attachment.localPath];
        } else {
            [self toLoadDownloadViewWithMCMailAttachment:attachment];
        }
        title = attachment.name;
        
    } else if (_sourceFrom == MCFileSourceFromLocLibrary){
        //本地文件浏览
        MCFileBaseModel *fileBaseModel = (MCFileBaseModel*)_fileObject;
        [self showFileWithPath:fileBaseModel.location];
        title = fileBaseModel.sourceName;
    } else {
        
        MCIMFileModel *msgModel =(MCIMFileModel*)_fileObject;
        MCFileBaseModel *fileModel = [[MCFileCore sharedInstance] getFileModelWithFileId:msgModel.fileId];
        if (!fileModel) {
            //下载
            [self toLoadDownloadViewWithMFileModel:msgModel];
        }
        else {
            //预览
            if (!msgModel.localPath) {
                msgModel.localPath = [NSString stringWithFormat:@"%@/%@",msgFileDirectory,msgModel.name];
            }
            [self showFileWithPath:msgModel.localPath];
        }
        
        title = msgModel.name;
    }
    self.viewTitle = title;
    [self showSheardItem];
    //显示删除选项；
    self.mcDeleteItem.hidden = _deleteAttachComplete?NO:YES;
}

#pragma mark fileModel
- (void)toLoadDownloadViewWithMFileModel:(MCIMFileModel*)fileModel
{
    if (!_attachDownloadView) {
        _attachDownloadView = [[MCAttachDownloadView alloc]initWithType:MCDownloadFiletypeFromChat withFileModel:fileModel];
        __weak typeof(self)weekSelf = self;
        _attachDownloadView.cancelDownloadAttachment = ^ {
            [weekSelf.downloadTask cancel];
            [weekSelf.navigationController popViewControllerAnimated:YES];
        };
        
        [self.view addSubview:_attachDownloadView];
    }
    __weak typeof(self)weekSelf = self;
    
     self.downloadTask =  [ServerAPI downLoadFileWithFileModel:fileModel progress:^(NSInteger currentBytes, NSInteger totalBytes) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weekSelf.attachDownloadView.progress =(CGFloat)currentBytes;
        });
    } success:^(id filePath) {
        NSURL *fileUrl = (NSURL *)filePath;
        NSData *data = [NSData dataWithContentsOfURL:fileUrl];
        MCFileManager *fileManager =[[MCFileCore sharedInstance] getFileModule];
       NSString *shortPath = [fileManager saveFileWithData:data folder:msgFileDirectory fileName:fileModel.name];
        NSError *error = nil;
        BOOL flag = [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&error];
        if (flag) {
        }else{
            DDLogError(@"文件删除失败 = %@",error);
        }
        fileModel.localPath = shortPath;
        fileModel.fileId = fileModel.messageId;
        [[MCFileCore sharedInstance] saveFileInDbWithModel:fileModel];

        dispatch_async(dispatch_get_main_queue(), ^{
            fileModel.downloadState = IMFileDownloaded;
            MCIMMessageManager *messageManager =[[MCIMMessageManager alloc] init];
            [messageManager updateMessage:fileModel];
            [weekSelf showFileWithPath:fileModel.localPath];
        });
    } failure:^(NSError *error) {
        
    }];
    
}

#pragma mark MCMailAttachment
- (void)toLoadDownloadViewWithMCMailAttachment:(MCMailAttachment*)mailAttachment {
    
    if (!_attachDownloadView) {
        _attachDownloadView = [[MCAttachDownloadView alloc]initWithType:MCDownloadFiletypeFromEmail withFileModel:mailAttachment];
        __weak typeof(self)weekSelf = self;
        _attachDownloadView.cancelDownloadAttachment = ^ {
            [weekSelf.navigationController popViewControllerAnimated:YES];
            [weekSelf.mailManager cancelOpration];
        };
        
        [self.view addSubview:_attachDownloadView];
    }
   //下载邮件附件
    typeof(self)weak = self;
    [self.mailManager getAttachmentDataInfo:mailAttachment progress:^(NSInteger current, NSInteger maximum) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (maximum == 0) {
                return ;
            }
            weak.attachDownloadView.progress = (CGFloat)current/maximum;
        });
    } success:^(id response) {
        DDLogDebug(@"download attachment success");
        dispatch_async(dispatch_get_main_queue(), ^{
            [weak showFileWithPath:mailAttachment.localPath];
        });
        
    } failure:^(NSError *error) {
        DDLogDebug(@"download attachement error = %@",error);
    }];
}
//show
- (void)showFileWithPath:(NSString*)filePath {
  
    self.filePath = filePath;
    if (!self.filePath) {
        //TODO:路径失败错误处理；
    }
    
    if ([filePath.pathExtension isEqualToString:@"txt"]) {
        
        NSString*fullFilePath = [[[MCFileCore sharedInstance] getFileModule] getFileFullPathWithShortPath:filePath];
        NSString *txtFile = [self encodeTextFileWithPath:fullFilePath];
        if (txtFile) {
            //尝试编码后加载
            [self.webView loadHTMLString:txtFile baseURL:nil];
            
        } else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullFilePath]];
            [self.webView loadRequest:request];
        }
        
    } else {
        
        if (_attachDownloadView) {
            [_attachDownloadView removeFromSuperview];
            _attachDownloadView = nil;
        }
        _qlviewController = [[QLPreviewController alloc]init];
        CGRect rect = _qlviewController.view.frame;
        rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        _qlviewController.view.frame = rect;
        _qlviewController.view.autoresizingMask = self.view.autoresizingMask;
        [self.view addSubview:_qlviewController.view];
        if (EGOVersion_iOS10) {
           [self addChildViewController:_qlviewController];
        }
        _qlviewController.dataSource = self;
        [_qlviewController reloadData];
        
        /* TODO :
         * ps:ios 10 不加这个 附件不显示
         * [self addChildViewController:_qlviewController];
         *  加了addChildViewController: 导致iOS8.0  8.1  显示异常
         *  iOS8.0  8.1 这个属性会修改导致导航栏透明，UI坐标上移64像素，这里再次设置成默认值：NO
            [self.navigationController.navigationBar setTranslucent:NO];
         */
    }
}

- (void)showSheardItem {
    
    [self.rightNavigationBarButtonItem setImage:[AppStatus.theme.mailStyle.attachmentShareImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}

#pragma mark - QLPreviewController delegate  dataSource
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
   
    NSString*fullFilePath = [[[MCFileCore sharedInstance] getFileModule] getFileFullPathWithShortPath:_filePath];
    return [NSURL fileURLWithPath:fullFilePath];
}

#pragma mark UIWebViewDelegate

- (NSString*)encodeTextFileWithPath:(NSString*)path {
    NSString*textFile;
    NSURL *url = [NSURL fileURLWithPath:path];
    textFile = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    if (!textFile) {
        //gb2312编码后再尝试打开
        NSStringEncoding encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        textFile = [NSString stringWithContentsOfURL:url encoding:encode error:nil];
    }
    return textFile;
}
//分享文件
- (void)rightNavigationBarButtonItemAction:(id)sender {
    
    NSString*fullFilePath = [[[MCFileCore sharedInstance] getFileModule] getFileFullPathWithShortPath:_filePath];
    
    if (!_filePath) {
        return;
    }
    self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:fullFilePath]];
    [self.docInteractionController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
}

//TODO:back cancelOpration
- (void)leftNavigationBarButtonItemAction:(id)sender {
    
    [super leftNavigationBarButtonItemAction:sender];
    [self.mailManager cancelOpration];
}

//delete attach
- (void)mcDeleteAttachment:(UIButton*)sender {
    if (_deleteAttachComplete) {
        _deleteAttachComplete();
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
