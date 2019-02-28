//
//  GREditImageViewController.m
//  OpenCViOSTest
//
//  Created by Miaoz on 2017/6/30.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import "GREditImageViewController.h"
#import "Masonry.h"
#import "GRInputView.h"
#import "OpenCVUtil.h"
#define saveimageName @"/Documents/savepic.png"
// 获取屏幕 宽度、高度
#define GR_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define GR_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface GREditImageViewController ()
{
    UIImage *_image;
    CGRect   _frame;
}
@property(nonatomic, strong) UILabel *addressLab;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIView   *bottomView;
@property(nonatomic, strong) UIView   *topView;
@property(nonatomic, strong) UIButton *noteButton;
@property(nonatomic, strong) UIButton *undoButton;
@property(nonatomic, strong) UIButton *saveButton;
@property(nonatomic, strong) GRInputView *inputView;
@property(nonatomic, strong) UIImage *getImage;


@end

@implementation GREditImageViewController

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame address:(NSString *)address{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _image = image;
        _frame = frame;
        self.getImage = _image;
        self.addressLab.text = address;
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithImage: frame:" userInfo:nil];
}

+ (instancetype)new{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithImage: frame:" userInfo:nil];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithImage:nil frame:CGRectZero address:nil];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithImage:nil frame:CGRectZero address:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     [self.view addSubview:self.topView];
     [self.view addSubview:self.bottomView];
     [self.view addSubview:self.imageView];
     [self.imageView addSubview:self.addressLab];
     [self.topView addSubview:self.noteButton];
     [self.bottomView addSubview:self.undoButton];
     [self.bottomView addSubview:self.saveButton];
     [self.view addSubview:self.inputView];
     [self initLayout];
    // 监听键盘弹出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = NO;
}

#pragma mark -- Layout

- (void)initLayout {

    [self.noteButton mas_makeConstraints:^(MASConstraintMaker *make) {

        make.right.equalTo(self.topView.mas_right).offset(-20);
        make.centerY.mas_equalTo(self.topView.mas_centerY);
    }];
    
    [self.undoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.bottomView.mas_left).offset(50);
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
    }];
    
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.bottomView.mas_right).offset(-50);
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
    }];

    



}

#pragma mark -- ClickEvent

- (void)noteEvent:(id)sender {

    self.inputView.hidden = NO;

}

- (void)undoEvent:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)saveEvent:(id)sender {
    
   UIImage * getImage2 = [[OpenCVUtil share] imageWithImage:self.getImage scaledToSize:CGSizeMake(600, 600)];
   UIImage *getImage3 =  [[OpenCVUtil share] addimageWithTitle:self.inputView.text fontSize:16.0f image:getImage2 rectX:0 rectY: 20];
   UIImage *getImage4 =   [[OpenCVUtil share] addimageWithTitle:self.addressLab.text fontSize:16.0f image:getImage3 rectX:0 rectY: getImage2.size.height - 50];
    //傅里叶打水印
    cv::Mat orignMat = [[OpenCVUtil share] cvMatFromUIImage:getImage4];//
        [[OpenCVUtil share] transformImageWithText:orignMat blindMarkText:@"Test" point:cv::Point(45,45) fontSize:0.8 scalar:CV_RGB(255,255,255)];
    cv::Mat dfMat = [[OpenCVUtil share] antitransformImage];
    //把打水印的图片添加信息
    cv::Mat matTmp = [[OpenCVUtil share] addMessageMatrixToOriginalMatRow:dfMat messageDic:@{@"imageMD5":[[OpenCVUtil share] getImageMatrixMD5String:dfMat],@"data":@"data"}];
    self.imageView.image = [[OpenCVUtil share] UIImageFromCVMat:matTmp];
    
    NSString *imagePath = [NSHomeDirectory() stringByAppendingString:saveimageName];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(self.imageView.image) writeToFile:imagePath atomically:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"添加完成" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark -- UI

-(UILabel *)addressLab {
    if (_addressLab == nil) {
        _addressLab = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, (GR_SCREEN_WIDTH - 20)/2, 30)];
        _addressLab.center = CGPointMake(self.imageView.center.x, self.imageView.frame.size.height - 20);
        _addressLab.textAlignment = NSTextAlignmentCenter;
        _addressLab.font = [UIFont systemFontOfSize:11.0f];
        _addressLab.textColor = [UIColor whiteColor];
        _addressLab.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        _addressLab.text = @"徐汇区凯宾路206号平安大厦A座";
    }
    return _addressLab;
}
-(UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc]initWithImage:_image];
        _imageView.layer.masksToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.frame = CGRectMake((GR_SCREEN_WIDTH - _frame.size.width)/2, self.topView.frame.size.height, _frame.size.width, _frame.size.height);
    }
    
    return _imageView;

}

-(UIView *)topView{
    if (_topView == nil) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, GR_SCREEN_WIDTH, 64)];
        _topView.backgroundColor = [UIColor blackColor];
    }
    return _topView;
}

-(UIView *)bottomView{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, GR_SCREEN_HEIGHT - 100, GR_SCREEN_WIDTH, 100)];
        _bottomView.backgroundColor = [UIColor blackColor];
    }
    return _bottomView;
}

- (UIButton *)noteButton {
    if (_noteButton == nil) {
        _noteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_noteButton setTitle:@"添加备注" forState:UIControlStateNormal];
//        _noteButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_noteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_noteButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        [_noteButton addTarget:self action:@selector(noteEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_noteButton sizeToFit];
    }
    return _noteButton;
}

- (UIButton *)undoButton {
    if (_undoButton == nil) {
       _undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_undoButton setTitle:@"撤销" forState:UIControlStateNormal];
        [_undoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_undoButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        [_undoButton addTarget:self action:@selector(undoEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_undoButton sizeToFit];
    }
    return _undoButton;
}

- (UIButton *)saveButton {
    if (_saveButton == nil) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        [_saveButton addTarget:self action:@selector(saveEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_saveButton sizeToFit];
    }
    return _saveButton;
}

- (GRInputView *)inputView {
    if (_inputView == nil) {
        _inputView = [[GRInputView alloc] initWithFrame:CGRectMake(20, self.topView.frame.size.height + 10, GR_SCREEN_WIDTH - 40, 0)];
        _inputView.hidden = YES;
        _inputView.font = [UIFont systemFontOfSize:14.0f];
        _inputView.textColor = [UIColor whiteColor];
        _inputView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        // 设置文本框占位文字
        _inputView.placeholder = @"添加备注";
        _inputView.placeholderColor = [UIColor whiteColor];
        
        // 监听文本框文字高度改变
        _inputView.yz_textHeightChangeBlock = ^(NSString *text,CGFloat textHeight){
            // 文本框文字高度改变会自动执行这个【block】，可以在这【修改底部View的高度】
            // 设置底部条的高度 = 文字高度 + textView距离上下间距约束
            // 为什么添加10 ？（10 = 底部View距离上（5）底部View距离下（5）间距总和）
            self.inputView.frame = CGRectMake(self.inputView.frame.origin.x, self.inputView.frame.origin.y, self.inputView.frame.size.width, 10 + textHeight);
        };
        
        // 设置文本框最大行数
        _inputView.maxNumberOfLines = 4;

    }

    return _inputView;

}
// 键盘弹出会调用
- (void)keyboardWillChangeFrame:(NSNotification *)note
{
    // 获取键盘frame
    CGRect endFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 获取键盘弹出时长
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    
    // 修改底部视图距离底部的间距
//    _bottomCons.constant = endFrame.origin.y != screenH?endFrame.size.height:0;
    
    // 约束动画
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}


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
