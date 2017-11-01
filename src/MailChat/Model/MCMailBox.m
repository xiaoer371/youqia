//
//  MailBox.m
//  NPushMail
//
//  Created by swhl on 14-10-8.
//  Copyright (c) 2014年 sprite. All rights reserved.
//

#import "MCMailBox.h"

@implementation MCMailBox

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![self.class isEqual:[other class]]) {
        return NO;
    } else {
        MCMailBox *otherBox = (MCMailBox *)other;
        return (otherBox.accountId == self.accountId && [otherBox.path isEqualToString:self.path] && otherBox.type == self.type);
    }
}

- (NSUInteger)hash
{
    return self.accountId ^ [self.path hash];
}

- (NSString*)name {
    //名称本地化
    switch (self.type) {
            
        case MCMailFolderTypeSmartBox:{
            _boxIconIamge = [UIImage imageNamed:@"mc_smartBox_icon.png"];
            return _name;
        }
            break;
        case MCMailFolderTypeInbox:{
            _boxIconIamge = AppStatus.theme.mailBoxStyle.inboxIcon;
            return PMLocalizedStringWithKey(@"PM_Mail_FolderOptionInbox");
        }
            break;
        case MCMailFolderTypePending:{
            _boxIconIamge = AppStatus.theme.mailBoxStyle.pendingBoxIcon;
            return PMLocalizedStringWithKey(@"PM_Mail_FolderOptionOutBox");
        }
            break;
        case MCMailFolderTypeSent:{
            _boxIconIamge = AppStatus.theme.mailBoxStyle.sentBoxIcon;
            return PMLocalizedStringWithKey(@"PM_Mail_FolderOptionSendBox");
        }
            break;
        case MCMailFolderTypeStarred:{
            _boxIconIamge = AppStatus.theme.mailBoxStyle.starBoxIcon;
            return PMLocalizedStringWithKey(@"PM_Mail_FolderOptionCollect");
        }
            break;
        case MCMailFolderTypeDrafts:{
            _boxIconIamge = AppStatus.theme.mailBoxStyle.draftsBoxIcon;
            return PMLocalizedStringWithKey(@"PM_Mail_FolderOptionDraft");
        }
            break;
        case MCMailFolderTypeTrash:{
            _boxIconIamge = AppStatus.theme.mailBoxStyle.trashBoxIcon;
            return PMLocalizedStringWithKey(@"PM_Mial_FolderOptionDelete");
        }
            break;
        case MCMailFolderTypeSpam:{
            _boxIconIamge = AppStatus.theme.mailBoxStyle.spamBoxIcon;
            return PMLocalizedStringWithKey(@"PM_Mail_FolderOptionSpam");
        }
            break;
        default:{
            _boxIconIamge = AppStatus.theme.mailBoxStyle.otherBoxIcon;
            return  _name;
        }
            break;
    }
}

@end
