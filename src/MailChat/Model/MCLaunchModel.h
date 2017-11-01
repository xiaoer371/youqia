//
//  MCLaunchModel.h
//  NPushMail
//
//  Created by swhl on 17/2/14.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCLaunchModel : NSObject

@property (nonatomic, strong) NSString  *version;
@property (nonatomic, strong) NSArray   *resources;   //跳转的url 资源
@property (nonatomic, strong) NSArray   *enter;       //按钮(多图时, ["文字", "位置bottom,middle,top", "背景图URL或资源"]
@property (nonatomic, strong) NSString  *title;
@property (nonatomic, assign) BOOL  enable;
// 显示跳过按钮
@property (nonatomic, assign) BOOL  skip;
@property (nonatomic, assign) CGFloat  end;
@property (nonatomic, assign) CGFloat  start;
//显示时间
@property (nonatomic, assign) CGFloat  delay;
//模式类型
@property (nonatomic, assign) CGFloat  model;
//控制是否下载成功
@property (nonatomic, assign) BOOL isDownLoad;

- (instancetype)initWithDictionary:(id)dict;
- (NSDictionary *)toJson;

@end
