//
//  MCPhotoPreviewController.h
//  NPushMail
//
//  Created by zhang on 16/8/17.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"
#import "MCMailAttachment.h"
typedef void(^deleteImageComplete)(MCMailAttachment* attach);

@interface MCPhotoPreviewController : MCBaseSubViewController

- (id)initWithImageAttachments:(NSArray*)imageAttachs didSelectIndex:(NSInteger)selectIndex;

@property (nonatomic,weak)IBOutlet UIButton *deleteButton;
@property (nonatomic,weak)IBOutlet UIButton *originalButton;
@property (nonatomic,weak)IBOutlet UILabel *originalLable;
@property (nonatomic,copy)deleteImageComplete deleteImageCallBack;
@end
