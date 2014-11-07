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
//        [weakSelf refreshTotal];
        
        return cell;

    };
    
    
    
    
//    JRButton *spinButton = (JRButton *)[self.jsonView getView:@"NESTED_DOWN.spinPurchaseOrder"];
    
}



@end
