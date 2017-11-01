//
//  MCDbVersionProtocol.h
//  NPushMail
//
//  Created by admin on 7/6/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@protocol MCDbVersionProtocol <NSObject>

@property (nonatomic,assign,readonly) NSInteger version;

- (BOOL)upgradeDatabase;

@end
