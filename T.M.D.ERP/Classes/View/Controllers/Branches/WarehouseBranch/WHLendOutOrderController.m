#import "WHLendOutOrderController.h"
#import "AppInterface.h"
#import "PurchaseBillCell.h"


#define ReturnViewAttributeKey @"NESTED_MIDDLE_INCREMENT_"

#define ReturnViewNestedKey(index) [NSString stringWithFormat:@"%@%d",ReturnViewAttributeKey,index]

#define ReturnViewNestedSubKeyPath(index, subViewKey) [NSString stringWithFormat:@"%@.%@",ReturnViewNestedKey(index),subViewKey]




@interface WHLendOutOrderController ()
{
    JsonDivView* _bottomView;
    
    JRImageView* _backgroundView;
    
    JRButton* _priorPageButton;
    JRButton* _nextPageButton;
    
    
    JRTextField* _productCodeTxtField;
    float _remainInventory;
    
    
    
    
    
    NSMutableArray* billsDataSources;
    
}

@property (nonatomic,assign) int incrementInt;
@property (strong) id billIdentification;
@end

@implementation WHLendOutOrderController


-(BOOL) viewWillAppearShouldRequestServer
{
    return [super viewWillAppearShouldRequestServer] && self.isMovingToParentViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak WHLendOutOrderController* weakSelf = self;
    __block WHLendOutOrderController* blockSelf = self;
    
    /*select staffCategory and staffNO*/
    JRTextField* staffCategoryTxtField = ((JRLabelCommaTextFieldView*)[self.jsonView getView:@"staffCategory"]).textField;
    JRTextField* staffNOTextField = ((JRLabelCommaTextFieldView*)[self.jsonView getView:@"staffNO"]).textField;
    
    NSArray* keys =  @[KEY_CONSTRUCTION_TEAM,KEY_EMPLOYEE, KEY_VENDOR, KEY_CLIENT];
    NSArray* values = @[KEY_CONSTRUCTION_TEAM, MODEL_EMPLOYEE, MODEL_VENDOR, MODEL_CLIENT];
    staffCategoryTxtField.isEnumerateValue = YES;
    staffCategoryTxtField.enumerateValues = values;
    staffCategoryTxtField.enumerateValuesLocalizeKeys = keys;
    staffCategoryTxtField.textFieldDidClickAction = ^void(JRTextField* textField) {
        [PopupTableHelper popTableView:nil keys:keys selectedAction:^(JRButtonsHeaderTableView *sender, NSUInteger selectedIndex, NSString* selectedVisualValue) {
            
            textField.text = selectedVisualValue;        // set text
            
            staffNOTextField.text = nil;
            NSString* selectedMemberType = [textField.enumerateValues objectAtIndex: selectedIndex];
            staffNOTextField.memberType = selectedMemberType;
            
            
                // pop
                [weakSelf popupMembersPicker: selectedMemberType textField:staffNOTextField];
                // change the staff number click action
                staffNOTextField.textFieldDidClickAction = ^void(JRTextField* textField) {
                    [weakSelf popupMembersPicker: selectedMemberType textField:textField];
                };
            
            
        }];
    };


    
    
    
    /*select product*/
    _productCodeTxtField= ((JRLabelTextFieldView*)[self.jsonView getView:@"productCode"]).textField;
    JRTextField* productNameTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"productName"]).textField;
    JRTextField* unitTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"unit"]).textField;
    
    
    _productCodeTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField){
        
        NSArray* needFields = @[@"productCode",@"productName",@"totalAmount",@"lendAmount",@"basicUnit"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_WHInventory fields:needFields];
        pickView.tableView.headersXcoordinates = @[@(20), @(150),@(280),@(400),@(520)];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            NSArray* array = [filterTableView realContentForIndexPath: realIndexPath];
            
            jrTextField.text = [array objectAtIndex:1];
            productNameTxtField.text = [array objectAtIndex:2];
            unitTxtField.text = [array objectAtIndex:5];
            blockSelf->_remainInventory = [[array objectAtIndex:3] floatValue] - [[array objectAtIndex:4] floatValue];
            
            [PickerModelTableView dismiss];
        };
        
    };
    
    
    _incrementInt = 0;
    _bottomView = ((JsonDivView*)[self.jsonView getView:@"NESTED_BOTTOM"]);
    _backgroundView = ((JRImageView*)[self.jsonView getView:@"BG_BOTTOM_IMAGE"]);
    _priorPageButton = (JRButton*)[self.jsonView getView:@"BTN_PriorPage"];
    _nextPageButton = (JRButton*)[self.jsonView getView:@"BTN_NextPage"];
    
    JRButton* returnButton = ((JRButton*)[self.jsonView getView:@"NESTED_BOTTOM.BTN_ReturnNum"]);
    returnButton.didClikcButtonAction =  ^void(JRButton* button){
        [WHLendOutOrderController deriveReturnViews: weakSelf index:weakSelf.incrementInt];
        weakSelf.incrementInt++;
        
        NSString* LASTimageKey = ReturnViewNestedSubKeyPath(_incrementInt-1, @"IMG_Photo_Return");
        JRImageView* jrImageView = (JRImageView*)[self.jsonView getView:LASTimageKey];
        jrImageView.didClickAction = ^void(JRImageView* imageView) {
            [JRComponentHelper previewImagesWithBrowseImageView: imageView config:nil];
        };
    };
    
    [WHLendOutOrderController deriveReturnViews: self index:0];
    weakSelf.incrementInt++;
}


-(void) popupMembersPicker:(NSString*)memberType textField:(JRTextField*)textField
{
    PickerModelTableView *pickerTableView = [PickerModelTableView popupWithModel: memberType ];
    pickerTableView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
        FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
        NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
        NSArray* realContents = [filterTableView realContentForIndexPath: realIndexPath];
        NSString* number = [realContents safeObjectAtIndex:1];
        [textField setValue: number];
        [PickerModelTableView dismiss];
    };
}


+(void) removerDeriveReturnViews: (WHLendOutOrderController*)controller index:(int)index
{
    NSString* NESTEDTAG = ReturnViewNestedKey(index);
    JsonDivView* nestedDivView = (JsonDivView*)[controller.jsonView getView: NESTEDTAG] ;
    [nestedDivView removeFromSuperview];
    if (index != 0) {
        [controller baseSuperViewMove:- [nestedDivView sizeHeight]];
    }
}

+(void) deriveReturnViews: (WHLendOutOrderController*)controller index:(int)index
{
    NSDictionary* specifications = controller.jsonView.specifications[@"COMPONENTS"][ReturnViewAttributeKey];
    
    NSString* NestedDivKey = ReturnViewNestedKey(index);
    JsonDivView* nestedDivView = (JsonDivView*)[JsonViewRenderHelper render:NestedDivKey specifications:specifications];
    [controller.jsonView addSubviewToContentView:nestedDivView];
    
    [nestedDivView addOriginY: [nestedDivView sizeHeight] * index];
    
    // -------- Client
    
    // --- DATE
    NSString* deferedReturAttribute = ReturnViewNestedSubKeyPath(index, @"returnDate");
    [controller.specifications[@"CLIENT"][@"COMS_DATE_PICKERS"] addObject:deferedReturAttribute];
    [controller.specifications[@"CLIENT"][@"COMS_DATE_PATTERNS"] setObject: deferedReturAttribute forKey:@"yyyy-MM-dd"];
    
    // --- IMAGE PICKER
    NSString* deferedImageAttribute = ReturnViewNestedSubKeyPath(index, @"BTN_Take_Return");
    NSString* deferedImageViewAttribute = ReturnViewNestedSubKeyPath(index, @"IMG_Photo_Return");
    
    [controller.specifications[@"IMAGES"][@"IMAGES_PREVIEWS"] setObject:@{} forKey:deferedImageViewAttribute ];
    [controller.specifications[@"IMAGES"][@"IMAGE_PICKER"] setObject: deferedImageViewAttribute forKey:deferedImageAttribute];
    
    
    NSString* returnDateKey = ReturnViewNestedSubKeyPath(index, @"returnDate");
    [controller.specifications[@"IMAGES"][@"IMAGES_NAMES"] setObject:@{@"MAINNAME": @[@"orderNO", returnDateKey], @"SUF":@"ReturnProduct.png"} forKey:deferedImageViewAttribute ];
    [controller.specifications[@"IMAGES"][@"IMAGES_DATAS"] setObject:@{} forKey:deferedImageViewAttribute];
    
    
    NSString* returnDateImageLoadKey = ReturnViewNestedSubKeyPath(index, @"IMG_Photo_Return");
    [controller.specifications[@"IMAGES"][@"IMAGES_LOAD"] addObject:returnDateImageLoadKey];
    
    
    // ---------- Sever
    [controller.specifications[@"SERVER"][@"SUBMIT_BUTTONS"] addObject:
     @{
       @"MODEL_SENDVIEW" : NestedDivKey,
       @"MODEL_SENDORDER" : @"WHLendOutBill",
       ReturnViewNestedSubKeyPath(index, @"createUser"): @{@"BUTTON_TYPE" : @(0), @"MODEL_APPTO" : @"app1"},
       ReturnViewNestedSubKeyPath(index, @"app1"): @{@"BUTTON_TYPE" : @(1), @"MODEL_APPFROM" : @"app1", @"MODEL_APPTO" : @"app2"},
       ReturnViewNestedSubKeyPath(index, @"app2"): @{@"BUTTON_TYPE" : @(1), @"MODEL_APPFROM" : @"app2", @"MODEL_APPTO" : @"createUser"}
       }];

    
    
    
    // refresh event
    [controller setupClientEvents];
//    [controller setupServerEvents];
    
    JRButton* createButton = ((JRButtonTextFieldView *)[nestedDivView getView:@"createUser"]).button;
    JRTextField *createTextField = ((JRButtonTextFieldView *)[nestedDivView getView:@"createUser"]).textField;
    JRButton* app1Button = ((JRButtonTextFieldView *)[nestedDivView getView:@"app1"]).button;
    JRTextField *app1TextField = ((JRButtonTextFieldView *)[nestedDivView getView:@"app1"]).textField;
    JRButton* app2Button = ((JRButtonTextFieldView* )[nestedDivView getView:@"app2"]).button;
    
    __weak WHLendOutOrderController* weakInstance = controller;
    __block WHLendOutOrderController *blockSelf = controller;
    NSString *order = @"WHLendOutBill";
    NSString *department = DEPARTMENT_WAREHOUSE;
    createButton.didClikcButtonAction = ^void(JRButton* BTN) {
        NSLog(@"----");
        NSMutableDictionary* objects = [weakInstance assembleSendObjects: NestedDivKey];
        if (! [weakInstance validateSendObjects: objects order:order]) {
            return;
        }
        [weakInstance translateSendObjects: objects order:order];
        
        [ViewControllerHelper popApprovalView: @"app1" department:department order:order selectAction:nil cancelAction:nil sendAction:^(id sender, NSString *forwardUserNumber) {
            [objects setObject:forwardUserNumber forKey:PROPERTY_FORWARDUSER];
//            [controller startSendCreateUpdateOrderRequest: objects order:@"WHLendOutBill" department:DEPARTMENT_WAREHOUSE];
            NSMutableDictionary* withoutImagesObjects = [DictionaryHelper filter:objects withType:[UIImage class]];

            [VIEW.progress show];
            RequestJsonModel* requestModel = [weakInstance assembleSendRequest: withoutImagesObjects order:order department:department];
            [MODEL.requester startPostRequestWithAlertTips:requestModel completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                
                if (response.status) {
                    // create order success
                    NSString* orderNO = [[response.results firstObject] objectForKey:PROPERTY_ORDERNO];
                    if (orderNO) {
                        [objects setObject: orderNO forKey:PROPERTY_ORDERNO];
                        [(id<JRComponentProtocal>)[weakInstance.jsonView getView: PROPERTY_ORDERNO] setValue: orderNO];
                    }
                    weakInstance.valueObjects = objects;
                    
                    [weakInstance didSuccessSendObjects: objects response: response];
                } else {
                    // create order failed
                    [weakInstance didFailedSendObjects: objects response: response];
                }
            }];

            
        }];
        
    };
    app1Button.didClikcButtonAction = ^void(JRButton* BTN) {
        NSLog(@"=====");
        if(OBJECT_EMPYT(createTextField.text)) return;
        NSDictionary* identities = [RequestModelHelper getModelIdentities:weakInstance.billIdentification];

        BOOL isNeedRequest = YES;
        NSMutableDictionary* objects = nil;
        [weakInstance assembleWillApplyObjects: @"app1" order:order valueObjects:[blockSelf->billsDataSources lastObject] divKey:NestedDivKey isNeedRequest:&isNeedRequest objects:&objects identities:&identities];
        if (! isNeedRequest) return;
        if (! identities) return;
        
        if (@"app2") {
        
            if ([JsonControllerHelper isLastAppLevel: order  applevel:@"app1"]) {
                NSString* forwardUser = [weakInstance getFowardUserForFinalApplyOrder: order  valueObjects:weakInstance.valueObjects appTo:@"app2"];
                [weakInstance startApplyOrderRequest:order divViewKey:NestedDivKey appFrom:@"app1" appTo:@"app2" forwarduser:forwardUser objects:objects identities:identities];
            } else {
                [ViewControllerHelper popApprovalView: @"app2" department:weakInstance.department order:order selectAction:nil cancelAction:nil sendAction:^(id sender, NSString *number) {
                    [weakInstance startApplyOrderRequest:order divViewKey:NestedDivKey appFrom:@"app1" appTo:@"app2" forwarduser:number objects:objects identities:identities];
                }];
            }
        } else {
            [weakInstance startApplyOrderRequest:order divViewKey:NestedDivKey appFrom:@"app1" appTo:@"app2" forwarduser:nil objects:objects identities:identities];
        }
    

    };
    app2Button.didClikcButtonAction = ^void(JRButton* BTN) {
        
        NSLog(@"%@",BTN);
        NSLog(@"++++++++++++");
        if(OBJECT_EMPYT(app1TextField.text)) return;
        NSDictionary* identities = [RequestModelHelper getModelIdentities:weakInstance.billIdentification];
        
        BOOL isNeedRequest = YES;
        NSMutableDictionary* objects = nil;
        [weakInstance assembleWillApplyObjects: @"app2" order:order valueObjects:[blockSelf->billsDataSources lastObject] divKey:NestedDivKey isNeedRequest:&isNeedRequest objects:&objects identities:&identities];
        if (! isNeedRequest) return;
        if (! identities) return;
        
        if (@"app3") {
            if ([JsonControllerHelper isLastAppLevel: order  applevel:@"app2"]) {
                NSString* forwardUser = [weakInstance getFowardUserForFinalApplyOrder: order  valueObjects:weakInstance.valueObjects appTo:@"app3"];
                [weakInstance startApplyOrderRequest:order divViewKey:NestedDivKey appFrom:@"app2" appTo:@"app3" forwarduser:forwardUser objects:objects identities:identities];
            } else {
                [ViewControllerHelper popApprovalView: @"app3" department:weakInstance.department order:order selectAction:nil cancelAction:nil sendAction:^(id sender, NSString *number) {
                    [weakInstance startApplyOrderRequest:order divViewKey:NestedDivKey appFrom:@"app2" appTo:@"app3" forwarduser:number objects:objects identities:identities];
                }];
            }
        } else {
            [weakInstance startApplyOrderRequest:order divViewKey:NestedDivKey appFrom:@"app2" appTo:@"app3" forwarduser:nil objects:objects identities:identities];
        }
        
        

        
    };


    if (index != 0) {
        [controller baseSuperViewMove:[nestedDivView sizeHeight]];
    }
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
//    [requestModel.parameters setObject: @(12) forKey:@"shouldDeleteBillId"];
    
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




#pragma mark -
#pragma mark - Request

-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects
{
    NSString* orderNO = self.identification;
    RequestJsonModel* requestModel = [RequestJsonModelFactory factoryMultiJsonModels:@[ORDER_WHLendOutOrder, BILL_WHLendOutBill]
                                                                           objects:@[[RequestModelHelper getModelIdentities: orderNO], @{}]
                                                                              path:PATH_LOGIC_READ(self.department)];
    
    [requestModel.preconditions addObjectsFromArray: @[@{}, @{@"referenceOrderNO": @"0-0-orderNO"}]];
    
    return requestModel;
}

-(NSMutableDictionary*) assembleSendObjects: (NSString*)divViewKey
{
    NSMutableDictionary* objects = [super assembleSendObjects: divViewKey];
    
    if ([divViewKey isEqualToString:@"NESTED_TOP"]) {
        JRTextView* remarkTxtView = ((JRLabelTextView*)[self.jsonView getView:@"NESTED_BOTTOM.remark"]).textView;
        [objects setObject:remarkTxtView.text forKey:@"remark"];
    }
    else {
        
        NSString* orderNO = self.valueObjects[@"orderNO"];
        if(orderNO)
        [objects setObject:orderNO forKey:@"referenceOrderNO"];
        [objects setObject:MODEL.signedUserName forKey:@"createUser"];
    }
    
    return objects;
}

-(BOOL) validateSendObjects: (NSMutableDictionary*)objects order:(NSString*)order
{
    
    if (self.controlMode == JsonControllerModeCreate)
    {
        if (!isEmptyString(_productCodeTxtField.text)){
            
            JRTextField* lendAmountTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"lendAmount"]).textField;
            float lendAmount = [lendAmountTxtField.text floatValue];
            if (lendAmount>_remainInventory) {
                [Utility showAlert: LOCALIZE_MESSAGE(@"LendAmountOutOfLimit")];
                return NO;
            }
        }
    }
    return [super validateSendObjects:objects order:order];
}

#pragma mark -
#pragma mark - Response

-(NSMutableDictionary*) assembleReadResponse: (ResponseJsonModel*)response
{
    NSArray* results = response.results;

    billsDataSources = [ArrayHelper deepCopy: [results lastObject]];
    _billIdentification = [[billsDataSources lastObject] objectForKey:@"id"];
    self.valueObjects = [DictionaryHelper deepCopy: [[results firstObject] firstObject]];
    
    return self.valueObjects;
    
}

-(void) enableViewsWithReceiveObjects: (NSMutableDictionary*)objects
{
    [self createBillViews: billsDataSources];
    
    [super enableViewsWithReceiveObjects:objects];
    
    [self enableBillViewButton: objects];
}


-(void) renderWithReceiveObjects: (NSMutableDictionary*)objects
{
    JsonDivView* orderTopDivView = (JsonDivView*)[self.jsonView getView:@"NESTED_TOP"];
    [orderTopDivView setModel: objects];
    
    JsonDivView* orderBottomDivView = (JsonDivView*)[self.jsonView getView:@"NESTED_BOTTOM"];
    [orderBottomDivView setModel: objects];
    
    JRTextField* notReturnAmountTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"NESTED_BOTTOM.notReturnAmount"]).textField;
    float lendAmount = [[objects objectForKey:@"lendAmount"] floatValue];
    notReturnAmountTxtField.text = [[NSNumber numberWithFloat:lendAmount] stringValue];
    
    
    NSArray* bills = billsDataSources;
    for (int j = 0; j<[bills count]; ++j) {
        NSString* NestedBillTag = ReturnViewNestedKey(j);
        JsonDivView* billDivView = (JsonDivView*)[self.jsonView getView:NestedBillTag];
        
        NSMutableDictionary* billObjdect = bills[j];
        [super translateReceiveObjects: billObjdect];
        [billDivView setModel: billObjdect];
        
        float returnAmount = [[billObjdect objectForKey:@"returnAmount"] floatValue];
        lendAmount = lendAmount - returnAmount;
    }
    
    notReturnAmountTxtField.text = [[NSNumber numberWithFloat:lendAmount] stringValue];
}



#pragma mark -
#pragma mark - Handle Bills
-(void)createBillViews:(NSArray *)bills
{
    int billCount = bills.count;
    int previousBillCount = self.incrementInt;
    int substract = billCount - previousBillCount;
    
    if (substract < 0) {
        for (int i = 0; i < abs(substract); i++) {
            [WHLendOutOrderController removerDeriveReturnViews: self index: previousBillCount - (i+1)];
            self.incrementInt -- ;
        }
    } else {
        
        for (int i = 0; i < substract; ++i) {
            [WHLendOutOrderController deriveReturnViews: self index: previousBillCount + i];
            self.incrementInt ++ ;
        }
    }
    
    if ([bills count] == 0) {
        [WHLendOutOrderController deriveReturnViews: self index: 0];
        self.incrementInt ++ ;
    }
}

-(void)enableBillViewButton:(NSMutableDictionary*)orderObjdect
{
    BOOL isOrderAllApproved = [JsonControllerHelper isAllApplied: self.order valueObjects:orderObjdect];
    
    JRButton* BTN_ReturnNumButton = (JRButton*)[self.jsonView getView:@"NESTED_BOTTOM.BTN_ReturnNum"];
    BTN_ReturnNumButton.enabled = isOrderAllApproved;
    
    if (isOrderAllApproved) {
        
        NSArray* bills = billsDataSources;
        if (bills.count == 0) {
            
            JsonDivView* billDivView = (JsonDivView*)[self.jsonView getView: ReturnViewNestedKey(0)];
            JRButton* approvalingButton = ((JRButtonTextFieldView*)[billDivView getView: PROPERTY_CREATEUSER]).button;
            [JsonControllerHelper setUserInterfaceEnable: approvalingButton enable:YES];
            
        } else {
            
            NSDictionary* lastBillObject = [bills lastObject];
            NSString* apporovingLevel = [JsonControllerHelper getCurrentApprovingLevel:BILL_WHLendOutBill valueObjects:lastBillObject];
            
            // all approved
            if (! apporovingLevel) return;

            JsonDivView* billDivView = (JsonDivView*)[self.jsonView getView: ReturnViewNestedKey(bills.count - 1)];
            JRButton* approvalingButton = ((JRButtonTextFieldView*)[billDivView getView: apporovingLevel]).button;
            if ([MODEL.signedUserName isEqualToString: lastBillObject[PROPERTY_FORWARDUSER]]) {
                [JsonControllerHelper setUserInterfaceEnable: approvalingButton enable:YES];
            }
            
        }
    }

}


#pragma mark -
#pragma mark - Order Operation
-(void)baseSuperViewMove:(float)moveHeight
{
    CGRect bottomRect = _bottomView.frame;
    bottomRect.origin.y = bottomRect.origin.y + moveHeight;
    [_bottomView setFrame:bottomRect];
    
    
    CGRect bgRect = self.jsonView.contentView.frame;
    bgRect.size.height = bgRect.size.height + moveHeight;
    _backgroundView.frame = bgRect;
    
    self.jsonView.contentView.frame = bgRect;
    self.jsonView.contentSize = CGSizeMake(self.jsonView.bounds.size.width,bgRect.size.height);
    
    CGRect priorPageRect = _priorPageButton.frame;
    priorPageRect.origin.y = priorPageRect.origin.y + moveHeight;
    _priorPageButton.frame = priorPageRect;
    
    
    CGRect nextPageRect = _nextPageButton.frame;
    nextPageRect.origin.y = nextPageRect.origin.y + moveHeight;
    _nextPageButton.frame = nextPageRect;
    
}


#pragma mark - Private methods

-(void) startBillSendCreateUpdateOrderRequest: (NSMutableDictionary*)objects order:(NSString*)order department:(NSString*)department
{
    NSMutableDictionary* withoutImagesObjects = [DictionaryHelper filter:objects withType:[UIImage class]];
    
    // get the models that filtered the images
    [VIEW.progress show];
    RequestJsonModel* requestModel = [self assembleSendRequest: withoutImagesObjects order:order department:department];
    [MODEL.requester startPostRequestWithAlertTips:requestModel completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (response.status) {
            // create order success
            NSString* orderNO = [[response.results firstObject] objectForKey:PROPERTY_ORDERNO];
            if (orderNO) {
                [objects setObject: orderNO forKey:PROPERTY_ORDERNO];
                [(id<JRComponentProtocal>)[self.jsonView getView: PROPERTY_ORDERNO] setValue: orderNO];
            }
            self.valueObjects = objects;
            
            [self didSuccessSendObjects: objects response: response];
        } else {
            // create order failed
            [self didFailedSendObjects: objects response: response];
        }
    }];
}

-(void) startBillApplyOrderRequest: (NSString*)orderType divViewKey:(NSString*)divViewKey appFrom:(NSString*)appFrom appTo:(NSString*)appTo forwarduser:(NSString*)forwardUser objects:(NSDictionary*)objects identities:(NSDictionary*)identities
{
    [VIEW.progress show];
    VIEW.progress.detailsLabelText = LOCALIZE_MESSAGE(@"ApplyingNow");
    [AppServerRequester apply: orderType department:self.department identities:identities objects:objects applevel:appFrom forwarduser:forwardUser completeHandler:^(ResponseJsonModel *response, NSError *error) {
        BOOL isSuccessfully = response.status;
        if (isSuccessfully) {
            [self didSuccessApplyOrder: orderType appFrom:appFrom appTo:appTo divViewKey:divViewKey forwarduser:forwardUser];
        } else {
            [self didFailedApplyOrder: orderType appFrom:appFrom appTo:appTo divViewKey:divViewKey];
        }
    }];
}


-(RequestJsonModel*) assembleSendRequest: (NSMutableDictionary*)withoutImagesObjects order:(NSString*)order department:(NSString*)department
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_CREATE(department);
    [requestModel addModels: order, nil];
    [requestModel addObject: withoutImagesObjects ];
    return requestModel;
}







@end
