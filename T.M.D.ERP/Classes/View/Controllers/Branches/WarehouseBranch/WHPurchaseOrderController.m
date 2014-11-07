#import "WHPurchaseOrderController.h"
#import "AppInterface.h"

#import "WHPurchaseStorageCell.h"
#import "WHPurchaseBillCell.h"


@interface WHPurchaseOrderController ()
{
    JRRefreshTableView* _purchaseTableView;
    
    JRRefreshTableView *_purchaseFooterTableView;
    NSMutableArray *_purchaseFooterCellContents;
    
    JRTextField* _deliveryTotalTxtField;
    JRTextField* _storageTotalTxtField;
    
}

@end


@implementation WHPurchaseOrderController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _middleTableViewDataSource = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak WHPurchaseOrderController* weakSelf = self;
    __block WHPurchaseOrderController* blockSelf = self;
    
    
    
    JRLabelCommaTextFieldView *contact = (JRLabelCommaTextFieldView *)[self.jsonView getView:@"NESTED_TOP.NESTED_top_middle.contact"];
    JRTextField *contactTextField = contact.textField;
    JRLabelCommaTextFieldView *phoneNO = (JRLabelCommaTextFieldView *)[self.jsonView getView:@"NESTED_TOP.NESTED_top_right.phoneNO"];
    JRTextField *phoneNoTextField = phoneNO.textField;
    JRLabelCommaTextFieldView *vendor = (JRLabelCommaTextFieldView *)[self.jsonView getView:@"NESTED_TOP.NESTED_top_left.vendorName"];
    JRTextField *vendorTextFiled = vendor.textField;
    vendorTextFiled.textFieldDidClickAction = ^void(JRTextField* textField) {
        NSArray* needFields = @[@"name", @"principal",@"phoneNO"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_VENDOR  fields:needFields criterias:nil];
        pickView.tableView.headersXcoordinates = @[@(0), @(200), @(400)];
        // when select
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            NSArray *array = [filterTableView realContentForIndexPath:realIndexPath];
            
            NSString* vendorNameValue = [array objectAtIndex:1];
            NSString* contacterValue = [array objectAtIndex:2];
            NSString* phoneNoValue = [array objectAtIndex:3];
            [textField setValue: vendorNameValue];
            [contactTextField setValue:contacterValue];
            [phoneNoTextField setValue:phoneNoValue];
            [PickerModelTableView dismiss];
        };
        
    };

    
    _deliveryTotalTxtField = ((JRLabelCommaTextFieldView*)[self.jsonView getView:@"NESTED_Middle_bottom.deliveryTotal"]).textField;
    _storageTotalTxtField = ((JRLabelCommaTextFieldView*)[self.jsonView getView:@"NESTED_Middle_bottom.storageTotal"]).textField;
   
    _purchaseTableView = (JRRefreshTableView*)[self.jsonView getView:@"NESTED_Middle_top.TABLE_Purchase"];
    _purchaseTableView.tableView.tableViewBaseNumberOfSectionsAction = ^NSInteger(TableViewBase* tableViewObje){
        return 1;
    };
    _purchaseTableView.tableView.tableViewBaseNumberOfRowsInSectionAction = ^NSInteger(TableViewBase* tableViewObj, NSInteger section) {
        return weakSelf.controlMode == JsonControllerModeCreate ? blockSelf->_middleTableViewDataSource.count + 1 : blockSelf->_middleTableViewDataSource.count;
    };
    _purchaseTableView.tableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath, UITableViewCell* oldCell) {
        static NSString *CellIdentifier = @"Cell";
        WHPurchaseStorageCell* cell = [tableViewObj dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[WHPurchaseStorageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.middleTableViewDataSource = weakSelf.middleTableViewDataSource;
            cell.didEndEditNewCellAction = ^void(BaseJRTableViewCell* cell){
                WHPurchaseStorageCell* purchaseCell = (WHPurchaseStorageCell*)cell;
                NSIndexPath* indexPath = [tableViewObj indexPathForCell: purchaseCell];
                int row = indexPath.row;
                if (row == blockSelf->_middleTableViewDataSource.count) {
                    [blockSelf->_middleTableViewDataSource addObject:[cell getDatas]];
                } else {
                    [blockSelf->_middleTableViewDataSource replaceObjectAtIndex:row withObject:[cell getDatas]];
                }
                
                [tableViewObj reloadData];
                [tableViewObj scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            };
        }
        [cell setDatas: [blockSelf->_middleTableViewDataSource safeObjectAtIndex: indexPath.row]];
        [weakSelf refreshTotal];
    
        return cell;
    };
    
    _purchaseFooterTableView = (JRRefreshTableView*)[self.jsonView getView:@"NESTED_Bottom.TABLE_Pay"];
    _purchaseFooterTableView.tableView.tableViewBaseNumberOfSectionsAction = ^NSInteger(TableViewBase* tableViewObje){
        return 1;
    };
    _purchaseFooterTableView.tableView.tableViewBaseNumberOfRowsInSectionAction = ^NSInteger(TableViewBase* tableViewObj, NSInteger section) {
        return [blockSelf->_purchaseFooterCellContents count];
    };
    _purchaseFooterTableView.tableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath, UITableViewCell* oldCell) {
        static NSString *CellIdentifier2 = @"Cell2";
        WHPurchaseBillCell* cell = [tableViewObj dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (cell == nil) {
            cell = [[WHPurchaseBillCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
        }
        [cell setDatas: [blockSelf->_purchaseFooterCellContents safeObjectAtIndex: indexPath.row]];
        return cell;
    };
    
    
    JRLabelCommaTextFieldView *payWayTextView = (JRLabelCommaTextFieldView *)[self.jsonView getView:@"NESTED_top_middle.payMode"];
    [FinancePaymentOrderController popPayWayTable: payWayTextView.textField selectedAction:nil];

    
}

#pragma mark -
#pragma mark - Request

-(NSArray*) getOrderFields{
    NSMutableArray* WHPurchaseOrderFields = [[MODEL.modelsStructure getModelProperties: @"WHPurchaseOrder"] mutableCopy];
    [WHPurchaseOrderFields removeObject: @"WHPurchaseBills"];
    [WHPurchaseOrderFields removeObject: @"createDate"];
    
    return WHPurchaseOrderFields;
}


-(NSMutableDictionary*) assembleSendObjects: (NSString*)divViewKey
{
    NSMutableDictionary* objects = [super assembleSendObjects: divViewKey];
    
    [objects setObject:_middleTableViewDataSource forKey:@"WHPurchaseBills"];
    if (objects[@"shouldPay"]) [objects setObject:objects[@"shouldPay"] forKey:@"totalPay"];
    
    return objects;
}

#pragma mark -
#pragma mark - Response

-(NSMutableDictionary*) assembleReadResponse: (ResponseJsonModel*)response
{
    
    NSArray* results = response.results;
    DBLOG(@"results === %@", results);
    _purchaseFooterCellContents = [ArrayHelper deepCopy: [results lastObject]];
    [_purchaseFooterTableView.tableView reloadData];
    
    NSMutableDictionary* responseObject = [NSMutableDictionary dictionary];
    NSDictionary* warehousePurchaseOrderValues = [[results firstObject] firstObject];
    [responseObject setObject:warehousePurchaseOrderValues forKey:@"purchase"];
    NSMutableDictionary* resultsObj = [DictionaryHelper deepCopy: responseObject];
    self.valueObjects = resultsObj[@"purchase"];
    
    return resultsObj;

}

-(void) enableViewsWithReceiveObjects: (NSMutableDictionary*)objects
{
    [super enableViewsWithReceiveObjects: objects[@"purchase"]];
}

-(void) translateReceiveObjects: (NSMutableDictionary*)objects
{
    NSMutableDictionary* orderObjdect = [objects objectForKey:@"purchase"];
    [super translateReceiveObjects: orderObjdect];
}

-(void) renderWithReceiveObjects: (NSMutableDictionary*)objects
{
    NSMutableDictionary* purchaseDic = [objects objectForKey:@"purchase"];
    
    [self.jsonView setModel: purchaseDic];
    
    _middleTableViewDataSource = [purchaseDic objectForKey:@"WHPurchaseBills"];
    [_purchaseTableView reloadTableData];
}


#pragma mark -
#pragma mark - Order Operation
-(void)refreshTotal
{
    if (_middleTableViewDataSource.count == 0 ) return;
    float subTotalFloat = 0;
    float storageSubTotalFloat = 0;
    for (int i = 0; i < [_middleTableViewDataSource count] ; i++ ) {
        NSDictionary* dic = [_middleTableViewDataSource objectAtIndex:i];
        
        NSString* amountString = [dic objectForKey:@"amount"];
        NSString *unitPriceString = [dic objectForKey:@"unitPrice"];
        float resultValue = [amountString floatValue]*[unitPriceString floatValue];
        subTotalFloat += resultValue;
        
        NSString *storageNumString = [dic objectForKey:@"storageNum"];
        NSString *storageUnitPriceString = [dic objectForKey:@"storageUnitPrice"];
        float resuleValue2 = [storageNumString floatValue]*[storageUnitPriceString floatValue];
        storageSubTotalFloat += resuleValue2;
        }
    
    _deliveryTotalTxtField.text = [[NSNumber numberWithFloat:subTotalFloat]stringValue];
    _storageTotalTxtField.text = [[NSNumber numberWithFloat:storageSubTotalFloat]stringValue];
}



@end
