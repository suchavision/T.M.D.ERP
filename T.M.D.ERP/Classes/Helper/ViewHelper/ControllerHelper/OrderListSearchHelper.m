#import "OrderListSearchHelper.h"
#import "AppInterface.h"


#define Date_Seperator @" ~ "

@implementation OrderListSearchHelper
{
    BaseOrderListController* _orderListController;
    NSMutableArray* _backupCriterias ;
    
    
    TableViewBase* _searchTableView;
    NSMutableDictionary* _searchValuesDataSources;
}


- (instancetype)initWithController: (BaseOrderListController*)listController
{
    self = [super init];
    if (self) {
        _orderListController = listController;
        _backupCriterias = [[NSMutableArray alloc] initWithArray: listController.requestModel.criterias];
        
        _searchValuesDataSources = [[NSMutableDictionary alloc] init];
        
        
        _orderPropertiesMap = [MODEL.modelsStructure getModelStructure: listController.order];
        _orderSearchProperties = [[_orderPropertiesMap allKeys] mutableCopy];
        _searchTableViewSuperView = [PopupTableHelper getCommonPopupTableView];
        
        [self initializeTableViewAndEvent];
    }
    return self;
}


- (void) initializeTableViewAndEvent
{
    __weak OrderListSearchHelper* weakInstance = self;
    
    // local variables
    NSString* orderType = _orderListController.order;
    NSMutableArray* orderSearchProperties = _orderSearchProperties;
    NSMutableDictionary* searchValuesDataSources = _searchValuesDataSources;
    
    JRButtonsHeaderTableView* searchHeaderTableView = (JRButtonsHeaderTableView*)[_searchTableViewSuperView viewWithTag: POPUP_TABLEVIEW_TAG];
    [searchHeaderTableView.tableView setHideSearchBar: YES];
    _searchTableView = searchHeaderTableView.tableView.tableView;
    TableViewBase* tableViewBaseObj = _searchTableView;
    
    // change the button title and button event
    JRButton* rightButton = searchHeaderTableView.rightButton;
    [rightButton setTitle:LOCALIZE_KEY(@"SEARCH") forState:UIControlStateNormal];
    rightButton.didClikcButtonAction = ^void(JRButton* button) {
        [weakInstance searchButtonAction];
    };
    
    JRButton* leftButton = searchHeaderTableView.leftButton;
    [leftButton setTitle:LOCALIZE_KEY(@"clear") forState:UIControlStateNormal];
    leftButton.didClikcButtonAction = ^void(JRButton* button) {
        [weakInstance clearButtonAction];
    };
    
    // set the table contents
    
    tableViewBaseObj.tableViewBaseDidSelectIndexPathAction = ^void(TableViewBase* tableViewObj, NSIndexPath* indexPath) {
        NSString* property = orderSearchProperties[indexPath.row];
        BOOL isBooleanValue = [weakInstance isBooleanValue: property];
        if (isBooleanValue) {
            if (!searchValuesDataSources[property]) {
                [searchValuesDataSources setObject: @(YES) forKey:property];
            } else {
                [searchValuesDataSources removeObjectForKey: property];
            }
            [tableViewObj reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    };
    tableViewBaseObj.tableViewBaseNumberOfSectionsAction = ^NSInteger(TableViewBase* tableViewObj) {
        return 1;
    };
    tableViewBaseObj.tableViewBaseNumberOfRowsInSectionAction = ^NSInteger(TableViewBase* tableViewObj, NSInteger section) {
        return orderSearchProperties.count;
    };
    tableViewBaseObj.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath, UITableViewCell* oldCell) {
        NSString* property = orderSearchProperties[indexPath.row];
        
        // Label
        NSInteger labelTag = 1000111;
        JRLocalizeLabel* label = (JRLocalizeLabel*)[oldCell.contentView viewWithTag: 1000111];
        if (!label) {
            label = [[JRLocalizeLabel alloc] initWithFrame:CanvasRect(10, 10, 120, 70)];
            label.tag = labelTag;
            [oldCell.contentView addSubview: label];
            
            label.font = [UIFont systemFontOfSize: CanvasFontSize(23)];
            label.disableChangeTextTransition = YES;
        }
        label.text = nil;
        
        
        // TextField
        NSInteger textFieldTag = 1000222;
        JRTextField* textField = (JRTextField*)[oldCell.contentView viewWithTag: textFieldTag];
        CGRect rect = CanvasRect(140, 10, 200, 45);
        if (!textField) {
            textField = [[JRTextField alloc] init];
            textField.tag = textFieldTag;
            [oldCell.contentView addSubview: textField];
            
            textField.borderStyle = UITextBorderStyleNone;
            textField.textAlignment = NSTextAlignmentCenter;
            [LayerHelper setAttributesValues: @{@"borderColor": [UIColor flatGrayColor], @"borderWidth": @(1.0f), @"cornerRadius": @(5)} layer:textField.layer];
        }
        textField.frame = rect;
        textField.textFieldDidClickAction = nil;
        [textField setValue: nil];
        textField.hidden = YES;
        
        
        // Checkbox
        NSInteger checkBoxTag = 3000333;
        JRCheckBox* checkBox = (JRCheckBox*)[oldCell.contentView viewWithTag: checkBoxTag];
        if (!checkBox) {
            checkBox = [[JRCheckBox alloc] initWithFrame:CanvasRect(280, 0, 50, 50)];
            checkBox.tag = checkBoxTag;
            [oldCell.contentView addSubview: checkBox];
        }
        checkBox.checked = NO;
        checkBox.hidden = YES;
        
        // set text and date event
        NSString* text = APPLOCALIZES(orderType, property);
        
        BOOL isBooleanValue = [weakInstance isBooleanValue: property];
        if (isBooleanValue) {
            
            checkBox.hidden = NO;
            text = [LOCALIZE_KEY(@"if") stringByAppendingString: text];
            
        } else {
            
            textField.hidden = NO;
            
            NSArray* levelApps = @[levelApp1, levelApp2, levelApp3, levelApp4];
            if ([levelApps containsObject: property]) {
                
                text = [text stringByAppendingString: LOCALIZE_KEY(@"people")];
                
            } else {
                
                BOOL isDate = [weakInstance isDateValue: property];
                if (isDate) {
                    
                    // longer...
                    [textField addOriginX: -CanvasW(20)];
                    [textField addSizeWidth: CanvasW(40)];
                    
                    textField.textFieldDidClickAction = ^void(JRTextField* textFieldObj) {
                        
                        
                        // From
                        [JRComponentHelper showDatePickerView:UIDatePickerModeDate title:LOCALIZE_KEY(@"from") date:[NSDate date] confirmAction:^(NSDate *selectedDate) {
                            
                            
                            // get the "From" date   ...
                            NSString* fromString = [DateHelper stringFromDate:selectedDate pattern:PATTERN_DATE];
                            textFieldObj.text = fromString;
                            
                            [JRComponentHelper showDatePickerView:UIDatePickerModeDate title:LOCALIZE_KEY(@"to") date:[NSDate date] confirmAction:^(NSDate *selectedDateTo) {
                                
                                // get the "To" date   ...
                                NSString* fromString = textFieldObj.text;
                                NSString* toString = [DateHelper stringFromDate:selectedDateTo pattern:PATTERN_DATE];
                                NSString* scopeString = [fromString stringByAppendingFormat:@"%@%@", Date_Seperator, toString ];
                                textFieldObj.text = scopeString;
                                
                            } cancelAction:nil];
                            
                            
                        } cancelAction:^(NSDate *selectedDate) {
                            textFieldObj.text = nil;
                        }];
                        
                        
                    };
                    
                    
                }
                
            }
            
        }
        
        
        //        NSLog(@"++ %@ : %@", property, text);
        label.text = text;
        [label adjustWidthToFontText];
        
        
        
        // clear background and set background
        [weakInstance clearCellBackgroundColor: oldCell];
        if (isBooleanValue) {
            if (searchValuesDataSources[property]) {
                [weakInstance setCellBackgroundColor: oldCell];
            }
        }
        // set value to checkbox and textfield
        if (searchValuesDataSources[property]) {
            checkBox.checked = [searchValuesDataSources[property] boolValue];
            [textField setValue: searchValuesDataSources[property]] ;
        }
        
        // set changed data to datasource
        if (!textField.textFieldDidSetTextBlock) {
            textField.textFieldDidSetTextBlock = ^void(NormalTextField* textField, NSString* oldText) {
                [weakInstance valueDidChangeAction: textField];
            };
        }
        if (!checkBox.stateChangedBlock) {
            checkBox.stateChangedBlock = ^void(JRCheckBox *checkBox) {
                [weakInstance valueDidChangeAction: checkBox];
            };
        }
        
        
        return oldCell;
    };
    tableViewBaseObj.tableViewBaseWillShowCellAction = ^void(TableViewBase* tableViewObj, UITableViewCell* cell, NSIndexPath* indexPath) {
        for (UIView* subview in cell.contentView.subviews) {
            [subview setCenterY: [cell.contentView sizeHeight]/2];
        }
    };
}



#pragma mark - Private Methods

-(void) setCellBackgroundColor: (UITableViewCell*)cell
{
    [ColorHelper setBackGround: cell color:[[UIColor flatBlueColor] colorWithAlphaComponent: 0.3]];
}

-(void) clearCellBackgroundColor: (UITableViewCell*)cell
{
    [ColorHelper setBackGround: cell color:[UIColor clearColor]];
}

-(void) valueDidChangeAction: (id)sender
{
    NSIndexPath* indexPath = [TableViewHelper getIndexPath: _searchTableView cellSubView:sender];
    if (!indexPath) return;
    UITableViewCell* cell = [TableViewHelper getTableViewCell: _searchTableView cellSubView:sender];
    
    NSString* property = _orderSearchProperties[indexPath.row];
//    NSLog(@"%d,%d : %@", indexPath.section, indexPath.row, property);
    id value = nil;
    
    if ([sender isKindOfClass:[JRTextField class]]) {
        
        JRTextField* textField = (JRTextField*)sender;
        value = [textField getValue];
        
    } else if ([sender isKindOfClass:[JRCheckBox class]]) {
        
        JRCheckBox* checkBox = (JRCheckBox*)sender;
        value = @(checkBox.checked);
        [self setCellBackgroundColor: cell];
        
    }
    
    if (!OBJECT_EMPYT(value)) {
        [_searchValuesDataSources setObject: value forKey:property];
    } else {
        [_searchValuesDataSources removeObjectForKey: property];
    }
}




-(BOOL) isBooleanValue: (NSString*)property
{
    return [self isProperty: property valueType:@"boolean"];
}

-(BOOL) isDateValue: (NSString*)property
{
    return [self isProperty: property valueType:@"Date"];
}

-(BOOL) isProperty: (NSString*)property valueType: (NSString*)type
{
    BOOL result = [_orderPropertiesMap[property] isEqualToString:type];
    return result;
}





#pragma mark - Button Action

-(void) searchButtonAction
{
    RequestJsonModel* requesJsonModel = _orderListController.requestModel;
    NSMutableArray* criterias = requesJsonModel.criterias;
    
    NSLog(@"search: %@, criterias: %@", _searchValuesDataSources, criterias);
    
    
    // For test now ...
    NSMutableDictionary* searchConditions = [NSMutableDictionary dictionary];
    for (NSString* key in _searchValuesDataSources) {
        NSString* value = _searchValuesDataSources[key];
        
        BOOL isBoolValue = [self isBooleanValue: key];

        if (isBoolValue) {
            
        } else {
            NSString* string = [CRITERIAL_GT stringByAppendingString:value];
            [searchConditions setObject: string forKey:key];
        }
    }
    
    NSDictionary* and = @{CRITERIAL_AND: searchConditions};
    if ([criterias firstObject]) {
        [criterias replaceObjectAtIndex: 0 withObject:and];
    } else {
        [criterias addObject:and];
    }
    
    [self hideSearchTableView];
    
    
    [_orderListController requestForDataFromServer];
}



-(void) clearButtonAction
{
    [_searchValuesDataSources removeAllObjects];
    [_searchTableView reloadData];
}





#pragma mark - Public Methods

-(void) showSearchTableView
{
    if ([PopupViewHelper isCurrentPopingView]) {
        return;
    }
    [PopupViewHelper popView:_searchTableViewSuperView willDissmiss:nil];
}


-(void) hideSearchTableView
{
    [PopupViewHelper dissmissCurrentPopView];
}

@end
