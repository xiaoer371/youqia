//
//  UITabBarItem+Badge.m
//  Pods
//
//  Created by ricky on 15/11/2.
//
//

#import "UITabBarItem+Badge.h"
#import "UIView+Badge.h"
#import "UIView+MCExpand.h"

@implementation UITabBarItem (Badge)


- (RTDraggableBadge *)rt_setBadgeValue:(NSString *)text
                            withHandle:(void (^)(RTDraggableBadge *, RTDragState))block
{
    UIView *view = [self valueForKeyPath:[NSString stringWithFormat:@"%@i%@", @"_v", @"ew"]];
    return [view rt_setBadge:text
                  withHandle:block];
}

- (void)rt_relayoutBadge:(BOOL)flag
{
    UIView *view = [self valueForKeyPath:[NSString stringWithFormat:@"%@i%@", @"_v", @"ew"]];
    RTDraggableBadge *badge = (RTDraggableBadge *)[view viewWithTag:9333];
    if (!badge) {
        return;
    }
    CGRect rect = badge.frame;
    CGFloat x = CGRectGetMidX(view.bounds);
    rect.origin.x = EGOVersion_iOS10?(flag?x+16:x):(x+8);
    rect.origin.y = 2;
    badge.frame = rect;
    badge.mc_height = 20;
}

- (void)rt_relayoutBadge
{
    UIView *view = [self valueForKeyPath:[NSString stringWithFormat:@"%@i%@", @"_v", @"ew"]];
    RTDraggableBadge *badge = (RTDraggableBadge *)[view viewWithTag:9333];
    badge.text = @"";
    [badge removeFromSuperview];
    badge = nil;
}

@end
