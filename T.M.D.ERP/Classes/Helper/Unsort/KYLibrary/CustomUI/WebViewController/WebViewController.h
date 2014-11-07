#import <UIKit/UIKit.h>
#import "BaseController.h"


#define PDF_PREFIX @"PDF/"

#define PRODUCTPDF_PREFIX @"ProductPDF/"
#define PRODUCTPDF_PATH(_SUFFIX) [PDF_PREFIX stringByAppendingString:_SUFFIX]

#define CONTRACTPDF_PREFIX @"ContractPDF/"
#define CONTRACTPDF_PREFIXPATH [PDF_PREFIX stringByAppendingString: CONTRACTPDF_PREFIX]
#define CONTRACTPDF_PATH(_SUFFIX) [CONTRACTPDF_PREFIXPATH stringByAppendingString:_SUFFIX]

@interface WebViewController : BaseController


@property(nonatomic,strong)NSString* pdfURLString;


@end
