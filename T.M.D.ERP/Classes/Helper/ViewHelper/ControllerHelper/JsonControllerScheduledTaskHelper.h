#import <Foundation/Foundation.h>


@class JsonController;


@interface JsonControllerScheduledTaskHelper : NSObject


@property (assign) JsonController* jsonController;


-(void) viewWillDisappearUnRegisterCache;

-(void) viewWillAppearCheckRegisterCache;

-(void) didCreateOrderDeleteCacheFile;


@end
