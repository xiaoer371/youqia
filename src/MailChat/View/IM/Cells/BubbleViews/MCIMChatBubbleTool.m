//
//  MCIMChatBubbleTool.m
//  NPushMail
//
//  Created by swhl on 16/7/11.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatBubbleTool.h"

static NSString* const MCChatEmojiRegex         = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";

@interface MCIMChatBubbleTool ()

@property (nonatomic ,strong)NSDataDetector       *detector;
@property (nonatomic ,strong)NSRegularExpression  *regexEmoji;

@end


@implementation MCIMChatBubbleTool

+ (MCIMChatBubbleTool *)sharedInstance
{
    static MCIMChatBubbleTool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _emojiMatches = [NSMutableDictionary new];
        _PhoneMatches = [NSMutableDictionary new];
        self.detector= [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:nil];
        self.regexEmoji= [[NSRegularExpression alloc]initWithPattern:MCChatEmojiRegex options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return self;
}

- (NSArray* )getEmojiMatchsWithContent:(NSString *)content
{
    NSArray *matchs =[self.regexEmoji matchesInString:content options:NSMatchingReportProgress range:NSMakeRange(0, [content length])];
    return matchs;
}

- (NSArray *)getPhoneAndLinkMatchsWithContent:(NSString *)content
{
    NSArray *matches = [self.detector matchesInString:content options:NSMatchingReportProgress range:NSMakeRange(0, content.length)];
    return matches;
}


- (NSDictionary *)mapper
{
    if (_mapper) {
        return _mapper;
    }
    
    @synchronized (self) {
        if (!_mapper) {
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MCIMEmoji" ofType:@"plist"];
            NSDictionary  *allFacesDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
            _mapper = allFacesDic;
        }
        return _mapper;
    }
}


@end
