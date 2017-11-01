//
//  MCAddFileManager.h
//  NPushMail
//
//  Created by zhang on 16/3/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailAttachment.h"
typedef  NS_ENUM(NSInteger,MCAddFileSourceType){
    MCAddFileSourceTypePhotoLibrary = 0,
    MCAddFileSourceTypeCamera,
    MCAddFileSourceTypeFileLibrary
};

@class MCAddFileManager;

@protocol MCAddFileManagerDelegate <NSObject>

/**
 *  MCAddFileManagerDelegate
 *
 *  @param mcAddFileManager MCAddFileManager
 *  @param files            MCMailAttachment
 */
- (void)manager:(MCAddFileManager*)mcAddFileManager didAddFiles:(NSArray*)files finish:(BOOL)finish;

@end


@interface MCAddFileManager : NSObject

@property (nonatomic,assign)MCAddFileSourceType addFileSource;
@property (nonatomic,assign)NSInteger mcAddFilesManagerImageCount;//default 6
- (id)initManagerWithDelegate:(id)delegate;

- (void)sourceShow;

@end
