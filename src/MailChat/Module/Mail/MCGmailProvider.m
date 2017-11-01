//
//  MCGmailProvider.m
//  NPushMail
//
//  Created by admin on 9/29/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCGmailProvider.h"
#import "AppAuth.h"
#import "MCAccountManager.h"

@interface MCGmailProvider ()<OIDAuthStateChangeDelegate>

@property (nonatomic,strong) OIDAuthState *authState;

@end

@implementation MCGmailProvider

- (instancetype)initWithAccount:(MCAccount *)account
{
    if (!account.authData) {
        DDLogError(@"Account %@ does't have authData",account.email);
    }
    
    OIDAuthState *state = [NSKeyedUnarchiver unarchiveObjectWithData:account.authData];
    account.authType = MCAccountAuthTypeOAuth;
    account.password = state.lastTokenResponse ? state.lastTokenResponse.accessToken : state.lastAuthorizationResponse.accessToken;
    
    if (self = [super initWithAccount:account]) {
        self.authState = state;
        self.authState.stateChangeDelegate = self;
    }
    
    return self;
}

#pragma mark - Delegate

- (void)didChangeState:(OIDAuthState *)state
{
    self.account.password = state.lastTokenResponse.accessToken;
    self.account.authData = [NSKeyedArchiver archivedDataWithRootObject:state];
    [[MCAccountManager shared] updateAccount:self.account];
    
    [super refreshAuthentication];
}


#pragma mark - Override

- (void)loginSuccess:(ActionBlock)success failure:(FailureBlock)failure
{
    [self.authState withFreshTokensPerformAction:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else{
            [super loginSuccess:success failure:failure];
        }
    }];
}


- (void)getAllFoldersSuccess:(SuccessBlock)success
                     failure:(FailureBlock)failure
{
    [self.authState withFreshTokensPerformAction:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else{
            [super getAllFoldersSuccess:success failure:failure];
        }
    }];
}

- (void)getFolderInfo:(NSString *)folder
              success:(SuccessBlock)success
              failure:(FailureBlock)failure
{
    [self.authState withFreshTokensPerformAction:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else{
            [super getFolderInfo:folder success:success failure:failure];
        }
    }];
}


- (void)getMailsByNumbersInFolder:(MCMailBox *)folder requestKind:(MCIMAPMessageRequestKind)requestKind numbers:(NSRange)range success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self.authState withFreshTokensPerformAction:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else{
            [super getMailsByNumbersInFolder:folder requestKind:requestKind numbers:range success:success failure:failure];
        }
    }];
}

- (void)getMailsByUidsInFolder:(MCMailBox *)folder requestKind:(MCIMAPMessageRequestKind)requestKind uids:(NSIndexSet *)uids success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self.authState withFreshTokensPerformAction:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else{
            [super getMailsByUidsInFolder:folder requestKind:requestKind uids:uids success:success failure:failure];
        }
    }];
}

- (void)getAttachmentData:(MCMailAttachment*)attachment progress:(ProgressBlock)progrss success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self.authState withFreshTokensPerformAction:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else{
            [super getAttachmentData:attachment progress:progrss success:success failure:failure];
        }
    }];
}

- (void)updateMailContent:(MCMailModel *)mailModel inFolder:(MCMailBox *)folder urgent:(BOOL)urgent success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self.authState withFreshTokensPerformAction:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else{
            [super updateMailContent:mailModel inFolder:folder urgent:urgent success:success failure:failure];
        }
    }];
}


- (void)getFullMailFolder:(MCMailBox*)folder  byUid:(NSInteger)uid success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self.authState withFreshTokensPerformAction:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else{
            [super getFullMailFolder:folder byUid:uid success:success failure:failure];
        }
    }];
}

- (void)storeFlag:(MCMailFlags)flag
          toMails:(NSArray *)uids
        storeKind:(MCMailFlagStoreKind)storeKind
          success:(ActionBlock)success
          failure:(FailureBlock)failure
{
    [self.authState withFreshTokensPerformAction:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else{
            [super storeFlag:flag toMails:uids storeKind:storeKind success:success failure:failure];
        }
    }];
}

- (void)moveMails:(NSArray *)uids
       fromFolder:(NSString *)fromFolder
         toFolder:(NSString *)toFolder
          success:(ActionBlock)success
          failure:(FailureBlock)failure
{
    [self.authState withFreshTokensPerformAction:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else{
            [super moveMails:uids fromFolder:fromFolder toFolder:toFolder success:success failure:failure];
        }
    }];
}


- (void)searchMailsWithFolder:(NSString*)folder
                   searchKind:(MCSearchMailKind)searchKind
                   searchText:(NSString*)searchText
                      success:(SuccessBlock)success
                      failure:(FailureBlock)failure
{
    [self.authState withFreshTokensPerformAction:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else{
            [super searchMailsWithFolder:folder searchKind:searchKind searchText:searchText success:success failure:failure];
        }
    }];
}

//sent

- (void)smtpConnectWithSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self.authState withFreshTokensPerformAction:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else{
            [super smtpConnectWithSuccess:success failure:failure];
        }
    }];
}

- (void)sendEmailWithData:(NSData*)messageData success:(SuccessBlock)success failure:(FailureBlock)failure progress:(ProgressBlock)progress
{
    [self.authState withFreshTokensPerformAction:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else{
            [super sendEmailWithData:messageData success:success failure:failure progress:progress];
        }
    }];
}

- (void)appendMailWithData:(NSData*)messageData folder:(NSString*)folder  isSent:(BOOL)isSent success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self.authState withFreshTokensPerformAction:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else{
            [super appendMailWithData:messageData folder:folder isSent:isSent success:success failure:failure];
        }
    }];
}

@end
