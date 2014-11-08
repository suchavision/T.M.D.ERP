#import "PurchaseRequisitionBill.h"
#import "AppInterface.h"
@interface PurchaseRequisitionBill()
@property(nonatomic, strong) JRTextField* productCodeTxtField;
@property(nonatomic, strong) JRTextField* productNameTxtField;
@property(nonatomic, strong) JRTextField* amountTxtField;
@property(nonatomic, strong) JRTextField* unitTxtField;
@property(nonatomic, strong) JRTextField* unitPriceTxtFieldOne;
@property(nonatomic, strong) JRTextField* unitPriceTxtFieldTwo;
@property(nonatomic, strong) JRTextField* unitPriceTxtFieldThree;
@end

@implementation PurchaseRequisitionBill

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        __weak PurchaseRequisitionBill* weakSelf = self;
        
        _productCodeTxtField  = [[JRTextField alloc] initWithFrame:CanvasRect(0, 0, 153, 50)];
        _productCodeTxtField.attribute = attr_productCode;
        _productNameTxtField  = [[JRTextField alloc] initWithFrame:CanvasRect(155, 0, 188, 50)];
        _productNameTxtField.attribute = attr_productName;
        _amountTxtField    = [[JRTextField alloc] initWithFrame:CanvasRect(345, 0, 100, 50)];
        _amountTxtField.attribute = attr_amount;
        _unitTxtField   = [[JRTextField alloc] initWithFrame:CanvasRect(445, 0, 115, 50)];
        _unitTxtField.attribute = attr_unit;
        _unitPriceTxtFieldOne  = [[JRTextField alloc] initWithFrame:CanvasRect(560, 0, 110, 50)];
        _unitPriceTxtFieldOne.attribute = attr_unitPriceOne;
        _unitPriceTxtFieldTwo  = [[JRTextField alloc] initWithFrame:CanvasRect(670, 0, 130, 50)];
        _unitPriceTxtFieldTwo.attribute = attr_unitPriceTwo;
        _unitPriceTxtFieldThree  = [[JRTextField alloc] initWithFrame:CanvasRect(800, 0, 125, 50)];
        _unitPriceTxtFieldThree.attribute = attr_unitPriceThree;

        _productCodeTxtField.textAlignment = NSTextAlignmentCenter;
        _productNameTxtField.textAlignment = NSTextAlignmentCenter;
        _amountTxtField.textAlignment = NSTextAlignmentCenter;
        _unitTxtField.textAlignment = NSTextAlignmentCenter;
        _unitPriceTxtFieldOne.textAlignment = NSTextAlignmentCenter;
        _unitPriceTxtFieldTwo.textAlignment = NSTextAlignmentCenter;
        _unitPriceTxtFieldThree.textAlignment = NSTextAlignmentCenter;
        
        
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
        _unitPriceTxtFieldOne.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _unitPriceTxtFieldTwo.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _unitPriceTxtFieldThree.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };


        
        
        [self.contentView addSubview:_productCodeTxtField];
        [self.contentView addSubview:_productNameTxtField];
        [self.contentView addSubview:_amountTxtField];
        [self.contentView addSubview:_unitTxtField];
        [self.contentView addSubview:_unitPriceTxtFieldOne];
        [self.contentView addSubview:_unitPriceTxtFieldTwo];
        [self.contentView addSubview:_unitPriceTxtFieldThree];
        
        [ColorHelper setBorder: _productCodeTxtField];
        [ColorHelper setBorder: _productNameTxtField];
        [ColorHelper setBorder: _amountTxtField];
        [ColorHelper setBorder: _unitTxtField];
        [ColorHelper setBorder: _unitPriceTxtFieldOne];
        [ColorHelper setBorder: _unitPriceTxtFieldTwo];
        [ColorHelper setBorder:_unitPriceTxtFieldThree];
        

        
        [self setValidatorTextField];
        self.backgroundColor = [UIColor clearColor];
        
        [ViewHelper iterateSubView: self.contentView class:[JRTextField class] handler:^BOOL(id subView) {
            JRTextField* tx = (JRTextField*) subView;
            [ColorHelper setBorder:subView];
            tx.enabled = YES;
            return NO;
        }];
        
        
    }
    return self;
}

-(void)setValidatorTextField
{
    
    
    __weak PurchaseRequisitionBill* weakInstance = self;
    _productCodeTxtField.textFieldDidClickAction = ^(JRTextField* jrTextField){
        
        NSArray* needFields = @[@"productCode",@"productName",@"basicUnit",@"unit"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_WHInventory fields:needFields];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            NSArray* array = [filterTableView realContentForIndexPath: realIndexPath];
            
            
            UITableView* tableView = [weakInstance getTableView];
            NSIndexPath* ownerIndexPath = [tableView indexPathForCell: weakInstance];
            NSMutableDictionary* cellContentDictionary = [weakInstance.requisitionTableViewDataSource safeObjectAtIndex: ownerIndexPath.row];
            if (!cellContentDictionary) {
                cellContentDictionary = [NSMutableDictionary dictionary];
                [weakInstance.requisitionTableViewDataSource addObject: cellContentDictionary];
            }
            
            [cellContentDictionary setObject:array[1] forKey:@"productCode"];
            [cellContentDictionary setObject:array[2] forKey:@"productName"];
            
            [tableView reloadData];
            
            [PickerModelTableView dismiss];
            
        };
        
    };
    _unitTxtField.textFieldDidClickAction = ^(JRTextField *jrTextField) {
        
        UITableView* tableView = [weakInstance getTableView];
        NSIndexPath* ownerIndexPath = [tableView indexPathForCell: weakInstance];
        NSMutableDictionary* cellContentDictionary = [weakInstance.requisitionTableViewDataSource safeObjectAtIndex: ownerIndexPath.row];
        
        NSString* productCode = cellContentDictionary[@"productCode"];
        
        
        RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
        requestModel.path = PATH_LOGIC_READ(DEPARTMENT_WAREHOUSE);
        [requestModel addModel: MODEL_WHInventory];
        [requestModel addObject: @{@"productCode": productCode}];
        [requestModel.fields addObject:@[@"basicUnit", @"unit"]];
        [MODEL.requester startPostRequest: requestModel completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
            
            NSArray* results = response.results;
            NSArray *uinits = [[results firstObject] firstObject];
            
            [PopupTableHelper popTableView:nil keys:uinits selectedAction:^(JRButtonsHeaderTableView *sender, NSUInteger selectedIndex, NSString *selectedVisualValue) {
                [jrTextField setValue: selectedVisualValue];
            }];
            
        }];
        
        
        
        
    };
}


-(UITableView*) getTableView
{
    UITableView* tableView = (UITableView*)self.superview;
    while (tableView && ![tableView isKindOfClass:[UITableView class]]) {
        tableView = (UITableView*)tableView.superview;
    }
    return tableView;
}


//-(void)setDatas:(id)cotents
//{
//    [super setDatas:cotents];
//    _subTotalTxtField.text = nil;
//    
//    if (OBJECT_EMPYT(_amountTxtField.text) || OBJECT_EMPYT(_unitPriceTxtField.text)) return;
//    
//    float finalValue = [_amountTxtField.text floatValue] *[_unitPriceTxtField.text floatValue];
//    NSString *finalValueString = [[NSNumber numberWithFloat:finalValue] stringValue];
//    //    NSString *finalValueString = [NSString stringWithFormat:@"%.2f",finalValue];
//    _subTotalTxtField.text = finalValueString;
//}



@end
