//
//  WHPickingOrderController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-16.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "WHPickingOrderController.h"
#import "AppInterface.h"

#import "PopBubbleView.h"

@interface WHPickingOrderController ()<UITextFieldDelegate>
{
    NSMutableArray* _unitArray;
    NSMutableArray* _priceArray;
    
    JRTextField* _pickingAmountTxtField;
    JRTextField* _priceTxtField;
    JRTextField* _totalPriceTxtField;
    
}
@end

@implementation WHPickingOrderController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _unitArray = [[NSMutableArray alloc] init];
    _priceArray = [[NSMutableArray alloc] init];
    
    /*select productCategory*/
    JRTextField* productCategoryTxtField= ((JRLabelTextFieldView*)[self.jsonView getView:@"productCategory"]).textField;
    productCategoryTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField){
        [WarehouseHelper popTableView:jrTextField settingModel:APPSettings_WHAREHOUSE_PRODUCT_CATEGORY];
        
        JRButtonsHeaderTableView* modelTableView = (JRButtonsHeaderTableView*)[[ViewHelper getTopView] viewWithTag: POPUP_TABLEVIEW_TAG];
        [modelTableView.rightButton setHidden:YES];
        
    };
    
    
    /*select productCode*/
    JRTextField* productCodeTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"productCode"]).textField;
    JRTextField* productNameTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"productName"]).textField;
    
    productCodeTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField){
        
        NSMutableDictionary* criteriasDic;
        if (isEmptyString(productCategoryTxtField.text)){
            criteriasDic = [NSMutableDictionary dictionary];
        }else{
            criteriasDic = [NSMutableDictionary dictionaryWithDictionary:@{@"productCategory": [NSString stringWithFormat:@"EQ<>%@",productCategoryTxtField.text]}];
        }
        
        NSArray* needFields = @[@"productCode",@"productName",@"productCategory"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_WHInventory fields:needFields criterias:@{@"and" : criteriasDic}];
        pickView.tableView.headersXcoordinates = @[@(20), @(170),@(300)];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            
            id idetification = [[filterTableView realContentForIndexPath: realIndexPath] firstObject];
            NSDictionary* objects = @{PROPERTY_IDENTIFIER: idetification};
            
            [VIEW.progress show];
            [AppServerRequester readModel: MODEL_WHInventory department:DEPARTMENT_WAREHOUSE objects:objects fields:@[@"basicUnit",@"unit",@"priceBasicUnit",@"priceUnit"] completeHandler:^(ResponseJsonModel *data, NSError *error) {
                NSArray* objectArr = [[data.results firstObject] firstObject];
                
                [_unitArray addObject:objectArr[0]];
                [_unitArray addObject:objectArr[1]];
                [_priceArray addObject:objectArr[2]];
                [_priceArray addObject:objectArr[3]];
                
                [VIEW.progress hide];
                
            }];
            
            NSArray* array = [filterTableView realContentForIndexPath: realIndexPath];
            jrTextField.text = [array objectAtIndex:1];
            productNameTxtField.text = [array objectAtIndex:2];
            productCategoryTxtField.text = [array objectAtIndex:3];

            [PickerModelTableView dismiss];
        };
        
    };
    
    /*select pickingStaff*/
    JRTextField* pickingStaffTxtField= ((JRLabelTextFieldView*)[self.jsonView getView:@"pickingStaff"]).textField;
    pickingStaffTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField){
        
        PickerModelTableView* pickView = [PickerModelTableView popupWithModel:MODEL_EMPLOYEE];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            jrTextField.text = [MODEL.usersNONames objectForKey:[filterTableView realContentForIndexPath: realIndexPath]];
            [PickerModelTableView dismiss];
        };
        
    };
    
    /*select unit*/
    JRTextField* unitTxtField= ((JRLabelTextFieldView*)[self.jsonView getView:@"unit"]).textField;
    _priceTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"unitPrice"]).textField;
    __weak JRTextField* weakPriceTxtField = _priceTxtField;
    unitTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField){
        
        [PopBubbleView popTableBubbleView:jrTextField title:LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(ORDER_WHPickingOrder,@"unit")) dataSource:_unitArray selectedBlock:^(NSInteger selectedIndex, NSString *selectedValue) {
            NSLog(@"selectedValue == %@",selectedValue);
            weakPriceTxtField.text = [[_priceArray objectAtIndex:selectedIndex] stringValue];
            jrTextField.text = selectedValue;
            
        }];
//        [PopBubbleView popCustomBubbleView:jrTextField keys:_unitArray selectedBlock:^(NSInteger selectedIndex, NSString *selectedValue) {
//            NSLog(@"selectedValue == %@",selectedValue);
//            weakPriceTxtField.text = [[_priceArray objectAtIndex:selectedIndex] stringValue];
//            jrTextField.text = selectedValue;
//        }];
    };
    
    
    JRTextField* applicationTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"purpose"]).textField;
    JRTextField* applicationDescTxtField = ((JRTextField*)[self.jsonView getView:@"applicationDesc"]);
    applicationTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField){
        
        NSArray* orderTypes = @[MODEL_WHInventory, @"Contract", @"Other"];
        
        [PopBubbleView popTableBubbleView:jrTextField title:LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(ORDER_WHPickingOrder,@"purpose")) dataSource:[LocalizeHelper localize: orderTypes] selectedBlock:^(NSInteger selectedIndex, NSString *selectedValue) {
            
            NSArray* needFields = nil;
            if (selectedIndex == 0) {
                needFields = @[@"productCode",@"productName"];
            }else if(selectedIndex == 1){
                needFields = @[@"contractNO",@"contractName"];
            }
            
            if (needFields != nil) {
                NSString* model = orderTypes[selectedIndex];
                PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:model fields:needFields];
                pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
                    FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
                    NSArray* array = [filterTableView contentForIndexPath: indexPath];
                    jrTextField.text = [array objectAtIndex:0];
                    applicationDescTxtField.text = [array objectAtIndex:1];
                    [PickerModelTableView dismiss];
                };
            }else{
                jrTextField.text = selectedValue;
                applicationDescTxtField.text = @"";
            }
            
        }];
    };
    
    
    /*calculate totalPrice*/
    _pickingAmountTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"pickingAmount"]).textField;
    _pickingAmountTxtField.delegate = self;
    
    _totalPriceTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"totalPrice"]).textField;

}


#pragma mark -
#pragma mark - UITextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if (textField == _pickingAmountTxtField)
        _totalPriceTxtField.text = [AppMathUtility calculateMultiply:_pickingAmountTxtField.text,_priceTxtField.text,nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
