#import "PDFDataManager.h"
#import "AppInterface.h"




@implementation PDFDataManager


+(instancetype)sharedManager
{
    static PDFDataManager* sharedDataSource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataSource = [[PDFDataManager alloc] init];
        sharedDataSource->_PDFStack = [[NSMutableArray alloc] init];
        
    });
    return sharedDataSource;
}



-(void)requestPDFDirectoriesFilesWithComplete:(void(^)( ResponseJsonModel *response, NSError* error))callback{
    NSString* pdfDirectoryPath = PRODUCTPDF_PATH(PRODUCTPDF_PREFIX);
    [MODEL.requester startDownloadRequest:IMAGE_URL(DOWNLOAD) parameters:@{@"PATH":pdfDirectoryPath} completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        

        callback(response, error);

        
    }];

}



-(NSMutableDictionary*)assembleDataSource:(NSDictionary*)source key:(NSString*)basekey
{
    NSMutableDictionary* assembleDictionary = [NSMutableDictionary dictionary];
    NSMutableArray* subArray = [NSMutableArray array];
    for (NSString* key in [source allKeys]) {
        if ([source[key] isKindOfClass:[NSDictionary class]]) {
            NSDictionary* subDic = source[key];
            if (subDic[@"content"]) {
                 NSDictionary* contentDic = subDic[@"content"];
                [subArray addObject:[self assembleDataSource:contentDic key:key]];
            }else{
                [subArray addObject:key];
            }
        }
    }
    [assembleDictionary setObject:subArray forKey:basekey];
    
    return assembleDictionary;
}


#pragma mark -
#pragma mark -

+ (NSString*)getDictionaryKey:(NSDictionary*)dictionary
{
    NSString* key = [[dictionary allKeys] lastObject];
    return key;
}

+ (NSArray*)getDictionaryArray:(NSDictionary*)dictionary
{
    NSString* key = [PDFDataManager getDictionaryKey:dictionary];
    NSArray* content = [dictionary objectForKey:key];
    return content;
}

#pragma mark -
#pragma mark - 

+(void)addTextToContain:(NSString*)text contain:(NSMutableArray*)containArray
{
    if ([[[PDFDataManager sharedManager] PDFStack] count] == 0) return;
    
    NSString* stackString = [self assembleStackString:text];
    [containArray addObject:stackString];
    
}

+(void)removeTextFromContain:(NSString*)text contain:(NSMutableArray*)containArray
{
    if ([[[PDFDataManager sharedManager] PDFStack] count] == 0) return;
    NSString* stackString = [self assembleStackString:text];
    [containArray removeObject:stackString];
}

+(BOOL)judgeTextInContain:(NSString*)text contain:(NSMutableArray*)containArray
{
    if ([[[PDFDataManager sharedManager] PDFStack] count] == 0) return NO;
    
    NSString* stackString = [self assembleStackString:text];
    return [containArray containsObject:stackString];
    
}

+ (NSString*)assembleStackString:(NSString*)text
{
    NSString* stackString = @"";
    int count = [[[PDFDataManager sharedManager] PDFStack] count];
    NSMutableArray* stackArray = [[PDFDataManager sharedManager] PDFStack];
    for (int i = 0; i<count; ++i) {
        NSDictionary* dic = stackArray[i];
        NSString* subKey = [PDFDataManager getDictionaryKey:dic];
        stackString = [stackString stringByAppendingString:subKey];
        stackString = [stackString stringByAppendingString:@"/"];
    }
    
    stackString = [stackString stringByAppendingString:text];
    return stackString;
}



@end
