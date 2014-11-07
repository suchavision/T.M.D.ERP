
#define attr_paymentOrderNO             @"paymentOrderNO"

#define attr_referenceOrderType          @"referenceOrderType"
#define attr_referenceOrderNO       @"referenceOrderNO"
#define attr_productName            @"productName"
#define attr_realPaid               @"realPaid"
#define attr_shouldPay              @"shouldPay"


@class JRTextField;
@class FinancePaymentOrderController;

@interface FinancePaymentBillCell : UIView

@property (strong) NSString* order;


@property (strong) JRTextField* itemOrderNOTf;
@property (strong) JRTextField* productNameTf;
@property (strong) JRTextField* shouldPayTf;
@property (strong) JRTextField* alreadPayTf ;
@property (strong) JRTextField* unpaidTextField;


@property (weak) FinancePaymentOrderController* paymentController;


-(void) setBillValues: (NSMutableDictionary*)values;
-(NSMutableDictionary*) getBillValues;

@end
