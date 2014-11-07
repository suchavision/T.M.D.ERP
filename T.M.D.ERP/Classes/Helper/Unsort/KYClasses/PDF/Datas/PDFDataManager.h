#import <Foundation/Foundation.h>


@class ResponseJsonModel;


@interface PDFDataManager : NSObject

@property(nonatomic,strong)NSMutableDictionary* PDFDic;

@property(nonatomic,strong)NSMutableArray* PDFStack;

+ (instancetype)sharedManager;

-(void)requestPDFDirectoriesFilesWithComplete:(void(^)( ResponseJsonModel *response, NSError* error))callback;

+ (NSString*)getDictionaryKey:(NSDictionary*)dictionary;
+ (NSArray*)getDictionaryArray:(NSDictionary*)dictionary;

+ (void)addTextToContain:(NSString*)text contain:(NSMutableArray*)containArray;
+ (void)removeTextFromContain:(NSString*)text contain:(NSMutableArray*)containArray;
+ (BOOL)judgeTextInContain:(NSString*)text contain:(NSMutableArray*)containArray;

@end
