//
//  MCMsgOAModel.h
//  NPushMail
//
//  Created by swhl on 16/1/25.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMPeerModelProtocol.h"

@interface MCIMAppModel : NSObject<MCIMPeerModelProtocol>

@property (nonatomic,copy) NSString *appId;
@property (nonatomic,strong) NSString *peerName;
@property (nonatomic,strong) NSString *avatarUrl;
@property (nonatomic,strong) UIImage *avatarPlaceHolder;

@end
