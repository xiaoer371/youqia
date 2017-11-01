//
//  MailModel.m
//  NPushMail
//
//  Created by swhl on 14-9-15.
//  Copyright (c) 2014年 sprite. All rights reserved.
//

#import "MCMailModel.h"

@implementation MCMailModel {
    BOOL _isRead;
    BOOL _isStar;
    BOOL _isAnswer;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![self.class isEqual:[other class]]) {
        return NO;
    } else {
        MCMailModel *otherModel = (MCMailModel *)other;
        if (otherModel.uid == self.uid) {
            return YES;
        }
        
        if (otherModel.boxId == self.boxId && otherModel.messageUid == self.messageUid) {
            return YES;
        }
        
        return NO;
    }
}

- (NSUInteger)hash
{
    return self.boxId ^ self.messageUid;
}


- (NSArray*)emailArrayFromString:(NSString*)emailStr
{
    if ([emailStr rangeOfString:@","].location != NSNotFound) {
        return [emailStr componentsSeparatedByString:@","];
    }
    return @[emailStr];
    
}

- (BOOL)isEqualToDraftModel:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    MCMailModel *other = object;
    
    
    if (![MCMailModel isAddressEqual:self.to to:other.to]) {
        return NO;
    }
    
    if (![MCMailModel isAddressEqual:self.cc to:other.cc]) {
        return NO;
    }
    
    if (![MCMailModel isAddressEqual:self.bcc to:other.bcc]) {
        return NO;
    }
    
    if (![MCMailModel obj:self.subject equalTo:other.subject]) {
        return NO;
    }
    
    if (self.hasAttachment != other.hasAttachment) {
        return NO;
    }

    if (![self isMessageContentEqual:self.messageContentString to:other.messageContentString]) {
        return NO;
    }
    
    return YES;

}

+ (BOOL)obj:(id)obj equalTo:(id)obj2
{
    if ((obj == nil || [obj length] == 0) && (obj2 == nil || [obj2 length] == 0)) {
        return YES;
    }
    
    if (obj != nil && obj2 != nil) {
        return [obj isEqualToString:obj2];
    }
    
    return NO;
}

- (BOOL)isMessageContentEqual:(id)msg1 to:(id)msg2
{
    if ([MCMailModel obj:[self contentTrimWith:msg1] equalTo:[self contentTrimWith:msg2]]) {
        return YES;
    }
    
    return  [self isEmptyString:msg1] && [self isEmptyString:msg2];
    
}

- (NSString*)contentTrimWith:(NSString*)str {
    
    return AppStatus.currentUser.signature?[[str stringByReplacingOccurrencesOfString:AppStatus.currentUser.signature withString:@""] trim]:[str trim];
}


- (BOOL)isEmptyString:(id)str
{
    if (!str) {
        return YES;
    }
    
    NSString *trimStr = [str trim];
    if ([trimStr isEqualToString:@""]) {
        return YES;
    }
    
    NSString *noContentString = [PMLocalizedStringWithKey(@"PM_Mail_NoneTextContent") trim];
    
    
    return [trimStr isEqualToString:noContentString];
    
}
+ (BOOL)isAddressEqual:(NSArray*)address1 to:(NSArray*)address2 {
    
    if (address1.count != address2.count) {
        return NO;
    }
    for (int i = 0; i < address1.count; i ++) {
        MCMailAddress *ad = address1[i];
        if ([address2 indexOfObject:ad] == NSNotFound) {
            return NO;
        }
    }
    return YES;
}

//set

- (void)setIsRead:(BOOL)isRead {
    _isRead = isRead;
    if (isRead) {
        _mailFlags = _mailFlags |MCMailFlagSeen;
    } else {
        _mailFlags = _mailFlags&(~MCMailFlagSeen);
    }
}

- (BOOL)isRead {
    return _mailFlags&MCMailFlagSeen;
}

- (void)setIsStar:(BOOL)isStar {
    _isStar = isStar;
    if (isStar) {
        _mailFlags = _mailFlags |MCMailFlagStar;
    } else {
        _mailFlags = _mailFlags&(~MCMailFlagStar);
    }
}

- (BOOL)isStar {
    return _mailFlags&MCMailFlagStar;
}

- (void)setIsAnswer:(BOOL)isAnswer {
    _isAnswer = isAnswer;
    if (isAnswer) {
        _mailFlags = _mailFlags |MCMailFlagAnswered;
    } else {
        _mailFlags = _mailFlags&(~MCMailFlagAnswered);
    }
}

- (BOOL)isAnswer {
    return _mailFlags&MCMailFlagAnswered;
}
@end
