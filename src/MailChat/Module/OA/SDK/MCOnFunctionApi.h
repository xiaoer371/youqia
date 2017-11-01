//
//  MCOnFunctionApi.h
//  NPushMail
//
//  Created by gaoyq on 10/02/2017.
//  Copyright © 2017 sprite. All rights reserved.
//

#import "MCJSApi.h"

static const NSString *kMailchatEventGoback = @"goback";
static const NSString *kMailchatEventButtonClick = @"button_click";


@interface MCOnFunctionApi : MCJSApi

- (void)fireEvent:(NSString *)event withParameters:(id)parameters;

@end
