//
//  WHScrapOrderController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-18.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "WHScrapOrderController.h"
#import "AppInterface.h"

@interface WHScrapOrderController ()


@end

@implementation WHScrapOrderController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    JRTextField* productCodeTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"productCode"]).textField;
    JRTextField* productNameTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"productName"]).textField;
    __weak JRTextField* weakProductCodeTxtField = productCodeTxtField;
    productCodeTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField) {
        
        NSArray* needFields = @[@"productCode",@"productName",@"productCategory"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_WHInventory fields:needFields];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            
            NSArray* array = [filterTableView realContentForIndexPath: realIndexPath];
            weakProductCodeTxtField.text = [array objectAtIndex:1];
            productNameTxtField.text = [array objectAtIndex:2];
            
            [PickerModelTableView dismiss];
        };
        
    };
    
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
