//
//  MCIMNoMessageView.h
//  NPushMail
//
//  Created by swhl on 16/7/14.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

enum MCNODateSourceAlertType {
    MCNODateSourceAlertNoMessage = 0,
    MCNODateSourceAlertNoEmail ,
    MCNODateSourceAlertNoFile ,
    MCNODateSourceAlertNoContact ,
    MCNODateSourceAlertCustom
};

@protocol MCIMNoMessageViewDelegate <NSObject>

@optional
- (void)didSelectImageView;

@end


@interface MCIMNoMessageView : UIView

@property (nonatomic, weak) id<MCIMNoMessageViewDelegate> delegate;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *imageView;

- (instancetype)initWithCreatType:(enum MCNODateSourceAlertType)type;

- (instancetype)initWithCreatType:(enum MCNODateSourceAlertType)type
                        imageName:(NSString *)imageName
                             text:(NSString *)text;


@end
