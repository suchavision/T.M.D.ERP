#import "FinanceReceiptOrderController.h"
#import "AppInterface.h"
#import "FinanceReceiptBill.h"



@implementation FinanceReceiptOrderController
{
    JRRefreshTableView* tableLeft;
    JRImagesTableView* tableRight;
    
    NSMutableArray* tableRightSectionContents;
    NSMutableArray* tableLeftSectionBillsContents;
   
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->tableLeftSectionBillsContents = [[NSMutableArray alloc] init];
        tableRightSectionContents  = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    JsonView* jsonView = self.jsonView;
    __weak FinanceReceiptOrderController* weakSelf = self;
    __block FinanceReceiptOrderController *blockWeakSelf = self;
    NSDictionary* specConfig = self.specifications[@"Specifications"];
    
    
    tableLeft = (JRRefreshTableView *)[jsonView getView:@"NESTED_MAIN_Table.TABLE_Left"];
    tableLeft.tableView.tableViewBaseNumberOfSectionsAction = ^NSInteger(TableViewBase *tableViewObj)
    {
        return 1;
    };
    tableLeft.tableView.tableViewBaseNumberOfRowsInSectionAction = ^NSInteger(TableViewBase *tableViewObj , NSInteger section){
        return weakSelf.controlMode == JsonControllerModeCreate ?  blockWeakSelf->tableLeftSectionBillsContents.count+1 : blockWeakSelf-> tableLeftSectionBillsContents.count;
    
    };
    tableLeft.tableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase *tableViewObj , NSIndexPath *indexPath, UITableViewCell *olderCell){
        static NSString *CellIdentifier = @"cell";
        FinanceReceiptBill *cell = [tableViewObj dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell)
        {
            cell = [[FinanceReceiptBill alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.didEndEditNewCellAction = ^void(BaseJRTableViewCell* cell){
                FinanceReceiptBill* purchaseCell = (FinanceReceiptBill*)cell;
                NSIndexPath* indexPath = [tableViewObj indexPathForCell: purchaseCell];
                int row = indexPath.row;
                if (row == blockWeakSelf->tableLeftSectionBillsContents.count) {
                    [blockWeakSelf->tableLeftSectionBillsContents addObject:[cell getDatas]];
                } else {
                    [blockWeakSelf->tableLeftSectionBillsContents replaceObjectAtIndex:row withObject:[cell getDatas]];
                }
                
                [tableViewObj reloadData];
                [tableViewObj scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            };

        }
        [cell setDatas: [blockWeakSelf->tableLeftSectionBillsContents safeObjectAtIndex: indexPath.row]];
        return cell;
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
    NSString* departmentOrderTypePath = [JsonControllerHelper getImagesHomeFolder: self.order department:self.department];
    NSString* orderNO = self.valueObjects[PROPERTY_ORDERNO];
    NSString* orderNOFolderPath = [departmentOrderTypePath stringByAppendingString:orderNO];
    NSString* rightTableImagePath = [orderNOFolderPath stringByAppendingPathComponent: @"images"];
    return  rightTableImagePath;
}
// Table Right   ------------ End ---------------------------------





#pragma mark -
#pragma mark - Request
-(RequestJsonModel*) assembleSendRequest: (NSMutableDictionary*)withoutImagesObjects order:(NSString*)order department:(NSString*)department
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_CREATE(department);
    [requestModel addModel: order];
    [requestModel addObject: withoutImagesObjects ];
    [requestModel.preconditions addObject: @{}];
    
    for (int i = 0; i < tableLeftSectionBillsContents.count; i++) {
        NSMutableDictionary* itemValues = tableLeftSectionBillsContents[i];
        [requestModel addModel: @"FinanceReceiptBill"];
        [requestModel addObject: itemValues];
        [requestModel.preconditions addObject: @{@"receiptOrderNO":@"0-orderNO"}];
    }
    
    return requestModel;
}





-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_READ(self.department);
    [requestModel addModels: self.order, @"FinanceReceiptBill", nil];
    [requestModel addObjects: objects, @{}, nil];
    [requestModel.preconditions addObjectsFromArray: @[@{}, @{@"receiptOrderNO": @"0-0-orderNO"}]];
    return requestModel;
}

-(NSMutableDictionary*) assembleSendObjects: (NSString*)divViewKey
{
    NSMutableDictionary* objects = [super assembleSendObjects:divViewKey];
    
//    if (vendorNumber && self.controlMode == JsonControllerModeCreate) [objects setObject: vendorNumber forKey:@"vendorNumber"];
    
    return objects;
}


#pragma mark -
#pragma mark - Response
-(NSMutableDictionary*) assembleReadResponse: (ResponseJsonModel*)response
{
    NSArray* results = response.results;
    
    DLOG(@"++++++++++ %@", results);
    
    NSDictionary* orderValues = [[results firstObject] firstObject];
    self.valueObjects = [DictionaryHelper deepCopy: orderValues];
    
    NSArray* billValues = [results lastObject];
    [tableLeftSectionBillsContents setArray:billValues];
    [tableLeft reloadTableData];
    
    return self.valueObjects;
}










#pragma mark - Private Methods



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
        // get table cell
        UITableViewCell* cell = [TableViewHelper getTableViewCellBySubView:textField];
        // get the index path
        NSIndexPath* indexPath = [tableLeft.tableView indexPathForCell: cell];
        
        NSMutableDictionary* itemValues = [tableLeftSectionBillsContents safeObjectAtIndex: indexPath.row];
        if (itemValues) {
            [itemValues setObject:value forKey:jrTextField.attribute];
            [tableLeft reloadTableData];
        }
    }
}



@end
