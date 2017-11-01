//
//  MCMailSubject.m
//  NPushMail
//
//  Created by admin on 19/11/2016.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailSubject.h"

@implementation MCMailSubject

- (instancetype)initWithSubject:(NSString *)subject
{
    if (self = [super init]) {
        _subject = [subject copy];
        [self parseSubject:_subject];
    }
    return self;
}

- (void)parseSubject:(NSString *)subject
{
    if ([subject containsString:@":"]) {
        NSArray *splitWords = [subject componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
        NSString *firstWord = [splitWords[0] trim];
        NSArray *replyWords = [[self class] replyWords];
        NSArray *forwardWords = [self.class forwardWords];
        if ([replyWords containsObject:firstWord]) {
            _isReply = YES;
            _realSubject = [[self class] parseOriginalSubjectWithWords:splitWords];
        }
        else if ([forwardWords containsObject:firstWord]) {
            _isFoward = YES;
            _realSubject = [[self class] parseOriginalSubjectWithWords:splitWords];
        }
        else {
            _realSubject = subject;
        }
    }
    else {
        _realSubject = subject;
    }
}

+ (NSString *)parseOriginalSubjectWithWords:(NSArray *)splitedWords
{
    NSMutableString *realName = [NSMutableString new];
    NSArray *replyWords = [self replyWords];
    NSArray *forwardWords = [self forwardWords];
    for (NSString *word in splitedWords) {
        if ([replyWords containsObject:[word trim]] ||
             [forwardWords containsObject:[word trim]]) {
            continue;
        }
        
        if (realName.length > 0) {
            [realName appendString:@":"];
        }
        [realName appendString:word];
    }
    
    return [realName copy];
}

+ (NSArray *)replyWords
{
    static NSArray *words;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        words = @[@"Re",@"Re all",@"回复",@"答复",@"回覆", @"答覆"];
    });
    
    return words;
}

+ (NSArray *)forwardWords
{
    static NSArray *words;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        words = @[@"Fw",@"Fwd",@"转发",@"轉發"];
    });
    
    return words;
}

@end
