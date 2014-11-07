#import "JRRefreshTableView.h"

@interface JRImagesTableView : JRRefreshTableView


@property (readonly, strong) NSMutableArray* loadImages;

//  set from outside
@property (nonatomic, strong) NSMutableArray* loadImagesPaths;

//  set from outside
@property (assign) CGRect cellImageViewFrame;



#pragma mark - Public Methods

-(void) stopLazyLoading;

@end
