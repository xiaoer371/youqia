//
//  MCAddContactBaseInfoCell.h
//  NPushMail
//
//  Created by wuwenyu on 16/8/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol textFieldDelegate <NSObject>

-(void) valueTextFieldDidChange:(UITextField*)textField;

@end

@interface MCAddContactBaseInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *textField;
+ (instancetype)instanceFromNib;
- (void)configureCellWithModel:(id)model indexPath:(NSIndexPath*)indexPath;
@property (nonatomic, weak)id <textFieldDelegate>valueTextFieldDelegate;

@end
