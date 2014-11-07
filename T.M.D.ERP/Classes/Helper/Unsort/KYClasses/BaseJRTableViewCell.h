#import <UIKit/UIKit.h>

@class BaseJRTableViewCell;
typedef void(^DidEndEditNewCellAction) (BaseJRTableViewCell* cell);

@interface BaseJRTableViewCell : UITableViewCell

@property (copy) DidEndEditNewCellAction didEndEditNewCellAction;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier ;


-(void)setDatas:(id)cotents;

-(id)getDatas;


-(NSDictionary*)assembleCellSpecifications:(NSString*)order;

-(void)renderCellSubView:(NSString*)order;
-(void)renderFooterCellSubView:(NSString*)order;

@end
