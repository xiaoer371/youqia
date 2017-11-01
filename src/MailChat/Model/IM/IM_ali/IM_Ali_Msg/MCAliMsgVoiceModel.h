//
//  MCAliMsgVoiceModel.h
//  NPushMail
//
//  Created by swhl on 16/12/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAliMsgBaseModel.h"

@interface MCAliMsgVoiceModel : MCAliMsgBaseModel

@property (nonatomic, assign) CGFloat  size;
@property (nonatomic, assign) CGFloat  voiceTime;
@property (nonatomic, strong) NSData   *data;

@end
