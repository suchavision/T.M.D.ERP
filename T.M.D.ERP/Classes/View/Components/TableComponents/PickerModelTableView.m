#import "PickerModelTableView.h"
#import "AppInterface.h"


@implementation PickerModelTableView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frame = [FrameTranslater convertCanvasRect: CGRectMake(0, 0, 650, 500)];
        
        self.tableView.searchBarHeight = [FrameTranslater convertCanvasHeight: 45];
        
        self.tableView.headersXcoordinates = @[@(50) , @(250), @(450)];
        
    }
    return self;
}


//- (id)initWithModel: (NSString*) model
//{
//    self = [super init];
//    if (self) {
//        // set frame
//                // title
//        self.titleLabel.text = LOCALIZE_KEY(model);
//        
//        // set data to table
//        NSArray* headers = nil;
//        NSMutableDictionary* contents = nil;
//        NSMutableDictionary* realContents = nil;
//        
//        if ([model isEqualToString: MODEL_EMPLOYEE]) {
//            self.titleLabel.text = LOCALIZE_KEY(KEY_EMPLOYEE);
//            
//            headers = @[ LOCALIZE_KEY(@"employeeNO") , LOCALIZE_KEY(@"name")  ];
//            
//            // filter the resigned
//            NSMutableArray* numbers = [ArrayHelper deepCopy: [MODEL.usersNONames allKeys]];
//            for (int i = 0; i < numbers.count; i++) {
//                NSString* username = numbers[i];
//                if ([MODEL.usersNOResign[username] boolValue]) {
//                    [numbers removeObject: username];
//                    i--;
//                }
//            }
//            
//            [PickerModelTableView setEmployeesNumbersNames:self.tableView.tableView numbers:numbers];
//            
//        } else if ([model isEqualToString: MODEL_VENDOR]) {
//            
//            
//            
//        } else if ([model isEqualToString: MODEL_CLIENT]) {
//            
//        }
//        
//        self.tableView.searchBarHeight = [FrameTranslater convertCanvasHeight: 45];
//        if (headers) {
//            self.tableView.headers = headers;
//            self.tableView.headersXcoordinates = @[@(50) , @(305)];
//        }
//        if (contents) self.tableView.tableView.contentsDictionary = contents;
//        if (realContents) self.tableView.tableView.realContentsDictionary = realContents;
//    }
//    return self;
//}



//+(void) setEmployeesNumbersNames:(TableViewBase*)tableViewBase numbers:(NSMutableArray*)numbers
//{
//    // numbers
//    [numbers sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        return [obj1 compare: obj2];
//    }];
//    // numbers and username
//    NSMutableArray* contentsTemp = [NSMutableArray array];
//    [IterateHelper iterate: numbers handler:^BOOL(int index, id obj, int count) {
//        NSString* name = MODEL.usersNONames[obj];
//        if (! name){
//            if (IS_SUPERUSER(MODEL.signedUserId)) {
//                name = LOCALIZE_KEY(@"ADMINISTRATOR");
//            } else {
//                name = @"<Deleted ???>";
//            }
//        }
//        [contentsTemp addObject: @[obj, name]];
//        return NO;
//    }];
//    tableViewBase.contentsDictionary = [NSMutableDictionary dictionaryWithObject:contentsTemp forKey:@""];
//    tableViewBase.realContentsDictionary = [NSMutableDictionary dictionaryWithObject:numbers forKey:@""];
//}



#pragma mark - Class Pair Methods

+(PickerModelTableView*) popupWithModel:(NSString*)model
{
    NSArray* fields = nil;
    
    if ([model isEqualToString: MODEL_EMPLOYEE]) {
        fields = @[@"employeeNO", @"name"];                         // TODO: Resigned Employee not show , but EmployeeCHOrderController should show out .
        
    } else if ([model isEqualToString: MODEL_VENDOR]) {
        fields = @[@"number", @"name", @"category"];
        
    } else if ([model isEqualToString: MODEL_CLIENT]) {
        fields = @[@"number", @"name", @"category"];
        
    }else if ([model isEqualToString:MODEL_FinanceAccount])
        fields = @[@"number",@"name"];
    
    return [self popupWithRequestModel:model fields:fields];
}

+(PickerModelTableView*) popupWithRequestModel:(NSString*)model fields:(NSArray*)fields
{
    return [self popupWithRequestModel:model fields:fields criterias:nil];
}

+(PickerModelTableView*) popupWithRequestModel:(NSString*)model fields:(NSArray*)fields criterias:(NSDictionary*)criterias
{
    PickerModelTableView* pickerView = [[PickerModelTableView alloc] init];
    
    
    // title
    pickerView.titleLabel.text = LOCALIZE_KEY(model);
    
    
    // headers
    NSMutableArray* localizeHeaders = [NSMutableArray array];
    for (int i = 0; i < fields.count; i++) {
        [localizeHeaders addObject: LOCALIZE_CONNECT_KEYS(model, fields[i])];
    }
    pickerView.tableView.headers = [LocalizeHelper localize: localizeHeaders];
    
    
    // assemble request
    NSString* department = [MODEL.modelsStructure getCategory: model];
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_READ(department);
    [requestModel addModel: model];
    
    // insert id to field
    NSMutableArray* withIdFields = [ArrayHelper deepCopy: fields];
    [withIdFields insertObject: PROPERTY_IDENTIFIER atIndex:0];
    [requestModel.fields addObject: withIdFields];
    if (criterias)[requestModel.criterias addObject:criterias];
    
    // get data from server
    HTTPRequester* requester = MODEL.requester;
    [AppViewHelper showIndicatorInView: pickerView];
    [requester startPostRequest:requestModel completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        [AppViewHelper stopIndicatorInView: pickerView];
        if (model.status) {
            TableViewBase* tableView = pickerView.tableView.tableView;
            NSArray* results = model.results;
            NSArray* models = model.models;
            ContentFilterBlock contentFilterBlock = ^void(int elementIndex , int innerCount, int outterCount, NSString* section, id cellElement, NSMutableArray* cellRepository) {
                // filter the id
                if (elementIndex != 0) if (cellElement) [cellRepository addObject: cellElement];
            };
            
            // assemble the contentsDctionary and realContentsDictionary to table
            [ListViewControllerHelper assembleTableContents: tableView objects:results keys:models filter:contentFilterBlock];
            
            
            [pickerView.tableView reloadTableData];
        } else {
            [AppViewHelper alertError: error];
        }
    }];
    
    
    // if dismiss , cancel the request to release network resource
    [PopupViewHelper popView: pickerView inView:VIEW.navigator.view tapOverlayAction:nil willDissmiss:^(UIView *view) {
        [requester cancelRequester];
    }];
    
    [ViewHelper setShadowWithCorner:pickerView config:@{@"cornerRadius":@(5.0)}];
    
    return pickerView;
    
}



+(void) dismiss
{
    [PopupViewHelper dissmissCurrentPopView];
}


@end
