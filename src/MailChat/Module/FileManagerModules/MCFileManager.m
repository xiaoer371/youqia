//
//  MCFileManager.m
//  NPushMail
//
//  Created by wuwenyu on 15/12/29.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCFileManager.h"
#import "MCFileCore.h"
#import "MCFileBaseModel.h"
#import "SDWebImageManager.h"
#import "MCTool.h"
static NSString* const fileTopDirectory = @"PMFile";

@implementation MCFileManager

// 初始化
- (id)init {
    return [self initWithFileCore:nil];
}

- (id)initWithFileCore:(MCFileCore *) core {
    self = [super initWithFileCore:core];
    return self;
}

#pragma mark - common
//返回当前用户存放所有文件的目录（PMFile/user/....）
- (NSString *)getFileFolderPath {
    NSString* userDirectory = [self getTopDirectory];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [[[paths objectAtIndex:0] stringByAppendingPathComponent:fileTopDirectory] stringByAppendingPathComponent:userDirectory];
    [self createDirectoryWithPath:path];
    return path;
}


- (NSString *)getCachesFilePath
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileLaunch];
    [self createDirectoryWithPath:path];
    return path;
}

- (NSString *)getTopDirectory {
    NSString *result = @"";
    result = [result stringByReplacingOccurrencesOfString:@"@" withString:@"_"];
    result = [result stringByReplacingOccurrencesOfString:@" " withString:@""];
    return result;
}

- (BOOL)createDirectoryWithPath:(NSString *)path {
    BOOL result = YES;
    NSFileManager *manager = [[NSFileManager alloc]init];
    if (![manager fileExistsAtPath:path]) {
        NSError *error ;
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            result = NO;
            DDLogInfo(@"创建目录失败");
        }
    }
    return result;
}

#pragma mark - 按模块区分获取对应模块的附件目录
//获取对应文件夹的目录步骤应该是：1:调用getFileFolderPathWithFolderName:withAccount: 得到顶层目录 2:传入对应的顶层目录获取到对应的相关文件夹路径

//获取存放邮件附件的路径
- (NSString *)getMailFilePath {
    NSString* path = [[self getFileFolderPath] stringByAppendingPathComponent:mailFileDirectory];
    [self createDirectoryWithPath:path];
    return path;
}

//获取存放消息文件的路径
- (NSString *)getMsgFilePath {
    NSString* path = [[self getFileFolderPath] stringByAppendingPathComponent:msgFileDirectory];
    [self createDirectoryWithPath:path];
    return path;
}

//获取存放消息图片文件的路径
- (NSString *)getMsgImageFilePath {
    NSString* path = [[self getFileFolderPath] stringByAppendingPathComponent:msgImageFileDirectory];
    [self createDirectoryWithPath:path];
    return path;
}

//获取全部文件的路径
- (NSString *)getAllFilePath {
    NSString* path = [[self getFileFolderPath] stringByAppendingPathComponent:allFileDirectory];
    [self createDirectoryWithPath:path];
    return path;
}

//获取收藏文件的路径
- (NSString *)getCollectFilePath {
    NSString* path = [[self getFileFolderPath] stringByAppendingPathComponent:collectFileDirectory];
    [self createDirectoryWithPath:path];
    return path;
}

//获取联系人文件的路径
- (NSString *)getContactFilePath {
    NSString* path = [[self getFileFolderPath] stringByAppendingPathComponent:contactImageFileDirectory];
    [self createDirectoryWithPath:path];
    return path;
}

//获取联内嵌文件的路径
- (NSString *)getInlineAttachMentFilePath {
    NSString* path = [[self getFileFolderPath] stringByAppendingPathComponent:inlineAttachMentFileDirectory];
    [self createDirectoryWithPath:path];
    return path;
}

#pragma mark - 保存文件到对应的文件夹下

- (NSString *)saveFileWithData:(NSData *)data folder:(NSString *)folder fileName:(NSString *)fileName {
    if (data) {
        NSString *path = [self getFilePathWithFolder:folder];
        //文件重名处理
        fileName = [[self getFileCore] getFileDisplayNameWithSourceName:fileName];
        path = [path stringByAppendingPathComponent:fileName];
        NSError *error = nil;
        if (![data writeToFile:path options:NSDataWritingAtomic error:&error]) {
            DDLogError(@"错误：保存到文件失败 - %@", [error localizedDescription]);
            return nil;
        }
        return [self getFileShortPathWithFolder:folder fileName:fileName];
    }else{
        return nil;
    }
}

- (NSString *)saveOrReplaceFileWithData:(NSData *)data folder:(NSString *)folder fileName:(NSString *)fileName {
    if (data) {
        NSString *path = [self getFilePathWithFolder:folder];
        path = [path stringByAppendingPathComponent:fileName];
        NSError *error = nil;
        if (![data writeToFile:path options:NSDataWritingAtomic error:&error]) {
            DDLogError(@"错误：保存到文件失败 - %@", [error localizedDescription]);
            return nil;
        }
        NSString *shortPath = [self getFileShortPathWithFolder:folder fileName:fileName];
        return shortPath;
    }else{
        return nil;
    }
}

//保存文件到指定的路径(不区分文件夹)
- (NSString *)saveOrReplaceFileWithData:(NSData *)data shortPath:(NSString *)shortPath fileName:(NSString *)fileName {
    if (data) {
        NSString *path = [self getFileFullPathWithShortPath:shortPath];
        if (![self createDirectoryWithPath:path]) {
            return nil;
        }
        path = [path stringByAppendingPathComponent:fileName];
        NSError *error = nil;
        if (![data writeToFile:path options:NSDataWritingAtomic error:&error]) {
            DDLogError(@"错误：保存到文件失败 - %@", [error localizedDescription]);
            return nil;
        }
        return shortPath;
    }else{
        return nil;
    }
}

- (NSString *)saveInlineFileWithData:(NSData *)data fileName:(NSString *)fileName {
    if (data) {
        NSString *path = [self getFilePathWithFolder:inlineAttachMentFileDirectory];
        path = [path stringByAppendingPathComponent:fileName];
        NSFileManager *manager = [NSFileManager defaultManager];
        int i = 0;
        NSString *name = fileName;
        while ([manager fileExistsAtPath:path]) {
            i ++;
            name = [NSString stringWithFormat:@"(%d)%@",i,fileName];
            path = [self getFilePathWithFolder:inlineAttachMentFileDirectory];
            path = [path stringByAppendingPathComponent:name];
        }
        NSError *error = nil;
        if (![data writeToFile:path options:NSDataWritingAtomic error:&error]) {
            DDLogError(@"错误：保存到文件失败 - %@", [error localizedDescription]);
            return nil;
        }
        return [self getFileShortPathWithFolder:inlineAttachMentFileDirectory fileName:name];
    }else{
        return nil;
    }
}

#pragma mark - 获取对应文件夹下的文件

//获取文件夹下的文件名
- (NSArray *)getFilesWithFolder:(NSString *)folder {
    NSString *path = [self getFilePathWithFolder:folder];
    return [[self getFilesWithPath:path] objectForKey:@"files"];
}

- (NSString *)getFilePathWithFolder:(NSString *)folder fileName:(NSString *)fileName {
    NSString *path = [self getFilePathWithFolder:folder];
    fileName = [[self getFileCore] getFileDisplayNameWithSourceName:fileName];
    path = [path stringByAppendingPathComponent:fileName];
    return path;
}

- (NSData *)getFileDataWithFolder:(NSString *)folder fileName:(NSString *)fileName {
    fileName = [[self getFileCore] getFileDisplayNameWithSourceName:fileName];
    NSString *path = [self getFilePathWithFolder:folder];
    path = [path stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

- (NSData *)getFileDataWithShortPath:(NSString *)shortPath {
    NSString *path = [self getFileFullPathWithShortPath:shortPath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

- (NSString *)getFilePathWithFolder:(NSString *)folder {
    NSString* path = [self getAllFilePath];
    if ([folder isEqualToString:allFileDirectory]) {
        path = [self getAllFilePath];
    }else if ([folder isEqualToString:mailFileDirectory]) {
        path = [self getMailFilePath];
    }else if ([folder isEqualToString:msgFileDirectory]) {
        path = [self getMsgFilePath];
    }else if ([folder isEqualToString:msgImageFileDirectory]) {
        path = [self getMsgImageFilePath];
    }else if ([folder isEqualToString:collectFileDirectory]) {
        path = [self getCollectFilePath];
    }else if ([folder isEqualToString:contactImageFileDirectory]) {
        path = [self getContactFilePath];
    }else if ([folder isEqualToString:inlineAttachMentFileDirectory]) {
        path = [self getInlineAttachMentFilePath];
    }else if ([folder isEqualToString:fileLaunch]) {
        path = [self getCachesFilePath];
    }
    return path;
}

/**
 *  返回PMFile之后的文件路径给上层接口，上层接口取文件的时候只需要传入这个短路径即可。(目前只供本类使用)
 *
 *  @param folder   文件夹
 *  @param fileName 文件名
 *
 *  @return
 */
- (NSString *)getFileShortPathWithFolder:(NSString *)folder fileName:(NSString *)fileName {
    NSString *shortPath = [folder stringByAppendingPathComponent:fileName];
    return shortPath;
}
/**
 *  根据短路径获取到全路径（保存短路径是因为有时候系统重装Documents的路径会发生改变）
 *
 *  @param shortPath
 *
 *  @return
 */
- (NSString *)getFileFullPathWithShortPath:(NSString *)shortPath {
    NSString *path = [self getFileFolderPath];
    path = [path stringByAppendingPathComponent:shortPath];
    return path;
}

- (NSMutableDictionary *)getFilesWithPath:(NSString *)filePath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![fm contentsOfDirectoryAtPath:filePath error:&error]) {
        DDLogError(@"%@", [NSString stringWithFormat:@"错误：获取 %@ 下的文件名和文件夹失败 - %@", filePath, [error localizedDescription]]);
        return nil;
    }
    /**
     * 获取包含有该文件夹下所有文件的文件名及文件夹名的数组(不再获取后代路径)
     */
    NSArray *arr = [fm contentsOfDirectoryAtPath:filePath error:nil];
    NSMutableArray *dirArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:0];
    BOOL isDir = NO;
    /**
     *  筛选出文件和子文件夹
     */
    for (NSString *file in arr) {
        NSString *path = [filePath stringByAppendingPathComponent:file];
        [fm fileExistsAtPath:path isDirectory:(&isDir)];
        if (isDir) {
            [dirArray addObject:file];
        }else {
            [files addObject:file];
        }
        isDir = NO;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:files forKey:@"files"];
    [dic setObject:dirArray forKey:@"dirs"];
    return dic;
}

#pragma mark - 移动文件

- (BOOL)moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&error];
    if (success) {
        return YES;
    }else{
        DDLogError(@"文件移动失败 = %@",error);
        return NO;
    }
    return YES;
}

- (BOOL)deleteFileWithPath:(NSString *)path {
    NSError *error = nil;
    BOOL flag = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (flag) {
        return YES;
    }else{
        DDLogError(@"文件删除失败 = %@",error);
        return NO;
    }
    return YES;
}

#pragma mark - Voice Data

+ (NSString *)saveVoiceData:(NSData *)voiceData withName:(NSString *)voiceName
{
    NSString *documentDir = AppStatus.documentDir;
    NSString *voiceFolder = [documentDir stringByAppendingPathComponent:@"voice"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:voiceFolder]) {
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:voiceFolder withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success) {
            DDLogError(@"Create folder dir error = %@",error);
        }
    }
    
    NSString *voicePath = [voiceFolder stringByAppendingPathComponent:voiceName];
    [voiceData writeToFile:voicePath atomically:YES];
    
    return voicePath;
}

+ (NSString *)voiceFullPathWithName:(NSString *)voiceName
{
    NSString *shortPath = [NSString stringWithFormat:@"voice/%@",voiceName];
    return [AppStatus.documentDir stringByAppendingPathComponent:shortPath];
}

//判断文件是否存在
- (BOOL)fileIsExistsAtPath:(NSString*)shotPath {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *filePath = [self getFileFullPathWithShortPath:shotPath];
    return [manager fileExistsAtPath:filePath];
}
//TODO: clear fils Cache
/**
 *  缓存文件大小
 */
- (NSString*)getAllCacheFilsSize {
    
    SDImageCache* imageCache = [[SDWebImageManager sharedManager] imageCache];
    long fileSize = 0;
    //获取SD的缓存
    fileSize += [imageCache getSize];
    //获取内嵌图片的缓存
    NSString *folderPath = [self getInlineAttachMentFilePath];
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath])
        return [[MCTool shared] getFileSizeWithLength:fileSize];
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        if ([manager fileExistsAtPath:fileAbsolutePath]){
            fileSize += [[manager attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];
        }
    }
    return [[MCTool shared] getFileSizeWithLength:fileSize];;
}

/**
 *  清除缓存文件
 */

- (void)clearCacheFiles{
    
    SDImageCache *imageCache = [[SDWebImageManager sharedManager] imageCache];
    [imageCache cleanDisk];
    [imageCache clearDisk];
    NSString *folderPath = [self getInlineAttachMentFilePath];
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) {
        return;
    }
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    NSError *error;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        if ([manager fileExistsAtPath:fileAbsolutePath]){
            [manager removeItemAtPath:fileAbsolutePath error:&error];
            if (error) {
                DDLogError(@"清除缓存--%@",error);
            }
        }
    }
    
}
@end
