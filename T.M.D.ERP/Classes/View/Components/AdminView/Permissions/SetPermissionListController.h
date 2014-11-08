#import "AppSearchTableViewController.h"

@interface SetPermissionListController : AppSearchTableViewController

@property (assign) NSMutableDictionary* orderPermissions;

- (id)initWithDepartment: (NSString*)department;

-(void) setupAllCellsByOrders: (NSArray*)orders;

@end
