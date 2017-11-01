//
//  MCMailAttachListView.h
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCMailAttachListCell.h"

const static CGFloat kMCMailAttchListCellHight =  46;

@class MCMailAttachListView;

@protocol MCMailAttachListViewDelegate <NSObject>

- (void)mailAttachListView:(MCMailAttachListView*)mailAttachListView didSelectAttach:(MCMailAttachment*)mailAttachment;

@end


@interface MCMailAttachListView : UIView

@property (nonatomic,weak)id <MCMailAttachListViewDelegate>delegate;

@property (nonatomic,strong)NSArray *mailAttachments;

- (id)initWithMCMailAttachment:(NSArray*)mailAttchments;

@end
