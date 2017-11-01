//
//  MCAccount.m
//  NPushMail
//
//  Created by admin on 12/24/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCAccount.h"
#import "MCAvatarHelper.h"
#import "MCMailManager.h"
@implementation MCAccount
{
    NSString *_dataFolder;
}

- (NSString *)dataFolder
{
    if (!_dataFolder) {
        NSString *folderName = [[self.email stringByReplacingOccurrencesOfString:@"@" withString:@"_"] stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        _dataFolder = [AppStatus.documentDir stringByAppendingPathComponent:folderName];
        BOOL isFolder = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:_dataFolder isDirectory:&isFolder]) {
            NSError *error = nil;
            BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:_dataFolder withIntermediateDirectories:NO attributes:nil error:&error];
            if (!success) {
                DDLogError(@"Create directory error = %@", error);
            }
        }
    }
    
    return _dataFolder;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return  YES;
    }
    
    if (![other isKindOfClass:[self class]]) {
        return NO;
    }
    
    MCAccount *otherAccount = (MCAccount *)other;
    if (otherAccount.accountId == self.accountId) {
        return YES;
    }
    
    return [self.email isEqualToString:otherAccount.email];
}

- (NSUInteger)hash
{
    return [self.email hash];
}

-(void)setAvatarUrl:(NSString *)avatarUrl
{
    
}


- (NSString *)avatarUrl
{
    return [MCAvatarHelper avatarUrlWithChecksum:self.avatar];
}

- (UIImage *)avatarPlaceHolder
{
    if (!self.color) {
        NSString *colorString = [MCAvatarHelper randomColorHexString];
        self.color = [UIColor colorWithHexString:colorString];
    }
    
    return [MCAvatarHelper avatarWithEmail:self.email displayName:self.displayName defaultColor:self.color];
}

- (NSString *)signature
{
    if (!_signature) {
        _signature = PMLocalizedStringWithKey(@"PM_Mail_Signature");
    }
    return _signature;
}

- (BOOL)isFreeMail
{
    NSString *mailDomain = [self.email mailDomain];
    NSRange range = [mailDomain rangeOfString:@"."];
    NSString *hostName = [[mailDomain substringToIndex:range.location] lowercaseString];
    return [[[self class] freeMailArray] containsObject:hostName];
    
}

+ (NSArray *)freeMailArray
{
    static NSArray *mails;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        mails = @[@"163",
                  @"sina",
                  @"hotmail",
                  @"live",
                  @"tom",
                  @"netease",
                  @"189",
                  @"173",
                  @"icloud",
                  @"pchome",
                  @"128",
                  @"2980",
                  @"kuikoo",
                  @"shortmail",
                  @"qip",
                  @"fastmail",
                  @"ok",
                  @"virgilio",
                  @"qq",
                  @"foxmail",
                  @"sina",
                  @"outlook",
                  @"21cn",
                  @"163",
                  @"wo",
                  @"aliyun",
                  @"tianya",
                  @"sunmail",
                  @"korean",
                  @"inbox",
                  @"mail2world",
                  @"goo",
                  @"fishwang",
                  @"gmail",
                  @"sohu",
                  @"chinaren",
                  @"139",
                  @"126",
                  @"renren",
                  @"gmx",
                  @"in",
                  @"yandex",
                  @"facebook",
                  @"india",
                  @"nextmail",
                  @"v",
                  @"leemail",
                  @"yahoo",
                  @"sogou",
                  @"17173",
                  @"aol",
                  @"yeah",
                  @"cntv",
                  @"nokia",
                  @"hushmail",
                  @"opera",
                  @"lycos",
                  @"ibibo",
                  @"zoho",
                  @"k"];
    });
    
    return mails;
}

@end
