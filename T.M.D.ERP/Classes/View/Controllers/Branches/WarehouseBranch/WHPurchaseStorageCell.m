#import "WHPurchaseStorageCell.h"
#import "AppInterface.h"


@interface WHPurchaseStorageCell()<UITextFieldDelegate>

@property(nonatomic, strong) JRTextField* codeTxtField;
@property(nonatomic, strong) JRTextField* nameTxtField;
@property(nonatomic, strong) JRTextField* qcTxtField;
@property(nonatomic, strong) JRTextField* numTxtField;
@property(nonatomic, strong) JRTextField* unitTxtField;
@property(nonatomic, strong) JRTextField* unitPriceTxtField;
@property(nonatomic, strong) JRTextField* subTotalTxtField;

@property(nonatomic, strong) JRTextField* storageNumTxtField;
@property(nonatomic, strong) JRTextField* storageUnitTxtField;
@property(nonatomic, strong) JRTextField* storageUnitPriceTxtField;
@property(nonatomic, strong) JRTextField* storageSubTotalTxtField;


@end


@implementation WHPurchaseStorageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        __weak WHPurchaseStorageCell *weakSelf = self;
        _codeTxtField  = [[JRTextField alloc] init];
        
        _nameTxtField  = [[JRTextField alloc] init];
        
        _qcTxtField    = [[JRTextField alloc] init];
        
        _numTxtField   = [[JRTextField alloc] init];
        
        _unitTxtField  = [[JRTextField alloc] init];
        
        _unitPriceTxtField = [[JRTextField alloc] init];
        
        _subTotalTxtField  = [[JRTextField alloc] init];
        
        _storageNumTxtField  = [[JRTextField alloc] init];
        
        _storageUnitTxtField = [[JRTextField alloc] init];
        
        _storageUnitPriceTxtField = [[JRTextField alloc] init];
        
        _storageSubTotalTxtField  = [[JRTextField alloc] init];
        
        
        // when end editing , update the datasource
        _codeTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _nameTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _qcTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _numTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
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
        _storageNumTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _storageUnitTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _storageUnitPriceTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };
        _storageSubTotalTxtField.textFieldDidEndEditingBlock = ^void(UITextField* tx, NSString* oldText) {
            weakSelf.didEndEditNewCellAction(weakSelf);
        };

        
        [self.contentView addSubview:_codeTxtField];
        [self.contentView addSubview:_nameTxtField];
        [self.contentView addSubview:_qcTxtField];
        [self.contentView addSubview:_numTxtField];
        [self.contentView addSubview:_unitTxtField];
        [self.contentView addSubview:_unitPriceTxtField];
        [self.contentView addSubview:_subTotalTxtField];
        [self.contentView addSubview:_storageNumTxtField];
        [self.contentView addSubview:_storageUnitTxtField];
        [self.contentView addSubview:_storageUnitPriceTxtField];
        [self.contentView addSubview:_storageSubTotalTxtField];
        
        self.backgroundColor = [UIColor clearColor];
        
        [super renderCellSubView:@"WHPurchaseOrder"];
        
        [self setValidatorTextField];
        
    }
    return self;
}

-(void)setValidatorTextField
{
    _numTxtField.inputValidator = [[NumericInputValidator alloc]init];
    _numTxtField.inputValidator.errorMsg = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(@"WHPurchaseOrder", _numTxtField.attribute));
    
    _unitPriceTxtField.inputValidator = [[NumericInputValidator alloc]init];
    _unitPriceTxtField.inputValidator.errorMsg = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(@"WHPurchaseOrder", _unitPriceTxtField.attribute));
    
    _storageNumTxtField.inputValidator = [[NumericInputValidator alloc]init];
    _storageNumTxtField.inputValidator.errorMsg = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(@"WHPurchaseOrder", _storageNumTxtField.attribute));
    
    _storageUnitPriceTxtField.inputValidator = [[NumericInputValidator alloc]init];
    _storageUnitPriceTxtField.inputValidator.errorMsg = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(@"WHPurchaseOrder", _storageUnitPriceTxtField.attribute));
    
    
    __weak WHPurchaseStorageCell* weakInstance = self;
    _codeTxtField.textFieldDidClickAction = ^(JRTextField* jrTextField){
        
        NSArray* needFields = @[@"productCode",@"productName",@"basicUnit",@"unit"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_WHInventory fields:needFields];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            NSArray* array = [filterTableView realContentForIndexPath: realIndexPath];
            
            
            UITableView* tableView = [TableViewHelper getTableViewBySubView: jrTextField];
            NSIndexPath* ownerIndexPath = [tableView indexPathForCell: weakInstance];
            NSMutableDictionary* cellContentDictionary = [weakInstance.middleTableViewDataSource safeObjectAtIndex: ownerIndexPath.row];
            if (!cellContentDictionary) {
                cellContentDictionary = [NSMutableDictionary dictionary];
                [weakInstance.middleTableViewDataSource addObject: cellContentDictionary];
            }
            
            [cellContentDictionary setObject:array[1] forKey:@"productCode"];
            [cellContentDictionary setObject:array[2] forKey:@"productName"];
            
            [tableView reloadData];
            
            [PickerModelTableView dismiss];
            
            };
        
    };
    _storageUnitTxtField.textFieldDidClickAction = ^(JRTextField *jrTextField) {
        
        UITableView* tableView = [TableViewHelper getTableViewBySubView: jrTextField];
        NSIndexPath* ownerIndexPath = [tableView indexPathForCell: weakInstance];
        NSMutableDictionary* cellContentDictionary = [weakInstance.middleTableViewDataSource safeObjectAtIndex: ownerIndexPath.row];
        
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



-(void)setDatas:(id)cotents
{
    [super setDatas:cotents];
    _subTotalTxtField.text = nil;
    _storageSubTotalTxtField.text = nil;

    
    if (!(OBJECT_EMPYT(_numTxtField.text) || OBJECT_EMPYT(_unitPriceTxtField.text))) {
        _subTotalTxtField.text = [AppMathUtility calculateMultiply:_numTxtField.text,_unitPriceTxtField.text,nil];
    }
    
    if (!(OBJECT_EMPYT(_storageNumTxtField.text) || OBJECT_EMPYT(_storageUnitPriceTxtField.text))) {
        _storageSubTotalTxtField.text= [AppMathUtility calculateMultiply:_storageNumTxtField.text,_storageUnitPriceTxtField.text,nil];
    }
    
}


@end
