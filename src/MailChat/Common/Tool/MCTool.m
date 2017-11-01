//
//  MCTool.m
//  NPushMail
//
//  Created by wuwenyu on 16/2/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCTool.h"
#import "MCFileCore.h"
#import "MCFileManager.h"
#import "UIView+Image.h"
#import "NSString+Extension.h"

@implementation MCTool

+ (instancetype)shared {
    static id instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [MCTool new];
    });
    return instance;
}

- (UIImage *)fileImageIconWithFileName:(NSString *)fileName {
    if ([fileName hasExtension:@"doc"]|[fileName hasExtension:@"docx"])
        return [UIImage imageNamed:@"doc_file.png"];
    else if ([fileName hasExtension:@"txt"])
        return [UIImage imageNamed:@"txt_file.png"];
    else if ([fileName hasExtension:@"xls"]|[fileName hasExtension:@"xlsx"])
        return [UIImage imageNamed:@"xls_file.png"];
    else if ([fileName hasExtension:@"pdf"])
        return [UIImage imageNamed:@"pdf_file.png"];
    else if ([fileName hasExtension:@"html"])
        return [UIImage imageNamed:@"html_file.png"];
    else if ([fileName hasExtension:@"zip"]|[fileName hasExtension:@"rar"])
        return [UIImage imageNamed:@"rar_file.png"];
    else if ([fileName hasExtension:@"apk"])
        return [UIImage imageNamed:@"apk_file.png"];
    else if ([fileName hasExtension:@"eml"])
        return [UIImage imageNamed:@"eml_file.png"];
    else if ([fileName.lowercaseString hasExtension:@"jpg"]|[fileName.lowercaseString hasExtension:@"png"])
        return [UIImage imageNamed:@"pic_file.png"];
    else if ([fileName hasExtension:@"ppt"])
        return [UIImage imageNamed:@"ppt_file.png"];
    else if ([fileName hasExtension:@"pptx"])
        return [UIImage imageNamed:@"ppt_file.png"];
    else if ([fileName hasExtension:@"psd"])
        return [UIImage imageNamed:@"psd_file.png"];
    else if ([fileName hasExtension:@"MOV"]||[fileName hasExtension:@"mp3"] )
        return [UIImage imageNamed:@"video_file.png"];
    else if ([fileName hasExtension:@"ai"])
        return [UIImage imageNamed:@"ai_file.png"];
    else if ([fileName hasExtension:@"swf"])
        return [UIImage imageNamed:@"swf_file.png"];
    return [UIImage imageNamed:@"unknown_file.png"];
}

- (NSString *)getFileSizeWithLength:(long)length {
    NSString* mcSizeString;
    if (0 <= length &&length < 1024) {
        return [NSString stringWithFormat:@"%ldB",length];
    }
    float size = length/1024;
    if (size < 100) {
        mcSizeString = [NSString stringWithFormat:@"%.2fK",size];
        return mcSizeString;
    }
    size = size/1024;
    if (size < 100) {
        mcSizeString = [NSString stringWithFormat:@"%.2fM",size];
        return mcSizeString;
    }
    size = size < 1024;
    mcSizeString = [NSString stringWithFormat:@"%.2fG",size];
    return mcSizeString;
}

- (NSDate *)getDateFromTimeMills:(int64_t)timeMills {
    return [[NSDate alloc] initWithTimeIntervalSince1970:(timeMills / 1000)];
}

- (NSDate*)getDateFromTimeSeconds:(int64_t)seconds {
    return [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
}

- (NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}

- (void) registerRemoteNoticationsWithAppDelegate:(id<UNUserNotificationCenterDelegate>)appDelegate {
#if !TARGET_IPHONE_SIMULATOR
    if (EGOVersion_iOS10) {
        [self registIOS10NotificationWithAppDelegate:appDelegate];
    } else {
        [self registNotification];
    }
#endif
}

- (NSString *)replaceDominWith35cn:(NSString *)email {
    NSString *domin = [email mailDomain];
    if (domin) {
        if ([domin isEqualToString:@"china-channel.com"]) {
           email = [email stringByReplacingOccurrencesOfString:domin withString:@"35.cn"];
        }
    }
    return email;
}

//cofigNotificationAction
//ios8 ios9
- (void)registNotification {
    UIMutableUserNotificationAction *deleteAction = [[UIMutableUserNotificationAction alloc]init];
    deleteAction.identifier = kMCNotificationDeleteActionIdentity;
    deleteAction.title = @"删除";
    deleteAction.activationMode = UIUserNotificationActivationModeBackground;
    deleteAction.destructive = YES;
    
    
    UIMutableUserNotificationAction *readAction = [[UIMutableUserNotificationAction alloc]init];
    readAction.identifier = kMCNotificationReadActionIdentity;
    readAction.title = @"标记已读";
    readAction.activationMode = UIUserNotificationActivationModeBackground;
    
    UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc]init];
    category.identifier = kMCNotificationCategoryIdentity;
    [category setActions:@[readAction,deleteAction] forContext:(UIUserNotificationActionContextMinimal)];
    
    UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:[NSSet setWithObjects:category, nil]];
    UIApplication *application = [UIApplication sharedApplication];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
}
//ios10
- (void)registIOS10NotificationWithAppDelegate:(id<UNUserNotificationCenterDelegate>)appDelegate {
    UNNotificationAction *deleteAction = [UNNotificationAction actionWithIdentifier:kMCNotificationDeleteActionIdentity title:@"删除" options:UNNotificationActionOptionDestructive];
    UNNotificationAction *readAction = [UNNotificationAction actionWithIdentifier:kMCNotificationReadActionIdentity title:@"标记已读" options:UNNotificationActionOptionAuthenticationRequired];
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:kMCNotificationCategoryIdentity actions:@[deleteAction,readAction] intentIdentifiers:@[kMCNotificationDeleteActionIdentity,kMCNotificationReadActionIdentity] options:UNNotificationCategoryOptionCustomDismissAction];
    
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObjects:category, nil]];
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        DDLogDebug(@"completionHandler");
    }];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [UNUserNotificationCenter currentNotificationCenter].delegate = appDelegate;
}

- (void)shareYouqia
{
    [self shareYouqiaWithTitle:@"邮件办公上邮洽 Gmail也能直连" image:[UIImage imageNamed:@"youqiaIcon.png"] url:[NSURL URLWithString:@"http://a.app.qq.com/o/simple.jsp?pkgname=cn.mailchat&g_f=991653"]];
}

-(void)shareYouqiaWithTitle:(NSString *)title image:(UIImage *)image url:(NSURL *)url
{
    MCAppDelegate*mcAppDelegate = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *nav = mcAppDelegate.tabBarController.viewControllers[mcAppDelegate.tabBarController.selectedIndex];
    NSString *content = title;
    UIImage *image1 =image ;
    NSURL *url1 = url;
    NSArray *activityItems = @[content, image1, url1];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeMessage, UIActivityTypeCopyToPasteboard];
    [nav.viewControllers[0] presentViewController:activityVC animated:YES completion:nil];
    
}

- (UIImage *)getBackgroundImage
{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    screenWidth = MAX(screenWidth, screenHeight);
    
    if (screenHeight == 568.0) {
        return [UIImage imageNamed:@"LaunchImage-700-568h"];
    }
    
    if (screenHeight == 667.0) {
        return [UIImage imageNamed:@"LaunchImage-800-667h"];
    }
    
    if (screenHeight == 736.0) {
        return [UIImage imageNamed:@"LaunchImage-800-Portrait-736h"];
    }
    
    return [UIImage imageNamed:@"LaunchImage-700"];
}

@end
