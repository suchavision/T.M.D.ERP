#import "PDFMainViewController.h"
#import "AppInterface.h"



#define cellReuseIdentifier  @"cellReuseIdentifier"


@interface PDFMainViewController ()
{
    NSMutableArray* dataSources;
    
    // for save button ------------
    NSMutableArray* newTempPaths;
    NSMutableArray* deleteTempPaths;
    // for save button ------------
}

@end

@implementation PDFMainViewController



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.isMovingToParentViewController) {
        return;
    }
    
    [VIEW.progress show];
    [MODEL.requester startDownloadRequest:IMAGE_URL(DOWNLOAD) parameters:@{@"PATH": self.productPDFDirectoryPath} completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        [VIEW.progress hide];
        
        if (response.status) {
            NSMutableArray* results = [response.results mutableCopy];
            dataSources = results;
            
            [self.collectionView reloadData];
        }
        
    }];

    NSString* title = [self.productPDFDirectoryPath stringByReplacingOccurrencesOfString:PRODUCTPDF_PATH(PRODUCTPDF_PREFIX) withString:@""];        // "A/B/C/"
//    self.navigationItem.title = [title length] > 2 ? [title substringToIndex: [title length] - 2] : title;
    self.navigationItem.title = [title lastPathComponent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.itemSize = CanvasSize(220, 260);
    layout.sectionInset = UIEdgeInsetsMake(CanvasH(20), CanvasW(15), CanvasH(20), CanvasW(15));
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];

    [self.collectionView registerClass:[PDFCollectionCell class] forCellWithReuseIdentifier:cellReuseIdentifier];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.collectionView];
    


    // for save button ------------
    deleteTempPaths = [NSMutableArray array];
    newTempPaths = [NSMutableArray array];
    UIBarButtonItem* saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveToInventorySelectedPaths)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    // for save button ------------
}


#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [dataSources count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray* selectedSavedFilePaths = [PDFMainViewController getWHInventoryController].selectedAndSavedFilePaths;
    
    id object = [dataSources objectAtIndex:indexPath.row];
    NSString* fileName = object;
    PDFCollectionCell* cell = (PDFCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    [cell hideIcon];
    cell.fileName = fileName;
    
    NSString* filePath = [self.productPDFDirectoryPath stringByAppendingPathComponent:fileName];
    
    if ([selectedSavedFilePaths containsObject: filePath]) {
        [cell showSaveIcon];
    }
    
    if ([newTempPaths containsObject: filePath]) {
        [cell showIcon];
    }
    
    if ([deleteTempPaths containsObject: filePath]) {
        [cell showDeleteIcon];
    }
    
    NSString* extension = [fileName pathExtension];
    cell.isDirectory = [extension isEqualToString:@""];
    
    cell.cellTapAction = ^(PDFCollectionCell* cell){
        
        // is Directory
        if(cell.isDirectory) {
            PDFMainViewController* mainPDFController = [[PDFMainViewController alloc] init];
            mainPDFController.productPDFDirectoryPath = [self.productPDFDirectoryPath stringByAppendingPathComponent: object];
            mainPDFController.productPDFDirectoryPath = [mainPDFController.productPDFDirectoryPath stringByAppendingString:@"/"];
            [self.navigationController pushViewController:mainPDFController animated:YES];
            
            // is PDF File
        } else {
            
            NSString* fileName = cell.fileName;
            NSString* filePath = [self.productPDFDirectoryPath stringByAppendingPathComponent:fileName];
//            if ([selectedSavedFilePaths containsObject: filePath]) {
//                [selectedSavedFilePaths addObject: filePath];
//            } else {
//                [selectedSavedFilePaths removeObject: filePath];
//            }
            
            // for save button ------------
            if ([selectedSavedFilePaths containsObject: filePath]) {
                if (![deleteTempPaths containsObject: filePath]) {
                    [deleteTempPaths addObject: filePath];
                } else {
                    [deleteTempPaths removeObject: filePath];
                }
            } else {
                if (![newTempPaths containsObject: filePath]) {
                    [newTempPaths addObject: filePath];
                } else {
                    [newTempPaths removeObject: filePath];
                }
            }
            // for save button ------------
            
            
        }
        
        [collectionView reloadItemsAtIndexPaths: @[indexPath]];
    };
    
    return cell;
}


// for save button ------------
-(void) saveToInventorySelectedPaths
{
    NSMutableArray* selectedSavedFilePaths = [PDFMainViewController getWHInventoryController].selectedAndSavedFilePaths;

    //
    for (int i = 0; i < newTempPaths.count; i++) {
        [selectedSavedFilePaths addObject: newTempPaths[i]];
    }
    [newTempPaths removeAllObjects];
    
    //
    for (int i = 0; i < deleteTempPaths.count; i++) {
        [selectedSavedFilePaths removeObject: deleteTempPaths[i]];
    }
    [deleteTempPaths removeAllObjects];
    
    //
    [selectedSavedFilePaths setArray:[ArrayHelper eliminateDuplicates: selectedSavedFilePaths]];
    
    [self.collectionView reloadData];
}
// for save button ------------


+(WHInventoryController*) getWHInventoryController
{
    for (int i = VIEW.navigator.viewControllers.count - 1; i >= 0 ; i--) {
        UIViewController* controller = [VIEW.navigator.viewControllers objectAtIndex: i];
        if ([controller isKindOfClass:[WHInventoryController class]]) {
            return (WHInventoryController*)controller;
        }
    }
    return nil;
}

@end
