//
//  MCMailSearchManager.m
//  NPushMail
//
//  Created by zhang on 16/5/24.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMailSearchManager.h"
#import "MCMailModel.h"
#import "MCMailProviderPool.h"

@interface MCMailSearchManager()

@property (nonatomic,strong)NSMutableArray *locMails;
@property (nonatomic,assign)MCSearchMailKind mcSearchMailKind;
@property (nonatomic,strong)NSString *mcSearchText;
@property (nonatomic,strong) id<MCMailProviderProtocol>provider;
@property (nonatomic,strong)NSMutableArray *searchResultUids;
@property (nonatomic,strong)MCMailContentTable *dbMail;
@property (nonatomic,strong)NSMutableArray *searchMails;
//@property (nonatomic,)
@end

@implementation MCMailSearchManager

- (instancetype)initWithAccount:(MCAccount *)account {
    if (self = [super init]) {
        _provider = [[MCMailProviderPool shared] providerForAccount:account];
        _dbMail = [[MCMailContentTable alloc] init];
        _searchResultUids = [NSMutableArray new];
    }
    
    return self;
}

- (void)beginSeachWithlocMails:(NSArray*)locMails {
    _locMails = [locMails mutableCopy];
    _mcSearchText = @"";
}

- (void)deleteSearchMails:(NSArray *)mails {
    [_locMails removeObjectsInArray:mails];
}

- (NSArray*)searchLocMailsSearchText:(NSString*)searchText searchKind:(MCSearchMailKind) searchKind {

    NSMutableArray *locSerachMails = [NSMutableArray new];
    _mcSearchMailKind = searchKind;
    _mcSearchText = searchText;
    
    for (MCMailModel *mail in _locMails) {
        
        if (searchKind == MCSearchMailKindAll) {
            
            if ([self string:mail.messageContentString Contains:searchText]|
                [self string:mail.subject  Contains:searchText]|
                [self string:mail.from.email Contains:searchText]|
                [self string:mail.from.name Contains:searchText]) {
                [locSerachMails addObject:mail];
            } else if ([self searchMailaddress:mail.to]|
                [self searchMailaddress:mail.cc]) {
                    [locSerachMails addObject:mail];
            }
            
        } else if (searchKind == MCSearchMailKindSubject) {
            
            if ([self string:mail.subject Contains:searchText]) {
                [locSerachMails addObject:mail];
            }
        } else if (searchKind == MCSearchMailKindTo) {
            
            if ([self searchMailaddress:mail.to]|
                [self searchMailaddress:mail.cc]) {
                [locSerachMails addObject:mail];
            }
        } else if(searchKind == MCSearchMailKindFrom) {
            
            if ([self searchMailaddress:@[mail.from]]) {
                [locSerachMails addObject:mail];
            }
            
        }
        
    }
    _searchMails = locSerachMails;
    return locSerachMails;
}


- (void)searchFromServerWithFolder:(MCMailBox*)folder success:(SuccessBlock)success failure:(FailureBlock)failure {
    
//    [_searchResultUids removeAllObjects];
    
    //添加友盟事件统计
    switch (_mcSearchMailKind) {
        case MCSearchMailKindAll:
            [MCUmengManager addEventWithKey:mc_mail_search_all];
            break;
        case MCSearchMailKindTo:
            [MCUmengManager addEventWithKey:mc_mail_search_receiver];
            break;
        case MCSearchMailKindFrom:
            [MCUmengManager addEventWithKey:mc_mail_search_sender];
            break;
        case MCSearchMailKindSubject:
            [MCUmengManager addEventWithKey:mc_mail_search_subject];
            break;
        default:
            break;
    }
     __weak typeof(self)weekSelf = self;
    [_provider searchMailsWithFolder:folder.path searchKind:_mcSearchMailKind searchText:_mcSearchText success:^(id response) {
        [weekSelf.searchResultUids removeAllObjects];
        NSIndexSet *indexSet = (NSIndexSet *)response;
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            [_searchResultUids insertObject:@(idx) atIndex:0];
        }];
        
        [weekSelf loadMoreSearchWithfolder:folder success:success failure:failure];
        
    } failure:failure];
}


- (void)loadMoreSearchWithfolder:(MCMailBox*)folder  success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    if (_searchResultUids.count > 0) {
        NSInteger len = _searchResultUids.count >20?20:_searchResultUids.count;
        NSArray *indexes = [_searchResultUids objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, len)]];
        NSMutableArray *needFetchUids = [NSMutableArray new];
        
        for (NSNumber *uid in indexes) {
              NSInteger mailUid = [uid integerValue];
              MCMailModel *mail = [_dbMail getMailWithFolder:folder.uid mailUid:mailUid];
              if (mail) {
                if ([_searchMails containsObject:mail]) {
                    continue;
                }
                [_searchMails addObject:mail];
              } else {
                [needFetchUids addObject:uid];
              }
        }
        if (_searchMails.count > 0) {
            _searchMails = [[_searchMails sortedArrayUsingComparator:^NSComparisonResult(MCMailModel *obj1, MCMailModel *obj2) {
                return [obj2.receivedDate compare:obj1.receivedDate];
            }] mutableCopy];
        }
        
        [_searchResultUids removeObjectsInRange:NSMakeRange(0, indexes.count)];
        NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
        for (NSNumber *uid in needFetchUids) {
            [indexSet addIndex:[uid integerValue]];
        }
        
        __weak typeof(self)weak = self;
        [_provider getMailsByUidsInFolder:folder requestKind:MCIMAPMessageRequestKindFullHeaders uids:indexSet success:^(id response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray* resultArray = (NSArray*)response;
                [_dbMail insertMails:resultArray];
                if (resultArray.count > 0) {
                    NSMutableArray *array = [NSMutableArray arrayWithArray:resultArray];
                    [array addObjectsFromArray:weak.searchMails];
                    NSArray *returnArray = [array sortedArrayUsingComparator:^NSComparisonResult(MCMailModel *obj1, MCMailModel *obj2) {
                        return [obj2.receivedDate compare:obj1.receivedDate];
                    }];
                    weak.searchMails = [returnArray mutableCopy];
                    success(returnArray);
                } else {
                    success(weak.searchMails);
                }
            });
            
        }  failure:failure];
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            success (_searchMails);
        });
    }
}

- (BOOL)string:(NSString*)string1 Contains:(NSString*)string2 {
    
    if (!string1) {
        return NO;
    }
    
    if ([[[string1 lowercaseString] trim] rangeOfString:[string2 lowercaseString]].location != NSNotFound) {
        return YES;
    }
    return NO;
}

- (BOOL)searchMailaddress:(NSArray*)addresses {
    
    for (MCMailAddress *address in addresses) {
        
        if ([self string:address.email Contains:_mcSearchText]|
            [self string:address.name Contains:_mcSearchText]) {
            return  YES;
        }
    }
    return NO;
}

@end
