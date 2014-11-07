#import "ViewControllerHelper.h"
#import "AppInterface.h"

@implementation ViewControllerHelper

/** @prama dictionary ,which is two dimesion, first dimension element is NSMutableDictionary , second dimesion element is NSArray*/
+(void) filterDictionaryEmptyElement: (NSMutableDictionary*)dictionary {
    NSArray* allKeys = [dictionary allKeys];
    for (NSString* department in allKeys) {
        NSMutableDictionary* ordersPermission = [dictionary objectForKey: department];
        
        NSArray* allKeys = [ordersPermission allKeys];
        for (NSString* order in allKeys) {
            NSArray* permissions = [ordersPermission objectForKey: order];
            
            if (permissions.count == 0) {
                [ordersPermission removeObjectForKey: order];
            }
        }
        
        if (ordersPermission.count == 0) {
            [dictionary removeObjectForKey: department];
        }
    }
}

+(UIViewController*) getPreviousViewControllerBeforePushSelf {
    NSArray* viewControllers = VIEW.navigator.viewControllers;
    return [viewControllers objectAtIndex: viewControllers.count - 1];
}


#pragma mark -

+(void) popApprovalView: (NSString*)app department:(NSString*)department order:(NSString*)order selectAction:(void(^)(NSString* number))selectAction cancelAction:(void(^)(id sender))cancelAction sendAction:(void(^)(id sender, NSString* number))sendAction
{
    __block NSString* selectNumber = nil;
    
    UIView* superView = [PopupTableHelper getCommonPopupTableView];
    JRButtonsHeaderTableView* searchTableView = (JRButtonsHeaderTableView*)[superView viewWithTag: POPUP_TABLEVIEW_TAG];
    
    NSMutableArray* users = [self getApprovalsUsers: app department:department order:order];
    searchTableView.tableView.headers = @[LOCALIZE_KEY(@"number"), LOCALIZE_KEY(@"name")];
    [self setEmployeesNumbersNames:searchTableView.tableView.tableView numbers:users];
    
    searchTableView.tableView.tableView.tableViewBaseDidSelectIndexPathAction = ^void(TableViewBase* tableViewObj, NSIndexPath* indexPath) {
        NSIndexPath* realIndexPath = [(FilterTableView*)tableViewObj getRealIndexPathInFilterMode: indexPath];
//        NSArray* usersCtontens = [tableViewObj realContentForIndexPath: realIndexPath];
        selectNumber = [tableViewObj realContentForIndexPath: realIndexPath]; //[usersCtontens objectAtIndex: 1];
        if (selectAction) selectAction(selectNumber);
    };
    searchTableView.tableView.headerTableViewHeaderHeightAction = ^CGFloat(HeaderTableView* tableViewObj) {
         return [FrameTranslater convertCanvasHeight: 25.0f];
    };

    // cancel button
    JRButton* cancelBtn = searchTableView.leftButton ;
    [cancelBtn setTitle:LOCALIZE_KEY(@"CANCEL") forState:UIControlStateNormal];
    cancelBtn.didClikcButtonAction = ^void(id sender) {
        [PopupViewHelper dissmissCurrentPopView];
        if (cancelAction) cancelAction(sender);
    };
    

    // send button
    JRButton* sendBtn = searchTableView.rightButton;
    [sendBtn setTitle:LOCALIZE_KEY(@"SEND") forState:UIControlStateNormal];
    sendBtn.didClikcButtonAction = ^void(id sender) {
        // alert ....
        if (OBJECT_EMPYT(selectNumber)) {
            [AppViewHelper alertWarning: LOCALIZE_MESSAGE(MESSAGE_SelectNextLevelApp)];
            return ;
        }
        if (sendAction) sendAction(sender, selectNumber);
    };
    
    // title label
    searchTableView.titleLabel.text = LOCALIZE_MESSAGE(MESSAGE_SelectNextLevelApp);

    [PopupViewHelper popView: superView willDissmiss:nil];
}

+(void) setEmployeesNumbersNames:(TableViewBase*)tableViewBase numbers:(NSMutableArray*)numbers
{
    // numbers
    [numbers sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare: obj2];
    }];
    // numbers and username
    NSMutableArray* contentsTemp = [NSMutableArray array];
    [IterateHelper iterate: numbers handler:^BOOL(int index, id obj, int count) {
        NSString* name = MODEL.usersNONames[obj];
        if (! name){
            if (IS_SUPERUSER(MODEL.signedUserId)) {
                name = LOCALIZE_KEY(@"ADMINISTRATOR");
            } else {
                name = @"<Deleted ???>";
            }
        }
        [contentsTemp addObject: @[obj, name]];
        return NO;
    }];
    tableViewBase.contentsDictionary = [NSMutableDictionary dictionaryWithObject:contentsTemp forKey:@""];
    tableViewBase.realContentsDictionary = [NSMutableDictionary dictionaryWithObject:numbers forKey:@""];
}


+(NSMutableArray*) getApprovalsUsers: (NSString*)app department:(NSString*)department order:(NSString*)orderOrBill
{
    NSString* orderType = [self getOrderType: orderOrBill];
    
    // assemble approvals users list
    NSDictionary* approvalsettings = [[[MODEL.approvalSettings objectForKey: department] objectForKey: orderOrBill] objectForKey:app ];
    NSArray* approvalUsers = [approvalsettings objectForKey: APPSettings_APPROVALS_USERS];
    
    // FOR TEST
    if (! approvalUsers) {
        if ([VIEW isTestDevice]) {
            approvalUsers = [MODEL.usersNONames allKeys];
        }
    }
    if (IS_SUPERUSER(MODEL.signedUserId)) {
        approvalUsers = @[MODEL.signedUserName];
    }
    
    NSMutableArray* users = [ArrayHelper deepCopy: approvalUsers];
    if (!IS_SUPERUSER(MODEL.signedUserId)) {
        
        NSUInteger level = [[[approvalsettings objectForKey: APPSettings_APPROVALS_PRAMAS] objectForKey:APPSettings_APPROVALS_PRAMAS_LEVEL] integerValue];
        if (level != 0) {
            for (NSString* username in MODEL.usersNOLevels) {
                NSNumber* userLevel = MODEL.usersNOLevels[username];
                if ([userLevel integerValue] <= level) {
                    if (! [users containsObject: username]) {
                        [users addObject: username];
                    }
                }
            }
        }
        for (int i = 0; i < users.count; i++) {
            NSString* username = [users objectAtIndex: i];
            BOOL isHaveReadPermission = [PermissionChecker check: username department:department order:orderType permission:PERMISSION_READ];
            if (! MODEL.usersNONames[username] || ! [MODEL.usersNOApproval[username] boolValue] || [MODEL.usersNOResign[username] boolValue] || ! isHaveReadPermission ) {
                [users removeObject: username];
                i--;
            }
        }
        
    }
    return [ArrayHelper eliminateDuplicates: users];
}


+(NSString*) getOrderType: (NSString*)orderOrBill
{
    NSString* orderType = orderOrBill;
    NSDictionary* modelStructs = [MODEL.modelsStructure getInsertModelsDefine];
    for (NSString* orderKey in modelStructs) {
        NSArray* values = modelStructs[orderKey];
        if ([values containsObject: orderOrBill]) {
            orderType = orderKey;
        }
    }
    return orderType;
}



#pragma mark -
+(NSString*) getUserName: (NSString*)number
{
    NSString* userName = [MODEL.usersNONames objectForKey:number];
    if (!userName && IS_SUPERUSER(MODEL.signedUserId)) {
        userName = LOCALIZE_KEY(@"ADMINISTRATOR");
    }
    return userName;
}

// ["1","2"] -> [["1", "1Name"], ["2", "2Name"]]
+(NSMutableArray*) getUserNumbersNames: (NSArray*)numbers
{
    NSMutableArray* contents = [NSMutableArray array];
    
    for (int i = 0; i < numbers.count; i++) {
        NSMutableArray* cellValues = [NSMutableArray array];
        NSString* employeeNO = [numbers objectAtIndex:i];
        
        NSString* employeeName = MODEL.usersNONames[employeeNO];
        
        [cellValues addObject: employeeNO];
        if (employeeName) {
            [cellValues addObject: employeeName];
        }
        
        [contents addObject:cellValues];
    }
    
    return contents;
}


@end
