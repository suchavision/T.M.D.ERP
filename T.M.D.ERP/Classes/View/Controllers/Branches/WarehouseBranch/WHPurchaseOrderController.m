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
@property (strong) NSMutableArray* whPurchseDeletedContents;

@end


@implementation WHPurchaseOrderController
@synthesize vendorNumber;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _middleTableViewDataSource = [[NSMutableArray alloc] init];
        _whPurchseDeletedContents = [[NSMutableArray alloc] init];
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

    [JRComponentHelper setJRRefreshTableViewHeaderViewNoEmpty: _purchaseTableView attributes:@[@"productNames", @"amount",@"unit",@"unitPrice",@"storageNum",@"storageUnitPrice"]];
    
//    for(JRLocalizeLabel *localizeLabel in headView.subviews)
//    {
//        NSString *attribute = localizeLabel.attribute;
//        if([attribute isEqualToString:@"productNames" ]|| [attribute isEqualToString:@"amount"] || [attribute isEqualToString:@"unit" ]|| [attribute isEqualToString:@"unitPrice"] || [attribute isEqualToString:@"storageNum"] ||[attribute isEqualToString:@"storageUnitPrice"])
//        {
//            UILabel *label = [[UILabel alloc] init];
//            [label setSize:CGSizeMake(CanvasW(15), [localizeLabel sizeHeight])];
//            [label setOriginX:CanvasX(-5)];
//            [label setOriginY:CanvasY(-5)];
//            [label setTextColor:[UIColor redColor]];
//            label.text = @"*";
//            [localizeLabel addSubview:label];
//        }
//    }
    
    
    _purchaseTableView.tableView.tableViewBaseCanEditIndexPathAction = ^BOOL(TableViewBase *tableViewObj , NSIndexPath *indexPath){
        return YES;
    };
    _purchaseTableView.tableView.tableViewBaseShouldDeleteContentsAction = ^BOOL(TableViewBase *tableViewObj ,NSIndexPath *indexPath)
    {
        if (indexPath.row == blockSelf.middleTableViewDataSource.count) {
            return NO;
        } else {
            id contents = [blockSelf->_middleTableViewDataSource objectAtIndex: indexPath.row];
            [blockSelf->_whPurchseDeletedContents addObject:contents];

            [blockSelf.middleTableViewDataSource removeObjectAtIndex: indexPath.row];     // keep the data source update . or will error occur
            
            return YES;
        }

    };
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


- (BOOL)validateSendObjects:(NSMutableDictionary *)objects order:(NSString *)order
{
    BOOL success = [super validateSendObjects:objects order:order];
    if(!success)
    {
        return NO;
    }
    BOOL isSuccess = YES;
    NSString *message = nil;
    NSArray *dataSource = _middleTableViewDataSource;
    if(!dataSource)
    {
        NSString *tip = [LOCALIZE_KEY(@"product") stringByAppendingString:LOCALIZE_KEY(@"list")];
        message = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, tip);
        isSuccess = NO;
    }
    for(NSDictionary *dictionary in dataSource)
    {
        if(OBJECT_EMPYT(dictionary[@"productName"]))
        {
            message = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, LOCALIZE_KEY(@"productName"));
            isSuccess = NO;
            break;
            
        }
        if(OBJECT_EMPYT(dictionary[@"amount"]))
        {
            message = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, LOCALIZE_KEY(@"amount"));
            isSuccess = NO;
            break;
        }
        if(OBJECT_EMPYT(dictionary[@"unit"]))
        {
            message = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, LOCALIZE_KEY(@"unit"));
            isSuccess = NO;
            break;
        }
        if(OBJECT_EMPYT(dictionary[@"unitPrice"]))
        {
            message = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, LOCALIZE_KEY(@"unitPrice"));
            isSuccess = NO;
            break;
        }
        if(OBJECT_EMPYT(dictionary[@"storageNum"]))
        {
            message = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, LOCALIZE_KEY(@"storageNum"));
            isSuccess = NO;
            break;
        }
        
        if(OBJECT_EMPYT(dictionary[@"storageUnit"]))
        {
            message = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, LOCALIZE_MESSAGE(@"storageUnit"));
            isSuccess = NO;
            break;
        }
        if(OBJECT_EMPYT(@"storageUnitPrice"))
        {
            message = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, LOCALIZE_KEY(@"storageUnitPrice"));
            isSuccess = NO;
            break;
        }
           }
    if(message)
        [AppViewHelper alertMessage:message];
    return isSuccess;
}



#pragma mark -
#pragma mark - Request


-(NSMutableDictionary*) assembleSendObjects: (NSString*)divViewKey
{
    NSMutableDictionary* objects = [super assembleSendObjects: divViewKey];
    
    [objects setObject:_middleTableViewDataSource forKey:@"WHPurchaseBills"];
    if (objects[@"shouldPay"]) [objects setObject:objects[@"shouldPay"] forKey:@"totalPay"];
    if (vendorNumber && self.controlMode == JsonControllerModeCreate) [objects setObject: vendorNumber forKey:@"vendorNumber"];
    
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
    
    NSDictionary* warehousePurchaseOrderValues = [[results firstObject] firstObject];
    
    NSMutableDictionary* resultsObj = [DictionaryHelper deepCopy: warehousePurchaseOrderValues];
    self.valueObjects =  resultsObj;
    
    return resultsObj;

}


-(void) renderWithReceiveObjects: (NSMutableDictionary*)objects
{
    [super renderWithReceiveObjects:objects];
    
    _middleTableViewDataSource = [objects objectForKey:@"WHPurchaseBills"];
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
    
    for (int i = 0 ; i < self.whPurchseDeletedContents.count; i++) {
        id identifictaion = self.whPurchseDeletedContents[i][@"id"];
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
