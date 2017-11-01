//
//  UIColor+Hex.h
//  NPushMail
//
//  Created by admin on 1/27/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (Hex)
+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor *)colorWithHexValue:(NSInteger)hexValue;

- (NSUInteger)hexValue;
- (NSString *)hexString;

@end
