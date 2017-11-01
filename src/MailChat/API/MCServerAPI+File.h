//
//  MCServerAPI+File.h
//  NPushMail
//
//  Created by admin on 4/25/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCServerAPI.h"
#import "MCIMFileModel.h"

@interface MCServerAPI (File)

- (void)uploadImage:(NSData *)imageData name:(NSString *)name success:(SuccessBlock)success failure:(FailureBlock)failure;

- (void)uploadFileWithUrl:(NSURL *)url name:(NSString *)fileName success:(SuccessBlock)success failure:(FailureBlock)failure;

-(NSURLSessionDownloadTask *)downLoadFileWithFileModel:(MCIMFileModel *)fileModel
                        progress:(ProgressBlock)progress
                         success:(SuccessBlock)success
                         failure:(FailureBlock)failure;
- (void)checkUpdateJsFileParameters:(NSDictionary *)parameters
                            success:(SuccessBlock)success
                            failure:(FailureBlock)failure;
- (NSURLSessionDownloadTask *)downLoadFileWithUrl:(NSURL *)url
                                          success:(SuccessBlock)success
                                          failure:(FailureBlock)failure;
@end
