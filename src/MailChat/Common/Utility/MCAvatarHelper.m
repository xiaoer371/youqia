//
//  MCAvatarHelper.m
//  NPushMail
//
//  Created by admin on 4/7/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCAvatarHelper.h"
#import "UIView+Image.h"
#import <SDImageCache.h>
#import "UIColor+Hex.h"
#import "MCAppSetting.h"

@implementation MCAvatarHelper

+ (NSArray *)colors
{
    static NSArray *headColors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        headColors = @[@"5e97f6", @"5ec9f6", @"3bc2b5", @"7dda70", @"5c6bc0", @"f65e8d", @"bd84cd", @"ff943e", @"ffd254", @"ff5d5d", @"ff8e6b"];
    });
    return headColors;
}

+ (NSString *)randomColorHexString
{
    NSArray *headColors = [[self class] colors];
    NSString *colorStr = headColors[arc4random()%11];
    return colorStr;
}

+ (UIImage *)avatarWithEmail:(NSString *)email displayName:(NSString *)name defaultColorString:(NSString *)colorStr
{
    NSString *displayName = name.length > 0 ? name: [email mailName];
    UIColor *bgColor = [UIColor colorWithHexString:colorStr];
    NSString *key = [NSString stringWithFormat:@"%@_%@",displayName,colorStr];
    return [self avatarWithKey:key displayName:displayName defaultColor:bgColor];
}

+ (UIImage *)avatarWithEmail:(NSString *)email displayName:(NSString *)name defaultColor:(UIColor *)color
{
    NSString *displayName = name.length > 0 ? name: [email mailName];
    NSString *hexColor = [color hexString];
    NSString *key = [NSString stringWithFormat:@"%@_%@",displayName,hexColor];
    return [self avatarWithKey:key displayName:displayName defaultColor:color];
}

+ (UIImage *)avatarWithKey:(NSString *)key displayName:(NSString *)name defaultColor:(UIColor *)color
{
    if (!key) {
        return nil;
    }
    
    UIImage *avatar = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    if (avatar) {
        return avatar;
    }
    
    if (!name||name.length == 0) {
        DDLogWarn(@"No name for avatar key : %@",key);
        return nil;
    }
    
    NSString *imageName = [[name substringToIndex:1] uppercaseString];
    UILabel *displayLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64,64)];
    displayLab.backgroundColor = color;
    displayLab.textColor = [UIColor whiteColor];
    displayLab.font = [UIFont systemFontOfSize:26.0f];
    displayLab.textAlignment = NSTextAlignmentCenter;
    displayLab.text = imageName;
    UIImage *image = [displayLab convertViewToImage];
    [[SDImageCache sharedImageCache] storeImage:image forKey:key toDisk:YES];
    return image;
}


+ (NSString *)avatarUrlWithChecksum:(NSString *)checksum
{
    if (!checksum) {
        return nil;
    }
    
    // 头像必须加上一个后缀名，才能取到文件
    NSString *path = [NSString stringWithFormat:@"photo/%@_s/1.jpg",checksum];
    return [AppSettings.apiBaseUrl stringByAppendingPathComponent:path];
}

+ (NSString *)largeAvatarUrlWithChecksum:(NSString *)checksum
{
    // 头像必须加上一个后缀名，才能取到文件
    NSString *path = [NSString stringWithFormat:@"photo/%@/1.jpg",checksum];
    return [AppSettings.apiBaseUrl stringByAppendingPathComponent:path];
}

@end
