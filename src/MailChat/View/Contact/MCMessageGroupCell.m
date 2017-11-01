//
//  MCMessageGroupCell.m
//  NPushMail
//
//  Created by wuwenyu on 16/7/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMessageGroupCell.h"
#import "MCIMGroupModel.h"

@implementation MCMessageGroupCell

+ (instancetype)instanceFromNib {
    return [[[NSBundle mainBundle]loadNibNamed:@"MCMessageGroupCell" owner:nil options:nil]lastObject];
}

- (void)configureCellWithModel:(id)model {
    if ([model isMemberOfClass:[MCIMGroupModel class]]) {
        MCIMGroupModel *groupModel = (MCIMGroupModel *)model;
        self.groupNameLabel.text = groupModel.groupName;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setSubViewStyle];
    // Initialization code
}

- (void)setSubViewStyle {
    self.avatorImgView.image = [UIImage imageNamed:@"msgGroupIcon.png"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
