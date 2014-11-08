 #import "LoginViewController.h"
#import "AppInterface.h"

#define ScheduledTaskTime 10


@interface LoginViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@end

@implementation LoginViewController
{
    JsonView* jsonview;
    
    JRTextField *userNameTextField;
    JRTextField *passwordTextField;
    
    JRImageView* verfiyImageView;
    JRTextField *verifyCodeTextField;
    
    JRCheckBox* userCheckBox ;
    JRCheckBox* passwordCheckBox ;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self getConnectToServer];
    [EVENT destroyReleaseableProcedure];
    
    // get the save username & password
    NSArray* array = [MODEL.appSqlite selectFirstUserNameAndPassword];
    NSString* username = [array firstObject];
    NSString* password = [array lastObject];
    userNameTextField.text = username;
    passwordTextField.text = password;
    if (!OBJECT_EMPYT(username)) {
        userCheckBox.checked = YES;
    }
    if (!OBJECT_EMPYT(password)) {
        passwordCheckBox.checked = YES;
    }
}


#pragma mark - Double Tap Gesture Recognizer

-(void) doubleTapAction: (UITapGestureRecognizer*)doubleTapGesture
{
    [[KeyBoardHelper sharedInstance] setKeyboardDistanceFromTextField: CanvasH(85)];
    [jsonview setZoomScale: 1.0 animated: YES];
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (jsonview.zoomScale == 1.0) return NO;
    return YES;
}

#pragma mark - UITextFieldDelegate Methods
// userNameTextField , passwordTextField , verifyCodeTextField
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[KeyBoardHelper sharedInstance] setKeyboardDistanceFromTextField: CanvasH(160)];
        if (jsonview.zoomScale != 2.0) [jsonview setZoomScale: 2.0 animated:YES];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - JSON VIEW TEST HERE
-(UIButton*) getLanguageButtonForTest
{
    // for test , remove in production
    [MODEL.modelsStructure renderModels: nil];
    NSMutableDictionary* categories = [DictionaryHelper deepCopy: [MODEL.modelsStructure getAllOders:YES]];
    if (!categories[CATEGORIE_SHAREDORDER]) [categories setObject:[NSMutableArray array] forKey:CATEGORIE_SHAREDORDER];
    if (!categories[DEPARTMENT_VEHICLE]) [categories setObject:[NSMutableArray array] forKey:DEPARTMENT_VEHICLE];
    [categories[DEPARTMENT_SECURITY] addObject:@"SecurityJournalOrder"];
    [categories[DEPARTMENT_FINANCE] addObject:@"FinanceReceiptOrder"];
    
    [CategoriesLocalizer setCategories: categories];
    [AppDataHelper dealWithSignedBasicData: nil];
    
    // language button
    NormalButton* languageButton = [[NormalButton alloc] init];
    languageButton.backgroundColor = WHITE_COLOR;
    languageButton.didClikcButtonAction = ^(UIButton* button) {
        
        NSArray* localizeLanguages = [LocalizeHelper localize: LANGUAGES];
        [PopupViewHelper popSheet: @"Select a language" inView:button.superview actionBlock:^(UIView *popView, NSInteger index) {
            if (index >= 0 && index < LANGUAGES.count) {
                NSString* languageSelected = LANGUAGES[index];
                [CategoriesLocalizer setCurrentLanguage: languageSelected];
                
                // Set Preference Language
                [[NSUserDefaults standardUserDefaults] setObject: languageSelected forKey: PREFERENCE_LANGUAGE];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                UIView* view = [VIEW.navigator topViewController].view;
                for (UIView* subView in view.subviews) {
                    if ([subView isKindOfClass:[JsonView class]]){
                        JsonView* jsonview_ = (JsonView*)subView;
                        [JsonViewHelper refreshJsonViewLocalizeText: jsonview_];
                    }
                }
                
            }
        } buttonTitles: localizeLanguages];
        
    };
    languageButton.frame = CGRectMake(10, 200, 50, 20);
    [ColorHelper setBorder: languageButton];
    return languageButton;
}

- (void) previewJsonView
{
#pragma mark - JSON VIEW TEST HERE
    

//        JsonController* jsonController = [[EmployeeController alloc] initWithOrder:@"Employee" department:DEPARTMENT_HUMANRESOURCE];
    JsonController* jsonController = [[PurchaseRequisitionOrderController alloc] initWithOrder:@"PurchaseRequisitionOrder" department:DEPARTMENT_PURCHASE];

//        JsonController* jsonController = [[WHInventoryController alloc] initWithOrder:@"PurchaseOrder" department:DEPARTMENT_WAREHOUSE];
//        JsonController* jsonController = [[FinanceReceiptOrderController alloc] initWithOrder:@"FinanceReceiptOrder" department:DEPARTMENT_FINANCE];
//        JsonController* jsonController = [[JsonController alloc] initWithOrder:@"EmployeeCHOrder" department:DEPARTMENT_HUMANRESOURCE];
//        UIViewController* jsonController = [AdminControllerDispatcher dispatchToOtherSettingsController];
//        [ColorHelper setBorderRecursive: jsonController.jsonView];
    
    [VIEW.navigator pushViewController: jsonController animated:YES];
    
    UIButton* langurageButton = [self getLanguageButtonForTest];
    [jsonController.view addSubview: langurageButton];
    [ColorHelper setBorderRecursive: jsonController.view];

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self previewJsonView];
//    return;
    
    
#pragma mark - Json View
    __weak LoginViewController* weakInstance = self;
    jsonview =  (JsonView*)[JsonViewRenderHelper renderFile:@"Views" specificationsKey:@"LoginView"];
    CGRect rect = self.view.bounds;
    rect.size = [RectHelper getScreenLandscapeSize];
    [jsonview setViewFrame: rect];
    [ColorHelper clearBorderRecursive: jsonview];
    
    [self.view addSubview: jsonview];
    
    
    // Check box
    userCheckBox = ((JRLabelCheckBoxView*)[jsonview getView: @"rememberUserName"]).checkBox;
    passwordCheckBox = ((JRLabelCheckBoxView*)[jsonview getView: @"rememberPawword"]).checkBox;
    
    // verify code
    verifyCodeTextField = (JRTextField*)[jsonview getView: @"verifyCode"];
    verfiyImageView = (JRImageView*)[jsonview getView: @"IMG_VerifyCodeImg"];
    verfiyImageView.didClickAction = ^(JRImageView* imageView) {
        [weakInstance getConnectToServer];
    };
    
    // username & password
    userNameTextField = ((JRLabelCommaTextFieldView*)[jsonview getView: @"username"]).textField;
    passwordTextField = ((JRLabelCommaTextFieldView*)[jsonview getView: @"password"]).textField;
    
    // For zooming
    userNameTextField.delegate = self;
    passwordTextField.delegate = self;
    verifyCodeTextField.delegate = self;
    
    UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.delegate = self;
    [jsonview addGestureRecognizer: doubleTapGesture];
    
    
    // lauguage setting
    JRButton* languageButton = ((JRLabelButtonView*)[jsonview getView: @"languageSet"]).button;
    __weak JsonView* weakJsonView = jsonview;
    languageButton.didClikcButtonAction = ^(id button) {
        [AppViewHelper refreshLocalizeTextBySelectLanguage: weakJsonView];
    };
    
    
    // login button
    JRButton* loginButton = (JRButton*)[jsonview getView: @"loginBtn"];
    loginButton.didClikcButtonAction = ^(id sender) {
        [weakInstance loginRequestAction];
    };
    
    [JsonViewHelper refreshJsonViewLocalizeText: jsonview];
}

#pragma mark - Private Methods

-(void) getConnectToServer
{
    RequestJsonModel* model = [RequestJsonModel getJsonModel];
    model.path = PATH_SETTING(@"getConnection");
    
    // show indicator
    [AppViewHelper showIndicatorInViewAndDisableInteraction: verfiyImageView];
    [MODEL.requester startPostRequest:model completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        [AppViewHelper stopIndicatorInViewAndEnableInteraction: verfiyImageView];
        if (error) {
            [AppViewHelper alertError: error];
        } else if (data.status){
            NSDictionary* allHeaders = [httpURLReqponse allHeaderFields];
            NSString* cookie = [allHeaders objectForKey: HTTP_RES_HEADER_COOKIE];
            if (cookie) {
                // data cookie
                MODEL.cookies = cookie;
                DLOG(@" ------ Models Structure & Set Cookie Success");
            }
            
            // initialize the administrators
            if ([data.descriptions isEqualToString:HR_INITAILIZED_ADMIN_KEY]) {
                [AdministratorAction initializeAdministrator];
            }
            
            // data modelstructure
            [MODEL.modelsStructure renderModels: data.results];
            [CategoriesLocalizer setCategories: [MODEL.modelsStructure getAllOders: YES]];
            
            // verify code
            UIImage *image = [UIImage imageWithData:data.binaryData];
            if (image) verfiyImageView.image = image;
        }
    }];
}


-(void)loginRequestAction
{

    NSString* verifyCode = verifyCodeTextField.text ? verifyCodeTextField.text : @"" ;
//           if (OBJECT_EMPYT(verifyCode)) {
//           [AppViewHelper alertWarning: @"Verify Code Cannot Be Empty!"];
//            return;
//        }
//    NSData* data = UIImagePNGRepresentation([UIImage imageNamed:@"camera.png"]);
//    NSString* fileName = @"/Users/isaacs/Desktop/camera.png";
//    NSDictionary* parameters = @{UPLOAD_Data: data, UPLOAD_FileName: fileName, UPLOAD_MIMEType: @"image/png"};
//    HTTPUploader* uploader = [[HTTPUploader alloc] initWithURLString:@"http://127.0.0.1:7072/ERPWebServer/resource/upload" parameters:parameters timeoutInterval:100];
//    
//    [uploader startRequest:^(HTTPRequestBase *httpRequest, NSURLResponse *response, NSData *data, NSError *connectionError) {
//       
//        NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@, %@", response, string);
//        
//        
//    }];
//    
//    return;
    
    
    NSString* tokenStr = [UserInstance sharedInstance].DGUDID;
    NSString* username = [userNameTextField getValue];
    NSString* password = [passwordTextField getValue];
    
    [UserInstance sharedInstance].userJobNum = username;
    [UserInstance sharedInstance].userPwd = password;
    
    MODEL.signedUserName = username;
    MODEL.signedUserPassword = password;
    
    
    // Rember password and username
    if (passwordCheckBox.checked) {
        [MODEL.appSqlite updatePassword: passwordTextField.text];
    } else {
        [MODEL.appSqlite updatePassword: @""];
    }
    if (userCheckBox.checked) {
        [MODEL.appSqlite updateUsername: userNameTextField.text];
    } else {
        [MODEL.appSqlite updateUsername: @""];
    }
    
    // Send Login request
    RequestJsonModel* model = [RequestJsonModel getJsonModel];
    model.path = PATH_USER(@"signin");
    [model.parameters setObject:tokenStr forKey:@"APNSTOKEN"];
    [model.parameters setObject:verifyCode forKey:@"VERIFYCODE"];
    [model addModels: CATEGORIE_USER, nil];
    
    password = [AppRSAHelper encrypt: password];
    [model addObjects: @{@"username":username, @"password":  password} ,nil];
    
    [VIEW.progress show];
    [MODEL.requester startPostRequestWithAlertTips:model completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (response.status) {
            [self getUserAuthoritysWithObject: response.results];
        } else {
            [VIEW.progress hide];
        }
    }];
}


#pragma mark - SIGN SUCCESSFULLY
-(void)getUserAuthoritysWithObject:(NSDictionary*)permissionsJsons
{
    MODEL.signedUserId = [[permissionsJsons objectForKey: USER_IDENTIFIER ] integerValue];
    MODEL.usersNOPermissions = [AppDataParserHelper parseUserPermissions: [permissionsJsons objectForKey: ALL_USERS_PERMISSIONS]];
    
    
    // get the refresh data first time
    __weak LoginViewController* weakInstance = self;
    [AppDataHelper refreshServerBasicData:^(BOOL isSuccess) {
        [weakInstance accessIntoWheels];
        [VIEW.progress hide];
    }];
    
    
    // start the refresh action
    static BOOL flag = NO;
    if (! flag) {
        flag = !flag;
        [ScheduledTask setSharedInstance: [[ScheduledTask alloc] initWithTimeInterval: 1]];
        [ScheduledTask.sharedInstance registerSchedule:self timeElapsed:ScheduledTaskTime repeats:0];
        [ScheduledTask.sharedInstance start];
    }
}

-(void) accessIntoWheels
{
#pragma mark - IF Administrator Signined
    if (IS_ADMINISTATOR(MODEL.signedUserId)) {
        [EVENT initialiazeAdministerProcedure];
        AppWheelViewController* controller = [[AppWheelViewController alloc] init];
        controller.wheels = @[@"User_Permissions_Settings", @"Orders_Settings", @"Dropbox_Settings", @"General_Settings"];
        controller.wheelDidTapSwipLeftBlock = ^(AppWheelViewController* wheel, NSInteger index){
            UIViewController* nextController = nil;
            
            if (index == 0) {
                // User Permissions Settings
                nextController = [AdminControllerDispatcher dispatchToUsersList];
            } else if (index == 1){
                // Orders Settings
                nextController = [AdminControllerDispatcher dispatchToDepartmentsWheel];
            } else if (index == 2) {
                // Dropbox Settings
                nextController = [AdminControllerDispatcher dispatchToDropboxController];
            } else if (index == 3) {
                // Others Settings
                nextController = [AdminControllerDispatcher dispatchToOtherSettingsController];
            }
            
            if (nextController) [VIEW.navigator pushViewController:nextController animated:YES];
        };
        [VIEW.navigator pushViewController:controller animated:YES];
    }
    
    
#pragma mark - IF User Signined
    else {
        [ApproveHelper refreshBadgeIconNumber: MODEL.signedUserName];
        
        AppWheelViewController* departmentWheel = [AppViewHelper getDepartmentsWheelController];
        departmentWheel.wheels = [AppDataHelper getUserCategoryWheels: MODEL.signedUserName];
        departmentWheel.wheelDidTapSwipLeftBlock = ^(AppWheelViewController* wheel, NSInteger index) {
            NSString* department = [wheel.wheels objectAtIndex: index];
            UIViewController* controller = nil;
            
            
            if ([department isEqualToString: CATEGORIE_CARDS]) {
                
                NSString* sbname = @"Main_iPhone";
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
                    sbname = @"Main_iPad";
                }
                UIStoryboard* sb = [UIStoryboard storyboardWithName:sbname bundle:nil];
                assert(sb != nil);
                controller = [sb instantiateViewControllerWithIdentifier:@"Cards"];
                
            } else if ([department isEqualToString: CATEGORIE_APPROVAL] || [department isEqualToString: WHEEL_TRACE_STATUS_FILE]) {
                
                EmployeeController* employeeController = [[EmployeeController alloc] initWithOrder: MODEL_EMPLOYEE department:DEPARTMENT_HUMANRESOURCE];
                employeeController.identification = @{PROPERTY_EMPLOYEENO: MODEL.signedUserName};
                employeeController.controlMode = JsonControllerModeRead;
                
                NSString* buttonKey = [department isEqualToString: CATEGORIE_APPROVAL] ? @"ZZ_TAB_BTNPending" : @"TraceStatus";
                JRButton* actionButton = (JRButton*)[employeeController.jsonView getView:buttonKey];
                [actionButton sendActionsForControlEvents: UIControlEventTouchUpInside];
                controller = employeeController;
                
                
                
            } else {
                
                // show the orders
                AppWheelViewController* orderWheel = [AppViewHelper getOrdersWheelController:department];
                orderWheel.wheels = [AppDataHelper getUserModelWheels: MODEL.signedUserName department:department];
                
                orderWheel.wheelDidTapSwipLeftBlock = ^(AppWheelViewController* wheel, NSInteger index) {
                    NSString* order = [wheel.wheels objectAtIndex: index];
                    BaseOrderListController* orderListController = nil;
                    
                    NSString* orderClazzString = [NSString stringWithFormat:@"%@%@", order, @"ListController"];
                    orderListController = [[NSClassFromString(orderClazzString) alloc] init];
                    
                    if (!orderListController) {
                        NSString* orderClazzString = [NSString stringWithFormat:@"%@%@", department, @"ListController"];
                        orderListController = [[NSClassFromString(orderClazzString) alloc] init];
                        
                        if (!orderListController) {
                            orderListController = [[BaseOrderListController alloc] init ];
                        }
                    }
                    
                    [orderListController initializeWithDepartment: department order:order];
                    
                    [VIEW.navigator pushViewController:orderListController animated:YES];
                };
                controller = orderWheel;
                
            }
            
            if ([controller isKindOfClass:[UINavigationController class]]){
                [self presentViewController:controller animated:YES completion:nil];
            }else{
                [VIEW.navigator pushViewController: controller animated:YES];
            }
        };
        
        [VIEW.navigator pushViewController:departmentWheel animated:YES];
    }
    
}


#pragma mark - Scheduled Action

-(void) scheduledTask
{
    if ([VIEW isTestDevice]) return;
    
    [AppDataHelper refreshServerBasicData:nil];
}

@end
