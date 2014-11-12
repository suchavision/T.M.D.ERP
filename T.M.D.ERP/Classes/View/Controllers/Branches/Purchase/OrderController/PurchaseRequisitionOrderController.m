#import "PurchaseRequisitionOrderController.h"
#import "AppInterface.h"
#import "PurchaseRequisitionBill.h"
@interface PurchaseRequisitionOrderController ()
{
    JRRefreshTableView *_purchaseRequisitionTableView;
    
    NSString* vendorNumber;         // 承办厂商编号
    
    NSString* vendorNumber1;		// 询价厂商编号
    
    NSString* vendorNumber2;		// 询价厂商编号
    
    NSString* vendorNumber3;		// 询价厂商编号

}

@end

@implementation PurchaseRequisitionOrderController
- (instancetype)init
{
    self = [super init];
    if (self) {
        _requisitionTableViewDataSource = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak PurchaseRequisitionOrderController *weakSelf = self;
    __block PurchaseRequisitionOrderController *blockSelf = self;
    NSString* orderNO = [@"QGD" stringByAppendingString:[DateHelper stringFromDate:[NSDate date] pattern:@"yyyyMMddhhmmss"]];
    [((id<JRComponentProtocal>)[self.jsonView getView:@"orderNO"]) setValue: orderNO];
    _purchaseRequisitionTableView = (JRRefreshTableView *)[self.jsonView getView:@"NESTED_MIDDLE.TABLE_ITEMS_LIST"];
       _purchaseRequisitionTableView.tableView.tableViewBaseNumberOfSectionsAction = ^NSInteger(TableViewBase *tableViewObject){
        return 1;
    };
    _purchaseRequisitionTableView.tableView.tableViewBaseNumberOfRowsInSectionAction = ^NSInteger(TableViewBase *tableViewOBJ ,NSInteger section){
        return weakSelf.controlMode == JsonControllerModeCreate ? blockSelf->_requisitionTableViewDataSource.count + 1 : blockSelf->_requisitionTableViewDataSource.count;
    };
    _purchaseRequisitionTableView.tableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase *tableObj ,NSIndexPath *indexPath ,UITableViewCell *olderCell){
        static NSString *CellIdentifier = @"Cell";
        PurchaseRequisitionBill* cell = [tableObj dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PurchaseRequisitionBill alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.requisitionTableViewDataSource = weakSelf.requisitionTableViewDataSource;
            cell.didEndEditNewCellAction = ^void(BaseJRTableViewCell* cell){
                PurchaseRequisitionBill* purchaseCell = (PurchaseRequisitionBill*)cell;
                NSIndexPath* indexPath = [tableObj indexPathForCell: purchaseCell];
                int row = indexPath.row;
                if (row == blockSelf->_requisitionTableViewDataSource.count) {
                    [blockSelf->_requisitionTableViewDataSource addObject:[cell getDatas]];
                } else {
                    [blockSelf->_requisitionTableViewDataSource replaceObjectAtIndex:row withObject:[cell getDatas]];
                }
                
                [tableObj reloadData];
                [tableObj scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            };
        }
        [cell setDatas: [blockSelf->_requisitionTableViewDataSource safeObjectAtIndex: indexPath.row]];
        return cell;

    };
    
    
    
    
    JRTextField *vendorName1 = (JRTextField *)[self.jsonView getView:@"vendorName1"];
    vendorName1.textFieldDidClickAction = ^void(JRTextField *jrTextField){
        NSArray* needFields = @[@"number", @"name", @"principal",@"phoneNO"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_VENDOR  fields:needFields criterias:nil];
        pickView.tableView.headersXcoordinates = @[@(30), @(200), @(520), @(800)];
        // when select
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSArray *array = [filterTableView getRealContentsAtIndexPath:indexPath];
            
            vendorNumber1 = [array safeObjectAtIndex: 1];
            NSString *vendorName = [array objectAtIndex:2];
            [jrTextField setValue:vendorName];
            [PickerModelTableView dismiss];

        };

    
    };
    JRTextField *vendorName2 = (JRTextField *)[self.jsonView getView:@"vendorName2"];
    vendorName2.textFieldDidClickAction = ^void(JRTextField *jrTextField){
        NSArray* needFields = @[@"number", @"name", @"principal",@"phoneNO"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_VENDOR  fields:needFields criterias:nil];
        pickView.tableView.headersXcoordinates = @[@(30), @(200), @(520), @(800)];
        // when select
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSArray *array = [filterTableView getRealContentsAtIndexPath:indexPath];
            
            vendorNumber2 = [array safeObjectAtIndex: 1];
            NSString *vendorName = [array objectAtIndex:2];
            [jrTextField setValue:vendorName];
            [PickerModelTableView dismiss];
            
        };
        
        
    };
    JRTextField *vendorName3 = (JRTextField *)[self.jsonView getView:@"vendorName3"];
    vendorName3.textFieldDidClickAction = ^void(JRTextField *jrTextField){
        NSArray* needFields = @[@"number", @"name", @"principal",@"phoneNO"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_VENDOR  fields:needFields criterias:nil];
        pickView.tableView.headersXcoordinates = @[@(30), @(200), @(520), @(800)];
        // when select
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSArray *array = [filterTableView getRealContentsAtIndexPath:indexPath];
            
            vendorNumber3 = [array safeObjectAtIndex: 1];
            NSString *vendorName = [array objectAtIndex:2];
            [jrTextField setValue:vendorName];
            [PickerModelTableView dismiss];
            
        };
        
        
    };
    
    JRLabelTextFieldView *underTakeVendor = (JRLabelTextFieldView *)[self.jsonView getView:@"vendorName"];
    JRTextField* underTextField = underTakeVendor.textField;
    underTextField.textFieldDidClickAction = ^void(JRTextField* tx) {
        NSString *vendorOne = [vendorName1 getValue];
        NSString *vendorTwo = [vendorName2 getValue];
        NSString *vendorThree = [vendorName3 getValue];
        
        
        if(!OBJECT_EMPYT(vendorOne) && vendorTwo != nil && vendorThree != nil)
        {
            NSArray *dataSources = [NSArray arrayWithObjects:vendorOne,vendorTwo,vendorThree, nil];
            NSArray *realDataSources = [NSArray arrayWithObjects:@[vendorNumber1, vendorOne],@[vendorNumber2, vendorTwo],@[vendorNumber3, vendorThree], nil];
            
            JRButtonsHeaderTableView* tableViews = [PopupTableHelper showPopTableView: tx titleKey:@"VENDOR" dataSources:dataSources realDataSources:realDataSources];
            
            tableViews.tableView.tableView.tableViewBaseDidSelectIndexPathAction = ^void(TableViewBase* tb, NSIndexPath* indexPath) {
                NSArray* vendorDatas = [tb realContentForIndexPath: indexPath];
                vendorNumber = [vendorDatas firstObject];
                [tx setValue: [vendorDatas lastObject]];
                [PopupTableHelper dissmissCurrentPopTableView];
            };
        }
    };
}




#pragma mark -
#pragma mark - Request

-(RequestJsonModel*) assembleSendRequest: (NSMutableDictionary*)withoutImagesObjects order:(NSString*)order department:(NSString*)department
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_CREATE(department);
    [requestModel addModel: order];
    
    [requestModel addObject: withoutImagesObjects ];
    
    [withoutImagesObjects setObject:vendorNumber forKey:@"vendorNumber"];
    [withoutImagesObjects setObject:vendorNumber1 forKey:@"vendorNumber1"];
    [withoutImagesObjects setObject:vendorNumber2 forKey:@"vendorNumber2"];
    [withoutImagesObjects setObject:vendorNumber3 forKey:@"vendorNumber3"];
    
    [requestModel.preconditions addObject: @{}];
    
    for (int i = 0; i < _requisitionTableViewDataSource.count; i++) {
        NSMutableDictionary* itemValues = _requisitionTableViewDataSource[i];
        [requestModel addModel: @"PurchaseRequisitionBill"];
        [requestModel addObject: itemValues];
        [requestModel.preconditions addObject: @{@"purchaseRequisitionOrderNO":@"0-orderNO"}];
    }
    
    return requestModel;
}


-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_READ(self.department);
    [requestModel addModels: self.order, @"PurchaseRequisitionBill", nil];
    [requestModel addObjects: objects, @{}, nil];
    [requestModel.preconditions addObjectsFromArray: @[@{}, @{@"purchaseRequisitionOrderNO": @"0-0-orderNO"}]];
    return requestModel;
}





-(NSMutableDictionary*) assembleReadResponse: (ResponseJsonModel*)response
{
    
    NSArray* results = response.results;
    
    NSMutableDictionary* valuesObjects = [DictionaryHelper deepCopy: [[results firstObject] firstObject]];
    self.valueObjects = valuesObjects;
    
    _requisitionTableViewDataSource = [results lastObject];
    [_purchaseRequisitionTableView reloadTableData];
    
    return valuesObjects;
    
}

-(void) enableViewsWithReceiveObjects: (NSMutableDictionary*)objects
{
    [super enableViewsWithReceiveObjects: objects];
    
    
    __weak PurchaseRequisitionOrderController* weakSelf = self;
    
    if ([JsonControllerHelper isAllApplied: self.order valueObjects:self.valueObjects]) {
        JRButton *spinPurchaseOrderButton = (JRButton *)[self.jsonView getView:@"spinPurchaseOrder"];
        [JsonControllerHelper setUserInterfaceEnable: spinPurchaseOrderButton enable:YES];
        spinPurchaseOrderButton.didClikcButtonAction = ^(id sender){
            
            if(! [PermissionChecker checkSignedUserWithAlert: DEPARTMENT_PURCHASE order:ORDER_PurchaseOrder permission:PERMISSION_CREATE]) {
                return;
            }
            
            
            RequestJsonModel* jsonModel = [RequestJsonModel getJsonModel];
            [jsonModel addModel: MODEL_VENDOR];
            [jsonModel addObject: @{@"number": vendorNumber}];
            [jsonModel.fields addObject:@[@"number", @"name", @"principal", @"phoneNO"]];
            jsonModel.path = PATH_LOGIC_READ(DEPARTMENT_PURCHASE);
            
            [VIEW.progress show];
            [MODEL.requester startPostRequest: jsonModel completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                [VIEW.progress hide];
                
                if (response.status) {
                    NSArray* vendorInformations = [[response.results firstObject] firstObject];
                    
                    NSString* number = [vendorInformations firstObject];
                    NSString* name = [vendorInformations objectAtIndex: 1];
                    NSString* principal = [vendorInformations objectAtIndex: 2];
                    NSString* phoneNO = [vendorInformations objectAtIndex: 3];
                    
                    
                    // ----------
                    PurchaseOrderController * jsonController = (PurchaseOrderController*)[OrderListControllerHelper getNewJsonControllerInstance: DEPARTMENT_PURCHASE order:ORDER_PurchaseOrder];
                    
                    jsonController.controlMode = JsonControllerModeCreate;
                    jsonController.vendorNumber = number;
                    
                    
                    NSMutableDictionary* destinationObjects = [NSMutableDictionary dictionary];
                    [destinationObjects setObject:weakSelf.valueObjects[@"orderNO"] forKey:@"bookPurhaseNO"];
                    [destinationObjects setObject:name forKey:@"vendorName"];
                    [destinationObjects setObject:principal forKey:@"contact"];
                    [destinationObjects setObject:phoneNO forKey:@"phoneNO"];
                    [destinationObjects setObject:[(JRLabelTextView *)[weakSelf.jsonView getView:@"purpose"] getValue] forKey:@"purpose"];
                    [jsonController.jsonView setModel:destinationObjects];
                    
                    
                    // --------- bills
                    NSString* unitPriceKey = nil;
                    if ([number isEqualToString:vendorNumber1]) {
                        unitPriceKey = @"unitPrice1";
                    } else if([number isEqualToString: vendorNumber2]) {
                        unitPriceKey = @"unitPrice2";
                    } else if([number isEqualToString: vendorNumber3]) {
                        unitPriceKey = @"unitPrice3";
                    }
                    
                    NSMutableArray* array = [NSMutableArray array];
                    for (NSMutableDictionary* dic in weakSelf.requisitionTableViewDataSource) {
                        id unitPrice = dic[unitPriceKey];
                        NSMutableDictionary* contents = [DictionaryHelper subtract: dic keys:@[@"productCode", @"productName", @"amount", @"unit"]];
                        [contents setObject: unitPrice forKey:@"unitPrice"];
                        [array addObject: contents];
                    }
                    
                    [jsonController.purchaseCellContents setArray: array];
                    
                    [VIEW.navigator pushViewController: jsonController animated:YES];
                }
                
            }];
            
        };
        
    }

}

-(void) translateReceiveObjects: (NSMutableDictionary*)objects
{
    [super translateReceiveObjects: objects];
    
    vendorNumber = objects[@"vendorNumber"];
    vendorNumber1 = objects[@"vendorNumber1"];
    vendorNumber2 = objects[@"vendorNumber2"];
    vendorNumber3 = objects[@"vendorNumber3"];
}


@end
