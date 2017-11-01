//
//  MCIMPreviewImageViewController.h
//  NPushMail
//
//  Created by swhl on 16/4/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCIMPreviewImageViewControllerDelegate <NSObject>


@end

@interface MCIMPreviewImageViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic,assign) id <MCIMPreviewImageViewControllerDelegate> delegate;



@end
