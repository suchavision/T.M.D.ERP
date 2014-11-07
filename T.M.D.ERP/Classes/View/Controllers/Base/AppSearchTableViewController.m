#import "AppSearchTableViewController.h"
#import "AppInterface.h"

#define HeaderHeight 50


@interface AppSearchTableViewController () 

@end

@implementation AppSearchTableViewController

@synthesize headerTableView;

-(id)init {
    self = [super init];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        headerTableView = [[JRRefreshTableView alloc] init];
        headerTableView.headerLabelClass = [JRLocalizeLabel class];
        
        [headerTableView.searchBar setHiddenCancelButton: YES];
        [headerTableView.searchBar setContentEdgeInsets: UIEdgeInsetsMake(CanvasH(2), CanvasW(0), CanvasH(2), CanvasW(0))];
        headerTableView.searchBar.backgroundColor = [UIColor clearColor];
        headerTableView.searchBar.textField.textAlignment = NSTextAlignmentCenter;
        headerTableView.searchBar.textField.placeholder = APPLOCALIZE_KEYS(@"local", @"SEARCH");
        headerTableView.searchBar.textField.borderStyle = UITextBorderStyleNone;
        [LayerHelper setAttributesValues:@{@"borderColor": @[@(193),@(193),@(193), @(0.5)], @"borderWidth": @(1), @"cornerRadius": @(2.0)} layer:headerTableView.searchBar.textField.layer];
        
        headerTableView.tableView.proxy = self;
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.headerTableView.searchBarHeight = CanvasH(70);
            self.headerTableView.headerTableViewHeaderHeightAction = ^CGFloat(HeaderTableView* tableView){
                return CanvasH(HeaderHeight) ;
            };
        }
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (! self.isMovingToParentViewController) {        // pop
        if (self.isPopNeedRefreshRequest) {
            [self requestForDataFromServer];
        }
    } else {                                            // push
        if (self.requestModel) {
            [self requestForDataFromServer];
        }
    }
    
    self.isPopNeedRefreshRequest = NO;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSArray* headers = self.headers;
        UIView* headerView = self.headerTableView.headerView;
        for (int i = 0; i < headers.count; i++) {
            JRLocalizeLabel* label = (JRLocalizeLabel*)[headerView viewWithTag:ALIGNTABLE_HEADER_LABEL_TAG(i)];
            
            label.font = [UIFont systemFontOfSize: [FrameTranslater convertFontSize: 25]];
            [label adjustWidthToFontText];
            [label setSizeHeight: [FrameTranslater convertCanvasHeight: HeaderHeight]];
            [label setCenterY: [FrameTranslater convertCanvasHeight: HeaderHeight]/2];
            
            // for easy to click
            if (label.sizeWidth <= 38) {
                label.sizeWidth = label.sizeWidth * 3/2;
            }
        }
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:headerTableView];
    [self initializeSubViewConstraints];
}

-(void) requestForDataFromServer
{
    if (! self.requestModel) return;
    
    if (! VIEW.isProgressShowing) {
        [VIEW.progress show];
        VIEW.progress.labelText = nil;
        VIEW.progress.detailsLabelText = nil;
    }
    
    [MODEL.requester startPostRequestWithAlertTips:self.requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        [self didReceiveDataFromServer: data error:error];
        
        if (VIEW.progress.labelText == nil && VIEW.progress.detailsLabelText == nil) {
            [VIEW.progress hide];
        }
    }];
}
-(void) didReceiveDataFromServer: (ResponseJsonModel*)data error:(NSError*)error
{
    if (data.status) {
        // load the data to view
        
        NSArray* keys = data.models;
        NSArray* objects = data.results;
        ContentFilterBlock filter = self.contentsFilter;
        
        AlignTableView* tableViewObj = self.headerTableView.tableView;
        NSMutableDictionary* realContentsDictionary = [TableViewBaseContentHelper assembleToRealContentDictionary: objects keys:keys];
        tableViewObj.realContentsDictionary = realContentsDictionary;
        NSMutableDictionary* contentsDictionary = [ListViewControllerHelper convertRealToVisualContents: realContentsDictionary filter:filter];
        tableViewObj.contentsDictionary = contentsDictionary;
        
        [self reloadTableData];
        
    }
}


#pragma mark - Public Methods

-(void) reloadTableData {
    headerTableView.tableView.filterText = headerTableView.tableView.filterText;
}

-(NSArray*) sections {
    return self.headerTableView.tableView.sections;
}

-(void)setHeaders:(NSArray *)headers
{
    _headers = headers;
    self.headerTableView.headers = [LocalizeHelper localize: headers];
}

-(void)setHeadersXcoordinates:(NSArray *)headersXcoordinates
{
    _headersXcoordinates = headersXcoordinates;
    self.headerTableView.headersXcoordinates = headersXcoordinates;
}

-(void)setValuesXcoordinates:(NSArray *)valuesXcoordinates
{
    _valuesXcoordinates = valuesXcoordinates;
    self.headerTableView.valuesXcoordinates = valuesXcoordinates;
}

-(NSMutableDictionary*) realContentsDictionary
{
    return headerTableView.tableView.realContentsDictionary;
}

-(void) setRealContentsDictionary:(NSMutableDictionary *)realContentsDictionary
{
    headerTableView.tableView.realContentsDictionary = realContentsDictionary;
}

-(NSMutableDictionary*) contentsDictionary
{
    return headerTableView.tableView.contentsDictionary;
}

-(void) setContentsDictionary:(NSMutableDictionary *)contentsDictionary
{
    headerTableView.tableView.contentsDictionary = contentsDictionary;
}


#pragma mark - Public Methods

-(id) valueForIndexPath: (NSIndexPath*)indexPath
{
    return [headerTableView.tableView realContentForIndexPath: indexPath];
}

-(id) getIdentification: (NSIndexPath*)indexPath {
    return [[self valueForIndexPath: indexPath] firstObject];
}



#pragma mark - TableViewBaseTableProxy
- (void)tableViewBase:(TableViewBase *)tableViewObj didSelectIndexPath:(NSIndexPath*)indexPath
{
    [self appSearchTableViewController: self didSelectIndexPath:indexPath];
}

- (NSString*)tableViewBase:(TableViewBase *)tableViewObj titleForDeleteButtonAtIndexPath:(NSIndexPath*)indexPath
{
    return LOCALIZE_KEY(KEY_DELETE);
}

- (void)tableViewBase:(TableViewBase *)tableViewObj willShowCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        int iphoneFontSize = CanvasFontSize(30);
        
        // restore
        for (UILabel* label in cell.contentView.subviews) {
            if([label isKindOfClass: [UILabel class]] && !label.hidden) {
                label.font = [UIFont systemFontOfSize: iphoneFontSize];
                [label adjustWidthToFontText];
                [label setSizeHeight: CanvasH(70)];
                [label setCenterY: [cell sizeHeight]/2];
            }
        }
        
        
        
        
        // adjust
        for (int i = 0; i < self.headers.count - 1; i++) {
            int tag = ALIGNTABLE_CELL_LABEL_TAG(i);
            UILabel* label = (UILabel*)[cell.contentView viewWithTag: tag];
            UILabel* nextLabel = (UILabel*)[cell.contentView viewWithTag: tag + 1];
            if (!nextLabel) continue;
            
            int size = iphoneFontSize;
            while (label.originX + label.sizeWidth - nextLabel.originX > 0) {
                size -= 2;
                if (size < 5) break;
                label.font = [UIFont systemFontOfSize: size];
                [label adjustWidthToFontText];
            }
        }
    }

    if (self.willShowCellBlock) self.willShowCellBlock(self, indexPath, cell);
}

- (CGFloat)tableViewBase:(TableViewBase *)tableViewObj heightForIndexPath:(NSIndexPath*)indexPath
{
    return [FrameTranslater convertCanvasHeight:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 80 : 50];
}





#pragma mark - For Subclass Override Methods

-(void) appSearchTableViewController: (AppSearchTableViewController*)controller didSelectIndexPath:(NSIndexPath*)indexPath
{
    if (self.appTableDidSelectRowBlock) {
        NSIndexPath* realIndexPath = [controller.headerTableView.tableView getRealIndexPathInFilterMode: indexPath];
        self.appTableDidSelectRowBlock(self, realIndexPath);
    }
}



#pragma mark - Private Methods
-(void) initializeSubViewConstraints
{
    [headerTableView setTranslatesAutoresizingMaskIntoConstraints: NO];
    float barHeight = VIEW.navigator.navigationBar.frame.size.height;
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"|-0-[headerTableView]-0-|"
                               options:NSLayoutFormatAlignAllTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(headerTableView)]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-(barHeight)-[headerTableView]-0-|"
                               options:NSLayoutFormatAlignAllTrailing
                               metrics:@{@"barHeight":@(barHeight)}
                               views:NSDictionaryOfVariableBindings(headerTableView)]];
}



@end