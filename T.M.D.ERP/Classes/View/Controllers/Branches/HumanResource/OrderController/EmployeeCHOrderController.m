#import "EmployeeCHOrderController.h"
#import "AppInterface.h"



#define OLD_SUFFIX @"_O"
#define NEW_SUFFIX @"_N"



@implementation EmployeeCHOrderController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    __weak EmployeeCHOrderController* weakInstance = self;
    
    JsonView* jsonView = self.jsonView;
    
    JRImageView* photoImageView = (JRImageView*)[jsonView getView: @"IMG_Photo_old"];
    
    // employeeNO. button
    JRTextField* employeeNOBTN = ((JRLabelCommaTextFieldView*)[jsonView getView: PROPERTY_EMPLOYEENO]).textField;
    employeeNOBTN.textFieldDidClickAction = ^void(id sender) {
        // popup a table
        PickerModelTableView* pickView = [PickerModelTableView popupWithModel:MODEL_EMPLOYEE];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            
            NSString* employeeNO = [filterTableView realContentForIndexPath: realIndexPath];
            NSDictionary* objects = @{PROPERTY_EMPLOYEENO: employeeNO};
            [VIEW.progress show];
            
            [AppServerRequester readModels: @[MODEL_EMPLOYEE, ORDER_EmployeeCHOrder] department:DEPARTMENT_HUMANRESOURCE objects:@[objects,objects] fields:nil limits:@[@[],@[@(0),@(1)]] sorts:@[@[],@[DOT_CONNENT(@"createDate", SORT_DESC)]] completeHandler:^(ResponseJsonModel *response, NSError *error) {
                
                [VIEW.progress hide];
                if (error) {
                    [AppViewHelper alertError: error];
                } else {
                    
                    
                    // info
                    NSDictionary* employeeInfo = [[response.results firstObject] firstObject];
                    if (![JsonControllerHelper isAllApplied: MODEL_EMPLOYEE valueObjects:employeeInfo]) {
                        [JsonOrderCreateHelper cannotCreateAlert:weakInstance.order causeOrder:MODEL_EMPLOYEE department:DEPARTMENT_HUMANRESOURCE identifier:employeeInfo[PROPERTY_IDENTIFIER] employeeNO:employeeInfo[PROPERTY_EMPLOYEENO] objects:employeeInfo];
                        return ;
                    }
                    
                    // ch info
                    NSDictionary* employeeChInfo = [[response.results lastObject] firstObject];
                    if (employeeChInfo && ! [JsonControllerHelper isAllApplied: ORDER_EmployeeCHOrder valueObjects:employeeChInfo]) {
                        [JsonOrderCreateHelper cannotCreateAlert:weakInstance.order causeOrder:ORDER_EmployeeCHOrder department:DEPARTMENT_HUMANRESOURCE identifier:employeeChInfo[PROPERTY_IDENTIFIER] employeeNO:employeeChInfo[PROPERTY_EMPLOYEENO] objects:employeeChInfo];
                        return;
                    }
                    
                    
                    NSMutableDictionary* objects = [DictionaryHelper deepCopy: employeeInfo];
                    if (objects[@"livingAddress"]) [objects setObject:[AppRSAKeysKeeper simpleDecrypt:objects[@"livingAddress"]] forKey:@"livingAddress"];
                    NSArray* excepts = @[PROPERTY_EMPLOYEENO];
                    
                    NSMutableDictionary* oldModel = [DictionaryHelper tailKeys: objects with:OLD_SUFFIX excepts:excepts];
                    NSMutableDictionary* newModel = [DictionaryHelper tailKeys: objects with:NEW_SUFFIX excepts:excepts];

                    // Automatic fill the textfield .
                    [jsonView clearModel];
                    [jsonView setModel: oldModel];      // set the old
                    [jsonView setModel: newModel];      // set the new
                    [jsonView setModel: @{PROPERTY_EMPLOYEENO: employeeInfo[PROPERTY_EMPLOYEENO]}];  // set the unchanged
                    
                    // Load the Original Photo
                    weakInstance.valueObjects = oldModel;
                    NSString* originalPhotoPath = [JsonControllerHelper getImageNamePathWithOrder: MODEL_EMPLOYEE attribute:@"IMG_Photo" jsoncontroller:weakInstance];
                    
                    [AppViewHelper showIndicatorInView:photoImageView];
                    [AppServerRequester getImage: originalPhotoPath completeHandler:^(id identification, UIImage *image, NSError *error) {
                        [AppViewHelper stopIndicatorInView: photoImageView];
                        photoImageView.image = image;
                    }];
                }
            }];
            
            [PickerModelTableView dismiss];
        };
    };
    
    
    // OVERRIDE THE APP4 BUTTON
    JRButton* app4Button = ((JRButtonTextFieldView*)[jsonView getView:@"NESTED_footer.app4"]).button;
    NormalButtonDidClickBlock preClickAction = app4Button.didClikcButtonAction;
    app4Button.didClikcButtonAction = ^void(JRButton* button){
        preClickAction(button); // call super/ old;
        
        NSString* originalPhotoPath = [JsonControllerHelper getImageNamePathWithOrder: MODEL_EMPLOYEE attribute:@"IMG_Photo" jsoncontroller:weakInstance];
        
        NSString* newPhotoPath = [JsonControllerHelper getImageNamePathWithOrder: ORDER_EmployeeCHOrder attribute:@"IMG_Photo_new" jsoncontroller:weakInstance];
        [MODEL.requester startPostRequest:IMAGE_URL(@"replace") parameters:@{@"PATH":newPhotoPath, @"DESTINATION_PATH":originalPhotoPath} completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
            NSLog(@"DONE!!!!~~~~~~~~");
        }];
    };
}

#pragma mark - Override Super Class
-(BOOL) validateSendObjects: (NSMutableDictionary*)objects order:(NSString*)order
{
    NSString* workMask = [((id<JRComponentProtocal>)[self.jsonView getView:@"password_N"]) getValue];
    if (!OBJECT_EMPYT(workMask)) {
        if (workMask.length < 7 || [workMask rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound || [workMask rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound) {
            [AppViewHelper alertMessage:LOCALIZE_MESSAGE(@"PasswordEnhanced")];
            return NO;
        }
    }
    
    return [super validateSendObjects:objects order:order];
}

-(void)translateSendObjects:(NSMutableDictionary *)objects order:(NSString *)order
{
    [super translateSendObjects:objects order:order];
    
    // rsa
    if (objects[@"password_N"]) {
        NSString* encryptWordMask = [AppRSAHelper encrypt: objects[@"password_N"]];
        if (encryptWordMask) {
            [objects setObject: encryptWordMask forKey:@"password_N"];
        }
    }
    //
    if (objects[@"livingAddress_O"]) [objects setObject:[AppRSAKeysKeeper simpleEncrypty:objects[@"livingAddress_O"]] forKey:@"livingAddress_O"];
    if (objects[@"livingAddress_N"]) [objects setObject:[AppRSAKeysKeeper simpleEncrypty:objects[@"livingAddress_N"]] forKey:@"livingAddress_N"];
}

-(void)translateReceiveObjects:(NSMutableDictionary *)objects
{
    [super translateReceiveObjects:objects];
    
    if (![JsonControllerHelper isAllApplied: self.order valueObjects:objects]) {
        NSString* decryptWordMask = [AppRSAHelper decrypt: objects[@"password_N"]];
        [objects setObject: decryptWordMask forKey:@"password_N"];
    }
    
    //
    if (objects[@"livingAddress_O"]) [objects setObject:[AppRSAKeysKeeper simpleDecrypt:objects[@"livingAddress_O"]] forKey:@"livingAddress_O"];
    if (objects[@"livingAddress_N"]) [objects setObject:[AppRSAKeysKeeper simpleDecrypt:objects[@"livingAddress_N"]] forKey:@"livingAddress_N"];
}


@end
