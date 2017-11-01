//
//  MCGmailAuth.m
//  NPushMail
//
//  Created by admin on 9/30/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCGmailAuth.h"
#import "NSURLSession+Proxy.h"
#import "MCLoginManager.h"
#import "MCAvatarHelper.h"
#import "MCAccountManager.h"
#import "MCContactManager.h"

static NSString* const kMailChatProxyHost = @"g.mailchat.cn";

@implementation MCGmailAuth

+ (MCMailConfig *)gmailConfig
{
    MCMailConfigItem *imap = [MCMailConfigItem new];
    imap.hostName = kMailChatProxyHost;
    imap.port = 9001;
    imap.ssl = MCMailEncryptSSL;
    
    MCMailConfigItem *smtp = [MCMailConfigItem new];
    smtp.hostName = kMailChatProxyHost;
    smtp.port = 9002;
    smtp.ssl = MCMailEncryptSSL;
    
    MCMailConfig *config = [[MCMailConfig alloc] init];
    config.imap = imap;
    config.smtp = smtp;
    config.mailType = MCMailTypeGmail;
    config.mailTypeKey = @"gmail";
    
    return config;
}

+ (void)requestAccountWithAuthState:(OIDAuthState *)authState success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSURL *userinfoEndpoint =
    authState.lastAuthorizationResponse.request.configuration.discoveryDocument.userinfoEndpoint;
    if (!userinfoEndpoint) {
        DDLogError(@"Userinfo endpoint not declared in discovery document");
        return;
    }
    NSString *currentAccessToken = authState.lastTokenResponse.accessToken;
    
    DDLogVerbose(@"Performing userinfo request");
    
    [authState withFreshTokensPerformAction:^(NSString *_Nonnull accessToken,
                                               NSString *_Nonnull idToken,
                                               NSError *_Nullable error) {
        if (error) {
           DDLogError(@"Error fetching fresh tokens: %@", [error localizedDescription]);
            return;
        }
        
        // log whether a token refresh occurred
        if (![currentAccessToken isEqual:accessToken]) {
            DDLogVerbose(@"Access token was refreshed automatically (%@ to %@)",
             currentAccessToken,
             accessToken);
        } else {
            DDLogVerbose(@"Access token was fresh and not updated [%@]", accessToken);
        }
        
        // creates request to the userinfo endpoint, with access token in the Authorization header
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:userinfoEndpoint];
        NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
        [request addValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];
        
        NSURLSessionConfiguration *configuration =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.connectionProxyDictionary = [NSURLSession sessionProxyConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                              delegate:nil
                                                         delegateQueue:nil];
        
        // performs HTTP request
        NSURLSessionDataTask *postDataTask =
        [session dataTaskWithRequest:request
                   completionHandler:^(NSData *_Nullable data,
                                       NSURLResponse *_Nullable response,
                                       NSError *_Nullable error) {
                       dispatch_async(dispatch_get_main_queue(), ^() {
                           if (error) {
                               DDLogError(@"HTTP request failed %@", error);
                               return;
                           }
                           if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
                               DDLogError( @"Non-HTTP response");
                               return;
                           }
                           
                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                           id jsonDictionaryOrArray =
                           [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                           
                           if (httpResponse.statusCode != 200) {
                               // server replied with an error
                               NSString *responseText = [[NSString alloc] initWithData:data
                                                                              encoding:NSUTF8StringEncoding];
                               if (httpResponse.statusCode == 401) {
                                   // "401 Unauthorized" generally indicates there is an issue with the authorization
                                   // grant. Puts OIDAuthState into an error state.
                                   NSError *oauthError =
                                   [OIDErrorUtilities resourceServerAuthorizationErrorWithCode:0
                                                                                 errorResponse:jsonDictionaryOrArray
                                                                               underlyingError:error];
                                   [authState updateWithAuthorizationError:oauthError];
                                   
                                   if (failure) {
                                       failure(oauthError);
                                   }
                                   // log error
                                   DDLogError( @"Authorization Error (%@). Response: %@", oauthError, responseText);
                               } else {
                                   DDLogVerbose( @"HTTP: %d. Response: %@",
                                    (int)httpResponse.statusCode,
                                    responseText);
                               }
                               return;
                           }
                           
                           // success response
                           DDLogVerbose( @"Success: %@", jsonDictionaryOrArray);
                           NSString *serverCode = (NSString *)authState.lastTokenResponse.additionalParameters[@"server_code"];
                           MCAccount *account = [self accountWithAuthDictionary:jsonDictionaryOrArray andAuthState:authState];
                           account.serverCode = serverCode;
                           [[MCAccountManager shared] updateAccount:account withNickName:account.displayName company:nil dept:nil title:nil success:nil failure:nil];
                           if (success) {
                               success(account);
                           }
                           
                       });
                   }];
        
        [postDataTask resume];
    }];
}

+ (MCAccount *)accountWithAuthDictionary:(NSDictionary *)dict andAuthState:(OIDAuthState *)authState
{
    MCAccount *account = [[MCAccount alloc] init];
    account.email = dict[@"email"];
    account.displayName = dict[@"name"];
    account.type = MCMailTypeGmail;
    account.authType = MCAccountAuthTypeOAuth;
    account.authData = [NSKeyedArchiver archivedDataWithRootObject:authState];
    account.config = [self gmailConfig];
    account.color = [UIColor colorWithHexString:[MCAvatarHelper randomColorHexString]];
    account.signature = PMLocalizedStringWithKey(@"PM_Mail_Signature");
    account.status = MCAccountStatusInitialized;
    return account;
}

@end
