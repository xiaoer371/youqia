//
//  MCMailComposerExtestionView.h
//  NPushMail
//
//  Created by zhang on 16/1/11.
//  Copyright © 2016年 sprite. All rights reserved.
//


@class MCMailAddress;

typedef void(^searchComplete)(MCMailAddress *mailAddress);

#import <UIKit/UIKit.h>
#import "MCMailAddress.h"

@interface MCMailComposerExtensionView : UIView
@property (nonatomic,copy)searchComplete searchCompleteCallBack;
@property (nonatomic,strong)NSString     *searchString;
@property (nonatomic,strong)NSArray     *resultContacts;
@end
