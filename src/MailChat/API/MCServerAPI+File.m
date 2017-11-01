//
//  MCServerAPI+File.m
//  NPushMail
//
//  Created by admin on 4/25/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCServerAPI+File.h"
#import "MCFileCore.h"
#import "MCFileManager.h"
#import "MCJsFileConfig.h"

@implementation MCServerAPI (File)

- (void)uploadImage:(NSData *)imageData name:(NSString *)name success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    
    [self.manager POST:@"/chat/upload" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:name mimeType:@"image/jpeg"];
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"upload file response = %@",responseObject);
        BOOL result = [responseObject[@"result"] boolValue];
        if (result) {
            if (success) {
                NSString *checksum = responseObject[@"checksum"];
                NSString *url = responseObject[@"url"];
                success(@{@"checksum" : checksum,
                          @"url" : url
                          });
            }
        }
        else{
            NSError *error = [self errorWithResponse:responseObject];
            if (failure) {
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"upload image error = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)uploadFileWithUrl:(NSURL *)url name:(NSString *)fileName success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    
    [self.manager POST:@"/chat/upload" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSError *error = nil;
        [formData appendPartWithFileURL:url name:@"file" fileName:fileName mimeType:@"application/octet-stream" error:&error];
        if (error) {
            DDLogError(@"Upload file error = %@",error);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"upload file response = %@",responseObject);
        BOOL result = [responseObject[@"result"] boolValue];
        if (result) {
            if (success) {
                NSString *checksum = responseObject[@"checksum"];
                NSString *url = responseObject[@"url"];
                success(@{@"checksum" : checksum,
                          @"url" : url
                          });
            }
        }
        else{
            NSError *error = [self errorWithResponse:responseObject];
            if (failure) {
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"upload file error = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

-(NSURLSessionDownloadTask *)downLoadFileWithFileModel:(MCIMFileModel *)fileModel progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSURL *URL = [NSURL URLWithString:fileModel.path];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            DDLogError(@"Download file error = %@",error);
            failure(error);
        }else{
            success(filePath);
        }
    }];
    
    [self.manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        progress((float)totalBytesWritten,(float)totalBytesExpectedToWrite);
    }];
    
    [downloadTask resume];
    return downloadTask;
}

- (void)checkUpdateJsFileParameters:(NSDictionary *)parameters success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *path = @"app/ihotfix";
    
    [self.manager POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject) {
            DDLogVerbose(@"responseObject: %@", responseObject);
            if ([[responseObject objectForKey:@"result"] intValue] == 1) {
                NSDictionary *configDic = [responseObject objectForKey:@"data"];
                MCJsFileConfig *jsConfig = [[MCJsFileConfig alloc] initWithDictionary:configDic];
                if (success) {
                    success(jsConfig);
                }else {
                    failure(nil);
                }
            }else {
                if (success) {
                    MCJsFileConfig *jsConfig = [MCJsFileConfig new];
                    jsConfig.needUpdate = NO;
                    jsConfig.needRollBack = NO;
                    success(jsConfig);
                }
            }
        }else {
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
    
}

- (NSURLSessionDownloadTask *)downLoadFileWithUrl:(NSURL *)url
                                          success:(SuccessBlock)success
                                          failure:(FailureBlock)failure {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            DDLogError(@"Download file error = %@",error);
            failure(error);
        }else{
            success(filePath);
        }
    }];
    [downloadTask resume];
    return downloadTask;
}


@end
