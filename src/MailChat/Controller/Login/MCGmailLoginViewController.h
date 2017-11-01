//
//  MCGmailLoginViewController.h
//  NPushMail
//
//  Created by swhl on 16/10/8.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCLoginAuthViewController.h"

@interface MCGmailLoginViewController : MCLoginAuthViewController

@property (nonatomic, strong) NSString *email;

@end

@interface ShapeLoadingView : UIView
{
    UIImageView *_shapView;
    UIImageView *_shadowView;
    
    float _toValue;
    float _fromValue;
    float _scaletoValue;
    float _scalefromValue;
    
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;

-(void) step;
-(void) startAnimating;
-(void) stopAnimating;
@end
