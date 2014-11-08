#import "BaseJRTableViewCell.h"
#define attr_productCode            @"productCode"
#define attr_productName            @"productName"
#define attr_amount                 @"amount"
#define attr_unit                   @"unit"
#define attr_unitPriceOne              @"unitPrice1"
#define attr_unitPriceTwo              @"unitPrice2"
#define attr_unitPriceThree             @"unitPrice3"

@interface PurchaseRequisitionBill : BaseJRTableViewCell
@property (assign) NSMutableArray* requisitionTableViewDataSource;
@end
