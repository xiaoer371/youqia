//
//  MCAddFileManager.m
//  NPushMail
//
//  Created by zhang on 16/3/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAddFileManager.h"
#import "MCFileBaseModel.h"
#import "MCFileCore.h"
#import "MCFileManager.h"
#import "QBImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MCFileManagerViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCAvailablePhotoViewController.h"
#import "DNImagePickerController.h"
#import "DNAsset.h"
@interface MCAddFileManager ()<UINavigationControllerDelegate,QBImagePickerControllerDelegate,UIImagePickerControllerDelegate,DNImagePickerControllerDelegate>

@property (nonatomic,weak)id <MCAddFileManagerDelegate> delegate;
@property (nonatomic,weak)UIViewController *viewController;

@end

@implementation MCAddFileManager

- (id)initManagerWithDelegate:(id)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _viewController = (UIViewController*)delegate;
    }
    return self;
}

- (void)sourceShow{
    
    if (self.addFileSource == MCAddFileSourceTypeCamera) {
        
        UIImagePickerController*picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.sourceType = (UIImagePickerControllerSourceType)self.addFileSource;
        [_viewController.navigationController presentViewController:picker animated:YES completion:NULL];
        
    } else if (self.addFileSource == MCAddFileSourceTypePhotoLibrary){
        
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
            //无权限
            MCAvailablePhotoViewController* v = [[MCAvailablePhotoViewController alloc] init];
            MCBaseNavigationViewController*navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:v];
            [_viewController presentViewController:navigationController animated:YES completion:^{
            }];
            return;
        } else {
            
            DNImagePickerController *imagePicker = [[DNImagePickerController alloc] init];
            imagePicker.filterType = DNImagePickerFilterTypePhotos;
            imagePicker.sureButtonTitle = PMLocalizedStringWithKey(@"PM_Msg_GroupMemberAdd");
            imagePicker.imagePickerDelegate = self;
            imagePicker.maxNumber = _mcAddFilesManagerImageCount == 0?6:_mcAddFilesManagerImageCount;;
            [_viewController.navigationController presentViewController:imagePicker animated:YES completion:nil];
        }
        
    } else {
        //文件
        MCFileManagerViewController *fileManagerViewController = [[MCFileManagerViewController alloc]initWithFromType:MCFileCtrlFromMail selectedFileBlock:^(id models) {
            NSArray*files = (NSArray*)models;
            [self didSelectFiles:files];
        }];
        
        MCBaseNavigationViewController*navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:fileManagerViewController];
        [_viewController presentViewController:navigationController animated:YES completion:NULL];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
   
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
//{
//    UIImage* original = [info objectForKey:UIImagePickerControllerOriginalImage];
//    MCMailAttachment *attachment = [self  mailAttachmentWith:original thumbImage:original name:nil scale:0.8];
//    if ([_delegate respondsToSelector:@selector(manager:didAddFiles:finish:)]) {
//        [_delegate manager:self didAddFiles:@[attachment] finish:YES];
//    }
//    [picker dismissViewControllerAnimated:YES completion:nil];
//}


#pragma mark FileMagager callback
- (void)didSelectFiles:(NSArray*)files {
    
    NSMutableArray*attachments = [NSMutableArray new];
    for (MCFileBaseModel *fileModel in files) {
        NSData*data = [[[MCFileCore sharedInstance] getFileModule] getFileDataWithShortPath:fileModel.location];
        BOOL isImage = [fileModel.format isEqualToString:@"jpg"]|[fileModel.format isEqualToString:@"png"];
        MCMailAttachment *attachment = [self mailAttachmentData:data
                                                     thumbImage:nil
                                                           name:fileModel.sourceName
                                                           path:fileModel.location
                                                        isImage:isImage];
        
        attachment.size = (NSInteger)fileModel.size;
        [attachments addObject:attachment];
    }
    if ([_delegate respondsToSelector:@selector(manager:didAddFiles:finish:)]) {
        [_delegate manager:self didAddFiles:attachments finish:YES];
    }
}


#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage*image = info[UIImagePickerControllerOriginalImage];
    
    MCMailAttachment*attachment = [self mailAttachmentWith:image
                                                thumbImage:image
                                                      name:nil
                                                     scale:0.5];
    //delegate
    if ([_delegate respondsToSelector:@selector(manager:didAddFiles:finish:)]) {
        [_delegate manager:self didAddFiles:@[attachment]finish:YES];
    }
    [self dismissImagePickerController];
}

- (void)dismissImagePickerController{
    
    [_viewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - dnPickDelegate

- (void)dnImagePickerController:(DNImagePickerController *)imagePicker
                     sendImages:(NSArray *)imageAssets
                    isFullImage:(BOOL)fullImage {
    
    ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary new];
    __block NSInteger finishAdd = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (DNAsset *dnAsset in imageAssets) {
            [assetsLibrary assetForURL:dnAsset.url resultBlock:^(ALAsset *asset) {
                if (asset) {
                     MCMailAttachment *attach = [self getImageAttachWithALsset:asset];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([_delegate respondsToSelector:@selector(manager:didAddFiles:finish:)]) {
                            finishAdd++;
                            BOOL finish = finishAdd == imageAssets.count?YES:NO;
                            [_delegate manager:self didAddFiles:@[attach] finish:finish];
                        }
                    });
                    
                } else {
                    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                            if ([result valueForProperty:ALAssetPropertyAssetURL]) {
                                *stop = YES;
                                MCMailAttachment *attach = [self getImageAttachWithALsset:result];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if ([_delegate respondsToSelector:@selector(manager:didAddFiles:finish:)]) {
                                        finishAdd++;
                                        BOOL finish = finishAdd == imageAssets.count?YES:NO;
                                        [_delegate manager:self didAddFiles:@[attach] finish:finish];
                                    }
                                });
                            }
                        }];
                        
                    } failureBlock:nil];
                }
                
            } failureBlock:nil];
        }
    });
    
    [self dismissImagePickerController];
}

- (void)dnImagePickerControllerDidCancel:(DNImagePickerController *)imagePicker {
    [self dismissImagePickerController];
}

//pravite

- (MCMailAttachment*)getImageAttachWithALsset:(ALAsset*)asset {
    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
    //通过ALAsset获取相对应的资源，获取图片的等比缩略图，原图的等比缩略
    CGImageRef ratioThum = [asset thumbnail];
    UIImage* thumbnail = [UIImage imageWithCGImage:ratioThum];
    MCMailAttachment *attachment = [MCMailAttachment new];
    attachment.thumbImage = thumbnail;
    attachment.name = assetRep.filename;
    attachment.size = assetRep.size;
    attachment.mimeType = attachment.name.pathExtension;
    attachment.fileExtension = attachment.name.pathExtension;
    CGImageRef ref =  [assetRep fullResolutionImage];
    UIImage *resolutionImage = [UIImage imageWithCGImage:ref];
    attachment.originalImage = resolutionImage;
    attachment.data = UIImageJPEGRepresentation(resolutionImage, 0.5);
    attachment.isImage = YES;
    attachment.isDownload = YES;
    return attachment;
}

//image
- (MCMailAttachment*)mailAttachmentWith:(UIImage*)originalImage thumbImage:(UIImage*)thumbIamge name:(NSString*)name scale:(CGFloat)scale
{
    NSData*data = UIImageJPEGRepresentation(originalImage, scale);
    if (!name) {
        name = @"image.jpg";
    }
    return [self mailAttachmentData:data
                         thumbImage:thumbIamge
                               name:name
                               path:nil
                            isImage:YES];
}

//file
- (MCMailAttachment*)mailAttachmentData:(NSData*)data
                             thumbImage:(UIImage*)thumbIamge
                                   name:(NSString*)name
                                   path:(NSString*)path
                                isImage:(BOOL)isImage{
    
    MCMailAttachment*attachModel = [MCMailAttachment new];
    attachModel.thumbImage = thumbIamge;
    attachModel.mimeType = name.pathExtension;
    attachModel.fileExtension = name.pathExtension;
    attachModel.name = name;
    attachModel.data = data;
    attachModel.size = data.length;
    attachModel.localPath = path;
    attachModel.isDownload = YES;
    attachModel.isImage = isImage;
    return attachModel;
}

@end
