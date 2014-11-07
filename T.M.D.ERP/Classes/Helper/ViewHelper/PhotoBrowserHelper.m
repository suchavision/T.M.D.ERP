#import "PhotoBrowserHelper.h"
#import "AppInterface.h"

@implementation PhotoBrowserHelper

MWPhotoBrowser* photoBrowser = nil;
NSMutableArray* mwPhotos = nil;
UINavigationController *navigationController = nil;

+(void) browser: (NSArray*)resouces resourcesIsURL:(BOOL)resourcesIsURL currentIndex:(NSUInteger)currentIndex
{
    if (!photoBrowser) {
        photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:(id<MWPhotoBrowserDelegate>)self];
        photoBrowser.displayActionButton = YES;
        photoBrowser.displayNavArrows = NO;
        photoBrowser.wantsFullScreenLayout = YES;
        photoBrowser.zoomPhotosToFill = NO;
        
    }
    if (!navigationController) {
        navigationController = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
    }
    
    // data sources
    if (! mwPhotos) {
        mwPhotos = [NSMutableArray array];
    } else {
        [mwPhotos removeAllObjects];
    }
    
    for (int i = 0; i < resouces.count; i++) {
        MWPhoto* mwPhoto = nil;
        
        if (resourcesIsURL) {
            NSString* loadPath = resouces[i];
            NSString* fullImageURL = [NSString stringWithFormat:@"%@?%@",IMAGE_URL(DOWNLOAD),loadPath];
            mwPhoto = [[MWPhoto alloc] initWithURL: [NSURL URLWithString:fullImageURL]];
        } else {
            UIImage* image = resouces[i];
            mwPhoto = [[MWPhoto alloc] initWithImage: image];
        }
        
        [mwPhotos addObject: mwPhoto];
    }
    
    [photoBrowser setCurrentPhotoIndex: currentIndex];
    
    [[ViewHelper getTopViewController] presentViewController:navigationController animated:YES completion:nil];
}




#pragma mark - MWPhotoBrowserDelegate methods

+ (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return mwPhotos.count;
}
+ (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    return [mwPhotos objectAtIndex:index];
}

@end
