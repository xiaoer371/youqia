//
//  MCLoginExtensionView.h
//  NPushMail
//
//  Created by zhang on 16/1/22.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Extension.h"
@class MCLoginExtensionView;
@protocol MCLoginExtensionViewDelegate <NSObject>

- (void)mcLoginExtensionView:(MCLoginExtensionView*)extensionView didSelectEmail:(NSString*)email;

@end

@interface MCLoginExtensionView : UIView

@property (nonatomic,weak)id <MCLoginExtensionViewDelegate> delegate;

@property (nonatomic,strong)NSString * email;

- (id)initWithFrame:(CGRect)frame EmailType:(NSInteger)emailType;
@end
