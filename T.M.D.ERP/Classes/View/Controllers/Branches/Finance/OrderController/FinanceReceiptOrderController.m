#import "FinanceReceiptOrderController.h"
#import "AppInterface.h"
#import "FinancePaymentBillCell.h"



#define STAFF_CATEGORY              @"staffCategory"
#define STAFF_NUMBER                @"staffNO"
#define ReferenceOrder_Attr_TotalShouldPay @"totalPay"

@implementation FinanceReceiptOrderController
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    tableRightSectionContents = [NSMutableArray array];
    tableLeftSectionBillsContents = [NSMutableArray array];
    JsonView* jsonView = self.jsonView;
    __weak FinanceReceiptOrderController* weakSelf = self;
    NSDictionary* specConfig = self.specifications[@"Specifications"];
    
    JRButton* priorPageBTN = (JRButton*)[self.jsonView getView:json_BTN_PriorPage];
    JRButton* nextPageBTN = (JRButton*)[self.jsonView getView: json_BTN_NextPage];
    JRButton* backBTN = (JRButton*)[self.jsonView getView: JSON_KEYS(json_NESTED_header, json_BTN_Back)];
    
    
    NormalButtonDidClickBlock superPriorPageBTNBlock = priorPageBTN.didClikcButtonAction;
    priorPageBTN.didClikcButtonAction = ^void(id sender) {
        [tableRight stopLazyLoading];
        superPriorPageBTNBlock(sender);
        NSLog(@"priorPageBTN-------");
    };
    NormalButtonDidClickBlock superNextPageBTNBlock = nextPageBTN.didClikcButtonAction;
    nextPageBTN.didClikcButtonAction = ^void(id sender) {
        [tableRight stopLazyLoading];
        superNextPageBTNBlock(sender);
        NSLog(@"nextPageBTN-------");

    };
    backBTN.didClikcButtonAction = ^void(id sender) {
        [tableRight stopLazyLoading];
        [VIEW.navigator popViewControllerAnimated: YES];
        NSLog(@"backBTN-------");
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
        
        NSString* number = [filterTableView realContentForIndexPath: realIndexPath];
        [textField setValue: number];
        [PickerModelTableView dismiss];
    };
}




#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    JRTextField* jrTextField = (JRTextField*)textField;
    id value = [jrTextField getValue];
    if (value) {
        NSIndexPath* indexPath = [TableViewHelper getIndexPath: tableLeft.tableView cellSubView:textField];
        NSMutableDictionary* itemValues = [tableLeftSectionBillsContents safeObjectAtIndex: indexPath.row];
        if (itemValues) {
            [itemValues setObject:value forKey:jrTextField.attribute];
            [tableLeft reloadTableData];
        }
    }
}



@end
