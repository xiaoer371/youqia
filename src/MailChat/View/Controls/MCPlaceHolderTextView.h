//
//  MCPlaceJolderTextView.h
//  NPushMail
//
//  Created by zhang on 16/4/19.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCPlaceHolderTextView : UITextView

@property (nonatomic,strong)UILabel *placeHolderLabel;
@property (nonatomic,strong)NSString *placeholder;
@property (nonatomic,strong)UIColor *placeHoderColor;

- (void)textChanged:(NSNotification*)notification;

@end
