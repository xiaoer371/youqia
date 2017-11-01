//
//  MCAttachPreviewViewcontroller.h
//  NPushMail
//
//  Created by zhang on 16/1/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"
#import "MCMailAttachment.h"
#import "MCMailManager.h"

typedef NS_ENUM(NSInteger ,MCFileSourceFrom) {
    MCFileSourceFromMail = 0,
    MCFileSourceFromLocLibrary,
    MCFileSourceFromChat,
};


@interface MCAttachPreviewViewcontroller : MCBaseSubViewController

- (id)initWithFile:(id)file manager:(MCMailManager *)mailManager fileSourceFrom:(MCFileSourceFrom)sourceFrom;

@property (nonatomic,copy)dispatch_block_t deleteAttachComplete;

@end
