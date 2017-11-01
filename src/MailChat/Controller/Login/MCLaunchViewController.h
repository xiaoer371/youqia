//
//  MCLaunchViewController.h
//  NPushMail
//
//  Created by swhl on 16/12/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
//启动页加载的View

typedef enum : NSUInteger {
    LaunchViewTypeDefault = 0, // image
    LaunchViewTypeGif,
    LaunchViewTypeVideo,
} LaunchViewType;

@class MCLaunchViewController;
@protocol MCLaunchViewControllerDelegate <NSObject>

- (void)jumpLaunchView:(MCLaunchViewController*)launchVC;

@end

@class MCLaunchModel;

@interface  MCLaunchViewController: UIViewController

@property (nonatomic,weak) id<MCLaunchViewControllerDelegate> delegate;

- (instancetype)initWithLaunchModel:(MCLaunchModel *)model;

@end
