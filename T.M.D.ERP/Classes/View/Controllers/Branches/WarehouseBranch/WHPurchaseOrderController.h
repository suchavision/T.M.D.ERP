#import "JsonController.h"

@interface WHPurchaseOrderController : JsonController

@property (strong, readonly) NSMutableArray* middleTableViewDataSource;
@property (strong) NSString* vendorNumber;
@end
