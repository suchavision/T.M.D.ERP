#import "GeneralEditController.h"
#import "AppInterface.h"


@implementation GeneralEditController



@synthesize apnsSettingsTableView;


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    
    
    // -------------+++++++++++++ Load the settings From Server  +++++++++++++++-------------------------
    [VIEW.progress show];
    [AppServerRequester readSetting: [self getSettingType] completeHandler:^(ResponseJsonModel *response, NSError *error) {
        [VIEW.progress hide];
        if (! error) {
            NSDictionary* results = [CollectionHelper convertJSONStringToJSONObject: response.results[@"settings"]];
            if (self.APNSDidGetDataFromServerAction) {
                self.APNSDidGetDataFromServerAction(self, results);
            } else {
                [self setDataToViews: results[APNS_RESULTS_USERS] parameters:results[APNS_RESULTS_PARAMETERS]];
            }
        }
    }];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
    // check if pop or push ?
    
    if ([VIEW.navigator.viewControllers containsObject:self]) {
        DLOG(@"It is push now , no need to save .");
        return;
    } else {
        DLOG(@"It is Pop now , should need to save .");
    }
    
    
    // -------------+++++++++++++ Save the settings to Server  +++++++++++++++-------------------------
    NSMutableDictionary* results = nil;
    
    if (self.APNSGetDataSendToServerAction) {
        results = self.APNSGetDataSendToServerAction(self);
    } else {
        results = [NSMutableDictionary dictionary];
        [self getViewsDataTo: results];
    }
    
    NSString* json = [CollectionHelper convertJSONObjectToJSONString:results];
    [AppServerRequester modifySetting: [self getSettingType] json:json completeHandler:^(ResponseJsonModel *data, NSError *error) {
        if (error) {
            [AppViewHelper alertMessage: @"Settings Failed , please try again later."];
        }
    }];
    
}

-(void) initializeTableHeaderAddButtonView
{
    [self setAutomaticallyAdjustsScrollViewInsets: NO];
    apnsSettingsTableView = [[TableHeaderAddButtonView alloc] init];
    
    apnsSettingsTableView.headers = [LocalizeHelper localize: @[PROPERTY_EMPLOYEENO, PROPERTY_EMPLOYEE_NAME]];
    apnsSettingsTableView.headersXcoordinates = @[@(20), @(200)];
    apnsSettingsTableView.valuesXcoordinates = @[@(10), @(200)];
    apnsSettingsTableView.tableView.tableViewBaseCanEditIndexPathAction = ^BOOL(TableViewBase* tb, NSIndexPath* indexPath) {
        return YES;
    };
    apnsSettingsTableView.frame = CanvasRect(0, 80, 500, 400);
    [ColorHelper setBorder: apnsSettingsTableView color:[UIColor grayColor]];
    CGSize size = [RectHelper getScreenLandscapeSize];
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    [apnsSettingsTableView setCenterX: bounds.size.width/2];
    // add button event
    
    __weak TableHeaderAddButtonView* weakApprovalView = apnsSettingsTableView;
    apnsSettingsTableView.addButton.didClikcButtonAction = ^void(NormalButton* button) {
        
        PickerModelTableView* pickView = [PickerModelTableView popupWithModel:MODEL_EMPLOYEE];
        
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [headerTableView.tableView.tableView getRealIndexPathInFilterMode: indexPath];
            
            NSString* employeeNO = [filterTableView realContentForIndexPath: realIndexPath];
            NSArray* contents = [filterTableView contentForIndexPath: indexPath];
            
            [PopupViewHelper popAlert: nil message:LOCALIZE_MESSAGE_FORMAT(@"AskSureToAddApproval", MODEL.usersNONames[employeeNO]) style:0 actionBlock:^(UIView *popView, NSInteger index) {
                if (index == 1) {
                    [TableViewBaseContentHelper insertToFirstRowWithAnimation: weakApprovalView.tableView section:0 content:contents realContent:employeeNO];
                }
            } dismissBlock:nil buttons:LOCALIZE_KEY(@"CANCEL"), LOCALIZE_KEY(@"OK"), nil];
            
        };
        
    };
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (apnsSettingsTableView) {
        [self.view addSubview: apnsSettingsTableView];
    }
    
    
}



#pragma mark - Public Methods
-(NSString*) getSettingType
{
    return [@"ADMIN_" stringByAppendingString: self.apnsType];
}

-(void) setDataToViews: (NSArray*)users parameters:(NSDictionary*)parameters
{
    // users
    NSMutableArray* contents = [ViewControllerHelper getUserNumbersNames:users];
    apnsSettingsTableView.tableView.contentsDictionary = [NSMutableDictionary dictionaryWithObject:contents forKey:@""];
    [apnsSettingsTableView reloadTableData];
    
    // parameters
    JsonDivView* divView = (JsonDivView*)[self.view viewWithTag: APNSEditControllerJSONDivTag];
    if (divView) {
        [divView clearModel];
        [divView setModel: parameters];
    }
}

-(void) getViewsDataTo: (NSMutableDictionary*)results
{
    // users
    NSArray* users = [apnsSettingsTableView.tableView contentsForSection:0];
    NSMutableArray* numbers = [NSMutableArray array];
    for (int i = 0 ; i < users.count; i++) [numbers addObject:[users[i] firstObject]];
    [results setObject: numbers forKey:APNS_RESULTS_USERS];
    // parameters
    JsonDivView* divView = (JsonDivView*)[self.view viewWithTag: APNSEditControllerJSONDivTag];
    if (divView) {
        NSDictionary* parameters = [divView getModel];
        [results setObject: parameters forKey:APNS_RESULTS_PARAMETERS];
    }
}



@end
