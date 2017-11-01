//
//  MCLoginAuthViewController.h
//  NPushMail
//
//  Created by admin on 02/11/2016.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"

@protocol MCLoginAuthViewControllerDelegate <NSObject>

- (void)authViewController:(UIViewController *)vc didAuthWithAccount:(MCAccount *)account;
- (void)authViewController:(UIViewController *)vc didFailedWithError:(NSError *)error;

@end


@interface MCLoginAuthViewController : MCBaseSubViewController


@property (nonatomic,weak) id<MCLoginAuthViewControllerDelegate> delegate;

@end
