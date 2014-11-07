#import "JsonController.h"
#define attr_financeAccountId @"financeAccountId"

@class JRTextField;

@class JRButtonsHeaderTableView;

@interface FinancePaymentOrderController : JsonController


- (void)updateDataSourcesWhenTextFieldDidEndEditing:(JRTextField *)jrTextField;

+(void) popPayWayTable: (JRTextField*)payWayTextfield selectedAction:(void(^)(JRButtonsHeaderTableView *sender, NSUInteger selectedIndex, NSString* selectedVisualValue))selectedAction;


@end
