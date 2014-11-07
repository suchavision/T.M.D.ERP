#import "FinancePaymentOrderController.h"
#import "FinancePaymentBillCell.h"
#import "AppInterface.h"


#define STAFF_CATEGORY              @"staffCategory"
#define STAFF_NUMBER                @"staffNO"
//12334s

// Table Left   ------------ Begin ---------------------------------

#define ReferenceOrder_Attr_TotalShouldPay @"shouldPay"      // the cost

// Table Left   ------------ End ---------------------------------


@implementation FinancePaymentOrderController
{
    JRRefreshTableView* tableLeft;
    JRImagesTableView* tableRight;
    
    // Table Right   ------------ Begin ---------------------------------
    NSMutableArray* tableRightSectionContents;
    // Table Right   ------------ End ---------------------------------
    
    
    // Table Left   ------------ Begin ---------------------------------
    NSMutableArray* tableLeftSectionBillsContents;
    // Table Left   ------------ End ---------------------------------
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"FinancePaymentOrderController ----- didReceiveMemoryWarning");
}

-(void)dealloc
{
    NSLog(@"FinancePaymentOrderController ----- dealloc");
    
    [tableRight stopLazyLoading];
    [tableRight.loadImages removeAllObjects];
    
    tableLeft = nil;
    tableRight = nil;
    
    [tableRightSectionContents removeAllObjects];
    tableRightSectionContents = nil;
    
    
    [tableLeftSectionBillsContents removeAllObjects];
    tableLeftSectionBillsContents = nil;
    
}

+(void) popPayWayTable: (JRTextField*)payWayTextfield selectedAction:(void(^)(JRButtonsHeaderTableView *sender, NSUInteger selectedIndex, NSString* selectedVisualValue))selectedAction
{
    NSArray *payWayKeys =@[KEY_CASH,KEY_TRANSFER,KEY_CHEQUE];
    NSArray *payWayValues =@[KEY_CASH,KEY_TRANSFER,KEY_CHEQUE];
    payWayTextfield.isEnumerateValue = YES;
    payWayTextfield.enumerateValuesLocalizeKeys = payWayKeys;
    payWayTextfield.enumerateValues = payWayValues;
    payWayTextfield.textFieldDidClickAction = ^void(JRTextField* textField) {
        [PopupTableHelper popTableView:nil keys:payWayKeys selectedAction:^(JRButtonsHeaderTableView *sender, NSUInteger selectedIndex, NSString* selectedVisualValue) {
            textField.text = selectedVisualValue;        // set text
            if (selectedAction) {
                selectedAction(sender, selectedIndex, selectedVisualValue);
            }
        }];
    };
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    JsonView* jsonView = self.jsonView;
    __weak FinancePaymentOrderController* weakSelf = self;
    NSDictionary* specConfig = self.specifications[@"Specifications"];
    
    
    
    
    // -------
    
    
    
    // NESTED_MAIN   ------------ Begin ---------------------------------
    // staff categry & staff number
    JRLabelCommaTextFieldView* staffCategory = (JRLabelCommaTextFieldView*)[jsonView getView: @"NESTED_MAIN_Header.staffCategory"];
    JRLabelCommaTextFieldView* staffNO = (JRLabelCommaTextFieldView*)[jsonView getView: @"NESTED_MAIN_Header.staffNO"];
    
    JRTextField* staffCategoryTextField = staffCategory.textField;
    __weak JRTextField* staffNOTextField = staffNO.textField;

    NSArray* keys =  @[KEY_EMPLOYEE, KEY_VENDOR, KEY_CLIENT, KEY_OTHERS];
    NSArray* values = @[MODEL_EMPLOYEE, MODEL_VENDOR, MODEL_CLIENT, KEY_OTHERS];
    
    // pop
    staffCategoryTextField.isEnumerateValue = YES;
    staffCategoryTextField.enumerateValues = values;
    staffCategoryTextField.enumerateValuesLocalizeKeys = keys;
    staffCategoryTextField.textFieldDidClickAction = ^void(JRTextField* textField) {
        [PopupTableHelper popTableView:nil keys:keys selectedAction:^(JRButtonsHeaderTableView *sender, NSUInteger selectedIndex, NSString* selectedVisualValue) {
            
            textField.text = selectedVisualValue;        // set text
            
            staffNOTextField.text = nil;
            NSString* selectedMemberType = [textField.enumerateValues objectAtIndex: selectedIndex];
            staffNOTextField.memberType = selectedMemberType;
            
            if ([selectedMemberType isEqualToString: KEY_OTHERS]) {
                staffNOTextField.textFieldDidClickAction = nil;
                [staffNOTextField becomeFirstResponder];
            } else {
                // pop
                [weakSelf popupMembersPicker: selectedMemberType textField:staffNOTextField];
                // change the staff number click action
                staffNOTextField.textFieldDidClickAction = ^void(JRTextField* textField) {
                    [weakSelf popupMembersPicker: selectedMemberType textField:textField];
                };
            }
            
        }];
    };
    
    
    JRLabelCommaTextFieldView *payWay = (JRLabelCommaTextFieldView*)[jsonView getView:@"NESTED_MAIN_Header.payMode"];
    JRLabelCommaTextFieldView *bankAccount = (JRLabelCommaTextFieldView*)[jsonView getView:@"NESTED_MAIN_Header.bankAccount"];
    JRTextField *payWayTextfield = payWay.textField;
    JRTextField *bankAccountTextField = bankAccount.textField;
    
    [FinancePaymentOrderController popPayWayTable: payWayTextfield selectedAction:^(JRButtonsHeaderTableView *sender, NSUInteger selectedIndex, NSString *selectedVisualValue) {
        
        bankAccountTextField.text = nil;
        NSString* selectedMemberType = MODEL_FinanceAccount;
        
        if ([selectedMemberType isEqualToString: KEY_OTHERS]) {
            staffNOTextField.textFieldDidClickAction = nil;
            [staffNOTextField becomeFirstResponder];
        } else {
            // pop
            [weakSelf popupMembersPicker: selectedMemberType textField:bankAccountTextField];
            // change the staff number click action
            bankAccountTextField.textFieldDidClickAction = ^void(JRTextField* textField) {
                [weakSelf popupMembersPicker: selectedMemberType textField:textField];
            };
        }
        
    }];

    // NESTED_MAIN   ------------ End ---------------------------------
    
    
    
    
    
    
    
    // Table Left   ------------ Begin ---------------------------------
    // left table-------------
    tableLeftSectionBillsContents = [[NSMutableArray alloc] init];
    NSMutableArray* weaktableLeftSectionBillsContents = tableLeftSectionBillsContents;
    tableLeft = (JRRefreshTableView*)[jsonView getView:@"TABLE_Left"];
    tableLeft.tableView.tableViewBaseNumberOfSectionsAction = ^NSInteger(TableViewBase* tableViewObj) { return 1; };
    tableLeft.tableView.tableViewBaseCanEditIndexPathAction = ^BOOL(TableViewBase *tableViewObj, NSIndexPath *indexPath) {
        if (indexPath.row == weaktableLeftSectionBillsContents.count) return NO;
        return YES;
    };
    tableLeft.tableView.tableViewBaseShouldDeleteContentsAction = ^BOOL(TableViewBase *tableViewObj, NSIndexPath *indexPath) {
        if (indexPath.row == weaktableLeftSectionBillsContents.count) {
            return NO;
        } else {
            [weaktableLeftSectionBillsContents removeObjectAtIndex: indexPath.row];     // keep the data source update . or will error occur
            return YES;
        }
    };
    tableLeft.tableView.tableViewBaseNumberOfRowsInSectionAction = ^NSInteger(TableViewBase* tableViewObj, NSInteger section) {
        return weakSelf.controlMode == JsonControllerModeCreate ? weaktableLeftSectionBillsContents.count + 1 : weaktableLeftSectionBillsContents.count;
    };
    UITableViewCell *(^ previousCellAction)(TableViewBase *, NSIndexPath *, UITableViewCell *) = tableLeft.tableView.tableViewBaseCellForIndexPathAction;
    tableLeft.tableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath, UITableViewCell* oldCell) {
        if (previousCellAction) previousCellAction(tableViewObj, indexPath, oldCell);       // back ground , border , radius
        FinancePaymentBillCell* financePaymentBillCellView = (FinancePaymentBillCell*)[oldCell viewWithTag: 2030];
        
        // alloc add item view
        if (! financePaymentBillCellView) {
            financePaymentBillCellView = [[FinancePaymentBillCell alloc] init];
            financePaymentBillCellView.paymentController = weakSelf;
            
            [FrameHelper setComponentFrame: specConfig[@"LeftTableOrderCellFrame"] component:financePaymentBillCellView];
            // frames and subrenders
            for (int i = 0; i < financePaymentBillCellView.subviews.count; i++) {
                NSArray* frame = [specConfig[@"LeftTableOrderCellElementsFrames"] safeObjectAtIndex: i];
                UIView* subview = [financePaymentBillCellView.subviews objectAtIndex: i];
                [FrameHelper setComponentFrame: frame component:subview];
                // subRender
                if ([subview conformsToProtocol:@protocol(JRComponentProtocal)]) {
                    [((id<JRComponentProtocal>)subview) subRender: [specConfig[@"LeftTableOrderCellElementsSubRenders"] safeObjectAtIndex: i]];
                }
            }
            financePaymentBillCellView.tag = 2030;
            [oldCell addSubview: financePaymentBillCellView];
            
            // did click first cell action
            JRTextField* itemOrderNOTf = financePaymentBillCellView.itemOrderNOTf;
            itemOrderNOTf.textFieldDidClickAction = ^void(JRTextField* textField) {
                [weakSelf didTapBillItemFirstRowAction: textField];
            };
        }
        
        // set data
        NSMutableDictionary* billValues = [weaktableLeftSectionBillsContents safeObjectAtIndex: indexPath.row];
        [financePaymentBillCellView setBillValues: billValues];
        return oldCell;
    };
    
    // Table Left   ------------ End ---------------------------------
    
    
    
    
    // Table Right   ------------ Begin ---------------------------------
    // super behaviour
    JRButton* priorPageBTN = (JRButton*)[self.jsonView getView:json_BTN_PriorPage];
    JRButton* nextPageBTN = (JRButton*)[self.jsonView getView: json_BTN_NextPage];
    JRButton* backBTN = (JRButton*)[self.jsonView getView: JSON_KEYS(json_NESTED_header, json_BTN_Back)];
    
    NormalButtonDidClickBlock superPriorPageBTNBlock = priorPageBTN.didClikcButtonAction;
    priorPageBTN.didClikcButtonAction = ^void(id sender) {
        [tableRight stopLazyLoading];
        superPriorPageBTNBlock(sender);
    };
    NormalButtonDidClickBlock superNextPageBTNBlock = nextPageBTN.didClikcButtonAction;
    nextPageBTN.didClikcButtonAction = ^void(id sender) {
        [tableRight stopLazyLoading];
        superNextPageBTNBlock(sender);
    };
    backBTN.didClikcButtonAction = ^void(id sender) {
        [tableRight stopLazyLoading];
        [VIEW.navigator popViewControllerAnimated: YES];
    };
    
    // right table-----------
    
    tableRight = (JRImagesTableView*)[jsonView getView:@"TABLE_Right"];
    // right table data
    tableRight.cellImageViewFrame = [RectHelper parseRect: specConfig[@"RightTableImageFrame"]];
    tableRight.tableView.valuesXcoordinates = @[specConfig[@"RightTableImageNameX"]];
    
    tableRightSectionContents = [NSMutableArray array];
    tableRight.tableView.contentsDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tableRightSectionContents, @"IMAGES_NAME", nil];
    
    
    // button ,  take photo to list
    JRButton* takePhotoButton = (JRButton*)[jsonView getView: @"ZZ_BTNTake_Picture"];
    [JRComponentHelper setupPhotoPickerWithInteractivView: takePhotoButton handler:^(AppImagePickerController *imagePickerController) {
        imagePickerController.didFinishPickingImage = ^void(UIImagePickerController* controller, UIImage* image) {
            [controller dismissViewControllerAnimated:YES completion: nil];
            
            NSInteger index = [[tableRightSectionContents lastObject] integerValue];
            NSString* imageName = [NSString stringWithFormat: @"%d", ++index];
            [tableRightSectionContents addObject: imageName];
            
            [tableRight.loadImages addObject: image];
            [tableRight reloadTableData];
        };
        imagePickerController.didCancelPickingImage =  ^void(UIImagePickerController* controller){
           [controller dismissViewControllerAnimated:YES completion: nil];
        };
        
    }];
    // Table Right   ------------ End ---------------------------------
    
    
}


#pragma mark - Override Super Class Methods
-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_READ(self.department);
    [requestModel addModels: self.order, BILL_FinancePaymentBill, nil];
    [requestModel addObjects: objects, @{}, nil];
    [requestModel.preconditions addObjectsFromArray: @[@{}, @{attr_paymentOrderNO: @"0-0-orderNO"}]];
    return requestModel;
}

-(NSMutableDictionary*) assembleReadResponse: (ResponseJsonModel*)response
{
    // Table Left   ------------ Begin ---------------------------------
    
    // load the data to table left
    NSMutableArray* billContents = [ArrayHelper deepCopy:[response.results lastObject]];
    [tableLeftSectionBillsContents setArray: billContents];
    [tableLeft reloadTableData];
    
    // Table Left   ------------ End ---------------------------------
    

    // call super . load the data to json view
    return [super assembleReadResponse:response];
}

-(void) didRenderWithReceiveObjects: (NSMutableDictionary*)objects
{
    [super didRenderWithReceiveObjects: objects];
    
    // Table Right   ------------ Begin ---------------------------------
    // load right table images file names  , set the imagepaths , then the table do lazy loading by itself
    [tableRightSectionContents removeAllObjects];
    tableRight.loadImagesPaths = nil;
    [tableRight reloadTableData];
    
    NSString* rightTableImagesPath = [self getRightTableImagePath];
    [MODEL.requester startDownloadRequest:IMAGE_URL(DOWNLOAD)
                              parameters:@{@"PATH":[NSString stringWithFormat:@"/%@/",rightTableImagesPath]}
                         completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                             NSArray *fileNames = data.results;
                             for (NSString* fileName in fileNames) {
                                 if ([fileName hasSuffix: @"png"] || [fileName hasSuffix: @"jpg"]) {
                                     [tableRightSectionContents addObject: fileName];
                                 }
                             }
                             
                             // occupy the position , ensure the image against to its name
                             NSMutableArray* loadingImagesPaths = [NSMutableArray array];
                             for (int i = 0; i < fileNames.count; i++) {
                                 NSString* fileName = fileNames[i];
                                 NSString* imagePath = [rightTableImagesPath stringByAppendingPathComponent: fileName];
                                 [loadingImagesPaths addObject: imagePath];
                             }
                             tableRight.loadImagesPaths = loadingImagesPaths;
                             [tableRight reloadTableData];
                         }];
    // Table Right   ------------ End ---------------------------------
    
}

-(RequestJsonModel*) assembleSendRequest: (NSMutableDictionary*)withoutImagesObjects order:(NSString*)order department:(NSString*)department
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_CREATE(department);
    [requestModel addModel: order];
    [requestModel addObject: withoutImagesObjects ];
    [requestModel.preconditions addObject: @{}];
    
    for (int i = 0; i < tableLeftSectionBillsContents.count; i++) {
        NSMutableDictionary* itemValues = tableLeftSectionBillsContents[i];
        [requestModel addModel: BILL_FinancePaymentBill];
        [requestModel addObject: itemValues];
        [requestModel.preconditions addObject: @{attr_paymentOrderNO:@"0-orderNO"}];
    }
    
    return requestModel;
}

-(void) didSuccessSendObjects: (NSMutableDictionary*)objects response:(ResponseJsonModel*)response
{
    [super didSuccessSendObjects: objects response:response];
    
    
    // Table Right   ------------ Begin ---------------------------------
    //  save right images
    NSArray* fileNames = tableRightSectionContents;
    NSArray* rightTableImageNames = [self getRightTableImagesNames: fileNames];
    NSMutableArray* rightTableImagesDatas = [NSMutableArray array];
    for (int i = 0; i < tableRight.loadImages.count; i++) {
        UIImage* image = tableRight.loadImages[i];
        [rightTableImagesDatas addObject: UIImageJPEGRepresentation(image, 0.5)];
    }
    __block NSError* errorOccur = nil;
    [AppServerRequester saveImages: rightTableImagesDatas paths:rightTableImageNames completeHandler:^(id identification, ResponseJsonModel *data, NSError *error, BOOL isFinish) {
        if (error) errorOccur = error;
        if (isFinish) {
            if (errorOccur) {
                // TODO ......
                [PopupViewHelper popAlert:@"Failed" message:@"Image Upload Failed ." style:0 actionBlock:^(UIView *popView, NSInteger index) {
                    [VIEW.navigator popViewControllerAnimated: YES];
                } dismissBlock:nil buttons:LOCALIZE_KEY(@"OK"), nil];
                
            }
        }
    }];
    // Table Right   ------------ End ---------------------------------
}


#pragma mark - Private Methods

// Table Right   ------------ Begin ---------------------------------
// Right Table Image Names
-(NSArray*) getRightTableImagesNames: (NSArray*)names
{
    NSString* rightTableImagesPath = [self getRightTableImagePath];
    
    NSMutableArray* imagesFullPaths = [NSMutableArray array];
    for (int i = 0; i < names.count; i++) {
        NSString* imageName = [names objectAtIndex: i] ;
        if(OBJECT_EMPYT([imageName pathExtension])) {
            imageName = [imageName stringByAppendingPathExtension:@"jpg"];
        }
        NSString* imageFullName = [rightTableImagesPath stringByAppendingPathComponent:imageName];
        [imagesFullPaths addObject: imageFullName];
    }
    return imagesFullPaths;
}
-(NSString*) getRightTableImagePath
{
    NSString* signatureImagePath = [JsonControllerHelper getImageNamePathWithOrder:self.order attribute:@"IMG_Signature" jsoncontroller:self];
    NSString* orderResourcesPath = [signatureImagePath stringByDeletingLastPathComponent];
    NSString* rightTableImagePath = [orderResourcesPath stringByAppendingPathComponent: @"images"];
    return  rightTableImagePath;
}
// Table Right   ------------ End ---------------------------------







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


// Table Left   ------------ Begin ---------------------------------
-(void) didTapBillItemFirstRowAction: (JRTextField*) textField
{
    NSInteger row = [TableViewHelper getIndexPath: tableLeft.tableView cellSubView:textField].row;
    NSInteger lastRow = [tableLeft.tableView numberOfRowsInSection:0] - 1;
    
    // is the last row , do add
    if ( row == lastRow && OBJECT_EMPYT([textField getValue])) {
        
        NSArray* departments = @[DEPARTMENT_WAREHOUSE];
        NSArray* orderTypes = @[ORDER_WHPurchaseOrder,@"VehicleApplyOrder"];
        NSArray* orderfields = @[@[PROPERTY_ORDERNO, @"purchaseDate", ReferenceOrder_Attr_TotalShouldPay]];

        [PopupTableHelper popTableView:nil keys:orderTypes selectedAction:^(JRButtonsHeaderTableView *sender, NSUInteger selectedIndex, NSString* selectedVisualValue) {
            NSString* department = [departments objectAtIndex: selectedIndex];
            NSString* orderType = [orderTypes objectAtIndex: selectedIndex];
            NSArray* fields = [orderfields objectAtIndex: selectedIndex];
            
            // pop table view to choose , data loading on avove requester
            PickerModelTableView *pickerTableView = [PickerModelTableView popupWithRequestModel:orderType fields:fields criterias:nil] ;
            
            // set header x
            pickerTableView.tableView.headersXcoordinates = @[@(0), @(200), @(450)];
            
            // choose, the pop action to select
            pickerTableView.tableView.tableView.tableViewBaseDidSelectIndexPathAction = ^void(TableViewBase* tablViewBaseObject, NSIndexPath* indexPath) {
                NSIndexPath* realIndexPath = [(FilterTableView*)tablViewBaseObject getRealIndexPathInFilterMode: indexPath];
                
                NSArray* selectContents = [tablViewBaseObject realContentForIndexPath: realIndexPath];
                id referenceOrderNOid = [selectContents objectAtIndex: [fields indexOfObject:PROPERTY_ORDERNO] + 1];  // cause id index 0
                id shouldPay = [selectContents objectAtIndex: [fields indexOfObject:ReferenceOrder_Attr_TotalShouldPay] + 1];
                
                [PopupViewHelper popAlert: LOCALIZE_MESSAGE(@"SelectAnAction") message:nil style:0 actionBlock:^(UIView *popView, NSInteger index) {
                    // read
                    if (index == 1) {
                        [OrderListControllerHelper navigateToOrderController: department order:orderType identifier:referenceOrderNOid];
                        // add
                    } else if (index == 2) {
                        // check if have already in the payment order
                        NSInteger result = [self checkIsContainsId: referenceOrderNOid contents:tableLeftSectionBillsContents];
                        
                        // then really add it
                        if (result == NSNotFound) {
                            
                            [tableLeftSectionBillsContents addObject: [DictionaryHelper deepCopy:@{
                                                                                                   attr_referenceOrderType:orderType,
                                                                                                   attr_referenceOrderNO:referenceOrderNOid,
                                                                                                   attr_shouldPay:shouldPay
                                                                                                   }]];
                            [tableLeft reloadTableData];
                            
                            // dismiss the table
                            [PickerModelTableView dismiss];
                        } else {
                            [AppViewHelper alertWarning: LOCALIZE_MESSAGE_FORMAT(@"AlreadyExist", referenceOrderNOid)];
                            [tableLeft.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:result inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                        }
                        
                    }
                } dismissBlock:nil buttons:LOCALIZE_KEY(KEY_CANCEL), LOCALIZE_KEY(@"read"), LOCALIZE_KEY(KEY_ADD), nil];
            };
        } ];
        
    // not the last row
    } else {
        [PopupViewHelper popAlert: LOCALIZE_MESSAGE(@"SelectAnAction") message:nil style:0 actionBlock:^(UIView *popView, NSInteger index) {
            // read
            if (index == 1) {
                // get the department and orderType
                NSString* order = ((FinancePaymentBillCell*)textField.superview).order;
                NSString* department = [MODEL.modelsStructure getCategory: order];
                
                // get identificaion
                id identification = [[tableLeftSectionBillsContents objectAtIndex: row] objectForKey:attr_referenceOrderNO];
                // show
                [OrderListControllerHelper navigateToOrderController: department order:order identifier:identification];
            }
        } dismissBlock:nil buttons:LOCALIZE_KEY(KEY_CANCEL), LOCALIZE_KEY(@"read"), nil];
    }
}

-(NSInteger) checkIsContainsId: (NSString*)itemNO contents:(NSArray*)contents
{
    for (int i = 0; i < contents.count; i++) {
        NSDictionary* itemValues = [contents objectAtIndex: i];
        if ([itemValues[attr_referenceOrderNO] isEqualToString: itemNO]) {
            return i;
        }
    }
    return NSNotFound;
}

- (void)updateDataSourcesWhenTextFieldDidEndEditing:(JRTextField *)jrTextField
{
    id value = [jrTextField getValue];
    if (value) {
        NSIndexPath* indexPath = [TableViewHelper getIndexPath: tableLeft.tableView cellSubView:jrTextField];
        NSMutableDictionary* itemValues = [tableLeftSectionBillsContents safeObjectAtIndex: indexPath.row];
        if (itemValues) {
            [itemValues setObject:value forKey:jrTextField.attribute];
            [tableLeft reloadTableData];
        }
    }
}


// Table Left   ------------ End ---------------------------------



@end
