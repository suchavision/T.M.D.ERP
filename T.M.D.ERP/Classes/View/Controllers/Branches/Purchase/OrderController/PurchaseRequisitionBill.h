#import "BaseJRTableViewCell.h"
#define attr_productCode            @"productCode"
#define attr_productName            @"productName"
#define attr_amount                 @"amount"
#define attr_unit                   @"unit"
#define attr_unitPriceOne              @"unitPriceOne"
#define attr_unitPriceTwo              @"unitPriceTwo"
#define attr_unitPriceThree             @"unitPriceThree"

@interface PurchaseRequisitionBill : BaseJRTableViewCell
@property (assign) NSMutableArray* requisitionTableViewDataSource;
@end
