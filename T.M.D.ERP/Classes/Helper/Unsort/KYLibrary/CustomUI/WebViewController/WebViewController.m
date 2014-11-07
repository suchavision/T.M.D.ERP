#import "WebViewController.h"
#import "AppInterface.h"

#import "TCBlobDownloadManager.h"

@interface WebViewController ()<UIWebViewDelegate>

@end




@implementation WebViewController
{
    UIWebView* webView;
    
    JRButton* cancelButton;
    
    MBProgressHUD* HUD;
}

-(void)loadView
{
    webView =[[UIWebView alloc]initWithFrame: [RectHelper getScreenLandscapeRect]];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    self.view = webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak WebViewController* weakInstance = self;
    
    HUD = [[MBProgressHUD alloc] init];
	HUD.mode = MBProgressHUDModeDeterminate;
	HUD.labelText = @"Loading";
    [webView addSubview: HUD];
    
    UIImage* cancelImage = [UIImage imageNamed:@"public_取消按钮.png"];
    cancelButton = [[JRButton alloc] init];
    [self setCancelButtonFrame];
    [cancelButton setImage:cancelImage forState:UIControlStateNormal];
    cancelButton.didClikcButtonAction = ^void(JRButton* button) {
        [weakInstance dismissViewControllerAnimated: YES completion:nil];
    };
    [self.view addSubview:cancelButton];
    
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setCancelButtonFrame];
}

-(void) setCancelButtonFrame
{
    [UIView animateWithDuration: 0.2 animations:^{
        CGRect rect = CGRectMake(self.view.bounds.size.width - 50, 5, 40, 40);
        cancelButton.frame = rect;
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [HUD show: YES];
    
    MBProgressHUD* hub = HUD;
    UIWebView* webViewObj = webView;
    
    NSDictionary* paramenters = @{@"PATH":self.pdfURLString};
    HTTPPostRequest* httpGetRequest = [[HTTPPostRequest alloc] initWithURLString: IMAGE_URL(DOWNLOAD) parameters: paramenters timeoutInterval:60];
    NSMutableURLRequest* request = (NSMutableURLRequest*)httpGetRequest.request;
    [[TCBlobDownloadManager sharedDownloadManager] startDownloadWithRequest:request customPath:nil firstResponse:nil progress:^(float receivedLength, float totalLength) {
        hub.progress = receivedLength / totalLength;
    } error:^(NSError *error) {
        hub.labelText = @"Download Error";
        [hub hide: YES afterDelay:1];
    } complete:^(BOOL downloadFinished, NSString *pathToFile) {
        hub.labelText = @"Download Finished";
        [hub hide: YES afterDelay:1];
        
        NSLog(@"Download to path : %@", pathToFile);
        NSData* pdfDatas = [NSData dataWithContentsOfFile: pathToFile];
        [webViewObj loadData:pdfDatas MIMEType:@"application/pdf" textEncodingName:nil baseURL: nil];
        
        
        [FileManager deleteFile: pathToFile];
    }];
    
//    NSURL* URL = [NSURL URLWithString:@"http://192.168.0.202:8080/BIG.pdf"];
//    [[TCBlobDownloadManager sharedDownloadManager] startDownloadWithURL:URL customPath:nil firstResponse:nil progress:^(float receivedLength, float totalLength) {
//        hub.progress = receivedLength / totalLength;
//    } error:^(NSError *error) {
//        hub.labelText = @"Download Error";
//        [hub hide: YES afterDelay:1];
//    } complete:^(BOOL downloadFinished, NSString *pathToFile) {
//        hub.labelText = @"Download Finished";
//        [hub hide: YES afterDelay:1];
//
//
//        NSData* pdfDatas = [NSData dataWithContentsOfFile: pathToFile];
//        [webViewObj loadData:pdfDatas MIMEType:@"application/pdf" textEncodingName:nil baseURL: nil];
//    }];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [webView removeFromSuperview];
    webView = nil;
    
}




#pragma mark - WebView
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//}
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//}
//
//- (void)webViewDidStartLoad:(UIWebView *)webView {
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.mode = MBProgressHUDModeIndeterminate;
//    hud.labelText = @"Loading...";
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"%@ : didReceiveMemoryWarning", [self class]);
}

@end
