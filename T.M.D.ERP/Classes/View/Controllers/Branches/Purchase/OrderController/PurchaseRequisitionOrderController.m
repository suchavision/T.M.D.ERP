#import "PurchaseRequisitionOrderController.h"
#import "AppInterface.h"
#import "PurchaseRequisitionBill.h"
@interface PurchaseRequisitionOrderController ()
{
    JRRefreshTableView *_purchaseRequisitionTableView;
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
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            NSArray *array = [filterTableView realContentForIndexPath:realIndexPath];
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
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            NSArray *array = [filterTableView realContentForIndexPath:realIndexPath];
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
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            NSArray *array = [filterTableView realContentForIndexPath:realIndexPath];
            NSString *vendorName = [array objectAtIndex:2];
            [jrTextField setValue:vendorName];
            [PickerModelTableView dismiss];
            
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
    DBLOG(@"results === %@", results);
//    _purchaseFooterCellContents = [ArrayHelper deepCopy: [results lastObject]];
//    [_purchaseFooterTableView.tableView reloadData];
    
    NSMutableDictionary* responseObject = [NSMutableDictionary dictionary];
    NSDictionary* warehousePurchaseOrderValues = [[results firstObject] firstObject];
    [responseObject setObject:warehousePurchaseOrderValues forKey:@"purchase"];
    NSMutableDictionary* resultsObj = [DictionaryHelper deepCopy: responseObject];
    self.valueObjects = resultsObj[@"purchase"];
    _requisitionTableViewDataSource = results[1];
    [_purchaseRequisitionTableView reloadTableData];
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
//    _requisitionTableViewDataSource = [purchaseDic objectForKey:];
    
}

@end
