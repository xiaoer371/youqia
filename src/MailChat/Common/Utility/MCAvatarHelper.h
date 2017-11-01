//
//  MCAvatarHelper.h
//  NPushMail
//
//  Created by admin on 4/7/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCAvatarHelper : NSObject

+ (NSString *)randomColorHexString;

+ (UIImage *)avatarWithEmail:(NSString *)email displayName:(NSString *)name defaultColorString:(NSString *)colorStr;

+ (UIImage *)avatarWithEmail:(NSString *)email displayName:(NSString *)name defaultColor:(UIColor *)color;

+ (NSString *)avatarUrlWithChecksum:(NSString *)checksum;

+ (NSString *)largeAvatarUrlWithChecksum:(NSString *)checksum;

@end
