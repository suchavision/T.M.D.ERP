#import "PurchaseOrderController.h"
#import "AppInterface.h"

#import "PurchaseBillCell.h"

@interface PurchaseOrderController ()
{
    JRRefreshTableView* _purchaseTableView;
    NSString* vendorNumber;
    JRTextField *_summaryTextField;
}

@property (strong) NSMutableArray* purchaseCellContents;

@end

@implementation PurchaseOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* orderNO = [@"GCD" stringByAppendingString:[DateHelper stringFromDate:[NSDate date] pattern:@"yyyyMMddhhmmss"]];
    [((id<JRComponentProtocal>)[self.jsonView getView:@"orderNO"]) setValue: orderNO];
    
    __weak PurchaseOrderController *weakSelf = self;
    self.purchaseCellContents = [[NSMutableArray alloc] init];
    NSLog(@"self.jsonView:%@",self.jsonView);
    _summaryTextField = ((JRLabelCommaTextFieldView *)[self.jsonView getView:@"summary"]).textField;
    JRLabelCommaTextFieldView *contact = (JRLabelCommaTextFieldView *)[self.jsonView getView:@"NESTED_BODY.contact"];
    JRTextField *contactTextField = contact.textField;
    JRLabelCommaTextFieldView *phoneNO = (JRLabelCommaTextFieldView *)[self.jsonView getView:@"NESTED_BODY.phoneNO"];
    JRTextField *phoneNoTextField = phoneNO.textField;
    JRLabelCommaTextFieldView *vendor = (JRLabelCommaTextFieldView *)[self.jsonView getView:@"NESTED_BODY.vendorName"];
    JRTextField *vendorTextFiled = vendor.textField;
    vendorTextFiled.textFieldDidClickAction = ^void(JRTextField* textField) {
        NSArray* needFields = @[@"number", @"name", @"principal",@"phoneNO"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_VENDOR  fields:needFields criterias:nil];
         pickView.tableView.headersXcoordinates = @[@(0), @(200), @(520), @(800)];
        // when select
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            NSArray *array = [filterTableView realContentForIndexPath:realIndexPath];
            
            vendorNumber = [array objectAtIndex:1];
            NSString* vendorNameValue = [array objectAtIndex:2];
             NSString* contacterValue = [array objectAtIndex:3];
             NSString* phoneNoValue = [array objectAtIndex:4];
            [textField setValue: vendorNameValue];
            [contactTextField setValue:contacterValue];
            [phoneNoTextField setValue:phoneNoValue];
            [PickerModelTableView dismiss];
        };
        
    };
    
    
    
    _purchaseTableView = (JRRefreshTableView*)[self.jsonView getView:@"NESTED_MIDDLE.TABLE_ITEMS_LIST"];
    _purchaseTableView.tableView.tableViewBaseNumberOfSectionsAction = ^NSInteger(TableViewBase* tableViewObje){
        return 1;
        
    };
    _purchaseTableView.tableView.tableViewBaseNumberOfRowsInSectionAction = ^NSInteger(TableViewBase* tableViewObj, NSInteger section) {
        return weakSelf.controlMode == JsonControllerModeCreate ? weakSelf.purchaseCellContents.count + 1 : weakSelf.purchaseCellContents.count;
    };
    _purchaseTableView.tableView.tableViewBaseCanEditIndexPathAction = ^BOOL(TableViewBase *tableViewObj, NSIndexPath *indexPath) {
        return YES;
    };
    _purchaseTableView.tableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath, UITableViewCell* oldCell) {
        static NSString *CellIdentifier = @"Cell";
        PurchaseBillCell* cell = [tableViewObj dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PurchaseBillCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            cell.didEndEditNewCellAction = ^void(BaseJRTableViewCell* cell){
                PurchaseBillCell* purchaseCell = (PurchaseBillCell*)cell;
                NSIndexPath* indexPath = [tableViewObj indexPathForCell: purchaseCell];
                int row = indexPath.row;
                if (row == weakSelf.purchaseCellContents.count) {
                    [weakSelf.purchaseCellContents addObject:[cell getDatas]];
                } else {
                    [weakSelf.purchaseCellContents replaceObjectAtIndex:row withObject:[cell getDatas]];
                }
                
                [tableViewObj reloadData];
                [tableViewObj scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            };
        }
        
        NSDictionary* cellValue = [weakSelf.purchaseCellContents safeObjectAtIndex: indexPath.row];
        [cell setDatas: cellValue];
        [weakSelf refreshTotal];
        return cell;
    };
    
    
    
    JRLabelCommaTextFieldView *payWayTextView = (JRLabelCommaTextFieldView *)[self.jsonView getView:@"NESTED_BODY.NESTED_DOWN.payMode"];
    [FinancePaymentOrderController popPayWayTable: payWayTextView.textField selectedAction:nil];
}

#pragma mark -
#pragma mark - Request

-(RequestJsonModel*) assembleSendRequest: (NSMutableDictionary*)withoutImagesObjects order:(NSString*)order department:(NSString*)department
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_CREATE(department);
    [requestModel addModel: order];

    [requestModel addObject: withoutImagesObjects ];
    [requestModel.preconditions addObject: @{}];
    
    for (int i = 0; i < _purchaseCellContents.count; i++) {
        NSMutableDictionary* itemValues = _purchaseCellContents[i];
        [requestModel addModel: @"PurchaseBill"];
        [requestModel addObject: itemValues];
        [requestModel.preconditions addObject: @{@"purchaseOrderNO":@"0-orderNO"}];
    }
    
    return requestModel;
}


-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_READ(self.department);
    [requestModel addModels: self.order, @"PurchaseBill", nil];
    [requestModel addObjects: objects, @{}, nil];
    [requestModel.preconditions addObjectsFromArray: @[@{}, @{@"purchaseOrderNO": @"0-0-orderNO"}]];
    return requestModel;
}

-(NSMutableDictionary*) assembleSendObjects: (NSString*)divViewKey
{
    NSMutableDictionary* objects = [super assembleSendObjects:divViewKey];
    
    if (vendorNumber && self.controlMode == JsonControllerModeCreate) [objects setObject: vendorNumber forKey:@"vendorNumber"];
    
    return objects;
}


#pragma mark -
#pragma mark - Response
-(NSMutableDictionary*) assembleReadResponse: (ResponseJsonModel*)response
{
    NSArray* results = response.results;
    
    DLOG(@"++++++++++ %@", results);
    
    NSDictionary* orderValues = [[results firstObject] firstObject];
    self.valueObjects = [DictionaryHelper deepCopy: orderValues];
    
    NSArray* billValues = [results lastObject];
    [self.purchaseCellContents setArray:billValues];
    [_purchaseTableView reloadTableData];
    
    return self.valueObjects;
}


-(void) enableViewsWithReceiveObjects: (NSMutableDictionary*)objects
{
    [super enableViewsWithReceiveObjects:objects];
    
    if ([JsonControllerHelper isAllApplied: self.order valueObjects:self.valueObjects]) {
        JRButton *spinButton = (JRButton *)[self.jsonView getView:@"NESTED_BODY.NESTED_DOWN.spin"];
        [JsonControllerHelper setUserInterfaceEnable: spinButton enable:YES];
        spinButton.didClikcButtonAction = ^(id sender){
            
            if(! [PermissionChecker checkSignedUserWithAlert: DEPARTMENT_WAREHOUSE order:ORDER_WHPurchaseOrder permission:PERMISSION_CREATE]) {
                return;
            }
            
            WHPurchaseOrderController* jsonController = (WHPurchaseOrderController*)[OrderListControllerHelper getNewJsonControllerInstance: DEPARTMENT_WAREHOUSE order:ORDER_WHPurchaseOrder];
            jsonController.controlMode = JsonControllerModeCreate;
            
            
            
            NSMutableDictionary* valueObjects = self.valueObjects;
            NSArray* keys = @[@"vendorNumber",@"vendorName",@"contact",@"phoneNO",@"payCondition",@"payMode",@"freight"];
            NSMutableDictionary* destinationObjects = [DictionaryHelper subtract: valueObjects keys:keys];
            
            [destinationObjects setObject:valueObjects[@"orderNO"] forKey:@"purchaseOrderNO"];
            
            [jsonController.jsonView setModel:destinationObjects];
            
            NSMutableArray* array = [ArrayHelper deepCopy:self.purchaseCellContents];
            for (NSMutableDictionary* dic in array) {
                [dic removeObjectForKey:@"id"];
            }
            [jsonController.middleTableViewDataSource addObjectsFromArray: array];
            
            [VIEW.navigator pushViewController: jsonController animated:YES];
        };
        
    }
}

-(void)refreshTotal
{
    if (_purchaseCellContents.count == 0) return;
    float subTotalFloat = 0;
    for (int i = 0; i < [_purchaseCellContents count] ; i++ ) {
        NSDictionary* dic = [_purchaseCellContents objectAtIndex:i];
        
        NSString* amount = [dic objectForKey:@"amount"];
        NSString* unitPrice = [dic objectForKey:@"unitPrice"];
        float subTotal = [amount floatValue]*[unitPrice floatValue];
        subTotalFloat += subTotal;
        }
    _summaryTextField.text = [[NSNumber numberWithFloat:subTotalFloat] stringValue];

}






@end
