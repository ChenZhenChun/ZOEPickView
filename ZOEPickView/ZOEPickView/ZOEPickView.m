//
//  ZOEPickView.m
//  AiyoyouCocoapods
//
//  Created by aiyoyou on 15/3/13.
//  Copyright (c) 2015年 zysoft. All rights reserved.
//

#define ToobarHeight 38
#import "ZOEPickView.h"

@interface ZOEPickView ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIDatePickerMode _datePickerMode;
}
@property (nonatomic,copy)   void (^MyBolck)(ZOEPickView *pickView,NSString *resultStr,NSInteger index);
@property (nonatomic,copy)   void (^MyBolck2)(ZOEPickView *pickView,NSString *resultStr,NSString *resultIndex);
@property (nonatomic,copy)   NSString               *plistName;
@property (nonatomic,strong) NSArray                *plistArray;
@property (nonatomic,assign) BOOL                   isLevelArray;
@property (nonatomic,assign) BOOL                   isLevelString;
@property (nonatomic,assign) BOOL                   isLevelDic;
@property (nonatomic,strong) NSDictionary           *levelTwoDic;
@property (nonatomic,strong) UIToolbar              *toolbar;
@property (nonatomic,strong) UIPickerView           *pickerView;
@property (nonatomic,strong) UIDatePicker           *datePickerTemp;
@property (nonatomic,assign) BOOL                   isHaveNavControler;//底部是否有tabBar
@property (nonatomic,assign) NSInteger              pickeviewHeight;
@property (nonatomic,copy)   NSString               *resultString;
@property (nonatomic,copy)   NSString               *resultIndex;
@property (nonatomic,strong) NSMutableArray         *dicKeyArray;
@property (nonatomic,copy)   NSMutableArray         *state;
@property (nonatomic,copy)   NSMutableArray         *city;
@property (nonatomic,assign) BOOL                   isDatePicker;
@property (nonatomic,strong) UIView                 *bgView;
@property (nonatomic,strong) UIButton               *leftBtn;
@property (nonatomic,strong) UILabel                *titleLabel;
@property (nonatomic,strong) UIButton               *rightBtn;

@end

@implementation ZOEPickView
@synthesize toolbarTextColor = _toolbarTextColor;

#pragma mark - init

- (instancetype)initPickviewWithPlistName:(NSString *)plistName isHaveNavControler:(BOOL)isHaveNavControler{
    
    self=[super init];
    if (self) {
        _plistName = plistName;
        _isDatePicker = NO;
        self.plistArray = [self getPlistArrayByplistName:plistName];
        [self pickerView];
        [_pickerView selectRow:(self.plistArray.count>3 ? 3:0) inComponent:0 animated:YES];
        [self setFrameWith:isHaveNavControler];
        [self toolbar];
    }
    return self;
}

- (instancetype)initPickviewWithArray:(NSArray *)array isHaveNavControler:(BOOL)isHaveNavControler{
    self=[super init];
    if (self) {
        _isDatePicker = NO;
        self.plistArray = array;
        [self setArrayClass:array];
        [self pickerView];
        [_pickerView selectRow:(self.plistArray.count>3 ? 3:0) inComponent:0 animated:YES];
        [self setFrameWith:isHaveNavControler];
        [self toolbar];
    }
    return self;
}

- (instancetype)initPickviewWithArray:(NSArray *)array isHaveNavControler:(BOOL)isHaveNavControler Block:(void (^)(ZOEPickView *pickView,NSString *resultStr,NSInteger index)) resultBlock {
    self=[super init];
    if (self) {
        _isDatePicker = NO;
        self.plistArray = array;
        [self setArrayClass:array];
        [self pickerView];
        [_pickerView selectRow:(self.plistArray.count>3 ? 3:0) inComponent:0 animated:YES];
        [self setFrameWith:isHaveNavControler];
        [self toolbar];
    }
    _MyBolck = resultBlock;
    return self;
}

- (instancetype)initPickviewWithArray:(NSArray *)array isHaveNavControler:(BOOL)isHaveNavControler block:(void (^)(ZOEPickView *pickView,NSString *resultStr,NSString *resultIndex)) resultBlock {
    self=[super init];
    if (self) {
        _isDatePicker = NO;
        self.plistArray = array;
        [self setArrayClass:array];
        [self pickerView];
        [_pickerView selectRow:(self.plistArray.count>3 ? 3:0) inComponent:0 animated:YES];
        [self setFrameWith:isHaveNavControler];
        [self toolbar];
    }
    _MyBolck2 = resultBlock;
    return self;
}

- (instancetype)initDatePickWithDate:(NSDate *)defaulDate datePickerMode:(UIDatePickerMode)datePickerMode isHaveNavControler:(BOOL)isHaveNavControler{
    self=[super init];
    if (self) {
        _datePickerMode = datePickerMode;
        _isDatePicker = YES;
        self.datePickerTemp.datePickerMode = datePickerMode;
        if (defaulDate)self.datePickerTemp.date = defaulDate;
        [self setFrameWith:isHaveNavControler];
        [self toolbar];
    }
    return self;
}

- (instancetype)initDatePickWithDate:(NSDate *)defaulDate datePickerMode:(UIDatePickerMode)datePickerMode isHaveNavControler:(BOOL)isHaveNavControler  Block:(void (^)(ZOEPickView *pickView,NSString *resultStr,NSInteger index)) resultBlock {
    self=[super init];
    if (self) {
        _datePickerMode = datePickerMode;
        _isDatePicker = YES;
        self.datePickerTemp.datePickerMode = datePickerMode;
        if (defaulDate)self.datePickerTemp.date = defaulDate;
        [self setFrameWith:isHaveNavControler];
        [self toolbar];
    }
    _MyBolck = resultBlock;
    return self;
}

- (instancetype)initDatePickWithDate:(NSDate *)defaulDate datePickerMode:(UIDatePickerMode)datePickerMode isHaveNavControler:(BOOL)isHaveNavControler  block:(void (^)(ZOEPickView *pickView,NSString *resultStr,NSString *resultIndex)) resultBlock {
    self=[super init];
    if (self) {
        _datePickerMode = datePickerMode;
        _isDatePicker = YES;
        self.datePickerTemp.datePickerMode = datePickerMode;
        if (defaulDate)self.datePickerTemp.date = defaulDate;
        [self setFrameWith:isHaveNavControler];
        [self toolbar];
    }
    _MyBolck2 = resultBlock;
    return self;
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (_isLevelArray) {
        return _plistArray.count;
    }
    if (_isLevelString){
        return 1;
    }
    if(_isLevelDic){
        return [_levelTwoDic allKeys].count*2;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *rowArray=[[NSArray alloc] init];
    if (_isLevelArray) {
        rowArray=_plistArray[component];
    }else if (_isLevelString){
        rowArray=_plistArray;
    }else if (_isLevelDic){
        NSInteger pIndex = [pickerView selectedRowInComponent:0];
        NSDictionary *dic=_plistArray[pIndex];
        for (id dicValue in [dic allValues]) {
                if ([dicValue isKindOfClass:[NSArray class]]) {
                    if (component%2==1) {
                        rowArray=dicValue;
                    }else{
                        rowArray=_plistArray;
                    }
            }
        }
    }
    return rowArray.count;
}


#pragma mark UIPickerViewdelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *rowTitle=nil;
    if (_isLevelArray) {
        rowTitle=_plistArray[component][row];
    }else if (_isLevelString){
        rowTitle=_plistArray[row];
    }else if (_isLevelDic){
        NSInteger pIndex = [pickerView selectedRowInComponent:0];
        NSDictionary *dic=_plistArray[pIndex];
        if(component%2==0)
        {
            rowTitle=_dicKeyArray[row][component];
        }
        for (id aa in [dic allValues]) {
           if ([aa isKindOfClass:[NSArray class]]&&component%2==1){
                NSArray *bb=aa;
                if (bb.count>row) {
                    rowTitle=aa[row];
                }
                
            }
        }
    }
    return rowTitle;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//
//    if (_isLevelDic&&component%2==0) {
//        [pickerView reloadComponent:1];
//        [pickerView selectRow:0 inComponent:1 animated:YES];
//    }
//    if (_isLevelString) {
//        _resultString = _plistArray[row];
//        _resultIndex = [NSString stringWithFormat:@"%ld",(long)row];
//
//    }else if (_isLevelArray){
//        _resultString=@"";
//        _resultIndex = @"";
//        if (![self.componentArray containsObject:@(component)]) {
//            [self.componentArray addObject:@(component)];
//        }
//        for (int i=0; i<_plistArray.count;i++) {
//            if ([self.componentArray containsObject:@(i)]) {
//                NSInteger cIndex = [pickerView selectedRowInComponent:i];
//                _resultString=[NSString stringWithFormat:@"%@%@",_resultString,_plistArray[i][cIndex]];
//                if (_resultIndex&&_resultIndex.length>0) {
//                    _resultIndex = [NSString stringWithFormat:@"%@,%ld",_resultIndex,(long)cIndex];
//                }else {
//                    _resultIndex = [NSString stringWithFormat:@"%ld",(long)cIndex];
//                }
//            }else{
//                _resultString=[NSString stringWithFormat:@"%@%@",_resultString,_plistArray[i][0]];
//                if (_resultIndex&&_resultIndex.length>0) {
//                    _resultIndex = [NSString stringWithFormat:@"%@,%d",_resultIndex,0];
//                }else {
//                    _resultIndex = [NSString stringWithFormat:@"%d",0];
//                }
//
//                          }
//        }
//    }else if (_isLevelDic){
//        if (component==0) {
//          _state =_dicKeyArray[row][0];
//        }else{
//            NSInteger cIndex = [pickerView selectedRowInComponent:0];
//            NSDictionary *dicValueDic=_plistArray[cIndex];
//            NSArray *dicValueArray=[dicValueDic allValues][0];
//            if (dicValueArray.count>row) {
//                _city =dicValueArray[row];
//            }
//        }
//    }
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if(_componentWidthBlock) {
       return _componentWidthBlock(component);
    }
    return 100;
}
#pragma mark - Action
#pragma mark - 移除控件
- (void)remove {
    [self.bgView removeFromSuperview];
    [self removeFromSuperview];
}

#pragma mark - 显示控件
- (void)show{
    [[UIApplication sharedApplication].keyWindow addSubview:self.bgView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}
#pragma mark - 确定按钮
- (void)doneClick {
    if (_isDatePicker) {
        if (_datePickerTemp && &_datePickerMode) {
            NSDateFormatter *dateFmt = [[NSDateFormatter alloc]init];
            switch (_datePickerMode) {
                case UIDatePickerModeTime:
                    dateFmt.dateFormat = @"HH:mm";
                    break;
                case UIDatePickerModeDate:
                    dateFmt.dateFormat = @"yyyy-MM-dd";
                    break;
                case UIDatePickerModeDateAndTime:
                    dateFmt.dateFormat = @"MM-dd EEE HH:mm";
                    break;
                case UIDatePickerModeCountDownTimer:
                    dateFmt.dateFormat = @"HH:mm";
                    break;
                    
                default:
                    break;
            }
            
            _resultString=[NSString stringWithFormat:@"%@",[dateFmt stringFromDate:_datePickerTemp.date]];
        }
    }else {
        if (_pickerView) {
            
            if (_resultString) {
                
            }else{
                if (_isLevelString) {
                    NSInteger row = [_pickerView selectedRowInComponent:0];
                    _resultString = [NSString stringWithFormat:@"%@",_plistArray[row]];
                    _resultIndex = [NSString stringWithFormat:@"%ld",(long)row];
                }else if (_isLevelArray){
                    _resultString=@"";
                    _resultIndex = nil;
                    for (int i=0; i<_plistArray.count;i++) {
                        NSInteger row = [_pickerView selectedRowInComponent:i];
                        _resultString=[NSString stringWithFormat:@"%@%@",_resultString,_plistArray[i][row]];
                        if (_resultIndex&&_resultIndex.length>0) {
                            _resultIndex = [NSString stringWithFormat:@"%@,%ld",_resultIndex,row];
                        }else {
                            _resultIndex = [NSString stringWithFormat:@"%ld",row];
                        }
                    }
                }else if (_isLevelDic){
                    
                    if (_state==nil) {
                        _state =_dicKeyArray[0][0];
                        NSDictionary *dicValueDic=_plistArray[0];
                        _city=[dicValueDic allValues][0][0];
                    }
                    if (_city==nil){
                        NSInteger cIndex = [_pickerView selectedRowInComponent:0];
                        NSDictionary *dicValueDic=_plistArray[cIndex];
                        _city=[dicValueDic allValues][0][0];
                        
                    }
                    _resultString=[NSString stringWithFormat:@"%@%@",_state,_city];
                }
            }
        }
    }
    if (_MyBolck) {
        _MyBolck(self,_resultString,[_pickerView selectedRowInComponent:0]);
        _MyBolck = nil;
    }
    if (_MyBolck2) {
        _MyBolck2(self,_resultString,_resultIndex);
        _MyBolck2 = nil;
    }
    if ([self.delegate respondsToSelector:@selector(toobarDonBtnHaveClick:resultString:resultIndex:)]) {
        [self.delegate toobarDonBtnHaveClick:self resultString:_resultString resultIndex:[_pickerView selectedRowInComponent:0]];
    }
    [self remove];
}

#pragma mark - 设置PickView的颜色

- (void)setPickViewBGColor:(UIColor *)pickViewBGColor {
    _pickViewBGColor = pickViewBGColor;
    self.pickerView.backgroundColor = _pickViewBGColor;
}

#pragma mark - 设置datePicker的背景色
- (void)setDatePickerBGColor:(UIColor *)datePickerBGColor {
    _datePickerBGColor = datePickerBGColor;
    self.datePickerTemp.backgroundColor = _datePickerBGColor;
}

#pragma mark - 设置toobar的文字颜色
- (void)setToolbarTextColor:(UIColor *)toolbarTextColor {
    _toolbarTextColor = toolbarTextColor;
    [self.leftBtn setTitleColor:toolbarTextColor forState:UIControlStateNormal];
    [self.rightBtn setTitleColor:toolbarTextColor forState:UIControlStateNormal];
    if (_titleLabel) {
        _titleLabel.textColor = toolbarTextColor;
    }
}

- (void)setToolbarLeftTextColor:(UIColor *)toolbarLeftTextColor {
    _toolbarLeftTextColor = toolbarLeftTextColor;
    [self.leftBtn setTitleColor:_toolbarLeftTextColor forState:UIControlStateNormal];
}

- (void)setToolbarRightTextColor:(UIColor *)toolbarRightTextColor {
    _toolbarRightTextColor = toolbarRightTextColor;
    [self.rightBtn setTitleColor:_toolbarRightTextColor forState:UIControlStateNormal];
}

- (void)setToolbarTitleTextColor:(UIColor *)toolbarTitleTextColor {
    _toolbarTitleTextColor = toolbarTitleTextColor;
    self.titleLabel.textColor = _toolbarTitleTextColor;
}

- (UIColor *)toolbarTextColor {
    if (!_toolbarTextColor) {
        _toolbarTextColor = [UIColor whiteColor];
    }
    return _toolbarTextColor;
}

#pragma mark - 设置toobar的背景颜色
- (void)setToolbarBGColor:(UIColor *)toolbarBGColor {
    _toolbarBGColor = toolbarBGColor;
    self.toolbar.barTintColor = _toolbarBGColor;
}

- (UIDatePicker *)datePicker {
    return _datePickerTemp;
}

#pragma mark - Properties

- (NSArray *)plistArray{
    if (!_plistArray) {
        _plistArray=[[NSArray alloc] init];
    }
    return _plistArray;
}

#pragma mark - 背景遮罩
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
        _bgView.tag = 999;
        _bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];;
    }
    return _bgView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tag = 999;
    }
    return self;
}

- (NSArray *)getPlistArrayByplistName:(NSString *)plistName{
    NSString *path= [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    NSArray * array=[[NSArray alloc] initWithContentsOfFile:path];
    [self setArrayClass:array];
    return array;
}

- (void)setArrayClass:(NSArray *)array{
    _dicKeyArray=[[NSMutableArray alloc] init];
    for (id levelTwo in array) {
        
        if ([levelTwo isKindOfClass:[NSArray class]]) {
            _isLevelArray=YES;
            _isLevelString=NO;
            _isLevelDic=NO;
        }else if ([levelTwo isKindOfClass:[NSString class]]) {
            _isLevelString=YES;
            _isLevelArray=NO;
            _isLevelDic=NO;
            
        }else if ([levelTwo isKindOfClass:[NSDictionary class]]) {
            _isLevelDic=YES;
            _isLevelString=NO;
            _isLevelArray=NO;
            _levelTwoDic=levelTwo;
            [_dicKeyArray addObject:[_levelTwoDic allKeys] ];
        }
    }
}

- (void)setFrameWith:(BOOL)isHaveNavControler{
    CGFloat toolViewX = 0;
    CGFloat toolViewH = _pickeviewHeight+ToobarHeight;
    CGFloat toolViewY ;
    if (isHaveNavControler) {
        toolViewY= [UIScreen mainScreen].bounds.size.height-toolViewH-50;
    }else {
        toolViewY= [UIScreen mainScreen].bounds.size.height-toolViewH;
    }
    CGFloat toolViewW = [UIScreen mainScreen].bounds.size.width;
    self.frame = CGRectMake(toolViewX, toolViewY, toolViewW, toolViewH);
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.frame = CGRectMake(0, ToobarHeight, [UIScreen mainScreen].bounds.size.width, _pickerView.frame.size.height);
        _pickeviewHeight = _pickerView.frame.size.height;
    }
    if (_datePickerTemp)[_datePickerTemp removeFromSuperview];
    [self addSubview:_pickerView];
    return _pickerView;
}

- (UIDatePicker *)datePickerTemp {
    if (!_datePickerTemp) {
        _datePickerTemp = [[UIDatePicker alloc]init];
        _datePickerTemp.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        _datePickerTemp.backgroundColor=[UIColor whiteColor];
        _datePickerTemp.frame = CGRectMake(0, ToobarHeight,[[UIScreen mainScreen]bounds].size.width , _datePickerTemp.frame.size.height);
        _pickeviewHeight = _datePickerTemp.frame.size.height;
    }
    if (_pickerView)[_pickerView removeFromSuperview];
    [self addSubview:_datePickerTemp];
    return _datePickerTemp;
}

- (UIToolbar *)toolbar {
    if (!_toolbar) {
        _toolbar = [[UIToolbar alloc] init];
        _toolbar.frame = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, ToobarHeight);
        UIBarButtonItem *lefttem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn];
        UIBarButtonItem *centerSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *righttem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
        _toolbar.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.000];
        _toolbar.items=@[lefttem,centerSpace,righttem];
        [self addSubview:_toolbar];
    }
    return _toolbar;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    if (_title.length>0) {
        self.titleLabel.text = title;
        [self.toolbar addSubview:self.titleLabel];
    }
}

- (UIButton *)leftBtn {
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(0, 0, 100, 44);
        _leftBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_leftBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_leftBtn setTitleColor:self.toolbarTextColor forState:UIControlStateNormal];
        [_leftBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBtn;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(0, 0, 100, 44);
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_rightBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_rightBtn setTitleColor:self.toolbarTextColor forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        CGFloat screenWidth = [[UIScreen mainScreen]bounds].size.width;
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(100,0,screenWidth-200,ToobarHeight)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = self.toolbarTextColor;
        _titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _titleLabel;
}

@end

