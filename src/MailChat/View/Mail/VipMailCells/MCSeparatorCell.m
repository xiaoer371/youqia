//
//  MCSeparatorCell.m
//  NPushMail
//
//  Created by zhang on 2016/12/8.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCSeparatorCell.h"

@implementation MCSeparatorCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor colorWithHexString:@"f7f7f9"];
    self.separatorInset = UIEdgeInsetsZero;
}

+ (UINib*)registNib {
    return [UINib nibWithNibName:@"MCSeparatorCell" bundle:nil];
}

@end
