//
//  FinanceReceiptBill.m
//  T.M.D.ERP
//
//  Created by wudonghui on 11/11/14.
//  Copyright (c) 2014 Xinyuan4. All rights reserved.
//
#define attr_receiptOrderNO             @"receiptOrderNO"
#define attr_productName             @"productName"
#define attr_shouldReceive           @"shouldReceive"
#define attr_realReceive               @"realReceive"
#define attr_notReceive              @"notReceive"
#import "FinanceReceiptBill.h"
#import "AppInterface.h"
@interface FinanceReceiptBill()
@property(nonatomic, strong) JRTextField* receiptOrderNOTxtField;
@property(nonatomic, strong) JRTextField* productNameTxtField;
@property(nonatomic, strong) JRTextField* shouldReceiveTxtField;
@property(nonatomic, strong) JRTextField* realReceiveTxtField;
@property(nonatomic, strong) JRTextField* notReceiveTxtFieldOne;
@end
@implementation FinanceReceiptBill
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        __weak FinanceReceiptBill* weakSelf = self;
        
        _receiptOrderNOTxtField  = [[JRTextField alloc] initWithFrame:CanvasRect(0, 0, 178, 50)];
        _receiptOrderNOTxtField.attribute = attr_receiptOrderNO;
        _productNameTxtField  = [[JRTextField alloc] initWithFrame:CanvasRect(178, 0, 172, 50)];
        _productNameTxtField.attribute = attr_productName;
        _shouldReceiveTxtField    = [[JRTextField alloc] initWithFrame:CanvasRect(350, 0, 112, 50)];
        _shouldReceiveTxtField.attribute = attr_shouldReceive;
        _realReceiveTxtField   = [[JRTextField alloc] initWithFrame:CanvasRect(462, 0, 110, 50)];
        _realReceiveTxtField.attribute = attr_realReceive;
        _notReceiveTxtFieldOne  = [[JRTextField alloc] initWithFrame:CanvasRect(572, 0, 108, 50)];
        
    
        
        _receiptOrderNOTxtField.textAlignment = NSTextAlignmentCenter;
        _productNameTxtField.textAlignment = NSTextAlignmentCenter;
        _shouldReceiveTxtField.textAlignment = NSTextAlignmentCenter;
        _realReceiveTxtField.textAlignment = NSTextAlignmentCenter;
        _notReceiveTxtFieldOne.textAlignment = NSTextAlignmentCenter;
    
        
        // when end editing , update the datasource
        _receiptOrderNOTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _productNameTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _shouldReceiveTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _realReceiveTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _notReceiveTxtFieldOne.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        
        
        [self.contentView addSubview:_receiptOrderNOTxtField];
        [self.contentView addSubview:_productNameTxtField];
        [self.contentView addSubview:_shouldReceiveTxtField];
        [self.contentView addSubview:_realReceiveTxtField];
        [self.contentView addSubview:_notReceiveTxtFieldOne];
            
        
        [self setValidatorTextField];
        self.backgroundColor = [UIColor clearColor];
        
        [ViewHelper iterateSubView: self.contentView class:[JRTextField class] handler:^BOOL(id subView) {
            JRTextField* tx = (JRTextField*) subView;
            tx.enabled = YES;
            return NO;
        }];
        
        
    }
    return self;
}
-(void)setValidatorTextField
{
    __weak JRTextField *_weakProductNameTxtField =  _productNameTxtField;
    _receiptOrderNOTxtField.textFieldDidClickAction = ^(JRTextField* jrTextField){
        
        NSArray* needFields = @[@"productCode",@"productName"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_WHInventory fields:needFields ];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            
            NSArray* array = [filterTableView realContentForIndexPath: realIndexPath];
            jrTextField.text = [array objectAtIndex:1];
            _weakProductNameTxtField.text = [array objectAtIndex:2];
            
            
            [PickerModelTableView dismiss];
        };
    };
    
}

-(void)setDatas:(id)cotents
{
    [super setDatas:cotents];
    _notReceiveTxtFieldOne.text = nil;
    
    if (OBJECT_EMPYT(_shouldReceiveTxtField.text) || OBJECT_EMPYT(_realReceiveTxtField.text)) return;
    float finalValue = [_shouldReceiveTxtField.text floatValue] - [_realReceiveTxtField.text floatValue];
    NSString *finalValueString = [[NSNumber numberWithFloat:finalValue] stringValue];
    _notReceiveTxtFieldOne.text = finalValueString;
}


@end
