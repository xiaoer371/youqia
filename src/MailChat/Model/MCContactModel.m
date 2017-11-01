//
//  MCContactModel.m
//  NPushMail
//
//  Created by wuwenyu on 16/1/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactModel.h"
#import "pinyin.h"
#import "MCAvatarHelper.h"

@implementation MCContactModel{
    NSString *_headImageUrl;
    NSString *_largeHeadImageUrl;
}

- (NSString *)peerName
{
    return self.displayName;
}

- (NSString *)avatarUrl
{
    return self.headImageUrl;
}

- (void)setHeadChecksum:(NSString *)headChecksum
{
    _headImageUrl = nil;
    _largeHeadImageUrl = nil;
    _headChecksum = [headChecksum copy];
}

- (NSString *)headImageUrl
{
    if (_headImageUrl) {
        return _headImageUrl;
    }
    
    _headImageUrl = [MCAvatarHelper avatarUrlWithChecksum:_headChecksum];
    return _headImageUrl;
}

- (NSString *)largeHeadImageUrl
{
    if (!_headChecksum) {
        return nil;
    }
    
    return [MCAvatarHelper largeAvatarUrlWithChecksum:_headChecksum];
}

- (NSString *)displayName
{
    if (self.noteDisplayName.length > 0) {
        return self.noteDisplayName;
    }
    
    if (self.enterpriseUserName.length > 0) {
        return self.enterpriseUserName;
    }
    
    if (self.youqiaNickName.length > 0) {
        return self.youqiaNickName;
    }
    
    if (self.emailNickName.length > 0) {
        return self.emailNickName;
    }
    
    return [self.account mailName];
}

- (UIImage *)avatarPlaceHolder
{
    return [MCAvatarHelper avatarWithEmail:self.account displayName:self.displayName defaultColorString:self.headDefaultColorStr];
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:self.class]) {
        return NO;
    } else {
        MCContactModel *otherContact = (MCContactModel *)other;
        return [otherContact.account isEqualToString:self.account];
    }
}

- (NSUInteger)hash
{
    return [self.account hash];
}

+ (NSString *)getPinYinFirstCharWith:(NSString *)str {
    if(str == nil) {
        str = @"";
    }
     NSString *singlePinyinLetter = @"#";
    if(![str isEqualToString:@""]) {
        singlePinyinLetter = [[NSString stringWithFormat:@"%c",                                                 pinyinFirstLetter ([str characterAtIndex:0])] uppercaseString];
        NSString *wordRegex = @"[A-Z]";
        NSPredicate *wordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", wordRegex];
        if ([wordPredicate evaluateWithObject:singlePinyinLetter]) {
            return singlePinyinLetter;
        }
        singlePinyinLetter = @"#";
    }
    return singlePinyinLetter;
}

+ (NSString *)getPinyin:(NSString *)str {
    if(str == nil) {
        str = @"";
    }
    NSString *pinYin = @"";
    if(![str isEqualToString:@""]) {
        NSString *pinYinResult = [NSString string];
        for(int j =0; j < str.length; j++) {
            NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c",                                                 pinyinFirstLetter ([str characterAtIndex:j])] uppercaseString];
            pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
        }
        pinYin = pinYinResult;
    }else {
        pinYin = @"";
    }
    return pinYin;
}

+ (MCContactModel *)contactWithEmail:(NSString *)email emailNickName:(NSString *)emailNickName {
    MCContactModel *model = [[MCContactModel alloc] init];
    model.account = email;
    
    model.emailNickName = [emailNickName trim];
    model.headDefaultColorStr = [MCAvatarHelper randomColorHexString];
    model.pinyin = [self getPinyin:model.emailNickName];
    model.pinyinFirstChar = [self getPinYinFirstCharWith:model.emailNickName];
    model.youqiaFlag = NO;
    return model;
}

+ (NSSet *)keyPathsForValuesAffectingPeerName
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(displayName))];
}

+ (NSSet *)keyPathsForValuesAffectingAvatarUrl
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(headImageUrl))];
}

+ (NSSet *)keyPathsForValuesAffectingDisplayName
{
    return [NSSet setWithObjects:NSStringFromSelector(@selector(noteDisplayName)), NSStringFromSelector(@selector(enterpriseUserName)), NSStringFromSelector(@selector(youqiaNickName)), NSStringFromSelector(@selector(emailNickName)), nil];
}

@end
