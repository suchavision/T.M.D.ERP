#import "PopupTableHelper.h"
#import "AppInterface.h"

@implementation PopupTableHelper


#pragma mark - New Interface
+(void) setupPopTableViewsInJsonView:(JsonView*)jsonView config:(NSDictionary*)config
{
    for (NSString* attribute in config) {
        NSString* type = config[attribute];
        JRTextField* jrTextField = [JRComponentHelper getJRTextField: [jsonView getView: attribute]];
        [self setupPopTableView: jrTextField type:type];
    }
}

+(void) setupPopTableView: (JRTextField*)textField type:(NSString*)type
{
    if ([type isEqualToString:VALUES_PICKER_gender]) {
        [JRTextField setTextFieldBoolValueAction:textField keys:HR_GENDERS_KEYS titleKey:type];
        return;
    }
    
    
    textField.textFieldDidClickAction = ^void (JRTextField* jrTextField) {
        
        if ([type isEqualToString:VALUES_PICKER_department]) {
            
            [VIEW.progress show];
            [AppServerRequester readSetting: APPSettings_TYPE_USER_JOBPOSITIONS completeHandler:^(ResponseJsonModel *data, NSError *error) {
                [VIEW.progress hide];
                
                NSString* jobPositionString = data.results[@"settings"];
                NSMutableArray* dataSources = [PopupTableHelper getJobPositionDataSoucesFromSettingsString: jobPositionString];
                
                [self showPopTableView: jrTextField titleKey:type dataSources:dataSources];
            }];
            
            return;
        }
        
        NSArray* dataSources = nil ;
        if ([type isEqualToString:VALUES_PICKER_jobLevel]) {
            [PopupTableHelper showUpJobLevelPopTableView: jrTextField];
            return;
            
        } else if ([type isEqualToString:VALUES_PICKER_eduDegree]) {
            dataSources = [LocalizeHelper localize: HR_EDU_DEGREE_KEYS] ;
        } else if ([type isEqualToString:VALUES_PICKER_eduRecord] ) {
            dataSources = [LocalizeHelper localize: HR_EDU_RECORD_KEYS] ;
        }
        
        [self showPopTableView: jrTextField titleKey:type dataSources:dataSources];
        
    };
}

+(NSMutableArray*) getJobPositionDataSoucesFromSettingsString: (NSString*)jobPositionString
{
    NSString* keyPrefix = @"KEY.";
    NSMutableArray* temp = [ArrayHelper deepCopy: [CollectionHelper convertJSONStringToJSONObject:jobPositionString]];
    NSString* key_finance = [keyPrefix stringByAppendingString:DEPARTMENT_FINANCE];
    NSString* key_business = [keyPrefix stringByAppendingString:DEPARTMENT_BUSINESS];
    if (temp.count == 0) {
        [temp addObjectsFromArray: @[key_finance, key_business]];
    } else {
        if (! [temp containsObject: key_finance]) {
            [temp insertObject:key_finance atIndex:0];
        }
        if (! [temp containsObject: key_business]) {
            [temp insertObject: key_business atIndex:0];
        }
    }
    
    
    NSMutableArray* dataSources = [NSMutableArray array];
    for (int i = 0; i < temp.count; i++) {
        NSString* value = temp[i];
        if ([value hasPrefix: keyPrefix]) {
            NSString* key = [[value componentsSeparatedByString: keyPrefix] lastObject];
            value = LOCALIZE_KEY(key);
        }
        [dataSources addObject: value];
    }

    return dataSources;
}

+(JRButtonsHeaderTableView*) showUpJobLevelPopTableView: (JRTextField*)jrTextField
{
    JRButtonsHeaderTableView* searchTableView = [self showPopTableView: jrTextField titleKey:VALUES_PICKER_jobLevel dataSources:nil];
    
    [AppViewHelper showIndicatorInView: searchTableView];
    [AppServerRequester readSetting: APPSettings_TYPE_USER_JOBLEVELS completeHandler:^(ResponseJsonModel *data, NSError *error) {
        [AppViewHelper stopIndicatorInView: searchTableView];
        
        NSArray* array = MODEL.config[@"JOBLEVELS"];
        NSString* jobLevelJsonString = data.results[@"settings"];
        if (jobLevelJsonString) {
            NSArray* temp =[CollectionHelper convertJSONStringToJSONObject:jobLevelJsonString];
            if (temp) array = temp;
        }
        searchTableView.tableView.tableView.contentsDictionary = [DictionaryHelper deepCopy: @{@"JOBLEVELS": array}];
        [searchTableView.tableView reloadTableData];
    }];
    
    searchTableView.tableView.headersXcoordinates = @[@(50),@(100)];
    searchTableView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
        FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
        NSArray* value = [filterTableView contentForIndexPath:indexPath];
        [jrTextField setValue: [value firstObject]];
        [PopupViewHelper dissmissCurrentPopView];
    };
    return searchTableView;
}

+(void) dissmissCurrentPopTableView
{
    [PopupViewHelper dissmissCurrentPopView];
}


// title key is type
+(JRButtonsHeaderTableView*) showPopTableView: (JRTextField*)textField titleKey:(NSString*)titleKey dataSources:(NSArray*)dataSources
{
    return [self showPopTableView:textField titleKey:titleKey dataSources:dataSources realDataSources:nil];
}

+(JRButtonsHeaderTableView*) showPopTableView: (JRTextField*)textField titleKey:(NSString*)titleKey dataSources:(NSArray*)dataSources realDataSources:(NSArray*)realDataSources
{
    UIView* superView = [PopupTableHelper getCommonPopupTableView];
    JRButtonsHeaderTableView* searchTableView = (JRButtonsHeaderTableView*)[superView viewWithTag: POPUP_TABLEVIEW_TAG];
    [searchTableView.tableView setHideSearchBar: YES];
    
    if (dataSources) {
        searchTableView.tableView.tableView.contentsDictionary = [DictionaryHelper deepCopy:@{@"": dataSources}];
    }
    if (realDataSources) {
        searchTableView.tableView.tableView.realContentsDictionary = [DictionaryHelper deepCopy:@{@"": realDataSources}];
    }
    searchTableView.titleLabel.text = LOCALIZE_KEY(titleKey);
    searchTableView.rightButton.hidden = YES;
    searchTableView.leftButton.hidden = YES;
    
    searchTableView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
        FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
        id value = [filterTableView contentForIndexPath:indexPath];
        [textField setValue: value];
        [PopupViewHelper dissmissCurrentPopView];
    };
    [PopupViewHelper popView:superView willDissmiss:nil];
    
    return searchTableView;
}



+(JRButtonsHeaderTableView*) popTableView: (NSString*)title keys:(NSArray*)keys selectedAction:(void(^)(JRButtonsHeaderTableView* sender, NSUInteger selectedIndex, NSString* selectedVisualValue))selectedAction
{
    NSArray* localizeKeys = [LocalizeHelper localize: keys] ;
    JRButtonsHeaderTableView* searchTableView = [self showPopTableView: nil titleKey:title dataSources:localizeKeys];
    searchTableView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
        [PopupViewHelper dissmissCurrentPopView];
        if (selectedAction) {
            NSUInteger selectedIndex = indexPath.row;
            NSString* selectedVisualValue = [headerTableView.tableView.tableView contentForIndexPath: indexPath];
            selectedAction((JRButtonsHeaderTableView*)headerTableView, selectedIndex, selectedVisualValue);
        }
    };
    return searchTableView;
}


+(UIView*) getCommonPopupTableView
{
    // background
    UIImage* bgImage = [UIImage imageNamed:@"Pushbutton_06.png"];
    UIImageView* bgImageView = [[UIImageView alloc] initWithImage: bgImage];
    [bgImageView setSize:[FrameTranslater convertCanvasSize: bgImage.size]];
    bgImageView.userInteractionEnabled = YES;
    
    
    JRButtonsHeaderTableView* searchTableView = [[JRButtonsHeaderTableView alloc] initWithFrame: CGRectMake([FrameTranslater convertCanvasX:15], 0, [bgImageView sizeWidth] - [FrameTranslater convertCanvasWidth:28], [bgImageView sizeHeight] - [FrameTranslater convertCanvasHeight:30])];
    searchTableView.headerView.backgroundColor = [UIColor clearColor];
    searchTableView.tableView.backgroundColor = [UIColor clearColor];
    searchTableView.tableView.tableView.backgroundColor = [UIColor clearColor];
    searchTableView.tag = POPUP_TABLEVIEW_TAG;
    [bgImageView addSubview: searchTableView];
    
    searchTableView.tableView.headerTableViewHeaderHeightAction = ^CGFloat(HeaderTableView* tableViewObj) {
        return 0;
    };
    searchTableView.tableView.tableView.tableViewBaseTitleForDeleteButtonAction = ^NSString*(TableViewBase* tableViewBase, NSIndexPath* indexPath) {
        return LOCALIZE_KEY(KEY_DELETE);
    };
    
    JRButton* rightButton = searchTableView.rightButton;
    [rightButton setBackgroundImage:[UIImage imageNamed:@"Pushbutton_08.png"] forState:UIControlStateNormal];
    rightButton.frame = CanvasRect(285, 5, 84, 46);
    [rightButton setTitle:LOCALIZE_KEY(@"edit") forState:UIControlStateNormal];
    
    
    
    JRButton* leftButton = searchTableView.leftButton;
    [leftButton setBackgroundImage:[UIImage imageNamed:@"Pushbutton_08.png"] forState:UIControlStateNormal];
    leftButton.frame = CanvasRect(0, 5, 84, 46);
    
    [leftButton setTitle:LOCALIZE_KEY(@"CANCEL") forState:UIControlStateNormal];
    
    
    return bgImageView;
}

@end
