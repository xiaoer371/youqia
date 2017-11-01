/*
 
 ------------------------------------------------------------------------------------
 CustomBadge.m
 ------------------------------------------------------------------------------------
 CustomBadge is an UIView which draws a customizable badge on any other view.
 The latest version has separation between style and rendering.
 This class is the core of CustomBadge where the actual rendering happens.
 It recommended to use the convenient allocators instead of the init methods.
 ------------------------------------------------------------------------------------
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Sascha Paulus
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */


#import "CustomBadge.h"


@interface CustomBadge()

@property(nonatomic) UIFont *badgeFont;

- (void) drawRoundedRectWithContext:(CGContextRef)context withRect:(CGRect)rect;
- (void) drawFrameWithContext:(CGContextRef)context withRect:(CGRect)rect;

@end

@implementation CustomBadge

@synthesize badgeText;
@synthesize badgeCornerRoundness;
@synthesize badgeScaleFactor;
@synthesize badgeStyle;

// I recommend to use one of the allocators like customBadgeWithString
- (id) initWithString:(NSString *)badgeString withScale:(CGFloat)scale withStyle:(BadgeStyle*)style
{
	self = [super initWithFrame:CGRectMake(0, 0, 19, 19)];
	if(self!=nil) {
		self.contentScaleFactor = [[UIScreen mainScreen] scale];
		self.backgroundColor = [UIColor clearColor];
		badgeText = badgeString;
        self.badgeStyle = style;
		self.badgeCornerRoundness = 0.4;
		self.badgeScaleFactor = scale;
        self.userInteractionEnabled = NO;
        [self autoBadgeSizeWithString:badgeString];
	}
	return self;
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    self.contentScaleFactor = [[UIScreen mainScreen] scale];
    self.backgroundColor = [UIColor clearColor];
    badgeText = @"0";
    self.badgeStyle = [BadgeStyle defaultStyle];
    self.badgeCornerRoundness = 0.4;
    self.badgeScaleFactor = 1;
    self.userInteractionEnabled = NO;
    [self autoBadgeSizeWithString:@"0"];
}


- (void)setBadgeText:(NSString *)te
{
    badgeText = te;
    if ([te intValue] == 0) {
        self.hidden = YES;
    }else
    {
        self.hidden = NO;
    }
}
// Use this method if you want to change the badge text after the first rendering
- (void) autoBadgeSizeWithString:(NSString *)badgeString
{
	CGSize retValue;
	CGFloat rectWidth, rectHeight;
	CGFloat flexSpace;
	if ([badgeString length]>=2) {
		flexSpace = [badgeString length];
		rectWidth  = 24 + 4*flexSpace /*(stringSize.width + flexSpace)*/;
        rectHeight = 24;
		retValue = CGSizeMake(rectWidth*badgeScaleFactor, rectHeight*badgeScaleFactor);
	} else {
		retValue = CGSizeMake(24*badgeScaleFactor, 24*badgeScaleFactor);
	}
    CGRect oldFrame   = self.frame;
    oldFrame.origin.x =self.frame.origin.x -( retValue.width -self.frame.size.width);
	self.frame = CGRectMake(oldFrame.origin.x, self.frame.origin.y, retValue.width, retValue.height);
	self.badgeText = badgeString;
	[self setNeedsDisplay];
}


// Creates a Badge with a given Text in default BadgeStyle and normal scale
+ (CustomBadge*) customBadgeWithString:(NSString *)badgeString
{
    return [[self alloc] initWithString:badgeString withScale:1.0 withStyle:[BadgeStyle defaultStyle]];
}

// Creates a Badge with a given Text in default BadgeStyle and given scale
+ (CustomBadge*) customBadgeWithString:(NSString *)badgeString withScale:(CGFloat)scale {
    
    return [[self alloc] initWithString:badgeString withScale:scale withStyle:[BadgeStyle defaultStyle]];
    
}

// Creates a Badge with a given Text in given BadgeStyle and normal scale
+ (CustomBadge*) customBadgeWithString:(NSString *)badgeString withStyle:(BadgeStyle*)style
{
    return [[self alloc] initWithString:badgeString withScale:1.0 withStyle:style];
}


// Creates a Badge with a given Text in given BadgeStyle and a given scale
+ (CustomBadge*) customBadgeWithString:(NSString *)badgeString withScale:(CGFloat)scale withStyle:(BadgeStyle*)style {

    return [[self alloc] initWithString:badgeString withScale:scale withStyle:style];
    
}
 

// Draws the Badge with Quartz
-(void) drawRoundedRectWithContext:(CGContextRef)context withRect:(CGRect)rect
{
	CGContextSaveGState(context);
	
	CGFloat radius = CGRectGetMaxY(rect)*self.badgeCornerRoundness;
	CGFloat puffer = CGRectGetMaxY(rect)*0.10;
	CGFloat maxX = CGRectGetMaxX(rect) - puffer;
	CGFloat maxY = CGRectGetMaxY(rect) - puffer;
	CGFloat minX = CGRectGetMinX(rect) + puffer;
	CGFloat minY = CGRectGetMinY(rect) + puffer;
		
    CGContextBeginPath(context);
	CGContextSetFillColorWithColor(context, [self.badgeStyle.badgeInsetColor CGColor]);
	CGContextAddArc(context, maxX-radius, minY+radius, radius, M_PI+(M_PI/2), 0, 0);
	CGContextAddArc(context, maxX-radius, maxY-radius, radius, 0, M_PI/2, 0);
	CGContextAddArc(context, minX+radius, maxY-radius, radius, M_PI/2, M_PI, 0);
	CGContextAddArc(context, minX+radius, minY+radius, radius, M_PI, M_PI+M_PI/2, 0);
    if (self.badgeStyle.badgeShadow) {
        CGContextSetShadowWithColor(context, CGSizeMake(1.0,1.0), 3, [[UIColor blackColor] CGColor]);
    }
	CGContextFillPath(context);

	CGContextRestoreGState(context);

}

// Draws the Badge Shine with Quartz
-(void) drawShineWithContext:(CGContextRef)context withRect:(CGRect)rect
{
	CGContextSaveGState(context);
 
	CGFloat radius = CGRectGetMaxY(rect)*self.badgeCornerRoundness;
	CGFloat puffer = CGRectGetMaxY(rect)*0.10;
	CGFloat maxX = CGRectGetMaxX(rect) - puffer;
	CGFloat maxY = CGRectGetMaxY(rect) - puffer;
	CGFloat minX = CGRectGetMinX(rect) + puffer;
	CGFloat minY = CGRectGetMinY(rect) + puffer;
	CGContextBeginPath(context);
	CGContextAddArc(context, maxX-radius, minY+radius, radius, M_PI+(M_PI/2), 0, 0);
	CGContextAddArc(context, maxX-radius, maxY-radius, radius, 0, M_PI/2, 0);
	CGContextAddArc(context, minX+radius, maxY-radius, radius, M_PI/2, M_PI, 0);
	CGContextAddArc(context, minX+radius, minY+radius, radius, M_PI, M_PI+M_PI/2, 0);
	CGContextClip(context);
	
	
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 0.4 };
	CGFloat components[8] = {  0.92, 0.92, 0.92, 1.0, 0.82, 0.82, 0.82, 0.4 };

	CGColorSpaceRef cspace;
	CGGradientRef gradient;
	cspace = CGColorSpaceCreateDeviceRGB();
	gradient = CGGradientCreateWithColorComponents (cspace, components, locations, num_locations);
	
	CGPoint sPoint, ePoint;
	sPoint.x = 0;
	sPoint.y = 0;
	ePoint.x = 0;
	ePoint.y = maxY;
	CGContextDrawLinearGradient (context, gradient, sPoint, ePoint, 0);
	
	CGColorSpaceRelease(cspace);
	CGGradientRelease(gradient);
	
	CGContextRestoreGState(context);	
}


// Draws the Badge Frame with Quartz
-(void) drawFrameWithContext:(CGContextRef)context withRect:(CGRect)rect
{
	CGFloat radius = CGRectGetMaxY(rect)*self.badgeCornerRoundness;
	CGFloat puffer = CGRectGetMaxY(rect)*0.10;
	
	CGFloat maxX = CGRectGetMaxX(rect) - puffer;
	CGFloat maxY = CGRectGetMaxY(rect) - puffer;
	CGFloat minX = CGRectGetMinX(rect) + puffer;
	CGFloat minY = CGRectGetMinY(rect) + puffer;
	
	
    CGContextBeginPath(context);
	CGFloat lineSize = 2;
	if(self.badgeScaleFactor>1) {
		lineSize += self.badgeScaleFactor*0.25;
	}
	CGContextSetLineWidth(context, lineSize);
	CGContextSetStrokeColorWithColor(context, [self.badgeStyle.badgeFrameColor CGColor]);
	CGContextAddArc(context, maxX-radius, minY+radius, radius, M_PI+(M_PI/2), 0, 0);
	CGContextAddArc(context, maxX-radius, maxY-radius, radius, 0, M_PI/2, 0);
	CGContextAddArc(context, minX+radius, maxY-radius, radius, M_PI/2, M_PI, 0);
	CGContextAddArc(context, minX+radius, minY+radius, radius, M_PI, M_PI+M_PI/2, 0);
	CGContextClosePath(context);
	CGContextStrokePath(context);
}


- (UIFont*) fontForBadgeWithSize:(CGFloat)size {
    switch (self.badgeStyle.badgeFontType) {
        case BadgeStyleFontTypeHelveticaNeueMedium:
            return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
            break;
        default:
            return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
            break;
    }
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	[self drawRoundedRectWithContext:context withRect:rect];
	
	if(self.badgeStyle.badgeShining) {
		[self drawShineWithContext:context withRect:rect];
	}
	
	if (self.badgeStyle.badgeFrame)  {
		[self drawFrameWithContext:context withRect:rect];
	}
	
	if ([self.badgeText length]>0) {
		CGFloat sizeOfFont = 12*badgeScaleFactor;
		if ([self.badgeText length]<2) {
            sizeOfFont += sizeOfFont * 0.20f;
		}
        UIFont *textFont = [UIFont systemFontOfSize:15];//[self fontForBadgeWithSize:sizeOfFont];
        NSDictionary *fontAttr = @{ NSFontAttributeName : textFont, NSForegroundColorAttributeName : self.badgeStyle.badgeTextColor };
		CGSize textSize = [self.badgeText sizeWithAttributes:fontAttr];
        CGPoint textPoint = CGPointMake((rect.size.width/2-textSize.width/2), (rect.size.height/2-textSize.height/2) - 0.5 );
		[self.badgeText drawAtPoint:textPoint withAttributes:fontAttr];
	}
}




@end
