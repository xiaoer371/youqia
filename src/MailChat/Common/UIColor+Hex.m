//
//  UIColor+Hex.m
//  NPushMail
//
//  Created by admin on 1/27/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
        return [UIColor grayColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]
        || [cString hasPrefix:@"0x"])
        cString = [cString substringFromIndex:2];
    if ([cString length] != 6)
        return [UIColor grayColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}

+ (UIColor *) colorWithHexString: (NSString *) hexString {
    return [self colorWithHexString:hexString alpha:1.0];
}

+ (UIColor *)colorWithHexValue:(NSInteger)hexValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0
                           alpha:1.0];
}

- (NSUInteger)hexValue
{
    CGFloat red, green, blue;
    if ([self getRed:&red green:&green blue:&blue alpha:NULL])
    {
        NSUInteger redInt = (NSUInteger)(red * 255 + 0.5);
        NSUInteger greenInt = (NSUInteger)(green * 255 + 0.5);
        NSUInteger blueInt = (NSUInteger)(blue * 255 + 0.5);
        
        return (redInt << 16) | (greenInt << 8) | blueInt;
    }
    
    return 0;
}

- (NSString *)hexString
{
    CGFloat red, green, blue;
    if ([self getRed:&red green:&green blue:&blue alpha:NULL])
    {
        NSInteger redInt = (NSUInteger)(red * 255 + 0.5);
        NSInteger greenInt = (NSUInteger)(green * 255 + 0.5);
        NSInteger blueInt = (NSUInteger)(blue * 255 + 0.5);
        
        return [NSString stringWithFormat:@"0x%02lx%02lx%02lx", (long)redInt,(long)greenInt,(long)blueInt];
    }
    
    return nil;
    
}

@end
