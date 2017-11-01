//
//  UIBarButtonItem+note.m
//  NPushMail
//
//  Created by zhang on 16/7/18.
//  Copyright © 2016年 sprite. All rights reserved.
//
#import <objc/runtime.h>
#import "UIBarButtonItem+note.h"

static NSString *const kMUIBarButtonItemNoteKey = @"BarButtonNoteKey";
static const CGFloat kMUIBarButtonItemNoteSize = 8.0f;
@implementation UIBarButtonItem(note)

- (void)initNoteShow:(BOOL)show {
    
    UIView *view;
    if (self.customView) {
        view = self.customView;
        view.clipsToBounds = YES;
    } else {
        view = [(id)self view];
    }
    UIView *note = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(view.frame) + 2,2, kMUIBarButtonItemNoteSize, kMUIBarButtonItemNoteSize)];
    note.backgroundColor = [UIColor redColor];
    note.layer.cornerRadius = kMUIBarButtonItemNoteSize/2;
    note.hidden = !show;
    [view addSubview:note];
    objc_setAssociatedObject(self, &kMUIBarButtonItemNoteKey, note, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showBarButtonNote:(BOOL)showNote {
    
    UIView *note = objc_getAssociatedObject(self, &kMUIBarButtonItemNoteKey);
    if (!note) {
        [self initNoteShow:showNote];
    } else {
       note.hidden = !showNote;
    }
}
@end
