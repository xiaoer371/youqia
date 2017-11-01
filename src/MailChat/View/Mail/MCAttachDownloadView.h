//
//  MCAttachDownloadView.h
//  NPushMail
//
//  Created by zhang on 16/3/28.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCMailAttachment.h"
#import "MCIMFileModel.h"

typedef NS_ENUM(NSInteger ,MCDownloadFiletype) {
    MCDownloadFiletypeFromEmail = 0,
    MCDownloadFiletypeFromChat,
};

@interface MCAttachDownloadView : UIView

@property (nonatomic,strong) id fileModel;

@property (nonatomic,assign) CGFloat progress;

@property (nonatomic,copy)  dispatch_block_t cancelDownloadAttachment;

- (instancetype)initWithType:(MCDownloadFiletype)type withFileModel:(id)fileModel;


@end
