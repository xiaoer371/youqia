//
//  MD5Additions.h
//  NPushMail
//
//  Created by wuwenyu on 16/10/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(MD5Addition)
-(NSString*) md5;
@end

@interface NSData(MD5Addition)
-(NSString*) md5;
@end
