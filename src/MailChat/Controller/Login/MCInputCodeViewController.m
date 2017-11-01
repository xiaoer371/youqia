//
//  MCInputCodeViewController.m
//  NPushMail
//
//  Created by swhl on 16/1/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCInputCodeViewController.h"
#define LeftX 20.0f
@interface MCInputCodeViewController ()<UITextFieldDelegate>

@property(nonatomic,strong)UIButton  *noteBtn;
@property (strong, nonatomic)  UILabel *titleLabel;
@property (strong, nonatomic)  UILabel *contentLabel;
@property (strong, nonatomic)  UILabel *noteLabel;
@property (strong, nonatomic)  UIView *bgView;
@property (strong, nonatomic)  UITextField *textField;
@property (strong, nonatomic)  UIButton *startBtn;



@end

@implementation MCInputCodeViewController

- (instancetype)initWithDic:(NSMutableDictionary*)dic withData:(NSData*)data
{
    self = [super init];
    if (self) {
//        self.data =data;
//        self.userDic =dic;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];

    
    [self.view addSubview:self.titleLabel];
    
    [self.view addSubview:self.bgView];
    [self.view addSubview:self.textField];
    
    [self.view addSubview:self.contentLabel];
    
    [self.view addSubview:self.noteLabel];
    
    
    [self.view addSubview:self.startBtn];
    
    [self.view addSubview:self.noteBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];

}


- (IBAction)jumpAction:(id)sender {
    
}

- (IBAction)startAction:(id)sender
{
    //    WEAKSELF
    if (_textField.text.length>0) {
        
    }
}


-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        
        _titleLabel =[[UILabel alloc] initWithFrame:CGRectMake(60, 58, ScreenWidth-120,18)];
        _titleLabel.text =PMLocalizedStringWithKey(@"PM_Invite_InputCode");
        _titleLabel.font=[UIFont systemFontOfSize:18.0f];
        _titleLabel.textAlignment =NSTextAlignmentCenter;
    }
    return _titleLabel;
}

-(UILabel *)contentLabel
{
    if (!_contentLabel) {
        
        float a =CGRectGetMaxY(self.textField.frame);
        
        _contentLabel =[[UILabel alloc] initWithFrame:CGRectMake(LeftX, a+12, ScreenWidth-LeftX*2,50)];
        _contentLabel.font=[UIFont systemFontOfSize:14.0f];
        NSString *string =[NSString stringWithFormat:@"%@%@",PMLocalizedStringWithKey(@"PM_Invite_Info"),PMLocalizedStringWithKey(@"PM_Msg_Details")];
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:string];
        NSRange range =[string rangeOfString:PMLocalizedStringWithKey(@"PM_Msg_Details")];
        NSRange range1 =[string rangeOfString:PMLocalizedStringWithKey(@"PM_Invite_Info")];
        [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"808080"] range:range1];
        [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"006dc3"] range:range];
        _contentLabel.attributedText=attriString;
        _contentLabel.numberOfLines =0;
        _contentLabel.textAlignment =NSTextAlignmentLeft;
    }
    return _contentLabel;
}

-(UIView *)bgView
{
    if (!_bgView) {
        _bgView =[[UIView alloc] initWithFrame:CGRectMake(LeftX, 100, ScreenWidth-LeftX*2, 44)];
        _bgView.backgroundColor =[UIColor colorWithHexString:@"e6e6e6"];
    }
    return _bgView;
}
-(UITextField *)textField
{
    if (!_textField) {
        _textField =[[UITextField alloc] initWithFrame:CGRectMake(LeftX+3, 105, ScreenWidth-LeftX*2, 34)];
        _textField.borderStyle =UITextBorderStyleNone;
        _textField.delegate = self;
        _textField.placeholder =PMLocalizedStringWithKey(@"PM_Invite_InputCode");
    }
    return _textField;
}

-(UILabel *)noteLabel
{
    if (!_noteLabel) {
        float a =CGRectGetMaxY(self.contentLabel.frame);
        _noteLabel =[[UILabel alloc] initWithFrame:CGRectMake(LeftX, a+12, ScreenWidth-LeftX*2,31)];
        _noteLabel.text =PMLocalizedStringWithKey(@"PM_Invite_Mark");
        _noteLabel.textColor =[UIColor colorWithHexString:@"808080"];
        _noteLabel.font=[UIFont systemFontOfSize:14.0f];
        _noteLabel.textAlignment =NSTextAlignmentLeft;
    }
    return _noteLabel;
}

-(UIButton *)noteBtn
{
    if (!_noteBtn) {
        _noteBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        _noteBtn.frame =self.contentLabel.frame;
        _noteBtn.backgroundColor =[UIColor clearColor];
        [_noteBtn addTarget:self action:@selector(noteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _noteBtn;
}



-(UIButton *)startBtn
{
    if (!_startBtn) {
        _startBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        float h =CGRectGetMaxY(self.noteLabel.frame);
        _startBtn.frame =CGRectMake(LeftX, h+30, ScreenWidth-LeftX*2, 44);
        _startBtn.layer.cornerRadius = 6;
        [_startBtn setTitle:PMLocalizedStringWithKey(@"PM_Login_YQstart") forState:UIControlStateNormal];
        [_startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
        _startBtn.backgroundColor =[UIColor colorWithHexString:@"75bde1"];
    }
    return _startBtn;
}

- (void)loadMainView
{
    
}

-(void)noteAction:(UIButton*)sender
{
    [self.view endEditing:YES];
}

#pragma mark-UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ((range.location ==0 && range.length == 1) || textField.text.length == 0) {
        _startBtn.backgroundColor = [UIColor colorWithHexString:@"75bde1"];
        _startBtn.userInteractionEnabled = NO;
    }else{
        _startBtn.backgroundColor = [UIColor colorWithHexString:@"2ea8e6"];
        _startBtn.userInteractionEnabled = YES;
    }
    return YES;
}



#pragma mark - touch

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark  - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
