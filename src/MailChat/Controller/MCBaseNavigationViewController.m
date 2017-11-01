//
//  MCBaseNavigationViewController.m
//  NPushMail
//
//  Created by zhang on 16/1/20.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseNavigationViewController.h"
@interface MCBaseNavigationViewController ()<UINavigationControllerDelegate>
//@property (nonatomic,assign)BOOL isPushing;
@end

@implementation MCBaseNavigationViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    
    self = [super initWithRootViewController:rootViewController];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
//    self.isPushing = NO;
    // Do any additional setup after loading the view.
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    if (self.isPushing) {
//        return;
//    }
//    self.isPushing = YES;
    if (self.viewControllers.count > 0) {
        ///第二层viewcontroller 隐藏tabbar
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}


//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    self.isPushing = NO;
//}
@end
