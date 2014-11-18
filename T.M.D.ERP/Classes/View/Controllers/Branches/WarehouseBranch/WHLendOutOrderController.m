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
    
}

@property (nonatomic,assign) int incrementInt;

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
        [WHLendOutOrderController createOneReturnView: weakSelf index:weakSelf.incrementInt];
        weakSelf.incrementInt++;
        
        NSString* LASTimageKey = [NSString stringWithFormat:@"%@%d.%@",@"NESTED_MIDDLE_INCREMENT_",_incrementInt-1,@"IMG_Photo_Return"];
        JRImageView* jrImageView = (JRImageView*)[self.jsonView getView:LASTimageKey];
        jrImageView.didClickAction = ^void(JRImageView* imageView) {
            [JRComponentHelper previewImagesWithBrowseImageView: imageView config:nil];
        };
    };
    
    [WHLendOutOrderController createOneReturnView: self index:0];
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
    NSString* NESTEDTAG = [NSString stringWithFormat:@"%@%d",@"NESTED_MIDDLE_INCREMENT_",index];
    JsonDivView* nestedDivView = (JsonDivView*)[controller.jsonView getView: NESTEDTAG] ;
    [nestedDivView removeFromSuperview];
    if (index != 0) {
        [controller baseSuperViewMove:- [nestedDivView sizeHeight]];
    }
}


+(void) createOneReturnView: (WHLendOutOrderController*)controller index:(int)index
{
    
    JsonView* varJsonView = controller.jsonView;
    
    // create view
    NSString* NestedKey = ReturnViewNestedKey(index);
    NSDictionary* specifications = controller.jsonView.specifications[@"COMPONENTS"][ReturnViewAttributeKey];
    JsonDivView* nestedDivView = (JsonDivView*)[JsonViewRenderHelper render:NestedKey specifications:specifications];
    [varJsonView addSubviewToContentView:nestedDivView];
    [nestedDivView addOriginY: [nestedDivView sizeHeight] * index];
    
    
    
    JRButton* createUser = ((JRButtonTextFieldView*)[nestedDivView getView:@"createUser"]).button;
    createUser.didClikcButtonAction = ^void(NormalButton* btn) {
        
    };
    
    JRButton* app1 = ((JRButtonTextFieldView*)[nestedDivView getView:@"app1"]).button;
    app1.didClikcButtonAction = ^void(NormalButton* btn) {

    };
    
    JRButton* app2 = ((JRButtonTextFieldView*)[nestedDivView getView:@"app2"]).button;
    app2.didClikcButtonAction = ^void(NormalButton* btn) {

    };
    
    // Date Pickers & Date Patterns
    NSString* returnDateViewKey = ReturnViewNestedSubKeyPath(index, @"returnDate");
    [JRComponentHelper setupDatePickerComponents: varJsonView pickers:@[returnDateViewKey] patterns: @{returnDateViewKey: @"yyyy-MM-dd"}];
    
    
    // Photos Picker
    // Photos Previews
    NSString* buttonTakeViewKey = ReturnViewNestedSubKeyPath(index, @"BTN_Take_Return");
    NSString* buttonTakeImageViewKey = ReturnViewNestedSubKeyPath(index, @"IMG_Photo_Return");
    [JRComponentHelper setupPhotoPickerComponents: varJsonView config:@{buttonTakeViewKey: buttonTakeImageViewKey}];
    [JRComponentHelper setupPreviewImageComponents: controller config:@{buttonTakeImageViewKey:@{}}];
    
    
    if (index != 0) {
        [controller baseSuperViewMove:[nestedDivView sizeHeight]];
    }
    
    
    
    
    // -------- Client
    
    /*
    
    // --- DATE
    NSString* deferedReturAttribute = [NSString stringWithFormat:@"%@.%@", NESTEDTAG, @"returnDate"];
    [controller.specifications[@"CLIENT"][@"COMS_DATE_PICKERS"] addObject:deferedReturAttribute];
    [controller.specifications[@"CLIENT"][@"COMS_DATE_PATTERNS"] setObject: deferedReturAttribute forKey:@"yyyy-MM-dd"];
    
    // --- IMAGE PICKER
    NSString* deferedImageAttribute = [NSString stringWithFormat:@"%@.%@", NESTEDTAG, @"BTN_Take_Return"];
    NSString* deferedImageViewAttribute = [NSString stringWithFormat:@"%@.%@", NESTEDTAG, @"IMG_Photo_Return"];
    [controller.specifications[@"IMAGES"][@"IMAGES_PREVIEWS"] setObject:@{} forKey:deferedImageViewAttribute ];
    [controller.specifications[@"IMAGES"][@"IMAGE_PICKER"] setObject: deferedImageViewAttribute forKey:deferedImageAttribute];
    
    
    NSString* returnDateKey = [NSString stringWithFormat:@"%@.%@", NESTEDTAG, @"returnDate"];
    [controller.specifications[@"IMAGES"][@"IMAGES_NAMES"] setObject:@{@"MAINNAME": @[@"orderNO", returnDateKey],
                                                                 @"SUF":@"ReturnProduct.png"} forKey:deferedImageViewAttribute  ];
    [controller.specifications[@"IMAGES"][@"IMAGES_DATAS"] setObject:@{} forKey:deferedImageViewAttribute  ];
    
    
    NSString* returnDateImageLoadKey = [NSString stringWithFormat:@"%@.%@", NESTEDTAG, @"IMG_Photo_Return"];
    [controller.specifications[@"IMAGES"][@"IMAGES_LOAD"] addObject:returnDateImageLoadKey];
    
    
    // ---------- Sever
    
    [controller.specifications[@"SERVER"][@"SUBMIT_BUTTONS"] addObject:@{@"MODEL_SENDVIEW" : NESTEDTAG,
                                                                   @"MODEL_SENDORDER" : @"WHLendOutBill",
     
                                                                   creatorButtonKey: @{ @"MODEL_APPTO" : @"app1"},
                                                                   [NESTEDTAG stringByAppendingFormat:@".%@",@"app1"]: @{@"BUTTON_TYPE" : @(1),
                                                                                                                         @"MODEL_APPFROM" : @"app1",
                                                                                                                         @"MODEL_APPTO" : @"app2"},
                                                                   [NESTEDTAG stringByAppendingFormat:@".%@",@"app2"]: @{@"BUTTON_TYPE" : @(1),
                                                                                                                         @"MODEL_APPFROM" : @"app2",
                                                                                                                         @"MODEL_APPTO" : @"createUser"}
     
                                                                   }];
    
     NSString* creatorButtonKey = [NESTEDTAG stringByAppendingFormat:@".%@",@"createUser"];
    
    */
    
    /*
       // refresh event
    [controller setupClientEvents];
    [controller setupServerEvents];
    */
    
}

#pragma mark -
#pragma mark - Request

-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects
{
    NSString* orderNO = self.identification;
    RequestJsonModel* requestModel = [RequestJsonModelFactory factoryMultiJsonModels:@[ORDER_WHLendOutOrder, BILL_WHLendOutBill]
                                                                           objects:@[[RequestModelHelper getModelIdentities: orderNO], @{}]
                                                                              path:PATH_LOGIC_READ(self.department)];
    
    [requestModel.preconditions addObjectsFromArray: @[@{}, @{@"billNO": @"0-0-orderNO"}]];
    
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
        [objects setObject:orderNO forKey:@"billNO"];
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
    NSMutableDictionary* responseObject = [NSMutableDictionary dictionary];
    
    NSDictionary* orderObject = [[results firstObject] firstObject];
    NSArray* billArray = [results lastObject];
    
    [responseObject setObject:orderObject forKey:@"order"];
    [responseObject setObject:billArray forKey:@"bills"];
    
    NSMutableDictionary* resultsObj = [DictionaryHelper deepCopy: responseObject];
    self.valueObjects = resultsObj[@"order"];
    
//    DBLOG(@"resultsObj === %@", resultsObj);
    
    return resultsObj;
    
}

-(void) enableViewsWithReceiveObjects: (NSMutableDictionary*)objects
{
    NSMutableDictionary* orderObjdect = [objects objectForKey:@"order"];
    
    [self createBillViews:[objects objectForKey:@"bills"]];
    
    [super enableViewsWithReceiveObjects:orderObjdect];
    
    [self enableBillViewButton:orderObjdect];
    
}


-(void) translateReceiveObjects: (NSMutableDictionary*)objects
{
    NSMutableDictionary* orderObjdect = [objects objectForKey:@"order"];
    [super translateReceiveObjects: orderObjdect];
}

-(void) renderWithReceiveObjects: (NSMutableDictionary*)objects
{
    NSDictionary* orderObjdect = [objects objectForKey:@"order"];
    
    //    DBLOG(@"orderObjdect === %@",orderObjdect);
    
    JsonDivView* orderTopDivView = (JsonDivView*)[self.jsonView getView:@"NESTED_TOP"];
    [orderTopDivView setModel: orderObjdect];
    
    JsonDivView* orderBottomDivView = (JsonDivView*)[self.jsonView getView:@"NESTED_BOTTOM"];
    [orderBottomDivView setModel: orderObjdect];
    
    JRTextField* notReturnAmountTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"NESTED_BOTTOM.notReturnAmount"]).textField;
    
    float lendAmount = [[orderObjdect objectForKey:@"lendAmount"] floatValue];
    notReturnAmountTxtField.text = [[NSNumber numberWithFloat:lendAmount] stringValue];
    
    NSArray* bills = [objects objectForKey:@"bills"];
    
    for (int j = 0; j < [bills count]; ++j) {
        
        NSString* NestedBillTag = [NSString stringWithFormat:@"%@%d",@"NESTED_MIDDLE_INCREMENT_",j];
        JsonDivView* billDivView = (JsonDivView*)[self.jsonView getView:NestedBillTag];
        
        NSDictionary* billObjdect = bills[j];
        NSMutableDictionary* billMutObject = [DictionaryHelper deepCopy: billObjdect];
        [super translateReceiveObjects: billMutObject];
        [billDivView setModel: billMutObject];
        
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
            [WHLendOutOrderController createOneReturnView: self index: previousBillCount + i];
            self.incrementInt ++ ;
        }
    }
    
    if ([bills count] == 0) {
        [WHLendOutOrderController createOneReturnView: self index: 0];
        self.incrementInt ++ ;
    }
}

-(void)enableBillViewButton:(NSMutableDictionary*)orderObjdect
{
    BOOL isOrderAllApproved = [JsonControllerHelper isAllApplied: self.order valueObjects:orderObjdect];
    
    JRButton* BTN_ReturnNumButton = (JRButton*)[self.jsonView getView:@"NESTED_BOTTOM.BTN_ReturnNum"];
    BTN_ReturnNumButton.enabled = isOrderAllApproved;
    
    if (isOrderAllApproved) {
        
        NSArray* bills = [orderObjdect objectForKey:@"bills"];
        
        NSDictionary* lastBillObject = [bills lastObject];
        NSString* apporovingLevel = PROPERTY_CREATEUSER;
        int billDivIndex = bills.count;
        
        if (lastBillObject != nil) {
            while (!OBJECT_EMPYT(lastBillObject[apporovingLevel])) {
                apporovingLevel = [JsonControllerHelper getNextAppLevel: apporovingLevel];
            }
            billDivIndex = bills.count - 1;
        }
        
        if (!lastBillObject[apporovingLevel]) {
            
            NSString* billDivViewKey = [NSString stringWithFormat:@"%@%d",@"NESTED_MIDDLE_INCREMENT_", billDivIndex];
            JsonDivView* billDivView = (JsonDivView*)[self.jsonView getView: billDivViewKey];
            
            JRButton* approvalingButton = ((JRButtonTextFieldView*)[billDivView getView: apporovingLevel]).button;
            
            if (!lastBillObject || [MODEL.signedUserName isEqualToString: lastBillObject[PROPERTY_FORWARDUSER]]) {
                [JsonControllerHelper setUserInterfaceEnable: approvalingButton enable:YES];
            }
            
            if (OBJECT_EMPYT(lastBillObject[levelApp2])) {
                BTN_ReturnNumButton.enabled = NO;
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



@end
