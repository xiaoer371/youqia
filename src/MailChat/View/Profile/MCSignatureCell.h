//
//  MCSignatureCell.h
//  NPushMail
//
//  Created by zhang on 16/4/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCSignatureCell;

@protocol MCSignatureCellDelegate <NSObject>

- (void)signatureCell:(MCSignatureCell*)signatureCell beginEditting:(UITextView*)textView;

@end

@interface MCSignatureCell : UITableViewCell

@property (nonatomic,strong)MCAccount *mcAccount;

@property (weak, nonatomic) IBOutlet UIView *mcTitleBackgrondView;
@property (nonatomic,weak)IBOutlet UILabel *accoutLable;
@property (nonatomic,weak)IBOutlet UITextView *signatureTextView;
@property (nonatomic,assign)id <MCSignatureCellDelegate>delegate;

@end
