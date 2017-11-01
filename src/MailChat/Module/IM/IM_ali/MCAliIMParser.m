//
//  MCAliIMParser.m
//  NPushMail
//
//  Created by swhl on 16/12/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAliIMParser.h"
#import "MCAliBaseGroupModel.h"
#import "MCAliMsgImageModel.h"
#import "MCAliMsgVoiceModel.h"
#import "MCAliMsgFileModel.h"
#import "MCAliSysHelperModel.h"
#import "MCAliSysMailModel.h"

@implementation MCAliIMParser

+ (MCAliBaseModel *)parserAliMsgData:(NSData *)data
{
    int IMtype;
    switch (IMtype) {
        case 0:{
            //聊天消息
            int msgType;
            switch (msgType) {
                case 0:
                    //未知格式
                    break;
                case 1:
                    //文本
                    break;
                case 2:
                    //图片
                    break;
                case 3:
                    //语音
                    break;
                default:
                    break;
            }
            
        }
            break;
        case 1:
        {
            //群消息
        }
            break;
            
        case 2:
        {
            //系统消息
        }
            break;
            
            
        default:
            break;
    }
    
    return nil;
}

@end
