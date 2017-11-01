//
//  UITabBarItem+Badge.h
//  Pods
//
//  Created by ricky on 15/11/2.
//
//

#import <UIKit/UIKit.h>
#import "RTDraggableBadge.h"

@interface UITabBarItem (Badge)


- (RTDraggableBadge *)rt_setBadgeValue:(NSString *)text
                            withHandle:(void(^)(RTDraggableBadge *, RTDragState))block;


- (void)rt_relayoutBadge:(BOOL)flag;

- (void)rt_relayoutBadge;

@end
