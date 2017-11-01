//
//  MCIMVoiceModel.h
//  NPushMail
//
//  Created by swhl on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMMessageModel.h"

@interface MCIMVoiceModel : MCIMMessageModel

@property (nonatomic,strong) NSData *data;

@property (nonatomic,strong) NSData *sendData;

@property (nonatomic,assign) float seconds;

/**
 *  语音文件路径
 */
@property (nonatomic,copy) NSString *localPath;

@end
