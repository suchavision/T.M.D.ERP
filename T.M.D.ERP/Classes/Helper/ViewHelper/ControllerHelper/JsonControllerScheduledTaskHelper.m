#import "JsonControllerScheduledTaskHelper.h"

#import "AppInterface.h"


#define CacheIntervalTime 12


@implementation JsonControllerScheduledTaskHelper


@synthesize jsonController;



-(void) viewWillDisappearUnRegisterCache
{
    [ScheduledTask.sharedInstance unRegisterSchedule: self];
}


-(void) viewDidAppearCheckRegisterCache
{
    if (jsonController.controlMode == JsonControllerModeCreate) {
        // start
        [ScheduledTask.sharedInstance registerSchedule:self timeElapsed:CacheIntervalTime repeats:0];
        
        // get and set to view
        NSString* cachePath = [self getWritingFilePath: jsonController.department order:jsonController.order];
        NSDictionary* objects = [JsonFileManager getJsonFromPath: cachePath];
        if ([self needToWriteOrRenderCache: objects]) {
            NSMutableDictionary* valueObjects = [DictionaryHelper deepCopy: objects];
            [jsonController renderWithReceiveObjects: valueObjects];
        }
    }
}


-(void) didCreateOrderDeleteCacheFile
{
    NSString* cachePath = [self getWritingFilePath: jsonController.department order:jsonController.order];
    [FileManager deleteFile: cachePath];
}


#pragma mark - Scheduled Action

-(void) scheduledTask
{
    if (jsonController.controlMode != JsonControllerModeCreate) return;
    
    NSDictionary* withImagesObjects = [jsonController assembleSendObjects: nil];
    NSMutableDictionary* objects = [DictionaryHelper filter:withImagesObjects withType:[UIImage class]];
    
    if ([self needToWriteOrRenderCache: objects]) {
        NSString* jsonString = [CollectionHelper convertJSONObjectToJSONString: objects];
        NSString* cachePath = [self getWritingFilePath: jsonController.department order:jsonController.order];
        [FileManager writeDataToFile: cachePath data: [jsonString dataUsingEncoding: NSUTF8StringEncoding]];
    }
}


-(BOOL) needToWriteOrRenderCache: (NSDictionary*)objects
{
    int notEmptyCount = 0;
    for (NSString* key in objects) {
        if (!OBJECT_EMPYT(objects[key])) {
            notEmptyCount++;
        }
    }
    return notEmptyCount > 6;
}




-(NSString*) getWritingFilePath: (NSString*)department order:(NSString*)order
{
    
    return [[[[FileManager tempPath] stringByAppendingPathComponent: department] stringByAppendingPathComponent: order] stringByAppendingPathComponent: @"writing.json"];
}

@end
