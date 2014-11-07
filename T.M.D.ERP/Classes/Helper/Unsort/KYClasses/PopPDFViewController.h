#import <UIKit/UIKit.h>

@interface PopPDFTableViewCell : UITableViewCell

@property(nonatomic,strong)UIImageView* checkImageView;
@property (nonatomic, assign) BOOL isSelected;


@end


typedef void (^PopViewSelectValueBlock)(NSMutableArray* selectArray);

@interface PopPDFViewController : UIViewController

@property(nonatomic,copy)PopViewSelectValueBlock selectBlock;
@property(nonatomic,strong)NSMutableArray* selectedMarks;
@property(nonatomic,copy)NSString* title;
@property(nonatomic,strong)NSArray* pathArray;


@end
