#import "FilterTableView+Additions.h"

@implementation FilterTableView (Additions)

-(id) getRealContentsAtIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath* realIndexPath = [self getRealIndexPathInFilterMode: indexPath];
    id value = [self realContentForIndexPath: realIndexPath];
    return value;
}

@end
