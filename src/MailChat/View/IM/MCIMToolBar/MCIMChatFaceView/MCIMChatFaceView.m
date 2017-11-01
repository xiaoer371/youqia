//
//  MCIMChatFaceView.m
//  NPushMail
//
//  Created by swhl on 16/3/2.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatFaceView.h"


const static NSInteger   xChatFaceNum = 7 ;  //一行显示几个表情
const static NSInteger   xChatFaceRow = 4;   //一页显示几行

#define ImageWidth  26
#define ImageHeight  25

#define ITEM_WIDTH (ScreenWidth-ImageWidth*xChatFaceNum)/(xChatFaceNum+1)
#define ITEM_HEIGHT  43



#define HPadding (ScreenWidth-ITEM_WIDTH*xChatFaceNum)/(xChatFaceNum+1)
#define YPadding 5


@interface MCIMChatFaceView ()

@property (nonatomic, strong) NSMutableArray  *faceArray;  //

@property (nonatomic, strong) NSDictionary  *faceNameDics;  //

@end

@implementation MCIMChatFaceView

-(instancetype)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame:frame];
    if (self ) {
        self.backgroundColor = AppStatus.theme.chatStyle.moreViewBackGroundColor;
        [self _initData];
    }
    return self;
}

-(void)_initData
{
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MCIMChatEmoji" ofType:@"plist"];
//    NSDictionary  *allFacesDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
//    NSArray *faceImages =[allFacesDic allKeys];
    
    NSMutableArray *faceImages = [[NSMutableArray alloc] initWithCapacity:76];
    for (int i=1; i<77; i++) {
        NSString *str;
        if (i<10) {
            str = [NSString stringWithFormat:@"emoji_00%d",i];
        }else{
            str = [NSString stringWithFormat:@"emoji_0%d",i];
        }
        [faceImages addObject:str];
    }
    
    int sub = (xChatFaceNum * xChatFaceRow) - 3 ; //每页表情数
    NSMutableArray *smoleArray =[[NSMutableArray alloc] initWithCapacity:sub];

    for (int i=0; i< faceImages.count; i++) {
        if ((i % sub) ==0 && i!=0) {
            [self.faceArray addObject:smoleArray];
            smoleArray = [[NSMutableArray alloc] initWithCapacity:sub];
        }
        NSString *str = faceImages[i];
        [smoleArray addObject:str];
        if (i == faceImages.count-1) {
            [self.faceArray addObject:smoleArray];
        }
    }
    
    
    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleClick:)];
    //点击的次数
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    //给self.添加一个手势监测；
    [self addGestureRecognizer:singleRecognizer];
    
}

-(void)singleClick:(UITapGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:self];
    [self touchFace:point];
}

-(void)touchFace:(CGPoint)point
{
    int page = point.x / ScreenWidth;
    
    float x = point.x - (page*ScreenWidth);
    float y = point.y ;
    
    int colum = (x-HPadding) / (ITEM_WIDTH + HPadding);
    int row = y / (ITEM_HEIGHT+YPadding);
    
    int index = colum + (row * xChatFaceNum);
    
    int sum = xChatFaceNum * xChatFaceRow -2;  //(ps: 一页显示表情总数)
    int delNub = xChatFaceNum * (xChatFaceRow-1) -1;  //(ps: 删除键位置)
    int sendNum = xChatFaceNum * xChatFaceRow -2;  //(ps: 发送键位置)
    
    
    if (index < sum && index != delNub) {
       
        NSArray *array = [self.faceArray objectAtIndex:page];
        
        if (index > array.count) {
            return;
        }
        if ( index == sum-1) {
            NSString *str = [array objectAtIndex:delNub];
            NSString *faceName = self.faceNameDics[str];
            if (self.delegate && [self.delegate respondsToSelector:@selector(selectedFacialView:)]) {
                [self.delegate selectedFacialView:faceName];
            }
            return;
        }
        NSString *str = [array objectAtIndex:index];
           NSString *faceName = self.faceNameDics[str];
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectedFacialView:)]) {
            [self.delegate selectedFacialView:faceName];
        }
        
    }else if(index==delNub){
        if (self.delegate && [self.delegate respondsToSelector:@selector(deleteFacialView:)]) {
            [self.delegate deleteFacialView:@"删除"];
        }
        
    }else if(index == sendNum || index == sendNum+1){
        if ([self.delegate respondsToSelector:@selector(sendMessageText:)]) {
            [self.delegate sendMessageText:nil];
        }
    }

}

- (void)drawRect:(CGRect)rect {
    
    // Drawing code
    int row = 0, colum =0;
    
    int sum = xChatFaceNum * xChatFaceRow;  //(ps: 一页显示表情总数)
    int delNub = xChatFaceNum * (xChatFaceRow-1) -1;  //(ps: 删除键位置)
    int sendNum = xChatFaceNum * xChatFaceRow -2;  //(ps: 发送键位置)
    
    for (int i=0; i<self.faceArray.count; i++) {
        NSArray *smoleArray =[self.faceArray objectAtIndex:i];
        
        for (int j=0; j< sum ; j++) {
            
            if (j<smoleArray.count && j != delNub ) {
                
//                UIImage *image = [UIImage imageNamed:self.faceArray[i][j]];
                 UIImage *image = [UIImage  imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], self.faceArray[i][j]]];
                
                CGRect frame =CGRectMake(HPadding+colum * (ITEM_WIDTH+HPadding), 10+row*(ITEM_HEIGHT+YPadding) , ImageWidth, ImageHeight);
                float x = i*ScreenWidth + frame.origin.x;
                frame.origin.x = x;
                [image drawInRect:frame];
                
            }else if(j == delNub)
            {
                UIImage *image =[UIImage imageNamed:@"deleteFace.png"];
                CGRect frame =CGRectMake(HPadding+colum *(ITEM_WIDTH +HPadding) ,10+ row*(ITEM_HEIGHT+YPadding) , 25, 25);
                float x = i*ScreenWidth + frame.origin.x;
                frame.origin.x = x;
                [image drawInRect:frame];
                
            }else if(j == sendNum)
            {
                UIImage *image =[UIImage imageNamed:@"sendFace.png"];
                CGRect frame =CGRectMake(2*HPadding+colum *(ITEM_WIDTH +HPadding)- ITEM_WIDTH*2/3,row*(ITEM_HEIGHT+YPadding)-5, 60, 60);
                float x = i*ScreenWidth + frame.origin.x;
                frame.origin.x = x;
                [image drawInRect:frame];
                
            }else if(j == sendNum-1){
                
                //  ps 最后一位 补被删除键 占用的
                if (smoleArray.count >= sendNum-1) {
                    UIImage *image = [UIImage imageNamed:self.faceArray[i][delNub]];
                    CGRect frame =CGRectMake(HPadding+colum *(ITEM_WIDTH +HPadding),10+ row*(ITEM_HEIGHT+YPadding) , ImageWidth, ImageHeight);
                    float x = i*ScreenWidth + frame.origin.x;
                    frame.origin.x = x;
                    [image drawInRect:frame];
                }
            }else{
                //
            }
            
            //更新列和行
            colum++;
            if (colum % xChatFaceNum==0) {
                row++;
                colum=0;
            }
            
            if (row == xChatFaceRow) {
                row=0;
            }
        }
    }
}


-(NSMutableArray *)faceArray
{
    if (!_faceArray) {
        _faceArray = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return _faceArray;
}

-(NSDictionary *)faceNameDics
{
    if (!_faceNameDics) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MCIMChatEmoji" ofType:@"plist"];
       _faceNameDics = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    }
    return _faceNameDics;
}

-(NSArray *)getPlistFaces
{
    NSArray *array = [self.faceNameDics allValues];
    return array;
}

@end
