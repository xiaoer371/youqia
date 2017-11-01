//
//  UIButton+Badge.m
//  Pods
//
//  Created by ricky on 15/11/2.
//
//

#import "UIView+Badge.h"
#import "UIView+MCExpand.h"
#import "FBKVOController.h"
@implementation UIView (Badge)

- (RTDraggableBadge *)rt_setBadge:(NSString *)text
                       withHandle:(void (^)(RTDraggableBadge *badge, RTDragState))block
{
    [self removeKvo];
    RTDraggableBadge *badge = (RTDraggableBadge *)[self viewWithTag:9333];
    if (!badge) {
        badge = [RTDraggableBadge badgeWithDragHandle:block];
        badge.text = text;
        CGRect rect = badge.frame;
        CGFloat x = CGRectGetMidX(self.bounds);
        rect.origin.x = x+8;
        rect.origin.y = 2;
        badge.frame = rect;
        badge.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        badge.tag = 9333;
        [self addSubview:badge];
    }
    else {
        badge.text = text;
        badge.dragStateHandle = block;
    }
    [self registerKvo];
    return badge;
}

- (void)registerKvo {
    
     __weak typeof(self)weak = self;
    [self.KVOController observe:self keyPath:@"frame" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        RTDraggableBadge *badge = (RTDraggableBadge *)[weak viewWithTag:9333];
        if (badge) {
            CGRect rect = badge.frame;
            CGFloat x = CGRectGetMidX(weak.bounds);
            rect.origin.x = x+8;
            rect.origin.y = 2;
            badge.frame = rect;
            badge.mc_height = 20;
        }
    }];
}

- (void)removeKvo {
    [self.KVOController unobserveAll];
}
@end
