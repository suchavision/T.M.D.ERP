#import <UIKit/UIKit.h>
#import "BaseController.h"

@interface PDFMainViewController : BaseController <UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


@property(nonatomic,strong)UICollectionView* collectionView;


@property (strong) NSString* productPDFDirectoryPath;


@end
