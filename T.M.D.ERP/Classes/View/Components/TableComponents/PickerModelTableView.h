#import <UIKit/UIKit.h>
#import "JRTitleHeaderTableView.h"


@interface PickerModelTableView : JRTitleHeaderTableView


#pragma mark - Class Pair Methods

+(PickerModelTableView*) popupWithModel:(NSString*)model;

+(PickerModelTableView*) popupWithRequestModel:(NSString*)model fields:(NSArray*)fields;

+(PickerModelTableView*) popupWithRequestModel:(NSString*)model fields:(NSArray*)fields criterias:(NSDictionary*)criterias;

+(void) dismiss;

@end
