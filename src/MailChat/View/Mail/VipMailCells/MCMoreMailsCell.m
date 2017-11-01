//
//  MCMoreMailsCell.m
//  NPushMail
//
//  Created by zhang on 2016/12/8.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMoreMailsCell.h"

@implementation MCMoreMailsCell


+(UINib*)registNib {
    return [UINib nibWithNibName:@"MCMoreMailsCell" bundle:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    [self.moreMailsButton setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
}

- (void)setMailCount:(NSInteger)mailCount {
    [self.moreMailsButton setTitle:[NSString stringWithFormat:@"%@(%lu)",PMLocalizedStringWithKey(@"PM_Mail_ShowAllMails"),(unsigned long)mailCount] forState:UIControlStateNormal];
}

- (IBAction)showMoreMails:(id)sender {
    if (self.showMoreMailsCallback) {
        self.showMoreMailsCallback ();
    }
}


@end
