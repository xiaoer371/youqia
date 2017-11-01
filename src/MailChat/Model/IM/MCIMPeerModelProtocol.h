//
//  MCIMPeerModel.h
//  NPushMail
//
//  Created by admin on 3/18/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MCIMPeerModelProtocol <NSObject>

@property (nonatomic,readonly) NSString *peerName;
@property (nonatomic,readonly) NSString *avatarUrl;
@property (nonatomic,readonly) UIImage *avatarPlaceHolder;

@end
