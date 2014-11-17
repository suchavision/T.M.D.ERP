#import "PurchaseBillCell.h"
#import "AppInterface.h"

@interface PurchaseBillCell()<UITextFieldDelegate>

@property(nonatomic, strong) JRTextField* productCodeTxtField;
@property(nonatomic, strong) JRTextField* productNameTxtField;
@property(nonatomic, strong) JRTextField* amountTxtField;
@property(nonatomic, strong) JRTextField* lastUnitPrice;
@property(nonatomic, strong) JRTextField* unitTxtField;
@property(nonatomic, strong) JRTextField* unitPriceTxtField;
@property(nonatomic, strong) JRTextField* subTotalTxtField;

@end

@implementation PurchaseBillCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
         __weak PurchaseBillCell* weakSelf = self;
        
        _productCodeTxtField  = [[JRTextField alloc] initWithFrame:CanvasRect(0, 0, 160, 50)];
        _productCodeTxtField.attribute = attr_productCode;
        _productNameTxtField  = [[JRTextField alloc] initWithFrame:CanvasRect(190, 0, 200, 50)];
        _productNameTxtField.attribute = attr_productName;
        _amountTxtField    = [[JRTextField alloc] initWithFrame:CanvasRect(425, 0, 120, 50)];
        _amountTxtField.attribute = attr_amount;
        _unitTxtField   = [[JRTextField alloc] initWithFrame:CanvasRect(548, 0, 90, 50)];
        _unitTxtField.attribute = attr_unit;
        _unitPriceTxtField  = [[JRTextField alloc] initWithFrame:CanvasRect(616, 0, 120, 50)];
        _unitPriceTxtField.attribute = attr_unitPrice;
        _lastUnitPrice = [[JRTextField alloc] initWithFrame:CanvasRect(762, 0, 70, 50)];
        _lastUnitPrice.attribute = attr_lastUnitPrice;
        _subTotalTxtField  = [[JRTextField alloc] initWithFrame:CanvasRect(785, 0, 175, 50)];
        _productCodeTxtField.textAlignment = NSTextAlignmentCenter;
        _productNameTxtField.textAlignment = NSTextAlignmentCenter;
        _amountTxtField.textAlignment = NSTextAlignmentCenter;
        _unitTxtField.textAlignment = NSTextAlignmentCenter;
        _unitPriceTxtField.textAlignment = NSTextAlignmentCenter;
        _subTotalTxtField.textAlignment = NSTextAlignmentCenter;
        
        // when end editing , update the datasource
        _productCodeTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _productNameTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _amountTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _unitTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _unitPriceTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _subTotalTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        
        _productNameTxtField.delegate = self;
        _amountTxtField.delegate = self;
        _unitTxtField.delegate = self;
        _unitPriceTxtField.delegate = self;
        
        [self.contentView addSubview:_productCodeTxtField];
        [self.contentView addSubview:_productNameTxtField];
        [self.contentView addSubview:_amountTxtField];
        [self.contentView addSubview:_unitTxtField];
        [self.contentView addSubview:_unitPriceTxtField];
        [self.contentView addSubview:_subTotalTxtField];
        [self.contentView addSubview:_lastUnitPrice];
      
        
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
    __weak PurchaseBillCell* weakSelf = self;
    __weak JRTextField *_weakProductNameTxtField =  _productNameTxtField;
    
    _productCodeTxtField.textFieldDidClickAction = ^(JRTextField* jrTextField){
        
        NSArray* needFields = @[@"productCode",@"productName"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_WHInventory fields:needFields ];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            
            NSArray* array = [filterTableView realContentForIndexPath: realIndexPath];
            
            NSString* productCode = [array objectAtIndex:1];
            jrTextField.text = productCode;
            
            _weakProductNameTxtField.text = [array objectAtIndex:2];
            
            weakSelf.didEndEditNewCellAction(weakSelf);
            
            [PickerModelTableView dismiss];
        };
    };

}
-(void)setDatas:(id)cotents
{
    [super setDatas:cotents];
     _subTotalTxtField.text = nil;
    
    if (OBJECT_EMPYT(_amountTxtField.text) || OBJECT_EMPYT(_unitPriceTxtField.text)) return;
    
    float finalValue = [_amountTxtField.text floatValue] *[_unitPriceTxtField.text floatValue];
    NSString *finalValueString = [[NSNumber numberWithFloat:finalValue] stringValue];
//    NSString *finalValueString = [NSString stringWithFormat:@"%.2f",finalValue];
    _subTotalTxtField.text = finalValueString;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
