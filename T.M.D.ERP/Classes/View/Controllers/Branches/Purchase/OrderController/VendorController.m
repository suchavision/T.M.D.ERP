#import "VendorController.h"
#import "AppInterface.h"


@interface VendorController()

@property  (strong)  NSDictionary* renderObjects;

@end


@implementation VendorController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    __weak VendorController* weakInstance = self;
    
    JsonView* jsonView = self.jsonView;

    JRButton *cancelButton = (JRButton *)[self.jsonView getView:@"NESTED_BODY_FOOTER.CANCEL"];
    cancelButton.didClikcButtonAction = ^void(UIButton* button) {
        [weakInstance.jsonView setModel: weakInstance.renderObjects];
    };
    JRTextField* categoryTxtFidld = ((JRLabelTextFieldView*)[self.jsonView getView:@"NESTED_INFO.category"]).textField;
    categoryTxtFidld.textFieldDidClickAction = ^void(JRTextField* jrTextField) {
//        [WarehouseHelper popTableView:jrTextField settingModel:APPSettings_PURCHASE_VENDOR_CATEGORY];
        [WarehouseHelper popTableView:jrTextField settingModel:APPSettings_PURCHASE_VENDOR_CATEGORY title:nil];

        
    };
    
    
    //----------- Another Tabs Views
    JRRefreshTableView* goodInTableView = (JRRefreshTableView*)[jsonView getView:@"NESTED_GOODIN.GOODIN_TABLE"];
    JRRefreshTableView* borrowoutTableView = (JRRefreshTableView*)[jsonView getView:@"NESTED_BORROWOUT.BORROWOUT_TABLE"];
    
    self.didShowTabView = ^void(int index, JsonDivView* tabView) {
        NSString* number = [((id<JRComponentProtocal>)[jsonView getView: @"NESTED_INFO.number"]) getValue];     // Vendor number
        NSString* category = [((id<JRComponentProtocal>)[jsonView getView: @"NESTED_INFO.category"]) getValue]; // Vendor category
        // Good In order
        if (index == 1) {
            
            goodInTableView.tableView.contentsDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"aaaa":@[@"Loading", @"fdsafda"]}];
            [goodInTableView reloadTableData];
            // Lend Out Order
        } else if(index == 2) {
            borrowoutTableView.tableView.contentsDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"aaaa":@[@"fadsaf", @"Loading"]}];
            [borrowoutTableView reloadTableData];
            
            
            [VIEW.progress show];
            [AppServerRequester readModel: @"WHLendOutOrder" department:@"Warehouse" objects:@{@"staffNO": number, @"staffCategory": category} fields:@[PROPERTY_IDENTIFIER, PROPERTY_ORDERNO, @"lendAmount"] completeHandler:^(ResponseJsonModel *data, NSError *error) {
                [VIEW.progress hide];
                
                NSArray* objects = data.results;
                NSArray* keys = data.models;
                
                [ListViewControllerHelper assembleTableContents:borrowoutTableView.tableView objects:objects keys:keys filter:nil];
                
                [borrowoutTableView reloadTableData];
                
                NSLog(@"fkdlakfldsa");
            }];
        }
    };
}


-(void) renderWithReceiveObjects: (NSMutableDictionary*)objects
{
    [super renderWithReceiveObjects:objects];
    
    self.renderObjects = objects;
}

-(void) enableViewsWithReceiveObjects: (NSMutableDictionary*)objects
{
    [super enableViewsWithReceiveObjects:objects];
    
    BOOL isCandelete = [PermissionChecker checkSignedUser:self.department order:self.order permission:PERMISSION_DELETE];
    BOOL isCanCreate = [PermissionChecker checkSignedUser:self.department order:self.order permission:PERMISSION_CREATE];
    if(isCandelete || isCanCreate)
    {
        self.controlMode = JsonControllerModeModify;
        JRButton* Submitbutton = (JRButton*)[self.jsonView getView:@"ZZ_BTNSubmit"];
        Submitbutton.enabled = YES;
    }
}

@end
