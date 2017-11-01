//
//  MCAddContactBaseInfoCell.m
//  NPushMail
//
//  Created by wuwenyu on 16/8/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAddContactBaseInfoCell.h"

@implementation MCAddContactBaseInfoCell

+ (instancetype)instanceFromNib {
    return [[[NSBundle mainBundle]loadNibNamed:@"MCAddContactBaseInfoCell" owner:nil options:nil]lastObject];
}

- (void)configureCellWithModel:(id)model indexPath:(NSIndexPath*)indexPath {
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row == 0) {
                self.textField.placeholder = PMLocalizedStringWithKey(@"PM_Contact_CommentContactName");
            }else {
                self.textField.placeholder = [NSString stringWithFormat:@"* %@",PMLocalizedStringWithKey(@"PM_Contact_InputEmailAddress")];
            }
            break;
        }
        case 1:{
            self.textField.placeholder = PMLocalizedStringWithKey(@"PM_Contact_addPhoneNumbers");
            break;
        }
    }
    self.textField.text = model;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.textField];
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    if ([self.valueTextFieldDelegate  respondsToSelector:@selector(valueTextFieldDidChange:)]) {
        [self.valueTextFieldDelegate valueTextFieldDidChange:textField];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:self.textField];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
