#import "JsonController.h"

@interface PurchaseOrderController : JsonController


@property (strong, readonly) NSMutableArray* purchaseCellContents;


@property (strong) NSString* vendorNumber;


@end
