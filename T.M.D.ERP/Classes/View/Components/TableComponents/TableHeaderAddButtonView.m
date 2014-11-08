#import "TableHeaderAddButtonView.h"
#import "ClassesInterface.h"

@interface TableHeaderAddButtonView () <HeaderTableViewDeletage>

@end

@implementation TableHeaderAddButtonView

@synthesize addButton;


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // delete feature
        self.headersYcoordinates = @[@(20)];
        self.tableView.tableViewBaseCanEditIndexPathAction = ^BOOL(TableViewBase *tableView, NSIndexPath *indexPath) {
            return YES;
        };
        self.headerTableViewHeaderHeightAction = ^CGFloat(HeaderTableView* tableObj) {
          return [FrameTranslater convertCanvasHeight: 70.0f];
        };
        
        [self.searchBar setHiddenCancelButton: YES];
        
        // the add button
        addButton = [NormalButton buttonWithType:UIButtonTypeContactAdd];
        [addButton addOriginY:[FrameTranslater convertCanvasY: 8]];
        [self.headerView addSubview: addButton];
        
        
        [ColorHelper setBorder: self color:[UIColor grayColor]];
        [LayerHelper setAttributesValues: @{@"cornerRadius": @(5.0), @"masksToBounds": @(1)} layer:self.layer];
    }
    return self;
}


#pragma mark -
-(void)layoutSubviews
{
    [super layoutSubviews];
    [addButton setOriginX: [self.headerView sizeWidth] - [addButton sizeWidth]];
}

@end
