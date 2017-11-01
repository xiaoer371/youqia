//
//  MCMailBoxIconStyle.h
//  NPushMail
//
//  Created by zhang on 16/2/17.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCMailBoxIconStyle : NSObject
//收件箱icon
@property (nonatomic,strong)UIImage *inboxIcon;
//待发送icon
@property (nonatomic,strong)UIImage *pendingBoxIcon;
//已发送icon
@property (nonatomic,strong)UIImage *sentBoxIcon;
//收藏夹icon
@property (nonatomic,strong)UIImage *starBoxIcon;
//草稿箱icon
@property (nonatomic,strong)UIImage *draftsBoxIcon;
//已删除icon
@property (nonatomic,strong)UIImage *trashBoxIcon;
//垃圾箱icon
@property (nonatomic,strong)UIImage *spamBoxIcon;
//其他icon
@property (nonatomic,strong)UIImage *otherBoxIcon;
//背景
@property (nonatomic,strong)UIImage *backgroundImage;

@end
