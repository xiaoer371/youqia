//
//  MCAddAttachmentView.h
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCAddAtttachmentCell.h"
@class MCAddAttachmentView;

@protocol MCAddAttachmentViewDelegate <NSObject>

- (void)addAttachmentView:(MCAddAttachmentView*)addAttachmentView didSelectImagePickerSourceType:(NSInteger)imagePickerSourceType;

- (void)didDeleteAttachment:(MCMailAttachment*)mailAttachment index:(NSInteger)index;

- (void)addAttachmentView:(MCAddAttachmentView *)addAttachmentView didSelectAttach:(MCMailAttachment *)attachment imageAttachs:(NSArray*)attachments index:(NSInteger)index;
@end

@interface MCAddAttachmentView : UIView

@property (nonatomic,weak)id <MCAddAttachmentViewDelegate> delegate;
@property (nonatomic,strong)NSMutableArray *mailAttachments;

- (id)initWithMailAttachments:(NSMutableArray*)mailAttachments;
- (void)reload;

@end
