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

@property (strong) id delectIdentification;


@property (strong) NSMutableArray* deletedContents;

@end

@implementation PurchaseRequisitionOrderController
- (instancetype)init
{
    self = [super init];
    if (self) {
        _requisitionTableViewDataSource = [[NSMutableArray alloc] init];
        _deletedContents = [NSMutableArray array];
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
    UIView* headerView = _purchaseRequisitionTableView.headerView;
    for (JRLocalizeLabel* view in headerView.subviews) {
        NSString* attribute = view.attribute;
        if ([attribute isEqualToString:@"productNames"] || [attribute isEqualToString:@"amount"] || [attribute isEqualToString:@"unit"] || [attribute isEqualToString:@"unitPriceOne"]) {
            
            UILabel* label = [[UILabel alloc] init];
            [label setSize:CGSizeMake(CanvasW(15), [view sizeHeight])];
            [label setOriginX: CanvasX(-15)];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor redColor];
            [view addSubview: label];
            label.text = @"*";

        }
    }
    _purchaseRequisitionTableView.tableView.tableViewBaseNumberOfSectionsAction = ^NSInteger(TableViewBase* tableViewObj) { return 1; };
    _purchaseRequisitionTableView.tableView.tableViewBaseCanEditIndexPathAction = ^BOOL(TableViewBase *tableViewObj, NSIndexPath *indexPath) {
        if (indexPath.row == blockSelf->_requisitionTableViewDataSource.count) return NO;
        return YES;
    };
    _purchaseRequisitionTableView.tableView.tableViewBaseShouldDeleteContentsAction = ^BOOL(TableViewBase *tableViewObj, NSIndexPath *indexPath) {
        if (indexPath.row == blockSelf->_requisitionTableViewDataSource.count) {
            return NO;
        } else {
            id contents = [blockSelf->_requisitionTableViewDataSource objectAtIndex: indexPath.row];
            [blockSelf->_deletedContents addObject:contents];
            [blockSelf->_requisitionTableViewDataSource removeObjectAtIndex: indexPath.row];     // keep the data source update . or will error occur
    
            return YES;
        }
    };
    _purchaseRequisitionTableView.tableView.tableViewBaseNumberOfRowsInSectionAction = ^NSInteger(TableViewBase* tableViewObj, NSInteger section) {
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
        NSArray *dataSource = _requisitionTableViewDataSource;
        for(NSDictionary *dic in dataSource)
        {
            NSString *unitPriceOneString = dic[@"unitPrice1"];
            if(!unitPriceOneString)
            {
                return;
            }
        }
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
        
        NSArray *dataSource = _requisitionTableViewDataSource;
        for(NSDictionary *dic in dataSource)
        {
            NSString *unitPriceTwoString = dic[@"unitPrice2"];
            if(!unitPriceTwoString)
            {
                return;
            }
        }

        
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
        
        NSArray *dataSource = _requisitionTableViewDataSource;
        for(NSDictionary *dic in dataSource)
        {
            NSString *unitPriceThreeString = dic[@"unitPrice3"];
            if(!unitPriceThreeString)
            {
                return;
            }
        }
        

        
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
        
//        NSArray *dataSources = [NSArray arrayWithObjects:vendorOne,vendorTwo,vendorThree, nil];
        NSMutableArray *dataSources = [NSMutableArray array];
        if(!OBJECT_EMPYT(vendorOne)) [dataSources addObject:vendorOne];
        if(!OBJECT_EMPYT(vendorTwo)) [dataSources addObject:vendorTwo];
        if(!OBJECT_EMPYT(vendorThree)) [dataSources addObject:vendorThree];
        NSMutableArray *realDataSourche = [NSMutableArray array];
        if(!OBJECT_EMPYT(vendorOne))
        {
            [realDataSourche addObject:@[vendorNumber1,vendorOne]];
            if(!OBJECT_EMPYT(vendorNumber2))
            {
                [realDataSourche addObject:@[vendorNumber2,vendorTwo]];
            }
            
            if(!OBJECT_EMPYT(vendorNumber3))
            {
                [realDataSourche addObject:@[vendorNumber3,vendorThree]];
            }
        }
                    JRButtonsHeaderTableView* tableViews = [PopupTableHelper showPopTableView: tx titleKey:@"VENDOR" dataSources:dataSources realDataSources:realDataSourche];
        
                    tableViews.tableView.tableView.tableViewBaseDidSelectIndexPathAction = ^void(TableViewBase* tb, NSIndexPath* indexPath) {
                        NSArray* vendorDatas = [tb realContentForIndexPath: indexPath];
                        vendorNumber = [vendorDatas firstObject];
                        [tx setValue: [vendorDatas lastObject]];
                        [PopupTableHelper dissmissCurrentPopTableView];
                    };

            
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
    if(vendorNumber)
    [withoutImagesObjects setObject:vendorNumber forKey:@"vendorNumber"];
    if(vendorNumber1)
    [withoutImagesObjects setObject:vendorNumber1 forKey:@"vendorNumber1"];
    if(vendorNumber2)
    [withoutImagesObjects setObject:vendorNumber2 forKey:@"vendorNumber2"];
    if(vendorNumber3)
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


-(RequestJsonModel*) purchaseRequisitionAssembleSendRequest: (NSMutableDictionary*)withoutImagesObjects order:(NSString*)order department:(NSString*)department
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_CREATE(department);
    [requestModel addModels: order, nil];
    [requestModel addObject: withoutImagesObjects ];
    if(vendorNumber)
        [withoutImagesObjects setObject:vendorNumber forKey:@"vendorNumber"];
    if(vendorNumber1)
        [withoutImagesObjects setObject:vendorNumber1 forKey:@"vendorNumber1"];
    if(vendorNumber2)
        [withoutImagesObjects setObject:vendorNumber2 forKey:@"vendorNumber2"];
    if(vendorNumber3)
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



-(BOOL)validateSendObjects:(NSMutableDictionary *)objects order:(NSString *)order
{
    
   
    BOOL isSuccess = YES;
    NSString* message = nil;
    NSArray* dataSources = self.requisitionTableViewDataSource;
    if (!dataSources.count) {
        NSString* tips = [LOCALIZE_KEY(@"product") stringByAppendingString:LOCALIZE_KEY(@"list")];
        message = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, tips);
        isSuccess = NO;
    }

    for (NSDictionary* dictionary in dataSources) {
        if (OBJECT_EMPYT(dictionary[@"productName"])) {
            message = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, LOCALIZE_KEY(@"productNames"));
            isSuccess = NO;
            break;
        }
        
        if (OBJECT_EMPYT(dictionary[@"amount"])) {
            message = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, LOCALIZE_KEY(@"amount"));
            isSuccess = NO;
            break;
            
        }

         if (OBJECT_EMPYT(dictionary[@"unit"])) {
            message = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, LOCALIZE_KEY(@"unit"));
            isSuccess = NO;
            break;
        }
         if (OBJECT_EMPYT(dictionary[@"unitPrice1"])) {
            message = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, LOCALIZE_KEY(@"unitPriceOne"));
            isSuccess = NO;
            break;
            
        }
        BOOL success = [super validateSendObjects:objects order:order];
        
        if (!success) {
            return NO;
        }

        
    
    }
    
    
    if (message)[AppViewHelper alertMessage: message];
    return isSuccess;
    
   
}




-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects
{
    [_deletedContents removeAllObjects];
    
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
    _requisitionTableViewDataSource = [ArrayHelper deepCopy:[results lastObject]];
//    NSDictionary *delectContent = [_requisitionTableViewDataSource objectAtIndex:self.delectRow];
//    self.delectIdentification = [delectContent objectForKey:@"id"];
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


-(void) didSuccessApplyOrder: (NSString*)orderType appFrom:(NSString*)appFrom appTo:(NSString*)appTo divViewKey:(NSString*)divViewKey forwarduser:(NSString*)forwardUser
{
    [super didSuccessApplyOrder:orderType appFrom:appFrom appTo:appTo divViewKey:divViewKey forwarduser:forwardUser];
    
}


-(void) translateReceiveObjects: (NSMutableDictionary*)objects
{
    [super translateReceiveObjects: objects];
    
    vendorNumber = objects[@"vendorNumber"];
    vendorNumber1 = objects[@"vendorNumber1"];
    vendorNumber2 = objects[@"vendorNumber2"];
    vendorNumber3 = objects[@"vendorNumber3"];
}


-(void) startApplyOrderRequest: (NSString*)orderType divViewKey:(NSString*)divViewKey appFrom:(NSString*)appFrom appTo:(NSString*)appTo forwarduser:(NSString*)forwardUser objects:(NSDictionary*)objects identities:(NSDictionary*)identities
{
    [VIEW.progress show];
    VIEW.progress.detailsLabelText = LOCALIZE_MESSAGE(@"ApplyingNow");
    
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_APPLY(self.department);
    [requestModel addModels: orderType, nil];
    if (objects) [requestModel addObject: objects ];
    
    [requestModel.identities addObject: identities];
    [requestModel.parameters setObject: appFrom forKey:REQUEST_PARA_APPLEVEL];
    
    for (int i = 0 ; i < self.deletedContents.count; i++) {
        id identifictaion = self.deletedContents[i][@"id"];
        [requestModel.parameters setObject: identifictaion forKey:@"shouldDeleteBillId"];
    }
    
//        [requestModel.parameters setObject: self.delectIdentification forKey:@"shouldDeleteBillId"];
    
    if (forwardUser) [requestModel.apns_forwards addObject:forwardUser];
    
    [MODEL.requester startPostRequestWithAlertTips: requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        
        BOOL isSuccessfully = response.status;
        if (isSuccessfully) {
            [self didSuccessApplyOrder: orderType appFrom:appFrom appTo:appTo divViewKey:divViewKey forwarduser:forwardUser];
        } else {
            [self didFailedApplyOrder: orderType appFrom:appFrom appTo:appTo divViewKey:divViewKey];
        }
        
    }];
    
    
    
}


@end
