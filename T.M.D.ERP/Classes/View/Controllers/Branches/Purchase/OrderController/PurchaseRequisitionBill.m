#import "PurchaseRequisitionBill.h"
#import "AppInterface.h"
@interface PurchaseRequisitionBill()<UITextFieldDelegate>
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
    
    
    __weak PurchaseRequisitionBill* weakInstance = self;
    __weak JRTextField *weakProductName = _productNameTxtField;
    __weak JRTextField *weakProductCode = _productCodeTxtField;
    _productCodeTxtField.textFieldDidClickAction = ^(JRTextField* jrTextField){
        weakProductName.userInteractionEnabled = NO;
        NSArray* needFields = @[@"productCode",@"productName",@"basicUnit",@"unit"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_WHInventory fields:needFields];
        pickView.tableView.headersXcoordinates =  @[@(30), @(300),@(700),@(800)];
        
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            NSArray* array = [filterTableView realContentForIndexPath: realIndexPath];
            
            
            UITableView* tableView = [TableViewHelper getTableViewBySubView: weakInstance];
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
        
        UITableView* tableView = [TableViewHelper getTableViewBySubView: weakInstance];
        NSIndexPath* ownerIndexPath = [tableView indexPathForCell: weakInstance];
        NSMutableDictionary* cellContentDictionary = [weakInstance.requisitionTableViewDataSource safeObjectAtIndex: ownerIndexPath.row];
        
        NSString* productCode = cellContentDictionary[@"productCode"];
        if([productCode isEqualToString:@""]) {
            JRButtonsHeaderTableView* popTableView = [PopupTableHelper popTableView:LOCALIZE_KEY(@"unit") keys:nil selectedAction:^(JRButtonsHeaderTableView *sender, NSUInteger selectedIndex, NSString *selectedVisualValue) {
                [jrTextField setValue: selectedVisualValue];
                
                
                UITableView* tableView = [TableViewHelper getTableViewBySubView: weakInstance];
                NSIndexPath* ownerIndexPath = [tableView indexPathForCell: weakInstance];
                NSMutableDictionary* cellContentDictionary = [weakInstance.requisitionTableViewDataSource safeObjectAtIndex: ownerIndexPath.row];
                if (!cellContentDictionary) {
                    cellContentDictionary = [NSMutableDictionary dictionary];
                    [weakInstance.requisitionTableViewDataSource addObject: cellContentDictionary];
                }
                [cellContentDictionary setObject: selectedVisualValue forKey:attr_unit];
                [tableView reloadData];
                
            }];
            
            
            popTableView.rightButton.hidden = NO;
            [popTableView.rightButton setTitle:LOCALIZE_KEY(@"ADD") forState:UIControlStateNormal];
            __weak TableViewBase* weakTableView = popTableView.tableView.tableView;
            
            NSMutableDictionary* datasources = [NSMutableDictionary dictionary];
            NSMutableArray* array = [NSMutableArray array];
            [datasources setObject: array forKey:@""];
            weakTableView.contentsDictionary = datasources;
            
            popTableView.rightButton.didClikcButtonAction = ^void(JRButton* btn) {
                NSString* addNewmessage = LOCALIZE_KEY(@"addNewUnit");
                [PopupViewHelper popAlert: addNewmessage message:nil style:UIAlertViewStylePlainTextInput actionBlock:^(UIView *popView, NSInteger index) {
                    UIAlertView* alertView = (UIAlertView*)popView;
                    NSString* newUnitString = [alertView textFieldAtIndex: 0].text;
                    [array addObject: newUnitString];
                    
                    [weakTableView reloadData];
                    
                } dismissBlock:nil buttons:LOCALIZE_KEY(@"CANCEL"), LOCALIZE_KEY(@"OK"), nil];
            };
            JRButton *cancleButton = popTableView.leftButton;
            cancleButton.hidden = NO;
            cancleButton.didClikcButtonAction = ^void(JRButton *btn){
                [PopupTableHelper dissmissCurrentPopTableView];
            };
            
        }
        RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
        requestModel.path = PATH_LOGIC_READ(DEPARTMENT_WAREHOUSE);
        [requestModel addModel: MODEL_WHInventory];
        [requestModel addObject: @{@"productCode": productCode}];
        [requestModel.fields addObject:@[@"basicUnit", @"unit",@"amount",]];
        [MODEL.requester startPostRequest: requestModel completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
            
            NSArray* results = response.results;
            
            NSArray *uinits = [[results firstObject] firstObject];
            
            if(uinits){
            NSString *basicUnitString = [uinits objectAtIndex:0];
            NSString *unitString = [uinits objectAtIndex:1];
            NSArray *myArray = [NSArray arrayWithObjects:basicUnitString,unitString, nil];
            NSNumber *amountNumber = [uinits objectAtIndex:2];
            NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
            NSString *amountString = [numberFormatter stringFromNumber:amountNumber];
            NSArray *array = [NSArray arrayWithObject:basicUnitString];
            if([amountString isEqualToString:@"1"]){
                myArray = array;
            }
            
            [PopupTableHelper popTableView:LOCALIZE_KEY(@"unit") keys:myArray selectedAction:^(JRButtonsHeaderTableView *sender, NSUInteger selectedIndex, NSString *selectedVisualValue) {
                
                [jrTextField setValue:selectedVisualValue];
                NSIndexPath* ownerIndexPath = [tableView indexPathForCell: weakInstance];
                NSMutableDictionary* cellContentDictionary = [weakInstance.requisitionTableViewDataSource safeObjectAtIndex: ownerIndexPath.row];
                [cellContentDictionary setObject: selectedVisualValue forKey:jrTextField.attribute];
                [tableView reloadData];
                
            }];
                
                
            }

        }];
        
        
        
        
    };
}



@end
