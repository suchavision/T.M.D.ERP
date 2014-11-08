#import "SetPermissionListController.h"
#import "ClassesInterface.h"
#import "AppInterface.h"


@interface OrderTableViewCell : UITableViewCell

@property (strong) NSString* order;

@end

@implementation OrderTableViewCell

@synthesize order;

@end


@interface SetPermissionListController () {
    NSArray* allCells;
    NSArray* permissionsMethods;
}

@end


@implementation SetPermissionListController

@synthesize orderPermissions;

- (id)initWithDepartment: (NSString*)department
{
    self = [super init];
    if (self) {
        permissionsMethods = @[PERMISSION_READ,PERMISSION_CREATE,PERMISSION_DELETE /*, PERMISSION_MODIFY, PERMISSION_APPLY*/ ];
        self.navigationItem.title = LOCALIZE_KEY(department);
        
        NSMutableArray* headers = [NSMutableArray arrayWithObject: KEY_ORDER];
        [headers addObjectsFromArray: permissionsMethods];
        self.headers = headers;
        
        self.headersXcoordinates = @[@(15), @(535), @(630), @(740), @(840), @(940)];
        self.valuesXcoordinates = @[@(10), @(535), @(630), @(740), @(840), @(940)];
        self.headerTableView.disableTriggered = YES;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear: animated];
}


#pragma mark - TableViewBaseTableProxy

- (UITableViewCell*)tableViewBase:(TableViewBase *)tableViewObj cellForIndexPath:(NSIndexPath *)indexPath oldCell:(UITableViewCell*)oldCell {
    return [allCells objectAtIndex: indexPath.row];
}

-(void) setupAllCellsByOrders: (NSArray*)orders
{
    allCells = [self generateCellsByOrders: orders];
}

#pragma mark - Private methods

-(NSMutableArray*) generateCellsByOrders: (NSArray*)orders {
    NSMutableArray* results = [NSMutableArray array];
    
    for (int i = 0; i < orders.count; i++) {
        // get the new cell
        OrderTableViewCell* cell = [[OrderTableViewCell alloc] init ];
        
        NSString* orderType = [orders objectAtIndex: i];
        NSArray* permissions = [orderPermissions objectForKey: orderType];
        
        // set checkboxes
        for (int tag = 0; tag < permissionsMethods.count; tag++) {
            
            CGRect canvas = CGRectMake(0, 0, 65, 65);
            JRCheckBox* checkBox = [[JRCheckBox alloc] init] ;
            checkBox.frame = [FrameTranslater convertCanvasRect: canvas];
            // set x
            float x = [self.valuesXcoordinates[tag+1] floatValue];
            [checkBox setOriginX: [FrameTranslater convertCanvasX: x]];
            
            checkBox.stateChangedBlock = ^(id sender) {
                [self checkBoxStateChanged: sender];
            };
            checkBox.tag = tag;             // important  !!
            [cell addSubview: checkBox];
            
            NSString* method = [permissionsMethods objectAtIndex: tag];
            if ([permissions containsObject: method]) checkBox.checked = YES;
        }
        
        // set the 'select all' button
        NormalButton* selectAllButton = [NormalButton buttonWithType: UIButtonTypeSystem];
        [selectAllButton setTitle: LOCALIZE_KEY(KEY_SELECTALL) forState:UIControlStateNormal];
        [selectAllButton setTitleColor: selectAllButton.tintColor forState:UIControlStateNormal];
        selectAllButton.frame = [FrameTranslater convertCanvasRect: CGRectMake(850, 0, 100, 56)];
        [cell addSubview: selectAllButton];
        selectAllButton.didClikcButtonAction = ^void(NormalButton* sender) {
            __block BOOL flag = NO;
            __block BOOL isChecked = NO;
            [ViewHelper iterateSubView: cell class:[JRCheckBox class] handler:^BOOL(id subView) {
                JRCheckBox* checkBox = (JRCheckBox*)subView;
                if (! flag) {
                    isChecked = ! checkBox.checked;
                    flag = YES;
                }
                [checkBox setChecked: isChecked];
                [self checkBoxStateChanged: checkBox];
                return NO;
            }];
            sender.selected = isChecked;
        };
        
        // set order type
        cell.order = orderType;
        
        [results addObject: cell];
    }
    
    
    return results;
}

// update the permission data
-(void) checkBoxStateChanged: (id)sender {
    JRCheckBox* checkBox = (JRCheckBox*)sender;
    int tag = checkBox.tag;
    bool checked = checkBox.checked;
    
    UITableViewCell* cell = (UITableViewCell*)[sender superview];
    while (cell && ![cell isKindOfClass:[UITableViewCell class]]) cell = (UITableViewCell*)[cell superview];
    NSString* order = ((OrderTableViewCell*)cell).order;
    NSString* permission = [permissionsMethods objectAtIndex: tag];
    
    if (! [orderPermissions objectForKey: order]) {
        [orderPermissions setObject: [NSMutableArray array] forKey: order];
    }
    if (checked) {
        if (![[orderPermissions objectForKey: order] containsObject: permission]) [[orderPermissions objectForKey: order] addObject: permission];
        
    } else {
        [[orderPermissions objectForKey: order] removeObject: permission];
    }
}



@end



